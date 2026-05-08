import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../model/invoice.dart';

class InvoiceStatusChip extends StatelessWidget {
  const InvoiceStatusChip({required this.status, super.key});

  final InvoiceStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      InvoiceStatus.paid => AppColors.success,
      InvoiceStatus.overdue => AppColors.warning,
      InvoiceStatus.cancelled => AppColors.error,
      InvoiceStatus.draft => AppColors.silver,
      InvoiceStatus.saved => Theme.of(context).colorScheme.primary,
    };
    final labelColor = status == InvoiceStatus.draft
        ? Theme.of(context).colorScheme.onSurfaceVariant
        : color;

    return Chip(
      label: Text(status.name.tr),
      side: BorderSide(color: color.withValues(alpha: 0.35)),
      backgroundColor: color.withValues(alpha: 0.1),
      labelStyle: TextStyle(color: labelColor),
    );
  }
}
