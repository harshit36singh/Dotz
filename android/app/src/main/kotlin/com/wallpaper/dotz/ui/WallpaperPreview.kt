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
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.withContext
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/** Loads the label typeface the wallpaper uses (Inter Medium). */
fun loadLabelTypeface(context: android.content.Context): Typeface? =
    runCatching { ResourcesCompat.getFont(context, R.font.inter_medium) }.getOrNull()

/**
 * Renders [settings] with the same [DotGridRenderer] the wallpaper uses, at
 * the real screen resolution, off the main thread. Newer settings cancel
 * older renders, so pinch/drag stays responsive.
 */
@Composable
fun rememberWallpaperBitmap(settings: DotzSettings): ImageBitmap? {
    val context = LocalContext.current
    val window = LocalWindowInfo.current.containerSize
    val typeface = remember { loadLabelTypeface(context) }
    val latest by rememberUpdatedState(settings)
    var image by remember { mutableStateOf<ImageBitmap?>(null) }
    LaunchedEffect(window) {
        if (window.width <= 0 || window.height <= 0) return@LaunchedEffect
        snapshotFlow { latest }.collectLatest { s ->
            val bmp: Bitmap? = withContext(Dispatchers.Default) {
                DotGridRenderer.buildBitmap(window.width, window.height, s, typeface)
            }
            if (bmp != null) image = bmp.asImageBitmap()
        }
    }
    return image
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
 */
@Composable
fun LockScreenContent(settings: DotzSettings, modifier: Modifier = Modifier, scale: Float = 1f) {
    val image = rememberWallpaperBitmap(settings)
    val now = rememberNow()
    Box(modifier.background(Color(settings.bgColor))) {
        if (image != null) {
            Image(
                bitmap = image,
                contentDescription = null,
                contentScale = ContentScale.Crop,
                modifier = Modifier.fillMaxSize(),
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
