package com.wallpaper.dotz.data

import android.app.WallpaperManager
import android.content.Context
import android.net.Uri
import com.wallpaper.dotz.BuildConfig
import com.wallpaper.dotz.DotzSettings
import com.wallpaper.dotz.DotzWidgetProvider
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONArray
import java.io.File
import java.net.HttpURLConnection
import java.net.URL

/**
 * Storage for the app:
 *  - "dotz_draft": what the user is editing (saved on every change, so
 *    settings survive restarts without touching the live wallpaper)
 *  - "dotz_prefs": what the live wallpaper + widget draw; only written when
 *    the user taps "Set as wallpaper"
 */
class DotzRepository(private val context: Context) {

    private val draftPrefs = context.getSharedPreferences(DRAFT_PREFS, Context.MODE_PRIVATE)
    private val wallpaperPrefs = context.getSharedPreferences(DotzSettings.PREFS_NAME, Context.MODE_PRIVATE)
    private val appPrefs = context.getSharedPreferences(APP_PREFS, Context.MODE_PRIVATE)

    // ── Onboarding ───────────────────────────────────────────────────
    fun isOnboardingComplete(): Boolean {
        if (appPrefs.getBoolean(KEY_ONBOARDED, false)) return true
        // Users upgrading from the Flutter build already saw onboarding.
        val flutter = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        return flutter.getBoolean("flutter.dotz_onboarding_complete", false)
    }

    fun setOnboardingComplete() {
        appPrefs.edit().putBoolean(KEY_ONBOARDED, true).apply()
    }

    // ── Draft ────────────────────────────────────────────────────────
    fun loadDraft(): DotzState {
        draftPrefs.getString(KEY_STATE, null)?.let { DotzState.fromJson(it) }?.let { return migrate(it) }
        // No draft yet: start from whatever the wallpaper last applied (Flutter
        // users upgrading keep their look), else defaults.
        if (wallpaperPrefs.contains("mode")) return fromWallpaperPrefs()
        return DotzState()
    }

    /** Repairs drafts saved by older builds or restored from a backup. */
    private fun migrate(draft: DotzState): DotzState {
        var d = draft
        // Older builds left the goal start null ("today"). Recover the start the
        // wallpaper was applied with if it is the same goal, else pin it to today.
        if (d.goalDateMillis != null && d.goalStartMillis == null) {
            val appliedEnd = wallpaperPrefs.getLong("goalEndMillis", 0L)
            val appliedStart = wallpaperPrefs.getLong("goalStartMillis", 0L)
            val start = appliedStart.takeIf { it > 0L && appliedEnd == d.goalDateMillis } ?: todayMidnight()
            d = d.copy(goalStartMillis = start)
        }
        // A background image path from another device (backup restore) or a
        // deleted file would otherwise show as "Custom" but draw nothing.
        if (d.bgImagePath.isNotEmpty() && !File(d.bgImagePath).exists()) {
            d = d.copy(bgImagePath = "")
        }
        return d
    }

    fun saveDraft(state: DotzState) {
        draftPrefs.edit().putString(KEY_STATE, state.toJson()).apply()
    }

    private fun fromWallpaperPrefs(): DotzState {
        val s = DotzSettings.load(wallpaperPrefs)
        val d = DotzState()
        return d.copy(
            mode = CalendarMode.fromNative(s.mode),
            pastColor = s.pastColor,
            todayColor = s.todayColor,
            futureColor = s.futureColor,
            bgColor = s.bgColor,
            todayStyle = s.todayStyle,
            dotShape = DotShape.entries.getOrElse(s.dotShape) { DotShape.CIRCLE },
            columns = s.columns,
            showDateNumbers = s.showDateNumbers,
            labelMode = LabelMode.entries.getOrElse(s.labelMode) { LabelMode.PROGRESS },
            customLabel = if (s.labelMode == LabelMode.CUSTOM.ordinal) s.customLabel else "",
            labelColor = s.labelColor,
            labelFontSize = s.labelFontSizeSp,
            bgImagePath = s.bgImagePath.takeIf { File(it).exists() } ?: "",
            gridScale = s.gridScale,
            offsetX = s.offsetX,
            offsetY = s.offsetY,
            goalName = s.goalName.takeUnless { it == "Goal" || it == "My Goal" } ?: "",
            goalDateMillis = s.goalEndMillis.takeIf { it > 0L },
            goalStartMillis = s.goalStartMillis.takeIf { it > 0L },
            birthMillis = s.birthMillis.takeIf { it > 0L },
            lifeExpYears = s.lifeExpYears,
            lifeUnit = LifeUnit.entries.getOrElse(s.lifeUnit) { LifeUnit.DAYS },
            markedDates = DotzState.parseMarkedDates(s.markedDatesJson),
            milestoneColor = s.milestoneColor,
        )
    }

    // ── Apply to the live wallpaper ──────────────────────────────────
    fun writeWallpaperPrefs(state: DotzState) {
        val s = state.toSettings()
        wallpaperPrefs.edit().apply {
            putInt("bgColor", s.bgColor)
            putInt("pastColor", s.pastColor)
            putInt("futureColor", s.futureColor)
            putInt("todayColor", s.todayColor)
            putInt("labelColor", s.labelColor)
            putFloat("labelFontSize", s.labelFontSizeSp)
            putInt("columns", s.columns)
            putBoolean("showLabel", s.showLabel)
            putInt("dotShape", s.dotShape)
            putInt("labelMode", s.labelMode)
            putString("customLabel", s.customLabel)
            putString("bgImagePath", s.bgImagePath)
            putString("apiUrl", BuildConfig.QUOTE_API_URL)
            putInt("mode", s.mode)
            putInt("goalTotal", s.goalTotalDays())
            putInt("goalPast", s.goalPastDays())
            putString("goalName", s.goalName)
            putInt("lifeTotal", s.lifeTotalUnits())
            putInt("lifeLived", s.lifeUnitsLived())
            putFloat("gridScale", s.gridScale)
            putFloat("offsetX", s.offsetX)
            putFloat("offsetY", s.offsetY)
            putLong("goalEndMillis", s.goalEndMillis)
            putLong("goalStartMillis", s.goalStartMillis)
            putLong("birthMillis", s.birthMillis)
            putInt("lifeExpYears", s.lifeExpYears)
            putInt("lifeUnit", s.lifeUnit)
            putString("markedDates", s.markedDatesJson)
            putInt("milestoneColor", s.milestoneColor)
            putBoolean("showDateNumbers", s.showDateNumbers)
            putString("todayStyle", s.todayStyle)
        }.commit()
        DotzWidgetProvider.requestUpdate(context)
        cleanupBackgrounds(state.bgImagePath)
    }

    fun isLiveWallpaperActive(): Boolean = try {
        WallpaperManager.getInstance(context).wallpaperInfo?.packageName == context.packageName
    } catch (e: Exception) {
        false
    }

    // ── Background image ─────────────────────────────────────────────
    /** Copies the picked image into app storage; returns its path or null. */
    suspend fun importBackground(uri: Uri): String? = withContext(Dispatchers.IO) {
        try {
            val dir = context.filesDir
            // New name each time so Compose/bitmap caches never show stale bytes.
            val target = File(dir, "wallpaper_bg_${System.currentTimeMillis()}.jpg")
            context.contentResolver.openInputStream(uri)?.use { input ->
                target.outputStream().use { input.copyTo(it) }
            } ?: return@withContext null
            target.absolutePath
        } catch (e: Exception) {
            null
        }
    }

    /**
     * Deletes stored background images except [draftPath] and the one the live
     * wallpaper is currently drawing (it must keep working until re-applied).
     */
    fun cleanupBackgrounds(draftPath: String) {
        val keep = setOf(draftPath, wallpaperPrefs.getString("bgImagePath", "") ?: "")
        context.filesDir.listFiles { f -> f.name.startsWith("wallpaper_bg") }
            ?.filter { it.absolutePath !in keep }
            ?.forEach { runCatching { it.delete() } }
    }

    // ── Quote ────────────────────────────────────────────────────────
    /** Fetches a zenquotes-style quote: `[{"q": "...", "a": "..."}]`. */
    suspend fun fetchQuote(): Pair<String, String>? = withContext(Dispatchers.IO) {
        val url = BuildConfig.QUOTE_API_URL
        if (url.isBlank()) return@withContext null
        try {
            val conn = (URL(url).openConnection() as HttpURLConnection).apply {
                requestMethod = "GET"
                setRequestProperty("Accept", "application/json")
                connectTimeout = 8000
                readTimeout = 8000
            }
            try {
                if (conn.responseCode != 200) return@withContext null
                val body = conn.inputStream.bufferedReader().use { it.readText() }
                val arr = JSONArray(body)
                if (arr.length() == 0) return@withContext null
                val item = arr.getJSONObject(0)
                val q = item.optString("q").trim()
                val a = item.optString("a").trim()
                if (q.isEmpty()) null else q to a
            } finally {
                conn.disconnect()
            }
        } catch (e: Exception) {
            null
        }
    }

    companion object {
        private const val DRAFT_PREFS = "dotz_draft"
        private const val APP_PREFS = "dotz_app"
        private const val KEY_STATE = "state"
        private const val KEY_ONBOARDED = "onboarding_complete"
    }
}
