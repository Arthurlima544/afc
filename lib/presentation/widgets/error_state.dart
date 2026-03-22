import 'package:flutter/material.dart';

import 'design_system.dart';

/// Generic error-state placeholder with a retry action.
///
/// Shows an icon, the [message], and a "Tentar novamente" button that
/// calls [onRetry].  All list screens should render this widget instead
/// of a raw [Text] whenever their BLoC emits an error state.
class ErrorState extends StatelessWidget {
  const ErrorState({required this.message, required this.onRetry, super.key});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(AppIcons.error, size: 52, color: AppColors.expense),
          const Gap(16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
          ),
          const Gap(24),
          OutlineButton(
            onPressed: onRetry,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    ),
  );
}
