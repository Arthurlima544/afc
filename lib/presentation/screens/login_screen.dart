import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart' hide Colors;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' hide ThemeData, Scaffold;

import '../blocs/category/category_cubit.dart';
import 'cadastrar_categoria.dart';

class LoginScreen extends StatelessWidget {
  /// Constructs an instance of Example App
  const LoginScreen({required this.publishableKey, super.key});

  /// Publishable Key
  final String publishableKey;

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData.dark(),
    home: ClerkAuth(
      config: ClerkAuthConfig(publishableKey: publishableKey),
      child: SafeArea(
        child: ClerkErrorListener(
          child: ClerkAuthBuilder(
            signedInBuilder: (BuildContext context, ClerkAuthState authState) =>
                const Scaffold(body: AuthenticatedRouterScreen()),
            signedOutBuilder:
                (BuildContext context, ClerkAuthState authState) =>
                    const ClerkAuthentication(),
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
        const Spacer(),
      ],
    ),
  );
}
