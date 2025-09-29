import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'flavors.dart';

final Logger logger = Logger(
  printer: kReleaseMode
      ? PrettyPrinter()
      : PrettyPrinter(
          methodCount: 0,
          errorMethodCount: 5,
          lineLength: 80,
          colors: false,
          dateTimeFormat: (DateTime date) => date.toString(),
        ),
  level: kReleaseMode ? Level.off : Level.trace,
);

Future<void> startupLogger(FlavorTypes flavor) async {
  final PackageInfo packageInfo = await PackageInfo.fromPlatform();
  final String appVersion = packageInfo.version;
  final String buildNumber = packageInfo.buildNumber;

  // Get Device Info (OS version)
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  final int deviceSdkInt = androidInfo.version.sdkInt;
  final String deviceVersion = androidInfo.version.release;
  final String deviceModel = androidInfo.model;

  logger.i(
    '''App Starting in ${flavor == FlavorTypes.prod ? 'Production' : 'Development'}:\n
       App Version: $appVersion
       Build Number (Version Code): $buildNumber
       Device Model: $deviceModel
       Device OS Version: Android $deviceVersion (API Level: $deviceSdkInt)
    ''',
  );
}

// !Stats for users on different Android versions
// Android 13 (API 33): 45% of your users
// Android 12 (API 31): 30% of your users
// Android 11 (API 30): 15% of your users
// Android 10 (API 29): 7% of your users
// Android 9 (API 28): 2.5% of your users
// Android 8 (API 26): 0.5% of your users
