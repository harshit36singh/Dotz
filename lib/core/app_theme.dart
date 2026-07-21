import 'package:flutter/material.dart';

const kBg    = Color(0xFFF5F0E8); // warm cream page background
const kSurf  = Color(0xFFFAF8F4); // elevated surface (cards, sheets)
const kSurf2 = Color(0xFFEEE9DF); // subtle surface
const kInk   = Color(0xFF1C1814); // primary text
const kMid   = Color(0xFF6B6660); // secondary / muted text
const kRule  = Color(0xFFE0DAD0); // dividers & borders
const kRed   = Color(0xFFCC2200); // accent / CTA
const kOrange= Color(0xFFE8640A); // app icon & live indicator

const kDotPast   = Color(0xFF1C1814); // near-black — days gone
const kDotToday  = Color(0xFFCC2200); // red — today marker
const kDotFuture = Color(0xFFE0DAD0); // light — days ahead
const kDotBg     = Color(0xFF0D0C0A); // near-black wallpaper bg

const kSwatches = [
  Color(0xFFFAF8F4), Color(0xFF1C1814), Color(0xFFF5F0E8),
  Color(0xFFCC2200), Color(0xFF0D0C0A), Color(0xFF252220),
  Color(0xFF9B8FFF), Color(0xFF00D470), Color(0xFFFFCC44),
  Color(0xFF38B6FF), Color(0xFFFF88CC), Color(0xFFFFD700),
  Color(0xFF282420), Color(0xFFE8D5C4), Color(0xFF8B7355),
  Color(0xFFFF6B35), Color(0xFFA0A09A), Color(0xFFC8B89A),
];

// ── Glass design system ──────────────────────────────────────────────
// One shared set of values for every glass surface in the app (see
// GlassContainer in widgets/glass_container.dart) so cards, sheets, and
// buttons read as one consistent material instead of each screen having
// its own slightly-different blur/radius/border.
const double kGlassRadius = 6.0; // squarish corners everywhere, not pills
const double kGlassBlur = 24.0;
const double kGlassBorderWidth = 1.0;
final Color kGlassBorderColor = Colors.white.withOpacity(0.20);

// One duration + curve for every micro-interaction (toggles, taps, selection
// changes) so the app has a single consistent "feel" instead of a mix of
// speeds. Larger one-off transitions (page navigation, splash) intentionally
// use their own longer durations, but share this curve family.
const Duration kAnimDuration = Duration(milliseconds: 220);
const Curve kAnimCurve = Curves.easeOutCubic;
