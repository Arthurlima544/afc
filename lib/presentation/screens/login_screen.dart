import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../blocs/auth/auth_bloc.dart';

/// Authentication screen shown at `/login`.
///
/// Displays the Clerk sign-in UI. The ClerkAuthObserver in MyApp handles
/// dispatching AuthEvent.signIn when Clerk detects a session. This screen
/// only listens to AuthBloc for the resulting AuthState.signedIn and
/// navigates to `/home` — no direct Clerk dependency in the navigation logic.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key, @visibleForTesting this.child});

  /// Override the default [ClerkAuthentication] child.
  /// Used in widget tests to avoid a live [ClerkAuth] dependency.
  final Widget? child;

  @override
  Widget build(BuildContext context) => BlocListener<AuthBloc, AuthState>(
    listener: (BuildContext context, AuthState state) {
      state.whenOrNull(signedIn: (_) => context.go('/home'));
    },
    child: child ??
        const Scaffold(
          body: SafeArea(
            child: ClerkErrorListener(
              child: ClerkAuthentication(),
            ),
          ),
        ),
  );
}
