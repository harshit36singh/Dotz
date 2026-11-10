package com.wallpaper.dotz.ui.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.wallpaper.dotz.ui.theme.PipEye
import com.wallpaper.dotz.ui.theme.PipOrange

enum class PipMood { IDLE, HAPPY, CURIOUS, CHEER, WINK, SLEEPY }

/**
 * Pip, the dotz mascot: a circle and two eyes, drawn from the 100-unit
 * viewBox geometry in the design spec (no image assets needed).
 *
 * @param blink 1 = eyes open, 0.1 = closed (only affects ellipse eyes).
 */
@Composable
fun Pip(
    modifier: Modifier = Modifier,
    size: Dp = 48.dp,
    mood: PipMood = PipMood.IDLE,
    color: Color = PipOrange,
    blink: Float = 1f,
    contentDescription: String? = null,
) {
    val semantics = if (contentDescription != null) {
        Modifier.semantics { this.contentDescription = contentDescription }
    } else Modifier
    // At chip sizes the eyes are drawn a little bigger so they stay legible.
    val boldEyes = size < 32.dp
    Canvas(modifier.size(size).then(semantics)) {
        drawPip(mood, color, blink, boldEyes)
    }
}

fun DrawScope.drawPip(mood: PipMood, color: Color, blink: Float = 1f, boldEyes: Boolean = false) {
    val u = this.size.minDimension / 100f
    fun p(x: Float, y: Float) = Offset(x * u, y * u)
    drawCircle(color, radius = 48f * u, center = p(50f, 50f))

    val rx = if (boldEyes) 7f else 5.5f
    val ry = if (boldEyes) 10f else 8f
    fun eye(cx: Float, cy: Float) {
        val h = ry * blink
        drawOval(PipEye, topLeft = p(cx - rx, cy - h), size = Size(2 * rx * u, 2 * h * u))
    }
    val stroke = Stroke(width = 6f * u, cap = StrokeCap.Round)
    fun arc(x0: Float, y0: Float, qx: Float, qy: Float, x1: Float, y1: Float) {
        val path = Path().apply {
            moveTo(x0 * u, y0 * u)
            quadraticTo(qx * u, qy * u, x1 * u, y1 * u)
        }
        drawPath(path, PipEye, style = stroke)
    }
    fun happyEyes() {
        arc(30f, 50f, 37f, 39f, 44f, 50f)
        arc(56f, 50f, 63f, 39f, 70f, 50f)
    }

    when (mood) {
        PipMood.IDLE -> { eye(37f, 46f); eye(63f, 46f) }
        PipMood.CURIOUS -> { eye(42f, 39f); eye(66f, 39f) }
        PipMood.HAPPY -> happyEyes()
        PipMood.CHEER -> {
            happyEyes()
            val mouth = Path().apply {
                moveTo(38f * u, 62f * u)
                quadraticTo(50f * u, 78f * u, 62f * u, 62f * u)
                close()
            }
            drawPath(mouth, PipEye)
        }
        PipMood.WINK -> {
            eye(37f, 46f)
            arc(56f, 47f, 63f, 41f, 70f, 47f)
        }
        PipMood.SLEEPY -> {
            arc(30f, 47f, 37f, 54f, 44f, 47f)
            arc(56f, 47f, 63f, 54f, 70f, 47f)
        }
    }
}
