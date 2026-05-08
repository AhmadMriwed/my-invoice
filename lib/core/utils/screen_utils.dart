import 'package:flutter/material.dart';

class ScreenUtils {
  const ScreenUtils._();

  static double width(BuildContext context) => MediaQuery.sizeOf(context).width;

  static double height(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  static bool isMobile(BuildContext context) => width(context) < 600;

  static bool isTablet(BuildContext context) {
    final screenWidth = width(context);
    return screenWidth >= 600 && screenWidth < 1024;
  }

  static bool isDesktop(BuildContext context) => width(context) >= 1024;

  static double responsiveHorizontalPadding(BuildContext context) {
    if (isDesktop(context)) {
      return 32;
    }
    if (isTablet(context)) {
      return 24;
    }
    return 16;
  }
}
