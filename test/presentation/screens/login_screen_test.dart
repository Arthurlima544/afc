import 'dart:async';

import 'package:afc/presentation/blocs/auth/auth_bloc.dart';
import 'package:afc/presentation/screens/login_screen.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockClerkAuthState extends Mock implements ClerkAuthState {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Wraps [LoginScreen] for navigation tests.
///
/// Passes a stub child to [LoginScreen] so tests do not need a live
/// ClerkAuth ancestor (which requires a valid publishable key and starts
/// network timers that prevent pumpAndSettle from completing).
Widget _buildApp({
  required MockAuthBloc authBloc,
  required Stream<AuthState> stateStream,
}) {
  when(() => authBloc.stream).thenAnswer((_) => stateStream);

  return BlocProvider<AuthBloc>.value(
    value: authBloc,
    child: MaterialApp.router(
      routerConfig: GoRouter(
        initialLocation: '/login',
        routes: <GoRoute>[
          GoRoute(
            path: '/login',
            builder: (BuildContext ctx, GoRouterState s) =>
                const LoginScreen(child: SizedBox()),
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

/// Wraps [LoginScreen] with a real [ClerkAuth] ancestor.
/// Used only for tests that verify the widget mounts without throwing —
/// navigation assertions are done via [_buildApp] to avoid Clerk timer hangs.
Widget _buildAppWithClerk({
  required MockAuthBloc authBloc,
  required Stream<AuthState> stateStream,
}) {
  when(() => authBloc.stream).thenAnswer((_) => stateStream);

  return BlocProvider<AuthBloc>.value(
    value: authBloc,
    child: ClerkAuth(
      config: ClerkAuthConfig(
        publishableKey: const String.fromEnvironment('CLERK_PUBLISHABLE_KEY'),
      ),
      child: MaterialApp.router(
        routerConfig: GoRouter(
          initialLocation: '/login',
          routes: <GoRoute>[
            GoRoute(
              path: '/login',
              builder: (BuildContext ctx, GoRouterState s) =>
                  const LoginScreen(),
            ),
          ],
        ),
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
  });

  tearDown(() => mockAuthBloc.close());

  group('LoginScreen (US-06 — auto-redirect after sign-in)', () {
    testWidgets('mounts without throwing', (WidgetTester tester) async {
      // Arrange
      final StreamController<AuthState> controller =
          StreamController<AuthState>.broadcast();

      // Act — use ClerkAuth wrapper to verify the full widget tree renders
      await tester.pumpWidget(
        _buildAppWithClerk(
          authBloc: mockAuthBloc,
          stateStream: controller.stream,
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));

      // Assert — no exception; widget was built
      expect(tester.takeException(), isNull);

      await controller.close();
    });

    testWidgets(
        'navigates to /home when AuthBloc emits signedIn',
        (WidgetTester tester) async {
      // Arrange — the BlocListener in LoginScreen only navigates on signedIn
      final MockClerkAuthState clerkState = MockClerkAuthState();
      final StreamController<AuthState> controller =
          StreamController<AuthState>.broadcast();

      await tester.pumpWidget(
        _buildApp(authBloc: mockAuthBloc, stateStream: controller.stream),
      );
      await tester.pump();

      // Act — simulate _ClerkAuthObserver dispatching AuthEvent.signIn
      // which causes AuthBloc to emit signedIn
      controller.add(AuthState.signedIn(clerkState));
      await tester.pumpAndSettle(); // BlocListener fires + route transition completes

      // Assert
      expect(find.text('Home Screen'), findsOneWidget);

      await controller.close();
    });

    testWidgets(
        'stays on /login when AuthBloc emits signedOut',
        (WidgetTester tester) async {
      // Arrange
      final StreamController<AuthState> controller =
          StreamController<AuthState>.broadcast();

      await tester.pumpWidget(
        _buildApp(authBloc: mockAuthBloc, stateStream: controller.stream),
      );
      await tester.pump(const Duration(milliseconds: 50));

      // Act — signedOut should NOT trigger navigation from /login
      controller.add(const AuthState.signedOut());
      await tester.pump();
      await tester.pump();

      // Assert — still on login; /home was not navigated to
      expect(find.text('Home Screen'), findsNothing);

      await controller.close();
    });

    testWidgets(
        'stays on /login when AuthBloc emits unknown state',
        (WidgetTester tester) async {
      // Arrange
      final StreamController<AuthState> controller =
          StreamController<AuthState>.broadcast();

      await tester.pumpWidget(
        _buildApp(authBloc: mockAuthBloc, stateStream: controller.stream),
      );
      await tester.pump(const Duration(milliseconds: 50));

      // Act
      controller.add(const AuthState.unknown());
      await tester.pump();
      await tester.pump();

      // Assert
      expect(find.text('Home Screen'), findsNothing);

      await controller.close();
    });
  });

  group('LoginScreen — constructor', () {
    test('accepts no required parameters', () {
      // Arrange & Act
      const LoginScreen screen = LoginScreen();

      // Assert
      expect(screen, isA<LoginScreen>());
    });
  });
}
