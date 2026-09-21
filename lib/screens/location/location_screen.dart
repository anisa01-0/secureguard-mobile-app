import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/app_notification.dart';
import '../../models/emergency_contact.dart';
import '../../providers/auth_provider.dart';
import '../../providers/contacts_provider.dart';
import '../../providers/emergency_provider.dart';
import '../../models/emergency_event.dart';
import '../../providers/location_provider.dart';
import '../../providers/notifications_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/alert_service.dart';
import '../../services/dialer_service.dart';
import '../../services/location_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../utils/responsive.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/contact_tile.dart';
import '../../widgets/mock_map.dart';
import '../../widgets/section_header.dart';
import '../../widgets/sg_card.dart';
import '../../widgets/status_pill.dart';

/// Live location screen: map, position details and sharing controls.
class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LocationProvider location = context.watch<LocationProvider>();
    final ContactsProvider contacts = context.watch<ContactsProvider>();
    final double padding = Responsive.horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Location'),
        actions: <Widget>[
          IconButton(
            onPressed: location.isLocating || !location.permissionGranted
                ? null
                : () => location.refresh(),
            icon: location.isLocating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  )
                : const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh my position',
          ),
          SizedBox(width: padding - 12),
        ],
      ),
      body: SafeArea(
        child: ResponsiveBody(
          child: ListView(
            padding: EdgeInsets.fromLTRB(padding, 6, padding, 32),
            children: <Widget>[
              if (!location.permissionGranted) ...<Widget>[
                InlineBanner(
                  title: 'Location permission is off',
                  message:
                      'SecureGuard cannot show or share your position until '
                      'the location permission is granted.',
                  icon: Icons.location_off_rounded,
                  color: AppColors.amber,
                  actionLabel: 'Grant permission',
                  onAction: () => _grantPermission(context),
                ),
                const SizedBox(height: 16),
              ],

              // ------------------------------------------------------ map
              MockMap(
                latitude: location.status.latitude,
                longitude: location.status.longitude,
                isSharing: location.isSharing,
                accuracyMeters: location.status.accuracyMeters,
                height: Responsive.isCompactHeight(context) ? 230 : 268,
              ),
              const SizedBox(height: 16),

              // -------------------------------------------- position card
              const _PositionCard(),
              const SizedBox(height: 16),

              // ---------------------------------------- sharing controls
              _SharingControls(
                isSharing: location.isSharing,
                canShare: location.permissionGranted && contacts.hasContacts,
                onStart: () => _startSharing(context),
                onStop: () => _stopSharing(context),
                onSendSms: () => _sendBySms(context),
              ),
              const SizedBox(height: 24),

              // ------------------------------------------ receiving list
              SectionHeader(
                title: 'Who can see your location',
                subtitle: location.isSharing
                    ? '${location.status.sharedWith.length} trusted contacts '
                          'are receiving live updates'
                    : 'Nobody is receiving your location right now',
                icon: Icons.group_rounded,
              ),
              if (contacts.isEmpty)
                SgCard(
                  child: Text(
                    'Add a trusted contact first — location sharing needs '
                    'somebody to share with.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                )
              else
                ...contacts.contacts.map(
                  (EmergencyContact contact) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ReceiverTile(
                      contact: contact,
                      receiving: location.status.sharedWith.contains(
                        contact.name,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 16),
              const InlineBanner(
                title: 'Simulated positioning',
                message:
                    'This prototype uses a simulated GPS feed and a drawn map '
                    'so it runs on any device without a paid map service. The '
                    'sharing flow behaves exactly as a finished product would.',
                icon: Icons.science_outlined,
                color: AppColors.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _grantPermission(BuildContext context) async {
    final bool granted = await context
        .read<LocationProvider>()
        .requestPermission();
    if (!context.mounted) return;
    context.read<SettingsProvider>().setLocationPermissionGranted(granted);
    if (granted) {
      AppFeedback.success(context, 'Location permission granted.');
    } else {
      AppFeedback.warning(context, 'Location permission was declined.');
    }
  }

  Future<void> _startSharing(BuildContext context) async {
    final LocationProvider location = context.read<LocationProvider>();
    final ContactsProvider contacts = context.read<ContactsProvider>();

    if (contacts.isEmpty) {
      AppFeedback.warning(
        context,
        'Add a trusted contact before sharing your location.',
      );
      return;
    }

    final bool confirmed = await AppFeedback.confirm(
      context,
      title: 'Share your live location?',
      message:
          'Your ${contacts.count} trusted '
          '${contacts.count == 1 ? 'contact' : 'contacts'} will be able to '
          'follow your position until you stop sharing.',
      confirmLabel: 'Start sharing',
      icon: Icons.share_location_rounded,
    );
    if (!confirmed || !context.mounted) return;

    final bool started = location.startSharing(
      contacts.contacts.map((EmergencyContact c) => c.name).toList(),
    );
    if (!context.mounted) return;

    if (!started) {
      AppFeedback.warning(
        context,
        'Grant the location permission before sharing.',
      );
      return;
    }

    context.read<EmergencyProvider>().logEvent(
      type: EmergencyEventType.locationShare,
      note: 'Live location sharing started from the location screen.',
      notifiedContactNames: contacts.contacts
          .map((EmergencyContact c) => c.name)
          .toList(),
      locationShared: true,
    );
    context.read<NotificationsProvider>().push(
      type: NotificationType.location,
      title: 'Location sharing started',
      message:
          'You are sharing your live location with ${contacts.count} '
          'trusted ${contacts.count == 1 ? 'contact' : 'contacts'}.',
    );
    AppFeedback.success(context, 'Live location sharing started.');
  }

  Future<void> _stopSharing(BuildContext context) async {
    final bool confirmed = await AppFeedback.confirm(
      context,
      title: 'Stop sharing your location?',
      message:
          'Your trusted contacts will no longer be able to see where you are.',
      confirmLabel: 'Stop sharing',
      destructive: true,
      icon: Icons.location_off_rounded,
    );
    if (!confirmed || !context.mounted) return;

    context.read<LocationProvider>().stopSharing();
    context.read<NotificationsProvider>().push(
      type: NotificationType.location,
      title: 'Location sharing stopped',
      message: 'Your trusted contacts can no longer see your position.',
    );
    AppFeedback.info(context, 'Location sharing stopped.');
  }

  Future<void> _sendBySms(BuildContext context) async {
    final LocationProvider location = context.read<LocationProvider>();
    final ContactsProvider contacts = context.read<ContactsProvider>();
    final EmergencyContact? primary = contacts.primaryContact;

    if (primary == null) {
      AppFeedback.warning(context, 'Add a trusted contact first.');
      return;
    }

    final String message = AlertService.buildMessage(
      userName: context.read<AuthProvider>().user?.fullName ?? 'A friend',
      locationLabel: location.status.addressLabel,
      mapLink: LocationService.shareLink(
        location.status.latitude,
        location.status.longitude,
      ),
    );

    final DialResult result = await const DialerService().sendSms(
      primary.phone,
      message,
    );
    if (!context.mounted) return;

    switch (result) {
      case DialResult.launched:
        AppFeedback.success(context, 'Message app opened for ${primary.name}.');
      case DialResult.unsupported:
        await Clipboard.setData(ClipboardData(text: message));
        if (!context.mounted) return;
        await AppFeedback.notice(
          context,
          title: 'Demo message',
          message:
              'This device has no SMS app. The message has been copied to '
              'your clipboard instead:\n\n$message',
          icon: Icons.content_copy_rounded,
        );
      case DialResult.failed:
        AppFeedback.error(context, 'The message could not be prepared.');
    }
  }
}

class _PositionCard extends StatelessWidget {
  const _PositionCard();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final LocationProvider location = context.watch<LocationProvider>();

    return SgCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
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
                      style: theme.textTheme.titleSmall?.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Updated ${Formatters.relative(location.status.updatedAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              StatusPill(
                label: location.isSharing ? 'Sharing' : 'Private',
                color: location.isSharing ? AppColors.red : AppColors.green,
                icon: location.isSharing
                    ? Icons.podcasts_rounded
                    : Icons.lock_rounded,
                dense: true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: theme.colorScheme.outline),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.my_location_rounded,
            label: 'Coordinates',
            value: location.status.coordinatesLabel,
          ),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.straighten_rounded,
            label: 'Accuracy',
            value:
                '± ${location.status.accuracyMeters.toStringAsFixed(0)} '
                'metres',
          ),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.schedule_rounded,
            label: 'Last update',
            value: Formatters.time(location.status.updatedAt),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
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
      children: <Widget>[
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 10),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(fontSize: 13)),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _SharingControls extends StatelessWidget {
  const _SharingControls({
    required this.isSharing,
    required this.canShare,
    required this.onStart,
    required this.onStop,
    required this.onSendSms,
  });

  final bool isSharing;
  final bool canShare;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onSendSms;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        if (isSharing)
          FilledButton.icon(
            onPressed: onStop,
            style: FilledButton.styleFrom(backgroundColor: AppColors.red),
            icon: const Icon(Icons.stop_circle_rounded),
            label: const Text('STOP SHARING LOCATION'),
          )
        else
          FilledButton.icon(
            onPressed: canShare ? onStart : null,
            style: FilledButton.styleFrom(backgroundColor: AppColors.blue),
            icon: const Icon(Icons.share_location_rounded),
            label: const Text('SHARE MY LIVE LOCATION'),
          ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: onSendSms,
          icon: const Icon(Icons.sms_outlined),
          label: const Text('Send location by message'),
        ),
      ],
    );
  }
}

class _ReceiverTile extends StatelessWidget {
  const _ReceiverTile({required this.contact, required this.receiving});

  final EmergencyContact contact;
  final bool receiving;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SgCard(
      padding: const EdgeInsets.all(13),
      child: Row(
        children: <Widget>[
          SgAvatar(
            initials: contact.initials,
            size: 40,
            color: receiving ? AppColors.green : AppColors.navy,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  contact.name,
                  style: theme.textTheme.titleSmall?.copyWith(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  contact.relationship,
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          StatusPill(
            label: receiving ? 'Receiving' : 'Not sharing',
            color: receiving ? AppColors.green : AppColors.textSecondary,
            icon: receiving
                ? Icons.wifi_tethering_rounded
                : Icons.wifi_tethering_off_rounded,
            dense: true,
          ),
        ],
      ),
    );
  }
}
