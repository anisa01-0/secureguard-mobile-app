import 'package:flutter/material.dart';

/// A friendly placeholder shown whenever a list has no items yet.
///
/// Every empty screen in SecureGuard explains what is missing and offers the
/// action that fixes it, so the user is never left on a blank page.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.iconColor,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color color = iconColor ?? theme.colorScheme.secondary;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 28,
          vertical: compact ? 18 : 36,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: compact ? 62 : 86,
              height: compact ? 62 : 86,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: compact ? 28 : 40, color: color),
            ),
            SizedBox(height: compact ? 14 : 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            if (actionLabel != null && onAction != null) ...<Widget>[
              SizedBox(height: compact ? 16 : 24),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded),
                label: Text(actionLabel!),
                style: FilledButton.styleFrom(minimumSize: const Size(220, 50)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
