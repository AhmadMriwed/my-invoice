import 'package:flutter/material.dart';

import 'app_card.dart';

class AppTableContainer extends StatelessWidget {
  const AppTableContainer({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(child: child),
        ),
      ),
    );
  }
}
