import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_notification.dart';
import '../../models/emergency_contact.dart';
import '../../models/emergency_event.dart';
import '../../providers/auth_provider.dart';
import '../../providers/contacts_provider.dart';
import '../../providers/emergency_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/notifications_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/app_routes.dart';
import '../../utils/formatters.dart';
import '../../utils/responsive.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/contact_tile.dart';
import '../../widgets/quick_action_tile.dart';
import '../../widgets/section_header.dart';
import '../../widgets/sg_card.dart';
import '../../widgets/sg_logo.dart';
import '../../widgets/sos_button.dart';
import '../../widgets/status_pill.dart';
import '../history/event_detail_screen.dart';
import 'root_shell.dart';

/// The dashboard: safety status, the SOS button and every shortcut.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// Starts the SOS flow, or explains why it cannot start yet.
  static Future<void> triggerSos(BuildContext context) async {
    final EmergencyProvider emergency = context.read<EmergencyProvider>();
    final SettingsProvider settings = context.read<SettingsProvider>();

    final SosStartOutcome outcome = emergency.startCountdown(
      seconds: settings.sosCountdownSeconds,
      shareLocation: settings.autoShareLocationOnSos,
    );

    if (!context.mounted) return;

    switch (outcome) {
      case SosStartOutcome.started:
        Navigator.of(context).pushNamed(AppRoutes.sos);
      case SosStartOutcome.alreadyRunning:
        Navigator.of(context).pushNamed(AppRoutes.sos);
      case SosStartOutcome.noContacts:
        final bool addNow = await AppFeedback.confirm(
          context,
          title: 'No trusted contact yet',
          message:
              'Please add at least one emergency contact before activating '
              'SOS, so SecureGuard knows who to alert.',
          confirmLabel: 'Add contact',
          cancelLabel: 'Not now',
          icon: Icons.group_add_rounded,
        );
        if (addNow && context.mounted) RootShell.goToTab(context, 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double padding = Responsive.horizontalPadding(context);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ResponsiveBody(
          child: CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(padding, 8, padding, 0),
                  child: const _HomeHeader(),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(padding, 20, padding, 28),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(<Widget>[
                    const _SafetyStatusCard(),
                    const SizedBox(height: 22),
                    const _SosPanel(),
                    const SizedBox(height: 28),
                    const _QuickActionsGrid(),
                    const SizedBox(height: 28),
                    const _TrustedContactsSection(),
                    const SizedBox(height: 26),
                    const _LocationSection(),
                    const SizedBox(height: 26),
                    const _RecentActivitySection(),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- header
class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String name = context.select<AuthProvider, String>(
      (AuthProvider a) => a.user?.firstName ?? 'there',
    );
    final int unread = context.select<NotificationsProvider, int>(
      (NotificationsProvider n) => n.unreadCount,
    );

    return Row(
      children: <Widget>[
        const SgLogo(size: 34),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '${Formatters.greeting()},',
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 12.5),
              ),
              const SizedBox(height: 1),
              Text(
                name,
                style: theme.textTheme.titleLarge,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        _HeaderIconButton(
          icon: Icons.notifications_none_rounded,
          tooltip: unread > 0
              ? '$unread unread notifications'
              : 'Notifications',
          badgeCount: unread,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.notifications),
        ),
        const SizedBox(width: 8),
        _HeaderIconButton(
          icon: Icons.settings_outlined,
          tooltip: 'Settings',
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.settings),
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: InkResponse(
          onTap: onTap,
          radius: 26,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Icon(icon, size: 21, color: theme.colorScheme.onSurface),
                if (badgeCount > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      constraints: const BoxConstraints(minWidth: 16),
                      decoration: BoxDecoration(
                        color: AppColors.red,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color: theme.colorScheme.surface,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        badgeCount > 9 ? '9+' : '$badgeCount',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                        ),
                      ),
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

// ------------------------------------------------------------ status card
class _SafetyStatusCard extends StatelessWidget {
  const _SafetyStatusCard();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ContactsProvider contacts = context.watch<ContactsProvider>();
    final LocationProvider location = context.watch<LocationProvider>();
    final EmergencyProvider emergency = context.watch<EmergencyProvider>();

    final bool protected = contacts.hasContacts && location.permissionGranted;
    final bool emergencyRunning = emergency.isEmergencyInProgress;

    final Color accent = emergencyRunning
        ? AppColors.red
        : protected
        ? AppColors.green
        : AppColors.amber;

    final String title = emergencyRunning
        ? 'Emergency in progress'
        : protected
        ? 'You are protected'
        : 'Protection incomplete';

    final String message = emergencyRunning
        ? 'Your trusted contacts have been alerted. Open the emergency '
              'screen to manage it.'
        : protected
        ? '${contacts.count} trusted '
              '${contacts.count == 1 ? 'contact is' : 'contacts are'} ready '
              'to be alerted, and your location is available.'
        : contacts.isEmpty
        ? 'Add a trusted contact so SecureGuard knows who to alert.'
        : 'Turn the location permission back on so your contacts can '
              'find you.';

    return SgCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          accent.withValues(alpha: 0.13),
          accent.withValues(alpha: 0.04),
        ],
      ),
      borderColor: accent.withValues(alpha: 0.30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SgIconBadge(
            icon: emergencyRunning
                ? Icons.emergency_share_rounded
                : protected
                ? Icons.verified_user_rounded
                : Icons.gpp_maybe_rounded,
            color: accent,
            size: 48,
            filled: true,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(title, style: theme.textTheme.titleMedium),
                    ),
                    if (location.isSharing) ...<Widget>[
                      const LiveDot(color: AppColors.red),
                      const SizedBox(width: 6),
                      Text(
                        'LIVE',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.red,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 5),
                Text(message, style: theme.textTheme.bodySmall),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    StatusPill(
                      label: '${contacts.count} contacts',
                      color: contacts.hasContacts
                          ? AppColors.green
                          : AppColors.amber,
                      icon: Icons.group_rounded,
                      dense: true,
                    ),
                    StatusPill(
                      label: location.permissionGranted
                          ? 'Location on'
                          : 'Location off',
                      color: location.permissionGranted
                          ? AppColors.green
                          : AppColors.amber,
                      icon: location.permissionGranted
                          ? Icons.location_on_rounded
                          : Icons.location_off_rounded,
                      dense: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------- SOS panel
class _SosPanel extends StatelessWidget {
  const _SosPanel();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool compact = Responsive.isCompactHeight(context);
    final EmergencyProvider emergency = context.watch<EmergencyProvider>();
    final bool running = emergency.isEmergencyInProgress;

    return SgCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 26),
      child: Column(
        children: <Widget>[
          Text(
            running ? 'EMERGENCY ACTIVE' : 'ARE YOU IN DANGER?',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              letterSpacing: 1.0,
              color: AppColors.red,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            running
                ? 'Open the emergency screen to see who has been notified.'
                : 'Help is one press away, day or night.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
          SizedBox(height: compact ? 18 : 24),
          if (running)
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.sos),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.red,
                minimumSize: const Size.fromHeight(58),
              ),
              icon: const Icon(Icons.open_in_full_rounded),
              label: const Text('OPEN EMERGENCY SCREEN'),
            )
          else
            SosButton(
              size: compact ? 168 : 196,
              onActivate: () => HomeScreen.triggerSos(context),
            ),
          SizedBox(height: compact ? 16 : 22),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.touch_app_rounded,
                  size: 17,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    running
                        ? 'Your contacts can see your live location until you '
                              'end the emergency.'
                        : 'Press and hold for 3 seconds to activate the '
                              'emergency alert.',
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 12.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------- quick actions
class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    final ContactsProvider contacts = context.watch<ContactsProvider>();
    final LocationProvider location = context.watch<LocationProvider>();
    final EmergencyProvider emergency = context.read<EmergencyProvider>();
    final int columns = Responsive.gridColumns(context);

    final List<Widget> tiles = <Widget>[
      QuickActionTile(
        icon: Icons.local_police_rounded,
        label: 'Emergency Services',
        badge: 'Direct emergency lines',
        color: AppColors.navy,
        onTap: () =>
            Navigator.of(context).pushNamed(AppRoutes.emergencyServices),
      ),
      QuickActionTile(
        icon: location.isSharing
            ? Icons.share_location_rounded
            : Icons.my_location_rounded,
        label: location.isSharing ? 'Stop Sharing' : 'Share Location',
        badge: location.isSharing
            ? 'Sharing with ${location.status.sharedWith.length}'
            : 'Send your live position',
        color: location.isSharing ? AppColors.red : AppColors.blue,
        onTap: () => _toggleSharing(context, location, contacts),
      ),
      QuickActionTile(
        icon: Icons.tips_and_updates_rounded,
        label: 'Safety Tips',
        badge: '15 practical tips',
        color: AppColors.green,
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.safetyTips),
      ),
      QuickActionTile(
        icon: Icons.verified_user_rounded,
        label: 'I Am Safe',
        badge: 'Tell your contacts',
        color: AppColors.amber,
        onTap: () => _sendSafetyCheck(context, emergency, contacts),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SectionHeader(
          title: 'Quick actions',
          subtitle: 'The tools you are most likely to need',
        ),
        // A fixed aspect ratio made the tiles shorter as the grid grew
        // narrower, while their labels kept their size, so a two-line label
        // such as "Emergency Services" ran out of the box. Give every tile a
        // height that follows the text instead of the column width.
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            mainAxisExtent: _tileHeight(context),
          ),
          children: tiles,
        ),
      ],
    );
  }

  /// Height of one quick-action tile: the icon, both label lines and the
  /// badge, plus the tile's own padding, grown with the reader's font size.
  static double _tileHeight(BuildContext context) {
    const double iconAndPadding = 32 + 42 + 12; // padding, icon, gap
    const double labelLines = 2 * 21 + 3 + 18; // label, gap, badge
    return iconAndPadding +
        MediaQuery.textScalerOf(context)
            .scale(labelLines)
            .clamp(labelLines, labelLines * 2);
  }

  Future<void> _toggleSharing(
    BuildContext context,
    LocationProvider location,
    ContactsProvider contacts,
  ) async {
    final NotificationsProvider notifications = context
        .read<NotificationsProvider>();

    if (location.isSharing) {
      location.stopSharing();
      notifications.push(
        type: NotificationType.location,
        title: 'Location sharing stopped',
        message: 'Your trusted contacts can no longer see your position.',
      );
      if (context.mounted) {
        AppFeedback.info(context, 'Location sharing stopped.');
      }
      return;
    }

    if (contacts.isEmpty) {
      AppFeedback.warning(
        context,
        'Add a trusted contact before sharing your location.',
      );
      return;
    }

    final bool started = location.startSharing(
      contacts.contacts.map((EmergencyContact c) => c.name).toList(),
    );

    if (!context.mounted) return;
    if (!started) {
      AppFeedback.warning(
        context,
        'Turn on the location permission in Settings first.',
      );
      return;
    }

    notifications.push(
      type: NotificationType.location,
      title: 'Location sharing started',
      message:
          'You are sharing your live location with ${contacts.count} trusted '
          '${contacts.count == 1 ? 'contact' : 'contacts'}.',
    );
    AppFeedback.success(context, 'Live location sharing started.');
  }

  Future<void> _sendSafetyCheck(
    BuildContext context,
    EmergencyProvider emergency,
    ContactsProvider contacts,
  ) async {
    if (contacts.isEmpty) {
      AppFeedback.warning(
        context,
        'Add a trusted contact before sending a check-in.',
      );
      return;
    }

    final bool confirmed = await AppFeedback.confirm(
      context,
      title: 'Let your contacts know you are safe',
      message:
          'SecureGuard will send a short "I am safe" message to your '
          '${contacts.count} trusted '
          '${contacts.count == 1 ? 'contact' : 'contacts'}.',
      confirmLabel: 'Send check-in',
      icon: Icons.verified_user_rounded,
    );
    if (!confirmed || !context.mounted) return;

    emergency.logEvent(
      type: EmergencyEventType.safetyCheck,
      note: 'Safety check-in sent from the dashboard.',
      notifiedContactNames: contacts.contacts
          .map((EmergencyContact c) => c.name)
          .toList(),
    );
    context.read<NotificationsProvider>().push(
      type: NotificationType.reminder,
      title: 'Safety check-in sent',
      message: 'Your trusted contacts know that you are safe.',
    );
    AppFeedback.success(context, 'Check-in sent to your trusted contacts.');
  }
}

// -------------------------------------------------------- trusted contacts
class _TrustedContactsSection extends StatelessWidget {
  const _TrustedContactsSection();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ContactsProvider contacts = context.watch<ContactsProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SectionHeader(
          title: 'Trusted contacts',
          subtitle: contacts.isEmpty
              ? 'Nobody will be alerted yet'
              : '${contacts.count} people are alerted when you press SOS',
          actionLabel: 'Manage',
          onAction: () => RootShell.goToTab(context, 1),
        ),
        if (contacts.isEmpty)
          SgCard(
            child: Row(
              children: <Widget>[
                const SgIconBadge(
                  icon: Icons.group_add_rounded,
                  color: AppColors.amber,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Add your first trusted contact',
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'SOS needs at least one person to alert.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                FilledButton(
                  onPressed: () => RootShell.goToTab(context, 1),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(72, 42),
                    backgroundColor: AppColors.amber,
                  ),
                  child: const Text('Add'),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 132,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: contacts.count,
              padding: EdgeInsets.zero,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (BuildContext context, int index) =>
                  _ContactChipCard(contact: contacts.contacts[index]),
            ),
          ),
      ],
    );
  }
}

class _ContactChipCard extends StatelessWidget {
  const _ContactChipCard({required this.contact});

  final EmergencyContact contact;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color accent = contact.isPrimary ? AppColors.green : AppColors.navy;

    return SizedBox(
      width: 148,
      child: SgCard(
        padding: const EdgeInsets.all(14),
        onTap: () => RootShell.goToTab(context, 1),
        semanticLabel:
            '${contact.name}, ${contact.relationship}'
            '${contact.isPrimary ? ', primary contact' : ''}',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                SgAvatar(initials: contact.initials, size: 38, color: accent),
                const Spacer(),
                if (contact.isPrimary)
                  const Icon(
                    Icons.star_rounded,
                    size: 18,
                    color: AppColors.green,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              contact.name,
              style: theme.textTheme.titleSmall?.copyWith(fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              contact.isPrimary
                  ? '${contact.relationship} • Primary'
                  : contact.relationship,
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 11.5),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------------------- location
class _LocationSection extends StatelessWidget {
  const _LocationSection();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final LocationProvider location = context.watch<LocationProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SectionHeader(
          title: 'Your location',
          subtitle: location.status.statusLabel,
          actionLabel: 'Open map',
          onAction: () => RootShell.goToTab(context, 2),
        ),
        SgCard(
          padding: const EdgeInsets.all(14),
          onTap: () => RootShell.goToTab(context, 2),
          child: Row(
            children: <Widget>[
              SgIconBadge(
                icon: location.isSharing
                    ? Icons.share_location_rounded
                    : Icons.location_on_rounded,
                color: location.isSharing ? AppColors.red : AppColors.blue,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      location.status.addressLabel,
                      style: theme.textTheme.titleSmall?.copyWith(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Updated ${Formatters.relative(location.status.updatedAt)}'
                      ' • ± ${location.status.accuracyMeters.toStringAsFixed(0)} m',
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// -------------------------------------------------------- recent activity
class _RecentActivitySection extends StatelessWidget {
  const _RecentActivitySection();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final EmergencyProvider emergency = context.watch<EmergencyProvider>();
    final List<EmergencyEvent> recent = emergency.recentActivity;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SectionHeader(
          title: 'Recent activity',
          subtitle: recent.isEmpty
              ? 'Your safety events will appear here'
              : 'Your latest safety events',
          actionLabel: recent.isEmpty ? null : 'View all',
          onAction: recent.isEmpty ? null : () => RootShell.goToTab(context, 3),
        ),
        if (recent.isEmpty)
          SgCard(
            child: Row(
              children: <Widget>[
                const SgIconBadge(
                  icon: Icons.history_rounded,
                  color: AppColors.blue,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'No safety events recorded yet. Everything you do in '
                    'SecureGuard is logged here.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          )
        else
          ...recent.map(
            (EmergencyEvent event) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ActivityRow(event: event),
            ),
          ),
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.event});

  final EmergencyEvent event;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SgCard(
      padding: const EdgeInsets.all(14),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => EventDetailScreen(event: event),
        ),
      ),
      child: Row(
        children: <Widget>[
          SgIconBadge(
            icon: event.type.icon,
            color: event.status.color,
            size: 40,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  event.type.label,
                  style: theme.textTheme.titleSmall?.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  Formatters.friendlyDateTime(event.startedAt),
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
    );
  }
}
