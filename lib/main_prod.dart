import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'utils/flavors.dart';
import 'utils/logger.dart';
import 'utils/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Flavor.flavorType = FlavorTypes.prod;

  await startupLogger(Flavor.flavorType);

  await Firebase.initializeApp(options: Flavor.firebaseConfigOptions);

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  runApp(const MyApp());
}
