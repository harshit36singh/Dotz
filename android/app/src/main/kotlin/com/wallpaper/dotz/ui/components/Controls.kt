package com.wallpaper.dotz.ui.components

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.Slider
import androidx.compose.material3.SliderDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.role
import androidx.compose.ui.semantics.selected
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.stateDescription
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardCapitalization
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.wallpaper.dotz.ui.theme.DotPast
import com.wallpaper.dotz.ui.theme.DotzType
import com.wallpaper.dotz.ui.theme.Hint
import com.wallpaper.dotz.ui.theme.Ink
import com.wallpaper.dotz.ui.theme.Muted
import com.wallpaper.dotz.ui.theme.RadiusCard
import com.wallpaper.dotz.ui.theme.RadiusInput
import com.wallpaper.dotz.ui.theme.Rule
import com.wallpaper.dotz.ui.theme.Surface
import com.wallpaper.dotz.ui.theme.TextPrimary
import com.wallpaper.dotz.ui.theme.TextSoft


/** Flat surface card, radius 20. */
@Composable
fun DotzCard(
    modifier: Modifier = Modifier,
    padding: PaddingValues = PaddingValues(16.dp),
    content: @Composable ColumnScope.() -> Unit,
) {
    Column(
        modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(RadiusCard))
            .background(Surface)
            .padding(padding),
        content = content,
    )
}

/** Section label (13/500 muted, 4px inset) above its card, 10px gap. */
@Composable
fun Section(label: String, modifier: Modifier = Modifier, content: @Composable ColumnScope.() -> Unit) {
    Column(modifier.fillMaxWidth(), verticalArrangement = Arrangement.spacedBy(10.dp)) {
        Text(label, style = DotzType.label, modifier = Modifier.padding(horizontal = 4.dp))
        content()
    }
}

/** 1px rule between rows, inset 16 on each side. */
@Composable
fun RowDivider(inset: Dp = 16.dp) {
    Box(
        Modifier
            .padding(horizontal = inset)
            .fillMaxWidth()
            .height(1.dp)
            .background(Rule),
    )
}

@Composable
fun PrimaryButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
    loading: Boolean = false,
    height: Dp = 56.dp,
    trailingIcon: ImageVector? = null,
    horizontalPadding: Dp = 20.dp,
) {
    val bg by animateColorAsState(if (enabled) TextPrimary else Rule, label = "bg")
    val fg = if (enabled) Ink else Muted
    Row(
        modifier
            .heightIn(min = height)
            .clip(CircleShape)
            .background(bg)
            .clickable(enabled = enabled && !loading, role = Role.Button, onClick = onClick)
            .padding(horizontal = horizontalPadding),
        horizontalArrangement = Arrangement.spacedBy(8.dp, Alignment.CenterHorizontally),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        if (loading) {
            CircularProgressIndicator(Modifier.size(18.dp), color = Ink, strokeWidth = 2.dp)
        } else {
            Text(text, style = DotzType.button.copy(fontSize = if (height >= 56.dp) DotzType.bodyLarge.fontSize else DotzType.button.fontSize), color = fg)
            if (trailingIcon != null) Icon(trailingIcon, null, tint = fg, modifier = Modifier.size(18.dp))
        }
    }
}

@Composable
fun SecondaryButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    icon: ImageVector? = null,
    height: Dp = 52.dp,
) {
    Row(
        modifier
            .heightIn(min = height)
            .clip(CircleShape)
            .background(Surface)
            .clickable(role = Role.Button, onClick = onClick)
            .padding(horizontal = 20.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp, Alignment.CenterHorizontally),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        if (icon != null) Icon(icon, null, tint = TextPrimary, modifier = Modifier.size(18.dp))
        Text(text, style = DotzType.button.copy(fontWeight = FontWeight.Medium), color = TextPrimary)
    }
}

/** Round icon button (secondary style). */
@Composable
fun RoundIconButton(icon: ImageVector, contentDescription: String, onClick: () -> Unit, modifier: Modifier = Modifier, size: Dp = 52.dp) {
    Box(
        modifier
            .size(size)
            .clip(CircleShape)
            .background(Surface)
            .clickable(role = Role.Button, onClick = onClick)
            .semantics { this.contentDescription = contentDescription },
        contentAlignment = Alignment.Center,
    ) {
        Icon(icon, null, tint = TextPrimary, modifier = Modifier.size(20.dp))
    }
}

@Composable
fun TextAction(text: String, onClick: () -> Unit, modifier: Modifier = Modifier, color: Color = Muted) {
    Box(
        modifier
            .heightIn(min = 44.dp)
            .clip(RoundedCornerShape(12.dp))
            .clickable(role = Role.Button, onClick = onClick)
            .padding(horizontal = 12.dp),
        contentAlignment = Alignment.Center,
    ) {
        Text(text, style = DotzType.button.copy(fontWeight = FontWeight.Medium, fontSize = DotzType.label.fontSize.times(14f / 13f)), color = color)
    }
}

/** Card-style text field: 12px muted label over a 16/500 input, no underline. */
@Composable
fun FieldCard(
    label: String,
    value: String,
    onValueChange: (String) -> Unit,
    placeholder: String,
    modifier: Modifier = Modifier,
    background: Color = Surface,
    singleLine: Boolean = true,
    trailing: (@Composable () -> Unit)? = null,
) {
    Row(
        modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(RadiusInput))
            .background(background)
            .padding(horizontal = 16.dp, vertical = 14.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Column(Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(8.dp)) {
            Text(label, style = DotzType.fieldLabel)
            BasicTextField(
                value = value,
                onValueChange = onValueChange,
                singleLine = singleLine,
                textStyle = DotzType.fieldValue,
                cursorBrush = SolidColor(TextPrimary),
                keyboardOptions = KeyboardOptions(
                    capitalization = KeyboardCapitalization.Sentences,
                    imeAction = ImeAction.Done,
                ),
                modifier = Modifier
                    .fillMaxWidth()
                    .semantics { contentDescription = label },
                decorationBox = { inner ->
                    Box {
                        if (value.isEmpty()) Text(placeholder, style = DotzType.fieldValue, color = Hint)
                        inner()
                    }
                },
            )
        }
        trailing?.invoke()
    }
}

/** Same shell as [FieldCard] with a calendar icon; opens a date picker. */
@Composable
fun DateFieldCard(
    label: String,
    value: String?,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    placeholder: String = "Pick a date",
    background: Color = Surface,
) {
    Row(
        modifier
            .fillMaxWidth()
            .heightIn(min = 64.dp)
            .clip(RoundedCornerShape(RadiusInput))
            .background(background)
            .clickable(role = Role.Button, onClick = onClick)
            .padding(horizontal = 16.dp, vertical = 14.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Column(Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(6.dp)) {
            Text(label, style = DotzType.fieldLabel)
            Text(value ?: placeholder, style = DotzType.fieldValue, color = if (value == null) Hint else TextPrimary)
        }
        Icon(DotzIcons.Calendar, null, tint = Muted, modifier = Modifier.size(20.dp))
    }
}

/** Segmented toggle: ink track, selected segment off-white with ink text. */
@Composable
fun SegmentedToggle(
    options: List<String>,
    selectedIndex: Int,
    onSelect: (Int) -> Unit,
    modifier: Modifier = Modifier,
) {
    Row(
        modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(14.dp))
            .background(Ink)
            .padding(4.dp),
        horizontalArrangement = Arrangement.spacedBy(4.dp),
    ) {
        options.forEachIndexed { i, label ->
            val selected = i == selectedIndex
            val bg by animateColorAsState(if (selected) TextPrimary else Color.Transparent, label = "seg")
            Box(
                Modifier
                    .weight(1f)
                    .heightIn(min = 40.dp)
                    .clip(RoundedCornerShape(11.dp))
                    .background(bg)
                    .clickable(role = Role.Tab) { onSelect(i) }
                    .semantics { this.selected = selected },
                contentAlignment = Alignment.Center,
            ) {
                Text(
                    label,
                    style = DotzType.label.copy(fontWeight = if (selected) FontWeight.SemiBold else FontWeight.Medium),
                    color = if (selected) Ink else Muted,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                )
            }
        }
    }
}

/** 48x28 switch. Off: past track + soft thumb. On: text track + ink thumb. */
@Composable
fun DotzSwitch(checked: Boolean, onCheckedChange: (Boolean) -> Unit, contentDescription: String) {
    val track by animateColorAsState(if (checked) TextPrimary else DotPast, label = "track")
    val thumb by animateColorAsState(if (checked) Ink else TextSoft, label = "thumb")
    val x by animateDpAsState(if (checked) 20.dp else 0.dp, label = "x")
    Box(
        Modifier
            .size(48.dp, 28.dp)
            .clip(CircleShape)
            .background(track)
            .clickable(
                interactionSource = remember { MutableInteractionSource() },
                indication = null,
                role = Role.Switch,
            ) { onCheckedChange(!checked) }
            .semantics {
                this.contentDescription = contentDescription
                stateDescription = if (checked) "On" else "Off"
            }
            .padding(3.dp),
    ) {
        Box(
            Modifier
                .offset(x = x)
                .size(22.dp)
                .clip(CircleShape)
                .background(thumb),
        )
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DotzSlider(
    value: Float,
    onValueChange: (Float) -> Unit,
    valueRange: ClosedFloatingPointRange<Float>,
    modifier: Modifier = Modifier,
    steps: Int = 0,
    contentDescription: String,
) {
    Slider(
        value = value,
        onValueChange = onValueChange,
        valueRange = valueRange,
        steps = steps,
        modifier = modifier
            .fillMaxWidth()
            .semantics { this.contentDescription = contentDescription },
        colors = SliderDefaults.colors(
            thumbColor = TextPrimary,
            activeTrackColor = TextPrimary,
            inactiveTrackColor = Rule,
            activeTickColor = Color.Transparent,
            inactiveTickColor = Color.Transparent,
        ),
        thumb = {
            Box(
                Modifier
                    .size(20.dp)
                    .clip(CircleShape)
                    .background(TextPrimary),
            )
        },
        track = { state ->
            SliderDefaults.Track(
                sliderState = state,
                modifier = Modifier.height(4.dp),
                colors = SliderDefaults.colors(
                    activeTrackColor = TextPrimary,
                    inactiveTrackColor = Rule,
                    activeTickColor = Color.Transparent,
                    inactiveTickColor = Color.Transparent,
                ),
                thumbTrackGapSize = 0.dp,
                drawStopIndicator = null,
            )
        },
    )
}

/** 40px colour circle with its label under it. */
@Composable
fun Swatch(color: Color, label: String, onClick: () -> Unit, modifier: Modifier = Modifier, size: Dp = 40.dp) {
    Column(
        modifier
            .clip(RoundedCornerShape(12.dp))
            .clickable(role = Role.Button, onClick = onClick)
            .padding(vertical = 4.dp)
            .semantics { contentDescription = "$label colour" },
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        ColorDot(color, size)
        Text(label, style = DotzType.caption.copy(fontWeight = FontWeight.Medium), color = TextSoft)
    }
}

/** A colour circle; dark colours get a hairline so they don't vanish. */
@Composable
fun ColorDot(color: Color, size: Dp, modifier: Modifier = Modifier) {
    val dark = (0.299f * color.red + 0.587f * color.green + 0.114f * color.blue) < 0.18f
    Box(
        modifier
            .size(size)
            .clip(CircleShape)
            .background(color)
            .then(if (dark) Modifier.border(1.dp, DotPast, CircleShape) else Modifier),
    )
}

/** List row with a value and chevron (Settings › More). */
@Composable
fun ListRow(title: String, value: String, onClick: () -> Unit) {
    Row(
        Modifier
            .fillMaxWidth()
            .heightIn(min = 56.dp)
            .clickable(role = Role.Button, onClick = onClick)
            .padding(horizontal = 16.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text(title, style = DotzType.rowTitle, modifier = Modifier.weight(1f))
        Text(value, style = DotzType.label.copy(fontSize = DotzType.rowTitle.fontSize.times(14f / 15f)), color = Muted)
        Spacer(Modifier.width(6.dp))
        Icon(DotzIcons.Chevron, null, tint = Muted, modifier = Modifier.size(16.dp))
    }
}

/** Page dots: 6px past-colour dots, active is a 22x6 off-white pill. */
@Composable
fun PageIndicator(count: Int, current: Int, modifier: Modifier = Modifier) {
    Row(
        modifier.semantics { contentDescription = "Page ${current + 1} of $count" },
        horizontalArrangement = Arrangement.spacedBy(6.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        repeat(count) { i ->
            val active = i == current
            val w by animateDpAsState(if (active) 22.dp else 6.dp, label = "w")
            val c by animateColorAsState(if (active) TextPrimary else DotPast, label = "c")
            Box(
                Modifier
                    .size(w, 6.dp)
                    .clip(CircleShape)
                    .background(c),
            )
        }
    }
}

/** Pill chip holding Pip and a short status, e.g. "50 days left". */
@Composable
fun PipChip(text: String, modifier: Modifier = Modifier) {
    Row(
        modifier
            .clip(CircleShape)
            .background(Surface)
            .padding(start = 6.dp, end = 12.dp, top = 6.dp, bottom = 6.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Pip(size = 22.dp)
        Text(text, style = DotzType.chip)
    }
}

/** Screen header for pushed pages: back button + h1. */
@Composable
fun PageHeader(title: String, onBack: () -> Unit, modifier: Modifier = Modifier) {
    Row(modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
        Box(
            Modifier
                .offset(x = (-10).dp)
                .size(44.dp)
                .clip(CircleShape)
                .clickable(role = Role.Button, onClick = onBack)
                .semantics { contentDescription = "Back" },
            contentAlignment = Alignment.Center,
        ) {
            Icon(DotzIcons.ArrowLeft, null, tint = TextPrimary, modifier = Modifier.size(22.dp))
        }
        Text(title, style = DotzType.h1)
    }
}

/** A row inside a card: title (+ optional subtitle) left, [trailing] right. */
@Composable
fun SettingRow(
    title: String,
    modifier: Modifier = Modifier,
    subtitle: String? = null,
    trailing: @Composable RowScope.() -> Unit,
) {
    Row(
        modifier
            .fillMaxWidth()
            .heightIn(min = 56.dp)
            .padding(horizontal = 16.dp, vertical = 14.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Column(Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(3.dp)) {
            Text(title, style = DotzType.rowTitle)
            if (subtitle != null) Text(subtitle, style = DotzType.caption)
        }
        trailing()
    }
}
