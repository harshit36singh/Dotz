import 'package:flutter/material.dart';
import '../models/wallpaper_settings.dart';

const _redL = Color(0xFFCC2200);

class LifeSetupScreen extends StatefulWidget {
  final WallpaperSettings settings;
  const LifeSetupScreen({super.key, required this.settings});
  @override State<LifeSetupScreen> createState() => _S();
}

class _S extends State<LifeSetupScreen> {
  late WallpaperSettings _s;
  DateTime? _b;
  int _exp = 80;

  @override void initState() {
    super.initState();
    _s = widget.settings;
    _b = _s.birthDate;
    _exp = _s.lifeExpectancyYears;
  }

  bool   get _dark => _s.isDark;
  Color  get _bg   => _dark ? const Color(0xFF100F0D) : const Color(0xFFF5F0E8);
  Color  get _surf => _dark ? const Color(0xFF181613) : const Color(0xFFFAF8F4);
  Color  get _ink  => _dark ? const Color(0xFFF0EBE2) : const Color(0xFF1C1814);
  Color  get _mid  => _dark ? const Color(0xFF686460) : const Color(0xFF6B6660);
  Color  get _rul  => _dark ? const Color(0xFF272420) : const Color(0xFFE0DAD0);

  int get _age => _b == null ? 0 : DateTime.now().difference(_b!).inDays ~/ 365;
  int get _wL  => _b == null ? 0 : DateTime.now().difference(_b!).inDays;
  int get _tot => _exp * 365;
  int get _rem => (_tot - _wL).clamp(0, _tot);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg, elevation: 0, surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: _mid, size: 18),
          onPressed: () => Navigator.pop(context)),
        title: Text('Life Calendar',
          style: TextStyle(color: _ink, fontSize: 15,
              fontStyle: FontStyle.italic, fontWeight: FontWeight.w700,
              letterSpacing: -0.3)),
        actions: [
          if (_b != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: () => Navigator.pop(context, _s.copyWith(
                    birthDate: _b,
                    lifeExpectancyYears: _exp,
                    mode: CalendarMode.life)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  color: _redL,
                  child: const Text('DONE',
                    style: TextStyle(color: Colors.white,
                        fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 2)),
                ),
              ),
            ),
        ],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _rul)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 8),
          Text('DATE OF BIRTH', style: TextStyle(
              color: _mid, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 3)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () async {
              final p = await showDatePicker(
                context: context,
                initialDate: _b ?? DateTime(1995, 6, 15),
                firstDate: DateTime(1900), lastDate: DateTime.now(),
                builder: (ctx, ch) => Theme(
                  data: Theme.of(ctx).copyWith(colorScheme:
                      ColorScheme.dark(primary: _redL, surface: _surf, onSurface: _ink)),
                  child: ch!),
              );
              if (p != null) setState(() => _b = p);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: _surf,
                border: Border.all(
                    color: _b != null ? _redL : _rul,
                    width: _b != null ? 1.5 : 1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(children: [
                Text(
                  _b == null ? 'Pick your birth date'
                      : '${_b!.day} / ${_b!.month} / ${_b!.year}',
                  style: TextStyle(color: _b != null ? _ink : _mid,
                      fontSize: 15, fontWeight: FontWeight.w500)),
                const Spacer(),
                if (_b != null)
                  Text('Age $_age',
                    style: const TextStyle(color: _redL,
                        fontSize: 13, fontWeight: FontWeight.w700)),
              ]),
            ),
          ),

          const SizedBox(height: 32),
          Container(height: 1, color: _rul),
          const SizedBox(height: 32),

          Text('LIFE EXPECTANCY', style: TextStyle(
              color: _mid, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 3)),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('$_exp',
                style: const TextStyle(
                  color: _redL, fontSize: 56,
                  fontStyle: FontStyle.italic, fontWeight: FontWeight.w900,
                  height: 0.9, letterSpacing: -2)),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('years', style: TextStyle(color: _mid, fontSize: 10,
                    fontWeight: FontWeight.w500, letterSpacing: 1.5)),
                Text('$_tot days total', style: const TextStyle(
                    color: _redL, fontSize: 11, fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(width: 12),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: _redL, inactiveTrackColor: _rul,
                    thumbColor: _redL, overlayColor: _redL.withOpacity(0.08),
                    trackHeight: 1,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                  ),
                  child: Slider(value: _exp.toDouble(), min: 50, max: 120, divisions: 70,
                      onChanged: (v) => setState(() => _exp = v.round())),
                ),
              ),
            ],
          ),

          if (_b != null) ...[
            const SizedBox(height: 32),
            Container(height: 1, color: _rul),
            const SizedBox(height: 28),

            Text('STATISTICS', style: TextStyle(
                color: _mid, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 3)),
            const SizedBox(height: 20),

            // Giant days lived
            Text(_wL.toString().padLeft(2, '0'),
              style: const TextStyle(
                color: _redL, fontSize: 88,
                fontStyle: FontStyle.italic, fontWeight: FontWeight.w900,
                height: 0.88, letterSpacing: -4)),
            Text('days lived',
              style: TextStyle(color: _ink, fontSize: 22,
                  fontStyle: FontStyle.italic, fontWeight: FontWeight.w700,
                  letterSpacing: -0.3)),

            const SizedBox(height: 24),

            // Stat row
            Row(children: [
              _Stat('$_rem', 'days left', _mid, _rul, _surf),
              const SizedBox(width: 1),
              _Stat(
                '${(_wL / _tot * 100).toStringAsFixed(1)}%',
                'of life lived', _mid, _rul, _surf),
            ]),
          ],
        ]),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String v, l;
  final Color mid, rul, surf;
  const _Stat(this.v, this.l, this.mid, this.rul, this.surf);
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: surf,
        border: Border.all(color: rul),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(v, style: const TextStyle(color: _redL,
            fontSize: 20, fontWeight: FontWeight.w800,
            fontStyle: FontStyle.italic, letterSpacing: -0.5)),
        const SizedBox(height: 2),
        Text(l, style: TextStyle(color: mid, fontSize: 9,
            fontWeight: FontWeight.w600, letterSpacing: 1.5)),
      ]),
    ),
  );
}
