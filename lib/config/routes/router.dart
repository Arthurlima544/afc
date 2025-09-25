import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/blocs/auth/auth_cubit.dart';
import '../../presentation/blocs/category/category_cubit.dart';
import '../../presentation/blocs/limit/limit_cubit.dart';
import '../../presentation/blocs/transaction/transaction_cubit.dart';
import '../../presentation/screens/cadastrar_categoria.dart';
import '../../presentation/screens/cadastrar_limites.dart';
import '../../presentation/screens/cadastrar_transacao.dart';
import '../../presentation/screens/home_page.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/login_screen.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) =>
          const HomeScreen(),
    ),

    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) => const LoginScreen(
        publishableKey:
            'pk_test_Y3VycmVudC1waWdsZXQtMTYuY2xlcmsuYWNjb3VudHMuZGV2JA',
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
      builder: (BuildContext context, GoRouterState state) => const HomePage(),
    ),
  ],
);
