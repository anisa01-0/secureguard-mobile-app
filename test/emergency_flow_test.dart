import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:secureguard/data/local_store.dart';
import 'package:secureguard/models/emergency_contact.dart';
import 'package:secureguard/models/emergency_event.dart';
import 'package:secureguard/providers/contacts_provider.dart';
import 'package:secureguard/providers/emergency_provider.dart';
import 'package:secureguard/providers/location_provider.dart';
import 'package:secureguard/providers/notifications_provider.dart';

/// End-to-end unit tests for the SOS flow.
///
/// [fakeAsync] lets the countdown and the per-contact delays run instantly
/// instead of making the test wait in real time.
void main() {
  /// Builds the four providers wired together exactly as `main.dart` does.
  ({
    ContactsProvider contacts,
    LocationProvider location,
    NotificationsProvider notifications,
    EmergencyProvider emergency,
  })
  buildProviders() {
    final ContactsProvider contacts = ContactsProvider();
    final LocationProvider location = LocationProvider();
    final NotificationsProvider notifications = NotificationsProvider();
    final EmergencyProvider emergency = EmergencyProvider()
      ..attach(
        contacts: contacts,
        location: location,
        notifications: notifications,
      );
    return (
      contacts: contacts,
      location: location,
      notifications: notifications,
      emergency: emergency,
    );
  }

  setUp(() => LocalStore.instance.clearAll());

  test('the demo history is loaded on a fresh install', () {
    fakeAsync((FakeAsync async) {
      final EmergencyProvider emergency = EmergencyProvider();
      expect(emergency.history, isNotEmpty);
      expect(emergency.isIdle, isTrue);
      expect(emergency.totalAlerts, greaterThan(0));
      emergency.dispose();
    });
  });

  test('SOS cannot start without a trusted contact', () {
    fakeAsync((FakeAsync async) {
      final providers = buildProviders();
      // Remove every contact first.
      for (final EmergencyContact contact in List<EmergencyContact>.from(
        providers.contacts.contacts,
      )) {
        providers.contacts.remove(contact.id);
      }

      expect(
        providers.emergency.startCountdown(seconds: 3),
        SosStartOutcome.noContacts,
      );
      expect(providers.emergency.isIdle, isTrue);

      providers.emergency.dispose();
      providers.location.dispose();
    });
  });

  test('the countdown can be cancelled and is recorded as cancelled', () {
    fakeAsync((FakeAsync async) {
      final providers = buildProviders();
      final int before = providers.emergency.history.length;

      expect(
        providers.emergency.startCountdown(seconds: 5),
        SosStartOutcome.started,
      );
      expect(providers.emergency.isCountingDown, isTrue);

      async.elapse(const Duration(seconds: 2));
      expect(providers.emergency.countdownRemaining, 3);

      providers.emergency.cancelCountdown();
      async.flushMicrotasks();

      expect(providers.emergency.isIdle, isTrue);
      expect(providers.emergency.history.length, before + 1);
      expect(
        providers.emergency.history.first.status,
        EmergencyEventStatus.cancelled,
      );
      // Nobody may be notified when an alert is cancelled.
      expect(providers.emergency.history.first.notifiedContactNames, isEmpty);
      expect(providers.location.isSharing, isFalse);

      providers.emergency.dispose();
      providers.location.dispose();
    });
  });

  test('a completed countdown notifies every contact and shares location', () {
    fakeAsync((FakeAsync async) {
      final providers = buildProviders();
      final int contactCount = providers.contacts.count;
      final int before = providers.emergency.history.length;

      providers.emergency.startCountdown(seconds: 3);
      async.elapse(const Duration(seconds: 3));
      async.flushMicrotasks();

      // The alert is live: the event exists and location sharing started.
      expect(providers.emergency.isEmergencyInProgress, isTrue);
      expect(providers.emergency.history.length, before + 1);
      expect(providers.location.isSharing, isTrue);

      // Let every contact be notified in turn.
      async.elapse(const Duration(seconds: 5));
      async.flushMicrotasks();

      expect(providers.emergency.isActive, isTrue);
      expect(providers.emergency.notifiedContacts.length, contactCount);
      expect(
        providers.emergency.history.first.status,
        EmergencyEventStatus.active,
      );
      expect(
        providers.emergency.history.first.notifiedContactNames.length,
        contactCount,
      );

      providers.emergency.dispose();
      providers.location.dispose();
    });
  });

  test('the primary contact is notified first', () {
    fakeAsync((FakeAsync async) {
      final providers = buildProviders();
      final String primaryName = providers.contacts.primaryContact!.name;

      providers.emergency.startCountdown(seconds: 1);
      async.elapse(const Duration(seconds: 2));
      async.flushMicrotasks();

      expect(providers.emergency.notifiedContacts.first.name, primaryName);

      providers.emergency.dispose();
      providers.location.dispose();
    });
  });

  test('ending an emergency resolves it and stops location sharing', () {
    fakeAsync((FakeAsync async) {
      final providers = buildProviders();

      providers.emergency.startCountdown(seconds: 1);
      async.elapse(const Duration(seconds: 6));
      async.flushMicrotasks();
      expect(providers.emergency.isActive, isTrue);

      providers.emergency.endEmergency();
      async.flushMicrotasks();

      expect(providers.emergency.isIdle, isTrue);
      expect(providers.emergency.activeEvent, isNull);
      expect(providers.location.isSharing, isFalse);
      expect(
        providers.emergency.history.first.status,
        EmergencyEventStatus.resolved,
      );
      expect(providers.emergency.history.first.endedAt, isNotNull);

      providers.emergency.dispose();
      providers.location.dispose();
    });
  });

  test('an SOS alert raises in-app notifications', () {
    fakeAsync((FakeAsync async) {
      final providers = buildProviders();
      final int before = providers.notifications.items.length;

      providers.emergency.startCountdown(seconds: 1);
      async.elapse(const Duration(seconds: 6));
      async.flushMicrotasks();

      expect(providers.notifications.items.length, greaterThan(before));
      expect(providers.notifications.items.first.title, isNotEmpty);

      providers.emergency.dispose();
      providers.location.dispose();
    });
  });

  test('a safety check-in is recorded in the history', () {
    fakeAsync((FakeAsync async) {
      final providers = buildProviders();
      final int before = providers.emergency.history.length;

      providers.emergency.logEvent(
        type: EmergencyEventType.safetyCheck,
        note: 'Test check-in',
        notifiedContactNames: <String>['Halima Abdi'],
      );

      expect(providers.emergency.history.length, before + 1);
      expect(
        providers.emergency.history.first.type,
        EmergencyEventType.safetyCheck,
      );
      expect(
        providers.emergency.history.first.status,
        EmergencyEventStatus.resolved,
      );

      providers.emergency.dispose();
      providers.location.dispose();
    });
  });

  test('history entries can be deleted and cleared', () {
    fakeAsync((FakeAsync async) {
      final EmergencyProvider emergency = EmergencyProvider();
      final int before = emergency.history.length;
      expect(before, greaterThan(0));

      emergency.deleteEvent(emergency.history.first.id);
      expect(emergency.history.length, before - 1);

      emergency.clearHistory();
      expect(emergency.history, isEmpty);

      emergency.resetToDemoData();
      expect(emergency.history.length, before);

      emergency.dispose();
    });
  });

  group('Location sharing', () {
    test('starts and stops, and reports who is receiving', () {
      fakeAsync((FakeAsync async) {
        final LocationProvider location = LocationProvider();
        expect(location.isSharing, isFalse);

        final bool started = location.startSharing(<String>[
          'Halima Abdi',
          'Yusuf Abdi',
        ]);
        expect(started, isTrue);
        expect(location.isSharing, isTrue);
        expect(location.status.sharedWith, hasLength(2));

        location.stopSharing();
        expect(location.isSharing, isFalse);
        expect(location.status.sharedWith, isEmpty);

        location.dispose();
      });
    });

    test('cannot start without the location permission', () {
      fakeAsync((FakeAsync async) {
        final LocationProvider location = LocationProvider()
          ..setPermissionGranted(false);

        expect(location.startSharing(<String>['Halima Abdi']), isFalse);
        expect(location.isSharing, isFalse);

        location.dispose();
      });
    });

    test('the position updates while sharing is active', () {
      fakeAsync((FakeAsync async) {
        final LocationProvider location = LocationProvider();
        final double startLatitude = location.status.latitude;

        location.startSharing(<String>['Halima Abdi']);
        async.elapse(const Duration(seconds: 12));

        expect(location.status.latitude, isNot(startLatitude));

        location.stopSharing();
        location.dispose();
      });
    });
  });
}
