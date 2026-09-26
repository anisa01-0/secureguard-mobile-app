import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/app_routes.dart';
import '../../utils/responsive.dart';
import '../../utils/validators.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/sg_logo.dart';
import '../../widgets/sg_text_field.dart';

/// Registration screen with full client-side validation.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();

  bool _acceptedTerms = false;
  bool _termsTouched = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _termsTouched = true);

    final bool formValid = _formKey.currentState!.validate();
    if (!formValid || !_acceptedTerms) return;

    final AuthProvider auth = context.read<AuthProvider>();
    final bool ok = await auth.register(
      fullName: _name.text,
      email: _email.text,
      phone: _phone.text,
      password: _password.text,
    );

    if (!mounted) return;
    if (ok) {
      AppFeedback.success(
        context,
        'Account created. Welcome to SecureGuard, ${auth.user?.firstName}.',
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
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back to sign in',
        ),
        title: const Text('Create account'),
      ),
      body: SafeArea(
        child: ResponsiveBody(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(padding, 8, padding, 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const SgLogo(size: 42),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Join SecureGuard',
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'It takes less than a minute to set up your '
                              'protection.',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),

                  if (auth.errorMessage != null) ...<Widget>[
                    InlineBanner(
                      title: 'Could not create the account',
                      message: auth.errorMessage!,
                      icon: Icons.error_outline_rounded,
                      color: AppColors.red,
                    ),
                    const SizedBox(height: 18),
                  ],

                  SgTextField(
                    label: 'Full name',
                    controller: _name,
                    hint: 'e.g. Anisa Abdi',
                    prefixIcon: Icons.person_outline_rounded,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    validator: Validators.fullName,
                    onChanged: (_) => auth.clearError(),
                  ),
                  const SizedBox(height: 18),
                  SgTextField(
                    label: 'Email address',
                    controller: _email,
                    hint: 'you@example.com',
                    prefixIcon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: Validators.email,
                    onChanged: (_) => auth.clearError(),
                  ),
                  const SizedBox(height: 18),
                  SgTextField(
                    label: 'Phone number',
                    controller: _phone,
                    hint: '+252 61 234 5678',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    validator: Validators.phone,
                    maxLength: 20,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[0-9+\s\-()]'),
                      ),
                    ],
                    helperText:
                        'Used only so your contacts recognise your alerts.',
                    onChanged: (_) => auth.clearError(),
                  ),
                  const SizedBox(height: 18),
                  SgTextField(
                    label: 'Password',
                    controller: _password,
                    hint: 'At least 8 characters',
                    prefixIcon: Icons.lock_outline_rounded,
                    obscure: true,
                    textInputAction: TextInputAction.next,
                    validator: Validators.newPassword,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 10),
                  _PasswordStrengthMeter(password: _password.text),
                  const SizedBox(height: 18),
                  SgTextField(
                    label: 'Confirm password',
                    controller: _confirm,
                    hint: 'Re-enter your password',
                    prefixIcon: Icons.lock_reset_rounded,
                    obscure: true,
                    textInputAction: TextInputAction.done,
                    validator: (String? value) =>
                        Validators.confirmPassword(value, _password.text),
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 18),

                  // ------------------------------------------------- terms
                  _TermsCheckbox(
                    value: _acceptedTerms,
                    showError: _termsTouched && !_acceptedTerms,
                    onChanged: (bool value) => setState(() {
                      _acceptedTerms = value;
                    }),
                  ),
                  const SizedBox(height: 22),

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
                        : const Text('Create Account'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Already have an account?',
                        style: theme.textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Sign in'),
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

/// A four-segment bar that reacts as the password is typed.
class _PasswordStrengthMeter extends StatelessWidget {
  const _PasswordStrengthMeter({required this.password});

  final String password;

  Color _colorFor(int strength) {
    return switch (strength) {
      0 => AppColors.border,
      1 => AppColors.red,
      2 => AppColors.amber,
      3 => AppColors.blue,
      _ => AppColors.green,
    };
  }

  @override
  Widget build(BuildContext context) {
    final int strength = Validators.passwordStrength(password);
    final Color color = _colorFor(strength);
    final ThemeData theme = Theme.of(context);

    return Row(
      children: <Widget>[
        ...List<Widget>.generate(
          4,
          (int i) => Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              margin: EdgeInsets.only(right: i == 3 ? 0 : 5),
              height: 5,
              decoration: BoxDecoration(
                color: i < strength ? color : theme.colorScheme.outline,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 108,
          child: Text(
            Validators.passwordStrengthLabel(password),
            textAlign: TextAlign.right,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: strength == 0 ? theme.colorScheme.onSurfaceVariant : color,
            ),
          ),
        ),
      ],
    );
  }
}

class _TermsCheckbox extends StatelessWidget {
  const _TermsCheckbox({
    required this.value,
    required this.onChanged,
    required this.showError,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showError;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Checkbox(
              value: value,
              onChanged: (bool? v) => onChanged(v ?? false),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(!value),
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'I understand that SecureGuard is a university prototype '
                    'and that my details are stored on this device only.',
                    style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (showError)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 6),
            child: Text(
              'Please accept this before creating your account.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
