import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The kind of message shown in the notification centre.
enum NotificationType {
  sos('Emergency', Icons.emergency_share_rounded, AppColors.red),
  contact('Contacts', Icons.group_rounded, AppColors.blue),
  location('Location', Icons.location_on_rounded, AppColors.green),
  reminder('Safety Reminder', Icons.lightbulb_rounded, AppColors.amber),
  system('System', Icons.info_rounded, AppColors.navy);

  const NotificationType(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;
}

/// An in-app notification.
///
/// SecureGuard generates these locally when the user performs an action; the
/// prototype does not use a push-notification backend.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
  });

  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;

  AppNotification copyWith({bool? isRead}) => AppNotification(
    id: id,
    type: type,
    title: title,
    message: message,
    createdAt: createdAt,
    isRead: isRead ?? this.isRead,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'type': type.name,
    'title': title,
    'message': message,
    'createdAt': createdAt.toIso8601String(),
    'isRead': isRead,
  };

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'] as String,
        type: NotificationType.values.firstWhere(
          (NotificationType t) => t.name == json['type'],
          orElse: () => NotificationType.system,
        ),
        title: json['title'] as String,
        message: json['message'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        isRead: json['isRead'] as bool? ?? false,
      );
}
