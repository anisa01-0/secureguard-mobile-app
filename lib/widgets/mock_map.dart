import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A simulated map view.
///
/// SecureGuard is a university prototype and deliberately avoids a paid map
/// SDK (Google Maps / Mapbox) that would need an API key and billing account.
/// This widget draws a stylised street grid with the user's marker, an
/// accuracy circle and a pulsing "live" ring, so the location features can be
/// demonstrated on any device. Swapping it for a real `GoogleMap` widget
/// later only changes this one file.
class MockMap extends StatefulWidget {
  const MockMap({
    super.key,
    required this.latitude,
    required this.longitude,
    this.isSharing = false,
    this.height = 260,
    this.accuracyMeters = 8,
    this.interactive = true,
  });

  final double latitude;
  final double longitude;
  final bool isSharing;
  final double height;
  final double accuracyMeters;

  /// When false the map renders as a static preview (used inside cards).
  final bool interactive;

  @override
  State<MockMap> createState() => _MockMapState();
}

class _MockMapState extends State<MockMap> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  double _zoom = 1;

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _changeZoom(double delta) {
    setState(() => _zoom = (_zoom + delta).clamp(0.7, 1.8));
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _pulse,
                builder: (BuildContext context, _) => CustomPaint(
                  painter: _MapPainter(
                    latitude: widget.latitude,
                    longitude: widget.longitude,
                    pulse: _pulse.value,
                    isSharing: widget.isSharing,
                    isDark: isDark,
                    zoom: _zoom,
                  ),
                ),
              ),
            ),

            // ------------------------------------------- simulation notice
            Positioned(
              left: 12,
              top: 12,
              child: _MapChip(
                icon: Icons.info_outline_rounded,
                label: 'Simulated map view',
                isDark: isDark,
              ),
            ),

            // ------------------------------------------------- live status
            if (widget.isSharing)
              Positioned(
                right: 12,
                top: 12,
                child: _MapChip(
                  icon: Icons.podcasts_rounded,
                  label: 'LIVE',
                  isDark: isDark,
                  color: AppColors.red,
                ),
              ),

            // ----------------------------------------------- zoom controls
            if (widget.interactive)
              Positioned(
                right: 12,
                bottom: 12,
                child: Column(
                  children: <Widget>[
                    _MapControl(
                      icon: Icons.add_rounded,
                      tooltip: 'Zoom in',
                      isDark: isDark,
                      onTap: () => _changeZoom(0.2),
                    ),
                    const SizedBox(height: 8),
                    _MapControl(
                      icon: Icons.remove_rounded,
                      tooltip: 'Zoom out',
                      isDark: isDark,
                      onTap: () => _changeZoom(-0.2),
                    ),
                  ],
                ),
              ),

            // ------------------------------------------------ scale legend
            Positioned(
              left: 12,
              bottom: 12,
              child: _MapChip(
                icon: Icons.straighten_rounded,
                label: '± ${widget.accuracyMeters.toStringAsFixed(0)} m',
                isDark: isDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapChip extends StatelessWidget {
  const _MapChip({
    required this.icon,
    required this.label,
    required this.isDark,
    this.color,
  });

  final IconData icon;
  final String label;
  final bool isDark;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color background =
        color ??
        (isDark
            ? AppColors.surfaceDark.withValues(alpha: 0.92)
            : Colors.white.withValues(alpha: 0.92));
    final Color foreground = color != null
        ? Colors.white
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(30),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapControl extends StatelessWidget {
  const _MapControl({
    required this.icon,
    required this.onTap,
    required this.isDark,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: isDark
            ? AppColors.surfaceDark.withValues(alpha: 0.92)
            : Colors.white.withValues(alpha: 0.94),
        shape: const CircleBorder(),
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(
              icon,
              size: 19,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  const _MapPainter({
    required this.latitude,
    required this.longitude,
    required this.pulse,
    required this.isSharing,
    required this.isDark,
    required this.zoom,
  });

  final double latitude;
  final double longitude;
  final double pulse;
  final bool isSharing;
  final bool isDark;
  final double zoom;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect bounds = Offset.zero & size;

    // ------------------------------------------------------------ backdrop
    canvas.drawRect(
      bounds,
      Paint()
        ..color = isDark ? const Color(0xFF0E1830) : const Color(0xFFE9EDF3),
    );

    // The coordinates shift the grid, so the "map" visibly moves as the
    // simulated position changes.
    final double offsetX = (longitude * 9000) % 46;
    final double offsetY = (latitude * 9000) % 46;

    // ------------------------------------------------------- city blocks
    final Paint block = Paint()
      ..color = isDark ? const Color(0xFF15223E) : const Color(0xFFDDE3EC);
    final double blockSize = 46 * zoom;
    for (double x = -blockSize; x < size.width + blockSize; x += blockSize) {
      for (double y = -blockSize; y < size.height + blockSize; y += blockSize) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              x - offsetX + 4,
              y - offsetY + 4,
              blockSize - 10,
              blockSize - 10,
            ),
            const Radius.circular(3),
          ),
          block,
        );
      }
    }

    // ------------------------------------------------------------- streets
    final Paint street = Paint()
      ..color = isDark ? const Color(0xFF1E2C4C) : Colors.white
      ..strokeWidth = 5 * zoom;
    for (double x = -blockSize; x < size.width + blockSize; x += blockSize) {
      canvas.drawLine(
        Offset(x - offsetX, 0),
        Offset(x - offsetX, size.height),
        street,
      );
    }
    for (double y = -blockSize; y < size.height + blockSize; y += blockSize) {
      canvas.drawLine(
        Offset(0, y - offsetY),
        Offset(size.width, y - offsetY),
        street,
      );
    }

    // --------------------------------------------- one highlighted main road
    final Paint mainRoad = Paint()
      ..color = isDark ? const Color(0xFF2A3C63) : const Color(0xFFF7D9A0)
      ..strokeWidth = 11 * zoom;
    canvas.drawLine(
      Offset(0, size.height * 0.62),
      Offset(size.width, size.height * 0.48),
      mainRoad,
    );

    // ------------------------------------------------------ a green space
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.06,
          size.height * 0.10,
          size.width * 0.26,
          size.height * 0.24,
        ),
        const Radius.circular(10),
      ),
      Paint()
        ..color = (isDark ? AppColors.green : const Color(0xFF8FCBA6))
            .withValues(alpha: isDark ? 0.22 : 0.65),
    );

    // ------------------------------------------------------- water feature
    final Path water = Path()
      ..moveTo(size.width * 0.72, 0)
      ..quadraticBezierTo(
        size.width * 0.88,
        size.height * 0.34,
        size.width * 0.78,
        size.height,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(
      water,
      Paint()
        ..color = (isDark ? const Color(0xFF14325C) : const Color(0xFFAFD2F0))
            .withValues(alpha: isDark ? 0.55 : 0.75),
    );

    // -------------------------------------------------------- user marker
    final Offset centre = Offset(size.width * 0.46, size.height * 0.52);
    final Color accent = isSharing ? AppColors.red : AppColors.blue;

    // Accuracy circle.
    canvas.drawCircle(
      centre,
      34 * zoom,
      Paint()..color = accent.withValues(alpha: 0.14),
    );
    canvas.drawCircle(
      centre,
      34 * zoom,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = accent.withValues(alpha: 0.4),
    );

    // Live pulse rings, only while sharing.
    if (isSharing) {
      for (int i = 0; i < 2; i++) {
        final double t = (pulse + i * 0.5) % 1.0;
        canvas.drawCircle(
          centre,
          (18 + t * 48) * zoom,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.2
            ..color = accent.withValues(alpha: (1 - t) * 0.55),
        );
      }
    }

    // The marker itself.
    canvas.drawCircle(
      centre,
      13,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawCircle(centre, 12, Paint()..color = Colors.white);
    canvas.drawCircle(centre, 9, Paint()..color = accent);

    // A small heading arrow above the marker.
    final Path heading = Path()
      ..moveTo(centre.dx, centre.dy - 22)
      ..lineTo(centre.dx - 6, centre.dy - 13)
      ..lineTo(centre.dx + 6, centre.dy - 13)
      ..close();
    canvas.drawPath(heading, Paint()..color = accent.withValues(alpha: 0.85));

    // ------------------------------------------------- compass (top-right)
    final Offset compass = Offset(size.width - 34, size.height * 0.42);
    canvas.drawCircle(
      compass,
      13,
      Paint()
        ..color = (isDark ? AppColors.surfaceDark : Colors.white).withValues(
          alpha: 0.9,
        ),
    );
    final Path needle = Path()
      ..moveTo(compass.dx, compass.dy - 9)
      ..lineTo(compass.dx - 4, compass.dy + 3)
      ..lineTo(compass.dx + 4, compass.dy + 3)
      ..close();
    canvas.drawPath(needle, Paint()..color = AppColors.red);
    canvas.save();
    canvas.translate(compass.dx, compass.dy);
    canvas.rotate(math.pi);
    canvas.translate(-compass.dx, -compass.dy);
    canvas.drawPath(
      needle,
      Paint()
        ..color = (isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondary),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MapPainter oldDelegate) =>
      oldDelegate.latitude != latitude ||
      oldDelegate.longitude != longitude ||
      oldDelegate.pulse != pulse ||
      oldDelegate.isSharing != isSharing ||
      oldDelegate.isDark != isDark ||
      oldDelegate.zoom != zoom;
}
