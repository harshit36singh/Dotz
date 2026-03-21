import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../models/wallpaper_settings.dart';
import '../widgets/dot_grid_widget.dart';

class CustomizeScreen extends StatefulWidget {
  final WallpaperSettings settings;
  const CustomizeScreen({super.key, required this.settings});
  @override
  State<CustomizeScreen> createState() => _CustomizeScreenState();
}

class _CustomizeScreenState extends State<CustomizeScreen>
    with SingleTickerProviderStateMixin {
  late WallpaperSettings _s;
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _s   = widget.settings;
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  void _pickColor(String label, Color current, void Function(Color) onPick) {
    Color picked = current;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        title: Text(label,
            style: const TextStyle(color: Colors.white, fontSize: 15)),
        content: SingleChildScrollView(
          child: HueRingPicker(
            pickerColor: current,
            onColorChanged: (c) => picked = c,
            enableAlpha: false,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white38))),
          ElevatedButton(
            onPressed: () { onPick(picked); Navigator.pop(context); },
            style: ElevatedButton.styleFrom(
                backgroundColor: _s.todayDotColor,
                foregroundColor: Colors.white),
            child: const Text('Apply')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white38),
          onPressed: () => Navigator.pop(context)),
        title: const Text('Customize',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _s),
            child: Text('Done',
                style: TextStyle(
                    color: _s.todayDotColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 16))),
        ],
        bottom: TabBar(
          controller: _tab,
          indicatorColor: _s.todayDotColor,
          labelColor: _s.todayDotColor,
          unselectedLabelColor: Colors.white30,
          tabs: const [Tab(text: 'Colors'), Tab(text: 'Grid')],
        ),
      ),
      body: Column(
        children: [
          // Live preview
          Container(
            margin: const EdgeInsets.all(16),
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
              boxShadow: [
                BoxShadow(
                    color: _s.todayDotColor.withOpacity(0.12),
                    blurRadius: 24)
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: DotGridWallpaper(settings: _s),
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [_colorsTab(), _gridTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _colorsTab() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      _label('DOT COLORS'),
      _colorRow('Past days', 'Days already gone', _s.pastDotColor,
          (c) => setState(() => _s = _s.copyWith(pastDotColor: c))),
      _colorRow('Future days', 'Days remaining', _s.futureDotColor,
          (c) => setState(() => _s = _s.copyWith(futureDotColor: c))),
      _colorRow('Today', 'Current day accent', _s.todayDotColor,
          (c) => setState(() => _s = _s.copyWith(todayDotColor: c))),
      _colorRow('Background', 'Screen background', _s.backgroundColor,
          (c) => setState(() => _s = _s.copyWith(backgroundColor: c))),
      const SizedBox(height: 20),
      _label('PRESETS'),
      const SizedBox(height: 10),
      _presets(),
    ],
  );

  Widget _gridTab() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      _label('COLUMNS'),
      _slider('Number of columns', _s.columns.toDouble(), 10, 30,
          (v) => setState(() => _s = _s.copyWith(columns: v.round())),
          label: '${_s.columns}',
          divisions: 20),
      const SizedBox(height: 16),
      _label('DISPLAY'),
      _toggle(
          'Show progress label',
          '"X days left · Y%" at bottom',
          _s.showProgressLabel,
          (v) => setState(() => _s = _s.copyWith(showProgressLabel: v))),
      const SizedBox(height: 16),
      _label('TARGET SCREEN'),
      const SizedBox(height: 8),
      _targetPicker(),
    ],
  );

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(top: 4, bottom: 10),
    child: Text(t,
        style: const TextStyle(
            color: Colors.white24,
            fontSize: 10,
            letterSpacing: 2,
            fontWeight: FontWeight.w700)),
  );

  Widget _colorRow(String title, String sub, Color color,
      void Function(Color) onPick) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        title: Text(title,
            style: const TextStyle(color: Colors.white, fontSize: 14)),
        subtitle: Text(sub,
            style: const TextStyle(color: Colors.white38, fontSize: 12)),
        trailing: GestureDetector(
          onTap: () => _pickColor(title, color, onPick),
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white12, width: 1.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _slider(String title, double val, double min, double max,
      void Function(double) onChange,
      {String? label, int? divisions}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(color: Colors.white, fontSize: 14)),
              Text(label ?? val.toStringAsFixed(1),
                  style: TextStyle(
                      color: _s.todayDotColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _s.todayDotColor,
              inactiveTrackColor: Colors.white10,
              thumbColor: _s.todayDotColor,
              overlayColor: _s.todayDotColor.withOpacity(0.1),
              trackHeight: 2,
            ),
            child: Slider(
              value: val.clamp(min, max),
              min: min, max: max,
              divisions: divisions,
              onChanged: onChange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggle(String title, String sub, bool val,
      void Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(14)),
      child: SwitchListTile(
        title: Text(title,
            style: const TextStyle(color: Colors.white, fontSize: 14)),
        subtitle: Text(sub,
            style: const TextStyle(color: Colors.white38, fontSize: 12)),
        value: val,
        onChanged: onChanged,
        activeColor: _s.todayDotColor,
      ),
    );
  }

  Widget _targetPicker() {
    return Row(
      children: WallpaperTarget.values.map((t) {
        final sel = _s.target == t;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _s = _s.copyWith(target: t)),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: sel
                    ? _s.todayDotColor.withOpacity(0.12)
                    : const Color(0xFF111111),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: sel ? _s.todayDotColor : Colors.white12,
                    width: sel ? 1.5 : 1),
              ),
              child: Column(children: [
                Icon(t.icon,
                    color: sel ? _s.todayDotColor : Colors.white24,
                    size: 20),
                const SizedBox(height: 6),
                Text(t.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: sel ? _s.todayDotColor : Colors.white24,
                        fontSize: 10,
                        fontWeight: sel
                            ? FontWeight.w600
                            : FontWeight.w400)),
              ]),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _presets() {
    final presets = [
      {'bg': const Color(0xFF000000), 'past': const Color(0xFFFFFFFF), 'future': const Color(0xFF2A2A2A), 'today': const Color(0xFFFF4500)},
      {'bg': const Color(0xFF000000), 'past': const Color(0xFFCCBBFF), 'future': const Color(0xFF1A1A2A), 'today': const Color(0xFF9B8FFF)},
      {'bg': const Color(0xFF000000), 'past': const Color(0xFF00FF88), 'future': const Color(0xFF0A1A10), 'today': const Color(0xFFFFD700)},
      {'bg': const Color(0xFF000000), 'past': const Color(0xFFFFCC44), 'future': const Color(0xFF1A1500), 'today': const Color(0xFFFF6B35)},
      {'bg': const Color(0xFF000000), 'past': const Color(0xFF88DDFF), 'future': const Color(0xFF0A1520), 'today': const Color(0xFFFF88CC)},
      {'bg': const Color(0xFF000000), 'past': const Color(0xFF888888), 'future': const Color(0xFF1E1E1E), 'today': const Color(0xFFFFFFFF)},
    ];

    return Wrap(
      spacing: 10, runSpacing: 10,
      children: presets.map((p) {
        return GestureDetector(
          onTap: () => setState(() => _s = _s.copyWith(
            backgroundColor: p['bg'] as Color,
            pastDotColor:    p['past'] as Color,
            futureDotColor:  p['future'] as Color,
            todayDotColor:   p['today'] as Color,
          )),
          child: Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: p['bg'] as Color,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _dot(p['past']   as Color, 6),
                  const SizedBox(width: 3),
                  _dot(p['today']  as Color, 8),
                  const SizedBox(width: 3),
                  _dot(p['future'] as Color, 6),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _dot(Color c, double r) => Container(
    width: r * 2, height: r * 2,
    decoration: BoxDecoration(color: c, shape: BoxShape.circle),
  );
}
