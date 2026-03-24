import 'package:flutter/material.dart';

import 'design_system.dart';

class SkeletonList extends StatelessWidget {
  const SkeletonList({this.itemCount = 4, this.itemHeight, super.key});

  final int itemCount;

  /// Fixed card height in logical pixels.
  ///
  /// When provided the card occupies exactly this height, filled with
  /// proportionally-sized shimmer rows so it matches the real item.
  /// When null a compact 3-row layout is used (suitable for simple cards).
  final double? itemHeight;

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      for (int i = 0; i < itemCount; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: itemHeight != null
              ? _TallSkeletonCard(height: itemHeight!)
              : const _CompactSkeletonCard(),
        ),
    ],
  );
}

// ---------------------------------------------------------------------------
// Compact card — 3-row layout matching simple list items (e.g. transactions)
// ---------------------------------------------------------------------------

class _CompactSkeletonCard extends StatelessWidget {
  const _CompactSkeletonCard();

  @override
  Widget build(BuildContext context) => const AppCard(
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _SkeletonBox(width: 180, height: 14),
        Gap(8),
        _SkeletonBox(width: 120, height: 12),
        Gap(6),
        _SkeletonBox(width: 80, height: 12),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// Tall card — fixed height with proportional shimmer rows
// ---------------------------------------------------------------------------

class _TallSkeletonCard extends StatelessWidget {
  const _TallSkeletonCard({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(16),
    child: SizedBox(
      height: height,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Title row
          Row(
            children: <Widget>[
              _SkeletonBox(width: 28, height: 28),
              Gap(12),
              Expanded(child: _SkeletonBox(width: double.infinity, height: 16)),
            ],
          ),
          Gap(12),
          // Secondary line
          _SkeletonBox(width: 200, height: 13),
          Gap(8),
          // Tertiary line
          _SkeletonBox(width: 140, height: 13),
          Spacer(),
          // Bottom bar (simulates progress bar or action button)
          _SkeletonBox(width: double.infinity, height: 8),
          Gap(10),
          _SkeletonBox(width: 100, height: 34),
        ],
      ),
    ),
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
