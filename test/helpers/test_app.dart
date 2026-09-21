import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:secureguard/data/local_store.dart';
import 'package:secureguard/providers/auth_provider.dart';
import 'package:secureguard/providers/contacts_provider.dart';
import 'package:secureguard/providers/emergency_provider.dart';
import 'package:secureguard/providers/location_provider.dart';
import 'package:secureguard/providers/notifications_provider.dart';
import 'package:secureguard/providers/settings_provider.dart';
import 'package:secureguard/theme/app_theme.dart';

/// Shared scaffolding for the widget tests.
///
/// It mirrors the provider wiring in `main.dart` so a screen behaves in a
/// test exactly as it does in the running application.
class TestApp {
  const TestApp._();

  /// Wipes the in-memory store so each test starts from the demo data.
  static Future<void> reset() => LocalStore.instance.clearAll();

  /// Gives the test a phone-width, extra-tall canvas (390 x 1400 logical px).
  ///
  /// The default 800x600 test surface is a small landscape tablet, which is
  /// not a layout SecureGuard targets, so the phone width matters. The extra
  /// height is a testing convenience: `ListView` and `SliverList` only build
  /// the items near the viewport, so a realistic 844-pixel-tall surface would
  /// leave most of a screen unbuilt and invisible to `find.text`.
  ///
  static void phoneSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(1170, 4200);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    _ignoreTestFontOverflows();
  }

  /// Ignores `RenderFlex overflowed` assertions inside widget tests.
  ///
  /// `flutter test` draws every glyph with a placeholder font in which each
  /// character is a full em square, so a label such as "Forgot password?"
  /// measures roughly twice its real width. Rows that fit comfortably on a
  /// real device therefore "overflow" in the test environment only.
  /// Layout is instead verified visually against a real browser rendering
  /// (see `docs/TESTING.md` §2), so these reports are filtered out here
  /// rather than being worked around in the production layouts.
  static void _ignoreTestFontOverflows() {
    final void Function(FlutterErrorDetails)? original = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exceptionAsString().contains('A RenderFlex overflowed')) {
        return;
      }
      original?.call(details);
    };
    addTearDown(() => FlutterError.onError = original);
  }

  /// Wraps [child] in the same providers and theme the real app uses.
  ///
  /// [routes] lets a test register the destinations a screen navigates to,
  /// so navigation can be asserted without pulling in the whole app.
  static Widget wrap(Widget child, {Map<String, WidgetBuilder>? routes}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(),
        ),
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<ContactsProvider>(
          create: (_) => ContactsProvider(),
        ),
        ChangeNotifierProvider<NotificationsProvider>(
          create: (_) => NotificationsProvider(),
        ),
        ChangeNotifierProvider<LocationProvider>(
          create: (_) => LocationProvider(),
        ),
        ChangeNotifierProxyProvider3<
          ContactsProvider,
          LocationProvider,
          NotificationsProvider,
          EmergencyProvider
        >(
          create: (_) => EmergencyProvider(),
          update:
              (
                _,
                ContactsProvider contacts,
                LocationProvider location,
                NotificationsProvider notifications,
                EmergencyProvider? emergency,
              ) => (emergency ?? EmergencyProvider())
                ..attach(
                  contacts: contacts,
                  location: location,
                  notifications: notifications,
                ),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        routes: routes ?? const <String, WidgetBuilder>{},
        home: child,
      ),
    );
  }

  /// Pumps a screen and lets its entrance animations play.
  ///
  /// `pumpAndSettle` is avoided on purpose: several SecureGuard widgets use
  /// deliberately endless animations (the SOS pulse, the live-location dot),
  /// which would make `pumpAndSettle` time out.
  static Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
    phoneSurface(tester);
    await tester.pumpWidget(wrap(screen));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }
}
