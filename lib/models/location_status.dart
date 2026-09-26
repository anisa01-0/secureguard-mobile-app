/// A snapshot of where the user is and whether that position is being shared.
///
/// In this prototype the coordinates come from a simulated GPS feed
/// (see `LocationService`) so the app can be demonstrated on any device,
/// including a desktop emulator with no location hardware.
class LocationStatus {
  const LocationStatus({
    required this.latitude,
    required this.longitude,
    required this.addressLabel,
    required this.accuracyMeters,
    required this.updatedAt,
    this.isSharing = false,
    this.permissionGranted = true,
    this.sharedWith = const <String>[],
  });

  final double latitude;
  final double longitude;
  final String addressLabel;
  final double accuracyMeters;
  final DateTime updatedAt;
  final bool isSharing;
  final bool permissionGranted;

  /// Names of the trusted contacts currently receiving the live location.
  final List<String> sharedWith;

  /// Human readable coordinate pair, e.g. `2.046100 N, 45.318200 E`.
  String get coordinatesLabel {
    final String lat =
        '${latitude.abs().toStringAsFixed(6)} ${latitude >= 0 ? 'N' : 'S'}';
    final String lng =
        '${longitude.abs().toStringAsFixed(6)} ${longitude >= 0 ? 'E' : 'W'}';
    return '$lat, $lng';
  }

  /// A short descriptive state used by status pills across the app.
  String get statusLabel {
    if (!permissionGranted) return 'Location permission off';
    return isSharing ? 'Live location sharing on' : 'Location ready';
  }

  LocationStatus copyWith({
    double? latitude,
    double? longitude,
    String? addressLabel,
    double? accuracyMeters,
    DateTime? updatedAt,
    bool? isSharing,
    bool? permissionGranted,
    List<String>? sharedWith,
  }) {
    return LocationStatus(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      addressLabel: addressLabel ?? this.addressLabel,
      accuracyMeters: accuracyMeters ?? this.accuracyMeters,
      updatedAt: updatedAt ?? this.updatedAt,
      isSharing: isSharing ?? this.isSharing,
      permissionGranted: permissionGranted ?? this.permissionGranted,
      sharedWith: sharedWith ?? this.sharedWith,
    );
  }
}
