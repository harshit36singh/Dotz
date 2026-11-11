package com.wallpaper.dotz.ui.screens

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.expandVertically
import androidx.compose.animation.shrinkVertically
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.rememberScrollState
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
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.wallpaper.dotz.DotGridRenderer
import com.wallpaper.dotz.DotzSettings
import com.wallpaper.dotz.DotzViewModel
import com.wallpaper.dotz.QuoteStatus
import com.wallpaper.dotz.data.DotzState
import com.wallpaper.dotz.data.LifeUnit
import com.wallpaper.dotz.data.todayMidnight
import com.wallpaper.dotz.ui.PhonePreview
import com.wallpaper.dotz.ui.components.DateFieldCard
import com.wallpaper.dotz.ui.components.DotzCard
import com.wallpaper.dotz.ui.components.DotzIcons
import com.wallpaper.dotz.ui.components.DotzSlider
import com.wallpaper.dotz.ui.components.DotzDatePickerDialog
import com.wallpaper.dotz.ui.components.FieldCard
import com.wallpaper.dotz.ui.components.FloatingNavBar
import com.wallpaper.dotz.ui.components.HomeTab
import com.wallpaper.dotz.ui.components.Pip
import com.wallpaper.dotz.ui.components.PipChip
import com.wallpaper.dotz.ui.components.PipMood
import com.wallpaper.dotz.ui.components.PrimaryButton
import com.wallpaper.dotz.ui.components.RowDivider
import com.wallpaper.dotz.ui.components.SecondaryButton
import com.wallpaper.dotz.ui.components.SegmentedToggle
import com.wallpaper.dotz.ui.components.TextAction
import com.wallpaper.dotz.ui.theme.DotzType
import com.wallpaper.dotz.ui.theme.Ink
import com.wallpaper.dotz.ui.theme.Muted
import com.wallpaper.dotz.ui.theme.ScreenPad
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale

private val dateFmt get() = SimpleDateFormat("d MMM yyyy", Locale.getDefault())
fun formatDate(millis: Long): String = dateFmt.format(Date(millis))

@Composable
fun HomeScreen(
    vm: DotzViewModel,
    state: DotzState,
    quoteStatus: QuoteStatus,
    tab: HomeTab,
    onTab: (HomeTab) -> Unit,
    applying: Boolean,
    onEdit: () -> Unit,
    onApply: () -> Unit,
    onOpenBackground: () -> Unit,
    onOpenMarkedDates: () -> Unit,
) {
    Box(
        Modifier
            .fillMaxSize()
            .background(Ink),
    ) {
        AnimatedContent(
            targetState = tab,
            transitionSpec = { fadeIn(tween(220)) togetherWith fadeOut(tween(160)) },
            label = "tab",
        ) { t ->
            when (t) {
                HomeTab.LOOK -> LookScreen(vm, state, quoteStatus, onOpenBackground, onOpenMarkedDates)
                else -> CalendarTab(vm, state, t, applying, onEdit, onApply)
            }
        }
        FloatingNavBar(
            selected = tab,
            onSelect = onTab,
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .navigationBarsPadding()
                .padding(bottom = 24.dp),
        )
    }
}

/** Header: h1 + subtitle on the left, optional Pip chip on the right. */
@Composable
private fun Header(title: String, subtitle: String, chip: String?) {
    Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
        Column(Modifier.weight(1f)) {
            Text(title, style = DotzType.h1)
            Spacer(Modifier.height(2.dp))
            Text(subtitle, style = DotzType.label)
        }
        if (chip != null) PipChip(chip)
    }
}

@Composable
private fun CalendarTab(
    vm: DotzViewModel,
    state: DotzState,
    tab: HomeTab,
    applying: Boolean,
    onEdit: () -> Unit,
    onApply: () -> Unit,
) {
    val settings = remember(state) { state.toSettings() }
    val now = Calendar.getInstance()
    val year = now.get(Calendar.YEAR)
    val yearLeft = DotGridRenderer.daysInYear() - DotGridRenderer.dayOfYear()

    Column(
        Modifier
            .fillMaxSize()
            // Insets before the scroll, so scrolled content clips below the
            // status bar instead of sliding under it.
            .statusBarsPadding()
            .imePadding()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = ScreenPad)
            .padding(top = 20.dp, bottom = 120.dp),
    ) {
        when (tab) {
            HomeTab.YEAR -> {
                Header("Year", "$year", plural(yearLeft, "day") + " left")
                PreviewAndActions(settings, applying, onEdit, onApply)
            }
            HomeTab.MONTH -> {
                val monthName = SimpleDateFormat("MMMM yyyy", Locale.getDefault()).format(now.time)
                Header("Month", monthName, plural(yearLeft, "day") + " left")
                PreviewAndActions(settings, applying, onEdit, onApply)
            }
            HomeTab.GOAL -> GoalTab(vm, state, settings, applying, onEdit, onApply)
            HomeTab.LIFE -> LifeTab(vm, state, settings, applying, onEdit, onApply)
            HomeTab.LOOK -> Unit
        }
    }
}

@Composable
private fun PreviewAndActions(settings: DotzSettings, applying: Boolean, onEdit: () -> Unit, onApply: () -> Unit) {
    Box(
        Modifier
            .fillMaxWidth()
            .padding(top = 22.dp),
        contentAlignment = Alignment.Center,
    ) {
        PhonePreview(settings, width = 240.dp)
    }
    Row(
        Modifier
            .fillMaxWidth()
            .padding(top = 28.dp),
        horizontalArrangement = Arrangement.spacedBy(10.dp),
    ) {
        SecondaryButton("Edit", onEdit, icon = DotzIcons.Pencil)
        PrimaryButton("Set as wallpaper", onApply, Modifier.weight(1f), loading = applying, height = 52.dp)
    }
}

// ── Empty state (Goal / Life) ───────────────────────────────────────
@Composable
private fun EmptyState(title: String, body: String) {
    Column(
        Modifier
            .fillMaxWidth()
            .padding(start = 12.dp, end = 12.dp, top = 56.dp, bottom = 40.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(14.dp),
    ) {
        Pip(size = 96.dp, mood = PipMood.CURIOUS, contentDescription = "Pip looking up")
        Text(title, style = DotzType.emptyTitle, textAlign = TextAlign.Center, modifier = Modifier.padding(top = 8.dp))
        Text(body, style = DotzType.body, textAlign = TextAlign.Center, modifier = Modifier.widthIn(max = 280.dp))
    }
}

// ── Goal ────────────────────────────────────────────────────────────
@Composable
private fun GoalTab(
    vm: DotzViewModel,
    state: DotzState,
    settings: DotzSettings,
    applying: Boolean,
    onEdit: () -> Unit,
    onApply: () -> Unit,
) {
    var picker by remember { mutableStateOf<String?>(null) } // "target" | "start" | "newTarget"

    if (!state.goalIsSet) {
        var name by rememberSaveable { mutableStateOf(state.goalName) }
        var target by rememberSaveable { mutableStateOf<Long?>(null) }
        Header("Goal", "Nothing set yet", null)
        EmptyState("What are we counting to?", "Name it and pick a date. Pip will mark each day until then.")
        Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
            FieldCard("Goal name", name, { name = it }, placeholder = "e.g. Final exams")
            DateFieldCard("Target date", target?.let(::formatDate), onClick = { picker = "newTarget" })
            PrimaryButton(
                "Start counting",
                onClick = { target?.let { vm.startGoal(name, it) } },
                enabled = name.isNotBlank() && target != null,
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(top = 8.dp),
            )
        }
        if (picker == "newTarget") {
            DotzDatePickerDialog(
                initial = target,
                minDate = todayMidnight(),
                onConfirm = { target = it; picker = null },
                onDismiss = { picker = null },
            )
        }
        return
    }

    val left = (settings.goalTotalDays() - settings.goalPastDays()).coerceAtLeast(0)
    Header("Goal", state.displayGoalName, plural(left, "day") + " left")
    PreviewAndActions(settings, applying, onEdit, onApply)

    var open by rememberSaveable { mutableStateOf(false) }
    val rotation by animateFloatAsState(if (open) 180f else 0f, label = "chev")
    DotzCard(Modifier.padding(top = 24.dp), padding = PaddingValues(0.dp)) {
        Row(
            Modifier
                .fillMaxWidth()
                .heightIn(min = 56.dp)
                .clickable(role = Role.Button) { open = !open }
                .padding(horizontal = 16.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Text("Goal details", style = DotzType.rowTitle, modifier = Modifier.weight(1f))
            Icon(DotzIcons.ChevronDown, null, tint = Muted, modifier = Modifier.size(18.dp).rotate(rotation))
        }
        AnimatedVisibility(open, enter = expandVertically() + fadeIn(), exit = shrinkVertically() + fadeOut()) {
            Column(
                Modifier.padding(start = 8.dp, end = 8.dp, bottom = 8.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp),
            ) {
                FieldCard("Goal name", state.goalName, vm::setGoalName, placeholder = "e.g. Final exams", background = Ink)
                val today = todayMidnight()
                DateFieldCard("Start date", state.goalStartMillis?.takeIf { it != today }?.let(::formatDate) ?: "Today", { picker = "start" }, background = Ink)
                if (state.goalStartMillis != null && state.goalStartMillis != today) {
                    TextAction("Reset to today", { vm.setGoalStart(today) })
                }
                DateFieldCard("Target date", state.goalDateMillis?.let(::formatDate), { picker = "target" }, background = Ink)
                TextAction("Clear goal", vm::clearGoal)
            }
        }
    }

    when (picker) {
        "start" -> DotzDatePickerDialog(
            initial = state.goalStartMillis ?: todayMidnight(),
            maxDate = state.goalDateMillis,
            onConfirm = { vm.setGoalStart(it); picker = null },
            onDismiss = { picker = null },
        )
        "target" -> DotzDatePickerDialog(
            initial = state.goalDateMillis,
            minDate = state.goalStartMillis ?: todayMidnight(),
            onConfirm = { vm.setGoalDate(it); picker = null },
            onDismiss = { picker = null },
        )
    }
}

// ── Life ────────────────────────────────────────────────────────────
@Composable
private fun LifeTab(
    vm: DotzViewModel,
    state: DotzState,
    settings: DotzSettings,
    applying: Boolean,
    onEdit: () -> Unit,
    onApply: () -> Unit,
) {
    var picking by remember { mutableStateOf(false) }
    val birth = state.birthMillis

    if (birth == null) {
        Header("Life", "Nothing set yet", null)
        EmptyState("When did it all start?", "Add your date of birth. Pip will show your whole life, one dot per week.")
        DateFieldCard("Date of birth", null, onClick = { picking = true })
    } else {
        val left = (settings.lifeTotalUnits() - settings.lifeUnitsLived()).coerceAtLeast(0)
        val unit = if (state.lifeUnit == LifeUnit.WEEKS) "week" else "day"
        Header("Life", "Age ${age(birth)}", plural(left, unit) + " left")
        PreviewAndActions(settings, applying, onEdit, onApply)

        DotzCard(Modifier.padding(top = 24.dp), padding = PaddingValues(vertical = 8.dp)) {
            DateFieldCard("Date of birth", formatDate(birth), { picking = true }, Modifier.padding(horizontal = 0.dp))
            RowDivider()
            Column(Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                Row(verticalAlignment = Alignment.Bottom) {
                    Text("Life expectancy", style = DotzType.rowTitle, modifier = Modifier.weight(1f))
                    Text("${state.lifeExpYears} years", style = DotzType.bigNumber)
                }
                DotzSlider(
                    value = state.lifeExpYears.toFloat(),
                    onValueChange = { vm.setLifeExp(it.toInt()) },
                    valueRange = 50f..110f,
                    steps = 59,
                    contentDescription = "Life expectancy",
                )
            }
            RowDivider()
            Column(Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                Text("Count in", style = DotzType.rowTitle)
                SegmentedToggle(
                    options = listOf("Days", "Weeks"),
                    selectedIndex = state.lifeUnit.ordinal,
                    onSelect = { vm.setLifeUnit(LifeUnit.entries[it]) },
                )
            }
        }
    }

    if (picking) {
        DotzDatePickerDialog(
            initial = birth ?: Calendar.getInstance().apply { add(Calendar.YEAR, -25) }.timeInMillis,
            maxDate = todayMidnight(),
            onConfirm = { vm.setBirth(it); picking = false },
            onDismiss = { picking = false },
        )
    }
}

private fun age(birth: Long): Int {
    val b = Calendar.getInstance().apply { timeInMillis = birth }
    val n = Calendar.getInstance()
    var years = n.get(Calendar.YEAR) - b.get(Calendar.YEAR)
    val beforeBirthday = n.get(Calendar.MONTH) < b.get(Calendar.MONTH) ||
        (n.get(Calendar.MONTH) == b.get(Calendar.MONTH) && n.get(Calendar.DAY_OF_MONTH) < b.get(Calendar.DAY_OF_MONTH))
    if (beforeBirthday) years--
    return years.coerceAtLeast(0)
}

fun plural(n: Int, word: String) = "%,d %s".format(n, if (n == 1) word else "${word}s")
