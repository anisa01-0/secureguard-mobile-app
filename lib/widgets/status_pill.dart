import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A small pill that pairs an icon with a label.
///
/// Status is never shown with colour alone - every pill also carries an icon
/// and a word, so the meaning is clear to users who cannot distinguish the
/// colours.
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    required this.color,
    required this.icon,
    this.dense = false,
    this.filled = false,
  });

  final String label;
  final Color color;
  final IconData icon;
  final bool dense;

  /// A filled pill uses the colour as the background (white text).
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final double fontSize = dense ? 11.5 : 12.5;
    final Color color = AppColors.adaptive(context, this.color);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 9 : 11,
        vertical: dense ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: filled ? color : color.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            size: dense ? 13 : 15,
            color: filled ? Colors.white : color,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: filled ? Colors.white : color,
            ),
          ),
        ],
      ),
    );
  }
}

/// A pulsing dot used next to "live" states such as active location sharing.
class LiveDot extends StatefulWidget {
  const LiveDot({super.key, required this.color, this.size = 9});

  final Color color;
  final double size;

  @override
  State<LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<LiveDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(
        begin: 0.35,
        end: 1,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: widget.color.withValues(alpha: 0.5),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}
