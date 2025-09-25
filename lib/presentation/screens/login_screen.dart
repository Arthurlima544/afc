import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart' hide Colors;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' hide ThemeData, Scaffold;

import '../blocs/auth/auth_cubit.dart';

class LoginScreen extends StatelessWidget {
  /// Constructs an instance of Example App
  const LoginScreen({required this.publishableKey, super.key});

  /// Publishable Key
  final String publishableKey;

  @override
  Widget build(BuildContext context) => BlocBuilder<AuthCubit, AuthState>(
    builder: (BuildContext context, AuthState state) => MaterialApp(
      theme: ThemeData.dark(),
      home: ClerkAuth(
        config: ClerkAuthConfig(publishableKey: publishableKey),
        child: SafeArea(
          child: ClerkErrorListener(
            child: ClerkAuthBuilder(
              signedInBuilder:
                  (BuildContext context, ClerkAuthState authState) {
                    context.read<AuthCubit>().signIn(authState);
                    return const Scaffold(body: AuthenticatedRouterScreen());
                  },
              signedOutBuilder:
                  (BuildContext context, ClerkAuthState authState) {
                    context.read<AuthCubit>().signOut();
                    return const ClerkAuthentication();
                  },
            ),
          ),
        ),
      ),
    ),
  );
}

class AuthenticatedRouterScreen extends StatelessWidget {
  const AuthenticatedRouterScreen({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      children: <Widget>[
        const Spacer(),
        OutlineButton(
          onPressed: () {
            GoRouter.of(context).push('/cadastro-categoria');
          },
          child: const Text('Categoria Cadastro Screen'),
        ),
        const Gap(15),
        OutlineButton(
          onPressed: () {
            GoRouter.of(context).push('/cadastro-transacao');
          },
          child: const Text('Transaction Cadastro Screen'),
        ),
        const Gap(15),
        OutlineButton(
          onPressed: () {
            GoRouter.of(context).push('/cadastro-limite');
          },
          child: const Text('Limite Cadastro Screen'),
        ),
        const Gap(15),
        OutlineButton(
          onPressed: () {
            GoRouter.of(context).push('/home');
          },
          child: const Text('Home Screen'),
        ),
        const Spacer(),
      ],
    ),
  );
}
