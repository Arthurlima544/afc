import 'package:flutter/widgets.dart';

/// Drop-in replacement for shadcn_flutter's Gap widget.
///
// ignore: comment_references
/// Renders a [SizedBox] with both [width] and [height] set to [size],
/// so it works as spacing in both [Row] and [Column] without needing
/// a separate [SizedBox.shrink] / axis-specific version.
class Gap extends StatelessWidget {
  const Gap(this.size, {super.key});

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(width: size, height: size);
}
