import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../core/utils/screen_utils.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../controller/invoices_controller.dart';
import '../model/invoice.dart';
import '../widgets/invoice_status_chip.dart';

class InvoiceDetailsView extends GetView<InvoicesController> {
  const InvoiceDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final invoiceId = Get.arguments?.toString();

    return Obx(() {
      final invoice = controller.invoices.firstWhereOrNull(
        (item) => item.id == invoiceId,
      );
      return Scaffold(
        appBar: AppBar(
          title: Text('invoice_details'.tr),
          actions: invoice == null
              ? null
              : [
                  IconButton(
                    onPressed: () => controller.openEdit(invoice),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    onPressed: () => controller.exportPdf(invoice),
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                  ),
                ],
        ),
        body: invoice == null
            ? AppEmptyState(title: 'invoice_not_found'.tr)
            : _Details(invoice: invoice),
      );
    });
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ScreenUtils.responsiveHorizontalPadding(context)),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              invoice.invoiceNumber,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                          InvoiceStatusChip(status: invoice.status),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('${'customer'.tr}: ${invoice.customerName}'),
                      Text(
                        '${'date'.tr}: ${DateTimeUtils.formatDate(invoice.date)}',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      for (final item in invoice.items)
                        ListTile(
                          title: Text(item.name),
                          subtitle: Text(
                            '${item.safeQuantity} x ${CurrencyUtils.format(item.safeUnitPrice)}',
                          ),
                          trailing: Text(CurrencyUtils.format(item.total)),
                        ),
                      const Divider(),
                      _TotalLine(label: 'subtotal'.tr, value: invoice.subtotal),
                      _TotalLine(label: 'discount'.tr, value: invoice.discount),
                      _TotalLine(label: 'tax'.tr, value: invoice.tax),
                      _TotalLine(
                        label: 'final_total'.tr,
                        value: invoice.finalTotal,
                        isStrong: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TotalLine extends StatelessWidget {
  const _TotalLine({
    required this.label,
    required this.value,
    this.isStrong = false,
  });

  final String label;
  final double value;
  final bool isStrong;

  @override
  Widget build(BuildContext context) {
    final style = isStrong
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(CurrencyUtils.format(value), style: style),
        ],
      ),
    );
  }
}
