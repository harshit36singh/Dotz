package com.example.dotz

import android.content.SharedPreferences
import android.graphics.*
import android.os.Handler
import android.os.Looper
import android.service.wallpaper.WallpaperService
import android.view.SurfaceHolder
import kotlin.math.ceil
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

        // Settings
        private var bgColor     = Color.BLACK
        private var pastColor   = Color.WHITE
        private var futureColor = Color.parseColor("#2A2A2A")
        private var todayColor  = Color.parseColor("#FF4500")
        private var columns     = 20
        private var showLabel   = true
        private var labelMode   = 1        // 0=off, 1=progress, 2=quote
        private var customLabel = ""       // pre-resolved by Flutter (quote or progress text)
        private var mode        = 0        // 0=year, 1=goal, 2=life

        // Goal
        private var goalTotalDays = 100
        private var goalPastDays  = 0
        private var goalName      = "Goal"

        // Life
        private var lifeTotalDays = 29200
        private var lifeDaysLived = 0

        // Render state
        private var dotRadius  = 0f
        private var dotSpacing = 0f
        private var renderCols = 20
        private var cachedBitmap: Bitmap? = null
        private var lastDrawnDay = -1

        private val paintPast   = Paint(Paint.ANTI_ALIAS_FLAG)
        private val paintFuture = Paint(Paint.ANTI_ALIAS_FLAG)
        private val paintToday  = Paint(Paint.ANTI_ALIAS_FLAG)
        private val paintText   = Paint(Paint.ANTI_ALIAS_FLAG)

        // ── Runnables ──────────────────────────────────────────
        private val prefsRunnable = Runnable {
            loadPrefs()
            val f = surfaceHolder.surfaceFrame
            if (f.width() > 0 && f.height() > 0) recalc(f.width(), f.height())
        }

        private val drawRunnable = object : Runnable {
            override fun run() {
                if (!isVisible) return
                val today = dayOfYear()
                if (today != lastDrawnDay) {
                    lastDrawnDay = today
                    val f = surfaceHolder.surfaceFrame
                    if (f.width() > 0 && f.height() > 0) buildCache(f.width(), f.height())
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
            paintPast.strokeCap   = Paint.Cap.ROUND
            paintFuture.strokeCap = Paint.Cap.ROUND
            paintToday.strokeCap  = Paint.Cap.ROUND
            paintText.textAlign   = Paint.Align.CENTER
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
                bgColor       = p.getInt("bgColor",     Color.BLACK)
                pastColor     = p.getInt("pastColor",   Color.WHITE)
                futureColor   = p.getInt("futureColor", Color.parseColor("#2A2A2A"))
                todayColor    = p.getInt("todayColor",  Color.parseColor("#FF4500"))
                columns       = p.getInt("columns",     20)
                showLabel     = p.getBoolean("showLabel", true)
                labelMode     = p.getInt("labelMode",   1)
                customLabel   = p.getString("customLabel", "") ?: ""
                mode          = p.getInt("mode",        0)
                goalTotalDays = p.getInt("goalTotal",   100)
                goalPastDays  = p.getInt("goalPast",    0)
                goalName      = p.getString("goalName", "Goal") ?: "Goal"
                lifeTotalDays = p.getInt("lifeTotal",   29200)
                lifeDaysLived = p.getInt("lifeLived",   0)
            }
        }

        // ── Dot counts ─────────────────────────────────────────
        private fun totalDots(): Int = when (mode) {
            1    -> goalTotalDays.coerceAtLeast(1)
            2    -> lifeTotalDays.coerceAtLeast(1)
            else -> daysInYear()
        }

        private fun pastDots(): Int = when (mode) {
            1    -> goalPastDays.coerceIn(0, totalDots())
            2    -> lifeDaysLived.coerceIn(0, totalDots())
            else -> (dayOfYear() - 1).coerceIn(0, totalDots())
        }

        /**
         * Resolve what text to draw at the bottom of the wallpaper.
         *
         * labelMode 0 = off  → empty string (nothing drawn)
         * labelMode 1 = progress → compute locally (always fresh at midnight)
         * labelMode 2 = quote  → use customLabel saved by Flutter (pre-fetched)
         */
        private fun resolvedLabel(): String {
            if (!showLabel || labelMode == 0) return ""
            if (labelMode == 2) return customLabel  // Flutter already formatted it
            // Progress mode — compute locally so midnight rollover works without app open
            return when (mode) {
                1 -> "${(goalTotalDays - goalPastDays).coerceAtLeast(0)} left · $goalName"
                2 -> {
                    val left = (lifeTotalDays - lifeDaysLived).coerceAtLeast(0)
                    val pct  = if (lifeTotalDays > 0) (lifeDaysLived * 100 / lifeTotalDays) else 0
                    "$left days left · $pct%"
                }
                else -> {
                    val left = daysInYear() - dayOfYear()
                    val pct  = (dayOfYear().toFloat() / daysInYear() * 100).toInt()
                    "$left left · $pct%"
                }
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

        // ── Build cached bitmap ────────────────────────────────
        private fun buildCache(w: Int, h: Int) {
            if (w <= 0 || h <= 0) return
            cachedBitmap?.recycle()
            cachedBitmap = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
            val canvas   = Canvas(cachedBitmap!!)
            canvas.drawColor(bgColor)

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
            val ox    = (w - gridW) / 2f
            val oy    = (h - gridH) / 2f

            for (i in 0 until total) {
                val cx = ox + (i % renderCols) * cell + dotRadius
                val cy = oy + (i / renderCols) * cell + dotRadius
                when {
                    i < safePast  -> { if (pIdx + 1 < pastPts.size)   { pastPts[pIdx++]   = cx; pastPts[pIdx++]   = cy } }
                    i == safePast -> { todayPt[0] = cx; todayPt[1] = cy; drewToday = true }
                    else          -> { if (fIdx + 1 < futurePts.size)  { futurePts[fIdx++] = cx; futurePts[fIdx++] = cy } }
                }
            }

            paintPast.color   = pastColor
            paintFuture.color = futureColor
            paintToday.color  = todayColor

            if (pIdx > 0)   canvas.drawPoints(pastPts,   0, pIdx,  paintPast)
            if (drewToday)  canvas.drawPoints(todayPt,   0, 2,     paintToday)
            if (fIdx > 0)   canvas.drawPoints(futurePts, 0, fIdx,  paintFuture)

            // ── Label ─────────────────────────────────────────
            val label = resolvedLabel()
            if (label.isNotEmpty()) {
                paintText.color       = Color.argb(140,
                    Color.red(pastColor), Color.green(pastColor), Color.blue(pastColor))
                paintText.textSize    = dotRadius * 1.8f
                paintText.letterSpacing = 0.06f

                // For quotes, wrap long text across multiple lines
                if (labelMode == 2 && label.length > 60) {
                    drawWrappedText(canvas, label, w / 2f, oy + gridH + dotRadius * 3.5f,
                        w * 0.85f, paintText)
                } else {
                    canvas.drawText(label, w / 2f, oy + gridH + dotRadius * 3.5f, paintText)
                }
            }
        }

        /** Draw text wrapping at [maxWidth], advancing [lineHeight] per line. */
        private fun drawWrappedText(
            canvas: Canvas, text: String,
            x: Float, startY: Float,
            maxWidth: Float, paint: Paint
        ) {
            val words     = text.split(" ")
            val lineH     = paint.textSize * 1.4f
            var line      = ""
            var y         = startY
            for (word in words) {
                val test = if (line.isEmpty()) word else "$line $word"
                if (paint.measureText(test) <= maxWidth) {
                    line = test
                } else {
                    if (line.isNotEmpty()) canvas.drawText(line, x, y, paint)
                    line = word
                    y   += lineH
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
            if (visible) handler.post(drawRunnable)
            else handler.removeCallbacks(drawRunnable)
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