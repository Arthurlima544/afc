import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart' hide Colors;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entity/category_entity.dart';
import '../../domain/entity/limit_entity.dart';
import '../../domain/entity/transaction_entity.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/category/category_cubit.dart';
import '../../presentation/blocs/home/home_bloc.dart';
import '../../presentation/blocs/limit/limit_cubit.dart';
import '../../presentation/blocs/open_finance/open_finance_cubit.dart';
import '../../presentation/blocs/recurring/recurring_cubit.dart';
import '../../presentation/blocs/review_queue/review_queue_cubit.dart';
import '../../presentation/blocs/transaction/transaction_cubit.dart';
import '../../presentation/screens/cadastrar_categoria.dart';
import '../../presentation/screens/cadastrar_limites.dart';
import '../../presentation/screens/cadastrar_recorrente.dart';
import '../../presentation/screens/cadastrar_transacao.dart';
import '../../presentation/screens/connect_bank_screen.dart';
import '../../presentation/screens/connected_accounts_screen.dart';
import '../../presentation/screens/dev_seed_screen.dart';
import '../../presentation/screens/home_page.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/lista_categorias.dart';
import '../../presentation/screens/lista_limites.dart';
import '../../presentation/screens/lista_recorrentes.dart';
import '../../presentation/screens/lista_transacoes.dart';
import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/review_queue_screen.dart';
import '../../presentation/screens/scaffold_shell.dart';
import '../../utils/logger.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) =>
          const HomeScreen(),
    ),

    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) =>
          const LoginScreen(),
    ),

    GoRoute(
      path: '/cadastro-categoria',
      builder: (BuildContext context, GoRouterState state) =>
          BlocProvider<CategoryCubit>(
            create: (BuildContext context) => CategoryCubit(),
            child: const CadastrarCategoria(),
          ),
    ),

    GoRoute(
      path: '/cadastro-transacao',
      builder: (BuildContext context, GoRouterState state) =>
          BlocProvider<TransactionCubit>(
            create: (BuildContext context) =>
                TransactionCubit()..getCategories(),
            child: const CadastrarTransacao(),
          ),
    ),

    GoRoute(
      path: '/cadastro-limite',
      builder: (BuildContext context, GoRouterState state) =>
          BlocProvider<LimitCubit>(
            create: (BuildContext context) => LimitCubit()..getCategories(),
            child: const CadastrarLimites(),
          ),
    ),

    StatefulShellRoute.indexedStack(
      builder: (
        BuildContext context,
        GoRouterState state,
        StatefulNavigationShell navigationShell,
      ) =>
          BlocProvider<RecurringCubit>(
            create: (_) => RecurringCubit(),
            child: ScaffoldShell(navigationShell: navigationShell),
          ),
      branches: <StatefulShellBranch>[
        // --- Tab 0: Dashboard ---
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/home',
              builder: (BuildContext context, GoRouterState state) {
                final AuthState authState = context.read<AuthBloc>().state;
                final String? uuidOrNull = authState.whenOrNull(
                  signedIn: (ClerkAuthState s) => s.user?.id,
                );
                if (uuidOrNull == null || uuidOrNull.isEmpty) {
                  logger.f('Invalid UUID!!!!!, $uuidOrNull}');
                  return const Center(child: CircularProgressIndicator());
                }
                return MultiBlocProvider(
                  providers: <BlocProvider<dynamic>>[
                    BlocProvider<HomeBloc>(
                      create: (_) =>
                          HomeBloc()..add(HomeEvent.loadHome(uuidOrNull)),
                    ),
                    BlocProvider<LimitCubit>(
                      create: (_) =>
                          LimitCubit()..loadLimitsWithProgress(uuidOrNull),
                    ),
                  ],
                  child: const HomePage(),
                );
              },
            ),
          ],
        ),

        // --- Tab 1: Transactions ---
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/lista-transacoes',
              builder: (BuildContext context, GoRouterState state) {
                final String userId =
                    context.read<AuthBloc>().state.whenOrNull(
                          signedIn: (ClerkAuthState s) => s.user?.id,
                        ) ??
                    '';
                return BlocProvider<TransactionCubit>(
                  create: (_) => TransactionCubit()..loadTransactions(userId),
                  child: const ListaTransacoes(),
                );
              },
            ),
          ],
        ),

        // --- Tab 2: Categories ---
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/lista-categorias',
              builder: (BuildContext context, GoRouterState state) =>
                  BlocProvider<CategoryCubit>(
                    create: (_) => CategoryCubit()..loadCategories(),
                    child: const ListaCategorias(),
                  ),
            ),
          ],
        ),

        // --- Tab 3: Limits ---
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/lista-limites',
              builder: (BuildContext context, GoRouterState state) {
                final String userId =
                    context.read<AuthBloc>().state.whenOrNull(
                          signedIn: (ClerkAuthState s) => s.user?.id,
                        ) ??
                    '';
                return BlocProvider<LimitCubit>(
                  create: (_) => LimitCubit()..loadLimits(userId),
                  child: const ListaLimites(),
                );
              },
            ),
          ],
        ),

        // --- Tab 4: Recorrências ---
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/lista-recorrentes',
              builder: (BuildContext context, GoRouterState state) {
                final String userId =
                    context.read<AuthBloc>().state.whenOrNull(
                          signedIn: (ClerkAuthState s) => s.user?.id,
                        ) ??
                    '';
                return BlocProvider<RecurringCubit>(
                  create: (_) => RecurringCubit()..loadRecurring(userId),
                  child: const ListaRecorrentes(),
                );
              },
            ),
          ],
        ),
      ],
    ),

    // --- Edit screens ---

    GoRoute(
      path: '/editar-transacao',
      builder: (BuildContext context, GoRouterState state) =>
          BlocProvider<TransactionCubit>(
            create: (BuildContext context) =>
                TransactionCubit()..getCategories(),
            child: CadastrarTransacao(
              initialTransaction: state.extra as TransactionEntity?,
            ),
          ),
    ),

    GoRoute(
      path: '/editar-categoria',
      builder: (BuildContext context, GoRouterState state) {
        final CategoryEntity? cat = state.extra as CategoryEntity?;
        return BlocProvider<CategoryCubit>(
          create: (BuildContext context) {
            final CategoryCubit cubit = CategoryCubit();
            if (cat != null) {
              cubit.changeSelectedCategory(cat.iconType);
            }
            return cubit;
          },
          child: CadastrarCategoria(initialCategory: cat),
        );
      },
    ),

    GoRoute(
      path: '/seed',
      builder: (BuildContext context, GoRouterState state) =>
          const DevSeedScreen(),
    ),

    GoRoute(
      path: '/editar-limite',
      builder: (BuildContext context, GoRouterState state) =>
          BlocProvider<LimitCubit>(
            create: (BuildContext context) => LimitCubit()..getCategories(),
            child: CadastrarLimites(
              initialLimit: state.extra as LimitEntity?,
            ),
          ),
    ),

    GoRoute(
      path: '/cadastro-recorrente',
      builder: (BuildContext context, GoRouterState state) =>
          MultiBlocProvider(
            providers: <BlocProvider<dynamic>>[
              BlocProvider<TransactionCubit>(
                create: (_) => TransactionCubit()..getCategories(),
              ),
              BlocProvider<RecurringCubit>(
                create: (_) => RecurringCubit(),
              ),
            ],
            child: const CadastrarRecorrente(),
          ),
    ),

    // --- Open Finance routes ---

    GoRoute(
      path: '/contas-conectadas',
      builder: (BuildContext context, GoRouterState state) {
        final AuthState authState = context.read<AuthBloc>().state;
        final String userId =
            authState.whenOrNull(
              signedIn: (ClerkAuthState s) => s.user?.id,
            ) ??
            '';
        return BlocProvider<OpenFinanceCubit>(
          create: (BuildContext context) =>
              OpenFinanceCubit()..loadAccounts(userId),
          child: const ConnectedAccountsScreen(),
        );
      },
    ),

    GoRoute(
      path: '/connect-bank',
      builder: (BuildContext context, GoRouterState state) =>
          ConnectBankScreen(connectToken: state.extra as String),
    ),

    GoRoute(
      path: '/revisar-transacoes',
      builder: (BuildContext context, GoRouterState state) {
        final AuthState authState = context.read<AuthBloc>().state;
        final String userId =
            authState.whenOrNull(
              signedIn: (ClerkAuthState s) => s.user?.id,
            ) ??
            '';
        return BlocProvider<ReviewQueueCubit>(
          create: (BuildContext context) =>
              ReviewQueueCubit()..loadQueue(userId),
          child: const ReviewQueueScreen(),
        );
      },
    ),
  ],
);
