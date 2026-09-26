import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A thin, safe wrapper around `SharedPreferences`.
///
/// Every method swallows storage errors and falls back to an in-memory copy,
/// so the application keeps working even when the platform has no storage
/// available (for example inside a widget test).
class LocalStore {
  LocalStore._();

  static final LocalStore instance = LocalStore._();

  SharedPreferences? _prefs;
  final Map<String, String> _memory = <String, String>{};
  bool _initialised = false;

  /// Called once from `main()` before the app is built.
  Future<void> init() async {
    if (_initialised) return;
    _initialised = true;
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (error) {
      // Storage is unavailable (unsupported platform, restricted sandbox...).
      // The in-memory map keeps the session working for the demonstration.
      debugPrint('SecureGuard: local storage unavailable, using memory only.');
      _prefs = null;
    }
  }

  // ------------------------------------------------------------- Primitives
  String? readString(String key) {
    try {
      return _prefs?.getString(key) ?? _memory[key];
    } catch (_) {
      return _memory[key];
    }
  }

  Future<void> writeString(String key, String value) async {
    _memory[key] = value;
    try {
      await _prefs?.setString(key, value);
    } catch (_) {
      // Ignored on purpose: the in-memory copy is already up to date.
    }
  }

  bool? readBool(String key) {
    try {
      final bool? stored = _prefs?.getBool(key);
      if (stored != null) return stored;
    } catch (_) {
      // fall through to the memory copy
    }
    final String? cached = _memory[key];
    if (cached == null) return null;
    return cached == 'true';
  }

  Future<void> writeBool(String key, bool value) async {
    _memory[key] = value.toString();
    try {
      await _prefs?.setBool(key, value);
    } catch (_) {
      // Ignored on purpose.
    }
  }

  Future<void> remove(String key) async {
    _memory.remove(key);
    try {
      await _prefs?.remove(key);
    } catch (_) {
      // Ignored on purpose.
    }
  }

  // ------------------------------------------------------------------ JSON
  /// Reads a stored list of JSON objects. Returns `null` when nothing has been
  /// saved yet (which tells a provider to fall back to the demo data).
  List<Map<String, dynamic>>? readJsonList(String key) {
    final String? raw = readString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! List) return null;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map((Map<String, dynamic> e) => e)
          .toList();
    } catch (error) {
      debugPrint(
        'SecureGuard: could not read "$key" ($error). Using defaults.',
      );
      return null;
    }
  }

  Future<void> writeJsonList(
    String key,
    List<Map<String, dynamic>> value,
  ) async {
    try {
      await writeString(key, jsonEncode(value));
    } catch (error) {
      debugPrint('SecureGuard: could not save "$key" ($error).');
    }
  }

  Map<String, dynamic>? readJsonMap(String key) {
    final String? raw = readString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (error) {
      debugPrint(
        'SecureGuard: could not read "$key" ($error). Using defaults.',
      );
      return null;
    }
  }

  Future<void> writeJsonMap(String key, Map<String, dynamic> value) async {
    try {
      await writeString(key, jsonEncode(value));
    } catch (error) {
      debugPrint('SecureGuard: could not save "$key" ($error).');
    }
  }

  /// Clears every SecureGuard key. Used by "Reset demo data" in Settings.
  Future<void> clearAll() async {
    _memory.clear();
    try {
      await _prefs?.clear();
    } catch (_) {
      // Ignored on purpose.
    }
  }
}

/// Storage keys, grouped so they are easy to audit.
class StoreKeys {
  const StoreKeys._();

  static const String onboardingSeen = 'sg_onboarding_seen';
  static const String rememberedEmail = 'sg_remembered_email';
  static const String isLoggedIn = 'sg_is_logged_in';
  static const String user = 'sg_user';
  static const String registeredAccounts = 'sg_registered_accounts';
  static const String contacts = 'sg_contacts';
  static const String events = 'sg_events';
  static const String notifications = 'sg_notifications';
  static const String settings = 'sg_settings';
}
