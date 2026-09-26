import 'dart:async';

import 'package:flutter/material.dart';

import '../models/location_status.dart';
import '../services/location_service.dart';

/// Holds the current (simulated) position and the location-sharing state.
class LocationProvider extends ChangeNotifier {
  LocationProvider({LocationService? service})
    : _service = service ?? LocationService() {
    final LocationReading first = _service.initialReading();
    _status = LocationStatus(
      latitude: first.latitude,
      longitude: first.longitude,
      addressLabel: first.addressLabel,
      accuracyMeters: first.accuracyMeters,
      updatedAt: DateTime.now(),
    );
  }

  final LocationService _service;
  Timer? _ticker;

  late LocationStatus _status;
  bool _isLocating = false;

  LocationStatus get status => _status;
  bool get isSharing => _status.isSharing;
  bool get isLocating => _isLocating;
  bool get permissionGranted => _status.permissionGranted;

  /// A short link a trusted contact would open to see the position.
  String get shareLink =>
      LocationService.shareLink(_status.latitude, _status.longitude);

  void _emit(LocationStatus next) {
    _status = next;
    notifyListeners();
  }

  /// Fetches a fresh position (used by the "Refresh" button).
  Future<void> refresh() async {
    if (!_status.permissionGranted) return;
    _isLocating = true;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 700));
    final LocationReading reading = _service.nextReading();
    _isLocating = false;
    _emit(
      _status.copyWith(
        latitude: reading.latitude,
        longitude: reading.longitude,
        addressLabel: reading.addressLabel,
        accuracyMeters: reading.accuracyMeters,
        updatedAt: DateTime.now(),
      ),
    );
  }

  /// Asks for the location permission (simulated).
  Future<bool> requestPermission() async {
    final bool granted = await _service.requestPermission();
    _emit(_status.copyWith(permissionGranted: granted));
    return granted;
  }

  void setPermissionGranted(bool granted) {
    if (_status.permissionGranted == granted) return;
    if (!granted) stopSharing();
    _emit(_status.copyWith(permissionGranted: granted));
  }

  /// Starts live sharing with the given trusted contacts.
  ///
  /// Returns `false` when the location permission is switched off.
  bool startSharing(List<String> contactNames) {
    if (!_status.permissionGranted) return false;
    _emit(
      _status.copyWith(
        isSharing: true,
        sharedWith: contactNames,
        updatedAt: DateTime.now(),
      ),
    );
    _startTicker();
    return true;
  }

  void stopSharing() {
    _stopTicker();
    if (!_status.isSharing) return;
    _emit(
      _status.copyWith(
        isSharing: false,
        sharedWith: const <String>[],
        updatedAt: DateTime.now(),
      ),
    );
  }

  /// Updates the position every few seconds while sharing is active, so the
  /// marker on the map screen visibly moves during the demonstration.
  void _startTicker() {
    _stopTicker();
    _ticker = Timer.periodic(const Duration(seconds: 5), (_) {
      final LocationReading reading = _service.nextReading();
      _emit(
        _status.copyWith(
          latitude: reading.latitude,
          longitude: reading.longitude,
          addressLabel: reading.addressLabel,
          accuracyMeters: reading.accuracyMeters,
          updatedAt: DateTime.now(),
        ),
      );
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  @override
  void dispose() {
    _stopTicker();
    super.dispose();
  }
}
