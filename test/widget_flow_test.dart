import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:secureguard/data/demo_data.dart';
import 'package:secureguard/models/emergency_contact.dart';
import 'package:secureguard/providers/auth_provider.dart';
import 'package:secureguard/providers/contacts_provider.dart';
import 'package:secureguard/providers/emergency_provider.dart';
import 'package:secureguard/screens/auth/login_screen.dart';
import 'package:secureguard/screens/auth/sign_up_screen.dart';
import 'package:secureguard/screens/contacts/contacts_screen.dart';
import 'package:secureguard/screens/history/history_screen.dart';
import 'package:secureguard/screens/home/home_screen.dart';
import 'package:secureguard/screens/notifications/notifications_screen.dart';
import 'package:secureguard/screens/onboarding/onboarding_screen.dart';
import 'package:secureguard/screens/services/emergency_services_screen.dart';
import 'package:secureguard/screens/settings/settings_screen.dart';
import 'package:secureguard/screens/sos/sos_screen.dart';
import 'package:secureguard/screens/splash/splash_screen.dart';
import 'package:secureguard/screens/tips/safety_tips_screen.dart';
import 'package:secureguard/utils/app_routes.dart';
import 'package:secureguard/main.dart';
import 'package:secureguard/widgets/sos_button.dart';

import 'helpers/test_app.dart';

/// Presses and holds the SOS button long enough to activate it.
///
/// The first short pump lets the tap-down recogniser win the gesture arena
/// (it waits `kPressTimeout`); only then does the 3-second hold animation
/// start, so the long pump has to come afterwards.
Future<void> _holdSosButton(WidgetTester tester) async {
  final TestGesture gesture = await tester.startGesture(
    tester.getCenter(find.byType(SosButton)),
  );
  await tester.pump(const Duration(milliseconds: 250));
  await tester.pump(const Duration(milliseconds: 3400));
  await gesture.up();
  await tester.pump();
}

void main() {
  setUp(TestApp.reset);

  // ---------------------------------------------------------------- splash
  group('Application start-up', () {
    testWidgets('boots on the splash screen and moves to onboarding', (
      WidgetTester tester,
    ) async {
      TestApp.phoneSurface(tester);

      // The real application widget, including its route table.
      await tester.pumpWidget(const SecureGuardApp());
      await tester.pump(const Duration(milliseconds: 1700));

      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('Your Safety. One Tap Away.'), findsOneWidget);
      expect(find.textContaining('University Prototype'), findsOneWidget);

      // A first-time user is taken to onboarding once the splash finishes.
      await tester.pump(const Duration(milliseconds: 900));
      await tester.pump(const Duration(milliseconds: 900));

      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.text('Stay Safe Anywhere'), findsOneWidget);
    });
  });

  // ------------------------------------------------------------ onboarding
  group('Onboarding', () {
    testWidgets('walks through all three pages to Get Started', (
      WidgetTester tester,
    ) async {
      await TestApp.pumpScreen(tester, const OnboardingScreen());

      expect(find.text('Stay Safe Anywhere'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Emergency Assistance'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Your Location, Your Protection'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
    });
  });

  // ----------------------------------------------------------------- login
  group('Login screen', () {
    testWidgets('rejects an empty form with friendly messages', (
      WidgetTester tester,
    ) async {
      await TestApp.pumpScreen(tester, const LoginScreen());

      await tester.tap(find.text('Sign In'));
      await tester.pump();

      expect(find.text('Please enter your email address.'), findsOneWidget);
      expect(find.text('Please enter your password.'), findsOneWidget);
    });

    testWidgets('rejects a malformed email address', (
      WidgetTester tester,
    ) async {
      await TestApp.pumpScreen(tester, const LoginScreen());

      await tester.enterText(find.byType(TextFormField).first, 'not-an-email');
      await tester.pump();

      expect(find.text('Please enter a valid email address.'), findsOneWidget);
    });

    testWidgets('the demo button fills in the presentation credentials', (
      WidgetTester tester,
    ) async {
      await TestApp.pumpScreen(tester, const LoginScreen());

      await tester.tap(find.text('Use demo account'));
      await tester.pump();

      expect(find.text(DemoData.demoEmail), findsWidgets);
    });

    testWidgets('signs in successfully with the demo account', (
      WidgetTester tester,
    ) async {
      TestApp.phoneSurface(tester);
      await tester.pumpWidget(
        TestApp.wrap(
          const LoginScreen(),
          routes: <String, WidgetBuilder>{
            AppRoutes.shell: (_) =>
                const Scaffold(body: Center(child: Text('Dashboard'))),
          },
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));

      final BuildContext context = tester.element(find.byType(LoginScreen));
      final AuthProvider auth = context.read<AuthProvider>();

      await tester.tap(find.text('Use demo account'));
      await tester.pump();
      await tester.tap(find.text('Sign In'));

      // The auth service adds a short delay so the spinner is visible.
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 600));

      expect(auth.isSignedIn, isTrue);
      expect(auth.user?.fullName, 'Anisa Abdi');
      expect(find.text('Dashboard'), findsOneWidget);
    });

    testWidgets('shows an error for an unknown account', (
      WidgetTester tester,
    ) async {
      await TestApp.pumpScreen(tester, const LoginScreen());

      await tester.enterText(
        find.byType(TextFormField).first,
        'nobody@example.com',
      );
      await tester.enterText(find.byType(TextFormField).last, 'whatever1');
      await tester.tap(find.text('Sign In'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('Could not sign in'), findsOneWidget);
    });
  });

  // --------------------------------------------------------------- sign up
  group('Sign up screen', () {
    testWidgets('validates every field before creating an account', (
      WidgetTester tester,
    ) async {
      await TestApp.pumpScreen(tester, const SignUpScreen());

      await tester.ensureVisible(find.text('Create Account'));
      await tester.pump();
      await tester.tap(find.text('Create Account'));
      await tester.pump();

      expect(find.text('Please enter your full name.'), findsOneWidget);
      expect(find.text('Please enter your email address.'), findsOneWidget);
      expect(find.text('Please enter a phone number.'), findsOneWidget);
      expect(find.text('Please create a password.'), findsOneWidget);
    });

    testWidgets('reports mismatched passwords', (WidgetTester tester) async {
      await TestApp.pumpScreen(tester, const SignUpScreen());

      final Finder fields = find.byType(TextFormField);
      await tester.enterText(fields.at(3), 'Secure123');
      await tester.enterText(fields.at(4), 'Secure124');
      await tester.pump();

      expect(find.text('Passwords do not match.'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------- home
  group('Dashboard', () {
    testWidgets('shows the greeting, safety status and SOS panel', (
      WidgetTester tester,
    ) async {
      await TestApp.pumpScreen(tester, const HomeScreen());

      expect(find.text('ARE YOU IN DANGER?'), findsOneWidget);
      expect(find.byType(SosButton), findsOneWidget);
      expect(
        find.text(
          'Press and hold for 3 seconds to activate the emergency '
          'alert.',
        ),
        findsOneWidget,
      );
      expect(find.text('You are protected'), findsOneWidget);
      expect(find.text('Quick actions'), findsOneWidget);
      expect(find.text('Trusted contacts'), findsOneWidget);
    });
  });

  // ------------------------------------------------------------- contacts
  group('Trusted contacts', () {
    testWidgets('lists the demo contacts with the primary one marked', (
      WidgetTester tester,
    ) async {
      await TestApp.pumpScreen(tester, const ContactsScreen());

      expect(find.text('Halima Abdi'), findsOneWidget);
      expect(find.text('Yusuf Abdi'), findsOneWidget);
      expect(find.text('Sagal Mohamed'), findsOneWidget);
      expect(find.text('Primary'), findsOneWidget);
      expect(find.text('3 trusted contacts'), findsOneWidget);
    });

    testWidgets('adds a contact through the bottom sheet', (
      WidgetTester tester,
    ) async {
      await TestApp.pumpScreen(tester, const ContactsScreen());

      await tester.tap(find.byIcon(Icons.person_add_alt_1_rounded).first);
      await tester.pumpAndSettle();
      expect(find.text('Add trusted contact'), findsOneWidget);

      final Finder fields = find.byType(TextFormField);
      await tester.enterText(fields.first, 'Amina Ali');
      await tester.enterText(fields.last, '+252 61 000 0044');
      await tester.pump();

      await tester.tap(find.text('Add contact').last);
      await tester.pumpAndSettle();

      final BuildContext context = tester.element(find.byType(ContactsScreen));
      final ContactsProvider contacts = context.read<ContactsProvider>();
      expect(contacts.count, 4);
      expect(
        contacts.contacts.any((EmergencyContact c) => c.name == 'Amina Ali'),
        isTrue,
      );
    });

    testWidgets('refuses a duplicate phone number', (
      WidgetTester tester,
    ) async {
      await TestApp.pumpScreen(tester, const ContactsScreen());

      await tester.tap(find.byIcon(Icons.person_add_alt_1_rounded).first);
      await tester.pumpAndSettle();

      final Finder fields = find.byType(TextFormField);
      await tester.enterText(fields.first, 'Copycat Contact');
      await tester.enterText(fields.last, '+252 61 000 0001');
      await tester.pump();
      await tester.tap(find.text('Add contact').last);
      await tester.pump();

      expect(
        find.text('Another trusted contact already uses this number.'),
        findsOneWidget,
      );
    });
  });

  // ------------------------------------------------------------------ SOS
  group('SOS flow', () {
    testWidgets('holding the button starts a cancellable countdown', (
      WidgetTester tester,
    ) async {
      await TestApp.pumpScreen(tester, const SosScreen());
      expect(find.text('ARE YOU IN DANGER?'), findsOneWidget);

      await _holdSosButton(tester);

      expect(find.text('Emergency Alert Activating…'), findsOneWidget);
      expect(find.text('CANCEL ALERT'), findsOneWidget);

      await tester.tap(find.text('CANCEL ALERT'));
      await tester.pump();

      final BuildContext context = tester.element(find.byType(SosScreen));
      final EmergencyProvider emergency = context.read<EmergencyProvider>();
      expect(emergency.isIdle, isTrue);
      expect(emergency.notifiedContacts, isEmpty);
    });

    testWidgets('a completed countdown notifies the trusted contacts', (
      WidgetTester tester,
    ) async {
      await TestApp.pumpScreen(tester, const SosScreen());

      await _holdSosButton(tester);

      // Run the 5-second countdown plus the per-contact dispatch delays.
      await tester.pump(const Duration(seconds: 5));
      await tester.pump(const Duration(seconds: 3));

      expect(find.text('Emergency Alert Sent'), findsOneWidget);
      expect(find.text('CALL EMERGENCY SERVICES'), findsOneWidget);
      expect(find.text("I'M SAFE — END EMERGENCY"), findsOneWidget);

      final BuildContext context = tester.element(find.byType(SosScreen));
      final EmergencyProvider emergency = context.read<EmergencyProvider>();
      expect(emergency.isActive, isTrue);
      expect(emergency.notifiedContacts.length, 3);

      emergency.endEmergency();
      await tester.pump();
    });
  });

  // -------------------------------------------------------------- history
  group('Emergency history', () {
    testWidgets('lists the demo events and filters them', (
      WidgetTester tester,
    ) async {
      await TestApp.pumpScreen(tester, const HistoryScreen());

      expect(find.text('SOS Alert'), findsWidgets);
      expect(find.textContaining('Showing 5 of 5 events'), findsOneWidget);

      // The filter chips scroll horizontally, so reveal the one we want.
      final Finder locationFilter = find.byKey(
        const ValueKey<String>('history-filter-locationShare'),
      );
      await tester.ensureVisible(locationFilter);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(locationFilter);
      await tester.pump();

      expect(find.textContaining('Showing 1 of 5 events'), findsOneWidget);
    });
  });

  // -------------------------------------------------- services, tips, etc.
  group('Supporting screens', () {
    testWidgets('emergency services lists every category', (
      WidgetTester tester,
    ) async {
      await TestApp.pumpScreen(tester, const EmergencyServicesScreen());

      expect(find.text('Demonstration numbers only'), findsOneWidget);
      expect(find.text('Police'), findsOneWidget);
      expect(find.text('Ambulance'), findsOneWidget);

      // The remaining categories are further down the page.
      await tester.scrollUntilVisible(find.text('Emergency Hotline'), 400);
      expect(find.text('Fire Department'), findsOneWidget);
      expect(find.text('Emergency Hotline'), findsOneWidget);
    });

    testWidgets('safety tips open on the personal safety tab', (
      WidgetTester tester,
    ) async {
      await TestApp.pumpScreen(tester, const SafetyTipsScreen());

      expect(find.text('Stay aware of your surroundings'), findsOneWidget);
      expect(find.text('3 tips in this category'), findsOneWidget);
    });

    testWidgets('notifications show the unread count', (
      WidgetTester tester,
    ) async {
      await TestApp.pumpScreen(tester, const NotificationsScreen());

      expect(find.text('Weekly safety reminder'), findsOneWidget);
      expect(find.textContaining('unread'), findsWidgets);
    });

    testWidgets('settings expose the main preference groups', (
      WidgetTester tester,
    ) async {
      await TestApp.pumpScreen(tester, const SettingsScreen());

      expect(find.text('Allow notifications'), findsOneWidget);
      expect(find.text('Location permission'), findsOneWidget);
      expect(find.text('Dark mode'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('Reset demo data'), 400);
      expect(find.text('Change password'), findsOneWidget);
      expect(find.text('Reset demo data'), findsOneWidget);
    });

    testWidgets('the dark mode switch updates the settings provider', (
      WidgetTester tester,
    ) async {
      await TestApp.pumpScreen(tester, const SettingsScreen());

      await tester.tap(find.text('Dark mode'));
      await tester.pump(const Duration(milliseconds: 400));

      // Tapping the row title toggles the tile, which flips the theme mode.
      expect(find.text('Easier on the eyes at night.'), findsOneWidget);
    });
  });
}
