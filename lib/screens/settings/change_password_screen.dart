import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/responsive.dart';
import '../../utils/validators.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/sg_text_field.dart';

/// Lets a locally registered user choose a new password.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _current = TextEditingController();
  final TextEditingController _next = TextEditingController();
  final TextEditingController _confirm = TextEditingController();

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final bool ok = await context.read<AuthProvider>().changePassword(
      currentPassword: _current.text,
      newPassword: _next.text,
    );

    if (!mounted) return;
    if (ok) {
      AppFeedback.success(context, 'Your password has been changed.');
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AuthProvider auth = context.watch<AuthProvider>();
    final double padding = Responsive.horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: SafeArea(
        child: ResponsiveBody(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(padding, 12, padding, 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.navy.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      size: 32,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Choose a new password',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Use at least 8 characters with letters and numbers. Do '
                    'not reuse the password of your email account.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 26),

                  if (auth.errorMessage != null) ...<Widget>[
                    InlineBanner(
                      title: 'Could not change the password',
                      message: auth.errorMessage!,
                      icon: Icons.error_outline_rounded,
                      color: AppColors.red,
                    ),
                    const SizedBox(height: 18),
                  ],

                  SgTextField(
                    label: 'Current password',
                    controller: _current,
                    prefixIcon: Icons.lock_clock_rounded,
                    obscure: true,
                    textInputAction: TextInputAction.next,
                    validator: Validators.loginPassword,
                    onChanged: (_) => auth.clearError(),
                  ),
                  const SizedBox(height: 18),
                  SgTextField(
                    label: 'New password',
                    controller: _next,
                    prefixIcon: Icons.lock_outline_rounded,
                    obscure: true,
                    textInputAction: TextInputAction.next,
                    validator: Validators.newPassword,
                    onChanged: (_) => auth.clearError(),
                  ),
                  const SizedBox(height: 18),
                  SgTextField(
                    label: 'Confirm new password',
                    controller: _confirm,
                    prefixIcon: Icons.lock_reset_rounded,
                    obscure: true,
                    textInputAction: TextInputAction.done,
                    validator: (String? value) =>
                        Validators.confirmPassword(value, _next.text),
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 26),

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
                        : const Text('Update Password'),
                  ),
                  const SizedBox(height: 18),
                  const InlineBanner(
                    title: 'Prototype limitation',
                    message:
                        'Passwords in this prototype are kept in local device '
                        'storage and are not hashed. A production release '
                        'would store only a salted hash on a secure server.',
                    icon: Icons.warning_amber_rounded,
                    color: AppColors.amber,
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
