import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

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
