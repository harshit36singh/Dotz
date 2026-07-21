import 'dart:ui';
import 'package:dotz/models/wallpaper_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/home_view_model.dart';
import '../widgets/color_strip.dart';
import '../widgets/glass_date_picker.dart';

// ── Main Settings Page ─────────────────────────────────────────────
class SettingsPage extends StatelessWidget {
  final HomeViewModel vm;
  const SettingsPage({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final title="Settings";
    final w = mq.size.width;
    final h = mq.size.height;
    final hp = w >= 900
        ? 48.0
        : w >= 600
            ? 32.0
            : 20.0;

    final availableHeight = h - mq.padding.top - mq.padding.bottom - 120;

    return SizedBox(
      height: availableHeight,
      child: Column(
        children: [
          // ── Fixed Top Header — text only, no icon ──
          Padding(
            padding: EdgeInsets.symmetric(horizontal: hp),
            child: _GlassContainer(
              blur: 14,
              color: const Color(0x55000000),
              borderRadius: 100,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  Text(
               title.toUpperCase()
                  ,style: TextStyle(
                    // Removing fontFamily defaults to the clean system font (Roboto/SF Pro)
                    color: Colors.white.withOpacity(0.85), // Slightly dimmed for a "sober" look
                    fontSize: 13, // Smaller size
                    fontWeight: FontWeight.w600, // Medium weight, not too bold
                    letterSpacing: 2.5, // Wide, elegant spacing
                  ),
                ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Scrollable Settings Body ──
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(hp, 0, hp, 40),
              child: _GlassContainer(
                blur: 18,
                color: const Color(0x44000000),
                borderRadius: 22,
                child: Column(
                  children: [
                    _SettingsSection(
                      label: 'Dot Colours',
                      child: ColorStrip(
                        pastColor: vm.pastColor,
                        todayColor: vm.todayColor,
                        futureColor: vm.futureColor,
                        bgColor: vm.bgColor,
                        onPastChanged: vm.setPastColor,
                        onTodayChanged: vm.setTodayColor,
                        onFutureChanged: vm.setFutureColor,
                        onBgChanged: vm.setBgColor,
                      ),
                    ),
                    _SectionDivider(),
                    _SettingsSection(
                      label: 'Grid Density',
                      child: _GridDensityContent(vm: vm),
                    ),
                    _SectionDivider(),
                    _SettingsSection(
                      label: 'Wallpaper Label',
                      child: _LabelModeSection(vm: vm),
                    ),
                    _SectionDivider(),
                    _SettingsSection(
                      label: 'Dot Shape',
                      child: _ShapeSelector(vm: vm),
                    ),
                    _SectionDivider(),
                    _SettingsSection(
                      label: 'Background Image',
                      child: _BackgroundImageSection(vm: vm),
                    ),
                    _SectionDivider(),
                    _SettingsSection(
                      label: 'Marked Dates',
                      isLast: true,
                      child: _MarkedDatesSection(vm: vm),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Settings Section ───────────────────────────────────────────────
class _SettingsSection extends StatelessWidget {
  final String label;
  final Widget child;
  final bool isLast;

  const _SettingsSection({
    required this.label,
    required this.child,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Montserrat',
              color: Colors.white.withOpacity(0.35),
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.2,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, isLast ? 22 : 16),
          child: child,
        ),
      ],
    );
  }
}

class _SectionDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          height: 0.5,
          color: Colors.white.withOpacity(0.06),
        ),
      );
}

// ── Grid Density ───────────────────────────────────────────────────
class _GridDensityContent extends StatelessWidget {
  final HomeViewModel vm;
  const _GridDensityContent({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '${vm.columns}',
          style: const TextStyle(
            fontFamily: 'Montserrat',
            color: Colors.white,
            fontSize: 46,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w900,
            height: 1,
            letterSpacing: -2,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'columns',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.white.withOpacity(0.28),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 6),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.white,
                  inactiveTrackColor: Colors.white.withOpacity(0.08),
                  thumbColor: Colors.white,
                  overlayColor: Colors.white.withOpacity(0.04),
                  trackHeight: 1,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 4.5),
                ),
                child: Slider(
                  value: vm.columns.toDouble(),
                  min: 10,
                  max: 30,
                  divisions: 20,
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

// ── Label Mode Section ─────────────────────────────────────────────
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
          Text(
            'No label will appear on the wallpaper.',
            style: TextStyle(
              fontFamily: 'Montserrat',
              color: Colors.white.withOpacity(0.35),
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.6,
            ),
          ),

        if (vm.labelMode == LabelMode.progress)
          _PreviewRow(text: vm.settings.progressLabel),

        if (vm.labelMode == LabelMode.custom) ...[
          _CustomLabelInput(vm: vm),
          const SizedBox(height: 12),
        ],

        if (vm.labelMode == LabelMode.quote) ...[
          if (vm.quoteFetching)
            Row(
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.2,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Fetching quote…',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.white.withOpacity(0.35),
                    fontSize: 12,
                  ),
                ),
              ],
            )
          else if (vm.quoteError)
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Could not load quote.',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.white.withOpacity(0.35),
                      fontSize: 12,
                    ),
                  ),
                ),
                _MinimalButton(label: 'RETRY', onTap: vm.fetchQuote),
              ],
            )
          else if (vm.quoteText.isNotEmpty) ...[
            _GlassContainer(
              blur: 8,
              color: const Color(0x28000000),
              borderRadius: 12,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '"${vm.quoteText}"',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: vm.labelColor,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        height: 1.65,
                      ),
                    ),
                    if (vm.quoteAuthor.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        '— ${vm.quoteAuthor}',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          color: vm.labelColor.withOpacity(0.45),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    // ZenQuotes' free tier requires visible attribution —
                    // https://zenquotes.io/documentation
                    const SizedBox(height: 10),
                    Text(
                      'Quote via zenquotes.io',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.white.withOpacity(0.22),
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Minimal refresh row — no icon, just a subtle label
            GestureDetector(
              onTap: vm.fetchQuote,
              behavior: HitTestBehavior.opaque,
              child: Text(
                '↻  REFRESH',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.white.withOpacity(0.25),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
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

// ── Custom Label Input ─────────────────────────────────────────────
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
  Widget build(BuildContext context) => _GlassContainer(
        blur: 8,
        color: const Color(0x28000000),
        borderRadius: 12,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              // Minimal thin pencil line — no icon widget
              Container(
                width: 1,
                height: 16,
                color: Colors.white.withOpacity(0.15),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: widget.vm.labelColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type your label…',
                    hintStyle: TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.white.withOpacity(0.18),
                      fontSize: 14,
                    ),
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
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white.withOpacity(0.18),
                      size: 14,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
}

// ── Label Appearance Controls ──────────────────────────────────────
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
        // Colour row
        GestureDetector(
          onTap: () => _pickColor(context),
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: vm.labelColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.15),
                    width: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'LABEL COLOUR',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.white.withOpacity(0.38),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              Text(
                '›',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.18),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Size row
        Row(
          children: [
            Text(
              'LABEL SIZE',
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: Colors.white.withOpacity(0.38),
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => vm.setLabelFontSize(isAuto ? 12.0 : 0.0),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isAuto
                      ? Colors.white.withOpacity(0.08)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white
                        .withOpacity(isAuto ? 0.18 : 0.07),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  isAuto ? 'AUTO' : '${vm.labelFontSize.round()} SP',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: isAuto
                        ? Colors.white.withOpacity(0.85)
                        : Colors.white.withOpacity(0.38),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),

        if (!isAuto) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'A',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.white.withOpacity(0.2),
                  fontSize: 10,
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: Colors.white.withOpacity(0.08),
                    thumbColor: Colors.white,
                    overlayColor: Colors.white.withOpacity(0.04),
                    trackHeight: 1,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 4.5),
                  ),
                  child: Slider(
                    value: vm.labelFontSize.clamp(8.0, 32.0),
                    min: 8,
                    max: 32,
                    divisions: 24,
                    onChanged: vm.setLabelFontSize,
                  ),
                ),
              ),
              Text(
                'A',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.white.withOpacity(0.2),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _GlassContainer(
            blur: 8,
            color: const Color(0x28000000),
            borderRadius: 10,
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Text(
                vm.resolvedLabel.isEmpty ? 'Label preview' : vm.resolvedLabel,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: vm.labelColor,
                  fontSize: vm.labelFontSize.clamp(8.0, 32.0),
                  fontStyle: vm.labelMode == LabelMode.quote
                      ? FontStyle.italic
                      : FontStyle.normal,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Four-way Toggle ────────────────────────────────────────────────
class _FourWayToggle extends StatelessWidget {
  final LabelMode selected;
  final void Function(LabelMode) onChanged;
  const _FourWayToggle({required this.selected, required this.onChanged});

  static const _options = [
    (LabelMode.off, 'OFF'),
    (LabelMode.progress, 'PROGRESS'),
    (LabelMode.quote, 'QUOTE'),
    (LabelMode.custom, 'CUSTOM'),
  ];

  @override
  Widget build(BuildContext context) {
    return _GlassContainer(
      blur: 8,
      color: const Color(0x38000000),
      borderRadius: 10,
      child: SizedBox(
        height: 36,
        child: Row(
          children: _options.asMap().entries.map((e) {
            final idx = e.key;
            final (mode, label) = e.value;
            final active = selected == mode;
            final isFirst = idx == 0;
            final isLast = idx == _options.length - 1;

            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(mode),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: active
                        ? Colors.white.withOpacity(0.92)
                        : Colors.transparent,
                    borderRadius: BorderRadius.horizontal(
                      left: isFirst
                          ? const Radius.circular(7)
                          : Radius.zero,
                      right:
                          isLast ? const Radius.circular(7) : Radius.zero,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: active
                            ? Colors.black.withOpacity(0.85)
                            : Colors.white.withOpacity(0.28),
                        fontSize: 7,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ── Preview Row ────────────────────────────────────────────────────
class _PreviewRow extends StatelessWidget {
  final String text;
  const _PreviewRow({required this.text});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          fontFamily: 'Montserrat',
          color: Colors.white.withOpacity(0.45),
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
      );
}

// ── Minimal Button ─────────────────────────────────────────────────
class _MinimalButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _MinimalButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
              width: 0.8,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
        ),
      );
}

// ── Hairline ───────────────────────────────────────────────────────
class _HairLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        height: 0.5,
        color: Colors.white.withOpacity(0.06),
      );
}

// ── Background Image Section ───────────────────────────────────────
class _BackgroundImageSection extends StatelessWidget {
  final HomeViewModel vm;
  const _BackgroundImageSection({required this.vm});

  @override
  Widget build(BuildContext context) {
    final hasImage = vm.bgImagePath.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasImage) ...[
          Text(
            'Custom image selected',
            style: TextStyle(
              fontFamily: 'Montserrat',
              color: Colors.white.withOpacity(0.35),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(
              // ── Moved GestureDetector Outside for full button hit area ──
              child: GestureDetector(
                onTap: vm.pickBackgroundImage,
                behavior: HitTestBehavior.opaque, 
                child: _GlassContainer(
                  blur: 10,
                  color: const Color(0x33FFFFFF),
                  borderRadius: 10,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    child: Center(
                      child: Text(
                        hasImage ? 'CHANGE IMAGE' : 'CHOOSE FROM GALLERY',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (hasImage) ...[
              const SizedBox(width: 10),
              // ── Moved GestureDetector Outside for full button hit area ──
              GestureDetector(
                onTap: vm.clearBackgroundImage,
                behavior: HitTestBehavior.opaque, 
                child: _GlassContainer(
                  blur: 10,
                  color: const Color(0x44FF3B30),
                  borderRadius: 10,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 13, horizontal: 18),
                    child: Text(
                      'REMOVE',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

// ── Glass Container Helper ─────────────────────────────────────────
class _GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final Color color;
  final double borderRadius;

  const _GlassContainer({
    required this.child,
    this.blur = 10,
    this.color = const Color(0x33000000),
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ── Shape Selector ─────────────────────────────────────────────────
class _ShapeSelector extends StatelessWidget {
  final HomeViewModel vm;
  const _ShapeSelector({required this.vm});

  static const _options = [
    (DotShape.circle, 'CIRCLE'),
    (DotShape.square, 'SQUARE'),
    (DotShape.star, 'STAR'),
    (DotShape.glass, 'GLASS'),
    (DotShape.hexagon, 'HEXAGON'),
    (DotShape.diamond, 'DIAMOND'),
  ];

  Widget _row(List<(DotShape, String)> rowOptions) {
    return SizedBox(
      height: 36,
      child: Row(
        children: rowOptions.map((e) {
          final (shape, label) = e;
          final active = vm.dotShape == shape;

          return Expanded(
            child: GestureDetector(
              onTap: () => vm.setDotShape(shape),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: active
                      ? Colors.white.withOpacity(0.92)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: active
                          ? Colors.black.withOpacity(0.85)
                          : Colors.white.withOpacity(0.28),
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _GlassContainer(
      blur: 8,
      color: const Color(0x38000000),
      borderRadius: 10,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _row(_options.sublist(0, 3)),
          _row(_options.sublist(3, 6)),
        ],
      ),
    );
  }
}

// ── Marked Dates ────────────────────────────────────────────────────
class _MarkedDatesSection extends StatefulWidget {
  final HomeViewModel vm;
  const _MarkedDatesSection({required this.vm});

  @override
  State<_MarkedDatesSection> createState() => _MarkedDatesSectionState();
}

class _MarkedDatesSectionState extends State<_MarkedDatesSection> {
  DateTime? _pendingDate;
  late final TextEditingController _labelCtrl;

  @override
  void initState() {
    super.initState();
    _labelCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showGlassDatePicker(
      context: context,
      initialDate: _pendingDate ?? now,
      firstDate: DateTime(now.year - 100),
      lastDate: DateTime(now.year + 10),
    );
    if (date != null) setState(() => _pendingDate = date);
  }

  void _addDate() {
    final date = _pendingDate;
    if (date == null) return;
    final label = _labelCtrl.text.trim().isEmpty ? 'Untitled' : _labelCtrl.text.trim();
    widget.vm.addMarkedDate(MarkedDate(month: date.month, day: date.day, label: label));
    setState(() {
      _pendingDate = null;
      _labelCtrl.clear();
    });
  }

  void _pickColor() => showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => ColorPickerSheet(
          label: 'Milestone',
          current: widget.vm.milestoneColor,
          onPick: widget.vm.setMilestoneColor,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Highlights specific calendar dates — birthdays, anniversaries — in '
          'Year and Weekly/Monthly mode. Repeats every year.',
          style: TextStyle(
            fontFamily: 'Montserrat',
            color: Colors.white.withOpacity(0.35),
            fontSize: 11,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),

        // Milestone colour
        GestureDetector(
          onTap: _pickColor,
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: vm.milestoneColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'MILESTONE COLOUR',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.white.withOpacity(0.38),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              Text('›', style: TextStyle(color: Colors.white.withOpacity(0.18), fontSize: 16)),
            ],
          ),
        ),
        const SizedBox(height: 18),

        if (vm.markedDates.isNotEmpty) ...[
          ...vm.markedDates.map(
            (m) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(color: vm.milestoneColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${m.label} — ${DateFormat('MMM d').format(DateTime(2000, m.month, m.day))}',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => vm.removeMarkedDate(m),
                    behavior: HitTestBehavior.opaque,
                    child: Icon(Icons.close_rounded, color: Colors.white.withOpacity(0.25), size: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          _HairLine(),
          const SizedBox(height: 16),
        ],

        Text(
          'ADD DATE',
          style: TextStyle(
            fontFamily: 'Montserrat',
            color: Colors.white.withOpacity(0.35),
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        _GlassContainer(
          blur: 8,
          color: const Color(0x28000000),
          borderRadius: 12,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _labelCtrl,
                    style: TextStyle(fontFamily: 'Montserrat', color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "e.g. Mom's Birthday",
                      hintStyle: TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.white.withOpacity(0.18),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _pickDate,
                  behavior: HitTestBehavior.opaque,
                  child: Text(
                    _pendingDate == null ? 'PICK DATE' : DateFormat('MMM d').format(_pendingDate!),
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _pendingDate == null ? null : _addDate,
          behavior: HitTestBehavior.opaque,
          child: _GlassContainer(
            blur: 10,
            color: _pendingDate == null ? const Color(0x18FFFFFF) : const Color(0x33FFFFFF),
            borderRadius: 10,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 13),
              child: Center(
                child: Text(
                  'ADD',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.white.withOpacity(_pendingDate == null ? 0.3 : 0.85),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}