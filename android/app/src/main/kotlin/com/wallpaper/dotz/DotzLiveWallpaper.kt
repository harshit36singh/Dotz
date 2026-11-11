package com.wallpaper.dotz

import android.content.SharedPreferences
import android.graphics.Bitmap
import android.graphics.Canvas
import android.service.wallpaper.WallpaperService
import android.os.Handler
import android.os.Looper
import android.view.SurfaceHolder
import com.wallpaper.dotz.data.QuoteApi
import com.wallpaper.dotz.data.todayMidnight

// NOTE: All grid-drawing logic lives in DotGridRenderer.kt, shared with
// DotzWidgetProvider so the wallpaper and the home-screen widget can never
// drift from each other. This class is just the WallpaperService plumbing:
// watching prefs, deciding when to redraw, and blitting the result.
class DotzLiveWallpaper : WallpaperService() {
    override fun onCreateEngine(): Engine = DotzEngine()

    inner class DotzEngine : Engine(),
        SharedPreferences.OnSharedPreferenceChangeListener {

        private val handler = Handler(Looper.getMainLooper())
        private var prefs: SharedPreferences? = null
        private var isVisible = false

        private lateinit var settings: DotzSettings
        private val labelTypeface by lazy {
            runCatching { androidx.core.content.res.ResourcesCompat.getFont(this@DotzLiveWallpaper, R.font.inter_medium) }.getOrNull()
        }

        private var cachedBitmap: Bitmap? = null
        private var lastDrawnDay = -1

        private val prefsRunnable = Runnable {
            loadPrefs()
            val f = surfaceHolder.surfaceFrame
            if (f.width() > 0 && f.height() > 0) recalc(f.width(), f.height())
        }

        private var quoteFetching = false
        private var lastQuoteAttempt = 0L

        /**
         * Quote mode: fetch the quote of the day once the stored one ("quoteDay")
         * is from an earlier day. Retries at most every 30 min, so a failure
         * (offline at midnight, reboot on a new day) still recovers.
         */
        private fun maybeFetchQuote() {
            if (settings.labelMode != 2 || settings.quoteApiUrl.isEmpty()) return
            val today = todayMidnight()
            if (prefs?.getLong("quoteDay", 0L) == today) return
            val now = System.currentTimeMillis()
            if (quoteFetching || now - lastQuoteAttempt < 30 * 60_000L) return
            quoteFetching = true
            lastQuoteAttempt = now
            val url = settings.quoteApiUrl
            Thread {
                val quote = QuoteApi.fetch(url)
                handler.post {
                    quoteFetching = false
                    if (quote != null) {
                        // The prefs listener rebuilds the wallpaper; the widget is told directly.
                        prefs?.edit()
                            ?.putString("customLabel", QuoteApi.format(quote.first, quote.second))
                            ?.putLong("quoteDay", today)
                            ?.apply()
                        DotzWidgetProvider.requestUpdate(this@DotzLiveWallpaper)
                    }
                }
            }.start()
        }

        private val drawRunnable = object : Runnable {
            override fun run() {
                if (!isVisible) return
                val today = DotGridRenderer.dayOfYear()
                if (today != lastDrawnDay) {
                    // New day: advance the grid now, even if the quote fetch fails.
                    lastDrawnDay = today
                    val f = surfaceHolder.surfaceFrame
                    if (f.width() > 0 && f.height() > 0) buildCache(f.width(), f.height())
                }
                maybeFetchQuote()
                drawFrame()
                handler.postDelayed(this, 60_000L)
            }
        }

        override fun onCreate(holder: SurfaceHolder) {
            super.onCreate(holder)
            prefs = getSharedPreferences(DotzSettings.PREFS_NAME, MODE_PRIVATE)
            prefs?.registerOnSharedPreferenceChangeListener(this)
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

        private fun loadPrefs() {
            prefs?.let { settings = DotzSettings.load(it) }
        }

        private fun recalc(w: Int, h: Int) {
            lastDrawnDay = DotGridRenderer.dayOfYear()
            buildCache(w, h)
            drawFrame()
        }

        private fun buildCache(w: Int, h: Int) {
            cachedBitmap?.recycle()
            cachedBitmap = DotGridRenderer.buildBitmap(w, h, settings, labelTypeface)
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
                cachedBitmap?.let { canvas.drawBitmap(it, 0f, 0f, null) }
                    ?: canvas.drawColor(settings.bgColor)
            } finally {
                if (canvas != null) try { surfaceHolder.unlockCanvasAndPost(canvas) } catch (_: Exception) {}
            }
        }
    }
}
