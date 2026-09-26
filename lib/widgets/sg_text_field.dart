import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A labelled text field with consistent spacing, icons and validation.
///
/// Every form in SecureGuard uses this widget so the inputs look and behave
/// identically across the application.
class SgTextField extends StatefulWidget {
  const SgTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.prefixIcon,
    this.keyboardType,
    this.validator,
    this.obscure = false,
    this.textInputAction,
    this.onSubmitted,
    this.enabled = true,
    this.maxLength,
    this.inputFormatters,
    this.autofillHints,
    this.helperText,
    this.onChanged,
    this.textCapitalization = TextCapitalization.none,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  /// When true the field starts hidden and gains a show/hide button.
  final bool obscure;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final String? helperText;
  final ValueChanged<String>? onChanged;
  final TextCapitalization textCapitalization;

  @override
  State<SgTextField> createState() => _SgTextFieldState();
}

class _SgTextFieldState extends State<SgTextField> {
  late bool _hidden = widget.obscure;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          widget.label,
          style: theme.textTheme.titleSmall?.copyWith(fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: _hidden,
          enabled: widget.enabled,
          validator: widget.validator,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onSubmitted,
          onChanged: widget.onChanged,
          maxLength: widget.maxLength,
          inputFormatters: widget.inputFormatters,
          autofillHints: widget.autofillHints,
          textCapitalization: widget.textCapitalization,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: widget.hint,
            helperText: widget.helperText,
            counterText: '',
            prefixIcon: widget.prefixIcon == null
                ? null
                : Icon(widget.prefixIcon),
            suffixIcon: widget.obscure
                ? IconButton(
                    onPressed: () => setState(() => _hidden = !_hidden),
                    icon: Icon(
                      _hidden
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    tooltip: _hidden ? 'Show password' : 'Hide password',
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

/// A labelled dropdown that matches [SgTextField].
class SgDropdownField<T> extends StatelessWidget {
  const SgDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.prefixIcon,
  });

  final String label;
  final T value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;
  final IconData? prefixIcon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: theme.textTheme.titleSmall?.copyWith(fontSize: 14)),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          initialValue: value,
          isExpanded: true,
          borderRadius: BorderRadius.circular(14),
          decoration: InputDecoration(
            prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
          ),
          style: theme.textTheme.bodyLarge,
          items: items
              .map(
                (T item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(itemLabel(item)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
