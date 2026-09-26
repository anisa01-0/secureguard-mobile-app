import 'package:flutter/material.dart';

import '../data/local_store.dart';

/// Languages offered in Settings.
///
/// The prototype ships with English strings only; the chosen language is
/// stored and shown so the full flow can be demonstrated, and translating the
/// interface is listed as a future improvement.
enum AppLanguage {
  english('English', 'EN'),
  somali('Soomaali', 'SO'),
  arabic('العربية', 'AR');

  const AppLanguage(this.label, this.code);

  final String label;
  final String code;
}

/// Application preferences: appearance, notifications, permissions, language.
class SettingsProvider extends ChangeNotifier {
  SettingsProvider({LocalStore? store})
    : _store = store ?? LocalStore.instance {
    _load();
  }

  final LocalStore _store;

  ThemeMode _themeMode = ThemeMode.light;
  bool _notificationsEnabled = true;
  bool _emergencySoundEnabled = true;
  bool _locationPermissionGranted = true;
  bool _autoShareLocationOnSos = true;
  bool _hideContactsOnLockScreen = true;
  int _sosCountdownSeconds = 5;
  AppLanguage _language = AppLanguage.english;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get emergencySoundEnabled => _emergencySoundEnabled;
  bool get locationPermissionGranted => _locationPermissionGranted;
  bool get autoShareLocationOnSos => _autoShareLocationOnSos;
  bool get hideContactsOnLockScreen => _hideContactsOnLockScreen;
  int get sosCountdownSeconds => _sosCountdownSeconds;
  AppLanguage get language => _language;

  void _load() {
    final Map<String, dynamic>? saved = _store.readJsonMap(StoreKeys.settings);
    if (saved == null) return;
    _themeMode = saved['darkMode'] == true ? ThemeMode.dark : ThemeMode.light;
    _notificationsEnabled = saved['notifications'] as bool? ?? true;
    _emergencySoundEnabled = saved['emergencySound'] as bool? ?? true;
    _locationPermissionGranted = saved['locationPermission'] as bool? ?? true;
    _autoShareLocationOnSos = saved['autoShareLocation'] as bool? ?? true;
    _hideContactsOnLockScreen = saved['hideContacts'] as bool? ?? true;
    _sosCountdownSeconds = saved['countdown'] as int? ?? 5;
    _language = AppLanguage.values.firstWhere(
      (AppLanguage l) => l.code == saved['language'],
      orElse: () => AppLanguage.english,
    );
  }

  Future<void> _persist() {
    return _store.writeJsonMap(StoreKeys.settings, <String, dynamic>{
      'darkMode': _themeMode == ThemeMode.dark,
      'notifications': _notificationsEnabled,
      'emergencySound': _emergencySoundEnabled,
      'locationPermission': _locationPermissionGranted,
      'autoShareLocation': _autoShareLocationOnSos,
      'hideContacts': _hideContactsOnLockScreen,
      'countdown': _sosCountdownSeconds,
      'language': _language.code,
    });
  }

  void _update(VoidCallback change) {
    change();
    notifyListeners();
    _persist();
  }

  void setDarkMode(bool value) =>
      _update(() => _themeMode = value ? ThemeMode.dark : ThemeMode.light);

  void setNotificationsEnabled(bool value) =>
      _update(() => _notificationsEnabled = value);

  void setEmergencySoundEnabled(bool value) =>
      _update(() => _emergencySoundEnabled = value);

  void setLocationPermissionGranted(bool value) => _update(() {
    _locationPermissionGranted = value;
    // Sharing cannot continue without the permission.
    if (!value) _autoShareLocationOnSos = false;
  });

  void setAutoShareLocationOnSos(bool value) =>
      _update(() => _autoShareLocationOnSos = value);

  void setHideContactsOnLockScreen(bool value) =>
      _update(() => _hideContactsOnLockScreen = value);

  void setSosCountdownSeconds(int value) =>
      _update(() => _sosCountdownSeconds = value.clamp(3, 15));

  void setLanguage(AppLanguage value) => _update(() => _language = value);

  /// Restores the factory defaults (used by "Reset demo data").
  void resetToDefaults() => _update(() {
    _themeMode = ThemeMode.light;
    _notificationsEnabled = true;
    _emergencySoundEnabled = true;
    _locationPermissionGranted = true;
    _autoShareLocationOnSos = true;
    _hideContactsOnLockScreen = true;
    _sosCountdownSeconds = 5;
    _language = AppLanguage.english;
  });
}
