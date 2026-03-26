import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../config/routes/router.dart';
import '../config/theme/app_theme.dart';
import '../presentation/blocs/auth/auth_bloc.dart';
import '../presentation/blocs/privacy/privacy_cubit.dart';
import '../presentation/blocs/theme/theme_cubit.dart';
import 'logger.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final ThemeCubit _themeCubit;
  late final PrivacyCubit _privacyCubit;

  @override
  void initState() {
    super.initState();
    _themeCubit = ThemeCubit();
    _themeCubit.loadSavedTheme();
    _privacyCubit = PrivacyCubit();
    _privacyCubit.loadSavedPrivacy();
  }

  @override
  void dispose() {
    _themeCubit.close();
    _privacyCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: <BlocProvider<dynamic>>[
      BlocProvider<ThemeCubit>.value(value: _themeCubit),
      BlocProvider<PrivacyCubit>.value(value: _privacyCubit),
      BlocProvider<AuthBloc>(
        create: (BuildContext context) => AuthBloc(
          onFirebaseSignIn: _firebaseSignIn,
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

  /// Exchanges a Clerk user ID for a Firebase custom token and signs in.
  ///
  /// Falls back to anonymous sign-in if the function call fails so the app
  /// remains usable in environments where the Cloud Function is unreachable.
  static Future<void> _firebaseSignIn(String clerkUserId) async {
    if (clerkUserId.isEmpty) {
      return;
    }
    try {
      final HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('getFirebaseToken');
      final HttpsCallableResult<dynamic> result =
          await callable.call(<String, dynamic>{'clerkUserId': clerkUserId});
      final String token = (result.data as Map<dynamic, dynamic>)['token']
          as String;
      await FirebaseAuth.instance.signInWithCustomToken(token);
    } on Exception catch (e) {
      logger.w('getFirebaseToken failed, falling back to anonymous: $e');
      await FirebaseAuth.instance.signInAnonymously();
    }
  }

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
      // Only dispatch signOut once Clerk has finished initialising.
      // isNotAvailable is true while the env/client are still loading,
      // so dispatching signOut in that window causes a login-screen flicker
      // for users who are already authenticated.
      if (!authState.isNotAvailable) {
        context.read<AuthBloc>().add(const AuthEvent.signOut());
      }
      return child;
    },
  );
}
