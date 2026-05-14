import 'package:flutter/material.dart';

import 'jf_button.dart';

/// Standard yes/no dialog used across the app for destructive and
/// confirmation actions (download deletion, Seerr request, …). Returns
/// `true` when the user taps the confirm button, `false` otherwise.
///
/// Prefer the [showJfConfirm] helper over instantiating this directly.
class JfConfirmDialog extends StatelessWidget {
  const JfConfirmDialog({
    required this.title,
    required this.message,
    this.confirmLabel = 'OK',
    this.cancelLabel = 'Annuler',
    this.destructive = false,
    this.confirmIcon,
    super.key,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;

  /// When true, the confirm button uses the error-tinted destructive variant.
  final bool destructive;

  /// Optional leading icon on the confirm button.
  final IconData? confirmIcon;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        JfButton.ghost(
          label: cancelLabel,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        if (destructive)
          JfButton.destructive(
            label: confirmLabel,
            icon: confirmIcon,
            onPressed: () => Navigator.of(context).pop(true),
          )
        else
          JfButton.primary(
            label: confirmLabel,
            icon: confirmIcon,
            onPressed: () => Navigator.of(context).pop(true),
          ),
      ],
    );
  }
}

/// Shows a [JfConfirmDialog] and resolves to `true` only when the user taps
/// confirm. Dismissing the dialog (back button, scrim tap) resolves to false.
Future<bool> showJfConfirm(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'OK',
  String cancelLabel = 'Annuler',
  bool destructive = false,
  IconData? confirmIcon,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => JfConfirmDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      destructive: destructive,
      confirmIcon: confirmIcon,
    ),
  );
  return result ?? false;
}
