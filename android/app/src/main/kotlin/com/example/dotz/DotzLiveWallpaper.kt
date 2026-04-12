package com.example.dotz

import android.content.SharedPreferences
import android.graphics.*
import android.os.Handler
import android.os.Looper
import android.service.wallpaper.WallpaperService
import android.view.SurfaceHolder
import kotlin.math.ceil
import java.util.Calendar

class DotzLiveWallpaper : WallpaperService() {
    override fun onCreateEngine(): Engine = DotzEngine()

    inner class DotzEngine : Engine(),
        SharedPreferences.OnSharedPreferenceChangeListener {

        private val handler  = Handler(Looper.getMainLooper())
        private var prefs: SharedPreferences? = null
        private var isVisible = false

        // Settings
        private var bgColor     = Color.BLACK
        private var pastColor   = Color.WHITE
        private var futureColor = Color.parseColor("#2A2A2A")
        private var todayColor  = Color.parseColor("#FF4500")
        private var columns     = 20
        private var showLabel   = true
        private var mode        = 0

        // Goal & Life
        private var goalTotalDays = 100
        private var goalPastDays  = 0
        private var goalName      = "Goal"
        private var lifeTotalDays  = 29200
        private var lifeDaysLived  = 0

        private var dotRadius  = 0f
        private var dotSpacing = 0f
        private var _renderCols = 20
        
        private var cachedBitmap: Bitmap? = null
        private val paintPast = Paint(Paint.ANTI_ALIAS_FLAG)
        private val paintFuture = Paint(Paint.ANTI_ALIAS_FLAG)
        private val paintToday = Paint(Paint.ANTI_ALIAS_FLAG)
        private val paintText = Paint(Paint.ANTI_ALIAS_FLAG)

        // ── FIX 1: MIDNIGHT ROLLOVER TRACKER ──
        private var lastDrawnDay = -1

        private val prefsRunnable = Runnable {
            loadPrefs()
            val f = surfaceHolder.surfaceFrame
            if (f.width() > 0) recalc(f.width(), f.height())
        }

        private val drawRunnable = object : Runnable {
            override fun run() {
                if (!isVisible) return
                
                // If the day changes (midnight), rebuild the cached image!
                val currentDay = dayOfYear()
                if (currentDay != lastDrawnDay) {
                    lastDrawnDay = currentDay
                    val f = surfaceHolder.surfaceFrame
                    if (f.width() > 0 && f.height() > 0) {
                        buildCache(f.width(), f.height())
                    }
                }
                
                drawFrame()
                handler.postDelayed(this, 60_000L) // Check again in a minute
            }
        }

        override fun onCreate(holder: SurfaceHolder) {
            super.onCreate(holder)
            prefs = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)
            if (!prefs!!.contains("flutter.mode")) {
                prefs = getSharedPreferences("dotz_prefs", MODE_PRIVATE)
            }
            prefs?.registerOnSharedPreferenceChangeListener(this)
            
            paintPast.strokeCap = Paint.Cap.ROUND
            paintFuture.strokeCap = Paint.Cap.ROUND
            paintToday.strokeCap = Paint.Cap.ROUND
            paintText.textAlign = Paint.Align.CENTER
            
            loadPrefs()
        }

        override fun onDestroy() {
            super.onDestroy()
            prefs?.unregisterOnSharedPreferenceChangeListener(this)
            handler.removeCallbacks(drawRunnable)
            handler.removeCallbacks(prefsRunnable)
            cachedBitmap?.recycle()
        }

        override fun onSharedPreferenceChanged(sp: SharedPreferences?, key: String?) {
            handler.removeCallbacks(prefsRunnable)
            handler.postDelayed(prefsRunnable, 50L)
        }

        private fun loadPrefs() {
            prefs?.let { p ->
                bgColor     = p.getInt("bgColor",     Color.BLACK)
                pastColor   = p.getInt("pastColor",   Color.WHITE)
                futureColor = p.getInt("futureColor", Color.parseColor("#2A2A2A"))
                todayColor  = p.getInt("todayColor",  Color.parseColor("#FF4500"))
                columns     = p.getInt("columns",      20)
                showLabel   = p.getBoolean("showLabel", true)
                mode        = p.getInt("mode",         0)
                goalTotalDays = p.getInt("goalTotal", 100)
                goalPastDays  = p.getInt("goalPast",  0)
                goalName      = p.getString("goalName", "Goal") ?: "Goal"
                lifeTotalDays  = p.getInt("lifeTotal", 29200)
                lifeDaysLived  = p.getInt("lifeLived", 0)
            }
        }

        private fun totalDots(): Int = when (mode) {
            1    -> goalTotalDays.coerceAtLeast(1)
            2    -> lifeTotalDays
            else -> daysInYear()
        }

        private fun pastDots(): Int = when (mode) {
            1    -> goalPastDays.coerceIn(0, totalDots())
            2    -> lifeDaysLived.coerceIn(0, totalDots())
            else -> dayOfYear() - 1
        }

        private fun labelText(): String = when (mode) {
            1    -> "${(goalTotalDays - goalPastDays).coerceAtLeast(0)} left · $goalName"
            2    -> "${(lifeTotalDays  - lifeDaysLived ).coerceAtLeast(0)} days left"
            else -> {
                val left = daysInYear() - dayOfYear()
                val pct  = (dayOfYear().toFloat() / daysInYear() * 100).toInt()
                "$left left · $pct%"
            }
        }

        private fun recalc(w: Int, h: Int) {
            val total  = totalDots()
            val availW = w * 0.90f
            val availH = h * 0.88f

            val effectiveCols = if (mode == 2 && total > 1000) {
                val ideal = Math.sqrt(total.toDouble() * w / h).toInt()
                ideal.coerceIn(30, 120)
            } else {
                columns
            }

            var r = availW / (effectiveCols * 2.5f - 0.5f)
            val rows0  = ceil(total.toFloat() / effectiveCols).toInt()
            val gridH0 = rows0 * (r * 2f + r * 0.5f) - r * 0.5f
            if (gridH0 > availH) {
                val rH = availH / (rows0 * 2.5f - 0.5f)
                if (rH < r) r = rH
            }

            dotRadius  = r.coerceIn(1.5f, 28f)
            dotSpacing = dotRadius * 0.5f
            _renderCols = effectiveCols

            val diameter = dotRadius * 2f
            paintPast.strokeWidth = diameter
            paintFuture.strokeWidth = diameter
            paintToday.strokeWidth = diameter

            lastDrawnDay = dayOfYear()
            buildCache(w, h)
            drawFrame()
        }

        private fun buildCache(w: Int, h: Int) {
            if (w <= 0 || h <= 0) return

            cachedBitmap?.recycle()
            cachedBitmap = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(cachedBitmap!!)
            canvas.drawColor(bgColor)

            val total = totalDots()
            
            // ── FIX 2: ARRAY SAFETY BOUNDS ──
            val safePast = pastDots().coerceIn(0, total)
            val safeFutureCount = (total - safePast - 1).coerceAtLeast(0)

            val pastPts = FloatArray(safePast * 2)
            val todayPts = FloatArray(2)
            val futurePts = FloatArray(safeFutureCount * 2)

            var pastIdx = 0
            var futureIdx = 0
            var drewToday = false

            val cell  = dotRadius * 2f + dotSpacing
            val rows  = ceil(total.toFloat() / _renderCols).toInt()
            val gridW = _renderCols * cell - dotSpacing
            val gridH = rows    * cell - dotSpacing
            val ox = (w - gridW) / 2f
            val oy = (h - gridH) / 2f

            for (i in 0 until total) {
                val col = i % _renderCols
                val row = i / _renderCols
                val cx  = ox + col * cell + dotRadius
                val cy  = oy + row * cell + dotRadius

                when {
                    i < safePast -> {
                        pastPts[pastIdx++] = cx
                        pastPts[pastIdx++] = cy
                    }
                    i == safePast -> {
                        todayPts[0] = cx
                        todayPts[1] = cy
                        drewToday = true
                    }
                    else -> {
                        futurePts[futureIdx++] = cx
                        futurePts[futureIdx++] = cy
                    }
                }
            }

            paintPast.color = pastColor
            paintFuture.color = futureColor
            paintToday.color = todayColor

            if (pastPts.isNotEmpty()) canvas.drawPoints(pastPts, paintPast)
            if (drewToday) canvas.drawPoints(todayPts, paintToday)
            if (futurePts.isNotEmpty()) canvas.drawPoints(futurePts, paintFuture)

            if (showLabel) {
                paintText.color = Color.argb(120, Color.red(pastColor), Color.green(pastColor), Color.blue(pastColor))
                paintText.textSize = dotRadius * 1.8f
                paintText.letterSpacing = 0.08f
                canvas.drawText(labelText(), w / 2f, oy + gridH + dotRadius * 3f, paintText)
            }
        }

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
            if (visible) {
                handler.post(drawRunnable)
            } else {
                handler.removeCallbacks(drawRunnable)
            }
        }

        private fun drawFrame() {
            var canvas: Canvas? = null
            try {
                canvas = surfaceHolder.lockCanvas() ?: return
                cachedBitmap?.let { 
                    canvas.drawBitmap(it, 0f, 0f, null) 
                } ?: run {
                    canvas.drawColor(bgColor)
                }
            } finally {
                if (canvas != null) {
                    try { surfaceHolder.unlockCanvasAndPost(canvas) } catch (_: Exception) {}
                }
            }
        }

        private fun dayOfYear(): Int = Calendar.getInstance().get(Calendar.DAY_OF_YEAR)
        private fun daysInYear(): Int = Calendar.getInstance().getActualMaximum(Calendar.DAY_OF_YEAR)
    }
}