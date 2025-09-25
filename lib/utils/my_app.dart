import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../config/routes/router.dart';
import '../presentation/blocs/auth/auth_cubit.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider<AuthCubit>(
    create: (BuildContext context) => AuthCubit(),
    child: ShadcnApp.router(
      debugShowCheckedModeBanner: false,
      title: 'AFC',
      routerConfig: router,
      theme: ThemeData(colorScheme: ColorSchemes.darkViolet),
    ),
  );
}
