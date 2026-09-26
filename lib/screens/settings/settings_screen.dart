import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/contacts_provider.dart';
import '../../providers/emergency_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/notifications_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/app_routes.dart';
import '../../utils/responsive.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/section_header.dart';
import '../../widgets/sg_card.dart';
import '../home/root_shell.dart';
import '../profile/profile_screen.dart';

/// Every preference in one place: alerts, permissions, appearance, account.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsProvider settings = context.watch<SettingsProvider>();
    final ContactsProvider contacts = context.watch<ContactsProvider>();
    final double padding = Responsive.horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ResponsiveBody(
          child: ListView(
            padding: EdgeInsets.fromLTRB(padding, 6, padding, 32),
            children: <Widget>[
              // ------------------------------------------- notifications
              const SectionHeader(
                title: 'Notifications',
                icon: Icons.notifications_none_rounded,
              ),
              SgCard(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: <Widget>[
                    _SwitchRow(
                      icon: Icons.notifications_active_outlined,
                      color: AppColors.blue,
                      title: 'Allow notifications',
                      subtitle:
                          'Alerts, location updates and safety reminders.',
                      value: settings.notificationsEnabled,
                      onChanged: (bool value) {
                        settings.setNotificationsEnabled(value);
                        AppFeedback.info(
                          context,
                          value
                              ? 'Notifications turned on.'
                              : 'Notifications turned off.',
                        );
                      },
                    ),
                    _SwitchRow(
                      icon: Icons.volume_up_outlined,
                      color: AppColors.red,
                      title: 'Emergency sound',
                      subtitle:
                          'Play a loud siren when an SOS alert is activated.',
                      value: settings.emergencySoundEnabled,
                      onChanged: settings.setEmergencySoundEnabled,
                      showDivider: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ------------------------------------ location & emergency
              const SectionHeader(
                title: 'Location & emergency',
                icon: Icons.location_on_outlined,
              ),
              SgCard(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: <Widget>[
                    _SwitchRow(
                      icon: Icons.my_location_outlined,
                      color: AppColors.green,
                      title: 'Location permission',
                      subtitle: settings.locationPermissionGranted
                          ? 'SecureGuard can read your position.'
                          : 'Your position is unavailable to the app.',
                      value: settings.locationPermissionGranted,
                      onChanged: (bool value) {
                        settings.setLocationPermissionGranted(value);
                        context.read<LocationProvider>().setPermissionGranted(
                          value,
                        );
                        AppFeedback.info(
                          context,
                          value
                              ? 'Location permission granted.'
                              : 'Location permission removed. Sharing stopped.',
                        );
                      },
                    ),
                    _SwitchRow(
                      icon: Icons.share_location_outlined,
                      color: AppColors.blue,
                      title: 'Share location during SOS',
                      subtitle:
                          'Start live sharing automatically when an alert is '
                          'sent.',
                      value: settings.autoShareLocationOnSos,
                      onChanged: settings.locationPermissionGranted
                          ? settings.setAutoShareLocationOnSos
                          : null,
                    ),
                    _NavRow(
                      icon: Icons.timer_outlined,
                      color: AppColors.amber,
                      title: 'SOS countdown',
                      subtitle:
                          '${settings.sosCountdownSeconds} seconds before the '
                          'alert is sent',
                      onTap: () => _pickCountdown(context, settings),
                    ),
                    _NavRow(
                      icon: Icons.group_outlined,
                      color: AppColors.navy,
                      title: 'Emergency contacts',
                      subtitle:
                          '${contacts.count} trusted '
                          '${contacts.count == 1 ? 'contact' : 'contacts'} '
                          'saved',
                      onTap: () {
                        Navigator.of(context).pop();
                        RootShell.goToTab(context, 1);
                      },
                      showDivider: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ---------------------------------------------- appearance
              const SectionHeader(
                title: 'Appearance & language',
                icon: Icons.palette_outlined,
              ),
              SgCard(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: <Widget>[
                    _SwitchRow(
                      icon: settings.isDarkMode
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      color: AppColors.navySoft,
                      title: 'Dark mode',
                      subtitle: settings.isDarkMode
                          ? 'Easier on the eyes at night.'
                          : 'Bright theme for daytime use.',
                      value: settings.isDarkMode,
                      onChanged: settings.setDarkMode,
                    ),
                    _NavRow(
                      icon: Icons.translate_rounded,
                      color: AppColors.green,
                      title: 'Language',
                      subtitle: settings.language.label,
                      onTap: () => _pickLanguage(context, settings),
                      showDivider: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ----------------------------------------- privacy/account
              const SectionHeader(
                title: 'Privacy & account',
                icon: Icons.shield_outlined,
              ),
              SgCard(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: <Widget>[
                    _SwitchRow(
                      icon: Icons.visibility_off_outlined,
                      color: AppColors.amber,
                      title: 'Hide contacts on lock screen',
                      subtitle:
                          'Keep your trusted contacts out of notification '
                          'previews.',
                      value: settings.hideContactsOnLockScreen,
                      onChanged: settings.setHideContactsOnLockScreen,
                    ),
                    _NavRow(
                      icon: Icons.lock_outline_rounded,
                      color: AppColors.navy,
                      title: 'Change password',
                      subtitle: 'Update the password for your account',
                      onTap: () =>
                          Navigator.of(context)
                              .pushNamed(AppRoutes.changePassword),
                    ),
                    _NavRow(
                      icon: Icons.privacy_tip_outlined,
                      color: AppColors.blue,
                      title: 'Privacy & data',
                      subtitle: 'What SecureGuard stores, and where',
                      onTap: () =>
                          Navigator.of(context).pushNamed(AppRoutes.privacy),
                    ),
                    _NavRow(
                      icon: Icons.info_outline_rounded,
                      color: AppColors.navySoft,
                      title: 'About SecureGuard',
                      subtitle: 'Version, purpose and project information',
                      onTap: () =>
                          Navigator.of(context).pushNamed(AppRoutes.about),
                      showDivider: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ------------------------------------------ demo utilities
              const SectionHeader(
                title: 'Demonstration tools',
                subtitle: 'Useful when presenting the project',
                icon: Icons.science_outlined,
              ),
              SgCard(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: _NavRow(
                  icon: Icons.restart_alt_rounded,
                  color: AppColors.amber,
                  title: 'Reset demo data',
                  subtitle:
                      'Restore the sample contacts, history and notifications',
                  onTap: () => _confirmReset(context),
                  showDivider: false,
                ),
              ),
              const SizedBox(height: 24),

              OutlinedButton.icon(
                onPressed: () => ProfileScreen.confirmLogout(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.red,
                  side: BorderSide(
                    color: AppColors.red.withValues(alpha: 0.42),
                    width: 1.4,
                  ),
                ),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Log out'),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'SecureGuard v1.0.0 • University Prototype',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickCountdown(
    BuildContext context,
    SettingsProvider settings,
  ) async {
    const List<int> options = <int>[3, 5, 10, 15];
    final int? chosen = await showModalBottomSheet<int>(
      context: context,
      builder: (BuildContext sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 18),
            Text(
              'SOS countdown',
              style: Theme.of(sheetContext).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'How long you have to cancel an alert before it is sent.',
                textAlign: TextAlign.center,
                style: Theme.of(sheetContext).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 14),
            ...options.map(
              (int seconds) => _ChoiceRow(
                title: '$seconds seconds',
                subtitle: switch (seconds) {
                  3 => 'Fastest — for urgent situations',
                  5 => 'Recommended balance',
                  10 => 'More time to cancel by mistake',
                  _ => 'Maximum time to reconsider',
                },
                selected: settings.sosCountdownSeconds == seconds,
                onTap: () => Navigator.of(sheetContext).pop(seconds),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );

    if (chosen == null || !context.mounted) return;
    settings.setSosCountdownSeconds(chosen);
    AppFeedback.success(context, 'SOS countdown set to $chosen seconds.');
  }

  Future<void> _pickLanguage(
    BuildContext context,
    SettingsProvider settings,
  ) async {
    final AppLanguage? chosen = await showModalBottomSheet<AppLanguage>(
      context: context,
      builder: (BuildContext sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 18),
            Text(
              'Interface language',
              style: Theme.of(sheetContext).textTheme.titleLarge,
            ),
            const SizedBox(height: 14),
            ...AppLanguage.values.map(
              (AppLanguage language) => _ChoiceRow(
                title: language.label,
                subtitle: 'Language code ${language.code}',
                selected: settings.language == language,
                onTap: () => Navigator.of(sheetContext).pop(language),
                leading: CircleAvatar(
                  radius: 17,
                  backgroundColor: AppColors.blue.withValues(alpha: 0.12),
                  child: Text(
                    language.code,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.blue,
                    ),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: InlineBanner(
                message:
                    'This prototype ships with English text only. Your choice '
                    'is saved, and full translation is listed as a future '
                    'improvement.',
                icon: Icons.info_outline_rounded,
                color: AppColors.amber,
              ),
            ),
          ],
        ),
      ),
    );

    if (chosen == null || !context.mounted) return;
    settings.setLanguage(chosen);
    AppFeedback.info(context, 'Language preference saved: ${chosen.label}.');
  }

  Future<void> _confirmReset(BuildContext context) async {
    final bool confirmed = await AppFeedback.confirm(
      context,
      title: 'Reset the demonstration data?',
      message:
          'Contacts, history and notifications go back to the sample data '
          'that ships with the project. Your account is not affected.',
      confirmLabel: 'Reset',
      destructive: true,
      icon: Icons.restart_alt_rounded,
    );
    if (!confirmed || !context.mounted) return;

    context.read<ContactsProvider>().resetToDemoData();
    context.read<EmergencyProvider>().resetToDemoData();
    context.read<NotificationsProvider>().resetToDemoData();
    context.read<LocationProvider>().stopSharing();
    AppFeedback.success(context, 'Demonstration data restored.');
  }
}

/// A selectable row used by the countdown and language pickers.
///
/// A tick plus a highlighted label shows the current choice, so the selection
/// is never communicated by colour alone.
class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.leading,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      selected: selected,
      contentPadding: const EdgeInsets.symmetric(horizontal: 22),
      leading: leading,
      title: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontSize: 15,
          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(fontSize: 12.5),
      ),
      trailing: Icon(
        selected
            ? Icons.check_circle_rounded
            : Icons.radio_button_unchecked_rounded,
        color: selected ? AppColors.green : theme.colorScheme.outline,
      ),
    );
  }
}

/// A settings row with a switch.
class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.showDivider = true,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool value;

  /// `null` disables the row (for example when a permission is missing).
  final ValueChanged<bool>? onChanged;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool enabled = onChanged != null;

    return Column(
      children: <Widget>[
        Opacity(
          opacity: enabled ? 1 : 0.5,
          child: SwitchListTile(
            value: value,
            onChanged: onChanged,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14),
            secondary: SgIconBadge(icon: icon, color: color, size: 38),
            title: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(fontSize: 14.5),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 12.5),
              ),
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 66, right: 14),
            child: Divider(height: 1, color: theme.colorScheme.outline),
          ),
      ],
    );
  }
}

/// A settings row that opens another screen or a picker.
class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      children: <Widget>[
        ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
          leading: SgIconBadge(icon: icon, color: color, size: 38),
          title: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(fontSize: 14.5),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 12.5),
            ),
          ),
          trailing: const Icon(Icons.chevron_right_rounded),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 66, right: 14),
            child: Divider(height: 1, color: theme.colorScheme.outline),
          ),
      ],
    );
  }
}
