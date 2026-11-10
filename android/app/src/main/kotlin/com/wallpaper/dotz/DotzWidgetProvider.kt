
package com.wallpaper.dotz

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews


/**
 * Home-screen widget mirroring whatever mode/settings are currently
 * configured for the live wallpaper.
 *
 * It reads the same Dotz preferences and uses the same DotGridRenderer.
 */
class DotzWidgetProvider : AppWidgetProvider() {

    companion object {

        /**
         * Called after the app writes new wallpaper settings
         * and when the widget needs updating.
         */
        fun requestUpdate(context: Context) {
            val mgr = AppWidgetManager.getInstance(context)

            val ids = mgr.getAppWidgetIds(
                ComponentName(context, DotzWidgetProvider::class.java)
            )

            for (id in ids) {
                updateWidget(context, mgr, id)
            }
        }

        private fun updateWidget(
            context: Context,
            mgr: AppWidgetManager,
            widgetId: Int
        ) {

            val prefs = context.getSharedPreferences(
                DotzSettings.PREFS_NAME,
                Context.MODE_PRIVATE
            )

            val settings = DotzSettings.load(prefs)

            val options = mgr.getAppWidgetOptions(widgetId)

            val minWidthDp = options.getInt(
                AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH,
                150
            ).coerceAtLeast(50)

            val minHeightDp = options.getInt(
                AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT,
                150
            ).coerceAtLeast(50)

            val density = context.resources.displayMetrics.density

            val w = (minWidthDp * density).toInt()
            val h = (minHeightDp * density).toInt()

            val views = RemoteViews(
                context.packageName,
                R.layout.dotz_widget
            )

            val typeface = runCatching {
                androidx.core.content.res.ResourcesCompat.getFont(context, R.font.inter_medium)
            }.getOrNull()

            val bitmap = DotGridRenderer.buildBitmap(
                w,
                h,
                settings,
                typeface
            )

            if (bitmap != null) {
                views.setImageViewBitmap(
                    R.id.dotz_widget_image,
                    bitmap
                )
            }

            mgr.updateAppWidget(widgetId, views)
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {

        for (id in appWidgetIds) {
            updateWidget(context, appWidgetManager, id)
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: android.os.Bundle?
    ) {

        // Redraw when the user resizes the widget.
        updateWidget(context, appWidgetManager, appWidgetId)
    }

    override fun onReceive(
        context: Context,
        intent: Intent
    ) {

        super.onReceive(context, intent)

        when (intent.action) {

            Intent.ACTION_DATE_CHANGED,
            Intent.ACTION_TIMEZONE_CHANGED,
            Intent.ACTION_BOOT_COMPLETED -> requestUpdate(context)
        }
    }
}
