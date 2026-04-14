import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../viewmodels/home_view_model.dart';
import '../widgets/color_strip.dart';

// ── Main Settings Page ─────────────────────────────────────────────
class SettingsPage extends StatelessWidget {
  final HomeViewModel vm;
  const SettingsPage({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    // Determine responsive padding
    final w = MediaQuery.of(context).size.width;
    final hp = w >= 900 ? 48.0 : w >= 600 ? 32.0 : 20.0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(hp, 20, hp, 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          // List-wise Card Container matching the image
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2C2936), // Deep purple/grey from image
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Text(
                'Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ),
                _ExpandableSettingsTile(
                  icon: CupertinoIcons.paintbrush,
                  title: 'Dot Colours',
                  vm: vm,
                  child: ColorStrip(
                    pastColor: vm.pastColor, todayColor: vm.todayColor,
                    futureColor: vm.futureColor, bgColor: vm.bgColor,
                    onPastChanged: vm.setPastColor, onTodayChanged: vm.setTodayColor,
                    onFutureChanged: vm.setFutureColor, onBgChanged: vm.setBgColor,
                  ),
                ),
                _Divider(),
                _ExpandableSettingsTile(
                  icon: CupertinoIcons.square_grid_3x2,
                  title: 'Grid Density',
                  vm: vm,
                  child: _GridDensityContent(vm: vm),
                ),
                _Divider(),
                _ExpandableSettingsTile(
                  icon: CupertinoIcons.text_bubble,
                  title: 'Wallpaper Label',
                  vm: vm,
                  isLast: true,
                  child: _LabelModeSection(vm: vm),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Expandable UI Component ────────────────────────────────────────

class _ExpandableSettingsTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final Widget child;
  final HomeViewModel vm;
  final bool isLast;

  const _ExpandableSettingsTile({
    required this.icon,
    required this.title,
    required this.child,
    required this.vm,
    this.isLast = false,
  });

  @override
  State<_ExpandableSettingsTile> createState() => _ExpandableSettingsTileState();
}

class _ExpandableSettingsTileState extends State<_ExpandableSettingsTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          borderRadius: BorderRadius.vertical(
            top: widget.isLast && !_isExpanded ? Radius.zero : const Radius.circular(20),
            bottom: widget.isLast && !_isExpanded ? const Radius.circular(20) : Radius.zero,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Icon(widget.icon, color: Colors.white, size: 20),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  _isExpanded ? CupertinoIcons.chevron_up : CupertinoIcons.chevron_down,
                  color: Colors.white.withOpacity(0.4),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        
        // This handles smooth inline expansion
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: !_isExpanded 
              ? const SizedBox(width: double.infinity)
              : // AnimatedBuilder ensures the UI reacts instantly to changes (fixes the tab bug)
                AnimatedBuilder(
                  animation: widget.vm,
                  builder: (context, _) => Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: widget.child,
                  ),
                ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(height: 1, color: Colors.white.withOpacity(0.05)),
      );
}

// ── Below are the exact unedited logic components from your code ──

// ── Grid density content ───────────────────────────────────────────
class _GridDensityContent extends StatelessWidget {
  final HomeViewModel vm;
  const _GridDensityContent({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('${vm.columns}',
          style: const TextStyle(
            color: Colors.white, fontSize: 48,
            fontStyle: FontStyle.italic, fontWeight: FontWeight.w900,
            height: 1, letterSpacing: -2)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('columns',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.35),
                  fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 2)),
              const SizedBox(height: 6),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor:   Colors.white,
                  inactiveTrackColor: Colors.white.withOpacity(0.1),
                  thumbColor:         Colors.white,
                  overlayColor:       Colors.white.withOpacity(0.06),
                  trackHeight:        1,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
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
        _FourWayToggle(selected: vm.labelMode, onChanged: vm.setLabelMode),
        const SizedBox(height: 16),

        if (vm.labelMode == LabelMode.off)
          Text('No label will appear on the wallpaper.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.3), fontSize: 12, height: 1.6)),

        if (vm.labelMode == LabelMode.progress)
          _PreviewRow(icon: CupertinoIcons.chart_bar, text: vm.settings.progressLabel),

        if (vm.labelMode == LabelMode.custom) ...[
          _CustomLabelInput(vm: vm),
          const SizedBox(height: 12),
        ],

        if (vm.labelMode == LabelMode.quote) ...[
          if (vm.quoteFetching)
            Row(children: [
              SizedBox(
                width: 13, height: 13,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5, color: Colors.white.withOpacity(0.5)),
              ),
              const SizedBox(width: 10),
              Text('Fetching quote…',
                style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 12)),
            ])
          else if (vm.quoteError)
            Row(children: [
              Expanded(child: Text('Could not load quote.',
                style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 12))),
              _MinimalButton(label: 'RETRY', onTap: vm.fetchQuote),
            ])
          else if (vm.quoteText.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2), // Adjusted to blend with new UI
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('"${vm.quoteText}"',
                    style: TextStyle(
                      color: vm.labelColor, fontSize: 13,
                      fontStyle: FontStyle.italic, height: 1.6)),
                  if (vm.quoteAuthor.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('— ${vm.quoteAuthor}',
                      style: TextStyle(
                        color: vm.labelColor.withOpacity(0.5),
                        fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: vm.fetchQuote,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(CupertinoIcons.arrow_clockwise,
                  color: Colors.white.withOpacity(0.3), size: 11),
                const SizedBox(width: 6),
                Text('REFRESH',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 2)),
              ]),
            ),
            const SizedBox(height: 12),
          ],
        ],

        if (vm.labelMode != LabelMode.off) ...[
          _HairLine(),
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
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.2), // Adjusted to blend with new UI
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
    ),
    child: Row(children: [
      Icon(CupertinoIcons.pencil,
        color: Colors.white.withOpacity(0.25), size: 13),
      const SizedBox(width: 10),
      Expanded(
        child: TextField(
          controller: _ctrl,
          style: TextStyle(
            color: widget.vm.labelColor,
            fontSize: 13, fontWeight: FontWeight.w400),
          decoration: InputDecoration(
            hintText: 'Type your label…',
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.2), fontSize: 13),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (v) {
            widget.vm.setCustomLabelText(v);
            setState(() {});
          },
        ),
      ),
      if (_ctrl.text.isNotEmpty)
        GestureDetector(
          onTap: () {
            _ctrl.clear();
            widget.vm.setCustomLabelText('');
            setState(() {});
          },
          child: Icon(CupertinoIcons.xmark_circle_fill,
            color: Colors.white.withOpacity(0.2), size: 15),
        ),
    ]),
  );
}

// ── Label appearance controls ──────────────────────────────────────
class _LabelAppearanceControls extends StatelessWidget {
  final HomeViewModel vm;
  const _LabelAppearanceControls({required this.vm});

  void _pickColor(BuildContext ctx) => showModalBottomSheet(
    context: ctx,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => ColorPickerSheet(
      label: 'Label', current: vm.labelColor, onPick: vm.setLabelColor),
  );

  @override
  Widget build(BuildContext context) {
    final isAuto = vm.labelFontSizeAuto;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Colour
        GestureDetector(
          onTap: () => _pickColor(context),
          child: Row(children: [
            Container(
              width: 20, height: 20,
              decoration: BoxDecoration(
                color: vm.labelColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.2), width: 1.5)),
            ),
            const SizedBox(width: 10),
            Text('LABEL COLOUR',
              style: TextStyle(
                color: Colors.white.withOpacity(0.45),
                fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 2)),
            const Spacer(),
            Icon(CupertinoIcons.chevron_right,
              color: Colors.white.withOpacity(0.2), size: 10),
          ]),
        ),

        const SizedBox(height: 18),

        // Size
        Row(children: [
          Icon(CupertinoIcons.textformat_size,
            color: Colors.white.withOpacity(0.35), size: 13),
          const SizedBox(width: 8),
          Text('LABEL SIZE',
            style: TextStyle(
              color: Colors.white.withOpacity(0.45),
              fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 2)),
          const Spacer(),
          GestureDetector(
            onTap: () => vm.setLabelFontSize(isAuto ? 12.0 : 0.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isAuto ? Colors.white.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(isAuto ? 0.2 : 0.08), width: 1)),
              child: Text(
                isAuto ? 'AUTO' : '${vm.labelFontSize.round()} SP',
                style: TextStyle(
                  color: isAuto ? Colors.white : Colors.white.withOpacity(0.45),
                  fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
            ),
          ),
        ]),

        if (!isAuto) ...[
          const SizedBox(height: 10),
          Row(children: [
            Text('A', style: TextStyle(
              color: Colors.white.withOpacity(0.25), fontSize: 10)),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor:   Colors.white,
                  inactiveTrackColor: Colors.white.withOpacity(0.1),
                  thumbColor:         Colors.white,
                  overlayColor:       Colors.white.withOpacity(0.06),
                  trackHeight:        1,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                ),
                child: Slider(
                  value: vm.labelFontSize.clamp(8.0, 32.0),
                  min: 8, max: 32, divisions: 24,
                  onChanged: vm.setLabelFontSize,
                ),
              ),
            ),
            Text('A', style: TextStyle(
              color: Colors.white.withOpacity(0.25),
              fontSize: 18, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2), // Adjusted to blend with new UI
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
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
                    ? FontStyle.italic : FontStyle.normal),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Four-way toggle ────────────────────────────────────────────────
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
      height: 40,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2), // Adjusted to blend with new UI
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
      ),
      child: Row(
        children: _options.asMap().entries.map((e) {
          final idx = e.key;
          final (mode, label, icon) = e.value;
          final active  = selected == mode;
          final isFirst = idx == 0;
          final isLast  = idx == _options.length - 1;

          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(mode),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: active ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.horizontal(
                    left:  isFirst ? const Radius.circular(7) : Radius.zero,
                    right: isLast  ? const Radius.circular(7) : Radius.zero,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 10,
                      color: active ? Colors.black : Colors.white.withOpacity(0.3)),
                    const SizedBox(height: 2),
                    Text(label,
                      style: TextStyle(
                        color: active ? Colors.black : Colors.white.withOpacity(0.3),
                        fontSize: 7, fontWeight: FontWeight.w800, letterSpacing: 0.8)),
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

// ── Preview row (progress mode) ────────────────────────────────────
class _PreviewRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _PreviewRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: Colors.white.withOpacity(0.3), size: 12),
      const SizedBox(width: 8),
      Flexible(child: Text(text,
        style: TextStyle(color: Colors.white.withOpacity(0.55),
          fontSize: 12, fontWeight: FontWeight.w400))),
    ],
  );
}

// ── Minimal outline button ─────────────────────────────────────────
class _MinimalButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _MinimalButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
        style: const TextStyle(
          color: Colors.white, fontSize: 9,
          fontWeight: FontWeight.w800, letterSpacing: 2)),
    ),
  );
}

// ── Hairline ───────────────────────────────────────────────────────
class _HairLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(height: 0.5, color: Colors.white.withOpacity(0.07));
}