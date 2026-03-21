import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../blocs/auth/auth_bloc.dart';

/// Splash/redirect screen shown at `/`.
///
/// The ClerkAuthObserver in MyApp dispatches AuthEvents from Clerk.
/// This screen only listens to AuthBloc state and navigates accordingly:
///   - AuthState.signedIn  → `/home`
///   - AuthState.signedOut → `/login`
///
/// No Clerk dependency here — fully testable with a mocked AuthBloc.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocListener<AuthBloc, AuthState>(
    listener: (BuildContext context, AuthState state) {
      state.whenOrNull(
        signedIn: (_) => context.go('/home'),
        signedOut: () => context.go('/login'),
      );
    },
    child: const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    ),
  );
}
