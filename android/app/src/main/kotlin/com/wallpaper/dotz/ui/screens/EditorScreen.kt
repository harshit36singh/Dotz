package com.wallpaper.dotz.ui.screens

import androidx.compose.foundation.gestures.detectTransformGestures
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.border
import androidx.compose.foundation.background
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.unit.dp
import com.wallpaper.dotz.DotzViewModel
import com.wallpaper.dotz.data.DotzState
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

    Box(Modifier.fillMaxSize()) {
        LockScreenContent(
            settings = settings,
            modifier = Modifier
                .fillMaxSize()
                .pointerInput(Unit) {
                    detectTransformGestures { _, pan, zoom, _ ->
                        val s = current
                        vm.setTransform(
                            s.gridScale * zoom,
                            s.offsetX + pan.x / size.width,
                            s.offsetY + pan.y / size.height,
                        )
                    }
                },
        )

        Text(
            "Pinch to zoom · drag to pan",
            style = DotzType.label.copy(color = TextSoft),
            modifier = Modifier
                .align(Alignment.TopCenter)
                .statusBarsPadding()
                .padding(top = 220.dp)
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
            RoundIconButton(DotzIcons.Reset, "Reset position", vm::resetTransform)
            Box(Modifier.weight(1f))
            PrimaryButton("Done", onDone, Modifier.widthIn(min = 120.dp), height = 52.dp, horizontalPadding = 32.dp)
        }
    }
}
