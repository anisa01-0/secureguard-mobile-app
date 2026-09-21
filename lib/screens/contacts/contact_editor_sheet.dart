import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/emergency_contact.dart';
import '../../providers/contacts_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/validators.dart';
import '../../widgets/sg_text_field.dart';

/// The values returned when the add/edit sheet is saved.
class ContactEditorResult {
  const ContactEditorResult({
    required this.name,
    required this.relationship,
    required this.phone,
    required this.isPrimary,
  });

  final String name;
  final String relationship;
  final String phone;
  final bool isPrimary;
}

/// A bottom sheet used for both adding and editing a trusted contact.
///
/// Pass an existing [contact] to edit it; pass nothing to add a new one.
class ContactEditorSheet extends StatefulWidget {
  const ContactEditorSheet({super.key, this.contact});

  final EmergencyContact? contact;

  @override
  State<ContactEditorSheet> createState() => _ContactEditorSheetState();
}

class _ContactEditorSheetState extends State<ContactEditorSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _name = TextEditingController(
    text: widget.contact?.name ?? '',
  );
  late final TextEditingController _phone = TextEditingController(
    text: widget.contact?.phone ?? '',
  );

  late String _relationship =
      widget.contact?.relationship ??
      EmergencyContact.relationshipOptions.first;
  late bool _isPrimary = widget.contact?.isPrimary ?? false;

  bool get _isEditing => widget.contact != null;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  /// Blocks saving two contacts with the same number.
  String? _validatePhone(String? value) {
    final String? basic = Validators.phone(value);
    if (basic != null) return basic;

    final bool duplicate = context.read<ContactsProvider>().isDuplicatePhone(
      value!,
      ignoreId: widget.contact?.id,
    );
    if (duplicate) {
      return 'Another trusted contact already uses this number.';
    }
    return null;
  }

  void _save() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(
      ContactEditorResult(
        name: _name.text.trim(),
        relationship: _relationship,
        phone: _phone.text.trim(),
        isPrimary: _isPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    // Lift the sheet above the keyboard.
    final double bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // ------------------------------------------------ drag handle
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.navy.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _isEditing
                          ? Icons.edit_rounded
                          : Icons.person_add_alt_1_rounded,
                      color: AppColors.navy,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _isEditing ? 'Edit contact' : 'Add trusted contact',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'They will be alerted when you press SOS.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Close',
                  ),
                ],
              ),
              const SizedBox(height: 24),

              SgTextField(
                label: 'Full name',
                controller: _name,
                hint: 'e.g. Halima Abdi',
                prefixIcon: Icons.person_outline_rounded,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: (String? value) =>
                    Validators.required(value, field: "the contact's name"),
              ),
              const SizedBox(height: 18),

              SgDropdownField<String>(
                label: 'Relationship',
                value: _relationship,
                items: EmergencyContact.relationshipOptions,
                itemLabel: (String value) => value,
                prefixIcon: Icons.diversity_3_rounded,
                onChanged: (String? value) => setState(
                  () => _relationship =
                      value ?? EmergencyContact.relationshipOptions.first,
                ),
              ),
              const SizedBox(height: 18),

              SgTextField(
                label: 'Phone number',
                controller: _phone,
                hint: '+252 61 234 5678',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                maxLength: 20,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s\-()]')),
                ],
                validator: _validatePhone,
                onSubmitted: (_) => _save(),
              ),
              const SizedBox(height: 18),

              // ------------------------------------------- primary toggle
              Container(
                padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.green.withValues(alpha: 0.26),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.star_rounded,
                      color: AppColors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Primary contact',
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Alerted first and called during an emergency.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isPrimary,
                      onChanged: (bool value) =>
                          setState(() => _isPrimary = value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: _save,
                      icon: Icon(
                        _isEditing
                            ? Icons.check_rounded
                            : Icons.person_add_alt_1_rounded,
                      ),
                      label: Text(_isEditing ? 'Save changes' : 'Add contact'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
