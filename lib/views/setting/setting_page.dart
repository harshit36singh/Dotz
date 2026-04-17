import 'dart:ui';
import 'package:dotz/models/wallpaper_settings.dart';
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
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = mq.size.height;
    final hp = w >= 900
        ? 48.0
        : w >= 600
        ? 32.0
        : 20.0;

    // Calculate exact height to perfectly fit inside HomeScreen's SafeArea and 120px bottom padding.
    // This stops the parent from scrolling and hands scroll control to this widget.
    final availableHeight = h - mq.padding.top - mq.padding.bottom - 120;

    return SizedBox(
      height: availableHeight,
      child: Column(
        children: [
          // ── Fixed Top Card ──
          Padding(
            padding: EdgeInsets.symmetric(horizontal: hp),
            child: _GlassContainer(
              blur: 14,
              color: const Color(0x66000000),
              borderRadius: 100,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    Icon(
                      CupertinoIcons.gear_alt_fill,
                      color: Colors.white.withOpacity(0.8),
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Settings',
                      style: TextStyle(
                        fontFamily: 'Glass Antiqua', // Font applied
                        color: Colors.white,
                        fontSize: 20,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
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
              // ClampingScrollPhysics ensures it sits completely fixed if there is enough height,
              // but allows standard scrolling if the screen is too small.
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(hp, 0, hp, 40),
              child: _GlassContainer(
                blur: 18,
                color: const Color(0x55000000),
                borderRadius: 20,
                child: Column(
                  children: [
                    _StaticSettingsSection(
                      icon: CupertinoIcons.paintbrush,
                      title: 'Dot Colours',
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
                    _Divider(),
                    _StaticSettingsSection(
                      icon: CupertinoIcons.square_grid_3x2,
                      title: 'Grid Density',
                      child: _GridDensityContent(vm: vm),
                    ),
                    _Divider(),
                    _StaticSettingsSection(
                      icon: CupertinoIcons.text_bubble,
                      title: 'Wallpaper Label',
                      child: _LabelModeSection(vm: vm),
                    ),
                    _Divider(),
                    _StaticSettingsSection(
                      icon: CupertinoIcons.square,
                      title: 'Dot Shape',
                      child: _ShapeSelector(vm: vm),
                    ),
                    _Divider(),
                    _StaticSettingsSection(
                      icon: CupertinoIcons.photo,
                      title: 'Background Image',
                      isLast: true,
                      child: _BackgroundImageSection(vm: vm),
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

// ── Static Settings Section (Replaced Expandable Tile) ─────────────
class _StaticSettingsSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  final bool isLast;

  const _StaticSettingsSection({
    required this.icon,
    required this.title,
    required this.child,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Glass Antiqua', // Font applied
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, isLast ? 24 : 16),
          child: child,
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
            fontFamily: 'Glass Antiqua',
            color: Colors.white,
            fontSize: 48,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w900,
            height: 1,
            letterSpacing: -2,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'columns',
                style: TextStyle(
                  fontFamily: 'Glass Antiqua',
                  color: Colors.white.withOpacity(0.35),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 6),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.white,
                  inactiveTrackColor: Colors.white.withOpacity(0.1),
                  thumbColor: Colors.white,
                  overlayColor: Colors.white.withOpacity(0.06),
                  trackHeight: 1,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 5,
                  ),
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
              fontFamily: 'Glass Antiqua',
              color: Colors.white.withOpacity(0.4),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.6,
            ),
          ),

        if (vm.labelMode == LabelMode.progress)
          _PreviewRow(
            icon: CupertinoIcons.chart_bar,
            text: vm.settings.progressLabel,
          ),

        if (vm.labelMode == LabelMode.custom) ...[
          _CustomLabelInput(vm: vm),
          const SizedBox(height: 12),
        ],

        if (vm.labelMode == LabelMode.quote) ...[
          if (vm.quoteFetching)
            Row(
              children: [
                SizedBox(
                  width: 13,
                  height: 13,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Fetching quote…',
                  style: TextStyle(
                    fontFamily: 'Glass Antiqua',
                    color: Colors.white.withOpacity(0.4),
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
                      fontFamily: 'Glass Antiqua',
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 12,
                    ),
                  ),
                ),
                _MinimalButton(label: 'RETRY', onTap: vm.fetchQuote),
              ],
            )
          else if (vm.quoteText.isNotEmpty) ...[
            // ── Glass quote box ──
            _GlassContainer(
              blur: 8,
              color: const Color(0x33000000),
              borderRadius: 12,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '"${vm.quoteText}"',
                      style: TextStyle(
                        fontFamily: 'Glass Antiqua',
                        color: vm.labelColor,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        height: 1.6,
                      ),
                    ),
                    if (vm.quoteAuthor.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        '— ${vm.quoteAuthor}',
                        style: TextStyle(
                          fontFamily: 'Glass Antiqua',
                          color: vm.labelColor.withOpacity(0.5),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: vm.fetchQuote,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.arrow_clockwise,
                    color: Colors.white.withOpacity(0.3),
                    size: 11,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'REFRESH',
                    style: TextStyle(
                      fontFamily: 'Glass Antiqua',
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                ],
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
    color: const Color(0x33000000),
    borderRadius: 12,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.pencil,
            color: Colors.white.withOpacity(0.25),
            size: 13,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _ctrl,
              style: TextStyle(
                fontFamily: 'Glass Antiqua',
                color: widget.vm.labelColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Type your label…',
                hintStyle: TextStyle(
                  fontFamily: 'Glass Antiqua',
                  color: Colors.white.withOpacity(0.2),
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
              child: Icon(
                CupertinoIcons.xmark_circle_fill,
                color: Colors.white.withOpacity(0.2),
                size: 15,
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
        GestureDetector(
          onTap: () => _pickColor(context),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: vm.labelColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'LABEL COLOUR',
                style: TextStyle(
                  fontFamily: 'Glass Antiqua',
                  color: Colors.white.withOpacity(0.45),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              Icon(
                CupertinoIcons.chevron_right,
                color: Colors.white.withOpacity(0.2),
                size: 10,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Icon(
              CupertinoIcons.textformat_size,
              color: Colors.white.withOpacity(0.35),
              size: 13,
            ),
            const SizedBox(width: 8),
            Text(
              'LABEL SIZE',
              style: TextStyle(
                fontFamily: 'Glass Antiqua',
                color: Colors.white.withOpacity(0.45),
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => vm.setLabelFontSize(isAuto ? 12.0 : 0.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isAuto
                      ? Colors.white.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(isAuto ? 0.2 : 0.08),
                    width: 1,
                  ),
                ),
                child: Text(
                  isAuto ? 'AUTO' : '${vm.labelFontSize.round()} SP',
                  style: TextStyle(
                    fontFamily: 'Glass Antiqua',
                    color: isAuto
                        ? Colors.white
                        : Colors.white.withOpacity(0.45),
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
                  fontFamily: 'Glass Antiqua',
                  color: Colors.white.withOpacity(0.25),
                  fontSize: 10,
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: Colors.white.withOpacity(0.1),
                    thumbColor: Colors.white,
                    overlayColor: Colors.white.withOpacity(0.06),
                    trackHeight: 1,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 5,
                    ),
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
                  fontFamily: 'Glass Antiqua',
                  color: Colors.white.withOpacity(0.25),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // ── Glass label preview box ──
          _GlassContainer(
            blur: 8,
            color: const Color(0x33000000),
            borderRadius: 10,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Text(
                vm.resolvedLabel.isEmpty ? 'Label preview' : vm.resolvedLabel,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Glass Antiqua',
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
    (LabelMode.off, 'OFF', CupertinoIcons.xmark),
    (LabelMode.progress, 'PROGRESS', CupertinoIcons.chart_bar_square),
    (LabelMode.quote, 'QUOTE', CupertinoIcons.quote_bubble),
    (LabelMode.custom, 'CUSTOM', CupertinoIcons.pencil),
  ];

  @override
  Widget build(BuildContext context) {
    return _GlassContainer(
      blur: 8,
      color: const Color(0x44000000),
      borderRadius: 10,
      child: SizedBox(
        height: 40,
        child: Row(
          children: _options.asMap().entries.map((e) {
            final idx = e.key;
            final (mode, label, icon) = e.value;
            final active = selected == mode;
            final isFirst = idx == 0;
            final isLast = idx == _options.length - 1;

            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(mode),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: active ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.horizontal(
                      left: isFirst ? const Radius.circular(7) : Radius.zero,
                      right: isLast ? const Radius.circular(7) : Radius.zero,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: 10,
                        color: active
                            ? Colors.black
                            : Colors.white.withOpacity(0.3),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        label,
                        style: TextStyle(
                          fontFamily: 'Glass Antiqua',
                          color: active
                              ? Colors.black
                              : Colors.white.withOpacity(0.3),
                          fontSize: 7,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
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
  final IconData icon;
  final String text;
  const _PreviewRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: Colors.white.withOpacity(0.3), size: 12),
      const SizedBox(width: 8),
      Flexible(
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Glass Antiqua',
            color: Colors.white.withOpacity(0.55),
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    ],
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
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Glass Antiqua',
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
  Widget build(BuildContext context) =>
      Container(height: 0.5, color: Colors.white.withOpacity(0.07));
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
              fontFamily: 'Glass Antiqua',
              color: Colors.white.withOpacity(0.45),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            // ── Pick image — glass button ──
            Expanded(
              child: _GlassContainer(
                blur: 10,
                color: const Color(0x44FFFFFF),
                borderRadius: 10,
                child: GestureDetector(
                  onTap: vm.pickBackgroundImage,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          hasImage
                              ? CupertinoIcons.arrow_2_circlepath
                              : CupertinoIcons.photo_on_rectangle,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          hasImage ? 'CHANGE IMAGE' : 'CHOOSE FROM GALLERY',
                          style: const TextStyle(
                            fontFamily: 'Glass Antiqua',
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Clear image — red glass button ──
            if (hasImage) ...[
              const SizedBox(width: 10),
              _GlassContainer(
                blur: 10,
                color: const Color(0x55FF3B30),
                borderRadius: 10,
                child: GestureDetector(
                  onTap: vm.clearBackgroundImage,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: Icon(
                      CupertinoIcons.trash,
                      color: Colors.white,
                      size: 16,
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

// ── Native Glass Container Helper ──────────────────────────────────
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

class _ShapeSelector extends StatelessWidget {
  final HomeViewModel vm;
  const _ShapeSelector({required this.vm});

  static const _options = [
    (DotShape.circle, 'CIRCLE', CupertinoIcons.circle_fill),
    (DotShape.square, 'SQUARE', CupertinoIcons.square_fill),
    (DotShape.star, 'STAR', CupertinoIcons.star_fill),
    (
      DotShape.glass,
      'GLASS',
      CupertinoIcons.drop_fill,
    ), // Using a drop icon for "glass"
  ];

  @override
  Widget build(BuildContext context) {
    return _GlassContainer(
      blur: 8,
      color: const Color(0x44000000),
      borderRadius: 10,
      child: SizedBox(
        height: 50, // Slightly taller for shape icons
        child: Row(
          children: _options.map((e) {
            final (shape, label, icon) = e;
            final active = vm.dotShape == shape;
            final isFirst = e == _options.first;
            final isLast = e == _options.last;

            return Expanded(
              child: GestureDetector(
                onTap: () => vm.setDotShape(shape),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: active ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.horizontal(
                      left: isFirst ? const Radius.circular(7) : Radius.zero,
                      right: isLast ? const Radius.circular(7) : Radius.zero,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: 14,
                        color: active
                            ? Colors.black
                            : Colors.white.withOpacity(0.3),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: TextStyle(
                          fontFamily: 'Glass Antiqua',
                          color: active
                              ? Colors.black
                              : Colors.white.withOpacity(0.3),
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
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
