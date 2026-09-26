import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/app_routes.dart';
import '../../widgets/sg_logo.dart';

/// The first screen the user sees.
///
/// While the branded animation plays, the app restores any saved session and
/// then decides where to go next:
///   * never opened before  -> onboarding
///   * signed out           -> login
///   * signed in (remember) -> dashboard
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  late final Animation<double> _logoScale = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
  );

  late final Animation<double> _textFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.35, 0.8, curve: Curves.easeOut),
  );

  late final Animation<double> _footerFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
  );

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    _controller.forward();
    // Restoring the session notifies AuthProvider's listeners, so it must
    // wait until the first frame has been built.
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final AuthProvider auth = context.read<AuthProvider>();

    // Restore the session while the animation plays, then keep the splash
    // on screen just long enough for the branding to be readable.
    await Future.wait<void>(<Future<void>>[
      auth.restoreSession(),
      Future<void>.delayed(const Duration(milliseconds: 2200)),
    ]);

    if (!mounted) return;

    final String next;
    if (!auth.hasSeenOnboarding) {
      next = AppRoutes.onboarding;
    } else if (auth.isSignedIn) {
      next = AppRoutes.shell;
    } else {
      next = AppRoutes.login;
    }

    // The named route table lives in main.dart; the theme supplies the
    // cross-fade transition between pages.
    Navigator.of(context).pushReplacementNamed(next);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyDeep,
      // SizedBox.expand keeps the brand gradient covering the whole screen;
      // a bare Container would shrink to the width of the wordmark.
      body: SizedBox.expand(
        child: DecoratedBox(
          decoration: const BoxDecoration(gradient: AppColors.brandGradient),
          child: SafeArea(
            child: Column(
              children: <Widget>[
                const Spacer(flex: 3),
                ScaleTransition(
                  scale: Tween<double>(begin: 0.6, end: 1).animate(_logoScale),
                  child: FadeTransition(
                    opacity: _logoScale,
                    child: const SgLogo(size: 108, showPulse: true),
                  ),
                ),
                const SizedBox(height: 34),
                FadeTransition(
                  opacity: _textFade,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.25),
                      end: Offset.zero,
                    ).animate(_textFade),
                    child: const SgWordmark(
                      color: Colors.white,
                      fontSize: 38,
                      taglineColor: Color(0xCCFFFFFF),
                    ),
                  ),
                ),
                const Spacer(flex: 3),
                FadeTransition(
                  opacity: _footerFade,
                  child: Column(
                    children: <Widget>[
                      const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.6,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white70,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'Preparing your safety tools…',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 13.5,
                        ),
                      ),
                      const SizedBox(height: 26),
                      Text(
                        'University Prototype • v1.0.0',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: 11.5,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
