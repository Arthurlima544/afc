import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'utils/flavors.dart';
import 'utils/logger.dart';
import 'utils/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Flavor.flavorType = FlavorTypes.dev;

  await startupLogger(Flavor.flavorType);

  // Load environment variables
  await dotenv.load();

  await Firebase.initializeApp(options: Flavor.firebaseConfigOptions);

  runApp(const MyApp());
}
