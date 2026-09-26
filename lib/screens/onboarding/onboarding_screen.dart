import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/app_routes.dart';
import '../../utils/responsive.dart';
import '../../widgets/sg_logo.dart';

/// One onboarding page.
class _OnboardingPage {
  const _OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.accent,
    required this.highlights,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color accent;
  final List<String> highlights;
}

/// A three-page introduction shown the first time the app is opened.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  static const List<_OnboardingPage> _pages = <_OnboardingPage>[
    _OnboardingPage(
      title: 'Stay Safe Anywhere',
      description:
          'SecureGuard keeps you connected to the people you trust, whether '
          'you are walking home from class, travelling or simply out late.',
      icon: Icons.shield_rounded,
      accent: AppColors.navy,
      highlights: <String>[
        'Protection that travels with you',
        'One clear screen for every safety tool',
        'Works the same day or night',
      ],
    ),
    _OnboardingPage(
      title: 'Emergency Assistance',
      description:
          'Hold the SOS button for three seconds and SecureGuard alerts every '
          'trusted contact you have saved, with your name and your position.',
      icon: Icons.emergency_share_rounded,
      accent: AppColors.red,
      highlights: <String>[
        'Press and hold to avoid accidental alerts',
        'A countdown you can always cancel',
        'Police, ambulance and fire one tap away',
      ],
    ),
    _OnboardingPage(
      title: 'Your Location, Your Protection',
      description:
          'Share your live location with your trusted contacts while you are '
          'on the move, and stop sharing the moment you arrive safely.',
      icon: Icons.location_on_rounded,
      accent: AppColors.green,
      highlights: <String>[
        'Live location for the people you choose',
        'Stop sharing at any time, in one tap',
        'Every alert saved in your history',
      ],
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isLastPage => _index == _pages.length - 1;

  Future<void> _finish() async {
    await context.read<AuthProvider>().markOnboardingSeen();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  void _next() {
    if (_isLastPage) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double padding = Responsive.horizontalPadding(context);

    return Scaffold(
      body: SafeArea(
        child: ResponsiveBody(
          child: Column(
            children: <Widget>[
              // --------------------------------------------- header + skip
              Padding(
                padding: EdgeInsets.fromLTRB(padding, 12, padding - 8, 0),
                child: Row(
                  children: <Widget>[
                    const SgLogo(size: 28),
                    const SizedBox(width: 10),
                    Text('SecureGuard', style: theme.textTheme.titleMedium),
                    const Spacer(),
                    TextButton(onPressed: _finish, child: const Text('Skip')),
                  ],
                ),
              ),

              // ------------------------------------------------- the pages
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (int value) => setState(() => _index = value),
                  itemBuilder: (BuildContext context, int index) =>
                      _OnboardingPageView(
                        page: _pages[index],
                        horizontalPadding: padding,
                      ),
                ),
              ),

              // --------------------------------------- indicators + button
              Padding(
                padding: EdgeInsets.fromLTRB(padding, 8, padding, 24),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List<Widget>.generate(
                        _pages.length,
                        (int i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOut,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: i == _index ? 26 : 8,
                          decoration: BoxDecoration(
                            color: i == _index
                                ? _pages[_index].accent
                                : theme.colorScheme.outline,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    FilledButton(
                      onPressed: _next,
                      style: FilledButton.styleFrom(
                        backgroundColor: _pages[_index].accent,
                      ),
                      // The label leads and the arrow follows, so the button
                      // reads the way the action moves: "Next ->".
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(_isLastPage ? 'Get Started' : 'Next'),
                          const SizedBox(width: 10),
                          Icon(
                            _isLastPage
                                ? Icons.check_circle_rounded
                                : Icons.arrow_forward_rounded,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 42,
                      child: _index == 0
                          ? const SizedBox.shrink()
                          : TextButton.icon(
                              onPressed: () => _controller.previousPage(
                                duration: const Duration(milliseconds: 380),
                                curve: Curves.easeOutCubic,
                              ),
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                size: 18,
                              ),
                              label: const Text('Back'),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPageView extends StatelessWidget {
  const _OnboardingPageView({
    required this.page,
    required this.horizontalPadding,
  });

  final _OnboardingPage page;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool compact = Responsive.isCompactHeight(context);
    final double illustrationSize = compact ? 168 : 212;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: compact ? 12 : 24),

          // ------------------------------------------------- illustration
          Center(
            child: SizedBox(
              width: illustrationSize,
              height: illustrationSize,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: page.accent.withValues(alpha: 0.07),
                    ),
                  ),
                  Container(
                    width: illustrationSize * 0.74,
                    height: illustrationSize * 0.74,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: page.accent.withValues(alpha: 0.12),
                    ),
                  ),
                  Container(
                    width: illustrationSize * 0.48,
                    height: illustrationSize * 0.48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: page.accent,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: page.accent.withValues(alpha: 0.35),
                          blurRadius: 26,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      page.icon,
                      size: illustrationSize * 0.24,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: compact ? 24 : 36),
          Text(page.title, style: theme.textTheme.headlineMedium),
          const SizedBox(height: 12),
          Text(
            page.description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 22),

          // ---------------------------------------------------- highlights
          ...page.highlights.map(
            (String highlight) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 22,
                    height: 22,
                    margin: const EdgeInsets.only(top: 1),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: page.accent.withValues(alpha: 0.14),
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: page.accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      highlight,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
