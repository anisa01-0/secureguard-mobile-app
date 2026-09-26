import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Category used to group the public emergency services screen.
enum EmergencyServiceCategory {
  police('Police', Icons.local_police_rounded, AppColors.navy),
  ambulance('Ambulance', Icons.emergency_rounded, AppColors.red),
  fire('Fire Department', Icons.local_fire_department_rounded, AppColors.amber),
  hotline('Emergency Hotline', Icons.support_agent_rounded, AppColors.green);

  const EmergencyServiceCategory(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;
}

/// A public service the user can call directly from the app.
///
/// NOTE: every number bundled with this prototype is a clearly fictional
/// demo number. Real deployments must load verified local numbers.
class EmergencyService {
  const EmergencyService({
    required this.id,
    required this.name,
    required this.category,
    required this.phoneNumber,
    required this.description,
    this.availability = '24 hours',
  });

  final String id;
  final String name;
  final EmergencyServiceCategory category;
  final String phoneNumber;
  final String description;
  final String availability;

  IconData get icon => category.icon;
  Color get color => category.color;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'category': category.name,
    'phoneNumber': phoneNumber,
    'description': description,
    'availability': availability,
  };

  factory EmergencyService.fromJson(Map<String, dynamic> json) =>
      EmergencyService(
        id: json['id'] as String,
        name: json['name'] as String,
        category: EmergencyServiceCategory.values.firstWhere(
          (EmergencyServiceCategory c) => c.name == json['category'],
          orElse: () => EmergencyServiceCategory.hotline,
        ),
        phoneNumber: json['phoneNumber'] as String,
        description: json['description'] as String,
        availability: json['availability'] as String? ?? '24 hours',
      );
}
