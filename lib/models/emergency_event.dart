import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The kind of safety event recorded in the history log.
enum EmergencyEventType {
  sosAlert('SOS Alert', Icons.emergency_share_rounded),
  locationShare('Location Shared', Icons.my_location_rounded),
  serviceCall('Emergency Call', Icons.phone_in_talk_rounded),
  safetyCheck('Safety Check-in', Icons.verified_user_rounded);

  const EmergencyEventType(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// The life-cycle state of a recorded event.
enum EmergencyEventStatus {
  active('Active'),
  resolved('Resolved'),
  cancelled('Cancelled');

  const EmergencyEventStatus(this.label);

  final String label;

  Color get color => switch (this) {
    EmergencyEventStatus.active => AppColors.red,
    EmergencyEventStatus.resolved => AppColors.green,
    EmergencyEventStatus.cancelled => AppColors.textSecondary,
  };

  IconData get icon => switch (this) {
    EmergencyEventStatus.active => Icons.radio_button_checked_rounded,
    EmergencyEventStatus.resolved => Icons.check_circle_rounded,
    EmergencyEventStatus.cancelled => Icons.cancel_rounded,
  };
}

/// One entry in the emergency history.
class EmergencyEvent {
  const EmergencyEvent({
    required this.id,
    required this.type,
    required this.startedAt,
    required this.locationLabel,
    required this.latitude,
    required this.longitude,
    required this.status,
    this.endedAt,
    this.notifiedContactNames = const <String>[],
    this.locationShared = false,
    this.note = '',
  });

  final String id;
  final EmergencyEventType type;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String locationLabel;
  final double latitude;
  final double longitude;
  final EmergencyEventStatus status;
  final List<String> notifiedContactNames;
  final bool locationShared;
  final String note;

  /// How long the emergency stayed active, or `null` while still running.
  Duration? get duration => endedAt?.difference(startedAt);

  EmergencyEvent copyWith({
    DateTime? endedAt,
    EmergencyEventStatus? status,
    List<String>? notifiedContactNames,
    bool? locationShared,
    String? note,
  }) {
    return EmergencyEvent(
      id: id,
      type: type,
      startedAt: startedAt,
      endedAt: endedAt ?? this.endedAt,
      locationLabel: locationLabel,
      latitude: latitude,
      longitude: longitude,
      status: status ?? this.status,
      notifiedContactNames: notifiedContactNames ?? this.notifiedContactNames,
      locationShared: locationShared ?? this.locationShared,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'type': type.name,
    'startedAt': startedAt.toIso8601String(),
    'endedAt': endedAt?.toIso8601String(),
    'locationLabel': locationLabel,
    'latitude': latitude,
    'longitude': longitude,
    'status': status.name,
    'notifiedContactNames': notifiedContactNames,
    'locationShared': locationShared,
    'note': note,
  };

  factory EmergencyEvent.fromJson(Map<String, dynamic> json) => EmergencyEvent(
    id: json['id'] as String,
    type: EmergencyEventType.values.firstWhere(
      (EmergencyEventType t) => t.name == json['type'],
      orElse: () => EmergencyEventType.sosAlert,
    ),
    startedAt: DateTime.parse(json['startedAt'] as String),
    endedAt: json['endedAt'] == null
        ? null
        : DateTime.parse(json['endedAt'] as String),
    locationLabel: json['locationLabel'] as String,
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    status: EmergencyEventStatus.values.firstWhere(
      (EmergencyEventStatus s) => s.name == json['status'],
      orElse: () => EmergencyEventStatus.resolved,
    ),
    notifiedContactNames:
        (json['notifiedContactNames'] as List<dynamic>? ?? <dynamic>[])
            .map((dynamic e) => e as String)
            .toList(),
    locationShared: json['locationShared'] as bool? ?? false,
    note: json['note'] as String? ?? '',
  );
}
