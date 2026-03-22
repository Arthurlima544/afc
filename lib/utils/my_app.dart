import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../config/routes/router.dart';
import '../config/theme/app_theme.dart';
import '../presentation/blocs/auth/auth_bloc.dart';
import '../presentation/blocs/theme/theme_cubit.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final ThemeCubit _themeCubit;

  @override
  void initState() {
    super.initState();
    _themeCubit = ThemeCubit();
    _themeCubit.loadSavedTheme();
  }

  @override
  void dispose() {
    _themeCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: <BlocProvider<dynamic>>[
      BlocProvider<ThemeCubit>.value(value: _themeCubit),
      BlocProvider<AuthBloc>(
        create: (BuildContext context) => AuthBloc(
          onFirebaseSignIn: () => FirebaseAuth.instance.signInAnonymously(),
          onFirebaseSignOut: () => FirebaseAuth.instance.signOut(),
        ),
      ),
    ],
    child: BlocBuilder<ThemeCubit, ThemePreference>(
      builder: (BuildContext context, ThemePreference preference) =>
          ClerkAuth(
            config: ClerkAuthConfig(
              publishableKey:
                  const String.fromEnvironment('CLERK_PUBLISHABLE_KEY'),
            ),
            child: _ClerkAuthObserver(
              child: MaterialApp.router(
                debugShowCheckedModeBanner: false,
                title: 'AFC',
                routerConfig: router,
                theme: _themeDataFor(preference, Brightness.light),
                darkTheme: _themeDataFor(preference, Brightness.dark),
                themeMode: _themeModeFor(preference),
              ),
            ),
          ),
    ),
  );

  static ThemeData _themeDataFor(
    ThemePreference preference,
    Brightness brightness,
  ) {
    switch (preference) {
      case ThemePreference.light:
        return AppTheme.light();
      case ThemePreference.dark:
        return AppTheme.dark();
      case ThemePreference.system:
        return brightness == Brightness.dark
            ? AppTheme.dark()
            : AppTheme.light();
    }
  }

  static ThemeMode _themeModeFor(ThemePreference preference) {
    switch (preference) {
      case ThemePreference.light:
        return ThemeMode.light;
      case ThemePreference.dark:
        return ThemeMode.dark;
      case ThemePreference.system:
        return ThemeMode.system;
    }
  }
}

/// Listens to Clerk's auth state and dispatches the corresponding
/// [AuthEvent] to [AuthBloc]. This is the single place in the app that
/// bridges Clerk and AuthBloc, keeping all other screens decoupled from
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
