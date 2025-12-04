import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyles {
  // Light Theme Text Styles
  static const TextStyle h1Light = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
    fontFamily: 'Poppins',
  );

  static const TextStyle h2Light = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
    fontFamily: 'Poppins',
  );

  static const TextStyle h3Light = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    fontFamily: 'Poppins',
  );

  static const TextStyle h4Light = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    fontFamily: 'Poppins',
  );

  static const TextStyle bodyLargeLight = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.grey700,
    fontFamily: 'Poppins',
  );

  static const TextStyle bodyMediumLight = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.grey700,
    fontFamily: 'Poppins',
  );

  static const TextStyle bodySmallLight = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.grey600,
    fontFamily: 'Poppins',
  );

  // Dark Theme Text Styles
  static const TextStyle h1Dark = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.onBackgroundDark,
    fontFamily: 'Poppins',
  );

  static const TextStyle h2Dark = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.onBackgroundDark,
    fontFamily: 'Poppins',
  );

  static const TextStyle h3Dark = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.onBackgroundDark,
    fontFamily: 'Poppins',
  );

  static const TextStyle h4Dark = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.onBackgroundDark,
    fontFamily: 'Poppins',
  );

  static const TextStyle bodyLargeDark = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.greyDark700,
    fontFamily: 'Poppins',
  );

  static const TextStyle bodyMediumDark = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.greyDark700,
    fontFamily: 'Poppins',
  );

  static const TextStyle bodySmallDark = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.greyDark600,
    fontFamily: 'Poppins',
  );

  // Button Text (Theme Independent)
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
  );

  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
  );

  // Helper Methods for Dynamic Theme Text
  static TextStyle getH1(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? h1Light : h1Dark;
  }

  static TextStyle getH2(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? h2Light : h2Dark;
  }

  static TextStyle getH3(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? h3Light : h3Dark;
  }

  static TextStyle getH4(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? h4Light : h4Dark;
  }

  static TextStyle getBodyLarge(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? bodyLargeLight
        : bodyLargeDark;
  }

  static TextStyle getBodyMedium(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? bodyMediumLight
        : bodyMediumDark;
  }

  static TextStyle getBodySmall(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? bodySmallLight
        : bodySmallDark;
  }
}
