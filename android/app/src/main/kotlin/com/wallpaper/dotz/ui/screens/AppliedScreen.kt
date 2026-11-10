package com.wallpaper.dotz.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.safeDrawingPadding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.wallpaper.dotz.ui.components.Pip
import com.wallpaper.dotz.ui.components.PipMood
import com.wallpaper.dotz.ui.components.PrimaryButton
import com.wallpaper.dotz.ui.theme.DotFuture
import com.wallpaper.dotz.ui.theme.DotPast
import com.wallpaper.dotz.ui.theme.DotzType
import com.wallpaper.dotz.ui.theme.Ink

@Composable
fun AppliedScreen(onDone: () -> Unit) {
    Column(
        Modifier
            .fillMaxSize()
            .background(Ink)
            .safeDrawingPadding()
            .padding(start = 24.dp, end = 24.dp, top = 24.dp, bottom = 32.dp),
    ) {
        Column(
            Modifier
                .weight(1f)
                .fillMaxWidth(),
            verticalArrangement = Arrangement.spacedBy(18.dp, Alignment.CenterVertically),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            Box(Modifier.size(200.dp, 160.dp), contentAlignment = Alignment.Center) {
                // Confetti of past/future dots around Pip (positions from the design).
                ScatterDot(14.dp, 30.dp, 10.dp, DotFuture)
                ScatterDot(40.dp, 4.dp, 7.dp, DotPast)
                ScatterDot(200.dp - 22.dp - 12.dp, 12.dp, 12.dp, DotFuture)
                ScatterDot(200.dp - 6.dp - 7.dp, 70.dp, 7.dp, DotPast)
                ScatterDot(2.dp, 160.dp - 30.dp - 7.dp, 7.dp, DotPast)
                ScatterDot(200.dp - 40.dp - 9.dp, 160.dp - 4.dp - 9.dp, 9.dp, DotFuture)
                Pip(size = 120.dp, mood = PipMood.CHEER, contentDescription = "Pip cheering")
            }
            Text("You’re all set.", style = DotzType.appliedTitle)
            Text(
                "Check your lock screen. A new dot fills in every midnight.",
                style = DotzType.bodyLarge,
                textAlign = TextAlign.Center,
                modifier = Modifier.widthIn(max = 280.dp),
            )
        }
        PrimaryButton("Done", onDone, Modifier.fillMaxWidth())
    }
}

@Composable
private fun ScatterDot(x: Dp, y: Dp, size: Dp, color: Color) {
    // Full-size layer so offsets are measured from the top-left corner.
    Box(Modifier.fillMaxSize()) {
        Box(
            Modifier
                .offset(x, y)
                .size(size)
                .clip(CircleShape)
                .background(color),
        )
    }
}
