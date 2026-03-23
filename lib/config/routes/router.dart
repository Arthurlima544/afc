import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart' hide Colors;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entity/bill_entity.dart';
import '../../domain/entity/category_entity.dart';
import '../../domain/entity/goal_entity.dart';
import '../../domain/entity/investment_entity.dart';
import '../../domain/entity/limit_entity.dart';
import '../../domain/entity/transaction_entity.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/bill/bill_cubit.dart';
import '../../presentation/blocs/category/category_cubit.dart';
import '../../presentation/blocs/goal/goal_cubit.dart';
import '../../presentation/blocs/health_score/health_score_cubit.dart';
import '../../presentation/blocs/home/home_bloc.dart';
import '../../presentation/blocs/import/import_cubit.dart';
import '../../presentation/blocs/investment/investment_cubit.dart';
import '../../presentation/blocs/limit/limit_cubit.dart';
import '../../presentation/blocs/market/market_opportunity_cubit.dart';
import '../../presentation/blocs/net_worth/net_worth_cubit.dart';
import '../../presentation/blocs/open_finance/open_finance_cubit.dart';
import '../../presentation/blocs/passive_income/passive_income_cubit.dart';
import '../../presentation/blocs/recurring/recurring_cubit.dart';
import '../../presentation/blocs/report/report_cubit.dart';
import '../../presentation/blocs/review_queue/review_queue_cubit.dart';
import '../../presentation/blocs/settings/settings_cubit.dart';
import '../../presentation/blocs/transaction/transaction_cubit.dart';
import '../../presentation/blocs/watchlist/watchlist_cubit.dart';
import '../../presentation/screens/cadastrar_categoria.dart';
import '../../presentation/screens/cadastrar_conta.dart';
import '../../presentation/screens/cadastrar_investimento.dart';
import '../../presentation/screens/cadastrar_limites.dart';
import '../../presentation/screens/cadastrar_meta.dart';
import '../../presentation/screens/cadastrar_recorrente.dart';
import '../../presentation/screens/cadastrar_transacao.dart';
import '../../presentation/screens/compound_interest_screen.dart';
import '../../presentation/screens/connect_bank_screen.dart';
import '../../presentation/screens/connected_accounts_screen.dart';
import '../../presentation/screens/dev_seed_screen.dart';
import '../../presentation/screens/fire_calculator_screen.dart';
import '../../presentation/screens/home_page.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/importar_extrato.dart';
import '../../presentation/screens/investment_goal_screen.dart';
import '../../presentation/screens/lista_categorias.dart';
import '../../presentation/screens/lista_contas.dart';
import '../../presentation/screens/lista_investimentos.dart';
import '../../presentation/screens/lista_limites.dart';
import '../../presentation/screens/lista_metas.dart';
import '../../presentation/screens/lista_recorrentes.dart';
import '../../presentation/screens/lista_transacoes.dart';
import '../../presentation/screens/lista_watchlist.dart';
import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/net_worth_screen.dart';
import '../../presentation/screens/onboarding_screen.dart';
import '../../presentation/screens/oportunidades_screen.dart';
import '../../presentation/screens/passive_income_screen.dart';
import '../../presentation/screens/portfolio_dashboard_screen.dart';
import '../../presentation/screens/relatorio.dart';
import '../../presentation/screens/review_queue_screen.dart';
import '../../presentation/screens/scaffold_shell.dart';
import '../../presentation/screens/settings_screen.dart';
import '../../utils/logger.dart';
import 'transitions.dart';

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
      path: '/onboarding',
      pageBuilder: (BuildContext context, GoRouterState state) =>
          fadeScaleTransition(
            context: context,
            state: state,
            child: const OnboardingScreen(),
          ),
    ),

    GoRoute(
      path: '/settings',
      pageBuilder: (BuildContext context, GoRouterState state) =>
          slideUpTransition(
            context: context,
            state: state,
            child: BlocProvider<SettingsCubit>(
              create: (_) => SettingsCubit(),
              child: const SettingsScreen(),
            ),
          ),
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
      pageBuilder: (BuildContext context, GoRouterState state) =>
          slideUpTransition(
            context: context,
            state: state,
            child: BlocProvider<TransactionCubit>(
              create: (BuildContext context) =>
                  TransactionCubit()..getCategories(),
              child: const CadastrarTransacao(),
            ),
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
                    BlocProvider<HealthScoreCubit>(
                      create: (_) =>
                          HealthScoreCubit()..loadScore(uuidOrNull),
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

        // --- Tab 2: Limits ---
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

        // --- Tab 3: Metas ---
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/lista-metas',
              builder: (BuildContext context, GoRouterState state) {
                final String userId =
                    context.read<AuthBloc>().state.whenOrNull(
                          signedIn: (ClerkAuthState s) => s.user?.id,
                        ) ??
                    '';
                return BlocProvider<GoalCubit>(
                  create: (_) => GoalCubit()..loadGoals(userId),
                  child: const ListaMetas(),
                );
              },
            ),
          ],
        ),
      ],
    ),

    GoRoute(
      path: '/lista-categorias',
      builder: (BuildContext context, GoRouterState state) =>
          BlocProvider<CategoryCubit>(
            create: (_) => CategoryCubit()..loadCategories(),
            child: const ListaCategorias(),
          ),
    ),

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
      path: '/lista-categorias',
      builder: (BuildContext context, GoRouterState state) =>
          BlocProvider<CategoryCubit>(
            create: (_) => CategoryCubit()..loadCategories(),
            child: const ListaCategorias(),
          ),
    ),

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
      path: '/cadastro-meta',
      builder: (BuildContext context, GoRouterState state) =>
          BlocProvider<GoalCubit>(
            create: (_) => GoalCubit(),
            child: const CadastrarMeta(),
          ),
    ),

    GoRoute(
      path: '/editar-meta',
      builder: (BuildContext context, GoRouterState state) =>
          BlocProvider<GoalCubit>(
            create: (_) => GoalCubit(),
            child: CadastrarMeta(initialGoal: state.extra as GoalEntity?),
          ),
    ),

    GoRoute(
      path: '/importar-extrato',
      builder: (BuildContext context, GoRouterState state) {
        final String userId =
            context.read<AuthBloc>().state.whenOrNull(
                  signedIn: (ClerkAuthState s) => s.user?.id,
                ) ??
            '';
        return BlocProvider<ImportCubit>(
          create: (_) => ImportCubit(),
          child: ImportarExtrato(userId: userId),
        );
      },
    ),

    GoRoute(
      path: '/relatorio',
      builder: (BuildContext context, GoRouterState state) {
        final String userId =
            context.read<AuthBloc>().state.whenOrNull(
                  signedIn: (ClerkAuthState s) => s.user?.id,
                ) ??
            '';
        return BlocProvider<ReportCubit>(
          create: (_) => ReportCubit(),
          child: Relatorio(userId: userId),
        );
      },
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

    // --- Investment routes ---

    GoRoute(
      path: '/lista-investimentos',
      builder: (BuildContext context, GoRouterState state) {
        final String userId =
            context.read<AuthBloc>().state.whenOrNull(
                  signedIn: (ClerkAuthState s) => s.user?.id,
                ) ??
            '';
        return BlocProvider<InvestmentCubit>(
          create: (_) => InvestmentCubit()..loadInvestments(userId),
          child: const ListaInvestimentos(),
        );
      },
    ),

    GoRoute(
      path: '/cadastro-investimento',
      builder: (BuildContext context, GoRouterState state) =>
          BlocProvider<InvestmentCubit>(
            create: (_) => InvestmentCubit(),
            child: const CadastrarInvestimento(),
          ),
    ),

    GoRoute(
      path: '/editar-investimento',
      builder: (BuildContext context, GoRouterState state) =>
          BlocProvider<InvestmentCubit>(
            create: (_) => InvestmentCubit(),
            child: CadastrarInvestimento(
              initialInvestment: state.extra as InvestmentEntity?,
            ),
          ),
    ),

    // --- Financial Independence calculators ---

    GoRoute(
      path: '/fire-calculadora',
      builder: (BuildContext context, GoRouterState state) =>
          const FireCalculatorScreen(),
    ),

    GoRoute(
      path: '/juros-compostos',
      builder: (BuildContext context, GoRouterState state) =>
          const CompoundInterestScreen(),
    ),

    GoRoute(
      path: '/portfolio-dashboard',
      builder: (BuildContext context, GoRouterState state) =>
          BlocProvider<InvestmentCubit>(
            create: (_) => InvestmentCubit(),
            child: const PortfolioDashboardScreen(),
          ),
    ),

    GoRoute(
      path: '/renda-passiva',
      builder: (BuildContext context, GoRouterState state) {
        final String userId =
            context.read<AuthBloc>().state.whenOrNull(
                  signedIn: (ClerkAuthState s) => s.user?.id,
                ) ??
            '';
        return BlocProvider<PassiveIncomeCubit>(
          create: (_) => PassiveIncomeCubit()..loadStreams(userId),
          child: PassiveIncomeScreen(userId: userId),
        );
      },
    ),

    GoRoute(
      path: '/meta-investimento',
      builder: (BuildContext context, GoRouterState state) =>
          const InvestmentGoalScreen(),
    ),

    GoRoute(
      path: '/patrimonio',
      builder: (BuildContext context, GoRouterState state) {
        final String userId =
            context.read<AuthBloc>().state.whenOrNull(
                  signedIn: (ClerkAuthState s) => s.user?.id,
                ) ??
            '';
        return BlocProvider<NetWorthCubit>(
          create: (_) => NetWorthCubit()..loadSnapshots(userId),
          child: NetWorthScreen(userId: userId),
        );
      },
    ),

    // --- Market opportunities & watchlist ---

    GoRoute(
      path: '/oportunidades',
      builder: (BuildContext context, GoRouterState state) {
        final String userId =
            context.read<AuthBloc>().state.whenOrNull(
                  signedIn: (ClerkAuthState s) => s.user?.id,
                ) ??
            '';
        return MultiBlocProvider(
          providers: <BlocProvider<dynamic>>[
            BlocProvider<MarketOpportunityCubit>(
              create: (_) => MarketOpportunityCubit()..load(),
            ),
            BlocProvider<WatchlistCubit>(
              create: (_) => WatchlistCubit()..loadWatchlist(userId),
            ),
          ],
          child: OportunidadesScreen(userId: userId),
        );
      },
    ),

    GoRoute(
      path: '/watchlist',
      builder: (BuildContext context, GoRouterState state) {
        final String userId =
            context.read<AuthBloc>().state.whenOrNull(
                  signedIn: (ClerkAuthState s) => s.user?.id,
                ) ??
            '';
        return BlocProvider<WatchlistCubit>(
          create: (_) => WatchlistCubit()..loadWatchlist(userId),
          child: ListaWatchlist(userId: userId),
        );
      },
    ),

    // --- Bill routes ---

    GoRoute(
      path: '/lista-contas',
      builder: (BuildContext context, GoRouterState state) {
        final String userId =
            context.read<AuthBloc>().state.whenOrNull(
                  signedIn: (ClerkAuthState s) => s.user?.id,
                ) ??
            '';
        return BlocProvider<BillCubit>(
          create: (_) => BillCubit()..loadBills(userId),
          child: const ListaContas(),
        );
      },
    ),

    GoRoute(
      path: '/cadastro-conta',
      builder: (BuildContext context, GoRouterState state) =>
          MultiBlocProvider(
            providers: <BlocProvider<dynamic>>[
              BlocProvider<BillCubit>(
                create: (_) => BillCubit(),
              ),
              BlocProvider<CategoryCubit>(
                create: (_) => CategoryCubit()..loadCategories(),
              ),
            ],
            child: const CadastrarConta(),
          ),
    ),

    GoRoute(
      path: '/editar-conta',
      builder: (BuildContext context, GoRouterState state) =>
          MultiBlocProvider(
            providers: <BlocProvider<dynamic>>[
              BlocProvider<BillCubit>(
                create: (_) => BillCubit(),
              ),
              BlocProvider<CategoryCubit>(
                create: (_) => CategoryCubit()..loadCategories(),
              ),
            ],
            child: CadastrarConta(
              initialBill: state.extra as BillEntity?,
            ),
          ),
    ),
  ],
);
