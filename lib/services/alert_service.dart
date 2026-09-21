import '../models/emergency_contact.dart';

/// The outcome of delivering an alert to one trusted contact.
class AlertDelivery {
  const AlertDelivery({
    required this.contact,
    required this.deliveredAt,
    this.channel = 'SMS + app alert',
  });

  final EmergencyContact contact;
  final DateTime deliveredAt;
  final String channel;
}

/// Simulates sending an emergency alert to the user's trusted contacts.
///
/// A production version of SecureGuard would send this through an SMS
/// gateway and a push-notification service. The prototype delivers the alert
/// locally, one contact at a time, so the demonstration shows exactly what
/// the real flow would look like without needing a paid backend.
class AlertService {
  const AlertService();

  /// Delay between contacts so the UI can show them being notified one by one.
  static const Duration perContactDelay = Duration(milliseconds: 450);

  /// Emits a delivery record for each contact, primary contact first.
  Stream<AlertDelivery> dispatch({
    required List<EmergencyContact> contacts,
    Duration delay = perContactDelay,
  }) async* {
    final List<EmergencyContact> ordered = sortByPriority(contacts);
    for (final EmergencyContact contact in ordered) {
      await Future<void>.delayed(delay);
      yield AlertDelivery(
        contact: contact,
        deliveredAt: DateTime.now(),
        channel: contact.isPrimary
            ? 'SMS + call + app alert'
            : 'SMS + app alert',
      );
    }
  }

  /// Primary contact first, then the rest in their existing order.
  static List<EmergencyContact> sortByPriority(
    List<EmergencyContact> contacts,
  ) {
    final List<EmergencyContact> ordered = List<EmergencyContact>.from(
      contacts,
    );
    ordered.sort((EmergencyContact a, EmergencyContact b) {
      if (a.isPrimary == b.isPrimary) return 0;
      return a.isPrimary ? -1 : 1;
    });
    return ordered;
  }

  /// The message body a trusted contact receives.
  static String buildMessage({
    required String userName,
    required String locationLabel,
    required String mapLink,
  }) {
    return 'EMERGENCY - $userName has activated a SecureGuard SOS alert.\n'
        'Last known location: $locationLabel\n'
        'Live map: $mapLink\n'
        'Please call them immediately or contact the emergency services.';
  }
}
