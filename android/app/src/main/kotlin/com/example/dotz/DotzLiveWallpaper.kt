package com.example.dotz

import android.content.SharedPreferences
import android.graphics.Bitmap
import android.graphics.Canvas
import android.service.wallpaper.WallpaperService
import android.os.Handler
import android.os.Looper
import android.view.SurfaceHolder

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

        private var cachedBitmap: Bitmap? = null
        private var lastDrawnDay = -1

        private val prefsRunnable = Runnable {
            loadPrefs()
            val f = surfaceHolder.surfaceFrame
            if (f.width() > 0 && f.height() > 0) recalc(f.width(), f.height())
        }

        private fun fetchNewQuoteAsync() {
            Thread {
                try {
                    val url = java.net.URL(settings.quoteApiUrl)
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
                val today = DotGridRenderer.dayOfYear()
                if (today != lastDrawnDay) {
                    lastDrawnDay = today

                    if (settings.labelMode == 2 && settings.quoteApiUrl.isNotEmpty()) {
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
            cachedBitmap = DotGridRenderer.buildBitmap(w, h, settings)
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
