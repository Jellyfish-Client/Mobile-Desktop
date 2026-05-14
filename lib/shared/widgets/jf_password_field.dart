import 'package:flutter/material.dart';

import 'jf_text_field.dart';

/// Password text input with a built-in show/hide toggle.
///
/// All [JfTextField] props are passed through. The `obscureText`,
/// `keyboardType` and `suffix` props are managed internally — don't override.
class JfPasswordField extends StatefulWidget {
  const JfPasswordField({
    this.controller,
    this.label,
    this.hint = 'Password',
    this.helper,
    this.errorText,
    this.prefixIcon = Icons.lock_outline,
    this.textInputAction,
    this.enabled = true,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.focusNode,
    super.key,
  });

  final TextEditingController? controller;
  final String? label;
  final String hint;
  final String? helper;
  final String? errorText;
  final IconData? prefixIcon;
  final TextInputAction? textInputAction;
  final bool enabled;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final FocusNode? focusNode;

  @override
  State<JfPasswordField> createState() => _JfPasswordFieldState();
}

class _JfPasswordFieldState extends State<JfPasswordField> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return JfTextField(
      controller: widget.controller,
      label: widget.label,
      hint: widget.hint,
      helper: widget.helper,
      errorText: widget.errorText,
      prefixIcon: widget.prefixIcon,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      enabled: widget.enabled,
      autocorrect: false,
      obscureText: !_visible,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      autofocus: widget.autofocus,
      focusNode: widget.focusNode,
      suffix: IconButton(
        icon: Icon(
          _visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        ),
        tooltip: _visible ? 'Hide password' : 'Show password',
        onPressed: widget.enabled
            ? () => setState(() => _visible = !_visible)
            : null,
      ),
    );
  }
}
