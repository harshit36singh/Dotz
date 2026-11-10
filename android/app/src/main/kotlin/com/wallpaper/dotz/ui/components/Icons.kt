package com.wallpaper.dotz.ui.components

import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.StrokeJoin
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.graphics.vector.addPathNodes
import androidx.compose.ui.unit.dp

/** Stroke icons from the design (24 viewBox, 1.8 stroke, round caps). */
object DotzIcons {

    private fun circle(cx: Float, cy: Float, r: Float) =
        "M${cx - r},${cy}a$r,$r 0 1,0 ${2 * r},0a$r,$r 0 1,0 ${-2 * r},0z"

    private fun roundRect(x: Float, y: Float, w: Float, h: Float, r: Float) =
        "M${x + r},${y}h${w - 2 * r}a$r,$r 0 0,1 $r,$r" +
            "v${h - 2 * r}a$r,$r 0 0,1 ${-r},$r" +
            "h${-(w - 2 * r)}a$r,$r 0 0,1 ${-r},${-r}" +
            "v${-(h - 2 * r)}a$r,$r 0 0,1 $r,${-r}z"

    private fun icon(name: String, vararg paths: String, strokeWidth: Float = 1.8f): ImageVector =
        ImageVector.Builder(name, 24.dp, 24.dp, 24f, 24f).apply {
            paths.forEach { d ->
                addPath(
                    pathData = addPathNodes(d),
                    fill = null,
                    stroke = SolidColor(Color.Black),
                    strokeLineWidth = strokeWidth,
                    strokeLineCap = StrokeCap.Round,
                    strokeLineJoin = StrokeJoin.Round,
                )
            }
        }.build()

    val Year = icon("year", circle(7f, 7f, 2.2f), circle(17f, 7f, 2.2f), circle(7f, 17f, 2.2f), circle(17f, 17f, 2.2f))
    val Calendar = icon("calendar", roundRect(3.5f, 5f, 17f, 15f, 3f), "M3.5 10h17M8 3v4M16 3v4")
    val Goal = icon("goal", circle(12f, 12f, 8.5f), circle(12f, 12f, 4f))
    val Life = icon("life", "M6.5 3.5h11M6.5 20.5h11M8 3.5c0 4.5 8 4.5 8 8.5s-8 4-8 8.5M16 3.5c0 4.5-8 4.5-8 8.5s8 4 8 8.5")
    val Look = icon("look", "M4 7h9M19 7h1M4 17h3M13 17h7", circle(16f, 7f, 2.5f), circle(10f, 17f, 2.5f))
    val Pencil = icon("pencil", "M4 20h4L19 9l-4-4L4 16v4z", "M13.5 6.5l4 4")
    val ArrowRight = icon("arrow", "M5 12h14M13 6l6 6-6 6", strokeWidth = 2f)
    val ArrowLeft = icon("back", "M19 12H5M11 6l-6 6 6 6", strokeWidth = 2f)
    val Chevron = icon("chevron", "M9 6l6 6-6 6", strokeWidth = 2f)
    val ChevronDown = icon("chevron_down", "M6 9l6 6 6-6", strokeWidth = 2f)
    val Reset = icon("reset", "M4 12a8 8 0 1 0 2.4-5.7", "M4 4v4h4")
    val Close = icon("close", "M6 6l12 12M18 6L6 18")
    val Plus = icon("plus", "M12 5v14M5 12h14")
    val Image = icon("image", roundRect(3.5f, 4.5f, 17f, 15f, 3f), "M3.5 16l5-5 4 4 3-3 5 5", circle(15.5f, 9f, 1.5f))
}
