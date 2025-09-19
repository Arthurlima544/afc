import 'package:firebase_core/firebase_core.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'utils/flavors.dart';
import 'utils/logger.dart';
import 'utils/my_app.dart';

void main() async {
  logger.i('App Starting');

  Flavor.flavorType = FlavorTypes.prod;
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: Flavor.firebaseConfigOptions);

  runApp(const MyApp());
}
