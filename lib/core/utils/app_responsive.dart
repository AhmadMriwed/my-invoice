import 'package:flutter/material.dart';

import 'screen_utils.dart';

class AppResponsive extends StatelessWidget {
  const AppResponsive({
    required this.mobile,
    this.tablet,
    this.desktop,
    super.key,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    if (ScreenUtils.isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    }
    if (ScreenUtils.isTablet(context)) {
      return tablet ?? mobile;
    }
    return mobile;
  }
}
