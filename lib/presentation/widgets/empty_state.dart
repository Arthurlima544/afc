import 'package:flutter/material.dart';

import 'design_system.dart';

/// Generic empty-state placeholder shown when a list has no items.
///
/// **Required**: [message] — the main descriptive text.
///
/// **Optional**:
/// - [icon] — the icon shown above the message (defaults to [AppIcons.emptyDefault]).
/// - [subtitle] — secondary hint text shown below [message].
/// - [actionLabel] — label for the CTA button; omit to hide the button.
/// - [onAction] — callback for the CTA button tap.
///
/// All optional parameters have `null` / default values so existing call
/// sites that only pass `message` (and optionally `icon`) continue to work
/// without modification.
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.message,
    this.icon = AppIcons.emptyDefault,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String message;
  final IconData icon;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 52, color: AppColors.muted),
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
          if (subtitle != null) ...<Widget>[
            const Gap(6),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.muted),
            ),
          ],
          if (actionLabel != null && onAction != null) ...<Widget>[
            const Gap(24),
            OutlineButton(
              onPressed: onAction,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(AppIcons.add, size: 16),
                  const Gap(6),
                  Text(actionLabel!),
                ],
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
