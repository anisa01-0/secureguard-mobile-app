import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

/// The press-and-hold emergency button.
///
/// The user must keep their finger down for [holdDuration] (3 seconds by
/// default) before [onActivate] fires. Requiring a deliberate hold is the
/// main protection against accidental activation, and the ring that fills
/// around the button tells the user exactly how much longer to hold.
class SosButton extends StatefulWidget {
  const SosButton({
    super.key,
    required this.onActivate,
    this.size = 196,
    this.holdDuration = const Duration(seconds: 3),
    this.enabled = true,
    this.label = 'HOLD FOR SOS',
  });

  final VoidCallback onActivate;
  final double size;
  final Duration holdDuration;
  final bool enabled;
  final String label;

  @override
  State<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton> with TickerProviderStateMixin {
  /// Fills while the button is held down.
  late final AnimationController _hold = AnimationController(
    vsync: this,
    duration: widget.holdDuration,
  )..addStatusListener(_onHoldStatusChanged);

  /// Runs forever, driving the calm outer pulse.
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat();

  bool _pressed = false;
  int _lastHapticStep = 0;

  void _onHoldStatusChanged(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    HapticFeedback.heavyImpact();
    setState(() => _pressed = false);
    _hold.reset();
    _lastHapticStep = 0;
    widget.onActivate();
  }

  @override
  void initState() {
    super.initState();
    // One light tap for every whole second the user keeps holding.
    _hold.addListener(() {
      final int step = (_hold.value * widget.holdDuration.inSeconds).floor();
      if (step != _lastHapticStep && step > 0) {
        _lastHapticStep = step;
        HapticFeedback.selectionClick();
      }
    });
  }

  @override
  void dispose() {
    _hold.dispose();
    _pulse.dispose();
    super.dispose();
  }

  void _start() {
    if (!widget.enabled) return;
    HapticFeedback.mediumImpact();
    setState(() => _pressed = true);
    _hold.forward(from: 0);
  }

  void _stop() {
    if (!_pressed) return;
    setState(() => _pressed = false);
    _lastHapticStep = 0;
    _hold.reverse();
  }

  /// Keyboard and screen-reader users activate the button with a single tap.
  void _activateFromAssistiveTechnology() {
    if (!widget.enabled) return;
    HapticFeedback.heavyImpact();
    widget.onActivate();
  }

  @override
  Widget build(BuildContext context) {
    final double outer = widget.size;
    final double inner = widget.size * 0.72;

    return Semantics(
      button: true,
      enabled: widget.enabled,
      label: 'Emergency S O S',
      hint: 'Press and hold for three seconds to send an emergency alert',
      onTap: _activateFromAssistiveTechnology,
      child: GestureDetector(
        onTapDown: (_) => _start(),
        onTapUp: (_) => _stop(),
        onTapCancel: _stop,
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: SizedBox(
            width: outer,
            height: outer,
            child: AnimatedBuilder(
              animation: Listenable.merge(<Listenable>[_hold, _pulse]),
              builder: (BuildContext context, Widget? child) {
                return CustomPaint(
                  painter: _SosRingPainter(
                    progress: _hold.value,
                    pulse: _pulse.value,
                    enabled: widget.enabled,
                    pressed: _pressed,
                  ),
                  child: Center(
                    child: Container(
                      width: inner,
                      height: inner,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: widget.enabled
                            ? AppColors.emergencyGradient
                            : const LinearGradient(
                                colors: <Color>[
                                  Color(0xFF9AA2B1),
                                  Color(0xFF7C8494),
                                ],
                              ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color:
                                (widget.enabled ? AppColors.red : Colors.black)
                                    .withValues(alpha: _pressed ? 0.48 : 0.30),
                            blurRadius: _pressed ? 34 : 24,
                            spreadRadius: _pressed ? 2 : 0,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: child,
                    ),
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.emergency_share_rounded,
                    color: Colors.white,
                    size: widget.size * 0.20,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: widget.size * 0.082,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SosRingPainter extends CustomPainter {
  const _SosRingPainter({
    required this.progress,
    required this.pulse,
    required this.enabled,
    required this.pressed,
  });

  /// 0.0 .. 1.0 hold progress.
  final double progress;

  /// 0.0 .. 1.0 continuous pulse animation value.
  final double pulse;
  final bool enabled;
  final bool pressed;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset centre = size.center(Offset.zero);
    final double radius = size.width / 2;
    final Color base = enabled ? AppColors.red : const Color(0xFF8B93A3);

    // ------------------------------------------------- calm outward pulse
    if (!pressed) {
      for (int i = 0; i < 2; i++) {
        final double t = (pulse + i * 0.5) % 1.0;
        final double r = radius * (0.76 + t * 0.24);
        canvas.drawCircle(
          centre,
          r,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = base.withValues(alpha: (1 - t) * 0.30),
        );
      }
    }

    // ------------------------------------------------------- track + fill
    final double ringRadius = radius - 8;
    canvas.drawCircle(
      centre,
      ringRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..color = base.withValues(alpha: 0.16),
    );

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: centre, radius: ringRadius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round
          ..color = base,
      );
    }
  }

  @override
  bool shouldRepaint(_SosRingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.pulse != pulse ||
      oldDelegate.pressed != pressed ||
      oldDelegate.enabled != enabled;
}
