import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../utils/screen_utils.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.body,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.padding,
    this.centerTitle,
    super.key,
  });

  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final EdgeInsetsGeometry? padding;
  final bool? centerTitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title == null
          ? null
          : AppBar(
              title: Text(title!),
              actions: actions,
              centerTitle: centerTitle,
            ),
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        child: Padding(
          padding:
              padding ??
              EdgeInsets.symmetric(
                horizontal: ScreenUtils.responsiveHorizontalPadding(context),
                vertical: AppConstants.defaultPadding,
              ),
          child: body,
        ),
      ),
    );
  }
}
