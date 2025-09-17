import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'config/routes/router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => ShadcnApp.router(
    title: 'AFC',
    routerConfig: router,
    theme: ThemeData(colorScheme: ColorSchemes.darkViolet),
  );
}
