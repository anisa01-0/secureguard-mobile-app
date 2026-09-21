/// Form validation rules shared by every input in SecureGuard.
///
/// Each method returns `null` when the value is acceptable, or a short,
/// friendly message that is shown directly under the field.
class Validators {
  const Validators._();

  static final RegExp _emailPattern = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]{2,}$');

  /// Digits, optionally preceded by a country code: +252 61 234 5678.
  static final RegExp _phonePattern = RegExp(r'^\+?[0-9]{7,15}$');

  static String? required(String? value, {String field = 'this field'}) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $field.';
    }
    return null;
  }

  static String? fullName(String? value) {
    final String name = (value ?? '').trim();
    if (name.isEmpty) return 'Please enter your full name.';
    if (name.length < 3) return 'Your name looks too short.';
    if (!name.contains(' ')) {
      return 'Please enter both your first and last name.';
    }
    return null;
  }

  static String? email(String? value) {
    final String email = (value ?? '').trim();
    if (email.isEmpty) return 'Please enter your email address.';
    if (!_emailPattern.hasMatch(email)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  static String? phone(String? value) {
    final String raw = (value ?? '').trim();
    if (raw.isEmpty) return 'Please enter a phone number.';
    final String cleaned = raw.replaceAll(RegExp(r'[\s\-()]'), '');
    if (!_phonePattern.hasMatch(cleaned)) {
      return 'Enter a valid phone number, e.g. +252 61 234 5678.';
    }
    return null;
  }

  /// Sign-in only checks that something was typed, so a demo account with a
  /// short password can still be used during the presentation.
  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your password.';
    return null;
  }

  /// Registration enforces a minimum strength.
  static String? newPassword(String? value) {
    final String password = value ?? '';
    if (password.isEmpty) return 'Please create a password.';
    if (password.length < 8) {
      return 'Password must be at least 8 characters long.';
    }
    if (!password.contains(RegExp(r'[A-Za-z]'))) {
      return 'Password must include at least one letter.';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must include at least one number.';
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password.';
    }
    if (value != original) return 'Passwords do not match.';
    return null;
  }

  /// 0 (empty) .. 4 (strong) - drives the strength meter on sign up.
  static int passwordStrength(String password) {
    if (password.isEmpty) return 0;
    int score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]'))) {
      score++;
    }
    if (password.contains(RegExp(r'[0-9]')) &&
        password.contains(RegExp(r'[^A-Za-z0-9]'))) {
      score++;
    }
    return score.clamp(0, 4);
  }

  static String passwordStrengthLabel(String password) {
    return switch (passwordStrength(password)) {
      0 => 'Enter a password',
      1 => 'Weak password',
      2 => 'Fair password',
      3 => 'Good password',
      _ => 'Strong password',
    };
  }
}
