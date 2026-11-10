package com.wallpaper.dotz

import android.app.WallpaperManager
import android.content.ComponentName
import android.content.Intent
import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.SystemBarStyle
import androidx.activity.compose.BackHandler
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.contract.ActivityResultContracts
import androidx.activity.viewModels
import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.wallpaper.dotz.data.CalendarMode
import com.wallpaper.dotz.ui.components.HomeTab
import com.wallpaper.dotz.ui.components.PipSnackbar
import com.wallpaper.dotz.ui.screens.AppliedScreen
import com.wallpaper.dotz.ui.screens.BackgroundImageScreen
import com.wallpaper.dotz.ui.screens.EditorScreen
import com.wallpaper.dotz.ui.screens.HomeScreen
import com.wallpaper.dotz.ui.screens.MarkedDatesScreen
import com.wallpaper.dotz.ui.screens.OnboardingScreen
import com.wallpaper.dotz.ui.screens.SplashScreen
import com.wallpaper.dotz.ui.theme.DotzTheme
import com.wallpaper.dotz.ui.theme.Ink
import kotlinx.coroutines.launch

/** Screens on top of Home. Home itself switches tabs in place. */
enum class Route { SPLASH, ONBOARDING, HOME, EDITOR, APPLIED, BACKGROUND, MARKED_DATES }

class MainActivity : ComponentActivity() {

    private val vm: DotzViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge(
            statusBarStyle = SystemBarStyle.dark(android.graphics.Color.TRANSPARENT),
            navigationBarStyle = SystemBarStyle.dark(android.graphics.Color.TRANSPARENT),
        )
        super.onCreate(savedInstanceState)
        setContent { DotzTheme { DotzApp(vm, firstLaunch = savedInstanceState == null) } }
    }

    /** Intents to open the system live-wallpaper picker, most specific first. */
    fun wallpaperPickerIntents(): List<Intent> = listOf(
        Intent(WallpaperManager.ACTION_CHANGE_LIVE_WALLPAPER).putExtra(
            WallpaperManager.EXTRA_LIVE_WALLPAPER_COMPONENT,
            ComponentName(this, DotzLiveWallpaper::class.java),
        ),
        Intent(WallpaperManager.ACTION_LIVE_WALLPAPER_CHOOSER),
    )
}

private val tabModes = mapOf(
    HomeTab.YEAR to CalendarMode.YEAR,
    HomeTab.MONTH to CalendarMode.MONTH,
    HomeTab.GOAL to CalendarMode.GOAL,
    HomeTab.LIFE to CalendarMode.LIFE,
)

private fun tabFor(mode: CalendarMode) = tabModes.entries.first { it.value == mode }.key

@Composable
private fun DotzApp(vm: DotzViewModel, firstLaunch: Boolean) {
    val activity = androidx.activity.compose.LocalActivity.current as MainActivity
    val state by vm.state.collectAsStateWithLifecycle()
    val quoteStatus by vm.quoteStatus.collectAsStateWithLifecycle()

    val stack = remember {
        mutableStateListOf(if (firstLaunch) Route.SPLASH else Route.HOME)
    }
    val route = stack.last()
    fun push(r: Route) { stack.add(r) }
    fun pop() { if (stack.size > 1) stack.removeAt(stack.lastIndex) }
    fun replace(r: Route) { stack.clear(); stack.add(r) }

    var tab by rememberSaveable { mutableStateOf(tabFor(state.mode)) }
    var applying by remember { mutableStateOf(false) }
    val snackbar = remember { SnackbarHostState() }
    val scope = rememberCoroutineScope()

    fun showError() {
        scope.launch { snackbar.showSnackbar("Couldn’t set the wallpaper. Try again.") }
    }

    // Returning from the system picker: success only if dotz is now live.
    val pickerLauncher = rememberLauncherForActivityResult(ActivityResultContracts.StartActivityForResult()) {
        applying = false
        if (vm.isLiveWallpaperActive()) push(Route.APPLIED)
    }

    fun apply() {
        applying = true
        if (!vm.applyToWallpaper()) {
            applying = false
            showError()
            return
        }
        // Already the live wallpaper: the new prefs are picked up instantly.
        if (vm.isLiveWallpaperActive()) {
            applying = false
            push(Route.APPLIED)
            return
        }
        val launched = activity.wallpaperPickerIntents().any { intent ->
            try {
                pickerLauncher.launch(intent)
                true
            } catch (e: Exception) {
                Log.w("Dotz", "Wallpaper picker intent failed: ${intent.action}", e)
                false
            }
        }
        if (!launched) {
            applying = false
            showError()
        }
    }

    BackHandler(enabled = stack.size > 1) { pop() }
    // Back from the Look tab returns to the calendar tab instead of exiting.
    BackHandler(enabled = stack.size == 1 && route == Route.HOME && tab == HomeTab.LOOK) {
        tab = tabFor(state.mode)
    }

    Box(
        Modifier
            .fillMaxSize()
            .background(Ink),
    ) {
        AnimatedContent(
            targetState = route,
            transitionSpec = { fadeIn(tween(220)) togetherWith fadeOut(tween(160)) },
            label = "route",
        ) { r ->
            when (r) {
                Route.SPLASH -> SplashScreen(onFinished = {
                    replace(if (vm.repo.isOnboardingComplete()) Route.HOME else Route.ONBOARDING)
                })
                Route.ONBOARDING -> OnboardingScreen(onFinished = {
                    vm.repo.setOnboardingComplete()
                    replace(Route.HOME)
                })
                Route.HOME -> HomeScreen(
                    vm = vm,
                    state = state,
                    quoteStatus = quoteStatus,
                    tab = tab,
                    onTab = { t ->
                        tab = t
                        tabModes[t]?.let(vm::setMode)
                    },
                    applying = applying,
                    onEdit = { push(Route.EDITOR) },
                    onApply = ::apply,
                    onOpenBackground = { push(Route.BACKGROUND) },
                    onOpenMarkedDates = { push(Route.MARKED_DATES) },
                )
                Route.EDITOR -> EditorScreen(vm, state, onDone = ::pop)
                Route.APPLIED -> AppliedScreen(onDone = ::pop)
                Route.BACKGROUND -> BackgroundImageScreen(vm, state, onBack = ::pop)
                Route.MARKED_DATES -> MarkedDatesScreen(vm, state, onBack = ::pop)
            }
        }

        SnackbarHost(
            hostState = snackbar,
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .navigationBarsPadding()
                .padding(bottom = 96.dp),
        ) { data -> PipSnackbar(data.visuals.message) }
    }
}
