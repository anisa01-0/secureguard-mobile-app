import 'dart:async';

import 'package:flutter/material.dart';

import '../data/demo_data.dart';
import '../data/local_store.dart';
import '../models/app_notification.dart';
import '../models/emergency_contact.dart';
import '../models/emergency_event.dart';
import '../services/alert_service.dart';
import 'contacts_provider.dart';
import 'location_provider.dart';
import 'notifications_provider.dart';

/// The stage the SOS flow is currently in.
enum SosPhase {
  /// Nothing is happening.
  idle,

  /// Counting down, the user can still cancel.
  countdown,

  /// Contacts are being notified one by one.
  dispatching,

  /// The alert is live: contacts notified, location shared.
  active,
}

/// Why an attempt to start the SOS flow did not begin.
enum SosStartOutcome { started, noContacts, alreadyRunning }

/// Coordinates the SOS flow and owns the emergency history.
///
/// This is the heart of the application: it runs the countdown, notifies the
/// trusted contacts, starts location sharing, writes the event into the
/// history and raises the matching in-app notifications.
class EmergencyProvider extends ChangeNotifier {
  EmergencyProvider({
    LocalStore? store,
    AlertService alertService = const AlertService(),
  }) : _store = store ?? LocalStore.instance,
       _alerts = alertService {
    _loadHistory();
  }

  final LocalStore _store;
  final AlertService _alerts;

  // Collaborating providers, wired up in `main.dart`.
  ContactsProvider? _contacts;
  LocationProvider? _location;
  NotificationsProvider? _notifications;

  Timer? _countdownTimer;
  Timer? _elapsedTimer;
  StreamSubscription<AlertDelivery>? _dispatchSubscription;

  SosPhase _phase = SosPhase.idle;
  int _countdownRemaining = 0;
  int _countdownTotal = 0;
  final List<EmergencyContact> _notifiedContacts = <EmergencyContact>[];
  EmergencyEvent? _activeEvent;
  DateTime? _activatedAt;
  Duration _elapsed = Duration.zero;
  bool _shareLocationOnActivation = true;
  List<EmergencyEvent> _history = <EmergencyEvent>[];

  // ------------------------------------------------------------- Accessors
  SosPhase get phase => _phase;
  bool get isIdle => _phase == SosPhase.idle;
  bool get isCountingDown => _phase == SosPhase.countdown;
  bool get isDispatching => _phase == SosPhase.dispatching;
  bool get isActive => _phase == SosPhase.active;

  /// True while an emergency is running in any form.
  bool get isEmergencyInProgress => _phase != SosPhase.idle;

  int get countdownRemaining => _countdownRemaining;
  int get countdownTotal => _countdownTotal;

  /// 0.0 .. 1.0 - drives the circular countdown animation.
  double get countdownProgress {
    if (_countdownTotal == 0) return 0;
    return 1 - (_countdownRemaining / _countdownTotal);
  }

  List<EmergencyContact> get notifiedContacts =>
      List<EmergencyContact>.unmodifiable(_notifiedContacts);

  EmergencyEvent? get activeEvent => _activeEvent;
  DateTime? get activatedAt => _activatedAt;
  Duration get elapsed => _elapsed;

  /// Newest first.
  List<EmergencyEvent> get history {
    final List<EmergencyEvent> sorted = List<EmergencyEvent>.from(_history)
      ..sort(
        (EmergencyEvent a, EmergencyEvent b) =>
            b.startedAt.compareTo(a.startedAt),
      );
    return List<EmergencyEvent>.unmodifiable(sorted);
  }

  List<EmergencyEvent> get recentActivity => history.take(3).toList();

  int get totalAlerts => _history
      .where((EmergencyEvent e) => e.type == EmergencyEventType.sosAlert)
      .length;

  int get resolvedCount => _history
      .where((EmergencyEvent e) => e.status == EmergencyEventStatus.resolved)
      .length;

  /// Attaches the providers the SOS flow depends on. Called by the
  /// `ChangeNotifierProxyProvider` in `main.dart` on every rebuild.
  void attach({
    required ContactsProvider contacts,
    required LocationProvider location,
    required NotificationsProvider notifications,
  }) {
    _contacts = contacts;
    _location = location;
    _notifications = notifications;
  }

  // --------------------------------------------------------------- History
  void _loadHistory() {
    final List<Map<String, dynamic>>? saved = _store.readJsonList(
      StoreKeys.events,
    );
    if (saved == null) {
      _history = DemoData.history();
      _persistHistory();
      return;
    }
    try {
      _history = saved.map(EmergencyEvent.fromJson).toList();
      // A previous session may have been closed while an alert was active.
      _history = _history
          .map(
            (EmergencyEvent e) => e.status == EmergencyEventStatus.active
                ? e.copyWith(
                    status: EmergencyEventStatus.resolved,
                    endedAt: e.endedAt ?? e.startedAt,
                  )
                : e,
          )
          .toList();
    } catch (_) {
      _history = DemoData.history();
    }
  }

  Future<void> _persistHistory() => _store.writeJsonList(
    StoreKeys.events,
    _history.map((EmergencyEvent e) => e.toJson()).toList(),
  );

  void _addEvent(EmergencyEvent event) {
    _history = <EmergencyEvent>[event, ..._history];
    _persistHistory();
  }

  void _replaceEvent(EmergencyEvent event) {
    final int index = _history.indexWhere(
      (EmergencyEvent e) => e.id == event.id,
    );
    if (index == -1) {
      _addEvent(event);
      return;
    }
    _history = List<EmergencyEvent>.from(_history);
    _history[index] = event;
    _persistHistory();
  }

  void deleteEvent(String id) {
    _history = _history.where((EmergencyEvent e) => e.id != id).toList();
    notifyListeners();
    _persistHistory();
  }

  void clearHistory() {
    _history = <EmergencyEvent>[];
    notifyListeners();
    _persistHistory();
  }

  void resetToDemoData() {
    _cancelTimers();
    _phase = SosPhase.idle;
    _activeEvent = null;
    _notifiedContacts.clear();
    _history = DemoData.history();
    notifyListeners();
    _persistHistory();
  }

  /// Records a non-SOS event such as a service call or a safety check-in.
  void logEvent({
    required EmergencyEventType type,
    required String note,
    List<String> notifiedContactNames = const <String>[],
    bool locationShared = false,
  }) {
    final LocationProvider? location = _location;
    _addEvent(
      EmergencyEvent(
        id: 'event-${DateTime.now().microsecondsSinceEpoch}',
        type: type,
        startedAt: DateTime.now(),
        endedAt: DateTime.now(),
        locationLabel: location?.status.addressLabel ?? 'Location unavailable',
        latitude: location?.status.latitude ?? 0,
        longitude: location?.status.longitude ?? 0,
        status: EmergencyEventStatus.resolved,
        notifiedContactNames: notifiedContactNames,
        locationShared: locationShared,
        note: note,
      ),
    );
    notifyListeners();
  }

  // ------------------------------------------------------------- SOS flow
  /// Starts the cancellable countdown.
  ///
  /// Returns [SosStartOutcome.noContacts] when the user has not added a
  /// trusted contact yet - the screen then shows a friendly message asking
  /// them to add one before using SOS.
  SosStartOutcome startCountdown({int seconds = 5, bool shareLocation = true}) {
    if (_phase != SosPhase.idle) return SosStartOutcome.alreadyRunning;

    final ContactsProvider? contacts = _contacts;
    if (contacts == null || contacts.isEmpty) {
      return SosStartOutcome.noContacts;
    }

    _shareLocationOnActivation = shareLocation;
    _countdownTotal = seconds;
    _countdownRemaining = seconds;
    _phase = SosPhase.countdown;
    _notifiedContacts.clear();
    notifyListeners();

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      _countdownRemaining--;
      if (_countdownRemaining <= 0) {
        timer.cancel();
        _countdownRemaining = 0;
        notifyListeners();
        _activate(shareLocation: _shareLocationOnActivation);
      } else {
        notifyListeners();
      }
    });

    return SosStartOutcome.started;
  }

  /// Cancels the alert during the countdown and records the attempt.
  void cancelCountdown() {
    if (_phase != SosPhase.countdown) return;
    _cancelTimers();
    _phase = SosPhase.idle;

    final LocationProvider? location = _location;
    _addEvent(
      EmergencyEvent(
        id: 'event-${DateTime.now().microsecondsSinceEpoch}',
        type: EmergencyEventType.sosAlert,
        startedAt: DateTime.now(),
        endedAt: DateTime.now(),
        locationLabel: location?.status.addressLabel ?? 'Location unavailable',
        latitude: location?.status.latitude ?? 0,
        longitude: location?.status.longitude ?? 0,
        status: EmergencyEventStatus.cancelled,
        note: 'Alert cancelled during the countdown. No contact was notified.',
      ),
    );

    _notifications?.push(
      type: NotificationType.sos,
      title: 'SOS alert cancelled',
      message: 'The countdown was stopped. No trusted contact was notified.',
    );

    notifyListeners();
  }

  /// Fires the alert: notify contacts, share location, record the event.
  Future<void> _activate({bool shareLocation = true}) async {
    final ContactsProvider? contacts = _contacts;
    final LocationProvider? location = _location;
    if (contacts == null || contacts.isEmpty) {
      _phase = SosPhase.idle;
      notifyListeners();
      return;
    }

    _phase = SosPhase.dispatching;
    _notifiedContacts.clear();
    _activatedAt = DateTime.now();
    _elapsed = Duration.zero;
    notifyListeners();

    final bool sharing =
        shareLocation &&
        (location?.startSharing(
              contacts.contacts.map((EmergencyContact c) => c.name).toList(),
            ) ??
            false);

    final EmergencyEvent event = EmergencyEvent(
      id: 'event-${DateTime.now().microsecondsSinceEpoch}',
      type: EmergencyEventType.sosAlert,
      startedAt: _activatedAt!,
      locationLabel: location?.status.addressLabel ?? 'Location unavailable',
      latitude: location?.status.latitude ?? 0,
      longitude: location?.status.longitude ?? 0,
      status: EmergencyEventStatus.active,
      locationShared: sharing,
      note: 'Emergency alert activated from the SecureGuard SOS screen.',
    );
    _activeEvent = event;
    _addEvent(event);

    _notifications?.push(
      type: NotificationType.sos,
      title: 'SOS alert sent',
      message: 'Your trusted contacts are being notified with your location.',
    );

    // Notify the contacts one at a time so the screen can show progress.
    await _dispatchSubscription?.cancel();
    _dispatchSubscription = _alerts
        .dispatch(contacts: contacts.contacts)
        .listen(
          (AlertDelivery delivery) {
            _notifiedContacts.add(delivery.contact);
            _activeEvent = _activeEvent?.copyWith(
              notifiedContactNames: _notifiedContacts
                  .map((EmergencyContact c) => c.name)
                  .toList(),
            );
            if (_activeEvent != null) _replaceEvent(_activeEvent!);
            notifyListeners();
          },
          onDone: () {
            if (_phase != SosPhase.dispatching) return;
            _phase = SosPhase.active;
            _startElapsedTimer();
            if (sharing) {
              _notifications?.push(
                type: NotificationType.location,
                title: 'Live location sharing started',
                message:
                    'Your trusted contacts can follow your location until you stop '
                    'sharing.',
              );
            }
            notifyListeners();
          },
        );
  }

  void _startElapsedTimer() {
    _elapsedTimer?.cancel();
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final DateTime? started = _activatedAt;
      if (started == null) return;
      _elapsed = DateTime.now().difference(started);
      notifyListeners();
    });
  }

  /// Ends a live emergency and marks the event as resolved.
  void endEmergency({String note = 'Emergency ended by the user.'}) {
    if (_phase == SosPhase.idle) return;
    _cancelTimers();

    final EmergencyEvent? event = _activeEvent;
    if (event != null) {
      _replaceEvent(
        event.copyWith(
          status: EmergencyEventStatus.resolved,
          endedAt: DateTime.now(),
          notifiedContactNames: _notifiedContacts
              .map((EmergencyContact c) => c.name)
              .toList(),
          note: note,
        ),
      );
    }

    _location?.stopSharing();
    _notifications?.push(
      type: NotificationType.sos,
      title: 'Emergency ended',
      message: 'Your contacts have been told that you are safe now.',
    );

    _phase = SosPhase.idle;
    _activeEvent = null;
    _activatedAt = null;
    _elapsed = Duration.zero;
    _notifiedContacts.clear();
    notifyListeners();
  }

  void _cancelTimers() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _elapsedTimer?.cancel();
    _elapsedTimer = null;
    _dispatchSubscription?.cancel();
    _dispatchSubscription = null;
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }
}
