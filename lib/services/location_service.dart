import 'dart:async';
import 'dart:math' as math;

/// A single simulated GPS reading.
class LocationReading {
  const LocationReading({
    required this.latitude,
    required this.longitude,
    required this.addressLabel,
    required this.accuracyMeters,
  });

  final double latitude;
  final double longitude;
  final String addressLabel;
  final double accuracyMeters;
}

/// Produces a realistic, repeatable stream of location updates.
///
/// The prototype does not use a real GPS plugin or a paid map SDK. Instead it
/// simulates a device slowly moving around a fixed area so that the map
/// screen, the location-sharing flow and the SOS alert can all be
/// demonstrated on any device - including a desktop emulator or a browser.
class LocationService {
  LocationService({math.Random? random})
    : _random = random ?? math.Random(2026);

  final math.Random _random;

  /// Starting point of the simulation (central Mogadishu).
  static const double _baseLatitude = 2.046100;
  static const double _baseLongitude = 45.318200;

  static const List<String> _places = <String>[
    'Maka Al Mukarama Road, Mogadishu',
    'University Campus, Hodan District',
    'Hodan District, Mogadishu',
    'Wadajir District, Mogadishu',
    'Bakara Market Area, Mogadishu',
  ];

  int _tick = 0;

  /// The very first reading, available immediately at start-up.
  LocationReading initialReading() => const LocationReading(
    latitude: _baseLatitude,
    longitude: _baseLongitude,
    addressLabel: 'University Campus, Hodan District',
    accuracyMeters: 8,
  );

  /// Produces the next reading, drifting slightly from the previous one.
  LocationReading nextReading() {
    _tick++;
    // A small circular drift keeps the marker moving in a natural way.
    final double angle = _tick * 0.45;
    final double radius = 0.0009 + _random.nextDouble() * 0.0004;

    return LocationReading(
      latitude: _baseLatitude + math.sin(angle) * radius,
      longitude: _baseLongitude + math.cos(angle) * radius,
      addressLabel: _places[(_tick ~/ 4) % _places.length],
      accuracyMeters: 5 + _random.nextDouble() * 9,
    );
  }

  /// Emits a new reading every [interval] while the stream has a listener.
  Stream<LocationReading> watch({
    Duration interval = const Duration(seconds: 4),
  }) async* {
    yield initialReading();
    while (true) {
      await Future<void>.delayed(interval);
      yield nextReading();
    }
  }

  /// Simulates asking the operating system for the location permission.
  Future<bool> requestPermission() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return true;
  }

  /// Builds the map link a trusted contact would receive by SMS.
  static String shareLink(double latitude, double longitude) =>
      'https://maps.google.com/?q='
      '${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}';
}
