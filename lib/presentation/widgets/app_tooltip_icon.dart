import 'package:flutter/material.dart';

/// A small ⓘ icon that surfaces a [message] tooltip on tap.
///
/// Place it next to labels in calculators and score cards to explain
/// financial concepts inline without cluttering the UI.
///
/// ```dart
/// Row(children: [
///   const Text('Taxa de retirada segura', style: AppTextStyles.label),
///   const Gap(4),
///   const AppTooltipIcon(
///     'Percentual que você retira anualmente do portfólio na aposentadoria. '
///     '4% é o padrão histórico seguro.',
///   ),
/// ])
/// ```
class AppTooltipIcon extends StatelessWidget {
  const AppTooltipIcon(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: message,
    triggerMode: TooltipTriggerMode.tap,
    showDuration: const Duration(seconds: 4),
    child: const Icon(
      Icons.info_outline,
      size: 14,
      color: Color(0xFF9CA3AF),
    ),
  );
}
