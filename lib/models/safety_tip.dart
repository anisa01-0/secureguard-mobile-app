import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Grouping used by the Safety Tips screen.
enum SafetyTipCategory {
  personal('Personal Safety', Icons.shield_moon_rounded, AppColors.navy),
  travel('Travel Safety', Icons.directions_bus_filled_rounded, AppColors.blue),
  night('Night Safety', Icons.nightlight_round, AppColors.navySoft),
  online('Online Safety', Icons.wifi_password_rounded, AppColors.green),
  preparedness(
    'Emergency Preparedness',
    Icons.medical_services_rounded,
    AppColors.amber,
  );

  const SafetyTipCategory(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;
}

/// A single piece of safety advice shown as a card.
class SafetyTip {
  const SafetyTip({
    required this.id,
    required this.category,
    required this.title,
    required this.body,
  });

  final String id;
  final SafetyTipCategory category;
  final String title;
  final String body;

  IconData get icon => category.icon;
  Color get color => category.color;
}
