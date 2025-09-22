import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' hide ThemeData;

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
                const ClerkUserButton(),
            signedOutBuilder:
                (BuildContext context, ClerkAuthState authState) =>
                    const ClerkAuthentication(),
          ),
        ),
      ),
    ),
  );
}
