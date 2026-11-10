package com.wallpaper.dotz.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.DatePicker
import androidx.compose.material3.DatePickerDefaults
import androidx.compose.material3.DatePickerDialog
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.SelectableDates
import androidx.compose.material3.Snackbar
import androidx.compose.material3.Text
import androidx.compose.material3.rememberDatePickerState
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.selected
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import com.wallpaper.dotz.ui.theme.DotzType
import com.wallpaper.dotz.ui.theme.Ink
import com.wallpaper.dotz.ui.theme.Muted
import com.wallpaper.dotz.ui.theme.PipOrange
import com.wallpaper.dotz.ui.theme.Rule
import com.wallpaper.dotz.ui.theme.Surface
import com.wallpaper.dotz.ui.theme.Swatches
import com.wallpaper.dotz.ui.theme.TextPrimary
import com.wallpaper.dotz.ui.theme.TextSoft
import java.util.Calendar
import java.util.TimeZone

// ── Colour picker sheet ─────────────────────────────────────────────
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ColorPickerSheet(
    title: String,
    selected: Int,
    onPick: (Int) -> Unit,
    onDismiss: () -> Unit,
) {
    val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)
    ModalBottomSheet(
        onDismissRequest = onDismiss,
        sheetState = sheetState,
        containerColor = Surface,
        shape = RoundedCornerShape(topStart = 24.dp, topEnd = 24.dp),
        dragHandle = {
            Box(
                Modifier
                    .padding(top = 12.dp, bottom = 8.dp)
                    .size(36.dp, 4.dp)
                    .clip(CircleShape)
                    .background(Rule),
            )
        },
    ) {
        Column(
            Modifier
                .fillMaxWidth()
                .padding(horizontal = 24.dp)
                .padding(bottom = 24.dp)
                .navigationBarsPadding(),
            verticalArrangement = Arrangement.spacedBy(20.dp),
        ) {
            Text(title, style = DotzType.emptyTitle.copy(fontSize = DotzType.emptyTitle.fontSize.times(0.82f)))
            Swatches.chunked(6).forEach { row ->
                Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                    row.forEach { c ->
                        val isSelected = c.toArgb() == selected
                        Box(
                            Modifier
                                .size(52.dp)
                                .clip(CircleShape)
                                .then(if (isSelected) Modifier.border(2.dp, TextPrimary, CircleShape) else Modifier)
                                .clickable(role = Role.Button) { onPick(c.toArgb()); onDismiss() }
                                .semantics {
                                    contentDescription = "Colour #%06X".format(c.toArgb() and 0xFFFFFF)
                                    this.selected = isSelected
                                },
                            contentAlignment = Alignment.Center,
                        ) {
                            ColorDot(c, 44.dp)
                        }
                    }
                    repeat(6 - row.size) { Spacer(Modifier.size(52.dp)) }
                }
            }
        }
    }
}

// ── Date picker dialog ──────────────────────────────────────────────
/**
 * Flat dark date picker. [initial] and the result are local-midnight millis
 * (Material's picker works in UTC; converted both ways here).
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DotzDatePickerDialog(
    initial: Long?,
    onConfirm: (Long) -> Unit,
    onDismiss: () -> Unit,
    minDate: Long? = null,
    maxDate: Long? = null,
) {
    val minUtc = minDate?.let(::localToUtc)
    val maxUtc = maxDate?.let(::localToUtc)
    val state = rememberDatePickerState(
        initialSelectedDateMillis = (initial ?: System.currentTimeMillis()).let(::localToUtc),
        selectableDates = object : SelectableDates {
            override fun isSelectableDate(utcTimeMillis: Long): Boolean =
                (minUtc == null || utcTimeMillis >= minUtc) && (maxUtc == null || utcTimeMillis <= maxUtc)
        },
    )
    val colors = DatePickerDefaults.colors(
        containerColor = Surface,
        titleContentColor = Muted,
        headlineContentColor = TextPrimary,
        weekdayContentColor = Muted,
        subheadContentColor = Muted,
        navigationContentColor = TextPrimary,
        yearContentColor = TextSoft,
        currentYearContentColor = PipOrange,
        selectedYearContentColor = Ink,
        selectedYearContainerColor = TextPrimary,
        dayContentColor = TextPrimary,
        disabledDayContentColor = Rule,
        selectedDayContentColor = Ink,
        selectedDayContainerColor = TextPrimary,
        todayContentColor = PipOrange,
        todayDateBorderColor = PipOrange,
        dividerColor = Rule,
    )
    DatePickerDialog(
        onDismissRequest = onDismiss,
        shape = RoundedCornerShape(24.dp),
        colors = colors,
        confirmButton = {
            PrimaryButton(
                "Confirm",
                onClick = { state.selectedDateMillis?.let { onConfirm(utcToLocal(it)) } },
                enabled = state.selectedDateMillis != null,
                height = 44.dp,
                modifier = Modifier.padding(end = 8.dp, bottom = 8.dp),
            )
        },
        dismissButton = { TextAction("Cancel", onDismiss, Modifier.padding(bottom = 8.dp)) },
    ) {
        DatePicker(state = state, colors = colors, showModeToggle = false)
    }
}

private fun localToUtc(local: Long): Long {
    val l = Calendar.getInstance().apply { timeInMillis = local }
    return Calendar.getInstance(TimeZone.getTimeZone("UTC")).apply {
        clear()
        set(l.get(Calendar.YEAR), l.get(Calendar.MONTH), l.get(Calendar.DAY_OF_MONTH))
    }.timeInMillis
}

private fun utcToLocal(utc: Long): Long {
    val u = Calendar.getInstance(TimeZone.getTimeZone("UTC")).apply { timeInMillis = utc }
    return Calendar.getInstance().apply {
        clear()
        set(u.get(Calendar.YEAR), u.get(Calendar.MONTH), u.get(Calendar.DAY_OF_MONTH))
    }.timeInMillis
}

// ── Error snackbar ──────────────────────────────────────────────────
@Composable
fun PipSnackbar(message: String) {
    Snackbar(
        modifier = Modifier.padding(horizontal = 24.dp),
        containerColor = Surface,
        contentColor = TextPrimary,
        shape = RoundedCornerShape(18.dp),
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Pip(size = 20.dp, mood = PipMood.SLEEPY)
            Spacer(Modifier.width(10.dp))
            Text(message, style = DotzType.chip.copy(fontSize = DotzType.rowTitle.fontSize.times(14f / 15f)))
        }
    }
}
