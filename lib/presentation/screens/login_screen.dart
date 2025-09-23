import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart' hide Colors;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' hide ThemeData, Scaffold;

import '../blocs/cubit/category_cubit.dart';
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
                Scaffold(
                  body: BlocProvider<CategoryCubit>(
                    create: (BuildContext context) => CategoryCubit(),
                    child: const CadastrarCategoria(),
                  ),
                ),
            signedOutBuilder:
                (BuildContext context, ClerkAuthState authState) =>
                    const ClerkAuthentication(),
          ),
        ),
      ),
    ),
  );
}
