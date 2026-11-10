package com.wallpaper.dotz.ui.screens

import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.requiredSize
import androidx.compose.foundation.layout.safeDrawingPadding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.semantics.clearAndSetSemantics
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.withStyle
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.wallpaper.dotz.ui.components.DotzIcons
import com.wallpaper.dotz.ui.components.PageIndicator
import com.wallpaper.dotz.ui.components.Pip
import com.wallpaper.dotz.ui.components.PipMood
import com.wallpaper.dotz.ui.components.PrimaryButton
import com.wallpaper.dotz.ui.components.TextAction
import com.wallpaper.dotz.ui.theme.DotFuture
import com.wallpaper.dotz.ui.theme.DotPast
import com.wallpaper.dotz.ui.theme.DotzType
import com.wallpaper.dotz.ui.theme.Ink
import com.wallpaper.dotz.ui.theme.Rule
import com.wallpaper.dotz.ui.theme.Surface
import com.wallpaper.dotz.ui.theme.TextPrimary
import com.wallpaper.dotz.ui.theme.TextSoft
import kotlinx.coroutines.launch
import java.util.Calendar

private data class OnboardPage(val title: String, val body: String, val art: @Composable () -> Unit)

private val pages = listOf(
    OnboardPage("Every day\nis a dot.", "Your year fills in one dot at a time. Meet Pip, who marks today.") { YearArt() },
    OnboardPage("Every month,\nin order.", "Twelve months in a clean grid. Pip shows where you are.") { MonthArt() },
    OnboardPage("Count down to\nwhat matters.", "Pick a date. Pip walks the dots with you until you get there.") { GoalArt() },
    OnboardPage("Your whole life\nat a glance.", "Every week is one dot, and none of them are wasted. Make every dot count.") { LifeArt() },
)

@Composable
fun OnboardingScreen(onFinished: () -> Unit) {
    val pager = rememberPagerState { pages.size }
    val scope = rememberCoroutineScope()
    val last = pager.currentPage == pages.lastIndex

    Column(
        Modifier
            .fillMaxSize()
            .background(Ink)
            .safeDrawingPadding()
            .padding(start = 24.dp, end = 24.dp, top = 16.dp, bottom = 32.dp),
    ) {
        Box(
            Modifier
                .fillMaxWidth()
                .height(44.dp),
            contentAlignment = Alignment.CenterEnd,
        ) {
            if (!last) TextAction("Skip", onFinished, Modifier.offset(x = 12.dp))
        }

        HorizontalPager(state = pager, modifier = Modifier.weight(1f)) { i ->
            val page = pages[i]
            Column(Modifier.fillMaxSize()) {
                Box(
                    Modifier
                        .weight(1f)
                        .fillMaxWidth()
                        .clearAndSetSemantics { },
                    contentAlignment = Alignment.Center,
                ) { page.art() }
                Column(
                    Modifier.padding(bottom = 36.dp),
                    verticalArrangement = Arrangement.spacedBy(14.dp),
                ) {
                    Text(page.title, style = DotzType.onboardingTitle)
                    Text(page.body, style = DotzType.bodyLarge)
                }
            }
        }

        if (last) {
            Column(verticalArrangement = Arrangement.spacedBy(20.dp), horizontalAlignment = Alignment.CenterHorizontally) {
                PageIndicator(pages.size, pager.currentPage)
                PrimaryButton("Get started", onFinished, Modifier.fillMaxWidth())
            }
        } else {
            Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                PageIndicator(pages.size, pager.currentPage, Modifier.weight(1f))
                PrimaryButton(
                    "Next",
                    onClick = { scope.launch { pager.animateScrollToPage(pager.currentPage + 1, animationSpec = tween(220, easing = EaseOutCubic)) } },
                    height = 52.dp,
                    trailingIcon = DotzIcons.ArrowRight,
                    horizontalPadding = 28.dp,
                )
            }
        }
    }
}

@Composable
private fun Dot(size: Dp, color: Color, modifier: Modifier = Modifier) {
    Box(
        modifier
            .size(size)
            .clip(CircleShape)
            .background(color),
    )
}

/** 9x8 grid of 20dp dots, Pip (happy) at index 39. */
@Composable
private fun YearArt() {
    Column(verticalArrangement = Arrangement.spacedBy(14.dp)) {
        for (r in 0 until 8) {
            Row(horizontalArrangement = Arrangement.spacedBy(14.dp)) {
                for (c in 0 until 9) {
                    val i = r * 9 + c
                    Box(Modifier.size(20.dp), contentAlignment = Alignment.Center) {
                        when {
                            i == 39 -> Pip(Modifier.requiredSize(36.dp), size = 36.dp, mood = PipMood.HAPPY)
                            i < 39 -> Dot(20.dp, DotPast)
                            else -> Dot(20.dp, DotFuture)
                        }
                    }
                }
            }
        }
    }
}

/** 3x4 grid of tiny month blocks; the current month holds Pip on today. */
@Composable
private fun MonthArt() {
    val now = Calendar.getInstance()
    val month = now.get(Calendar.MONTH)
    val today = now.get(Calendar.DAY_OF_MONTH)
    Column(verticalArrangement = Arrangement.spacedBy(22.dp)) {
        for (r in 0 until 4) {
            Row(horizontalArrangement = Arrangement.spacedBy(22.dp)) {
                for (c in 0 until 3) {
                    val m = r * 3 + c
                    val days = Calendar.getInstance().apply { set(Calendar.DAY_OF_MONTH, 1); set(Calendar.MONTH, m) }
                        .getActualMaximum(Calendar.DAY_OF_MONTH)
                    MonthBlock(days) { d ->
                        when {
                            m < month || (m == month && d < today) -> 0
                            m == month && d == today -> 1
                            else -> 2
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun MonthBlock(days: Int, kind: (Int) -> Int) {
    val dot = 7.dp
    Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
        for (row in 0 until 5) {
            Row(horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                for (col in 0 until 7) {
                    val d = row * 7 + col + 1
                    Box(Modifier.size(dot), contentAlignment = Alignment.Center) {
                        if (d <= days) {
                            when (kind(d)) {
                                0 -> Dot(dot, DotPast)
                                1 -> Pip(Modifier.requiredSize(16.dp), size = 16.dp)
                                else -> Dot(dot, DotFuture)
                            }
                        }
                    }
                }
            }
        }
    }
}

/** Past dots, Pip (curious), future dots, a target ring, and a status pill. */
@Composable
private fun GoalArt() {
    Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(28.dp)) {
        Row(horizontalArrangement = Arrangement.spacedBy(12.dp), verticalAlignment = Alignment.CenterVertically) {
            repeat(3) { Dot(18.dp, DotPast) }
            Pip(size = 48.dp, mood = PipMood.CURIOUS)
            repeat(3) { Dot(18.dp, DotFuture) }
            Box(
                Modifier
                    .size(34.dp)
                    .border(2.dp, DotFuture, CircleShape),
                contentAlignment = Alignment.Center,
            ) { Dot(12.dp, DotFuture) }
        }
        Text(
            buildAnnotatedString {
                withStyle(SpanStyle(color = TextPrimary, fontWeight = FontWeight.SemiBold)) { append("42 days") }
                append(" to Final exams")
            },
            style = DotzType.label.copy(color = TextSoft),
            modifier = Modifier
                .clip(CircleShape)
                .background(Surface)
                .border(1.dp, Rule, CircleShape)
                .padding(horizontal = 14.dp, vertical = 8.dp),
        )
    }
}

/** Pip sitting on the top edge (6dp overlap) of a 26x22 grid of 6dp dots. */
@Composable
private fun LifeArt() {
    val cols = 26
    val rows = 22
    val lived = (cols * rows * 0.34f).toInt()
    Box(contentAlignment = Alignment.TopCenter) {
        Column(
            Modifier
                .padding(top = 54.dp)
                .clip(RoundedCornerShape(20.dp))
                .background(Color(0xFF121214))
                .padding(18.dp),
            verticalArrangement = Arrangement.spacedBy(5.dp),
        ) {
            for (r in 0 until rows) {
                Row(horizontalArrangement = Arrangement.spacedBy(5.dp)) {
                    for (c in 0 until cols) {
                        Dot(6.dp, if (r * cols + c < lived) DotPast else DotFuture)
                    }
                }
            }
        }
        // Drawn after the grid so Pip sits in front of its top edge.
        Pip(size = 60.dp, mood = PipMood.HAPPY)
    }
}
