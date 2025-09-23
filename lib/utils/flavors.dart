import 'package:firebase_core/firebase_core.dart';

import '../firebase_options_dev.dart' as dev;
import '../firebase_options_prod.dart' as prod;

enum FlavorTypes { dev, prod }

class Flavor {
  Flavor._instance();

  static late FlavorTypes flavorType;

  static String get flavorMessage {
    switch (flavorType) {
      case FlavorTypes.dev:
        return 'Dev';
      case FlavorTypes.prod:
        return 'Production';
    }
  }

  static String get apiBaseUrl {
    switch (flavorType) {
      case FlavorTypes.dev:
        return 'apiUrlBaseDev';
      case FlavorTypes.prod:
        return 'apiUrlBaseProd';
    }
  }

  static bool isProduction() => flavorType == FlavorTypes.prod;
  static bool isDevelopment() => flavorType == FlavorTypes.dev;

  static FirebaseOptions? get firebaseConfigOptions {
    switch (flavorType) {
      case FlavorTypes.dev:
        return dev.DefaultFirebaseOptions.currentPlatform;
      case FlavorTypes.prod:
        return prod.DefaultFirebaseOptions.currentPlatform;
    }
  }
}
