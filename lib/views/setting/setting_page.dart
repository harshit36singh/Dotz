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
        // Four-way toggle: Off | Progress | Quote | Custom
        _FourWayToggle(
          selected: vm.labelMode,
          onChanged: vm.setLabelMode,
        ),

        const SizedBox(height: 16),

        // ── Mode-specific content ──────────────────────────────
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

        if (vm.labelMode == LabelMode.custom) ...[
          _CustomLabelInput(vm: vm),
          const SizedBox(height: 12),
        ],

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
                    style: TextStyle(
                      color: vm.labelColor, fontSize: 13,
                      fontStyle: FontStyle.italic, height: 1.55),
                  ),
                  if (vm.quoteAuthor.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('— ${vm.quoteAuthor}',
                      style: TextStyle(color: vm.labelColor.withOpacity(0.6),
                        fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),
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
            const SizedBox(height: 12),
          ],
        ],

        // ── Shared controls: colour + font size (shown when label is ON) ──
        if (vm.labelMode != LabelMode.off) ...[
          _Divider(),
          const SizedBox(height: 14),
          _LabelAppearanceControls(vm: vm),
        ],
      ],
    );
  }
}

// ── Custom text input ──────────────────────────────────────────────
class _CustomLabelInput extends StatefulWidget {
  final HomeViewModel vm;
  const _CustomLabelInput({required this.vm});

  @override
  State<_CustomLabelInput> createState() => _CustomLabelInputState();
}

class _CustomLabelInputState extends State<_CustomLabelInput> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.vm.customLabelText);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(CupertinoIcons.pencil,
            color: Colors.white.withOpacity(0.4), size: 14),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _ctrl,
              style: TextStyle(
                color: widget.vm.labelColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Type your label text…',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 13),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: widget.vm.setCustomLabelText,
            ),
          ),
          if (_ctrl.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _ctrl.clear();
                widget.vm.setCustomLabelText('');
              },
              child: Icon(CupertinoIcons.xmark_circle_fill,
                color: Colors.white.withOpacity(0.3), size: 16),
            ),
        ],
      ),
    );
  }
}

// ── Label appearance controls (colour + size) ──────────────────────
class _LabelAppearanceControls extends StatelessWidget {
  final HomeViewModel vm;
  const _LabelAppearanceControls({required this.vm});

  void _pickColor(BuildContext ctx) => showModalBottomSheet(
    context: ctx,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => ColorPickerSheet(
      label: 'Label',
      current: vm.labelColor,
      onPick: vm.setLabelColor,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final isAuto = vm.labelFontSizeAuto;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Row: colour swatch + label ────────────────────────
        Row(
          children: [
            // Colour swatch
            GestureDetector(
              onTap: () => _pickColor(context),
              child: Row(
                children: [
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: vm.labelColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withOpacity(0.3), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: vm.labelColor.withOpacity(0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('LABEL COLOR',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.55),
                      fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 2)),
                  const SizedBox(width: 6),
                  Icon(CupertinoIcons.chevron_right,
                    color: Colors.white.withOpacity(0.3), size: 10),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // ── Font size ─────────────────────────────────────────
        Row(
          children: [
            Icon(CupertinoIcons.textformat_size,
              color: Colors.white.withOpacity(0.5), size: 14),
            const SizedBox(width: 8),
            Text('LABEL SIZE',
              style: TextStyle(
                color: Colors.white.withOpacity(0.55),
                fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 2)),
            const Spacer(),
            // Auto toggle
            GestureDetector(
              onTap: () => vm.setLabelFontSize(isAuto ? 12.0 : 0.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isAuto
                      ? Colors.white.withOpacity(0.15)
                      : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isAuto
                        ? Colors.white.withOpacity(0.4)
                        : Colors.white.withOpacity(0.1),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  isAuto ? 'AUTO' : '${vm.labelFontSize.round()} SP',
                  style: TextStyle(
                    color: isAuto ? Colors.white : Colors.white.withOpacity(0.6),
                    fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),

        if (!isAuto) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Text('A', style: TextStyle(
                color: Colors.white.withOpacity(0.35), fontSize: 10)),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor:   Colors.white,
                    inactiveTrackColor: Colors.white.withOpacity(0.15),
                    thumbColor:    Colors.white,
                    overlayColor:  Colors.white.withOpacity(0.08),
                    trackHeight:   1.5,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  ),
                  child: Slider(
                    value: vm.labelFontSize.clamp(8.0, 32.0),
                    min: 8, max: 32, divisions: 24,
                    onChanged: vm.setLabelFontSize,
                  ),
                ),
              ),
              Text('A', style: TextStyle(
                color: Colors.white.withOpacity(0.35), fontSize: 18,
                fontWeight: FontWeight.w700)),
            ],
          ),
          // Live preview of the label text at chosen size
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.08), width: 0.5),
            ),
            child: Text(
              vm.resolvedLabel.isEmpty ? 'Label preview' : vm.resolvedLabel,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: vm.labelColor,
                fontSize: vm.labelFontSize.clamp(8.0, 32.0),
                fontStyle: vm.labelMode == LabelMode.quote
                    ? FontStyle.italic
                    : FontStyle.normal,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Thin divider ───────────────────────────────────────────────────
class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    height: 0.5,
    color: Colors.white.withOpacity(0.1),
  );
}

// ── Four-way toggle: Off | Progress | Quote | Custom ───────────────
class _FourWayToggle extends StatelessWidget {
  final LabelMode selected;
  final void Function(LabelMode) onChanged;
  const _FourWayToggle({required this.selected, required this.onChanged});

  static const _options = [
    (LabelMode.off,      'OFF',      CupertinoIcons.xmark),
    (LabelMode.progress, 'PROGRESS', CupertinoIcons.chart_bar_square),
    (LabelMode.quote,    'QUOTE',    CupertinoIcons.quote_bubble),
    (LabelMode.custom,   'CUSTOM',   CupertinoIcons.pencil),
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon,
                      size: 11,
                      color: active ? Colors.black : Colors.white.withOpacity(0.4)),
                    const SizedBox(height: 2),
                    Text(label,
                      style: TextStyle(
                        color: active ? Colors.black : Colors.white.withOpacity(0.4),
                        fontSize: 7, fontWeight: FontWeight.w800, letterSpacing: 1,
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