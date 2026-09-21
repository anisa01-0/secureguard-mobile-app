import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Consistent snack bars and dialogs.
///
/// Centralising them means every message in the application uses the same
/// wording style, the same icons and the same colours.
class AppFeedback {
  const AppFeedback._();

  static void success(BuildContext context, String message) =>
      _show(context, message, AppColors.green, Icons.check_circle_rounded);

  static void info(BuildContext context, String message) =>
      _show(context, message, AppColors.blue, Icons.info_rounded);

  static void warning(BuildContext context, String message) =>
      _show(context, message, AppColors.amber, Icons.warning_amber_rounded);

  static void error(BuildContext context, String message) =>
      _show(context, message, AppColors.red, Icons.error_rounded);

  static void _show(
    BuildContext context,
    String message,
    Color color,
    IconData icon,
  ) {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          content: Row(
            children: <Widget>[
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
  }

  /// A yes/no dialog. Returns `true` only when the user confirms.
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool destructive = false,
    IconData icon = Icons.help_outline_rounded,
  }) async {
    final Color accent = destructive ? AppColors.red : AppColors.blue;

    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        icon: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: accent, size: 27),
        ),
        title: Text(title, textAlign: TextAlign.center),
        content: Text(message, textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.center,
        actions: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Text(cancelLabel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: accent,
                  ),
                  child: Text(confirmLabel),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// An informational dialog with a single "Got it" button.
  static Future<void> notice(
    BuildContext context, {
    required String title,
    required String message,
    IconData icon = Icons.info_rounded,
    Color color = AppColors.blue,
    String buttonLabel = 'Got it',
  }) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        icon: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 27),
        ),
        title: Text(title, textAlign: TextAlign.center),
        content: Text(message, textAlign: TextAlign.center),
        actions: <Widget>[
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: color,
            ),
            child: Text(buttonLabel),
          ),
        ],
      ),
    );
  }
}

/// A full-width banner used to explain a blocking condition inside a screen,
/// for example "You have not added a trusted contact yet".
class InlineBanner extends StatelessWidget {
  const InlineBanner({
    super.key,
    required this.message,
    required this.icon,
    required this.color,
    this.title,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? title;
  final IconData icon;
  final Color color;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall + 2),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (title != null) ...<Widget>[
                  Text(
                    title!,
                    style: theme.textTheme.titleSmall?.copyWith(color: color),
                  ),
                  const SizedBox(height: 3),
                ],
                Text(message, style: theme.textTheme.bodySmall),
                if (actionLabel != null && onAction != null) ...<Widget>[
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: onAction,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 34),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: color,
                    ),
                    child: Text(actionLabel!),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
