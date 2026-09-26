import 'package:flutter/material.dart';

import '../data/local_store.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';

/// Where the user is in the authentication flow.
enum AuthStatus { unknown, signedOut, signedIn }

/// Owns the signed-in user and the sign-in / registration operations.
class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? service, LocalStore? store})
    : _service = service ?? AuthService(),
      _store = store ?? LocalStore.instance;

  final AuthService _service;
  final LocalStore _store;

  AuthStatus _status = AuthStatus.unknown;
  AppUser? _user;
  bool _isBusy = false;
  String? _errorMessage;
  bool _rememberMe = true;

  AuthStatus get status => _status;
  AppUser? get user => _user;
  bool get isBusy => _isBusy;
  String? get errorMessage => _errorMessage;
  bool get isSignedIn => _status == AuthStatus.signedIn && _user != null;
  bool get rememberMe => _rememberMe;

  /// The email pre-filled on the login screen when "Remember me" was used.
  String get rememberedEmail =>
      _store.readString(StoreKeys.rememberedEmail) ?? '';

  bool get hasSeenOnboarding =>
      _store.readBool(StoreKeys.onboardingSeen) ?? false;

  Future<void> markOnboardingSeen() =>
      _store.writeBool(StoreKeys.onboardingSeen, true);

  /// Restores a previous session, if the user asked to stay signed in.
  Future<void> restoreSession() async {
    final bool wasSignedIn = _store.readBool(StoreKeys.isLoggedIn) ?? false;
    final Map<String, dynamic>? saved = _store.readJsonMap(StoreKeys.user);
    if (wasSignedIn && saved != null) {
      try {
        _user = AppUser.fromJson(saved);
        _status = AuthStatus.signedIn;
        _rememberMe = true;
      } catch (_) {
        _status = AuthStatus.signedOut;
      }
    } else {
      _status = AuthStatus.signedOut;
    }
    notifyListeners();
  }

  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  void _begin() {
    _isBusy = true;
    _errorMessage = null;
    notifyListeners();
  }

  /// Runs an authentication operation and maps failures to a friendly message.
  Future<bool> _run(Future<AppUser?> Function() operation) async {
    _begin();
    try {
      final AppUser? user = await operation();
      if (user != null) {
        _user = user;
        _status = AuthStatus.signedIn;
        await _persistSession(user);
      }
      _isBusy = false;
      notifyListeners();
      return true;
    } on AuthException catch (error) {
      _errorMessage = error.message;
      _isBusy = false;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage =
          'Something went wrong. Please check your details and try again.';
      _isBusy = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({required String email, required String password}) {
    return _run(() => _service.signIn(email: email, password: password));
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) {
    return _run(
      () => _service.register(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
      ),
    );
  }

  Future<bool> sendPasswordReset(String email) async {
    _begin();
    try {
      await _service.sendPasswordReset(email);
      _isBusy = false;
      notifyListeners();
      return true;
    } catch (_) {
      _errorMessage = 'We could not send the reset link. Please try again.';
      _isBusy = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final AppUser? current = _user;
    if (current == null) return false;
    _begin();
    try {
      await _service.changePassword(
        email: current.email,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      _isBusy = false;
      notifyListeners();
      return true;
    } on AuthException catch (error) {
      _errorMessage = error.message;
      _isBusy = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> updateProfile({
    required String fullName,
    required String email,
    required String phone,
    String? bloodGroup,
    String? address,
  }) async {
    final AppUser? current = _user;
    if (current == null) return;
    final AppUser updated = current.copyWith(
      fullName: fullName,
      email: email,
      phone: phone,
      bloodGroup: bloodGroup,
      address: address,
    );
    _user = updated;
    notifyListeners();
    await _service.saveProfile(updated);
  }

  Future<void> _persistSession(AppUser user) async {
    await _store.writeJsonMap(StoreKeys.user, user.toJson());
    await _store.writeBool(StoreKeys.isLoggedIn, _rememberMe);
    if (_rememberMe) {
      await _store.writeString(StoreKeys.rememberedEmail, user.email);
    } else {
      await _store.remove(StoreKeys.rememberedEmail);
    }
  }

  Future<void> signOut() async {
    _user = null;
    _status = AuthStatus.signedOut;
    _errorMessage = null;
    notifyListeners();
    await _store.writeBool(StoreKeys.isLoggedIn, false);
  }
}
