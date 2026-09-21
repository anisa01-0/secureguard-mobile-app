import '../data/demo_data.dart';
import '../data/local_store.dart';
import '../models/app_user.dart';

/// Thrown when sign-in or registration cannot be completed.
///
/// The message is written for the user, not the developer, so screens can
/// show it directly.
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// A locally stored account record.
class _Account {
  const _Account({required this.user, required this.password});

  final AppUser user;
  final String password;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'user': user.toJson(),
    'password': password,
  };

  factory _Account.fromJson(Map<String, dynamic> json) => _Account(
    user: AppUser.fromJson(json['user'] as Map<String, dynamic>),
    password: json['password'] as String,
  );
}

/// Handles registration and sign-in for the prototype.
///
/// IMPORTANT (university prototype): accounts are kept on the device only.
/// There is no server, no encryption at rest and no password hashing - the
/// flow demonstrates the user experience of a secure sign-in, not a
/// production-grade authentication system. This limitation is documented in
/// the About & Privacy screen and in the README.
class AuthService {
  AuthService({LocalStore? store}) : _store = store ?? LocalStore.instance;

  final LocalStore _store;

  /// A short delay makes the loading indicators visible during the demo.
  static const Duration _simulatedLatency = Duration(milliseconds: 900);

  List<_Account> _loadAccounts() {
    final List<Map<String, dynamic>>? raw = _store.readJsonList(
      StoreKeys.registeredAccounts,
    );
    if (raw == null) return <_Account>[];
    return raw.map(_Account.fromJson).toList();
  }

  Future<void> _saveAccounts(List<_Account> accounts) {
    return _store.writeJsonList(
      StoreKeys.registeredAccounts,
      accounts.map((_Account a) => a.toJson()).toList(),
    );
  }

  /// Signs a user in with the built-in demo account or a locally registered
  /// account. Throws [AuthException] with a friendly message on failure.
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(_simulatedLatency);

    final String normalised = email.trim().toLowerCase();

    // The demo account is matched on the email alone, so that a mistyped
    // password reports "incorrect password" rather than "no account found".
    if (normalised == DemoData.demoEmail) {
      if (password != DemoData.demoPassword) {
        throw const AuthException('Incorrect password. Please try again.');
      }
      return DemoData.demoUser;
    }

    final List<_Account> accounts = _loadAccounts();
    for (final _Account account in accounts) {
      if (account.user.email.toLowerCase() == normalised) {
        if (account.password != password) {
          throw const AuthException('Incorrect password. Please try again.');
        }
        return account.user;
      }
    }

    throw const AuthException(
      'No account found for that email address. '
      'Create an account, or use the demo account shown below.',
    );
  }

  /// Registers a new local account.
  Future<AppUser> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    await Future<void>.delayed(_simulatedLatency);

    final String normalised = email.trim().toLowerCase();
    if (normalised == DemoData.demoEmail) {
      throw const AuthException(
        'That email address is reserved for the demo account.',
      );
    }

    final List<_Account> accounts = _loadAccounts();
    final bool exists = accounts.any(
      (_Account a) => a.user.email.toLowerCase() == normalised,
    );
    if (exists) {
      throw const AuthException(
        'An account already exists for that email address.',
      );
    }

    final AppUser user = AppUser(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName.trim(),
      email: email.trim(),
      phone: phone.trim(),
    );

    accounts.add(_Account(user: user, password: password));
    await _saveAccounts(accounts);
    return user;
  }

  /// Updates the password of a locally registered account.
  ///
  /// The demo account keeps a fixed password so the presentation credentials
  /// always work.
  Future<void> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    await Future<void>.delayed(_simulatedLatency);

    final String normalised = email.trim().toLowerCase();

    if (normalised == DemoData.demoEmail) {
      if (currentPassword != DemoData.demoPassword) {
        throw const AuthException('Your current password is incorrect.');
      }
      throw const AuthException(
        'The demo account password cannot be changed so that the '
        'presentation credentials keep working.',
      );
    }

    final List<_Account> accounts = _loadAccounts();
    final int index = accounts.indexWhere(
      (_Account a) => a.user.email.toLowerCase() == normalised,
    );
    if (index == -1) {
      throw const AuthException('We could not find your account.');
    }
    if (accounts[index].password != currentPassword) {
      throw const AuthException('Your current password is incorrect.');
    }

    accounts[index] = _Account(
      user: accounts[index].user,
      password: newPassword,
    );
    await _saveAccounts(accounts);
  }

  /// Simulates sending a password-reset email.
  Future<void> sendPasswordReset(String email) async {
    await Future<void>.delayed(_simulatedLatency);
    // A real application would call a backend here. The prototype always
    // reports success and never reveals whether an account exists, which is
    // the same behaviour a privacy-conscious real service would have.
  }

  /// Persists the updated profile of the signed-in user.
  Future<void> saveProfile(AppUser user) async {
    final List<_Account> accounts = _loadAccounts();
    final int index = accounts.indexWhere((_Account a) => a.user.id == user.id);
    if (index != -1) {
      accounts[index] = _Account(
        user: user,
        password: accounts[index].password,
      );
      await _saveAccounts(accounts);
    }
    await _store.writeJsonMap(StoreKeys.user, user.toJson());
  }
}
