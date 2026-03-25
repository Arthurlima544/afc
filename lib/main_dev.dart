import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'utils/connectivity_service.dart';
import 'utils/flavors.dart';
import 'utils/local_notification_service.dart';
import 'utils/logger.dart';
import 'utils/my_app.dart';
import 'utils/sync_queue.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR');
  Flavor.flavorType = FlavorTypes.dev;

  await startupLogger(Flavor.flavorType);

  await Firebase.initializeApp(options: Flavor.firebaseConfigOptions);

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  LocalNotificationService.register();
  ConnectivityService.register();
  SyncQueue.register();

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  SyncQueue.instance.attachPrefs(prefs);
  await ConnectivityService.instance.initialize();
  await LocalNotificationService.instance.initialize();

  runApp(const MyApp());
}
