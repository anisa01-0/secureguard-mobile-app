import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// A square shortcut used in the dashboard "Quick actions" grid.
///
/// Every tile shows an icon *and* a label, so the action is never conveyed by
/// colour or iconography alone.
class QuickActionTile extends StatelessWidget {
  const QuickActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  /// Optional short status shown under the label, e.g. "3 saved".
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final BorderRadius radius = BorderRadius.circular(AppTheme.radius);
    final Color accent = AppColors.adaptive(context, color);

    return Semantics(
      button: true,
      label: badge == null ? label : '$label, $badge',
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: theme.colorScheme.outline),
            ),
            // Only the label is `Flexible`: it is the one line that wraps, so
            // it absorbs whatever height is left over and shortens itself
            // rather than overflowing when the tile turns out to be short.
            // The badge keeps its natural height, otherwise the two would
            // halve the free space between them and both end up clipped.
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, color: accent, size: 22),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: Text(
                    label,
                    style: theme.textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (badge != null) ...<Widget>[
                  const SizedBox(height: 3),
                  Text(
                    badge!,
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
