import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/contacts_provider.dart';
import '../../providers/emergency_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/notifications_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/app_routes.dart';
import '../../utils/responsive.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/section_header.dart';
import '../../widgets/sg_card.dart';
import '../../widgets/status_pill.dart';
import '../home/root_shell.dart';

/// The user's profile: identity, protection summary and account shortcuts.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthProvider auth = context.watch<AuthProvider>();
    final AppUser? user = auth.user;
    final double padding = Responsive.horizontalPadding(context);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: <Widget>[
          IconButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
          ),
          SizedBox(width: padding - 12),
        ],
      ),
      body: SafeArea(
        child: ResponsiveBody(
          child: ListView(
            padding: EdgeInsets.fromLTRB(padding, 6, padding, 32),
            children: <Widget>[
              _ProfileHeader(user: user),
              const SizedBox(height: 18),
              const _ProtectionSummary(),
              const SizedBox(height: 24),

              const SectionHeader(
                title: 'Personal details',
                icon: Icons.badge_outlined,
              ),
              SgCard(
                child: Column(
                  children: <Widget>[
                    _ProfileRow(
                      icon: Icons.person_outline_rounded,
                      label: 'Full name',
                      value: user.fullName,
                    ),
                    const SizedBox(height: 14),
                    _ProfileRow(
                      icon: Icons.mail_outline_rounded,
                      label: 'Email',
                      value: user.email,
                    ),
                    const SizedBox(height: 14),
                    _ProfileRow(
                      icon: Icons.phone_outlined,
                      label: 'Phone',
                      value: user.phone,
                    ),
                    const SizedBox(height: 14),
                    _ProfileRow(
                      icon: Icons.bloodtype_outlined,
                      label: 'Blood group',
                      value: user.bloodGroup,
                    ),
                    const SizedBox(height: 14),
                    _ProfileRow(
                      icon: Icons.home_outlined,
                      label: 'Home area',
                      value: user.address,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.editProfile),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit profile'),
              ),
              const SizedBox(height: 26),

              const SectionHeader(
                title: 'Account',
                icon: Icons.manage_accounts_outlined,
              ),
              SgCard(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  children: <Widget>[
                    _ProfileAction(
                      icon: Icons.notifications_none_rounded,
                      label: 'Notifications',
                      color: AppColors.blue,
                      onTap: () =>
                          Navigator.of(context)
                              .pushNamed(AppRoutes.notifications),
                    ),
                    _ProfileAction(
                      icon: Icons.tips_and_updates_outlined,
                      label: 'Safety tips',
                      color: AppColors.green,
                      onTap: () =>
                          Navigator.of(context).pushNamed(AppRoutes.safetyTips),
                    ),
                    _ProfileAction(
                      icon: Icons.lock_outline_rounded,
                      label: 'Change password',
                      color: AppColors.navy,
                      onTap: () =>
                          Navigator.of(context)
                              .pushNamed(AppRoutes.changePassword),
                    ),
                    _ProfileAction(
                      icon: Icons.privacy_tip_outlined,
                      label: 'Privacy & data',
                      color: AppColors.amber,
                      onTap: () =>
                          Navigator.of(context).pushNamed(AppRoutes.privacy),
                    ),
                    _ProfileAction(
                      icon: Icons.info_outline_rounded,
                      label: 'About SecureGuard',
                      color: AppColors.navySoft,
                      onTap: () =>
                          Navigator.of(context).pushNamed(AppRoutes.about),
                      showDivider: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              OutlinedButton.icon(
                onPressed: () => confirmLogout(context),
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
              const SizedBox(height: 18),
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

  /// Signs out after a confirmation, and returns to the login screen.
  static Future<void> confirmLogout(BuildContext context) async {
    final EmergencyProvider emergency = context.read<EmergencyProvider>();

    if (emergency.isEmergencyInProgress) {
      AppFeedback.warning(
        context,
        'End the active emergency before logging out.',
      );
      return;
    }

    final bool confirmed = await AppFeedback.confirm(
      context,
      title: 'Log out of SecureGuard?',
      message:
          'Your trusted contacts and history stay saved on this device. You '
          'can sign back in at any time.',
      confirmLabel: 'Log out',
      destructive: true,
      icon: Icons.logout_rounded,
    );
    if (!confirmed || !context.mounted) return;

    context.read<LocationProvider>().stopSharing();
    await context.read<AuthProvider>().signOut();
    if (!context.mounted) return;

    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (Route<dynamic> route) => false);
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SgCard(
      gradient: AppColors.brandGradient,
      borderColor: AppColors.navySoft,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: <Widget>[
          Container(
            width: 74,
            height: 74,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.38),
                width: 2,
              ),
            ),
            child: Text(
              user.initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 27,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 17),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  user.fullName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  user.email,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                const StatusPill(
                  label: 'Account protected',
                  color: AppColors.green,
                  icon: Icons.verified_rounded,
                  dense: true,
                  filled: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProtectionSummary extends StatelessWidget {
  const _ProtectionSummary();

  @override
  Widget build(BuildContext context) {
    final ContactsProvider contacts = context.watch<ContactsProvider>();
    final EmergencyProvider emergency = context.watch<EmergencyProvider>();
    final NotificationsProvider notifications = context
        .watch<NotificationsProvider>();

    return Row(
      children: <Widget>[
        Expanded(
          child: _StatTile(
            value: '${contacts.count}',
            label: 'Trusted\ncontacts',
            icon: Icons.group_rounded,
            color: AppColors.green,
            onTap: () => RootShell.goToTab(context, 1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            value: '${emergency.totalAlerts}',
            label: 'SOS alerts\nsent',
            icon: Icons.emergency_share_rounded,
            color: AppColors.red,
            onTap: () => RootShell.goToTab(context, 3),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            value: '${notifications.items.length}',
            label: 'Notifications\nreceived',
            icon: Icons.notifications_rounded,
            color: AppColors.blue,
            onTap: () =>
                Navigator.of(context).pushNamed(AppRoutes.notifications),
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SgCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      semanticLabel: '$value ${label.replaceAll('\n', ' ')}',
      child: Column(
        children: <Widget>[
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(fontSize: 21),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11.5,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        SizedBox(
          width: 96,
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

class _ProfileAction extends StatelessWidget {
  const _ProfileAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final Color color;
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
            label,
            style: theme.textTheme.titleSmall?.copyWith(fontSize: 14.5),
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
