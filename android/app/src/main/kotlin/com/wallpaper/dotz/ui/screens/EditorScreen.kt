package com.wallpaper.dotz.ui.screens

import androidx.compose.foundation.gestures.awaitEachGesture
import androidx.compose.foundation.gestures.awaitFirstDown
import androidx.compose.foundation.gestures.calculatePan
import androidx.compose.foundation.gestures.calculateZoom
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.border
import androidx.compose.foundation.background
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.runtime.setValue
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.input.pointer.positionChanged
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.unit.dp
import com.wallpaper.dotz.DotzViewModel
import com.wallpaper.dotz.data.DotzState
import com.wallpaper.dotz.ui.GridTransform
import com.wallpaper.dotz.ui.LockScreenContent
import com.wallpaper.dotz.ui.components.DotzIcons
import com.wallpaper.dotz.ui.components.PrimaryButton
import com.wallpaper.dotz.ui.components.RoundIconButton
import com.wallpaper.dotz.ui.theme.DotzType
import com.wallpaper.dotz.ui.theme.Rule
import com.wallpaper.dotz.ui.theme.Surface
import com.wallpaper.dotz.ui.theme.TextSoft

/** Full-screen wallpaper: pinch to resize the grid, drag to move it. */
@Composable
fun EditorScreen(vm: DotzViewModel, state: DotzState, onDone: () -> Unit) {
    val settings = remember(state) { state.toSettings() }
    val current by rememberUpdatedState(state)
    // Where the grid is shown while (and right after) a gesture. Pinch/drag only
    // updates this, which moves the already-rendered grid on the GPU; the
    // position is saved once, when the fingers lift, and that triggers a single
    // sharp re-render. Re-rendering on every touch event made the editor stall.
    var live by remember { mutableStateOf<GridTransform?>(null) }

    Box(Modifier.fillMaxSize()) {
        LockScreenContent(
            settings = settings,
            liveTransform = live,
            modifier = Modifier
                .fillMaxSize()
                .pointerInput(Unit) {
                    awaitEachGesture {
                        awaitFirstDown(requireUnconsumed = false)
                        val s = current
                        var t = live ?: GridTransform(s.gridScale, s.offsetX, s.offsetY)
                        var moved = false
                        do {
                            val event = awaitPointerEvent()
                            val zoom = event.calculateZoom()
                            val pan = event.calculatePan()
                            if (zoom != 1f || pan != Offset.Zero) {
                                t = GridTransform(t.scale * zoom, t.x + pan.x / size.width, t.y + pan.y / size.height).clamped()
                                live = t
                                moved = true
                                event.changes.forEach { if (it.positionChanged()) it.consume() }
                            }
                        } while (event.changes.any { it.pressed })
                        if (moved) vm.setTransform(t.scale, t.x, t.y)
                    }
                },
        )

        Text(
            "Pinch to zoom · drag to pan",
            style = DotzType.label.copy(color = TextSoft),
            modifier = Modifier
                // Above the buttons, clear of the clock and the grid.
                .align(Alignment.BottomCenter)
                .navigationBarsPadding()
                .padding(bottom = 128.dp)
                .clip(CircleShape)
                .background(Surface)
                .border(1.dp, Rule, CircleShape)
                .padding(horizontal = 16.dp, vertical = 9.dp),
        )

        Row(
            Modifier
                .align(Alignment.BottomCenter)
                .fillMaxWidth()
                .navigationBarsPadding()
                .padding(horizontal = 24.dp, vertical = 32.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            RoundIconButton(DotzIcons.Reset, "Reset position", {
                live = null
                vm.resetTransform()
            })
            Box(Modifier.weight(1f))
            PrimaryButton("Done", onDone, Modifier.widthIn(min = 120.dp), height = 52.dp, horizontalPadding = 32.dp)
        }
    }
}
