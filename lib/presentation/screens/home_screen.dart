import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/theme/app_colors.dart';
import '../blocs/auth/auth_bloc.dart';
import 'onboarding_screen.dart';

/// Animated splash / redirect screen shown at `/`.
///
/// Shows the AFC brand logo with a fade + scale entrance animation while
/// the [AuthBloc] resolves the Clerk session. As soon as auth state is
/// known the [BlocListener] navigates to the correct destination:
///   - [AuthState.signedIn]  → `/home`
///   - [AuthState.signedOut] → `/login`
///
/// No Clerk dependency here — fully testable with a mocked [AuthBloc].
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _opacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );

    _scale = Tween<double>(begin: 0.72, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static Future<void> _navigateAfterSignIn(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!context.mounted) {
      return;
    }
    final bool done = prefs.getBool(OnboardingScreen.keyDone) ?? false;
    context.go(done ? '/home' : '/onboarding');
  }

  @override
  Widget build(BuildContext context) => BlocListener<AuthBloc, AuthState>(
    listener: (BuildContext context, AuthState state) {
      state.whenOrNull(
        signedIn: (_) => unawaited(_navigateAfterSignIn(context)),
        signedOut: () => context.go('/login'),
      );
    },
    child: Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: ScaleTransition(
            scale: _scale,
            child: const _AfcLogo(),
          ),
        ),
      ),
    ),
  );
}

/// AFC brand logo — displayed on the animated splash screen.
///
/// Built entirely in Flutter so no image assets are required.
/// Replace the body of [build] with an [Image.asset] when a graphic asset
/// is available.
class _AfcLogo extends StatelessWidget {
  const _AfcLogo();

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.onPrimary.withAlpha(0x26), // 15 % white
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(
          Icons.account_balance_wallet_outlined,
          size: 44,
          color: AppColors.onPrimary,
        ),
      ),
      const SizedBox(height: 20),
      const Text(
        'AFC',
        style: TextStyle(
          color: AppColors.onPrimary,
          fontSize: 36,
          fontWeight: FontWeight.w800,
          letterSpacing: 6,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        'Finanças pessoais',
        style: TextStyle(
          color: AppColors.onPrimary.withAlpha(0xCC), // 80 % white
          fontSize: 13,
          fontWeight: FontWeight.w400,
          letterSpacing: 1.2,
        ),
      ),
    ],
  );
}
