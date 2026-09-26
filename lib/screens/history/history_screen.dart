import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/emergency_event.dart';
import '../../providers/emergency_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../utils/responsive.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/sg_card.dart';
import '../../widgets/status_pill.dart';
import 'event_detail_screen.dart';

/// A filterable log of every safety event recorded by the application.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  /// `null` means "All".
  EmergencyEventType? _filter;

  List<EmergencyEvent> _applyFilter(List<EmergencyEvent> events) {
    if (_filter == null) return events;
    return events
        .where((EmergencyEvent e) => e.type == _filter)
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EmergencyProvider emergency = context.watch<EmergencyProvider>();
    final List<EmergencyEvent> all = emergency.history;
    final List<EmergencyEvent> events = _applyFilter(all);
    final double padding = Responsive.horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency History'),
        actions: <Widget>[
          if (all.isNotEmpty)
            IconButton(
              onPressed: () => _confirmClear(context),
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear history',
            ),
          SizedBox(width: padding - 12),
        ],
      ),
      body: SafeArea(
        child: ResponsiveBody(
          child: Column(
            children: <Widget>[
              if (all.isNotEmpty) ...<Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(padding, 4, padding, 0),
                  child: _HistorySummary(
                    total: all.length,
                    alerts: emergency.totalAlerts,
                    resolved: emergency.resolvedCount,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    children: <Widget>[
                      _FilterChip(
                        key: const ValueKey<String>('history-filter-all'),
                        label: 'All',
                        icon: Icons.all_inbox_rounded,
                        selected: _filter == null,
                        onTap: () => setState(() => _filter = null),
                      ),
                      ...EmergencyEventType.values.map(
                        (EmergencyEventType type) => _FilterChip(
                          key: ValueKey<String>('history-filter-${type.name}'),
                          label: type.label,
                          icon: type.icon,
                          selected: _filter == type,
                          onTap: () => setState(() => _filter = type),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Expanded(
                child: all.isEmpty
                    ? const EmptyState(
                        icon: Icons.history_rounded,
                        title: 'No safety events yet',
                        message:
                            'Every SOS alert, location share and check-in you '
                            'make is recorded here so you always have a '
                            'record of what happened.',
                      )
                    : events.isEmpty
                    ? EmptyState(
                        icon: Icons.filter_alt_off_rounded,
                        title: 'Nothing in this category',
                        message:
                            'There are no "${_filter?.label}" events yet. '
                            'Choose a different filter to see more.',
                        compact: true,
                      )
                    : ListView.separated(
                        padding: EdgeInsets.fromLTRB(padding, 4, padding, 28),
                        itemCount: events.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (BuildContext context, int index) =>
                            _HistoryTile(
                              event: events[index],
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      EventDetailScreen(event: events[index]),
                                ),
                              ),
                            ),
                      ),
              ),
              if (all.isNotEmpty)
                Padding(
                  padding: EdgeInsets.fromLTRB(padding, 0, padding, 10),
                  child: Text(
                    'Showing ${events.length} of ${all.length} events',
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final bool confirmed = await AppFeedback.confirm(
      context,
      title: 'Clear your history?',
      message:
          'Every recorded safety event will be permanently removed from this '
          'device. This cannot be undone.',
      confirmLabel: 'Clear all',
      destructive: true,
      icon: Icons.delete_sweep_rounded,
    );
    if (!confirmed || !context.mounted) return;
    context.read<EmergencyProvider>().clearHistory();
    AppFeedback.info(context, 'Emergency history cleared.');
  }
}

class _HistorySummary extends StatelessWidget {
  const _HistorySummary({
    required this.total,
    required this.alerts,
    required this.resolved,
  });

  final int total;
  final int alerts;
  final int resolved;

  @override
  Widget build(BuildContext context) {
    return SgCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Row(
        children: <Widget>[
          _SummaryCell(
            value: '$total',
            label: 'Events',
            color: AppColors.navy,
            icon: Icons.list_alt_rounded,
          ),
          const _SummaryDivider(),
          _SummaryCell(
            value: '$alerts',
            label: 'SOS alerts',
            color: AppColors.red,
            icon: Icons.emergency_share_rounded,
          ),
          const _SummaryDivider(),
          _SummaryCell(
            value: '$resolved',
            label: 'Resolved',
            color: AppColors.green,
            icon: Icons.check_circle_rounded,
          ),
        ],
      ),
    );
  }
}

class _SummaryDivider extends StatelessWidget {
  const _SummaryDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: Theme.of(context).colorScheme.outline,
    );
  }
}

class _SummaryCell extends StatelessWidget {
  const _SummaryCell({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  final String value;
  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: <Widget>[
          Icon(icon, size: 19, color: color),
          const SizedBox(height: 7),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 11.5),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color accent = AppColors.adaptive(context, AppColors.navy);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: selected ? accent : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: selected ? accent : theme.colorScheme.outline,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  icon,
                  size: 15,
                  color: selected
                      ? Colors.white
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? Colors.white
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.event, required this.onTap});

  final EmergencyEvent event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SgCard(
      onTap: onTap,
      padding: const EdgeInsets.all(15),
      semanticLabel:
          '${event.type.label}, '
          '${Formatters.dateAndTime(event.startedAt)}, '
          '${event.status.label}',
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              SgIconBadge(
                icon: event.type.icon,
                color: event.status.color,
                size: 44,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      event.type.label,
                      style: theme.textTheme.titleSmall?.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${Formatters.fullDate(event.startedAt)} • '
                      '${Formatters.time(event.startedAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              StatusPill(
                label: event.status.label,
                color: event.status.color,
                icon: event.status.icon,
                dense: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Icon(
                Icons.place_rounded,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  event.locationLabel,
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 12.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (event.locationShared) ...<Widget>[
                const SizedBox(width: 8),
                const StatusPill(
                  label: 'Location shared',
                  color: AppColors.blue,
                  icon: Icons.my_location_rounded,
                  dense: true,
                ),
              ],
            ],
          ),
          if (event.notifiedContactNames.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Icon(
                  Icons.group_rounded,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${event.notifiedContactNames.length} '
                    '${event.notifiedContactNames.length == 1 ? 'contact' : 'contacts'}'
                    ' notified: ${event.notifiedContactNames.join(', ')}',
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 12.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
