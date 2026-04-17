package com.example.dotz

import android.content.SharedPreferences
import android.graphics.*
import android.os.Handler
import android.os.Looper
import android.service.wallpaper.WallpaperService
import android.view.SurfaceHolder
import kotlin.math.ceil
import kotlin.math.cos
import kotlin.math.sin
import kotlin.math.sqrt
import java.util.Calendar

class DotzLiveWallpaper : WallpaperService() {
    override fun onCreateEngine(): Engine = DotzEngine()

    inner class DotzEngine : Engine(),
        SharedPreferences.OnSharedPreferenceChangeListener {

        private val PREFS_NAME = "dotz_prefs"

        private val handler = Handler(Looper.getMainLooper())
        private var prefs: SharedPreferences? = null
        private var isVisible = false

        // ── Settings ───────────────────────────────────────────
        private var bgColor       = Color.BLACK
        private var pastColor     = Color.WHITE
        private var futureColor   = Color.parseColor("#2A2A2A")
        private var todayColor    = Color.parseColor("#FF4500")
        private var labelColor    = Color.WHITE
        private var labelFontSizeSp = 0f
        private var columns       = 20
        private var showLabel     = true
        private var labelMode     = 1

        private var customLabel   = ""
        private var quoteApiUrl   = ""
        private var bgImagePath   = ""
        private var mode          = 0
        private var dotShape      = 0 // 0=Circle, 1=Square, 2=Star, 3=Glass

        // Goal
        private var goalTotalDays = 100
        private var goalPastDays  = 0
        private var goalName      = "Goal"

        // Life
        private var lifeTotalDays = 29200
        private var lifeDaysLived = 0

        // ── Render state ───────────────────────────────────────
        private var dotRadius  = 0f
        private var dotSpacing = 0f
        private var renderCols = 20
        private var cachedBitmap: Bitmap? = null
        private var lastDrawnDay = -1

        private var gridBottomY = 0f

        private val paintPast   = Paint(Paint.ANTI_ALIAS_FLAG)
        private val paintFuture = Paint(Paint.ANTI_ALIAS_FLAG)
        private val paintToday  = Paint(Paint.ANTI_ALIAS_FLAG)
        private val paintText   = Paint(Paint.ANTI_ALIAS_FLAG)

        // Used for the "Glass" shape
        private val paintGlassFill = Paint(Paint.ANTI_ALIAS_FLAG)
        private val paintGlassRim  = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.STROKE
            strokeWidth = 2f
            color = Color.argb(100, 255, 255, 255)
        }

        // ── Runnables ──────────────────────────────────────────
        private val prefsRunnable = Runnable {
            loadPrefs()
            val f = surfaceHolder.surfaceFrame
            if (f.width() > 0 && f.height() > 0) recalc(f.width(), f.height())
        }

        private fun fetchNewQuoteAsync() {
            Thread {
                try {
                    val url = java.net.URL(quoteApiUrl)
                    val connection = url.openConnection() as java.net.HttpURLConnection
                    connection.requestMethod = "GET"
                    connection.setRequestProperty("Accept", "application/json")
                    connection.connectTimeout = 8000
                    connection.readTimeout = 8000

                    if (connection.responseCode == 200) {
                        val response = connection.inputStream.bufferedReader().use { it.readText() }
                        val jsonArray = org.json.JSONArray(response)
                        
                        if (jsonArray.length() > 0) {
                            val item = jsonArray.getJSONObject(0)
                            val q = item.optString("q", "").trim()
                            val a = item.optString("a", "").trim()
                            
                            val newQuote = if (a.isNotEmpty()) "\"$q\" — $a" else "\"$q\""
                            
                            handler.post {
                                prefs?.edit()?.putString("customLabel", newQuote)?.apply()
                            }
                        }
                    }
                } catch (e: Exception) {
                    e.printStackTrace()
                    handler.post {
                        val f = surfaceHolder.surfaceFrame
                        if (f.width() > 0 && f.height() > 0) buildCache(f.width(), f.height())
                    }
                }
            }.start()
        }

        private val drawRunnable = object : Runnable {
            override fun run() {
                if (!isVisible) return
                val today = dayOfYear()
                if (today != lastDrawnDay) {
                    lastDrawnDay = today
                    
                    if (labelMode == 2 && quoteApiUrl.isNotEmpty()) {
                        fetchNewQuoteAsync()
                    } else {
                        val f = surfaceHolder.surfaceFrame
                        if (f.width() > 0 && f.height() > 0) buildCache(f.width(), f.height())
                    }
                }
                drawFrame()
                handler.postDelayed(this, 60_000L) 
            }
        }

        // ── Lifecycle ──────────────────────────────────────────
        override fun onCreate(holder: SurfaceHolder) {
            super.onCreate(holder)
            prefs = getSharedPreferences(PREFS_NAME, MODE_PRIVATE)
            prefs?.registerOnSharedPreferenceChangeListener(this)
            
            paintText.textAlign = Paint.Align.CENTER
            loadPrefs()
        }

        override fun onDestroy() {
            super.onDestroy()
            prefs?.unregisterOnSharedPreferenceChangeListener(this)
            handler.removeCallbacks(drawRunnable)
            handler.removeCallbacks(prefsRunnable)
            cachedBitmap?.recycle()
            cachedBitmap = null
        }

        override fun onSharedPreferenceChanged(sp: SharedPreferences?, key: String?) {
            handler.removeCallbacks(prefsRunnable)
            handler.postDelayed(prefsRunnable, 80L)
        }

        // ── Load prefs ─────────────────────────────────────────
        private fun loadPrefs() {
            prefs?.let { p ->
                bgColor           = p.getInt("bgColor",         Color.BLACK)
                pastColor         = p.getInt("pastColor",       Color.WHITE)
                futureColor       = p.getInt("futureColor",     Color.parseColor("#2A2A2A"))
                todayColor        = p.getInt("todayColor",      Color.parseColor("#FF4500"))
                labelColor        = p.getInt("labelColor",      Color.WHITE) 
                labelFontSizeSp   = p.getFloat("labelFontSize", 0f) 
                columns           = p.getInt("columns",         20)
                showLabel         = p.getBoolean("showLabel",   true)
                labelMode         = p.getInt("labelMode",       1)
                
                customLabel       = p.getString("customLabel",  "") ?: ""
                quoteApiUrl       = p.getString("apiUrl",       "") ?: "" 
                bgImagePath       = p.getString("bgImagePath",  "") ?: ""
                mode              = p.getInt("mode",            0)
                dotShape          = p.getInt("dotShape",        0) // ADDED SHAPE PROPERTY
                
                goalTotalDays     = p.getInt("goalTotal",       100)
                goalPastDays      = p.getInt("goalPast",        0)
                goalName          = p.getString("goalName",     "Goal") ?: "Goal"
                lifeTotalDays     = p.getInt("lifeTotal",       29200)
                lifeDaysLived     = p.getInt("lifeLived",       0)

                // Update stroke caps based on shape
                val cap = if (dotShape == 1) Paint.Cap.SQUARE else Paint.Cap.ROUND
                paintPast.strokeCap   = cap
                paintFuture.strokeCap = cap
                paintToday.strokeCap  = cap
            }
        }

        // ── Dot counts ─────────────────────────────────────────
        private fun totalDots(): Int = when (mode) {
            1    -> goalTotalDays.coerceAtLeast(1)
            2    -> lifeTotalDays.coerceAtLeast(1)
            3    -> daysInYear()
            else -> daysInYear()
        }

        private fun pastDots(): Int = when (mode) {
            1    -> goalPastDays.coerceIn(0, totalDots())
            2    -> lifeDaysLived.coerceIn(0, totalDots())
            3    -> (dayOfYear() - 1).coerceIn(0, totalDots())
            else -> (dayOfYear() - 1).coerceIn(0, totalDots())
        }

        private fun resolvedLabel(): String {
            if (!showLabel || labelMode == 0) return ""
            if (labelMode == 2 || labelMode == 3) {
                return if (customLabel.isNotBlank()) customLabel else computeProgressLabel()
            }
            return computeProgressLabel()
        }

        private fun computeProgressLabel(): String = when (mode) {
            1 -> "${(goalTotalDays - goalPastDays).coerceAtLeast(0)} left · $goalName"
            2 -> {
                val left = (lifeTotalDays - lifeDaysLived).coerceAtLeast(0)
                val pct  = if (lifeTotalDays > 0) (lifeDaysLived * 100 / lifeTotalDays) else 0
                "$left days left · $pct%"
            }
            else -> {
                val left = daysInYear() - dayOfYear()
                val pct  = (dayOfYear().toFloat() / daysInYear() * 100).toInt()
                "$left days left · $pct%"
            }
        }

        // ── Geometry ───────────────────────────────────────────
        private fun recalc(w: Int, h: Int) {
            val total  = totalDots()
            val availW = w * 0.90f
            val availH = h * 0.88f

            val effectiveCols = if (mode == 2 && total > 1000) {
                sqrt(total.toDouble() * w / h).toInt().coerceIn(30, 120)
            } else {
                columns
            }

            var r = availW / (effectiveCols * 2.5f - 0.5f)
            val rows0  = ceil(total.toFloat() / effectiveCols).toInt()
            val gridH0 = rows0 * (r * 2.5f) - r * 0.5f
            if (gridH0 > availH) {
                val rH = availH / (rows0 * 2.5f - 0.5f)
                if (rH < r) r = rH
            }

            dotRadius  = r.coerceIn(1.5f, 28f)
            dotSpacing = dotRadius * 0.5f
            renderCols = effectiveCols

            val d = dotRadius * 2f
            paintPast.strokeWidth   = d
            paintFuture.strokeWidth = d
            paintToday.strokeWidth  = d

            lastDrawnDay = dayOfYear()
            buildCache(w, h)
            drawFrame()
        }

        // ── Shape Drawing Helpers ──────────────────────────────
        private fun drawShapes(canvas: Canvas, pts: FloatArray, count: Int, paint: Paint) {
            if (count == 0) return

            when (dotShape) {
                0, 1 -> {
                    // 0 = Circle (ROUND cap), 1 = Square (SQUARE cap)
                    // Fast native drawing
                    canvas.drawPoints(pts, 0, count, paint)
                }
                2 -> {
                    // 2 = Star
                    for (i in 0 until count step 2) {
                        val cx = pts[i]
                        val cy = pts[i + 1]
                        val path = createStarPath(cx, cy, dotRadius, dotRadius * 0.45f, 5)
                        canvas.drawPath(path, paint)
                    }
                }
                3 -> {
                    // 3 = Glass
                    paintGlassFill.color = Color.argb(128, Color.red(paint.color), Color.green(paint.color), Color.blue(paint.color))
                    for (i in 0 until count step 2) {
                        val cx = pts[i]
                        val cy = pts[i + 1]
                        canvas.drawCircle(cx, cy, dotRadius, paintGlassFill)
                        canvas.drawCircle(cx, cy, dotRadius, paintGlassRim)
                    }
                }
            }
        }

        private fun createStarPath(cx: Float, cy: Float, outerRadius: Float, innerRadius: Float, numPoints: Int): Path {
            val path = Path()
            val step = Math.PI / numPoints
            var angle = -Math.PI / 2.0 

            for (i in 0 until numPoints * 2) {
                val radius = if (i % 2 == 0) outerRadius else innerRadius
                val dx = (cx + cos(angle) * radius).toFloat()
                val dy = (cy + sin(angle) * radius).toFloat()
                if (i == 0) {
                    path.moveTo(dx, dy)
                } else {
                    path.lineTo(dx, dy)
                }
                angle += step
            }
            path.close()
            return path
        }

        // ── Build cached bitmap ────────────────────────────────
        private fun buildCache(w: Int, h: Int) {
            if (w <= 0 || h <= 0) return
            cachedBitmap?.recycle()
            cachedBitmap = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
            val canvas   = Canvas(cachedBitmap!!)

            // --- BACKGROUND IMAGE LOGIC ---
            if (bgImagePath.isNotEmpty()) {
                try {
                    val bgImg = BitmapFactory.decodeFile(bgImagePath)
                    if (bgImg != null) {
                        val scale = maxOf(w.toFloat() / bgImg.width, h.toFloat() / bgImg.height)
                        val dx = (w - bgImg.width * scale) / 2f
                        val dy = (h - bgImg.height * scale) / 2f

                        val matrix = Matrix().apply {
                            postScale(scale, scale)
                            postTranslate(dx, dy)
                        }
                        
                        canvas.drawBitmap(bgImg, matrix, Paint(Paint.FILTER_BITMAP_FLAG))
                        canvas.drawColor(Color.argb(120, 0, 0, 0)) 
                        bgImg.recycle() 
                    } else {
                        canvas.drawColor(bgColor) 
                    }
                } catch (e: Exception) {
                    canvas.drawColor(bgColor) 
                }
            } else {
                canvas.drawColor(bgColor) 
            }
            // ----------------------------------

            // ── SET COLORS ──
            paintPast.color = pastColor
            paintFuture.color = futureColor
            paintToday.color = todayColor

            // ── DRAW GRIDS BASED ON MODE ──
            if (mode == 3) {
                // ── MONTHLY / WEEKLY MODE ──
                val monthNames = arrayOf("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
                val year = Calendar.getInstance().get(Calendar.YEAR)
                val todayDoy = dayOfYear()

                val availW = w * 0.85f
                val availH = h * 0.65f
                val blockW = availW / 3f
                val blockH = availH / 4f

                val cell = (blockW * 0.80f) / 7f
                dotRadius = (cell * 0.8f) / 2f
                
                val d = dotRadius * 2f
                paintPast.strokeWidth = d
                paintFuture.strokeWidth = d
                paintToday.strokeWidth = d

                val startX = (w - availW) / 2f + (blockW * 0.1f)
                val startY = (h - availH) / 2f + (h * 0.05f)
                gridBottomY = startY + availH

                val pastPts = FloatArray(366 * 2)
                val futurePts = FloatArray(366 * 2)
                val todayPt = FloatArray(2)
                var pIdx = 0; var fIdx = 0; var drewToday = false
                var currentDoy = 1

                paintText.color = labelColor
                paintText.textSize = dotRadius * 3.5f
                paintText.textAlign = Paint.Align.LEFT
                paintText.typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)

                for (m in 0 until 12) {
                    val cal = Calendar.getInstance()
                    cal.set(Calendar.YEAR, year)
                    cal.set(Calendar.MONTH, m)
                    val days = cal.getActualMaximum(Calendar.DAY_OF_MONTH)

                    val bx = startX + (m % 3) * blockW
                    val by = startY + (m / 3) * blockH

                    canvas.drawText(monthNames[m], bx, by, paintText)
                    val gridStartY = by + paintText.textSize * 1.2f

                    for (day in 0 until days) {
                        val col = day % 7
                        val row = day / 7
                        val cx = bx + col * cell + dotRadius
                        val cy = gridStartY + row * cell + dotRadius

                        when {
                            currentDoy < todayDoy -> {
                                pastPts[pIdx++] = cx; pastPts[pIdx++] = cy
                            }
                            currentDoy == todayDoy -> {
                                todayPt[0] = cx; todayPt[1] = cy; drewToday = true
                            }
                            else -> {
                                futurePts[fIdx++] = cx; futurePts[fIdx++] = cy
                            }
                        }
                        currentDoy++
                    }
                }

                // ── DRAW SHAPES ──
                drawShapes(canvas, pastPts, pIdx, paintPast)
                if (drewToday) drawShapes(canvas, todayPt, 2, paintToday)
                drawShapes(canvas, futurePts, fIdx, paintFuture)

                paintText.textAlign = Paint.Align.CENTER
                paintText.typeface = Typeface.DEFAULT

            } else {
                // ── STANDARD MODES (0, 1, 2) ──
                val total    = totalDots()
                val safePast = pastDots().coerceIn(0, total)
                val futCount = (total - safePast - 1).coerceAtLeast(0)

                val pastPts   = FloatArray(safePast * 2)
                val todayPt   = FloatArray(2)
                val futurePts = FloatArray(futCount * 2)
                var pIdx = 0; var fIdx = 0; var drewToday = false

                val cell  = dotRadius * 2f + dotSpacing
                val rows  = ceil(total.toFloat() / renderCols).toInt()
                val gridW = renderCols * cell - dotSpacing
                val gridH = rows       * cell - dotSpacing

                val ox = (w - gridW) / 2f
                val oy = (h - gridH) / 2f
                gridBottomY = oy + gridH

                for (i in 0 until total) {
                    val cx = ox + (i % renderCols) * cell + dotRadius
                    val cy = oy + (i / renderCols) * cell + dotRadius
                    when {
                        i < safePast  -> {
                            if (pIdx + 1 < pastPts.size) { pastPts[pIdx++] = cx; pastPts[pIdx++] = cy }
                        }
                        i == safePast -> { todayPt[0] = cx; todayPt[1] = cy; drewToday = true }
                        else          -> {
                            if (fIdx + 1 < futurePts.size) { futurePts[fIdx++] = cx; futurePts[fIdx++] = cy }
                        }
                    }
                }

                // ── DRAW SHAPES ──
                drawShapes(canvas, pastPts, pIdx, paintPast)
                if (drewToday) drawShapes(canvas, todayPt, 2, paintToday)
                drawShapes(canvas, futurePts, fIdx, paintFuture)
            }

            // ── Label ─────────────────────────────────────────
            val label = resolvedLabel()
            if (label.isNotEmpty()) {
                val density    = resources.displayMetrics.density
                val textSizePx = if (labelFontSizeSp > 0f) {
                    labelFontSizeSp * density
                } else {
                    (dotRadius * 1.8f).coerceAtLeast(10f * density)
                }

                paintText.color         = labelColor
                paintText.textSize      = textSizePx
                paintText.letterSpacing = 0.04f

                val gap    = dotRadius * 3f
                val startY = gridBottomY + gap + textSizePx

                val isLong = label.length > 60 && (labelMode == 2 || labelMode == 3)
                val lineH  = textSizePx * 1.45f
                if (isLong) {
                    drawWrappedText(canvas, label, w / 2f, startY, w * 0.85f, lineH, paintText)
                } else {
                    canvas.drawText(label, w / 2f, startY, paintText)
                }
            }
        }

        private fun drawWrappedText(
            canvas: Canvas, text: String,
            x: Float, startY: Float,
            maxWidth: Float, lineHeight: Float,
            paint: Paint
        ) {
            val words = text.split(" ")
            var line  = ""
            var y     = startY
            for (word in words) {
                val test = if (line.isEmpty()) word else "$line $word"
                if (paint.measureText(test) <= maxWidth) {
                    line = test
                } else {
                    if (line.isNotEmpty()) canvas.drawText(line, x, y, paint)
                    line = word
                    y   += lineHeight
                }
            }
            if (line.isNotEmpty()) canvas.drawText(line, x, y, paint)
        }

        // ── Surface callbacks ──────────────────────────────────
        override fun onSurfaceChanged(holder: SurfaceHolder, format: Int, w: Int, h: Int) {
            super.onSurfaceChanged(holder, format, w, h)
            recalc(w, h)
        }

        override fun onDesiredSizeChanged(dw: Int, dh: Int) {
            super.onDesiredSizeChanged(dw, dh)
            surfaceHolder.setFixedSize(dw, dh)
        }

        override fun onOffsetsChanged(xo: Float, yo: Float, xos: Float, yos: Float, xpo: Int, ypo: Int) {}

        override fun onVisibilityChanged(visible: Boolean) {
            isVisible = visible
            if (visible){
                handler.post(drawRunnable)
            }
            else {
                handler.removeCallbacks(drawRunnable)
            }
        }

        private fun drawFrame() {
            var canvas: Canvas? = null
            try {
                canvas = surfaceHolder.lockCanvas() ?: return
                cachedBitmap?.let { canvas.drawBitmap(it, 0f, 0f, null) }
                    ?: canvas.drawColor(bgColor)
            } finally {
                if (canvas != null) try { surfaceHolder.unlockCanvasAndPost(canvas) } catch (_: Exception) {}
            }
        }

        private fun dayOfYear(): Int  = Calendar.getInstance().get(Calendar.DAY_OF_YEAR)
        private fun daysInYear(): Int = Calendar.getInstance().getActualMaximum(Calendar.DAY_OF_YEAR)
    }
}