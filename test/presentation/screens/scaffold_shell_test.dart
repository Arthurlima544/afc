import 'package:afc/presentation/blocs/auth/auth_bloc.dart';
import 'package:afc/presentation/blocs/recurring/recurring_cubit.dart';
import 'package:afc/presentation/screens/scaffold_shell.dart';
import 'package:afc/utils/connectivity_service.dart';
import 'package:afc/utils/sync_queue.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
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

/// Builds a GoRouter with a [StatefulShellRoute] that hosts [ScaffoldShell].
/// Four stub branches give the shell its four tabs.
GoRouter _buildRouter({
  required MockAuthBloc authBloc,
  required RecurringCubit recurringCubit,
}) =>
    GoRouter(
      initialLocation: '/tab0',
      routes: <RouteBase>[
        StatefulShellRoute.indexedStack(
          builder: (
            BuildContext context,
            GoRouterState state,
            StatefulNavigationShell shell,
          ) =>
              MultiBlocProvider(
            providers: <BlocProvider<dynamic>>[
              BlocProvider<AuthBloc>.value(value: authBloc),
              BlocProvider<RecurringCubit>.value(value: recurringCubit),
            ],
            child: ScaffoldShell(navigationShell: shell),
          ),
          branches: <StatefulShellBranch>[
            StatefulShellBranch(
              routes: <GoRoute>[
                GoRoute(
                  path: '/tab0',
                  builder: (_, _) => const Scaffold(body: Text('Tab 0')),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <GoRoute>[
                GoRoute(
                  path: '/tab1',
                  builder: (_, _) => const Scaffold(body: Text('Tab 1')),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <GoRoute>[
                GoRoute(
                  path: '/tab2',
                  builder: (_, _) => const Scaffold(body: Text('Tab 2')),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: <GoRoute>[
                GoRoute(
                  path: '/tab3',
                  builder: (_, _) => const Scaffold(body: Text('Tab 3')),
                ),
              ],
            ),
          ],
        ),
      ],
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockAuthBloc mockAuthBloc;
  late RecurringCubit recurringCubit;

  setUp(() async {
    await GetIt.I.reset();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    ConnectivityService.register();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    GetIt.I.registerSingleton<SyncQueue>(SyncQueue(firestore: FakeFirebaseFirestore()));
    SyncQueue.instance.attachPrefs(prefs);

    mockAuthBloc = MockAuthBloc();
    when(() => mockAuthBloc.state).thenReturn(const AuthState.initial());
    when(() => mockAuthBloc.stream).thenAnswer(
      (_) => const Stream<AuthState>.empty(),
    );
    recurringCubit = RecurringCubit(firestore: FakeFirebaseFirestore());
  });

  tearDown(() async {
    await mockAuthBloc.close();
    await recurringCubit.close();
    await GetIt.I.reset();
  });

  group('ScaffoldShell (US-15 — bottom navigation tab switching)', () {
    testWidgets(
      'renders NavigationBar with 4 destinations',
      (WidgetTester tester) async {
        final GoRouter router = _buildRouter(
          authBloc: mockAuthBloc,
          recurringCubit: recurringCubit,
        );

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pump();

        expect(find.byType(NavigationBar), findsOneWidget);
        expect(find.byType(NavigationDestination), findsNWidgets(4));
      },
    );

    testWidgets(
      'renders all expected destination labels',
      (WidgetTester tester) async {
        final GoRouter router = _buildRouter(
          authBloc: mockAuthBloc,
          recurringCubit: recurringCubit,
        );

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pump();

        expect(find.text('Início'), findsOneWidget);
        expect(find.text('Transações'), findsOneWidget);
        expect(find.text('Limites'), findsOneWidget);
        expect(find.text('Metas'), findsOneWidget);
      },
    );

    testWidgets(
      'renders FloatingActionButton for quick-add',
      (WidgetTester tester) async {
        final GoRouter router = _buildRouter(
          authBloc: mockAuthBloc,
          recurringCubit: recurringCubit,
        );

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pump();

        expect(find.byType(FloatingActionButton), findsOneWidget);
        expect(find.byIcon(Icons.add), findsOneWidget);
      },
    );

    testWidgets(
      'tab 0 (Início) is selected on initial load',
      (WidgetTester tester) async {
        final GoRouter router = _buildRouter(
          authBloc: mockAuthBloc,
          recurringCubit: recurringCubit,
        );

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pump();

        final NavigationBar navBar =
            tester.widget<NavigationBar>(find.byType(NavigationBar));
        expect(navBar.selectedIndex, 0);
      },
    );

    testWidgets(
      'tapping Transações tab switches to index 1',
      (WidgetTester tester) async {
        final GoRouter router = _buildRouter(
          authBloc: mockAuthBloc,
          recurringCubit: recurringCubit,
        );

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pump();

        await tester.tap(find.text('Transações'));
        await tester.pumpAndSettle();

        final NavigationBar navBar =
            tester.widget<NavigationBar>(find.byType(NavigationBar));
        expect(navBar.selectedIndex, 1);
      },
    );

    testWidgets(
      'tapping Metas tab (index 3) switches to last tab',
      (WidgetTester tester) async {
        final GoRouter router = _buildRouter(
          authBloc: mockAuthBloc,
          recurringCubit: recurringCubit,
        );

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pump();

        await tester.tap(find.text('Metas'));
        await tester.pumpAndSettle();

        final NavigationBar navBar =
            tester.widget<NavigationBar>(find.byType(NavigationBar));
        expect(navBar.selectedIndex, 3);
      },
    );
  });
}
