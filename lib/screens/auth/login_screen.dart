import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/demo_data.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/app_routes.dart';
import '../../utils/responsive.dart';
import '../../utils/validators.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/sg_logo.dart';
import '../../widgets/sg_text_field.dart';

/// Sign-in screen.
///
/// The demo credentials are printed on the card so the project can be
/// demonstrated immediately, and a single button fills them in.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill the email when the user previously chose "Remember me".
    final AuthProvider auth = context.read<AuthProvider>();
    _email.text = auth.rememberedEmail;
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _fillDemoAccount() {
    setState(() {
      _email.text = DemoData.demoEmail;
      _password.text = DemoData.demoPassword;
    });
    context.read<AuthProvider>().clearError();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final AuthProvider auth = context.read<AuthProvider>();
    final bool ok = await auth.signIn(
      email: _email.text,
      password: _password.text,
    );

    if (!mounted) return;
    if (ok) {
      AppFeedback.success(
        context,
        'Welcome back, ${auth.user?.firstName ?? 'friend'}.',
      );
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.shell,
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AuthProvider auth = context.watch<AuthProvider>();
    final double padding = Responsive.horizontalPadding(context);

    return Scaffold(
      body: SafeArea(
        child: ResponsiveBody(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(padding, 20, padding, 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(height: 12),
                  const Center(child: SgLogo(size: 64)),
                  const SizedBox(height: 22),
                  Text(
                    'Welcome back',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to reach your emergency tools and your\n'
                    'trusted contacts.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 30),

                  // ------------------------------------------ error banner
                  if (auth.errorMessage != null) ...<Widget>[
                    InlineBanner(
                      title: 'Could not sign in',
                      message: auth.errorMessage!,
                      icon: Icons.error_outline_rounded,
                      color: AppColors.red,
                    ),
                    const SizedBox(height: 18),
                  ],

                  // ------------------------------------------------ fields
                  SgTextField(
                    label: 'Email address',
                    controller: _email,
                    hint: 'you@example.com',
                    prefixIcon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: Validators.email,
                    autofillHints: const <String>[AutofillHints.email],
                    onChanged: (_) => auth.clearError(),
                  ),
                  const SizedBox(height: 18),
                  SgTextField(
                    label: 'Password',
                    controller: _password,
                    hint: 'Enter your password',
                    prefixIcon: Icons.lock_outline_rounded,
                    obscure: true,
                    textInputAction: TextInputAction.done,
                    validator: Validators.loginPassword,
                    autofillHints: const <String>[AutofillHints.password],
                    onSubmitted: (_) => _submit(),
                    onChanged: (_) => auth.clearError(),
                  ),
                  const SizedBox(height: 6),

                  // -------------------------------- remember me + forgot
                  Row(
                    children: <Widget>[
                      Checkbox(
                        value: auth.rememberMe,
                        onChanged: (bool? value) =>
                            auth.setRememberMe(value ?? false),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => auth.setRememberMe(!auth.rememberMe),
                        child: Text(
                          'Remember me',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () =>
                            Navigator.of(context)
                                .pushNamed(AppRoutes.forgotPassword),
                        child: const Text('Forgot password?'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ------------------------------------------------ submit
                  FilledButton(
                    onPressed: auth.isBusy ? null : _submit,
                    child: auth.isBusy
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text('Sign In'),
                  ),
                  const SizedBox(height: 18),

                  // ------------------------------------------ demo account
                  _DemoCredentialsCard(onUse: _fillDemoAccount),
                  const SizedBox(height: 22),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Don't have an account?",
                        style: theme.textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.of(context).pushNamed(AppRoutes.signUp),
                        child: const Text('Create account'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shows the presentation credentials and fills them in with one tap.
class _DemoCredentialsCard extends StatelessWidget {
  const _DemoCredentialsCard({required this.onUse});

  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blue.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.blue.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.science_outlined,
                size: 19,
                color: AppColors.blue,
              ),
              const SizedBox(width: 8),
              Text(
                'Demonstration account',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _CredentialRow(label: 'Email', value: DemoData.demoEmail),
          const SizedBox(height: 4),
          _CredentialRow(label: 'Password', value: DemoData.demoPassword),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onUse,
              icon: const Icon(Icons.auto_fix_high_rounded, size: 18),
              label: const Text('Use demo account'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
                foregroundColor: AppColors.blue,
                side: BorderSide(color: AppColors.blue.withValues(alpha: 0.4)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CredentialRow extends StatelessWidget {
  const _CredentialRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      children: <Widget>[
        SizedBox(
          width: 74,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 12.5),
          ),
        ),
        Expanded(
          child: SelectableText(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
