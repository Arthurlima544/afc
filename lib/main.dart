import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'config/routes/router.dart';
import 'utils/logger.dart';

void main() {
  logger.i('App Starting');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => ShadcnApp.router(
    debugShowCheckedModeBanner: false,

    title: 'AFC',
    routerConfig: router,
    theme: ThemeData(colorScheme: ColorSchemes.darkViolet),
  );
}
