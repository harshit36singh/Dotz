package com.wallpaper.dotz.ui.screens

import androidx.compose.animation.animateContentSize
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.platform.LocalUriHandler
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.selected
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.withStyle
import androidx.compose.ui.unit.dp
import com.wallpaper.dotz.DotzSettings
import com.wallpaper.dotz.DotzViewModel
import com.wallpaper.dotz.QuoteStatus
import com.wallpaper.dotz.data.DotShape
import com.wallpaper.dotz.data.DotzState
import com.wallpaper.dotz.data.LabelMode
import com.wallpaper.dotz.ui.components.ColorDot
import com.wallpaper.dotz.ui.components.ColorPickerSheet
import com.wallpaper.dotz.ui.components.DotzCard
import com.wallpaper.dotz.ui.components.DotzSlider
import com.wallpaper.dotz.ui.components.DotzSwitch
import com.wallpaper.dotz.ui.components.FieldCard
import com.wallpaper.dotz.ui.components.ListRow
import com.wallpaper.dotz.ui.components.Pip
import com.wallpaper.dotz.ui.components.PipMood
import com.wallpaper.dotz.ui.components.RowDivider
import com.wallpaper.dotz.ui.components.Section
import com.wallpaper.dotz.ui.components.SegmentedToggle
import com.wallpaper.dotz.ui.components.SettingRow
import com.wallpaper.dotz.ui.components.Swatch
import com.wallpaper.dotz.ui.components.TextAction
import com.wallpaper.dotz.ui.theme.DotzType
import com.wallpaper.dotz.ui.theme.Ink
import com.wallpaper.dotz.ui.theme.Surface
import com.wallpaper.dotz.ui.theme.TextPrimary
import com.wallpaper.dotz.ui.theme.TextSoft

/** Which colour the sheet is editing. */
private enum class ColorTarget(val label: String) {
    PAST("Past"), TODAY("Today"), FUTURE("Future"), BACKGROUND("Background"), LABEL("Label")
}

@Composable
fun LookScreen(
    vm: DotzViewModel,
    state: DotzState,
    quoteStatus: QuoteStatus,
    onOpenBackground: () -> Unit,
    onOpenMarkedDates: () -> Unit,
) {
    var sheet by remember { mutableStateOf<ColorTarget?>(null) }

    Column(
        Modifier
            .fillMaxSize()
            .statusBarsPadding()
            .imePadding()
            .verticalScroll(rememberScrollState())
            .padding(start = 20.dp, end = 20.dp, top = 20.dp, bottom = 120.dp),
        verticalArrangement = Arrangement.spacedBy(24.dp),
    ) {
        Text("Look", style = DotzType.h1, modifier = Modifier.padding(horizontal = 4.dp))

        // 1. Dot colours
        Section("Dot colours") {
            DotzCard {
                Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceAround) {
                    Swatch(Color(state.pastColor), "Past", { sheet = ColorTarget.PAST }, Modifier.weight(1f))
                    Swatch(Color(state.todayColor), "Today", { sheet = ColorTarget.TODAY }, Modifier.weight(1f))
                    Swatch(Color(state.futureColor), "Future", { sheet = ColorTarget.FUTURE }, Modifier.weight(1f))
                    Swatch(Color(state.bgColor), "Background", { sheet = ColorTarget.BACKGROUND }, Modifier.weight(1f))
                }
            }
        }

        // 2. Today's dot
        Section("Today’s dot") {
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                ChoiceTile(
                    label = "Plain",
                    selected = state.todayStyle == DotzSettings.TODAY_STYLE_PLAIN,
                    onClick = { vm.setTodayStyle(DotzSettings.TODAY_STYLE_PLAIN) },
                    modifier = Modifier.weight(1f),
                ) { ColorDot(Color(state.todayColor), 28.dp) }
                ChoiceTile(
                    label = "Pip",
                    selected = state.todayStyle == DotzSettings.TODAY_STYLE_PIP,
                    onClick = { vm.setTodayStyle(DotzSettings.TODAY_STYLE_PIP) },
                    modifier = Modifier.weight(1f),
                ) { Pip(size = 28.dp, color = Color(state.todayColor)) }
            }
        }

        // 3. Shape
        Section("Shape") {
            Row(
                Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(20.dp))
                    .background(Surface)
                    .padding(8.dp),
                horizontalArrangement = Arrangement.spacedBy(6.dp),
            ) {
                listOf(DotShape.CIRCLE, DotShape.SQUARE, DotShape.DIAMOND, DotShape.HEXAGON, DotShape.STAR, DotShape.GLASS)
                    .forEach { shape -> ShapeChip(shape, state.dotShape == shape, { vm.setShape(shape) }, Modifier.weight(1f)) }
            }
        }

        // 4. Grid
        Section("Grid") {
            DotzCard(padding = PaddingValues(0.dp)) {
                Column(Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                    Row(verticalAlignment = Alignment.Bottom) {
                        Text("Columns", style = DotzType.rowTitle, modifier = Modifier.weight(1f))
                        Text("${state.columns}", style = DotzType.bigNumber)
                    }
                    DotzSlider(
                        value = state.columns.toFloat(),
                        onValueChange = { vm.setColumns(it.toInt()) },
                        valueRange = 7f..30f,
                        steps = 22,
                        contentDescription = "Columns",
                    )
                }
                RowDivider()
                SettingRow("Date numbers", subtitle = "Show the day inside each dot") {
                    DotzSwitch(state.showDateNumbers, vm::setShowDateNumbers, "Date numbers")
                }
            }
        }

        // 5. Label
        Section("Label") {
            DotzCard(padding = PaddingValues(start = 8.dp, end = 8.dp, top = 8.dp, bottom = 16.dp), modifier = Modifier.animateContentSize()) {
                SegmentedToggle(
                    options = listOf("Off", "Progress", "Quote", "Custom"),
                    selectedIndex = state.labelMode.ordinal,
                    onSelect = { vm.setLabelMode(LabelMode.entries[it]) },
                )
                LabelDetails(vm, state, quoteStatus, onPickColor = { sheet = ColorTarget.LABEL })
            }
        }

        // 6. More
        Section("More") {
            DotzCard(padding = PaddingValues(0.dp)) {
                ListRow("Background image", if (state.bgImagePath.isEmpty()) "None" else "Custom", onOpenBackground)
                RowDivider()
                ListRow("Marked dates", state.markedDates.size.toString(), onOpenMarkedDates)
                RowDivider()
                // Google Play requires the privacy policy to be reachable in-app.
                val uriHandler = LocalUriHandler.current
                ListRow("Privacy policy", "") { uriHandler.openUri(PRIVACY_POLICY_URL) }
            }
        }
    }

    sheet?.let { target ->
        val current = when (target) {
            ColorTarget.PAST -> state.pastColor
            ColorTarget.TODAY -> state.todayColor
            ColorTarget.FUTURE -> state.futureColor
            ColorTarget.BACKGROUND -> state.bgColor
            ColorTarget.LABEL -> state.labelColor
        }
        ColorPickerSheet(
            title = "Pick a colour for ${target.label}",
            selected = current,
            onPick = { c ->
                when (target) {
                    ColorTarget.PAST -> vm.setPastColor(c)
                    ColorTarget.TODAY -> vm.setTodayColor(c)
                    ColorTarget.FUTURE -> vm.setFutureColor(c)
                    ColorTarget.BACKGROUND -> vm.setBgColor(c)
                    ColorTarget.LABEL -> vm.setLabelColor(c)
                }
            },
            onDismiss = { sheet = null },
        )
    }
}

private const val PRIVACY_POLICY_URL = "https://github.com/harshit36singh/Dotz/blob/main/PRIVACY.md"

@Composable
private fun LabelDetails(vm: DotzViewModel, state: DotzState, quoteStatus: QuoteStatus, onPickColor: () -> Unit) {
    if (state.labelMode == LabelMode.OFF) {
        Text(
            "No label will appear on the wallpaper.",
            style = DotzType.label.copy(color = TextSoft),
            modifier = Modifier.padding(start = 8.dp, end = 8.dp, top = 14.dp),
        )
        return
    }

    Column(Modifier.padding(top = 14.dp), verticalArrangement = Arrangement.spacedBy(14.dp)) {
        when (state.labelMode) {
            LabelMode.QUOTE -> QuoteBlock(vm, state, quoteStatus)
            LabelMode.CUSTOM -> FieldCard(
                label = "Your text",
                value = state.customLabel,
                onValueChange = vm::setCustomLabel,
                placeholder = "e.g. Make every dot count",
                background = Ink,
            )
            else -> Unit
        }

        Text(
            buildAnnotatedString {
                append("Preview: ")
                withStyle(SpanStyle(color = TextPrimary)) { append(state.resolvedLabel()) }
            },
            style = DotzType.label.copy(color = TextSoft),
            modifier = Modifier.padding(horizontal = 8.dp),
            maxLines = 3,
        )

        // Label appearance
        Column(
            Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(14.dp))
                .background(Ink),
        ) {
            Row(
                Modifier
                    .fillMaxWidth()
                    .heightIn(min = 52.dp)
                    .clickable(role = Role.Button, onClick = onPickColor)
                    .padding(horizontal = 14.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Text("Label colour", style = DotzType.rowTitle, modifier = Modifier.weight(1f))
                ColorDot(Color(state.labelColor), 24.dp)
            }
            RowDivider(inset = 14.dp)
            Column(Modifier.padding(14.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text("Label size", style = DotzType.rowTitle, modifier = Modifier.weight(1f))
                    Text(
                        if (state.labelFontSize <= 0f) "Auto" else "${state.labelFontSize.toInt()} sp",
                        style = DotzType.label,
                    )
                }
                // The left end of the track is "Auto"; 8–32 sp beyond it.
                DotzSlider(
                    value = if (state.labelFontSize <= 0f) 7f else state.labelFontSize,
                    onValueChange = { v -> vm.setLabelFontSize(if (v < 7.5f) 0f else v.toInt().toFloat()) },
                    valueRange = 7f..32f,
                    steps = 24,
                    contentDescription = "Label size",
                )
            }
        }
    }
}

@Composable
private fun QuoteBlock(vm: DotzViewModel, state: DotzState, status: QuoteStatus) {
    Column(
        Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(14.dp))
            .background(Ink)
            .padding(14.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        when {
            status == QuoteStatus.LOADING -> Text("Fetching a quote…", style = DotzType.body)
            status == QuoteStatus.ERROR && state.quoteText.isBlank() -> Row(verticalAlignment = Alignment.CenterVertically) {
                Pip(size = 28.dp, mood = PipMood.SLEEPY)
                Text(
                    "Couldn’t load a quote. Check your connection.",
                    style = DotzType.body,
                    modifier = Modifier.padding(start = 10.dp),
                )
            }
            state.quoteText.isNotBlank() -> {
                Text("“${state.quoteText}”", style = DotzType.body.copy(color = TextPrimary))
                if (state.quoteAuthor.isNotBlank()) Text("— ${state.quoteAuthor}", style = DotzType.label)
            }
        }
        Row(verticalAlignment = Alignment.CenterVertically) {
            // zenquotes' free tier asks for a visible, linked attribution.
            val uriHandler = LocalUriHandler.current
            Text(
                "Quotes by zenquotes.io",
                style = DotzType.caption.copy(textDecoration = TextDecoration.Underline),
                modifier = Modifier
                    .weight(1f)
                    .clickable(role = Role.Button) { uriHandler.openUri("https://zenquotes.io/") },
            )
            if (status == QuoteStatus.ERROR) {
                TextAction("Try again", { vm.fetchQuote() }, color = TextPrimary)
            } else {
                TextAction("New quote", { vm.fetchQuote(random = true) }, color = TextPrimary)
            }
        }
    }
}

@Composable
private fun ChoiceTile(
    label: String,
    selected: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    icon: @Composable () -> Unit,
) {
    val shape = RoundedCornerShape(20.dp)
    Column(
        modifier
            .heightIn(min = 92.dp)
            .clip(shape)
            .background(Surface)
            .then(if (selected) Modifier.border(2.dp, TextPrimary, shape) else Modifier)
            .clickable(role = Role.RadioButton, onClick = onClick)
            .semantics { this.selected = selected },
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(10.dp, Alignment.CenterVertically),
    ) {
        icon()
        Text(
            label,
            style = DotzType.label.copy(fontWeight = if (selected) FontWeight.SemiBold else FontWeight.Medium),
            color = if (selected) TextPrimary else TextSoft,
        )
    }
}

@Composable
private fun ShapeChip(shape: DotShape, selected: Boolean, onClick: () -> Unit, modifier: Modifier = Modifier) {
    val glyph = if (selected) Ink else TextSoft
    val name = when (shape) {
        DotShape.GLASS -> "Ring"
        else -> shape.name.lowercase().replaceFirstChar { it.uppercase() }
    }
    Box(
        modifier
            .height(48.dp)
            .clip(RoundedCornerShape(14.dp))
            .background(if (selected) TextPrimary else Color.Transparent)
            .clickable(role = Role.RadioButton, onClick = onClick)
            .semantics {
                contentDescription = name
                this.selected = selected
            },
        contentAlignment = Alignment.Center,
    ) {
        when (shape) {
            DotShape.CIRCLE -> Box(Modifier.size(16.dp).clip(CircleShape).background(glyph))
            DotShape.SQUARE -> Box(Modifier.size(15.dp).clip(RoundedCornerShape(3.dp)).background(glyph))
            DotShape.DIAMOND -> Box(Modifier.size(12.dp).rotate(45f).clip(RoundedCornerShape(2.dp)).background(glyph))
            DotShape.GLASS -> Box(Modifier.size(13.dp).border(2.5.dp, glyph, CircleShape))
            DotShape.HEXAGON -> Canvas(Modifier.size(18.dp)) {
                val u = size.minDimension / 24f
                val p = Path().apply {
                    moveTo(12f * u, 3f * u); lineTo(19.8f * u, 7.5f * u); lineTo(19.8f * u, 16.5f * u)
                    lineTo(12f * u, 21f * u); lineTo(4.2f * u, 16.5f * u); lineTo(4.2f * u, 7.5f * u); close()
                }
                drawPath(p, glyph)
            }
            DotShape.STAR -> Canvas(Modifier.size(18.dp)) {
                val u = size.minDimension / 24f
                val pts = listOf(
                    12f to 3f, 14.6f to 8.9f, 21f to 9.5f, 16.2f to 13.8f, 17.6f to 20.1f,
                    12f to 16.9f, 6.4f to 20.1f, 7.8f to 13.8f, 3f to 9.5f, 9.4f to 8.9f,
                )
                val p = Path().apply {
                    pts.forEachIndexed { i, (x, y) -> if (i == 0) moveTo(x * u, y * u) else lineTo(x * u, y * u) }
                    close()
                }
                drawPath(p, glyph)
            }
        }
    }
}
