import 'package:flutter/widgets.dart';

export '../config/theme/app_colors.dart';
export '../config/theme/app_icons.dart';

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
}

abstract final class AppTextStyle {
  static const double sizeXs = 12;
  static const double sizeSm = 13;
  static const double sizeMd = 14;
  static const double sizeLg = 16;
  static const double sizeXl = 18;
  static const double sizeXxl = 20;
  static const double sizeDisplay = 36;
}

/// Named text styles derived from [AppTextStyle] size constants.
abstract final class AppTextStyles {
  static const TextStyle display = TextStyle(
    fontSize: AppTextStyle.sizeDisplay,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle heading = TextStyle(
    fontSize: AppTextStyle.sizeXxl,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: AppTextStyle.sizeXl,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle title = TextStyle(
    fontSize: AppTextStyle.sizeLg,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle bodyBold = TextStyle(
    fontSize: AppTextStyle.sizeMd,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle body = TextStyle(fontSize: AppTextStyle.sizeMd);

  static const TextStyle labelBold = TextStyle(
    fontSize: AppTextStyle.sizeSm,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle label = TextStyle(fontSize: AppTextStyle.sizeSm);

  static const TextStyle captionBold = TextStyle(
    fontSize: AppTextStyle.sizeXs,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle caption = TextStyle(fontSize: AppTextStyle.sizeXs);

  static const TextStyle chartLabelBold = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle chartLabel = TextStyle(fontSize: 10);
}
