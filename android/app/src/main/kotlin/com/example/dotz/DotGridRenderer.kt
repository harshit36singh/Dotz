package com.example.dotz

import android.content.SharedPreferences
import android.content.res.Resources
import android.graphics.*
import kotlin.math.ceil
import kotlin.math.cos
import kotlin.math.sin
import kotlin.math.sqrt
import java.util.Calendar

// NOTE: This is the single source of truth for what gets drawn into a Dotz
// bitmap on the native side — used by both DotzLiveWallpaper (the live
// wallpaper engine) and DotzWidgetProvider (the home-screen widget), so the
// two can never drift from each other. The grid-layout math here is
// intentionally mirrored in lib/views/widgets/dot_grid_widget.dart for the
// in-app preview; there is no shared source of truth with that Dart file —
// if you change the layout formulas here, change them there too.

/**
 * Snapshot of everything needed to render a Dotz grid, loaded from the
 * "dotz_prefs" SharedPreferences the Flutter app writes to.
 */
data class DotzSettings(
    val bgColor: Int,
    val pastColor: Int,
    val futureColor: Int,
    val todayColor: Int,
    val labelColor: Int,
    val labelFontSizeSp: Float,
    val columns: Int,
    val showLabel: Boolean,
    val labelMode: Int,
    val customLabel: String,
    val quoteApiUrl: String,
    val bgImagePath: String,
    val mode: Int,
    val dotShape: Int,
    val gridScale: Float,
    val offsetX: Float,
    val offsetY: Float,
    val goalName: String,
    // Precomputed snapshot, used as a fallback when the date fields below
    // are unset (e.g. no goal/birth date has ever been picked).
    val goalTotalFallback: Int,
    val goalPastFallback: Int,
    val lifeTotalFallback: Int,
    val lifeLivedFallback: Int,
    // Raw dates — preferred whenever present, since they let goal/life mode
    // advance every day on their own, the same way Year/Weekly mode already
    // do via the device clock, instead of only updating when the app is
    // reopened and "Apply" is tapped again.
    val goalEndMillis: Long,
    val goalStartMillis: Long,
    val birthMillis: Long,
    val lifeExpYears: Int,
    val lifeUnit: Int, // 0 = days, 1 = weeks
) {
    companion object {
        const val PREFS_NAME = "dotz_prefs"

        fun load(prefs: SharedPreferences): DotzSettings = DotzSettings(
            bgColor           = prefs.getInt("bgColor", Color.BLACK),
            pastColor         = prefs.getInt("pastColor", Color.WHITE),
            futureColor       = prefs.getInt("futureColor", Color.parseColor("#2A2A2A")),
            todayColor        = prefs.getInt("todayColor", Color.parseColor("#FF4500")),
            labelColor        = prefs.getInt("labelColor", Color.WHITE),
            labelFontSizeSp   = prefs.getFloat("labelFontSize", 0f),
            columns           = prefs.getInt("columns", 20),
            showLabel         = prefs.getBoolean("showLabel", true),
            labelMode         = prefs.getInt("labelMode", 1),
            customLabel       = prefs.getString("customLabel", "") ?: "",
            quoteApiUrl       = prefs.getString("apiUrl", "") ?: "",
            bgImagePath       = prefs.getString("bgImagePath", "") ?: "",
            mode              = prefs.getInt("mode", 0),
            dotShape          = prefs.getInt("dotShape", 0),
            gridScale         = prefs.getFloat("gridScale", 1.0f),
            offsetX           = prefs.getFloat("offsetX", 0f),
            offsetY           = prefs.getFloat("offsetY", 0f),
            goalName          = prefs.getString("goalName", "Goal") ?: "Goal",
            goalTotalFallback = prefs.getInt("goalTotal", 100),
            goalPastFallback  = prefs.getInt("goalPast", 0),
            lifeTotalFallback = prefs.getInt("lifeTotal", 29200),
            lifeLivedFallback = prefs.getInt("lifeLived", 0),
            goalEndMillis     = prefs.getLong("goalEndMillis", 0L),
            goalStartMillis   = prefs.getLong("goalStartMillis", 0L),
            birthMillis       = prefs.getLong("birthMillis", 0L),
            lifeExpYears      = prefs.getInt("lifeExpYears", 80),
            lifeUnit          = prefs.getInt("lifeUnit", 0),
        )
    }

    /** Whole days between two instants, both normalized to local midnight. */
    private fun daysBetween(startMillis: Long, endMillis: Long): Int {
        fun midnight(millis: Long): Long = Calendar.getInstance().apply {
            timeInMillis = millis
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }.timeInMillis
        return ((midnight(endMillis) - midnight(startMillis)) / 86_400_000L).toInt()
    }

    fun goalTotalDays(): Int {
        if (goalEndMillis <= 0L) return goalTotalFallback.coerceAtLeast(1)
        val start = if (goalStartMillis > 0L) goalStartMillis else System.currentTimeMillis()
        val diff = daysBetween(start, goalEndMillis)
        return if (diff <= 0) 1 else diff + 1
    }

    fun goalPastDays(): Int {
        if (goalEndMillis <= 0L) return goalPastFallback.coerceAtLeast(0)
        val total = goalTotalDays()
        val daysLeft = daysBetween(System.currentTimeMillis(), goalEndMillis).coerceAtLeast(0)
        return (total - daysLeft).coerceIn(0, total)
    }

    fun lifeTotalUnits(): Int {
        if (birthMillis <= 0L) return lifeTotalFallback.coerceAtLeast(1)
        return if (lifeUnit == 1) lifeExpYears * 52 else lifeExpYears * 365
    }

    fun lifeUnitsLived(): Int {
        if (birthMillis <= 0L) return lifeLivedFallback.coerceAtLeast(0)
        val elapsedDays = daysBetween(birthMillis, System.currentTimeMillis())
            .coerceIn(0, lifeExpYears * 365)
        val elapsed = if (lifeUnit == 1) elapsedDays / 7 else elapsedDays
        return elapsed.coerceIn(0, lifeTotalUnits())
    }
}

object DotGridRenderer {

    fun dayOfYear(): Int = Calendar.getInstance().get(Calendar.DAY_OF_YEAR)
    fun daysInYear(): Int = Calendar.getInstance().getActualMaximum(Calendar.DAY_OF_YEAR)

    private fun totalDots(s: DotzSettings): Int = when (s.mode) {
        1    -> s.goalTotalDays().coerceAtLeast(1)
        2    -> s.lifeTotalUnits().coerceAtLeast(1)
        3    -> daysInYear()
        else -> daysInYear()
    }

    private fun pastDots(s: DotzSettings): Int = when (s.mode) {
        1    -> s.goalPastDays().coerceIn(0, totalDots(s))
        2    -> s.lifeUnitsLived().coerceIn(0, totalDots(s))
        3    -> (dayOfYear() - 1).coerceIn(0, totalDots(s))
        else -> (dayOfYear() - 1).coerceIn(0, totalDots(s))
    }

    private fun resolvedLabel(s: DotzSettings): String {
        if (!s.showLabel || s.labelMode == 0) return ""
        if (s.labelMode == 2 || s.labelMode == 3) {
            return if (s.customLabel.isNotBlank()) s.customLabel else computeProgressLabel(s)
        }
        return computeProgressLabel(s)
    }

    private fun computeProgressLabel(s: DotzSettings): String = when (s.mode) {
        1 -> "${(s.goalTotalDays() - s.goalPastDays()).coerceAtLeast(0)} left · ${s.goalName}"
        2 -> {
            val total = s.lifeTotalUnits()
            val lived = s.lifeUnitsLived()
            val left  = (total - lived).coerceAtLeast(0)
            val pct   = if (total > 0) (lived * 100 / total) else 0
            val unit  = if (s.lifeUnit == 1) "weeks" else "days"
            "$left $unit left · $pct%"
        }
        else -> {
            val left = daysInYear() - dayOfYear()
            val pct  = (dayOfYear().toFloat() / daysInYear() * 100).toInt()
            "$left days left · $pct%"
        }
    }

    // Decodes bgImagePath at the smallest resolution that still covers the
    // (w, h) target, instead of BitmapFactory.decodeFile's default of
    // decoding the source at full resolution. A full-res gallery photo
    // (12MP+) decoded just to be scaled down afterward risks an OOM in the
    // wallpaper/widget process, which has a much tighter memory budget than
    // a normal activity.
    private fun decodeSampledBitmap(path: String, reqWidth: Int, reqHeight: Int): Bitmap? {
        val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
        BitmapFactory.decodeFile(path, bounds)
        if (bounds.outWidth <= 0 || bounds.outHeight <= 0) return null

        var inSampleSize = 1
        if (bounds.outHeight > reqHeight || bounds.outWidth > reqWidth) {
            val halfHeight = bounds.outHeight / 2
            val halfWidth  = bounds.outWidth / 2
            while ((halfHeight / inSampleSize) >= reqHeight &&
                   (halfWidth  / inSampleSize) >= reqWidth) {
                inSampleSize *= 2
            }
        }

        val opts = BitmapFactory.Options().apply { inSampleSize = inSampleSize }
        return BitmapFactory.decodeFile(path, opts)
    }

    private fun createStarPath(cx: Float, cy: Float, outerRadius: Float, innerRadius: Float, numPoints: Int): Path {
        val path = Path()
        val step = Math.PI / numPoints
        var angle = -Math.PI / 2.0

        for (i in 0 until numPoints * 2) {
            val radius = if (i % 2 == 0) outerRadius else innerRadius
            val dx = (cx + cos(angle) * radius).toFloat()
            val dy = (cy + sin(angle) * radius).toFloat()
            if (i == 0) path.moveTo(dx, dy) else path.lineTo(dx, dy)
            angle += step
        }
        path.close()
        return path
    }

    /** Regular polygon (sides=6 -> hexagon, sides=4 -> diamond), point-up. */
    private fun createPolygonPath(cx: Float, cy: Float, r: Float, sides: Int): Path {
        val path = Path()
        val step = 2.0 * Math.PI / sides
        var angle = -Math.PI / 2.0

        for (i in 0 until sides) {
            val dx = (cx + cos(angle) * r).toFloat()
            val dy = (cy + sin(angle) * r).toFloat()
            if (i == 0) path.moveTo(dx, dy) else path.lineTo(dx, dy)
            angle += step
        }
        path.close()
        return path
    }

    private fun drawShapes(
        canvas: Canvas, pts: FloatArray, count: Int, paint: Paint,
        dotShape: Int, dotRadius: Float, paintGlassRim: Paint,
    ) {
        if (count == 0) return
        val paintGlassFill = Paint(Paint.ANTI_ALIAS_FLAG)

        when (dotShape) {
            0 -> {
                paint.strokeCap = Paint.Cap.ROUND
                canvas.drawPoints(pts, 0, count, paint)
            }
            1 -> {
                val cornerRadius = dotRadius * 0.4f
                for (i in 0 until count step 2) {
                    val cx = pts[i]; val cy = pts[i + 1]
                    canvas.drawRoundRect(
                        cx - dotRadius, cy - dotRadius,
                        cx + dotRadius, cy + dotRadius,
                        cornerRadius, cornerRadius, paint
                    )
                }
            }
            2 -> {
                for (i in 0 until count step 2) {
                    val path = createStarPath(pts[i], pts[i + 1], dotRadius, dotRadius * 0.45f, 5)
                    canvas.drawPath(path, paint)
                }
            }
            3 -> {
                paintGlassFill.color = Color.argb(128, Color.red(paint.color), Color.green(paint.color), Color.blue(paint.color))
                for (i in 0 until count step 2) {
                    val cx = pts[i]; val cy = pts[i + 1]
                    canvas.drawCircle(cx, cy, dotRadius, paintGlassFill)
                    canvas.drawCircle(cx, cy, dotRadius, paintGlassRim)
                }
            }
            4 -> {
                for (i in 0 until count step 2) {
                    val path = createPolygonPath(pts[i], pts[i + 1], dotRadius, 6)
                    canvas.drawPath(path, paint)
                }
            }
            5 -> {
                for (i in 0 until count step 2) {
                    val path = createPolygonPath(pts[i], pts[i + 1], dotRadius, 4)
                    canvas.drawPath(path, paint)
                }
            }
        }
    }

    private fun drawWrappedText(
        canvas: Canvas, text: String, x: Float, startY: Float,
        maxWidth: Float, lineHeight: Float, paint: Paint,
    ) {
        val words = text.split(" ")
        var line = ""
        var y = startY
        for (word in words) {
            val test = if (line.isEmpty()) word else "$line $word"
            if (paint.measureText(test) <= maxWidth) {
                line = test
            } else {
                if (line.isNotEmpty()) canvas.drawText(line, x, y, paint)
                line = word
                y += lineHeight
            }
        }
        if (line.isNotEmpty()) canvas.drawText(line, x, y, paint)
    }

    /** Renders the full Dotz grid (background + dots + label) into a new bitmap. */
    fun buildBitmap(w: Int, h: Int, s: DotzSettings): Bitmap? {
        if (w <= 0 || h <= 0) return null
        val bitmap = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)

        val paintPast   = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = s.pastColor }
        val paintFuture = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = s.futureColor }
        val paintToday  = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = s.todayColor }
        val paintText   = Paint(Paint.ANTI_ALIAS_FLAG).apply { textAlign = Paint.Align.CENTER }
        val paintGlassRim = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.STROKE
            strokeWidth = 2f
            color = Color.argb(100, 255, 255, 255)
        }
        val cap = if (s.dotShape == 1) Paint.Cap.SQUARE else Paint.Cap.ROUND
        paintPast.strokeCap = cap; paintFuture.strokeCap = cap; paintToday.strokeCap = cap

        // ── Background ───────────────────────────────────────────
        if (s.bgImagePath.isNotEmpty()) {
            try {
                val bgImg = decodeSampledBitmap(s.bgImagePath, w, h)
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
                    canvas.drawColor(s.bgColor)
                }
            } catch (e: Exception) {
                canvas.drawColor(s.bgColor)
            }
        } else {
            canvas.drawColor(s.bgColor)
        }

        val shiftX = s.offsetX * w
        val shiftY = s.offsetY * h
        var dotRadius: Float
        var gridBottomY: Float

        if (s.mode == 3) {
            val monthNames = arrayOf("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
            val year = Calendar.getInstance().get(Calendar.YEAR)
            val todayDoy = dayOfYear()

            val availW = w * 0.85f * s.gridScale
            val availH = h * 0.65f * s.gridScale
            val blockW = availW / 3f
            val blockH = availH / 4f

            val cell = (blockW * 0.80f) / 7f
            dotRadius = (cell * 0.8f) / 2f

            val d = dotRadius * 2f
            paintPast.strokeWidth = d; paintFuture.strokeWidth = d; paintToday.strokeWidth = d

            val startX = (w - availW) / 2f + (blockW * 0.1f) + shiftX
            val startY = (h - availH) / 2f + (h * 0.05f) + shiftY
            gridBottomY = startY + availH

            val pastPts = FloatArray(366 * 2)
            val futurePts = FloatArray(366 * 2)
            val todayPt = FloatArray(2)
            var pIdx = 0; var fIdx = 0; var drewToday = false
            var currentDoy = 1

            paintText.color = s.labelColor
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
                        currentDoy < todayDoy -> { pastPts[pIdx++] = cx; pastPts[pIdx++] = cy }
                        currentDoy == todayDoy -> { todayPt[0] = cx; todayPt[1] = cy; drewToday = true }
                        else -> { futurePts[fIdx++] = cx; futurePts[fIdx++] = cy }
                    }
                    currentDoy++
                }
            }

            drawShapes(canvas, pastPts, pIdx, paintPast, s.dotShape, dotRadius, paintGlassRim)
            if (drewToday) drawShapes(canvas, todayPt, 2, paintToday, s.dotShape, dotRadius, paintGlassRim)
            drawShapes(canvas, futurePts, fIdx, paintFuture, s.dotShape, dotRadius, paintGlassRim)

            paintText.textAlign = Paint.Align.CENTER
            paintText.typeface = Typeface.DEFAULT

        } else {
            val total = totalDots(s)
            val availW = w * 0.90f * s.gridScale
            val availH = h * 0.88f * s.gridScale

            val effectiveCols = if (s.mode == 2 && total > 1000) {
                sqrt(total.toDouble() * w / h).toInt().coerceIn(30, 120)
            } else {
                s.columns
            }

            var r = availW / (effectiveCols * 2.5f - 0.5f)
            val rows0 = ceil(total.toFloat() / effectiveCols).toInt()
            val gridH0 = rows0 * (r * 2.5f) - r * 0.5f
            if (gridH0 > availH) {
                val rH = availH / (rows0 * 2.5f - 0.5f)
                if (rH < r) r = rH
            }
            dotRadius = r.coerceIn(1.5f, 28f)
            val dotSpacing = dotRadius * 0.5f
            val renderCols = effectiveCols

            val d = dotRadius * 2f
            paintPast.strokeWidth = d; paintFuture.strokeWidth = d; paintToday.strokeWidth = d

            val safePast = pastDots(s).coerceIn(0, total)
            val futCount = (total - safePast - 1).coerceAtLeast(0)

            val pastPts = FloatArray(safePast * 2)
            val todayPt = FloatArray(2)
            val futurePts = FloatArray(futCount * 2)
            var pIdx = 0; var fIdx = 0; var drewToday = false

            val cell = dotRadius * 2f + dotSpacing
            val rows = ceil(total.toFloat() / renderCols).toInt()
            val gridW = renderCols * cell - dotSpacing
            val gridH = rows * cell - dotSpacing

            val ox = (w - gridW) / 2f + shiftX
            val oy = (h - gridH) / 2f + shiftY
            gridBottomY = oy + gridH

            for (i in 0 until total) {
                val cx = ox + (i % renderCols) * cell + dotRadius
                val cy = oy + (i / renderCols) * cell + dotRadius
                when {
                    i < safePast -> {
                        if (pIdx + 1 < pastPts.size) { pastPts[pIdx++] = cx; pastPts[pIdx++] = cy }
                    }
                    i == safePast -> { todayPt[0] = cx; todayPt[1] = cy; drewToday = true }
                    else -> {
                        if (fIdx + 1 < futurePts.size) { futurePts[fIdx++] = cx; futurePts[fIdx++] = cy }
                    }
                }
            }

            drawShapes(canvas, pastPts, pIdx, paintPast, s.dotShape, dotRadius, paintGlassRim)
            if (drewToday) drawShapes(canvas, todayPt, 2, paintToday, s.dotShape, dotRadius, paintGlassRim)
            drawShapes(canvas, futurePts, fIdx, paintFuture, s.dotShape, dotRadius, paintGlassRim)
        }

        val label = resolvedLabel(s)
        if (label.isNotEmpty()) {
            val density = Resources.getSystem().displayMetrics.density
            val textSizePx = if (s.labelFontSizeSp > 0f) {
                s.labelFontSizeSp * density
            } else {
                (dotRadius * 1.8f).coerceAtLeast(10f * density)
            }

            paintText.color = s.labelColor
            paintText.textSize = textSizePx
            paintText.letterSpacing = 0.04f

            val gap = dotRadius * 3f
            val startY = gridBottomY + gap + textSizePx

            val isLong = label.length > 60 && (s.labelMode == 2 || s.labelMode == 3)
            val lineH = textSizePx * 1.45f
            if (isLong) {
                drawWrappedText(canvas, label, w / 2f, startY, w * 0.85f, lineH, paintText)
            } else {
                canvas.drawText(label, w / 2f, startY, paintText)
            }
        }

        return bitmap
    }
}
