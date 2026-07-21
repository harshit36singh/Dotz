import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

/// The one glass surface used everywhere in the app — cards, sheets,
/// buttons, dialogs. Radius, blur, and border are fixed to the shared
/// design tokens in app_theme.dart so every glass panel reads as the same
/// material; only fill color/opacity and padding vary per context.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final Color color;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final Border? border;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = kGlassBlur,
    this.color = const Color(0x33000000),
    this.borderRadius = const BorderRadius.all(Radius.circular(kGlassRadius)),
    this.padding,
    this.width,
    this.height,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: color,
            borderRadius: borderRadius,
            border: border ??
                Border.all(color: kGlassBorderColor, width: kGlassBorderWidth),
          ),
          child: child,
        ),
      ),
    );
  }
}
