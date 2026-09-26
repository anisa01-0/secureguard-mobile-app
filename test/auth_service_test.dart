import 'package:flutter_test/flutter_test.dart';
import 'package:secureguard/data/demo_data.dart';
import 'package:secureguard/data/local_store.dart';
import 'package:secureguard/models/app_user.dart';
import 'package:secureguard/services/auth_service.dart';

/// Unit tests for registration, sign-in and password changes.
void main() {
  late AuthService auth;

  setUp(() async {
    await LocalStore.instance.clearAll();
    auth = AuthService();
  });

  group('Sign in', () {
    test('accepts the demonstration account', () async {
      final AppUser user = await auth.signIn(
        email: DemoData.demoEmail,
        password: DemoData.demoPassword,
      );
      expect(user.fullName, 'Anisa Abdi');
      expect(user.email, DemoData.demoEmail);
    });

    test('ignores capitalisation and spacing in the email', () async {
      final AppUser user = await auth.signIn(
        email: '  ANISA@Example.com  ',
        password: DemoData.demoPassword,
      );
      expect(user.id, DemoData.demoUser.id);
    });

    test('rejects the wrong password with a friendly message', () async {
      await expectLater(
        auth.signIn(email: DemoData.demoEmail, password: 'wrong-password'),
        throwsA(
          isA<AuthException>().having(
            (AuthException e) => e.message,
            'message',
            contains('Incorrect password'),
          ),
        ),
      );
    });

    test('rejects an unknown account and suggests what to do', () async {
      await expectLater(
        auth.signIn(email: 'nobody@example.com', password: 'Secure123'),
        throwsA(
          isA<AuthException>().having(
            (AuthException e) => e.message,
            'message',
            contains('No account found'),
          ),
        ),
      );
    });
  });

  group('Registration', () {
    test('creates an account that can then sign in', () async {
      final AppUser registered = await auth.register(
        fullName: 'Amina Ali',
        email: 'amina@example.com',
        phone: '+252 61 000 0044',
        password: 'Secure123',
      );
      expect(registered.fullName, 'Amina Ali');

      final AppUser signedIn = await auth.signIn(
        email: 'amina@example.com',
        password: 'Secure123',
      );
      expect(signedIn.id, registered.id);
    });

    test('refuses a duplicate email address', () async {
      await auth.register(
        fullName: 'Amina Ali',
        email: 'amina@example.com',
        phone: '+252 61 000 0044',
        password: 'Secure123',
      );

      await expectLater(
        auth.register(
          fullName: 'Someone Else',
          email: 'AMINA@example.com',
          phone: '+252 61 000 0055',
          password: 'Secure456',
        ),
        throwsA(
          isA<AuthException>().having(
            (AuthException e) => e.message,
            'message',
            contains('already exists'),
          ),
        ),
      );
    });

    test('protects the reserved demonstration email', () async {
      await expectLater(
        auth.register(
          fullName: 'Impostor Account',
          email: DemoData.demoEmail,
          phone: '+252 61 000 0066',
          password: 'Secure123',
        ),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('Change password', () {
    test('updates the password of a registered account', () async {
      await auth.register(
        fullName: 'Amina Ali',
        email: 'amina@example.com',
        phone: '+252 61 000 0044',
        password: 'Secure123',
      );

      await auth.changePassword(
        email: 'amina@example.com',
        currentPassword: 'Secure123',
        newPassword: 'Stronger456',
      );

      final AppUser user = await auth.signIn(
        email: 'amina@example.com',
        password: 'Stronger456',
      );
      expect(user.email, 'amina@example.com');
    });

    test('rejects an incorrect current password', () async {
      await auth.register(
        fullName: 'Amina Ali',
        email: 'amina@example.com',
        phone: '+252 61 000 0044',
        password: 'Secure123',
      );

      await expectLater(
        auth.changePassword(
          email: 'amina@example.com',
          currentPassword: 'not-the-password',
          newPassword: 'Stronger456',
        ),
        throwsA(
          isA<AuthException>().having(
            (AuthException e) => e.message,
            'message',
            contains('current password is incorrect'),
          ),
        ),
      );
    });

    test(
      'keeps the demo account password fixed for the presentation',
      () async {
        await expectLater(
          auth.changePassword(
            email: DemoData.demoEmail,
            currentPassword: DemoData.demoPassword,
            newPassword: 'Something999',
          ),
          throwsA(
            isA<AuthException>().having(
              (AuthException e) => e.message,
              'message',
              contains('cannot be changed'),
            ),
          ),
        );
      },
    );
  });
}
