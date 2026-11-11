package com.wallpaper.dotz

import android.app.Application
import android.net.Uri
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.wallpaper.dotz.data.CalendarMode
import com.wallpaper.dotz.data.DotShape
import com.wallpaper.dotz.data.DotzRepository
import com.wallpaper.dotz.data.DotzState
import com.wallpaper.dotz.data.LabelMode
import com.wallpaper.dotz.data.LifeUnit
import com.wallpaper.dotz.data.MarkedDate
import com.wallpaper.dotz.data.todayMidnight
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

enum class QuoteStatus { IDLE, LOADING, ERROR }

class DotzViewModel(app: Application) : AndroidViewModel(app) {

    val repo = DotzRepository(app)

    private val _state = MutableStateFlow(repo.loadDraft())
    val state: StateFlow<DotzState> = _state.asStateFlow()

    private val _quoteStatus = MutableStateFlow(QuoteStatus.IDLE)
    val quoteStatus: StateFlow<QuoteStatus> = _quoteStatus.asStateFlow()

    private var saveJob: Job? = null

    init {
        refreshQuoteIfStale()
    }

    /** Quote mode shows the quote of the day: refetch once the stored one is from an earlier day. */
    private fun refreshQuoteIfStale() {
        val s = _state.value
        if (s.labelMode == LabelMode.QUOTE && (s.quoteText.isBlank() || s.quoteDay != todayMidnight())) fetchQuote()
    }

    private fun edit(block: (DotzState) -> DotzState) {
        _state.update(block)
        // Debounced so pinch/drag in the editor doesn't write on every frame.
        saveJob?.cancel()
        saveJob = viewModelScope.launch {
            delay(250)
            repo.saveDraft(_state.value)
        }
    }

    // ── Mode ─────────────────────────────────────────────────────────
    fun setMode(m: CalendarMode) = edit { it.copy(mode = m) }

    // ── Colours / look ───────────────────────────────────────────────
    fun setPastColor(c: Int) = edit { it.copy(pastColor = c) }
    fun setTodayColor(c: Int) = edit { it.copy(todayColor = c) }
    fun setFutureColor(c: Int) = edit { it.copy(futureColor = c) }
    /** Picking a background colour replaces any background image. */
    fun setBgColor(c: Int) = edit { it.copy(bgColor = c, bgImagePath = "") }
    fun setTodayStyle(style: String) = edit { it.copy(todayStyle = style) }
    fun setShape(s: DotShape) = edit { it.copy(dotShape = s) }
    fun setColumns(n: Int) = edit { it.copy(columns = n) }
    fun setShowDateNumbers(v: Boolean) = edit { it.copy(showDateNumbers = v) }

    // ── Label ────────────────────────────────────────────────────────
    fun setLabelMode(m: LabelMode) {
        edit { it.copy(labelMode = m) }
        refreshQuoteIfStale()
    }
    fun setCustomLabel(v: String) = edit { it.copy(customLabel = v) }
    fun setLabelColor(c: Int) = edit { it.copy(labelColor = c) }
    fun setLabelFontSize(v: Float) = edit { it.copy(labelFontSize = v) }

    /** [random] asks for a different quote than the quote of the day ("New quote"). */
    fun fetchQuote(random: Boolean = false) {
        if (_quoteStatus.value == QuoteStatus.LOADING) return
        _quoteStatus.value = QuoteStatus.LOADING
        viewModelScope.launch {
            val q = repo.fetchQuote(random)
            if (q != null) {
                edit { it.copy(quoteText = q.first, quoteAuthor = q.second, quoteDay = todayMidnight()) }
                _quoteStatus.value = QuoteStatus.IDLE
            } else {
                _quoteStatus.value = QuoteStatus.ERROR
            }
        }
    }

    // ── Background image ─────────────────────────────────────────────
    fun importBackground(uri: Uri) {
        viewModelScope.launch {
            val path = repo.importBackground(uri) ?: return@launch
            edit { it.copy(bgImagePath = path) }
            repo.cleanupBackgrounds(path)
        }
    }

    fun clearBackground() {
        edit { it.copy(bgImagePath = "") }
        repo.cleanupBackgrounds("")
    }

    // ── Position (editor) ────────────────────────────────────────────
    fun setTransform(scale: Float, x: Float, y: Float) = edit {
        it.copy(gridScale = scale.coerceIn(0.2f, 3f), offsetX = x.coerceIn(-1f, 1f), offsetY = y.coerceIn(-1f, 1f))
    }
    fun resetTransform() = setTransform(1f, 0f, 0f)

    // ── Goal ─────────────────────────────────────────────────────────
    fun startGoal(name: String, target: Long) =
        // Pin the start to today: leaving it null would make "today" move with the
        // calendar, so every re-apply would restart the countdown from day 1.
        edit { it.copy(goalName = name.trim(), goalDateMillis = target, goalStartMillis = todayMidnight()) }
    fun setGoalName(v: String) = edit { it.copy(goalName = v) }
    fun setGoalDate(d: Long) = edit { it.copy(goalDateMillis = d) }
    fun setGoalStart(d: Long) = edit { it.copy(goalStartMillis = d) }
    fun clearGoal() = edit { it.copy(goalName = "", goalDateMillis = null, goalStartMillis = null) }

    // ── Life ─────────────────────────────────────────────────────────
    fun setBirth(d: Long) = edit { it.copy(birthMillis = d) }
    fun setLifeExp(y: Int) = edit { it.copy(lifeExpYears = y) }
    fun setLifeUnit(u: LifeUnit) = edit { it.copy(lifeUnit = u) }

    // ── Marked dates ─────────────────────────────────────────────────
    fun addMarkedDate(d: MarkedDate) = edit { it.copy(markedDates = it.markedDates + d) }
    fun removeMarkedDate(d: MarkedDate) = edit { it.copy(markedDates = it.markedDates - d) }
    fun setMilestoneColor(c: Int) = edit { it.copy(milestoneColor = c) }

    // ── Apply ────────────────────────────────────────────────────────
    /** Writes the current look to the live wallpaper + widget prefs. */
    fun applyToWallpaper(): Boolean = try {
        repo.writeWallpaperPrefs(_state.value)
        true
    } catch (e: Exception) {
        false
    }

    fun isLiveWallpaperActive() = repo.isLiveWallpaperActive()

    override fun onCleared() {
        repo.saveDraft(_state.value)
        super.onCleared()
    }
}
