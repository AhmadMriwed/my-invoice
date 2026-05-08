import 'package:flutter/material.dart';

import 'app_card.dart';

class AppTableContainer extends StatefulWidget {
  const AppTableContainer({required this.child, super.key});

  final Widget child;

  @override
  State<AppTableContainer> createState() => _AppTableContainerState();
}

class _AppTableContainerState extends State<AppTableContainer> {
  final _horizontalController = ScrollController();
  final _verticalController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Scrollbar(
            controller: _horizontalController,
            thumbVisibility: true,
            notificationPredicate: (notification) =>
                notification.metrics.axis == Axis.horizontal,
            child: SingleChildScrollView(
              controller: _horizontalController,
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: Scrollbar(
                  controller: _verticalController,
                  thumbVisibility: true,
                  notificationPredicate: (notification) =>
                      notification.metrics.axis == Axis.vertical,
                  child: SingleChildScrollView(
                    controller: _verticalController,
                    child: widget.child,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }
}
