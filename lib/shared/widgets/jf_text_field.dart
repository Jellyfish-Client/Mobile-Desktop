import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';

/// Standard Jellyfish text input. Wraps `TextFormField` with our look,
/// optional [label] above the field, [hint], leading/trailing icons, and
/// validation feedback.
///
/// Use this everywhere instead of raw `TextFormField` so we keep visual
/// consistency and can iterate on the design from one place.
class JfTextField extends StatelessWidget {
  const JfTextField({
    this.controller,
    this.label,
    this.hint,
    this.helper,
    this.errorText,
    this.prefixIcon,
    this.suffix,
    this.keyboardType,
    this.textInputAction,
    this.autocorrect = true,
    this.enabled = true,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.focusNode,
    super.key,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helper;
  final String? errorText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool autocorrect;
  final bool enabled;
  final bool obscureText;
  final int? maxLines;
  final int? minLines;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: theme.textTheme.labelLarge?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        TextFormField(
          controller: controller,
          enabled: enabled,
          autocorrect: autocorrect,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          maxLines: obscureText ? 1 : maxLines,
          minLines: minLines,
          inputFormatters: inputFormatters,
          autofocus: autofocus,
          focusNode: focusNode,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onSurface),
          cursorColor: scheme.primary,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
            prefixIcon: prefixIcon == null
                ? null
                : Icon(prefixIcon, color: scheme.onSurfaceVariant, size: 20),
            suffixIcon: suffix,
            errorText: errorText,
            errorMaxLines: 2,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            border: _border(scheme.outline),
            enabledBorder: _border(scheme.outlineVariant),
            focusedBorder: _border(scheme.primary, width: 1.5),
            disabledBorder: _border(
              scheme.outlineVariant.withValues(alpha: 0.5),
            ),
            errorBorder: _border(scheme.error, width: 1.5),
            focusedErrorBorder: _border(scheme.error, width: 1.5),
            filled: true,
            fillColor: enabled
                ? scheme.surfaceContainer
                : scheme.surfaceContainerHigh,
          ),
        ),
        if (helper != null && errorText == null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            helper!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
