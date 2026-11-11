package com.wallpaper.dotz.ui

import android.graphics.Bitmap
import android.graphics.Typeface
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.produceState
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.runtime.setValue
import androidx.compose.runtime.snapshotFlow
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.TransformOrigin
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.platform.LocalWindowInfo
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.content.res.ResourcesCompat
import com.wallpaper.dotz.DotGridRenderer
import com.wallpaper.dotz.DotzSettings
import com.wallpaper.dotz.R
import com.wallpaper.dotz.ui.theme.DotzType
import com.wallpaper.dotz.ui.theme.Inter
import com.wallpaper.dotz.ui.theme.Ring
import com.wallpaper.dotz.ui.theme.Surface
import com.wallpaper.dotz.ui.theme.TextSoft
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.conflate
import kotlinx.coroutines.withContext
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/** Loads the label typeface the wallpaper uses (Inter Medium). */
fun loadLabelTypeface(context: android.content.Context): Typeface? =
    runCatching { ResourcesCompat.getFont(context, R.font.inter_medium) }.getOrNull()

/** Grid position and size, as stored in DotzState (scale 0.2..3, offsets -1..1). */
data class GridTransform(val scale: Float, val x: Float, val y: Float) {
    fun clamped() = GridTransform(scale.coerceIn(0.2f, 3f), x.coerceIn(-1f, 1f), y.coerceIn(-1f, 1f))
}

/** A rendered dots layer (transparent background) and the settings it was drawn from. */
class RenderedGrid(val image: ImageBitmap, val settings: DotzSettings)

/**
 * Renders the dots + label for [settings] with the same [DotGridRenderer] the
 * wallpaper uses, at the real screen resolution, off the main thread, on a
 * transparent background (the background is its own layer, see
 * [LockScreenContent]).
 *
 * Renders are conflated, not cancelled: a render can't be interrupted
 * mid-draw, so cancelling it whenever settings change (e.g. every frame of a
 * slider drag) meant no render ever finished until you let go. Now every
 * finished render is shown, and only the newest pending settings are drawn next.
 */
@Composable
fun rememberGridLayer(settings: DotzSettings): RenderedGrid? {
    val context = LocalContext.current
    val window = LocalWindowInfo.current.containerSize
    val typeface = remember { loadLabelTypeface(context) }
    val latest by rememberUpdatedState(settings)
    var grid by remember { mutableStateOf<RenderedGrid?>(null) }
    LaunchedEffect(window) {
        if (window.width <= 0 || window.height <= 0) return@LaunchedEffect
        snapshotFlow { latest }.conflate().collect { s ->
            val bmp: Bitmap? = withContext(Dispatchers.Default) {
                DotGridRenderer.buildBitmap(window.width, window.height, s, typeface, drawBackground = false)
            }
            if (bmp != null) grid = RenderedGrid(bmp.asImageBitmap(), s)
        }
    }
    return grid
}

/** The background photo, decoded once per path at about screen size. */
@Composable
private fun rememberBackgroundPhoto(path: String): ImageBitmap? {
    val window = LocalWindowInfo.current.containerSize
    val photo by produceState<ImageBitmap?>(null, path, window) {
        value = if (path.isEmpty() || window.width <= 0) null else withContext(Dispatchers.IO) {
            runCatching {
                DotGridRenderer.decodeSampledBitmap(path, window.width, window.height)?.asImageBitmap()
            }.getOrNull()
        }
    }
    return photo
}

/** Live "now" for the fake lock-screen clock, refreshed every 30 s. */
@Composable
private fun rememberNow(): Date {
    val now by produceState(Date()) {
        while (true) {
            kotlinx.coroutines.delay(30_000)
            value = Date()
        }
    }
    return now
}

/**
 * The wallpaper with a fake lock-screen date + clock on top, filling its
 * parent. [scale] shrinks the overlay text for the small phone preview.
 *
 * Drawn as layers that match the renderer: background colour, the photo
 * (centre-cropped and dimmed exactly like the wallpaper), then the dots.
 * [liveTransform] moves and scales the already-rendered dots on the GPU while
 * a pinch/drag is in progress, so the editor follows your fingers at full
 * frame rate; a sharp re-render happens once the gesture is committed.
 */
@Composable
fun LockScreenContent(
    settings: DotzSettings,
    modifier: Modifier = Modifier,
    scale: Float = 1f,
    liveTransform: GridTransform? = null,
) {
    val grid = rememberGridLayer(settings)
    val photo = rememberBackgroundPhoto(settings.bgImagePath)
    val now = rememberNow()
    Box(modifier.background(Color(settings.bgColor))) {
        if (photo != null) {
            Image(photo, contentDescription = null, contentScale = ContentScale.Crop, modifier = Modifier.fillMaxSize())
            Box(
                Modifier
                    .fillMaxSize()
                    .background(Color.Black.copy(alpha = DotGridRenderer.PHOTO_DIM_ALPHA / 255f)),
            )
        }
        if (grid != null) {
            val from = grid.settings
            val target = liveTransform ?: GridTransform(settings.gridScale, settings.offsetX, settings.offsetY)
            Image(
                bitmap = grid.image,
                contentDescription = null,
                contentScale = ContentScale.Crop,
                modifier = Modifier
                    .fillMaxSize()
                    .graphicsLayer {
                        // Map the transform the bitmap was rendered with onto the
                        // one being shown: scale about the rendered grid's centre,
                        // then shift. Identity once the re-render catches up.
                        val k = target.scale / from.gridScale
                        scaleX = k
                        scaleY = k
                        translationX = (target.x - from.offsetX) * size.width
                        translationY = (target.y - from.offsetY) * size.height
                        val monthShift = if (from.mode == 3) 0.05f else 0f
                        transformOrigin = TransformOrigin(0.5f + from.offsetX, 0.5f + from.offsetY + monthShift)
                    },
            )
        }
        // Full-screen sizes; the 240dp phone preview (scale ~0.6) lands on the
        // design's 11px date / 54px clock / 44px top inset.
        Column(
            Modifier
                .fillMaxWidth()
                .padding(top = (72f * scale).dp),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            val date = remember(now) { SimpleDateFormat("EEEE, d MMMM", Locale.getDefault()).format(now) }
            val time = remember(now) { SimpleDateFormat("HH:mm", Locale.getDefault()).format(now) }
            Text(date, style = TextStyle(fontFamily = Inter, fontSize = (18f * scale).sp, color = TextSoft))
            Text(time, style = DotzType.clock.copy(fontSize = (88f * scale).sp, letterSpacing = (-1.6f * scale).sp))
        }
    }
}

/**
 * Phone-shaped preview: [width] wide, screen aspect ratio, radius 38,
 * 1px hairline + 7px surface ring.
 */
@Composable
fun PhonePreview(settings: DotzSettings, width: Dp, modifier: Modifier = Modifier) {
    val window = LocalWindowInfo.current.containerSize
    val density = LocalDensity.current
    val ratio = if (window.width > 0) window.height.toFloat() / window.width else 2.0f
    val screenWidthDp = with(density) { window.width.toDp() }.value.takeIf { it > 0 } ?: 390f
    val scale = width.value / screenWidthDp
    val outer = RoundedCornerShape(45.dp)
    val inner = RoundedCornerShape(38.dp)
    Box(
        modifier
            .clip(outer)
            .background(Surface)
            .padding(7.dp)
            .semantics { contentDescription = "Lock screen preview" },
    ) {
        LockScreenContent(
            settings = settings,
            scale = scale,
            modifier = Modifier
                .size(width, width * ratio)
                .clip(inner)
                .border(1.dp, Ring, inner),
        )
    }
}
