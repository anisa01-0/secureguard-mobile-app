import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// The standard SecureGuard surface: rounded, outlined, softly shadowed.
///
/// Used by almost every screen so spacing and elevation stay consistent.
class SgCard extends StatelessWidget {
  const SgCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.color,
    this.borderColor,
    this.gradient,
    this.elevated = true,
    this.semanticLabel,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final Gradient? gradient;
  final bool elevated;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final BorderRadius radius = BorderRadius.circular(AppTheme.radius);

    Widget content = Container(
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? scheme.surface) : null,
        gradient: gradient,
        borderRadius: radius,
        border: Border.all(color: borderColor ?? scheme.outline),
        boxShadow: elevated
            ? <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: Theme.of(context).brightness == Brightness.dark
                        ? 0.24
                        : 0.05,
                  ),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );

    if (semanticLabel != null) {
      content = Semantics(
        label: semanticLabel,
        button: onTap != null,
        container: true,
        child: content,
      );
    }
    return content;
  }
}

/// A rounded icon badge used inside cards and list tiles.
class SgIconBadge extends StatelessWidget {
  const SgIconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.size = 44,
    this.iconSize,
    this.filled = false,
  });

  final IconData icon;
  final Color color;
  final double size;
  final double? iconSize;

  /// When true the badge uses a solid brand colour instead of a soft tint.
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final Color accent = AppColors.adaptive(context, color);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: filled ? accent : accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Icon(
        icon,
        size: iconSize ?? size * 0.50,
        color: filled ? Colors.white : accent,
      ),
    );
  }
}
