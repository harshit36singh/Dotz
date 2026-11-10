package com.wallpaper.dotz.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.safeDrawingPadding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import com.wallpaper.dotz.DotzViewModel
import com.wallpaper.dotz.data.DotzState
import com.wallpaper.dotz.data.MarkedDate
import com.wallpaper.dotz.ui.components.ColorDot
import com.wallpaper.dotz.ui.components.ColorPickerSheet
import com.wallpaper.dotz.ui.components.DateFieldCard
import com.wallpaper.dotz.ui.components.DotzCard
import com.wallpaper.dotz.ui.components.DotzDatePickerDialog
import com.wallpaper.dotz.ui.components.DotzIcons
import com.wallpaper.dotz.ui.components.FieldCard
import com.wallpaper.dotz.ui.components.PageHeader
import com.wallpaper.dotz.ui.components.PrimaryButton
import com.wallpaper.dotz.ui.components.RowDivider
import com.wallpaper.dotz.ui.components.Section
import com.wallpaper.dotz.ui.theme.DotzType
import com.wallpaper.dotz.ui.theme.Ink
import com.wallpaper.dotz.ui.theme.Muted
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Locale

private fun monthDay(month: Int, day: Int): String {
    val c = Calendar.getInstance().apply { set(2000, month - 1, day) }
    return SimpleDateFormat("d MMM", Locale.getDefault()).format(c.time)
}

@Composable
fun MarkedDatesScreen(vm: DotzViewModel, state: DotzState, onBack: () -> Unit) {
    var name by rememberSaveable { mutableStateOf("") }
    var date by rememberSaveable { mutableStateOf<Long?>(null) }
    var picking by remember { mutableStateOf(false) }
    var colorSheet by remember { mutableStateOf(false) }

    Column(
        Modifier
            .fillMaxSize()
            .background(Ink)
            .safeDrawingPadding()
            .imePadding()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = 20.dp, vertical = 20.dp),
        verticalArrangement = Arrangement.spacedBy(24.dp),
    ) {
        PageHeader("Marked dates", onBack, Modifier.padding(horizontal = 4.dp))
        Text(
            "Highlight birthdays and anniversaries in Year and Month mode. They repeat every year.",
            style = DotzType.body,
            modifier = Modifier.padding(horizontal = 4.dp),
        )

        if (state.markedDates.isNotEmpty()) {
            Section("Your dates") {
                DotzCard(padding = PaddingValues(0.dp)) {
                    state.markedDates.sortedWith(compareBy({ it.month }, { it.day })).forEachIndexed { i, d ->
                        if (i > 0) RowDivider()
                        Row(
                            Modifier
                                .fillMaxWidth()
                                .heightIn(min = 56.dp)
                                .padding(start = 16.dp, end = 4.dp),
                            verticalAlignment = Alignment.CenterVertically,
                        ) {
                            ColorDot(Color(state.milestoneColor), 10.dp)
                            Text(d.label.ifBlank { "Marked date" }, style = DotzType.rowTitle, modifier = Modifier.weight(1f).padding(start = 12.dp))
                            Text(monthDay(d.month, d.day), style = DotzType.label)
                            Box(
                                Modifier
                                    .size(44.dp)
                                    .clip(CircleShape)
                                    .clickable(role = Role.Button) { vm.removeMarkedDate(d) }
                                    .semantics { contentDescription = "Remove ${d.label}" },
                                contentAlignment = Alignment.Center,
                            ) {
                                Icon(DotzIcons.Close, null, tint = Muted, modifier = Modifier.size(18.dp))
                            }
                        }
                    }
                }
            }
        }

        Section("Add a date") {
            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                FieldCard("Name", name, { name = it }, placeholder = "e.g. Mom’s birthday")
                DateFieldCard("Date", date?.let { val c = Calendar.getInstance().apply { timeInMillis = it }; monthDay(c.get(Calendar.MONTH) + 1, c.get(Calendar.DAY_OF_MONTH)) }, { picking = true })
                PrimaryButton(
                    "Add date",
                    onClick = {
                        val c = Calendar.getInstance().apply { timeInMillis = date ?: return@PrimaryButton }
                        vm.addMarkedDate(MarkedDate(c.get(Calendar.MONTH) + 1, c.get(Calendar.DAY_OF_MONTH), name.trim()))
                        name = ""; date = null
                    },
                    enabled = date != null && name.isNotBlank(),
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(top = 4.dp),
                )
            }
        }

        Section("Colour") {
            DotzCard(padding = PaddingValues(0.dp)) {
                Row(
                    Modifier
                        .fillMaxWidth()
                        .heightIn(min = 56.dp)
                        .clickable(role = Role.Button) { colorSheet = true }
                        .padding(horizontal = 16.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Text("Marked date colour", style = DotzType.rowTitle, modifier = Modifier.weight(1f))
                    ColorDot(Color(state.milestoneColor), 24.dp)
                }
            }
        }
    }

    if (picking) {
        DotzDatePickerDialog(initial = date, onConfirm = { date = it; picking = false }, onDismiss = { picking = false })
    }
    if (colorSheet) {
        ColorPickerSheet("Pick a colour for marked dates", state.milestoneColor, vm::setMilestoneColor) { colorSheet = false }
    }
}
