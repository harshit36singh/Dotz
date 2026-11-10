package com.wallpaper.dotz.ui.components

import androidx.compose.animation.animateColorAsState
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Icon
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.selected
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import com.wallpaper.dotz.ui.theme.Ink
import com.wallpaper.dotz.ui.theme.Muted
import com.wallpaper.dotz.ui.theme.Rule
import com.wallpaper.dotz.ui.theme.Surface
import com.wallpaper.dotz.ui.theme.TextPrimary

enum class HomeTab(val label: String, val icon: ImageVector) {
    YEAR("Year", DotzIcons.Year),
    MONTH("Month", DotzIcons.Calendar),
    GOAL("Goal", DotzIcons.Goal),
    LIFE("Life", DotzIcons.Life),
    LOOK("Look", DotzIcons.Look),
}

/** Floating pill nav: 5 icon buttons, icons only (labels via semantics). */
@Composable
fun FloatingNavBar(selected: HomeTab, onSelect: (HomeTab) -> Unit, modifier: Modifier = Modifier) {
    Row(
        modifier
            .clip(CircleShape)
            .background(Surface)
            .border(1.dp, Rule, CircleShape)
            .padding(6.dp),
        horizontalArrangement = Arrangement.spacedBy(4.dp),
    ) {
        HomeTab.entries.forEach { tab ->
            val active = tab == selected
            val bg by animateColorAsState(if (active) TextPrimary else Color.Transparent, label = "navbg")
            val fg by animateColorAsState(if (active) Ink else Muted, label = "navfg")
            Box(
                Modifier
                    .size(48.dp)
                    .clip(CircleShape)
                    .background(bg)
                    .clickable(role = Role.Tab) { onSelect(tab) }
                    .semantics {
                        contentDescription = tab.label
                        this.selected = active
                    },
                contentAlignment = Alignment.Center,
            ) {
                Icon(tab.icon, null, tint = fg, modifier = Modifier.size(20.dp))
            }
        }
    }
}
