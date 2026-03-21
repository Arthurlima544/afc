import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../config/routes/router.dart';
import '../presentation/blocs/auth/auth_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider<AuthBloc>(
    create: (BuildContext context) => AuthBloc(),
    child: ShadcnApp.router(
      debugShowCheckedModeBanner: false,
      title: 'AFC',
      routerConfig: router,
      theme: ThemeData(colorScheme: LegacyColorSchemes.darkViolet()),
    ),
  );
}
