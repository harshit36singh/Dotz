import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../viewmodels/home_view_model.dart';
import '../widgets/color_strip.dart';

class SettingsPage extends StatelessWidget {
  final HomeViewModel vm;
  const SettingsPage({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Dot colours ──────────────────────────────────────
          _GlassSection(
            title: 'DOT COLOURS',
            icon: CupertinoIcons.paintbrush,
            child: ColorStrip(
              pastColor:       vm.pastColor,
              todayColor:      vm.todayColor,
              futureColor:     vm.futureColor,
              bgColor:         vm.bgColor,
              onPastChanged:   vm.setPastColor,
              onTodayChanged:  vm.setTodayColor,
              onFutureChanged: vm.setFutureColor,
              onBgChanged:     vm.setBgColor,
            ),
          ),

          const SizedBox(height: 16),

          // ── Grid density ─────────────────────────────────────
          _GlassSection(
            title: 'GRID DENSITY',
            icon: CupertinoIcons.square_grid_3x2,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${vm.columns}',
                  style: const TextStyle(
                    color: Colors.white, fontSize: 52,
                    fontStyle: FontStyle.italic, fontWeight: FontWeight.w900,
                    height: 1, letterSpacing: -2,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('columns',
                        style: TextStyle(color: Colors.white.withOpacity(0.5),
                          fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 2)),
                      const SizedBox(height: 6),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor:   Colors.white,
                          inactiveTrackColor: Colors.white.withOpacity(0.15),
                          thumbColor:    Colors.white,
                          overlayColor:  Colors.white.withOpacity(0.08),
                          trackHeight:   1.5,
                          thumbShape:    const RoundSliderThumbShape(enabledThumbRadius: 6),
                        ),
                        child: Slider(
                          value: vm.columns.toDouble(),
                          min: 10, max: 30, divisions: 20,
                          onChanged: (v) => vm.setColumns(v.round()),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Label / Quote ─────────────────────────────────────
          _GlassSection(
            title: 'WALLPAPER LABEL',
            icon: CupertinoIcons.text_bubble,
            child: _LabelModeSection(vm: vm),
          ),

          const SizedBox(height: 16),

          // ── About ─────────────────────────────────────────────
          _GlassSection(
            title: 'ABOUT',
            icon: CupertinoIcons.info_circle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AboutRow(label: 'App',     value: 'DotZ'),
                _AboutRow(label: 'Version', value: '1.0.0'),
                _AboutRow(label: 'Purpose', value: 'Live dot wallpapers'),
                const SizedBox(height: 8),
                Text(
                  'Each dot is a day. Watch your year, goals, and life unfold—one dot at a time.',
                  style: TextStyle(color: Colors.white.withOpacity(0.45),
                    fontSize: 12, height: 1.7, letterSpacing: 0.2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Label mode section ─────────────────────────────────────────────
class _LabelModeSection extends StatelessWidget {
  final HomeViewModel vm;
  const _LabelModeSection({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Three-way toggle
        _ThreeWayToggle(
          selected: vm.labelMode,
          onChanged: vm.setLabelMode,
        ),

        const SizedBox(height: 16),

        // Description / preview depending on mode
        if (vm.labelMode == LabelMode.off)
          Text(
            'Nothing will be shown at the bottom of the wallpaper.',
            style: TextStyle(color: Colors.white.withOpacity(0.45),
              fontSize: 12, height: 1.6),
          ),

        if (vm.labelMode == LabelMode.progress)
          _PreviewChip(
            icon: CupertinoIcons.chart_bar,
            text: vm.settings.progressLabel,
          ),

        if (vm.labelMode == LabelMode.quote) ...[
          if (vm.quoteFetching)
            Row(children: [
              const SizedBox(
                width: 14, height: 14,
                child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Text('Fetching today\'s quote…',
                style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 12)),
            ])
          else if (vm.quoteError)
            Row(
              children: [
                Expanded(
                  child: Text('Could not load quote. Tap to retry.',
                    style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 12)),
                ),
                GestureDetector(
                  onTap: vm.fetchQuote,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.5),
                    ),
                    child: const Text('RETRY',
                      style: TextStyle(color: Colors.white, fontSize: 9,
                        fontWeight: FontWeight.w800, letterSpacing: 2)),
                  ),
                ),
              ],
            )
          else if (vm.quoteText.isNotEmpty) ...[
            // Quote card preview
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '"${vm.quoteText}"',
                    style: const TextStyle(
                      color: Colors.white, fontSize: 13,
                      fontStyle: FontStyle.italic, height: 1.55),
                  ),
                  if (vm.quoteAuthor.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('— ${vm.quoteAuthor}',
                      style: TextStyle(color: Colors.white.withOpacity(0.5),
                        fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Refresh button
            GestureDetector(
              onTap: vm.fetchQuote,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(CupertinoIcons.arrow_clockwise,
                    color: Colors.white.withOpacity(0.4), size: 12),
                  const SizedBox(width: 6),
                  Text('REFRESH QUOTE',
                    style: TextStyle(color: Colors.white.withOpacity(0.4),
                      fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 2)),
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }
}

// ── Three-way toggle: Off | Progress | Quote ───────────────────────
class _ThreeWayToggle extends StatelessWidget {
  final LabelMode selected;
  final void Function(LabelMode) onChanged;
  const _ThreeWayToggle({required this.selected, required this.onChanged});

  static const _options = [
    (LabelMode.off,      'OFF',      CupertinoIcons.xmark),
    (LabelMode.progress, 'PROGRESS', CupertinoIcons.chart_bar_square),
    (LabelMode.quote,    'QUOTE',    CupertinoIcons.quote_bubble),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
      ),
      child: Row(
        children: _options.asMap().entries.map((e) {
          final idx  = e.key;
          final (mode, label, icon) = e.value;
          final active = selected == mode;

          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(mode),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: active ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon,
                      size: 11,
                      color: active ? Colors.black : Colors.white.withOpacity(0.4)),
                    const SizedBox(width: 5),
                    Text(label,
                      style: TextStyle(
                        color: active ? Colors.black : Colors.white.withOpacity(0.4),
                        fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Small preview chip shown for progress mode ─────────────────────
class _PreviewChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _PreviewChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.5), size: 13),
          const SizedBox(width: 8),
          Flexible(
            child: Text(text,
              style: TextStyle(color: Colors.white.withOpacity(0.7),
                fontSize: 12, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

// ── Glass section card ─────────────────────────────────────────────
class _GlassSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _GlassSection({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.12), width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(icon, color: Colors.white.withOpacity(0.5), size: 14),
                const SizedBox(width: 8),
                Text(title,
                  style: TextStyle(color: Colors.white.withOpacity(0.45),
                    fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 3.5)),
              ]),
              const SizedBox(height: 16),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  final String label, value;
  const _AboutRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4),
            fontSize: 12, fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.white,
            fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}