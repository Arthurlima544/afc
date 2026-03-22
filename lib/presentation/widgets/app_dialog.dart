import 'package:flutter/material.dart';

import 'design_system.dart';

/// Shows an AFC-styled [AppAlertDialog] and returns the result.
Future<T?> showAppDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) => showDialog<T>(context: context, builder: builder);

/// AFC branded alert / confirmation dialog.
///
/// Replaces shadcn's `AlertDialog(title:, content:, actions:)`.
class AppAlertDialog extends StatelessWidget {
  const AppAlertDialog({
    required this.title,
    required this.actions,
    this.content,
    super.key,
  });

  final Widget title;
  final Widget? content;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    title: DefaultTextStyle.merge(
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
      child: title,
    ),
    content: content,
    actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    actionsAlignment: MainAxisAlignment.end,
    actions: actions,
  );
}

// ---------------------------------------------------------------------------
// Convenience: input dialog with a single text field
// ---------------------------------------------------------------------------

/// Shows a dialog with a single [TextField] for numeric/text input.
///
/// Returns the entered string, or `null` if cancelled.
Future<String?> showInputDialog({
  required BuildContext context,
  required String title,
  required String hintText,
  TextInputType keyboardType = TextInputType.text,
}) async {
  final TextEditingController controller = TextEditingController();

  final String? result = await showAppDialog<String>(
    context: context,
    builder: (BuildContext dialogContext) => AppAlertDialog(
      title: Text(title),
      content: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          autofocus: true,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: AppColors.muted),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
      actions: <Widget>[
        SecondaryButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Cancelar'),
        ),
        const Gap(8),
        PrimaryButton(
          onPressed: () => Navigator.of(dialogContext).pop(controller.text),
          child: const Text('Confirmar'),
        ),
      ],
    ),
  );

  controller.dispose();
  return result;
}
