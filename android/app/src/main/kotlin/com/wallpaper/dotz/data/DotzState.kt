package com.wallpaper.dotz.data

import com.wallpaper.dotz.DotGridRenderer
import com.wallpaper.dotz.DotzSettings
import org.json.JSONArray
import org.json.JSONObject
import java.util.Calendar

/** Calendar modes. [nativeIndex] is the `mode` int the renderer understands. */
enum class CalendarMode(val nativeIndex: Int) {
    YEAR(0), MONTH(3), GOAL(1), LIFE(2);

    companion object {
        fun fromNative(i: Int) = entries.firstOrNull { it.nativeIndex == i } ?: YEAR
    }
}

/** Ordinal == the renderer's `dotShape` int. GLASS is shown as "Ring". */
enum class DotShape { CIRCLE, SQUARE, STAR, GLASS, HEXAGON, DIAMOND }

/** Ordinal == the renderer's `lifeUnit` int. */
enum class LifeUnit { DAYS, WEEKS }

/** Ordinal == the renderer's `labelMode` int. */
enum class LabelMode { OFF, PROGRESS, QUOTE, CUSTOM }

/** A yearly marker (birthday, anniversary): matched by month + day only. */
data class MarkedDate(val month: Int, val day: Int, val label: String)

/**
 * Everything the user can configure. Colours are ARGB ints so this maps 1:1
 * onto [DotzSettings] and SharedPreferences. Dates are local-midnight millis.
 */
data class DotzState(
    val mode: CalendarMode = CalendarMode.YEAR,
    val pastColor: Int = DotzSettings.DEFAULT_PAST,
    val todayColor: Int = DotzSettings.DEFAULT_TODAY,
    val futureColor: Int = DotzSettings.DEFAULT_FUTURE,
    val bgColor: Int = DotzSettings.DEFAULT_BG,
    val todayStyle: String = DotzSettings.TODAY_STYLE_PIP,
    val dotShape: DotShape = DotShape.CIRCLE,
    val columns: Int = 20,
    val showDateNumbers: Boolean = false,
    val labelMode: LabelMode = LabelMode.PROGRESS,
    val customLabel: String = "",
    val quoteText: String = "",
    val quoteAuthor: String = "",
    val quoteDay: Long = 0L, // local midnight of the day quoteText was fetched
    val labelColor: Int = 0xFFF2EEE8.toInt(),
    val labelFontSize: Float = 0f, // 0 = auto
    val bgImagePath: String = "",
    val gridScale: Float = 1f,
    val offsetX: Float = 0f,
    val offsetY: Float = 0f,
    val goalName: String = "",
    val goalDateMillis: Long? = null,
    val goalStartMillis: Long? = null, // set when the goal starts; null only in old drafts
    val birthMillis: Long? = null,
    val lifeExpYears: Int = 80,
    val lifeUnit: LifeUnit = LifeUnit.WEEKS,
    val markedDates: List<MarkedDate> = emptyList(),
    val milestoneColor: Int = DotzSettings.DEFAULT_MILESTONE,
) {
    val goalIsSet: Boolean get() = goalDateMillis != null
    val displayGoalName: String get() = goalName.ifBlank { "My goal" }

    /** Goal start actually used: the picked start, else today. */
    fun effectiveGoalStart(): Long = goalStartMillis ?: todayMidnight()

    /**
     * Text stored as the wallpaper's `customLabel`. Empty when there is nothing
     * of the user's own to show, so the renderer falls back to the progress
     * label and keeps it current, instead of freezing the apply-day progress.
     */
    private fun storedLabel(): String = when (labelMode) {
        LabelMode.CUSTOM -> customLabel.trim()
        LabelMode.QUOTE -> if (quoteText.isBlank()) "" else QuoteApi.format(quoteText, quoteAuthor)
        else -> ""
    }

    /** Renderer snapshot: exactly what the wallpaper will draw. */
    fun toSettings(): DotzSettings {
        return DotzSettings(
            bgColor = bgColor,
            pastColor = pastColor,
            futureColor = futureColor,
            todayColor = todayColor,
            labelColor = labelColor,
            labelFontSizeSp = labelFontSize,
            columns = columns,
            showLabel = labelMode != LabelMode.OFF,
            labelMode = labelMode.ordinal,
            customLabel = storedLabel(),
            quoteApiUrl = "",
            bgImagePath = bgImagePath,
            mode = mode.nativeIndex,
            dotShape = dotShape.ordinal,
            gridScale = gridScale,
            offsetX = offsetX,
            offsetY = offsetY,
            goalName = displayGoalName,
            goalTotalFallback = 100,
            goalPastFallback = 0,
            lifeTotalFallback = lifeExpYears * (if (lifeUnit == LifeUnit.WEEKS) 52 else 365),
            lifeLivedFallback = 0,
            goalEndMillis = goalDateMillis ?: 0L,
            goalStartMillis = if (goalDateMillis != null) effectiveGoalStart() else 0L,
            birthMillis = birthMillis ?: 0L,
            lifeExpYears = lifeExpYears,
            lifeUnit = lifeUnit.ordinal,
            markedDatesJson = markedDatesJson(),
            milestoneColor = milestoneColor,
            showDateNumbers = showDateNumbers,
            todayStyle = todayStyle,
        )
    }

    /** The exact text the wallpaper label will show. */
    fun resolvedLabel(settings: DotzSettings = toSettings()): String {
        val progress = DotGridRenderer.computeProgressLabel(settings)
        return when (labelMode) {
            LabelMode.OFF -> ""
            LabelMode.PROGRESS -> progress
            LabelMode.QUOTE, LabelMode.CUSTOM -> storedLabel().ifEmpty { progress }
        }
    }

    fun markedDatesJson(): String = JSONArray().apply {
        markedDates.forEach {
            put(JSONObject().put("month", it.month).put("day", it.day).put("label", it.label))
        }
    }.toString()

    // ── Draft persistence (survives app restarts) ───────────────────
    fun toJson(): String = JSONObject().apply {
        put("mode", mode.name)
        put("pastColor", pastColor); put("todayColor", todayColor)
        put("futureColor", futureColor); put("bgColor", bgColor)
        put("todayStyle", todayStyle)
        put("dotShape", dotShape.name)
        put("columns", columns)
        put("showDateNumbers", showDateNumbers)
        put("labelMode", labelMode.name)
        put("customLabel", customLabel)
        put("quoteText", quoteText); put("quoteAuthor", quoteAuthor)
        put("quoteDay", quoteDay)
        put("labelColor", labelColor)
        put("labelFontSize", labelFontSize.toDouble())
        put("bgImagePath", bgImagePath)
        put("gridScale", gridScale.toDouble())
        put("offsetX", offsetX.toDouble()); put("offsetY", offsetY.toDouble())
        put("goalName", goalName)
        put("goalDateMillis", goalDateMillis ?: 0L)
        put("goalStartMillis", goalStartMillis ?: 0L)
        put("birthMillis", birthMillis ?: 0L)
        put("lifeExpYears", lifeExpYears)
        put("lifeUnit", lifeUnit.name)
        put("markedDates", JSONArray(markedDatesJson()))
        put("milestoneColor", milestoneColor)
    }.toString()

    companion object {
        fun fromJson(json: String): DotzState? = try {
            val o = JSONObject(json)
            val d = DotzState()
            fun long(key: String): Long? = o.optLong(key, 0L).takeIf { it > 0L }
            DotzState(
                mode = enumOr(o.optString("mode"), d.mode),
                pastColor = o.optInt("pastColor", d.pastColor),
                todayColor = o.optInt("todayColor", d.todayColor),
                futureColor = o.optInt("futureColor", d.futureColor),
                bgColor = o.optInt("bgColor", d.bgColor),
                todayStyle = o.optString("todayStyle", d.todayStyle),
                dotShape = enumOr(o.optString("dotShape"), d.dotShape),
                columns = o.optInt("columns", d.columns),
                showDateNumbers = o.optBoolean("showDateNumbers", d.showDateNumbers),
                labelMode = enumOr(o.optString("labelMode"), d.labelMode),
                customLabel = o.optString("customLabel", ""),
                quoteText = o.optString("quoteText", ""),
                quoteAuthor = o.optString("quoteAuthor", ""),
                quoteDay = o.optLong("quoteDay", 0L),
                labelColor = o.optInt("labelColor", d.labelColor),
                labelFontSize = o.optDouble("labelFontSize", 0.0).toFloat(),
                bgImagePath = o.optString("bgImagePath", ""),
                gridScale = o.optDouble("gridScale", 1.0).toFloat(),
                offsetX = o.optDouble("offsetX", 0.0).toFloat(),
                offsetY = o.optDouble("offsetY", 0.0).toFloat(),
                goalName = o.optString("goalName", ""),
                goalDateMillis = long("goalDateMillis"),
                goalStartMillis = long("goalStartMillis"),
                birthMillis = long("birthMillis"),
                lifeExpYears = o.optInt("lifeExpYears", d.lifeExpYears),
                lifeUnit = enumOr(o.optString("lifeUnit"), d.lifeUnit),
                markedDates = parseMarkedDates(o.optJSONArray("markedDates")?.toString() ?: ""),
                milestoneColor = o.optInt("milestoneColor", d.milestoneColor),
            )
        } catch (e: Exception) {
            null
        }

        fun parseMarkedDates(json: String): List<MarkedDate> {
            if (json.isBlank()) return emptyList()
            return try {
                val arr = JSONArray(json)
                (0 until arr.length()).map { i ->
                    val o = arr.getJSONObject(i)
                    MarkedDate(o.getInt("month"), o.getInt("day"), o.optString("label", ""))
                }
            } catch (e: Exception) {
                emptyList()
            }
        }

        private inline fun <reified E : Enum<E>> enumOr(name: String, fallback: E): E =
            enumValues<E>().firstOrNull { it.name == name } ?: fallback
    }
}

fun todayMidnight(): Long = midnight(System.currentTimeMillis())

fun midnight(millis: Long): Long = Calendar.getInstance().apply {
    timeInMillis = millis
    set(Calendar.HOUR_OF_DAY, 0); set(Calendar.MINUTE, 0)
    set(Calendar.SECOND, 0); set(Calendar.MILLISECOND, 0)
}.timeInMillis
