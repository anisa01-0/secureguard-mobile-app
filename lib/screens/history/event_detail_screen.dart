import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/emergency_event.dart';
import '../../providers/emergency_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../utils/responsive.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/mock_map.dart';
import '../../widgets/section_header.dart';
import '../../widgets/sg_card.dart';
import '../../widgets/status_pill.dart';

/// The full record of a single safety event.
class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key, required this.event});

  final EmergencyEvent event;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double padding = Responsive.horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        actions: <Widget>[
          IconButton(
            onPressed: () => _confirmDelete(context),
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Delete this event',
          ),
          SizedBox(width: padding - 12),
        ],
      ),
      body: SafeArea(
        child: ResponsiveBody(
          child: ListView(
            padding: EdgeInsets.fromLTRB(padding, 6, padding, 32),
            children: <Widget>[
              // ------------------------------------------------- headline
              SgCard(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    event.status.color.withValues(alpha: 0.13),
                    event.status.color.withValues(alpha: 0.04),
                  ],
                ),
                borderColor: event.status.color.withValues(alpha: 0.30),
                child: Row(
                  children: <Widget>[
                    SgIconBadge(
                      icon: event.type.icon,
                      color: event.status.color,
                      size: 52,
                      filled: true,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            event.type.label,
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            Formatters.weekday(event.startedAt),
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 9),
                          StatusPill(
                            label: event.status.label,
                            color: event.status.color,
                            icon: event.status.icon,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // ------------------------------------------------- timeline
              const SectionHeader(
                title: 'When it happened',
                icon: Icons.schedule_rounded,
              ),
              SgCard(
                child: Column(
                  children: <Widget>[
                    _DetailRow(
                      label: 'Date',
                      value: Formatters.fullDate(event.startedAt),
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      label: 'Started at',
                      value: Formatters.time(event.startedAt),
                    ),
                    if (event.endedAt != null) ...<Widget>[
                      const SizedBox(height: 12),
                      _DetailRow(
                        label: 'Ended at',
                        value: Formatters.time(event.endedAt!),
                      ),
                    ],
                    if (event.duration != null) ...<Widget>[
                      const SizedBox(height: 12),
                      _DetailRow(
                        label: 'Duration',
                        value: Formatters.readableDuration(event.duration!),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // ------------------------------------------------- location
              const SectionHeader(
                title: 'Where it happened',
                icon: Icons.place_rounded,
              ),
              MockMap(
                latitude: event.latitude,
                longitude: event.longitude,
                height: 190,
                interactive: false,
                accuracyMeters: 10,
              ),
              const SizedBox(height: 12),
              SgCard(
                child: Column(
                  children: <Widget>[
                    _DetailRow(label: 'Place', value: event.locationLabel),
                    const SizedBox(height: 12),
                    _DetailRow(
                      label: 'Coordinates',
                      value:
                          '${event.latitude.toStringAsFixed(6)}, '
                          '${event.longitude.toStringAsFixed(6)}',
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      label: 'Location shared',
                      value: event.locationShared ? 'Yes' : 'No',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // ------------------------------------------------- contacts
              SectionHeader(
                title: 'Contacts notified',
                subtitle: event.notifiedContactNames.isEmpty
                    ? 'Nobody was notified for this event'
                    : '${event.notifiedContactNames.length} people were '
                          'alerted',
                icon: Icons.group_rounded,
              ),
              SgCard(
                child: event.notifiedContactNames.isEmpty
                    ? Row(
                        children: <Widget>[
                          Icon(
                            Icons.person_off_outlined,
                            size: 19,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              event.status == EmergencyEventStatus.cancelled
                                  ? 'The alert was cancelled before any '
                                        'contact was notified.'
                                  : 'No trusted contact was notified for this '
                                        'event.',
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: event.notifiedContactNames
                            .map(
                              (String name) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  children: <Widget>[
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      size: 18,
                                      color: AppColors.green,
                                    ),
                                    const SizedBox(width: 11),
                                    Expanded(
                                      child: Text(
                                        name,
                                        style: theme.textTheme.bodyLarge
                                            ?.copyWith(fontSize: 14.5),
                                      ),
                                    ),
                                    Text(
                                      'Notified',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            fontSize: 12,
                                            color: AppColors.green,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
              ),

              // ----------------------------------------------------- note
              if (event.note.isNotEmpty) ...<Widget>[
                const SizedBox(height: 22),
                const SectionHeader(
                  title: 'Notes',
                  icon: Icons.sticky_note_2_outlined,
                ),
                SgCard(
                  child: Text(
                    event.note,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final bool confirmed = await AppFeedback.confirm(
      context,
      title: 'Delete this event?',
      message:
          'This record will be permanently removed from your emergency '
          'history.',
      confirmLabel: 'Delete',
      destructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (!confirmed || !context.mounted) return;

    context.read<EmergencyProvider>().deleteEvent(event.id);
    Navigator.of(context).pop();
    AppFeedback.info(context, 'Event removed from your history.');
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 118,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 13),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
