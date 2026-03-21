import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../config/routes/router.dart';
import '../presentation/blocs/auth/auth_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider<AuthBloc>(
    create: (BuildContext context) => AuthBloc(),
    child: ClerkAuth(
      config: ClerkAuthConfig(
        publishableKey: const String.fromEnvironment('CLERK_PUBLISHABLE_KEY'),
      ),
      child: _ClerkAuthObserver(
        child: ShadcnApp.router(
          debugShowCheckedModeBanner: false,
          title: 'AFC',
          routerConfig: router,
          theme: ThemeData(colorScheme: LegacyColorSchemes.darkViolet()),
        ),
      ),
    ),
  );
}

/// Listens to Clerk's auth state and dispatches the corresponding
/// [AuthEvent] to [AuthBloc]. This is the single place in the app that
/// bridges Clerk ↔ AuthBloc, keeping all other screens decoupled from
/// the Clerk SDK and fully testable via a mocked [AuthBloc].
class _ClerkAuthObserver extends StatelessWidget {
  const _ClerkAuthObserver({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => ClerkAuthBuilder(
    signedInBuilder: (BuildContext context, ClerkAuthState authState) {
      context.read<AuthBloc>().add(AuthEvent.signIn(authState));
      return child;
    },
    signedOutBuilder: (BuildContext context, ClerkAuthState authState) {
      context.read<AuthBloc>().add(const AuthEvent.signOut());
      return child;
    },
  );
}
