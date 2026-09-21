import 'package:flutter_test/flutter_test.dart';
import 'package:secureguard/utils/validators.dart';

/// Unit tests for the shared form-validation rules.
void main() {
  group('Email validation', () {
    test('rejects an empty address with a friendly message', () {
      expect(Validators.email(''), 'Please enter your email address.');
      expect(Validators.email(null), 'Please enter your email address.');
    });

    test('rejects a malformed address', () {
      expect(Validators.email('anisa'), isNotNull);
      expect(Validators.email('anisa@'), isNotNull);
      expect(Validators.email('anisa@example'), isNotNull);
      expect(Validators.email('@example.com'), isNotNull);
    });

    test('accepts a valid address, ignoring surrounding spaces', () {
      expect(Validators.email('anisa@example.com'), isNull);
      expect(Validators.email('  anisa@example.com  '), isNull);
      expect(Validators.email('a.b+tag@mail.co.uk'), isNull);
    });
  });

  group('Password validation', () {
    test('sign-in only requires a non-empty value', () {
      expect(Validators.loginPassword(''), 'Please enter your password.');
      expect(Validators.loginPassword('x'), isNull);
    });

    test('registration rejects short or weak passwords', () {
      expect(Validators.newPassword('abc'), isNotNull);
      expect(Validators.newPassword('12345678'), isNotNull); // no letter
      expect(Validators.newPassword('abcdefgh'), isNotNull); // no number
    });

    test('registration accepts a password with letters and numbers', () {
      expect(Validators.newPassword('Secure123'), isNull);
    });

    test('confirmation must match exactly', () {
      expect(
        Validators.confirmPassword('Secure123', 'Secure124'),
        'Passwords do not match.',
      );
      expect(Validators.confirmPassword('Secure123', 'Secure123'), isNull);
      expect(Validators.confirmPassword('', 'Secure123'), isNotNull);
    });

    test('strength meter grows with complexity', () {
      expect(Validators.passwordStrength(''), 0);
      expect(Validators.passwordStrength('abc12'), lessThan(2));
      expect(
        Validators.passwordStrength('Str0ng!Passw0rd'),
        greaterThanOrEqualTo(3),
      );
      expect(Validators.passwordStrengthLabel(''), 'Enter a password');
    });
  });

  group('Phone validation', () {
    test('rejects empty and clearly invalid numbers', () {
      expect(Validators.phone(''), 'Please enter a phone number.');
      expect(Validators.phone('123'), isNotNull);
      expect(Validators.phone('not-a-number'), isNotNull);
    });

    test('accepts numbers with spaces, dashes and a country code', () {
      expect(Validators.phone('+252 61 234 5678'), isNull);
      expect(Validators.phone('0612345678'), isNull);
      expect(Validators.phone('(061) 234-5678'), isNull);
    });
  });

  group('Name validation', () {
    test('requires a first and last name', () {
      expect(Validators.fullName(''), 'Please enter your full name.');
      expect(Validators.fullName('Anisa'), isNotNull);
      expect(Validators.fullName('Anisa Abdi'), isNull);
    });
  });

  group('Required fields', () {
    test('names the field in the message', () {
      expect(
        Validators.required('', field: "the contact's name"),
        "Please enter the contact's name.",
      );
      expect(Validators.required('Halima'), isNull);
    });
  });
}
