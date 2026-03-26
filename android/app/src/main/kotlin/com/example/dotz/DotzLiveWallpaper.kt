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
        private var mode        = 0   // 0=year 1=goal 2=life

        // Goal
        private var goalTotalDays = 100
        private var goalPastDays  = 0
        private var goalName      = "Goal"

        // Life
        private var lifeTotalDays  = 29200
        private var lifeDaysLived  = 0

        // Dot geometry (computed once per surface change)
        private var dotRadius  = 0f
        private var dotSpacing = 0f

        private val drawRunnable = object : Runnable {
            override fun run() {
                if (!isVisible) return
                drawFrame()
                // Redraw once per minute (no animation loop needed)
                handler.postDelayed(this, 60_000L)
            }
        }

        override fun onCreate(holder: SurfaceHolder) {
            super.onCreate(holder)
            prefs = getSharedPreferences("dotz_prefs", MODE_PRIVATE)
            prefs?.registerOnSharedPreferenceChangeListener(this)
            loadPrefs()
        }

        override fun onDestroy() {
            super.onDestroy()
            prefs?.unregisterOnSharedPreferenceChangeListener(this)
            handler.removeCallbacks(drawRunnable)
        }

        override fun onSharedPreferenceChanged(sp: SharedPreferences?, key: String?) {
            loadPrefs()
            val f = surfaceHolder.surfaceFrame
            if (f.width() > 0) recalc(f.width(), f.height())
            drawFrame()
        }

        private fun loadPrefs() {
            prefs?.let { p ->
                bgColor     = p.getInt("bg_color",     Color.BLACK)
                pastColor   = p.getInt("past_color",   Color.WHITE)
                futureColor = p.getInt("future_color", Color.parseColor("#2A2A2A"))
                todayColor  = p.getInt("today_color",  Color.parseColor("#FF4500"))
                columns     = p.getInt("columns",      20)
                showLabel   = p.getBoolean("show_label", true)
                mode        = p.getInt("mode",         0)
                goalTotalDays = p.getInt("goal_total", 100)
                goalPastDays  = p.getInt("goal_past",  0)
                goalName      = p.getString("goal_name", "Goal") ?: "Goal"
                lifeTotalDays  = p.getInt("life_total", 29200)
                lifeDaysLived  = p.getInt("life_lived", 0)
            }
        }

        // ── Total / past dots for current mode ───────────────────
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

        // ── Geometry ──────────────────────────────────────────────
        // Auto-sizes dots to fill available space.
        // For large dot counts (life in days), uses enough columns so
        // dots are small and dense — matching the reference image.
        private fun recalc(w: Int, h: Int) {
            val total  = totalDots()
            val availW = w * 0.90f
            val availH = h * 0.88f

            // For life mode (days): auto-pick columns so grid fits nicely
            // Target: dots should be at least 2px radius, grid fills width
            // We want rows ≈ cols * (h/w) for a proportional grid
            val effectiveCols = if (mode == 2 && total > 1000) {
                // solve: cols^2 * (h/w) ≈ total  → cols = sqrt(total * w/h)
                val ideal = Math.sqrt(total.toDouble() * w / h).toInt()
                ideal.coerceIn(30, 120)
            } else {
                columns
            }

            // Solve r from width
            var r = availW / (effectiveCols * 2.5f - 0.5f)

            // Also solve r from height (rows constraint)
            val rows0  = ceil(total.toFloat() / effectiveCols).toInt()
            val gridH0 = rows0 * (r * 2f + r * 0.5f) - r * 0.5f
            if (gridH0 > availH) {
                val rH = availH / (rows0 * 2.5f - 0.5f)
                if (rH < r) r = rH
            }

            dotRadius  = r.coerceIn(1.5f, 28f)
            dotSpacing = dotRadius * 0.5f

            // Store effective cols for rendering
            _renderCols = effectiveCols
        }

        private var _renderCols = 20

        override fun onSurfaceChanged(holder: SurfaceHolder, format: Int, w: Int, h: Int) {
            super.onSurfaceChanged(holder, format, w, h)
            recalc(w, h)
            drawFrame()
        }

        override fun onDesiredSizeChanged(dw: Int, dh: Int) {
            super.onDesiredSizeChanged(dw, dh)
            surfaceHolder.setFixedSize(dw, dh) // kill parallax zoom
        }

        override fun onOffsetsChanged(xo: Float, yo: Float, xos: Float,
                                      yos: Float, xpo: Int, ypo: Int) { /* no pan */ }

        override fun onVisibilityChanged(visible: Boolean) {
            isVisible = visible
            if (visible) {
                loadPrefs()
                val f = surfaceHolder.surfaceFrame
                if (f.width() > 0) recalc(f.width(), f.height())
                handler.post(drawRunnable)
            } else {
                handler.removeCallbacks(drawRunnable)
            }
        }

        // ── Draw ─────────────────────────────────────────────────
        private fun drawFrame() {
            var canvas: Canvas? = null
            try {
                canvas = surfaceHolder.lockCanvas() ?: return
                render(canvas)
            } finally {
                if (canvas != null)
                    try { surfaceHolder.unlockCanvasAndPost(canvas) } catch (_: Exception) {}
            }
        }

        private fun render(canvas: Canvas) {
            val W = canvas.width.toFloat()
            val H = canvas.height.toFloat()

            val total    = totalDots()
            val past     = pastDots()
            val cols     = if (mode == 2 && total > 1000) _renderCols else columns

            val cell  = dotRadius * 2f + dotSpacing
            val rows  = ceil(total.toFloat() / cols).toInt()
            val gridW = columns * cell - dotSpacing
            val gridH = rows    * cell - dotSpacing

            // TRUE center
            val ox = (W - gridW) / 2f
            val oy = (H - gridH) / 2f

            canvas.drawColor(bgColor)

            val paint = Paint(Paint.ANTI_ALIAS_FLAG)

            for (i in 0 until total) {
                val col = i % cols
                val row = i / cols
                val cx  = ox + col * cell + dotRadius
                val cy  = oy + row * cell + dotRadius

                paint.style = Paint.Style.FILL
                paint.color = when {
                    i == past  -> todayColor   // today — solid, no animation
                    i <  past  -> pastColor
                    else       -> futureColor
                }
                canvas.drawCircle(cx, cy, dotRadius, paint)
            }

            if (showLabel) {
                paint.color = Color.argb(120,
                    Color.red(pastColor), Color.green(pastColor), Color.blue(pastColor))
                paint.textSize    = dotRadius * 1.8f
                paint.textAlign   = Paint.Align.CENTER
                paint.letterSpacing = 0.08f
                canvas.drawText(labelText(), W / 2f,
                    oy + gridH + dotRadius * 3f, paint)
            }
        }

        private fun dayOfYear(): Int =
            Calendar.getInstance().get(Calendar.DAY_OF_YEAR)

        private fun daysInYear(): Int =
            Calendar.getInstance().getActualMaximum(Calendar.DAY_OF_YEAR)
    }
}
