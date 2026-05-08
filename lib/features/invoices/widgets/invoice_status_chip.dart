import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../model/invoice.dart';

class InvoiceStatusChip extends StatelessWidget {
  const InvoiceStatusChip({required this.status, super.key});

  final InvoiceStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      InvoiceStatus.paid => Colors.green,
      InvoiceStatus.overdue => Colors.orange,
      InvoiceStatus.cancelled => Colors.red,
      InvoiceStatus.draft => Colors.blueGrey,
      InvoiceStatus.saved => Theme.of(context).colorScheme.primary,
    };

    return Chip(
      label: Text(status.name.tr),
      side: BorderSide(color: color.withValues(alpha: 0.35)),
      backgroundColor: color.withValues(alpha: 0.1),
      labelStyle: TextStyle(color: color),
    );
  }
}
