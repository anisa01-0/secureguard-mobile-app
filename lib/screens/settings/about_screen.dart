import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../utils/app_routes.dart';
import '../../utils/responsive.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/section_header.dart';
import '../../widgets/sg_card.dart';
import '../../widgets/sg_logo.dart';

/// Product information, credits and an honest statement of scope.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const String version = '1.0.0';

  static const List<_Feature> _features = <_Feature>[
    _Feature(
      icon: Icons.emergency_share_rounded,
      title: 'Emergency SOS',
      description:
          'Press and hold, confirm during the countdown, and every trusted '
          'contact is alerted with your location.',
      color: AppColors.red,
    ),
    _Feature(
      icon: Icons.group_rounded,
      title: 'Trusted contacts',
      description:
          'Add, edit and prioritise the people who should be alerted first.',
      color: AppColors.green,
    ),
    _Feature(
      icon: Icons.location_on_rounded,
      title: 'Live location sharing',
      description:
          'Share where you are while you travel, and stop the moment you '
          'arrive safely.',
      color: AppColors.blue,
    ),
    _Feature(
      icon: Icons.local_police_rounded,
      title: 'Emergency services',
      description:
          'Police, ambulance, fire and hotline numbers, one tap from any '
          'screen.',
      color: AppColors.navy,
    ),
    _Feature(
      icon: Icons.history_rounded,
      title: 'Emergency history',
      description:
          'Every alert, share and check-in is recorded so you always have a '
          'record of what happened.',
      color: AppColors.amber,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double padding = Responsive.horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(title: const Text('About SecureGuard')),
      body: SafeArea(
        child: ResponsiveBody(
          child: ListView(
            padding: EdgeInsets.fromLTRB(padding, 10, padding, 32),
            children: <Widget>[
              // ---------------------------------------------- brand block
              SgCard(
                gradient: AppColors.brandGradient,
                borderColor: AppColors.navySoft,
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Column(
                  children: <Widget>[
                    const SgLogo(size: 76),
                    const SizedBox(height: 22),
                    const SgWordmark(
                      color: Colors.white,
                      fontSize: 30,
                      taglineColor: Color(0xCCFFFFFF),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text(
                        'Version $version  •  University Prototype',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ----------------------------------------------- what it is
              const SectionHeader(
                title: 'What SecureGuard does',
                icon: Icons.help_outline_rounded,
              ),
              SgCard(
                child: Text(
                  'SecureGuard is a personal safety application. It brings the '
                  'things you need during an emergency into one simple screen: '
                  'one button that alerts the people you trust, your live '
                  'location, direct numbers for the emergency services and a '
                  'record of everything that happened.\n\n'
                  'It is designed for students, commuters and anybody who '
                  'sometimes travels alone, at night, or through unfamiliar '
                  'areas.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ------------------------------------------------- features
              const SectionHeader(
                title: 'Main features',
                icon: Icons.auto_awesome_rounded,
              ),
              ..._features.map(
                (_Feature feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 11),
                  child: SgCard(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SgIconBadge(
                          icon: feature.icon,
                          color: feature.color,
                          size: 42,
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                feature.title,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontSize: 14.5,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                feature.description,
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

              // --------------------------------------------- scope notice
              const InlineBanner(
                title: 'This is a university prototype',
                message:
                    'SecureGuard was built as a final-year mobile application '
                    'project. It demonstrates the complete user experience of '
                    'a personal safety product, but it does not connect to '
                    'real emergency services, real SMS gateways or a real '
                    'server. Do not rely on it during a genuine emergency — '
                    'call your local emergency number instead.',
                icon: Icons.school_rounded,
                color: AppColors.amber,
              ),
              const SizedBox(height: 22),

              // ------------------------------------------------- project
              const SectionHeader(
                title: 'Project information',
                icon: Icons.badge_outlined,
              ),
              SgCard(
                child: Column(
                  children: <Widget>[
                    _AboutRow(label: 'Application', value: 'SecureGuard'),
                    const SizedBox(height: 12),
                    _AboutRow(label: 'Tagline', value: SgWordmark.tagline),
                    const SizedBox(height: 12),
                    _AboutRow(label: 'Version', value: version),
                    const SizedBox(height: 12),
                    _AboutRow(label: 'Platform', value: 'Flutter (Dart)'),
                    const SizedBox(height: 12),
                    _AboutRow(
                      label: 'Project type',
                      value: 'Final-year university project',
                    ),
                    const SizedBox(height: 12),
                    _AboutRow(
                      label: 'Data storage',
                      value: 'On this device only',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              OutlinedButton.icon(
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.privacy),
                icon: const Icon(Icons.privacy_tip_outlined),
                label: const Text('Read the privacy statement'),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Built with Flutter and Material 3.',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Feature {
  const _Feature({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
}

class _AboutRow extends StatelessWidget {
  const _AboutRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 108,
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
