import 'package:flutter/material.dart';
import '../models/wallpaper_settings.dart';

const _red = Color(0xFFCC2200);

class GoalSetupScreen extends StatefulWidget {
  final WallpaperSettings settings;
  const GoalSetupScreen({super.key, required this.settings});
  @override State<GoalSetupScreen> createState() => _S();
}

class _S extends State<GoalSetupScreen> {
  late WallpaperSettings _s;
  final _c = TextEditingController();
  DateTime? _d;

  @override void initState() {
    super.initState();
    _s = widget.settings;
    _c.text = _s.goalName == 'My Goal' ? '' : _s.goalName;
    _d = _s.goalDate;
  }

  bool   get _dark => _s.isDark;
  Color  get _bg   => _dark ? const Color(0xFF100F0D) : const Color(0xFFF5F0E8);
  Color  get _surf => _dark ? const Color(0xFF181613) : const Color(0xFFFAF8F4);
  Color  get _ink  => _dark ? const Color(0xFFF0EBE2) : const Color(0xFF1C1814);
  Color  get _mid  => _dark ? const Color(0xFF686460) : const Color(0xFF6B6660);
  Color  get _rul  => _dark ? const Color(0xFF272420) : const Color(0xFFE0DAD0);

  @override
  Widget build(BuildContext context) {
    final days = _d == null ? null : _d!.difference(DateTime.now()).inDays;
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg, elevation: 0, surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: _mid, size: 18),
          onPressed: () => Navigator.pop(context)),
        title: Text('Goal Calendar',
          style: TextStyle(color: _ink, fontSize: 15,
              fontStyle: FontStyle.italic, fontWeight: FontWeight.w700,
              letterSpacing: -0.3)),
        actions: [
          if (_d != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: () => Navigator.pop(context, _s.copyWith(
                  goalName: _c.text.trim().isEmpty ? 'My Goal' : _c.text.trim(),
                  goalDate: _d, mode: CalendarMode.goal,
                )),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  color: _red,
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
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 8),
          Text('GOAL NAME', style: TextStyle(
              color: _mid, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 3)),
          const SizedBox(height: 12),
          TextField(
            controller: _c,
            style: TextStyle(color: _ink, fontSize: 16, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: 'e.g. New York Marathon',
              hintStyle: TextStyle(color: _mid),
              filled: true, fillColor: _surf,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: _rul)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: _rul)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: _red, width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 32),
          Container(height: 1, color: _rul),
          const SizedBox(height: 32),
          Text('TARGET DATE', style: TextStyle(
              color: _mid, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 3)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () async {
              final p = await showDatePicker(
                context: context,
                initialDate: _d ?? DateTime.now().add(const Duration(days: 60)),
                firstDate: DateTime.now().add(const Duration(days: 1)),
                lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                builder: (ctx, ch) => Theme(
                  data: Theme.of(ctx).copyWith(colorScheme:
                      ColorScheme.dark(primary: _red, surface: _surf, onSurface: _ink)),
                  child: ch!),
              );
              if (p != null) setState(() => _d = p);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: _surf,
                border: Border.all(
                    color: _d != null ? _red : _rul,
                    width: _d != null ? 1.5 : 1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(children: [
                Text(
                  _d == null ? 'Pick a date'
                      : '${_d!.day} / ${_d!.month} / ${_d!.year}',
                  style: TextStyle(color: _d != null ? _ink : _mid,
                      fontSize: 15, fontWeight: FontWeight.w500)),
                const Spacer(),
                if (days != null)
                  Text('$days days away',
                    style: const TextStyle(color: _red,
                        fontSize: 12, fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
          if (_d != null) ...[
            const SizedBox(height: 32),
            Container(height: 1, color: _rul),
            const SizedBox(height: 28),
            // Giant number preview
            Text(_d!.difference(DateTime.now()).inDays.toString().padLeft(2, '0'),
              style: const TextStyle(
                color: _red, fontSize: 96,
                fontStyle: FontStyle.italic, fontWeight: FontWeight.w900,
                height: 0.88, letterSpacing: -4)),
            Text('days remaining',
              style: TextStyle(color: _ink, fontSize: 20,
                  fontStyle: FontStyle.italic, fontWeight: FontWeight.w700,
                  letterSpacing: -0.3)),
          ],
        ]),
      ),
    );
  }
}
