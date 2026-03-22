import 'package:flutter/material.dart';

/// Shows a draggable modal bottom sheet suitable for create/edit forms.
///
/// The sheet occupies 90 % of the screen height initially and can be dragged
/// between 50 % (min) and 95 % (max). The surface colour and rounded top
/// corners are drawn inside the sheet — the outer background is transparent.
///
/// Usage:
/// ```dart
/// await showFormSheet<void>(
///   context,
///   builder: (ctx) => BlocProvider<MyCubit>(
///     create: (_) => MyCubit(),
///     child: const MyForm(),
///   ),
/// );
/// ```
Future<T?> showFormSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) =>
    showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (BuildContext _, ScrollController _) => Container(
          decoration: BoxDecoration(
            color: Theme.of(sheetContext).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: builder(sheetContext),
        ),
      ),
    );
