import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/emergency_contact.dart';
import '../../providers/auth_provider.dart';
import '../../providers/contacts_provider.dart';
import '../../providers/emergency_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/alert_service.dart';
import '../../services/dialer_service.dart';
import '../../services/location_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/app_routes.dart';
import '../../utils/formatters.dart';
import '../../utils/responsive.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/contact_tile.dart';
import '../../widgets/sos_button.dart';
import '../../widgets/status_pill.dart';

/// The dedicated emergency screen.
///
/// It shows one of four states, driven entirely by [EmergencyProvider]:
///   idle         -> confirm before starting
///   countdown    -> a cancellable countdown
///   dispatching  -> contacts being notified one by one
///   active       -> the alert is live
class SosScreen extends StatelessWidget {
  const SosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final EmergencyProvider emergency = context.watch<EmergencyProvider>();

    // A dark, focused backdrop keeps attention on the emergency itself.
    return PopScope(
      canPop: !emergency.isCountingDown,
      onPopInvokedWithResult: (bool didPop, _) {
        if (!didPop) {
          AppFeedback.warning(
            context,
            'Cancel the alert first, or wait for the countdown to finish.',
          );
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: AppColors.navyDeep,
          body: SafeArea(
            child: ResponsiveBody(
              child: switch (emergency.phase) {
                SosPhase.idle => const _IdleView(),
                SosPhase.countdown => const _CountdownView(),
                SosPhase.dispatching => const _ActiveView(dispatching: true),
                SosPhase.active => const _ActiveView(dispatching: false),
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------- shared bits
class _SosHeader extends StatelessWidget {
  const _SosHeader({required this.title, this.onClose});

  final String title;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: <Widget>[
          if (onClose != null)
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close_rounded, color: Colors.white),
              tooltip: 'Close',
            )
          else
            const SizedBox(width: 48),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- idle view
class _IdleView extends StatelessWidget {
  const _IdleView();

  @override
  Widget build(BuildContext context) {
    final bool compact = Responsive.isCompactHeight(context);
    final ContactsProvider contacts = context.watch<ContactsProvider>();

    return Column(
      children: <Widget>[
        _SosHeader(
          title: 'Emergency SOS',
          onClose: () => Navigator.of(context).maybePop(),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            child: Column(
              children: <Widget>[
                const Text(
                  'ARE YOU IN DANGER?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  contacts.isEmpty
                      ? 'Add a trusted contact before you can send an alert.'
                      : 'Hold the button below and SecureGuard will alert '
                            'your ${contacts.count} trusted '
                            '${contacts.count == 1 ? 'contact' : 'contacts'} '
                            'with your location.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 14.5,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: compact ? 30 : 44),
                SosButton(
                  size: compact ? 190 : 224,
                  enabled: contacts.hasContacts,
                  onActivate: () => _start(context),
                ),
                SizedBox(height: compact ? 26 : 38),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.shield_outlined,
                        color: Colors.white.withValues(alpha: 0.8),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Press and hold for 3 seconds to activate the '
                          'emergency alert. You can still cancel during the '
                          'countdown.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.78),
                            fontSize: 12.5,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: () =>
                      Navigator.of(context)
                          .pushNamed(AppRoutes.emergencyServices),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.32),
                    ),
                  ),
                  icon: const Icon(Icons.local_police_rounded),
                  label: const Text('Call emergency services instead'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _start(BuildContext context) {
    final SettingsProvider settings = context.read<SettingsProvider>();
    final SosStartOutcome outcome = context
        .read<EmergencyProvider>()
        .startCountdown(
          seconds: settings.sosCountdownSeconds,
          shareLocation: settings.autoShareLocationOnSos,
        );
    if (outcome == SosStartOutcome.noContacts && context.mounted) {
      AppFeedback.warning(
        context,
        'Please add at least one emergency contact before activating SOS.',
      );
    }
  }
}

// ----------------------------------------------------------- countdown view
class _CountdownView extends StatelessWidget {
  const _CountdownView();

  @override
  Widget build(BuildContext context) {
    final EmergencyProvider emergency = context.watch<EmergencyProvider>();
    final ContactsProvider contacts = context.watch<ContactsProvider>();
    final bool compact = Responsive.isCompactHeight(context);

    return Column(
      children: <Widget>[
        const _SosHeader(title: 'Emergency SOS'),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            child: Column(
              children: <Widget>[
                SizedBox(height: compact ? 8 : 20),
                const Text(
                  'Emergency Alert Activating…',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Your trusted contacts will be notified with your location.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: compact ? 26 : 40),

                // ------------------------------------------- the countdown
                _CountdownRing(
                  size: compact ? 200 : 236,
                  remaining: emergency.countdownRemaining,
                  progress: emergency.countdownProgress,
                ),

                SizedBox(height: compact ? 26 : 40),

                // ---------------------------------------------- cancel CTA
                FilledButton.icon(
                  onPressed: () => _cancel(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.navy,
                    minimumSize: const Size.fromHeight(62),
                  ),
                  icon: const Icon(Icons.close_rounded, size: 22),
                  label: const Text(
                    'CANCEL ALERT',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Pressed by mistake? Cancel before the countdown ends.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.62),
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 24),

                // ------------------------------- who is about to be alerted
                _DarkPanel(
                  title: 'Will be notified',
                  icon: Icons.group_rounded,
                  child: Column(
                    children: contacts.contacts
                        .map(
                          (EmergencyContact contact) => Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              children: <Widget>[
                                SgAvatar(
                                  initials: contact.initials,
                                  size: 34,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    '${contact.name} • ${contact.relationship}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (contact.isPrimary)
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 17,
                                    color: AppColors.amber,
                                  ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _cancel(BuildContext context) {
    HapticFeedback.mediumImpact();
    context.read<EmergencyProvider>().cancelCountdown();
    AppFeedback.info(context, 'Emergency alert cancelled. Nobody was alerted.');
    Navigator.of(context).maybePop();
  }
}

/// The large circular countdown with a sweeping progress ring.
class _CountdownRing extends StatelessWidget {
  const _CountdownRing({
    required this.size,
    required this.remaining,
    required this.progress,
  });

  final double size;
  final int remaining;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: 'Emergency alert activating in $remaining seconds',
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            // Soft glow behind the ring.
            Container(
              width: size * 0.92,
              height: size * 0.92,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.red.withValues(alpha: 0.16),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.red.withValues(alpha: 0.35),
                    blurRadius: 44,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: size,
              height: size,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: progress, end: progress),
                duration: const Duration(milliseconds: 400),
                builder: (BuildContext context, double value, _) =>
                    CircularProgressIndicator(
                      value: value,
                      strokeWidth: 10,
                      strokeCap: StrokeCap.round,
                      backgroundColor: Colors.white.withValues(alpha: 0.14),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.red,
                      ),
                    ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) =>
                          ScaleTransition(
                            scale: animation,
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          ),
                  child: Text(
                    '$remaining',
                    key: ValueKey<int>(remaining),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size * 0.36,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  remaining == 1 ? 'SECOND' : 'SECONDS',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------- active view
class _ActiveView extends StatelessWidget {
  const _ActiveView({required this.dispatching});

  /// True while contacts are still being notified.
  final bool dispatching;

  @override
  Widget build(BuildContext context) {
    final EmergencyProvider emergency = context.watch<EmergencyProvider>();
    final ContactsProvider contacts = context.watch<ContactsProvider>();
    final LocationProvider location = context.watch<LocationProvider>();
    final List<EmergencyContact> ordered = contacts.contacts;

    return Column(
      children: <Widget>[
        _SosHeader(
          title: dispatching ? 'Sending alert…' : 'Emergency active',
          onClose: dispatching ? null : () => Navigator.of(context).maybePop(),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _AlertSentHeader(dispatching: dispatching),
                const SizedBox(height: 26),

                // ------------------------------------------ status summary
                _DarkPanel(
                  title: 'Alert details',
                  icon: Icons.info_outline_rounded,
                  child: Column(
                    children: <Widget>[
                      _DetailRow(
                        icon: Icons.schedule_rounded,
                        label: 'Activated at',
                        value: emergency.activatedAt == null
                            ? '—'
                            : Formatters.time(emergency.activatedAt!),
                      ),
                      _DetailRow(
                        icon: Icons.timer_outlined,
                        label: 'Running for',
                        value: Formatters.timer(emergency.elapsed),
                      ),
                      _DetailRow(
                        icon: Icons.place_rounded,
                        label: 'Location',
                        value: location.status.addressLabel,
                      ),
                      _DetailRow(
                        icon: Icons.my_location_rounded,
                        label: 'Coordinates',
                        value: location.status.coordinatesLabel,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // --------------------------------------- location sharing
                _DarkPanel(
                  title: 'Location sharing',
                  icon: Icons.share_location_rounded,
                  trailing: StatusPill(
                    label: location.isSharing ? 'Live' : 'Off',
                    color: location.isSharing
                        ? AppColors.green
                        : AppColors.amber,
                    icon: location.isSharing
                        ? Icons.podcasts_rounded
                        : Icons.location_off_rounded,
                    dense: true,
                    filled: true,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      location.isSharing
                          ? 'Your trusted contacts can follow your position '
                                'until you end the emergency.'
                          : 'Location sharing is off. Turn it on so your '
                                'contacts can reach you.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ------------------------------------- contacts notified
                _DarkPanel(
                  title: 'Contacts notified',
                  icon: Icons.group_rounded,
                  trailing: StatusPill(
                    label:
                        '${emergency.notifiedContacts.length}'
                        '/${ordered.length}',
                    color: AppColors.green,
                    icon: Icons.check_rounded,
                    dense: true,
                    filled: emergency.notifiedContacts.length == ordered.length,
                  ),
                  child: Column(
                    children: ordered.map((EmergencyContact contact) {
                      final bool notified = emergency.notifiedContacts.any(
                        (EmergencyContact c) => c.id == contact.id,
                      );
                      return _NotifiedContactRow(
                        contact: contact,
                        notified: notified,
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 26),

                // ------------------------------------------------ actions
                FilledButton.icon(
                  onPressed: () =>
                      Navigator.of(context)
                          .pushNamed(AppRoutes.emergencyServices),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.red,
                    minimumSize: const Size.fromHeight(56),
                  ),
                  icon: const Icon(Icons.phone_in_talk_rounded),
                  label: const Text('CALL EMERGENCY SERVICES'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _shareLocation(context, location),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.34),
                    ),
                    minimumSize: const Size.fromHeight(56),
                  ),
                  icon: const Icon(Icons.ios_share_rounded),
                  label: const Text('Send my location by SMS'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: dispatching ? null : () => _end(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.green,
                    side: BorderSide(
                      color: AppColors.green.withValues(alpha: 0.65),
                    ),
                    minimumSize: const Size.fromHeight(56),
                  ),
                  icon: const Icon(Icons.verified_user_rounded),
                  label: const Text("I'M SAFE — END EMERGENCY"),
                ),
                if (dispatching) ...<Widget>[
                  const SizedBox(height: 10),
                  Text(
                    'You can end the emergency once every contact has been '
                    'notified.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _shareLocation(
    BuildContext context,
    LocationProvider location,
  ) async {
    final ContactsProvider contacts = context.read<ContactsProvider>();
    final String userName =
        context.read<AuthProvider>().user?.fullName ?? 'A SecureGuard user';
    final EmergencyContact? primary = contacts.primaryContact;
    if (primary == null) return;

    final String message = AlertService.buildMessage(
      userName: userName,
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
        await AppFeedback.notice(
          context,
          title: 'Demo message',
          message:
              'This device has no SMS app, so nothing was sent. On a phone '
              'SecureGuard would open your messages with:\n\n$message',
          icon: Icons.sms_rounded,
          color: AppColors.blue,
        );
      case DialResult.failed:
        AppFeedback.error(context, 'The message could not be prepared.');
    }
  }

  Future<void> _end(BuildContext context) async {
    final bool confirmed = await AppFeedback.confirm(
      context,
      title: 'End this emergency?',
      message:
          'SecureGuard will stop sharing your location and tell your trusted '
          'contacts that you are safe.',
      confirmLabel: "Yes, I'm safe",
      cancelLabel: 'Keep active',
      icon: Icons.verified_user_rounded,
    );
    if (!confirmed || !context.mounted) return;

    context.read<EmergencyProvider>().endEmergency(
      note: 'Emergency ended by the user. Marked as safe.',
    );
    AppFeedback.success(context, 'Emergency ended. Your contacts were told.');
    Navigator.of(context).maybePop();
  }
}

/// The big success header with a one-off check animation.
class _AlertSentHeader extends StatelessWidget {
  const _AlertSentHeader({required this.dispatching});

  final bool dispatching;

  @override
  Widget build(BuildContext context) {
    final Color accent = dispatching ? AppColors.amber : AppColors.green;

    return Column(
      children: <Widget>[
        TweenAnimationBuilder<double>(
          key: ValueKey<bool>(dispatching),
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutBack,
          builder: (BuildContext context, double value, Widget? child) =>
              Transform.scale(scale: value.clamp(0, 1.2), child: child),
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.18),
              border: Border.all(
                color: accent.withValues(alpha: 0.55),
                width: 2,
              ),
            ),
            child: Icon(
              dispatching
                  ? Icons.cell_tower_rounded
                  : Icons.check_circle_rounded,
              size: 46,
              color: accent,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          dispatching ? 'Sending your alert…' : 'Emergency Alert Sent',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 23,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          dispatching
              ? 'SecureGuard is notifying your trusted contacts one by one.'
              : 'Your trusted contacts have been notified and can see where '
                    'you are.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.72),
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _NotifiedContactRow extends StatelessWidget {
  const _NotifiedContactRow({required this.contact, required this.notified});

  final EmergencyContact contact;
  final bool notified;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: <Widget>[
          SgAvatar(initials: contact.initials, size: 36, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  contact.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  notified
                      ? 'Notified • ${contact.isPrimary ? 'SMS, call and app alert' : 'SMS and app alert'}'
                      : 'Waiting…',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 11.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            child: notified
                ? const Icon(
                    Icons.check_circle_rounded,
                    key: ValueKey<String>('done'),
                    color: AppColors.green,
                    size: 22,
                  )
                : SizedBox(
                    key: const ValueKey<String>('pending'),
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// A translucent panel used on the dark emergency background.
class _DarkPanel extends StatelessWidget {
  const _DarkPanel({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.13)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: 18, color: Colors.white.withValues(alpha: 0.75)),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.55)),
          const SizedBox(width: 10),
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12.5,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
