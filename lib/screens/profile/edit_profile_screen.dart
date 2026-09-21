import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/app_user.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/responsive.dart';
import '../../utils/validators.dart';
import '../../widgets/app_feedback.dart';
import '../../widgets/sg_text_field.dart';

/// Lets the signed-in user update their own details.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final AppUser? _user = context.read<AuthProvider>().user;

  late final TextEditingController _name = TextEditingController(
    text: _user?.fullName ?? '',
  );
  late final TextEditingController _email = TextEditingController(
    text: _user?.email ?? '',
  );
  late final TextEditingController _phone = TextEditingController(
    text: _user?.phone ?? '',
  );
  late final TextEditingController _address = TextEditingController(
    text: _user?.address ?? '',
  );

  late String _bloodGroup = _user?.bloodGroup ?? 'Not set';
  bool _saving = false;

  static const List<String> _bloodGroups = <String>[
    'Not set',
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    await context.read<AuthProvider>().updateProfile(
      fullName: _name.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      bloodGroup: _bloodGroup,
      address: _address.text.trim().isEmpty ? 'Not set' : _address.text.trim(),
    );

    if (!mounted) return;
    setState(() => _saving = false);
    AppFeedback.success(context, 'Your profile has been updated.');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double padding = Responsive.horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SafeArea(
        child: ResponsiveBody(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(padding, 10, padding, 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Center(
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: 84,
                          height: 84,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.brandGradient,
                          ),
                          child: Text(
                            _user?.initials ?? '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Your initials are used as your avatar',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  SgTextField(
                    label: 'Full name',
                    controller: _name,
                    prefixIcon: Icons.person_outline_rounded,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    validator: Validators.fullName,
                  ),
                  const SizedBox(height: 18),
                  SgTextField(
                    label: 'Email address',
                    controller: _email,
                    prefixIcon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 18),
                  SgTextField(
                    label: 'Phone number',
                    controller: _phone,
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    maxLength: 20,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[0-9+\s\-()]'),
                      ),
                    ],
                    validator: Validators.phone,
                  ),
                  const SizedBox(height: 18),
                  SgDropdownField<String>(
                    label: 'Blood group (optional)',
                    value: _bloodGroup,
                    items: _bloodGroups,
                    itemLabel: (String v) => v,
                    prefixIcon: Icons.bloodtype_outlined,
                    onChanged: (String? value) =>
                        setState(() => _bloodGroup = value ?? 'Not set'),
                  ),
                  const SizedBox(height: 18),
                  SgTextField(
                    label: 'Home area (optional)',
                    controller: _address,
                    hint: 'e.g. Hodan District, Mogadishu',
                    prefixIcon: Icons.home_outlined,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.done,
                    helperText: 'Shared with emergency responders only during an alert.',
                    onSubmitted: (_) => _save(),
                  ),
                  const SizedBox(height: 26),

                  FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.check_rounded),
                    label: Text(_saving ? 'Saving…' : 'Save changes'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(height: 18),
                  const InlineBanner(
                    title: 'Minimal data collection',
                    message:
                        'SecureGuard only asks for what an emergency responder '
                        'or a trusted contact genuinely needs. Optional fields '
                        'can be left empty.',
                    icon: Icons.privacy_tip_outlined,
                    color: AppColors.blue,
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
