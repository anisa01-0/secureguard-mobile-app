import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_notification.dart';
import '../../providers/notifications_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../utils/responsive.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/sg_card.dart';

/// The notification centre.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final NotificationsProvider notifications = context
        .watch<NotificationsProvider>();
    final List<AppNotification> items = notifications.items;
    final double padding = Responsive.horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: <Widget>[
          if (notifications.hasUnread)
            TextButton(
              onPressed: notifications.markAllAsRead,
              child: const Text('Mark all read'),
            ),
          if (items.isNotEmpty)
            IconButton(
              onPressed: () => _confirmClear(context),
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear notifications',
            ),
          SizedBox(width: padding - 12),
        ],
      ),
      body: SafeArea(
        child: ResponsiveBody(
          child: items.isEmpty
              ? const EmptyState(
                  icon: Icons.notifications_off_outlined,
                  title: 'No notifications',
                  message:
                      'Alerts, location updates and safety reminders will '
                      'appear here as you use SecureGuard.',
                )
              : ListView(
                  padding: EdgeInsets.fromLTRB(padding, 6, padding, 28),
                  children: <Widget>[
                    if (notifications.hasUnread) ...<Widget>[
                      Text(
                        '${notifications.unreadCount} unread',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.blue,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    ...items.map(
                      (AppNotification item) => Padding(
                        padding: const EdgeInsets.only(bottom: 11),
                        child: _NotificationTile(
                          notification: item,
                          onTap: () => notifications.markAsRead(item.id),
                          onDismiss: () => _dismiss(context, item),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void _dismiss(BuildContext context, AppNotification item) {
    context.read<NotificationsProvider>().remove(item.id);
    AppFeedback.info(context, 'Notification removed.');
  }

  Future<void> _confirmClear(BuildContext context) async {
    final bool confirmed = await AppFeedback.confirm(
      context,
      title: 'Clear all notifications?',
      message: 'Every notification will be removed from this device.',
      confirmLabel: 'Clear all',
      destructive: true,
      icon: Icons.delete_sweep_rounded,
    );
    if (!confirmed || !context.mounted) return;
    context.read<NotificationsProvider>().clearAll();
    AppFeedback.info(context, 'All notifications cleared.');
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool unread = !notification.isRead;

    return Dismissible(
      key: ValueKey<String>(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 22),
        decoration: BoxDecoration(
          color: AppColors.red.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text(
              'Remove',
              style: TextStyle(
                color: AppColors.red,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.delete_outline_rounded, color: AppColors.red),
          ],
        ),
      ),
      child: SgCard(
        onTap: onTap,
        padding: const EdgeInsets.all(15),
        borderColor: unread
            ? notification.type.color.withValues(alpha: 0.38)
            : theme.colorScheme.outline,
        semanticLabel:
            '${unread ? 'Unread. ' : ''}'
            '${notification.title}. ${notification.message}',
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SgIconBadge(
              icon: notification.type.icon,
              color: notification.type.color,
              size: 42,
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          notification.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontSize: 14.5,
                            fontWeight: unread
                                ? FontWeight.w800
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                      if (unread) ...<Widget>[
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: notification.type.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.schedule_rounded,
                        size: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        Formatters.relative(notification.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11.5,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        notification.type.label,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: notification.type.color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
