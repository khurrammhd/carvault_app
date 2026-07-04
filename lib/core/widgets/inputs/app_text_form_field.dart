import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// The standard text input for every form in the app: a persistent
/// static label above the field (not Material's floating label), a
/// visible + programmatic required-field marker, and keyboard/autofill
/// wiring.
class AppTextFormField extends StatelessWidget {
  const AppTextFormField({
    required this.label,
    this.controller,
    this.isRequired = false,
    this.obscureText = false,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.autofillHints,
    this.focusNode,
    this.onChanged,
    this.onFieldSubmitted,
    this.validator,
    this.hintText,
    this.maxLines = 1,
    this.inputFormatters,
    this.style,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final bool isRequired;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final String? Function(String?)? validator;
  final String? hintText;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: isRequired ? '$label, required' : label,
          excludeSemantics: true,
          child: Row(
            children: [
              Text(label, style: AppTextStyles.label),
              if (isRequired) ...[
                const SizedBox(width: 2),
                const Text('*', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
              ],
            ],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          focusNode: focusNode,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          validator: validator,
          maxLines: obscureText ? 1 : maxLines,
          inputFormatters: inputFormatters,
          style: style ?? AppTextStyles.inputText,
          decoration: InputDecoration(hintText: hintText, errorMaxLines: 2),
        ),
      ],
    );
  }
}
