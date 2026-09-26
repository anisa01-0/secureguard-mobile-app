import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The SecureGuard mark: a protective shield with a security check inside.
///
/// Drawn with a [CustomPainter] instead of an image asset so it stays sharp
/// at every size, adapts to light and dark mode and needs no external files.
class SgLogo extends StatelessWidget {
  const SgLogo({
    super.key,
    this.size = 72,
    this.gradient,
    this.markColor = Colors.white,
    this.showPulse = false,
  });

  /// Width of the shield. The height is 1.18x the width.
  final double size;

  /// Shield fill. Defaults to the SecureGuard brand gradient.
  final Gradient? gradient;

  /// Colour of the check mark inside the shield.
  final Color markColor;

  /// Draws a soft ring behind the shield (used on the splash screen).
  final bool showPulse;

  @override
  Widget build(BuildContext context) {
    final Widget shield = CustomPaint(
      size: Size(size, size * 1.18),
      painter: _ShieldPainter(
        gradient: gradient ?? AppColors.brandGradient,
        markColor: markColor,
      ),
    );

    if (!showPulse) {
      return Semantics(label: 'SecureGuard logo', child: shield);
    }

    return Semantics(
      label: 'SecureGuard logo',
      child: SizedBox(
        width: size * 1.9,
        height: size * 1.9,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              width: size * 1.9,
              height: size * 1.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: markColor.withValues(alpha: 0.07),
              ),
            ),
            Container(
              width: size * 1.45,
              height: size * 1.45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: markColor.withValues(alpha: 0.10),
              ),
            ),
            shield,
          ],
        ),
      ),
    );
  }
}

class _ShieldPainter extends CustomPainter {
  const _ShieldPainter({required this.gradient, required this.markColor});

  final Gradient gradient;
  final Color markColor;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Rect bounds = Offset.zero & size;

    // ------------------------------------------------------- shield outline
    final Path shield = Path()
      ..moveTo(w * 0.5, 0)
      ..lineTo(w * 0.96, h * 0.15)
      ..lineTo(w * 0.96, h * 0.50)
      ..cubicTo(w * 0.96, h * 0.76, w * 0.78, h * 0.93, w * 0.5, h)
      ..cubicTo(w * 0.22, h * 0.93, w * 0.04, h * 0.76, w * 0.04, h * 0.50)
      ..lineTo(w * 0.04, h * 0.15)
      ..close();

    canvas.drawShadow(shield, Colors.black.withValues(alpha: 0.4), 6, false);
    canvas.drawPath(shield, Paint()..shader = gradient.createShader(bounds));

    // A subtle highlight down the left edge gives the mark some depth.
    final Paint highlight = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          Colors.white.withValues(alpha: 0.18),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(bounds);
    canvas.save();
    canvas.clipPath(shield);
    canvas.drawRect(bounds, highlight);
    canvas.restore();

    // ----------------------------------------------------------- inner ring
    final Paint ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.035
      ..color = markColor.withValues(alpha: 0.28);
    canvas.drawCircle(Offset(w * 0.5, h * 0.46), w * 0.30, ring);

    // ----------------------------------------------------------- check mark
    final Path check = Path()
      ..moveTo(w * 0.35, h * 0.46)
      ..lineTo(w * 0.46, h * 0.57)
      ..lineTo(w * 0.67, h * 0.34);

    canvas.drawPath(
      check,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.10
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = markColor,
    );
  }

  @override
  bool shouldRepaint(_ShieldPainter oldDelegate) =>
      oldDelegate.gradient != gradient || oldDelegate.markColor != markColor;
}

/// The wordmark used on the splash screen and the login header.
class SgWordmark extends StatelessWidget {
  const SgWordmark({
    super.key,
    this.color,
    this.fontSize = 32,
    this.showTagline = true,
    this.taglineColor,
  });

  final Color? color;
  final double fontSize;
  final bool showTagline;
  final Color? taglineColor;

  /// The official product tagline.
  static const String tagline = 'Your Safety. One Tap Away.';

  @override
  Widget build(BuildContext context) {
    final Color base = color ?? Theme.of(context).colorScheme.onSurface;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
              color: base,
            ),
            children: <TextSpan>[
              const TextSpan(text: 'Secure'),
              TextSpan(
                text: 'Guard',
                style: TextStyle(color: base.withValues(alpha: 0.72)),
              ),
            ],
          ),
        ),
        if (showTagline) ...<Widget>[
          const SizedBox(height: 8),
          Text(
            tagline,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSize * 0.42,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.4,
              color: taglineColor ?? base.withValues(alpha: 0.75),
            ),
          ),
        ],
      ],
    );
  }
}
