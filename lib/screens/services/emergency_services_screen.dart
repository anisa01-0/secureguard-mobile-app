import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/demo_data.dart';
import '../../models/emergency_event.dart';
import '../../models/emergency_service.dart';
import '../../providers/emergency_provider.dart';
import '../../services/dialer_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/responsive.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/sg_card.dart';
import '../../widgets/status_pill.dart';

/// Public emergency services, grouped by category, each with a call button.
class EmergencyServicesScreen extends StatelessWidget {
  const EmergencyServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double padding = Responsive.horizontalPadding(context);
    final List<EmergencyService> services = DemoData.services;

    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Services')),
      body: SafeArea(
        child: ResponsiveBody(
          child: ListView(
            padding: EdgeInsets.fromLTRB(padding, 6, padding, 32),
            children: <Widget>[
              const _DemoNumbersBanner(),
              const SizedBox(height: 20),

              ...EmergencyServiceCategory.values.map((
                EmergencyServiceCategory category,
              ) {
                final List<EmergencyService> inCategory = services
                    .where((EmergencyService s) => s.category == category)
                    .toList();
                if (inCategory.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        SgIconBadge(
                          icon: category.icon,
                          color: category.color,
                          size: 32,
                          iconSize: 17,
                        ),
                        const SizedBox(width: 11),
                        Text(
                          category.label,
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...inCategory.map(
                      (EmergencyService service) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ServiceCard(service: service),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _DemoNumbersBanner extends StatelessWidget {
  const _DemoNumbersBanner();

  @override
  Widget build(BuildContext context) {
    return const InlineBanner(
      title: 'Demonstration numbers only',
      message:
          'The numbers on this screen are fictional placeholders chosen for '
          'the university demonstration, so nobody is called by mistake. A '
          'finished product would load the verified numbers for the user’s '
          'own country.',
      icon: Icons.info_outline_rounded,
      color: AppColors.amber,
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service});

  final EmergencyService service;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SgCard(
      padding: const EdgeInsets.all(15),
      semanticLabel: '${service.name}, ${service.phoneNumber}',
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SgIconBadge(
                icon: service.icon,
                color: service.color,
                size: 46,
                filled: true,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      service.name,
                      style: theme.textTheme.titleSmall?.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      service.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.phone_rounded,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          service.phoneNumber,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 10),
                        StatusPill(
                          label: service.availability,
                          color: AppColors.green,
                          icon: Icons.schedule_rounded,
                          dense: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: Tooltip(
              // The visible label stays short so it never wraps; the tooltip
              // and the card's semantics carry the full service name.
              message: 'Call ${service.name} on ${service.phoneNumber}',
              child: FilledButton.icon(
                onPressed: () => _call(context, service),
                style: FilledButton.styleFrom(
                  backgroundColor: service.color,
                  minimumSize: const Size.fromHeight(48),
                ),
                icon: const Icon(Icons.phone_in_talk_rounded, size: 20),
                label: const Text('Call now'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _call(BuildContext context, EmergencyService service) async {
    final bool confirmed = await AppFeedback.confirm(
      context,
      title: 'Call ${service.name}?',
      message:
          'SecureGuard will open your phone dialler with '
          '${service.phoneNumber}. You still choose when to press call.',
      confirmLabel: 'Open dialler',
      icon: Icons.phone_rounded,
    );
    if (!confirmed || !context.mounted) return;

    final DialResult result = await const DialerService().call(
      service.phoneNumber,
    );
    if (!context.mounted) return;

    // The call itself is recorded so it appears in the emergency history.
    context.read<EmergencyProvider>().logEvent(
      type: EmergencyEventType.serviceCall,
      note:
          'Opened the dialler for ${service.name} '
          '(${service.phoneNumber}).',
    );

    switch (result) {
      case DialResult.launched:
        AppFeedback.info(context, 'Opening the dialler…');
      case DialResult.unsupported:
        await AppFeedback.notice(
          context,
          title: 'Demo call',
          message:
              'This device cannot place phone calls, so nothing was dialled. '
              'On a phone SecureGuard would open the dialler with '
              '${service.phoneNumber}. The attempt has been added to your '
              'emergency history.',
          icon: Icons.phone_rounded,
          color: service.color,
        );
      case DialResult.failed:
        AppFeedback.error(context, 'The dialler could not be opened.');
    }
  }
}
