package com.wallpaper.dotz.ui.screens

import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.CubicBezierEasing
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.unit.dp
import com.wallpaper.dotz.ui.components.Pip
import com.wallpaper.dotz.ui.theme.DotzType
import com.wallpaper.dotz.ui.theme.Ink
import kotlinx.coroutines.delay

/** easeOutCubic, the app's one motion curve. */
val EaseOutCubic = CubicBezierEasing(0.33f, 1f, 0.68f, 1f)

@Composable
fun SplashScreen(onFinished: () -> Unit) {
    val fade = remember { Animatable(0f) }
    val blink = remember { Animatable(1f) }
    LaunchedEffect(Unit) {
        fade.animateTo(1f, tween(220, easing = EaseOutCubic))
        delay(400)
        // One blink just before moving on.
        blink.animateTo(0.1f, tween(80))
        blink.animateTo(1f, tween(80))
        delay(20)
        onFinished()
    }
    Column(
        Modifier
            .fillMaxSize()
            .background(Ink)
            .alpha(fade.value),
        verticalArrangement = Arrangement.spacedBy(22.dp, Alignment.CenterVertically),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Pip(size = 88.dp, blink = blink.value, contentDescription = "Pip")
        Text("dotz", style = DotzType.wordmark)
    }
}
