import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../utils/responsive.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/section_header.dart';
import '../../widgets/sg_card.dart';

/// A plain-English statement of what the app stores and what it does not.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  static const List<_DataItem> _collected = <_DataItem>[
    _DataItem(
      icon: Icons.person_outline_rounded,
      title: 'Your name, email and phone number',
      reason:
          'So your trusted contacts recognise who is asking for help, and so '
          'you can sign back in.',
    ),
    _DataItem(
      icon: Icons.group_outlined,
      title: 'Your trusted contacts',
      reason: 'So SecureGuard knows who to alert when you press SOS.',
    ),
    _DataItem(
      icon: Icons.location_on_outlined,
      title: 'Your position, while the app is open',
      reason:
          'So your contacts can find you. Sharing only runs when you start it '
          'or when an SOS alert is active.',
    ),
    _DataItem(
      icon: Icons.history_rounded,
      title: 'Your emergency history',
      reason:
          'So you have a record of what happened, which can matter later when '
          'reporting an incident.',
    ),
  ];

  static const List<String> _notCollected = <String>[
    'No microphone, camera or photo access',
    'No contact-list scraping from your phone',
    'No advertising identifiers or tracking',
    'No analytics or usage profiling',
    'No sharing or selling of data to anyone',
    'No background location when the app is closed',
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double padding = Responsive.horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & Data')),
      body: SafeArea(
        child: ResponsiveBody(
          child: ListView(
            padding: EdgeInsets.fromLTRB(padding, 10, padding, 32),
            children: <Widget>[
              SgCard(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    AppColors.blue.withValues(alpha: 0.13),
                    AppColors.blue.withValues(alpha: 0.04),
                  ],
                ),
                borderColor: AppColors.blue.withValues(alpha: 0.30),
                child: Row(
                  children: <Widget>[
                    const SgIconBadge(
                      icon: Icons.lock_rounded,
                      color: AppColors.blue,
                      size: 50,
                      filled: true,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Everything stays on this device',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'This prototype has no server. Nothing you enter '
                            'leaves your phone.',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const SectionHeader(
                title: 'What SecureGuard stores',
                icon: Icons.inventory_2_outlined,
              ),
              ..._collected.map(
                (_DataItem item) => Padding(
                  padding: const EdgeInsets.only(bottom: 11),
                  child: SgCard(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SgIconBadge(
                          icon: item.icon,
                          color: AppColors.navy,
                          size: 40,
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                item.title,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                item.reason,
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              const SectionHeader(
                title: 'What SecureGuard never does',
                icon: Icons.block_rounded,
              ),
              SgCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _notCollected
                      .map(
                        (String item) => Padding(
                          padding: const EdgeInsets.only(bottom: 11),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Icon(
                                Icons.do_not_disturb_on_outlined,
                                size: 18,
                                color: AppColors.green,
                              ),
                              const SizedBox(width: 11),
                              Expanded(
                                child: Text(
                                  item,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 14,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 24),

              const SectionHeader(
                title: 'Your control',
                icon: Icons.tune_rounded,
              ),
              SgCard(
                child: Text(
                  'You can delete any trusted contact, clear your entire '
                  'emergency history, remove every notification and switch the '
                  'location permission off at any time from Settings. '
                  'Uninstalling the application removes all of it from your '
                  'device permanently.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const SectionHeader(
                title: 'Honest security statement',
                icon: Icons.shield_outlined,
              ),
              const InlineBanner(
                title: 'This prototype is not production-secure',
                message:
                    'Account details are saved in ordinary device storage and '
                    'passwords are not hashed. There is no encryption at rest, '
                    'no server-side authentication and no penetration testing. '
                    'A real release would add hashed credentials, encrypted '
                    'storage, a secure backend and an independent security '
                    'review before anybody relied on it.',
                icon: Icons.warning_amber_rounded,
                color: AppColors.amber,
              ),
              const SizedBox(height: 14),
              SgCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'What the prototype does protect',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 10),
                    ..._protections.map(
                      (String item) => Padding(
                        padding: const EdgeInsets.only(bottom: 9),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Icon(
                              Icons.check_circle_outline_rounded,
                              size: 17,
                              color: AppColors.green,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                item,
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const List<String> _protections = <String>[
    'Every form validates input before it is accepted',
    'Passwords are hidden by default with a show/hide control',
    'A minimum password strength is enforced at registration',
    'SOS needs a deliberate 3-second hold plus a countdown, so it cannot '
        'fire by accident',
    'Location sharing never starts silently — you always confirm it',
    'Trusted contacts can be hidden from lock-screen previews',
  ];
}

class _DataItem {
  const _DataItem({
    required this.icon,
    required this.title,
    required this.reason,
  });

  final IconData icon;
  final String title;
  final String reason;
}
