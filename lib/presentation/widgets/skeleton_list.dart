import 'package:flutter/material.dart';

import 'design_system.dart';

class SkeletonList extends StatelessWidget {
  const SkeletonList({this.itemCount = 4, super.key});

  final int itemCount;

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      for (int i = 0; i < itemCount; i++)
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: AppCard(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _SkeletonBox(width: 160, height: 14),
                Gap(8),
                _SkeletonBox(width: 100, height: 12),
              ],
            ),
          ),
        ),
    ],
  );
}

// ---------------------------------------------------------------------------
// Animated shimmer box
// ---------------------------------------------------------------------------

class _SkeletonBox extends StatefulWidget {
  const _SkeletonBox({required this.width, required this.height});

  final double width;
  final double height;

  @override
  State<_SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<_SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animation = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Respect the user's reduce-motion accessibility setting.
    final bool disableAnimations = MediaQuery.of(context).disableAnimations;

    if (disableAnimations) {
      return _StaticBox(width: widget.width, height: widget.height);
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext ctx, Widget? _) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          gradient: LinearGradient(
            colors: const <Color>[
              Color(0xFF3A3A3A),
              Color(0xFF505050),
              Color(0xFF3A3A3A),
            ],
            stops: <double>[
              (_animation.value - 0.3).clamp(0.0, 1.0),
              _animation.value.clamp(0.0, 1.0),
              (_animation.value + 0.3).clamp(0.0, 1.0),
            ],
          ),
        ),
      ),
    );
  }
}

class _StaticBox extends StatelessWidget {
  const _StaticBox({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: const Color(0xFF3A3A3A),
      borderRadius: BorderRadius.circular(4),
    ),
  );
}
