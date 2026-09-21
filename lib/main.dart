import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'data/local_store.dart';
import 'providers/auth_provider.dart';
import 'providers/contacts_provider.dart';
import 'providers/emergency_provider.dart';
import 'providers/location_provider.dart';
import 'providers/notifications_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/sign_up_screen.dart';
import 'screens/home/root_shell.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/services/emergency_services_screen.dart';
import 'screens/settings/about_screen.dart';
import 'screens/settings/change_password_screen.dart';
import 'screens/settings/privacy_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/sos/sos_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/tips/safety_tips_screen.dart';
import 'theme/app_theme.dart';
import 'utils/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load any data saved during a previous session before the UI is built.
  await LocalStore.instance.init();

  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const SecureGuardApp());
}

/// Root of the SecureGuard application.
///
/// All shared state lives in the providers registered here, which keeps the
/// screens focused on presentation only.
class SecureGuardApp extends StatelessWidget {
  const SecureGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
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
        // The emergency flow needs the three providers above, so it is
        // created last and given a reference to each of them.
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
      child: const _SecureGuardMaterialApp(),
    );
  }
}

class _SecureGuardMaterialApp extends StatelessWidget {
  const _SecureGuardMaterialApp();

  @override
  Widget build(BuildContext context) {
    final ThemeMode themeMode = context.select<SettingsProvider, ThemeMode>(
      (SettingsProvider s) => s.themeMode,
    );

    return MaterialApp(
      title: 'SecureGuard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      initialRoute: AppRoutes.splash,
      routes: <String, WidgetBuilder>{
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.onboarding: (_) => const OnboardingScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.signUp: (_) => const SignUpScreen(),
        AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),
        AppRoutes.shell: (_) => const RootShell(),
        AppRoutes.sos: (_) => const SosScreen(),
        AppRoutes.emergencyServices: (_) => const EmergencyServicesScreen(),
        AppRoutes.safetyTips: (_) => const SafetyTipsScreen(),
        AppRoutes.notifications: (_) => const NotificationsScreen(),
        AppRoutes.settings: (_) => const SettingsScreen(),
        AppRoutes.editProfile: (_) => const EditProfileScreen(),
        AppRoutes.changePassword: (_) => const ChangePasswordScreen(),
        AppRoutes.about: (_) => const AboutScreen(),
        AppRoutes.privacy: (_) => const PrivacyScreen(),
      },
      builder: (BuildContext context, Widget? child) {
        // Keep the text readable but never so large that the emergency
        // button is pushed off the screen.
        final MediaQueryData media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: media.textScaler.clamp(
              minScaleFactor: 0.9,
              maxScaleFactor: 1.35,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
