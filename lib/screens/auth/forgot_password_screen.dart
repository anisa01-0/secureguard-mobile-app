import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/responsive.dart';
import '../../utils/validators.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/sg_text_field.dart';

/// Password-reset request screen.
///
/// The prototype has no mail server, so the screen simulates sending the link
/// and says so plainly rather than pretending an email was delivered.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final bool ok = await context.read<AuthProvider>().sendPasswordReset(
      _email.text,
    );
    if (!mounted) return;
    if (ok) {
      setState(() => _sent = true);
    } else {
      AppFeedback.error(context, 'We could not send the link. Try again.');
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
        title: const Text('Reset password'),
      ),
      body: SafeArea(
        child: ResponsiveBody(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(padding, 12, padding, 32),
            child: _sent ? _buildSentState(theme) : _buildForm(theme, auth),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(ThemeData theme, AuthProvider auth) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              color: AppColors.blue.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_reset_rounded,
              size: 34,
              color: AppColors.blue,
            ),
          ),
          const SizedBox(height: 22),
          Text('Forgot your password?', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 10),
          Text(
            'Enter the email address linked to your SecureGuard account and '
            'we will send you a link to choose a new password.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 28),
          SgTextField(
            label: 'Email address',
            controller: _email,
            hint: 'you@example.com',
            prefixIcon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            validator: Validators.email,
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
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Send Reset Link'),
          ),
          const SizedBox(height: 20),
          const InlineBanner(
            title: 'Prototype behaviour',
            message:
                'This university prototype has no mail server, so no email is '
                'actually delivered. The screen shows the flow a finished '
                'product would follow.',
            icon: Icons.info_outline_rounded,
            color: AppColors.amber,
          ),
        ],
      ),
    );
  }

  Widget _buildSentState(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: 26),
        Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 520),
            curve: Curves.easeOutBack,
            builder: (BuildContext context, double value, Widget? child) =>
                Transform.scale(scale: value, child: child),
            child: Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mark_email_read_rounded,
                size: 44,
                color: AppColors.green,
              ),
            ),
          ),
        ),
        const SizedBox(height: 26),
        Text(
          'Check your inbox',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 10),
        Text(
          'If an account exists for ${_email.text.trim()}, a reset link is on '
          'its way. The link expires after 30 minutes.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 28),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Back to Sign In'),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => setState(() => _sent = false),
          child: const Text('Use a different email address'),
        ),
      ],
    );
  }
}
