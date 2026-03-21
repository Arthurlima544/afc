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
import '../../presentation/blocs/transaction/transaction_cubit.dart';
import '../../presentation/screens/cadastrar_categoria.dart';
import '../../presentation/screens/cadastrar_limites.dart';
import '../../presentation/screens/cadastrar_transacao.dart';
import '../../presentation/screens/dev_seed_screen.dart';
import '../../presentation/screens/home_page.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/lista_categorias.dart';
import '../../presentation/screens/lista_limites.dart';
import '../../presentation/screens/lista_transacoes.dart';
import '../../presentation/screens/login_screen.dart';
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

    GoRoute(
      path: '/home',
      builder: (BuildContext context, GoRouterState state) {
        final AuthState authState = context.read<AuthBloc>().state;

        final String? uuidOrNull = authState.whenOrNull(
          signedIn: (ClerkAuthState authState) => authState.user?.id,
        );

        if (uuidOrNull == null || uuidOrNull.isEmpty) {
          logger.f('Invalid UUID!!!!!, $uuidOrNull}');
          return const Center(child: CircularProgressIndicator());
        }

        return MultiBlocProvider(
          providers: <BlocProvider<dynamic>>[
            BlocProvider<HomeBloc>(
              create: (BuildContext context) =>
                  HomeBloc()..add(HomeEvent.loadHome(uuidOrNull)),
            ),
            BlocProvider<LimitCubit>(
              create: (BuildContext context) =>
                  LimitCubit()..loadLimitsWithProgress(uuidOrNull),
            ),
          ],
          child: const HomePage(),
        );
      },
    ),

    // --- List screens ---

    GoRoute(
      path: '/lista-transacoes',
      builder: (BuildContext context, GoRouterState state) {
        final AuthState authState = context.read<AuthBloc>().state;
        final String userId = authState.whenOrNull(
              signedIn: (ClerkAuthState s) => s.user?.id,
            ) ??
            '';
        return BlocProvider<TransactionCubit>(
          create: (BuildContext context) =>
              TransactionCubit()..loadTransactions(userId),
          child: const ListaTransacoes(),
        );
      },
    ),

    GoRoute(
      path: '/lista-categorias',
      builder: (BuildContext context, GoRouterState state) =>
          BlocProvider<CategoryCubit>(
            create: (BuildContext context) => CategoryCubit()..loadCategories(),
            child: const ListaCategorias(),
          ),
    ),

    GoRoute(
      path: '/lista-limites',
      builder: (BuildContext context, GoRouterState state) {
        final AuthState authState = context.read<AuthBloc>().state;
        final String userId = authState.whenOrNull(
              signedIn: (ClerkAuthState s) => s.user?.id,
            ) ??
            '';
        return BlocProvider<LimitCubit>(
          create: (BuildContext context) =>
              LimitCubit()..loadLimits(userId),
          child: const ListaLimites(),
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
  ],
);
