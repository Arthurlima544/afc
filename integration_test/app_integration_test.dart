import 'package:afc/presentation/blocs/auth/auth_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockClerkAuthState extends Mock implements ClerkAuthState {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Minimal app that wraps a widget tree with GoRouter and the given AuthBloc.
Widget _buildTestApp({
  required AuthBloc authBloc,
  required Widget home,
}) {
  final GoRouter router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext ctx, GoRouterState s) => home,
      ),
    ],
  );

  return BlocProvider<AuthBloc>.value(
    value: authBloc,
    child: MaterialApp.router(
      routerConfig: router,
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
  });

  tearDown(() {
    mockAuthBloc.close();
  });

  group('Auth state integration', () {
    testWidgets(
      'shows loading indicator when auth state is initial',
      (WidgetTester tester) async {
        // Arrange
        when(() => mockAuthBloc.state).thenReturn(const AuthState.initial());
        when(() => mockAuthBloc.stream).thenAnswer(
          (_) => Stream<AuthState>.value(const AuthState.initial()),
        );

        // Act
        await tester.pumpWidget(
          _buildTestApp(
            authBloc: mockAuthBloc,
            home: BlocBuilder<AuthBloc, AuthState>(
              builder: (BuildContext context, AuthState state) =>
                  state.maybeWhen(
                    orElse: () => const CircularProgressIndicator(),
                  ),
            ),
          ),
        );
        await tester.pump();

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'shows signed-out content when auth state is signedOut',
      (WidgetTester tester) async {
        // Arrange
        when(() => mockAuthBloc.state).thenReturn(const AuthState.signedOut());
        when(() => mockAuthBloc.stream).thenAnswer(
          (_) => Stream<AuthState>.value(const AuthState.signedOut()),
        );

        // Act
        await tester.pumpWidget(
          _buildTestApp(
            authBloc: mockAuthBloc,
            home: BlocBuilder<AuthBloc, AuthState>(
              builder: (BuildContext context, AuthState state) =>
                  state.maybeWhen(
                    signedOut: () => const Text('Please sign in'),
                    orElse: () => const CircularProgressIndicator(),
                  ),
            ),
          ),
        );
        await tester.pump();

        // Assert
        expect(find.text('Please sign in'), findsOneWidget);
      },
    );

    testWidgets(
      'shows signed-in content when auth state is signedIn',
      (WidgetTester tester) async {
        // Arrange
        final MockClerkAuthState clerkState = MockClerkAuthState();
        when(() => mockAuthBloc.state)
            .thenReturn(AuthState.signedIn(clerkState));
        when(() => mockAuthBloc.stream).thenAnswer(
          (_) => Stream<AuthState>.value(AuthState.signedIn(clerkState)),
        );

        // Act
        await tester.pumpWidget(
          _buildTestApp(
            authBloc: mockAuthBloc,
            home: BlocBuilder<AuthBloc, AuthState>(
              builder: (BuildContext context, AuthState state) =>
                  state.maybeWhen(
                    signedIn: (_) => const Text('Welcome'),
                    orElse: () => const CircularProgressIndicator(),
                  ),
            ),
          ),
        );
        await tester.pump();

        // Assert
        expect(find.text('Welcome'), findsOneWidget);
      },
    );
  });

  group('AuthBloc event dispatch integration', () {
    testWidgets(
      'UI rebuilds after signOut event updates auth state',
      (WidgetTester tester) async {
        // Arrange — start signed in, then sign out
        final MockClerkAuthState clerkState = MockClerkAuthState();
        final Stream<AuthState> stateStream = Stream<AuthState>.fromIterable(
          <AuthState>[
            AuthState.signedIn(clerkState),
            const AuthState.signedOut(),
          ],
        );
        when(() => mockAuthBloc.state)
            .thenReturn(AuthState.signedIn(clerkState));
        when(() => mockAuthBloc.stream).thenAnswer((_) => stateStream);

        // Act
        await tester.pumpWidget(
          _buildTestApp(
            authBloc: mockAuthBloc,
            home: BlocBuilder<AuthBloc, AuthState>(
              builder: (BuildContext context, AuthState state) =>
                  state.maybeWhen(
                    signedIn: (_) => const Text('Signed In'),
                    signedOut: () => const Text('Signed Out'),
                    orElse: () => const SizedBox.shrink(),
                  ),
            ),
          ),
        );
        await tester.pump();

        // Assert initial state
        expect(find.text('Signed In'), findsOneWidget);

        // Act — stream emits signedOut
        await tester.pump();

        // Assert final state
        expect(find.text('Signed Out'), findsOneWidget);
      },
    );
  });
}
