package com.wallpaper.dotz.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Typography
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.em
import androidx.compose.ui.unit.sp
import com.wallpaper.dotz.R

// ── Surfaces ─────────────────────────────────────────────────────────
val Ink = Color(0xFF0C0C0D)      // page background
val Surface = Color(0xFF161618)  // cards, nav, inputs, secondary buttons
val Rule = Color(0xFF26262A)     // dividers, 1px borders, disabled button bg
val Tile = Color(0xFF141416)     // icon tile / phone preview frame
val Ring = Color(0xFF2A2A2E)     // phone preview hairline

// ── Text ─────────────────────────────────────────────────────────────
val TextPrimary = Color(0xFFF2EEE8) // primary text, primary button bg
val TextSoft = Color(0xFFB9B4AD)    // body copy
val Muted = Color(0xFF8E8A85)       // labels, inactive icons
val Hint = Color(0xFF6E6A66)        // placeholders

// ── Brand: orange is ONLY for Pip and today's dot ────────────────────
val PipOrange = Color(0xFFFF5A1F)
val PipEye = Color(0xFF1A0E08)

// ── Wallpaper defaults ───────────────────────────────────────────────
val DotPast = Color(0xFF3A3836)
val DotToday = PipOrange
val DotFuture = Color(0xFFEDE8E0)
val DotBg = Color(0xFF0D0C0A)

// ── Shape ────────────────────────────────────────────────────────────
val RadiusCard = 20.dp
val RadiusInput = 18.dp
val ScreenPad = 24.dp

/** Swatches offered in the colour sheet: Pip first, then the classic set. */
val Swatches = listOf(
    PipOrange,
    Color(0xFFFAF8F4), Color(0xFF1C1814), Color(0xFFF5F0E8),
    Color(0xFFCC2200), Color(0xFF0D0C0A), Color(0xFF252220),
    Color(0xFF9B8FFF), Color(0xFF00D470), Color(0xFFFFCC44),
    Color(0xFF38B6FF), Color(0xFFFF88CC), Color(0xFFFFD700),
    Color(0xFF282420), Color(0xFFE8D5C4), Color(0xFF8B7355),
    Color(0xFFFF6B35), Color(0xFFA0A09A), Color(0xFFC8B89A),
    DotPast, DotFuture, Color(0xFF3A3836),
).distinct()

// ── Type ─────────────────────────────────────────────────────────────
val SpaceGrotesk = FontFamily(
    Font(R.font.space_grotesk_light, FontWeight.Light),
    Font(R.font.space_grotesk_medium, FontWeight.Medium),
    Font(R.font.space_grotesk_semibold, FontWeight.SemiBold),
)

val Inter = FontFamily(
    Font(R.font.inter_regular, FontWeight.Normal),
    Font(R.font.inter_medium, FontWeight.Medium),
    Font(R.font.inter_semibold, FontWeight.SemiBold),
)

object DotzType {
    val h1 = TextStyle(fontFamily = SpaceGrotesk, fontWeight = FontWeight.SemiBold, fontSize = 28.sp, letterSpacing = (-0.5).sp, color = TextPrimary)
    val onboardingTitle = TextStyle(fontFamily = SpaceGrotesk, fontWeight = FontWeight.SemiBold, fontSize = 36.sp, lineHeight = 1.05.em, letterSpacing = (-1).sp, color = TextPrimary)
    val appliedTitle = TextStyle(fontFamily = SpaceGrotesk, fontWeight = FontWeight.SemiBold, fontSize = 32.sp, letterSpacing = (-0.8).sp, color = TextPrimary)
    val emptyTitle = TextStyle(fontFamily = SpaceGrotesk, fontWeight = FontWeight.SemiBold, fontSize = 22.sp, letterSpacing = (-0.3).sp, color = TextPrimary)
    val bigNumber = TextStyle(fontFamily = SpaceGrotesk, fontWeight = FontWeight.SemiBold, fontSize = 22.sp, color = TextPrimary)
    val clock = TextStyle(fontFamily = SpaceGrotesk, fontWeight = FontWeight.Light, fontSize = 54.sp, letterSpacing = (-1).sp, lineHeight = 1.em, color = TextPrimary)
    val wordmark = TextStyle(fontFamily = SpaceGrotesk, fontWeight = FontWeight.SemiBold, fontSize = 30.sp, letterSpacing = (-0.5).sp, color = TextPrimary)

    val body = TextStyle(fontFamily = Inter, fontWeight = FontWeight.Normal, fontSize = 15.sp, lineHeight = 1.5.em, color = TextSoft)
    val bodyLarge = body.copy(fontSize = 16.sp)
    val rowTitle = TextStyle(fontFamily = Inter, fontWeight = FontWeight.Medium, fontSize = 15.sp, color = TextPrimary)
    val label = TextStyle(fontFamily = Inter, fontWeight = FontWeight.Medium, fontSize = 13.sp, color = Muted)
    val fieldLabel = TextStyle(fontFamily = Inter, fontWeight = FontWeight.Medium, fontSize = 12.sp, color = Muted)
    val fieldValue = TextStyle(fontFamily = Inter, fontWeight = FontWeight.Medium, fontSize = 16.sp, color = TextPrimary)
    val caption = TextStyle(fontFamily = Inter, fontWeight = FontWeight.Normal, fontSize = 12.sp, color = Muted)
    val button = TextStyle(fontFamily = Inter, fontWeight = FontWeight.SemiBold, fontSize = 15.sp)
    val chip = TextStyle(fontFamily = Inter, fontWeight = FontWeight.Medium, fontSize = 13.sp, color = TextPrimary)
}

private val colorScheme = darkColorScheme(
    primary = TextPrimary,
    onPrimary = Ink,
    secondary = TextSoft,
    onSecondary = Ink,
    background = Ink,
    onBackground = TextPrimary,
    surface = Surface,
    onSurface = TextPrimary,
    surfaceVariant = Surface,
    onSurfaceVariant = Muted,
    surfaceContainer = Surface,
    surfaceContainerHigh = Surface,
    surfaceContainerHighest = Rule,
    surfaceContainerLow = Surface,
    outline = Rule,
    outlineVariant = Rule,
    inverseSurface = TextPrimary,
    inverseOnSurface = Ink,
)

private val typography = Typography().let { base ->
    fun TextStyle.inter() = copy(fontFamily = Inter)
    Typography(
        displayLarge = base.displayLarge.copy(fontFamily = SpaceGrotesk),
        displayMedium = base.displayMedium.copy(fontFamily = SpaceGrotesk),
        displaySmall = base.displaySmall.copy(fontFamily = SpaceGrotesk),
        headlineLarge = base.headlineLarge.copy(fontFamily = SpaceGrotesk),
        headlineMedium = base.headlineMedium.copy(fontFamily = SpaceGrotesk),
        headlineSmall = base.headlineSmall.copy(fontFamily = SpaceGrotesk),
        titleLarge = base.titleLarge.inter(),
        titleMedium = base.titleMedium.inter(),
        titleSmall = base.titleSmall.inter(),
        bodyLarge = base.bodyLarge.inter(),
        bodyMedium = base.bodyMedium.inter(),
        bodySmall = base.bodySmall.inter(),
        labelLarge = base.labelLarge.inter(),
        labelMedium = base.labelMedium.inter(),
        labelSmall = base.labelSmall.inter(),
    )
}

@Composable
fun DotzTheme(content: @Composable () -> Unit) {
    MaterialTheme(colorScheme = colorScheme, typography = typography, content = content)
}
