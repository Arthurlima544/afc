import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/privacy/privacy_cubit.dart';

/// Displays [text] normally, or replaces it with `"•••••"` when
/// [PrivacyCubit] is in the hidden state.
///
/// Wrap any sensitive monetary string with this widget instead of
/// a plain [Text] to respect the user's privacy-mode toggle.
class PrivacyText extends StatelessWidget {
  const PrivacyText(this.text, {this.style, super.key});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<PrivacyCubit, bool>(
        builder: (BuildContext context, bool isHidden) => AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            isHidden ? '•••••' : text,
            key: ValueKey<bool>(isHidden),
            style: style,
          ),
        ),
      );
}
