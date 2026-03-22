import 'dart:async';

import 'package:afc/presentation/blocs/auth/auth_bloc.dart';
import 'package:afc/presentation/screens/home_screen.dart';
import 'package:afc/presentation/screens/onboarding_screen.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockClerkAuthState extends Mock implements ClerkAuthState {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Builds a testable app with GoRouter spy routes.
/// No [ClerkAuth] needed — [HomeScreen] only depends on [AuthBloc].
Widget _buildApp({
  required MockAuthBloc authBloc,
  required Stream<AuthState> stateStream,
}) {
  when(() => authBloc.stream).thenAnswer((_) => stateStream);

  return BlocProvider<AuthBloc>.value(
    value: authBloc,
    child: MaterialApp.router(
      routerConfig: GoRouter(
        initialLocation: '/',
        routes: <GoRoute>[
          GoRoute(
            path: '/',
            builder: (BuildContext ctx, GoRouterState s) => const HomeScreen(),
          ),
          GoRoute(
            path: '/login',
            builder: (BuildContext ctx, GoRouterState s) =>
                const Scaffold(body: Text('Login Screen')),
          ),
          GoRoute(
            path: '/home',
            builder: (BuildContext ctx, GoRouterState s) =>
                const Scaffold(body: Text('Home Screen')),
          ),
        ],
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    when(() => mockAuthBloc.state).thenReturn(const AuthState.initial());
    // Mark onboarding as complete so sign-in always routes to /home.
    SharedPreferences.setMockInitialValues(
      <String, Object>{OnboardingScreen.keyDone: true},
    );
  });

  tearDown(() => mockAuthBloc.close());

  group('HomeScreen (US-05 — auto-redirect on app launch)', () {
    testWidgets(
        'shows branded splash while auth state is initial',
        (WidgetTester tester) async {
      // Arrange — stream never emits, auth stays in initial state
      final StreamController<AuthState> controller =
          StreamController<AuthState>.broadcast();

      await tester.pumpWidget(
        _buildApp(authBloc: mockAuthBloc, stateStream: controller.stream),
      );

      // Act — single frame, no state change emitted
      await tester.pump();

      // Assert — branded splash shows the app name; no navigation yet
      expect(find.text('AFC'), findsOneWidget);
      expect(find.text('Login Screen'), findsNothing);
      expect(find.text('Home Screen'), findsNothing);

      await controller.close();
    });

    testWidgets(
        'navigates to /login when AuthBloc emits signedOut',
        (WidgetTester tester) async {
      // Arrange
      final StreamController<AuthState> controller =
          StreamController<AuthState>.broadcast();

      await tester.pumpWidget(
        _buildApp(authBloc: mockAuthBloc, stateStream: controller.stream),
      );
      await tester.pump();

      // Act — simulate Clerk detecting no session → AuthEvent.signOut
      controller.add(const AuthState.signedOut());
      await tester.pump(); // BlocListener fires
      await tester.pump(); // router rebuilds

      // Assert
      expect(find.text('Login Screen'), findsOneWidget);
      expect(find.text('Home Screen'), findsNothing);

      await controller.close();
    });

    testWidgets(
        'navigates to /home when AuthBloc emits signedIn',
        (WidgetTester tester) async {
      // Arrange
      final MockClerkAuthState clerkState = MockClerkAuthState();
      final StreamController<AuthState> controller =
          StreamController<AuthState>.broadcast();

      await tester.pumpWidget(
        _buildApp(authBloc: mockAuthBloc, stateStream: controller.stream),
      );
      await tester.pump();

      // Act — simulate successful sign-in
      controller.add(AuthState.signedIn(clerkState));
      await tester.pump(); // BlocListener fires
      await tester.pump(); // router rebuilds

      // Assert
      expect(find.text('Home Screen'), findsOneWidget);
      expect(find.text('Login Screen'), findsNothing);

      await controller.close();
    });

    testWidgets(
        'does NOT navigate when AuthBloc emits unknown state',
        (WidgetTester tester) async {
      // Arrange
      final StreamController<AuthState> controller =
          StreamController<AuthState>.broadcast();

      await tester.pumpWidget(
        _buildApp(authBloc: mockAuthBloc, stateStream: controller.stream),
      );
      await tester.pump();

      // Act — unknown state must not trigger any redirect
      controller.add(const AuthState.unknown());
      await tester.pump();
      await tester.pump();

      // Assert — still on branded splash, no navigation occurred
      expect(find.text('AFC'), findsOneWidget);

      await controller.close();
    });

    testWidgets(
        'navigates to /login then back to /home on subsequent state changes',
        (WidgetTester tester) async {
      // Arrange
      final MockClerkAuthState clerkState = MockClerkAuthState();
      final StreamController<AuthState> controller =
          StreamController<AuthState>.broadcast();

      await tester.pumpWidget(
        _buildApp(authBloc: mockAuthBloc, stateStream: controller.stream),
      );
      await tester.pump();

      // Act — sign-out first
      controller.add(const AuthState.signedOut());
      await tester.pump();
      await tester.pump();
      expect(find.text('Login Screen'), findsOneWidget);

      // Act — then sign in
      controller.add(AuthState.signedIn(clerkState));
      await tester.pump();
      await tester.pump();

      // Assert
      expect(find.text('Home Screen'), findsOneWidget);

      await controller.close();
    });
  });
}
