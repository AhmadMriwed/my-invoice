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
                    tooltip: 'edit'.tr,
                    onPressed: () => controller.openEdit(invoice),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    tooltip: 'export_pdf'.tr,
                    onPressed: () => controller.exportPdf(invoice),
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                  ),
                  if (ScreenUtils.isMobile(context))
                    _InvoiceDetailsMenu(
                      invoice: invoice,
                      controller: controller,
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

enum _InvoiceDetailsAction { duplicate, delete }

class _InvoiceDetailsMenu extends StatelessWidget {
  const _InvoiceDetailsMenu({required this.invoice, required this.controller});

  final Invoice invoice;
  final InvoicesController controller;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_InvoiceDetailsAction>(
      tooltip: 'actions'.tr,
      icon: const Icon(Icons.more_vert),
      onSelected: (action) {
        switch (action) {
          case _InvoiceDetailsAction.duplicate:
            controller.duplicateInvoice(invoice);
          case _InvoiceDetailsAction.delete:
            controller.deleteInvoice(invoice);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _InvoiceDetailsAction.duplicate,
          child: ListTile(
            leading: const Icon(Icons.copy_outlined),
            title: Text('duplicate'.tr),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          value: _InvoiceDetailsAction.delete,
          child: ListTile(
            leading: const Icon(Icons.delete_outline),
            title: Text('delete'.tr),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
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
                      Text('${'invoice_type'.tr}: ${_documentType(invoice)}'),
                      if (invoice.documentType == InvoiceDocumentType.invoice)
                        Text(
                          '${'payment_method'.tr}: ${_paymentMethod(invoice)}',
                        ),
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
                            '${item.safeQuantity} x ${CurrencyUtils.format(item.safeUnitPrice, symbol: invoice.currencySymbol)}',
                          ),
                          trailing: Text(
                            CurrencyUtils.format(
                              item.total,
                              symbol: invoice.currencySymbol,
                            ),
                          ),
                        ),
                      const Divider(),
                      _TotalLine(
                        label: 'subtotal'.tr,
                        value: invoice.subtotal,
                        symbol: invoice.currencySymbol,
                      ),
                      _TotalLine(
                        label: 'discount'.tr,
                        value: invoice.discount,
                        symbol: invoice.currencySymbol,
                      ),
                      _TotalLine(
                        label: 'tax'.tr,
                        value: invoice.tax,
                        symbol: invoice.currencySymbol,
                      ),
                      _TotalLine(
                        label: 'final_total'.tr,
                        value: invoice.finalTotal,
                        symbol: invoice.currencySymbol,
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
    required this.symbol,
    this.isStrong = false,
  });

  final String label;
  final double value;
  final String symbol;
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
          Text(CurrencyUtils.format(value, symbol: symbol), style: style),
        ],
      ),
    );
  }
}

String _documentType(Invoice invoice) {
  if (invoice.documentType == InvoiceDocumentType.custom) {
    final value = invoice.customDocumentType.trim();
    return value.isEmpty ? 'custom'.tr : value;
  }
  return invoice.documentType.name.tr;
}

String _paymentMethod(Invoice invoice) {
  if (invoice.paymentMethod == InvoicePaymentMethod.custom) {
    final value = invoice.customPaymentMethod.trim();
    return value.isEmpty ? 'custom'.tr : value;
  }
  return invoice.paymentMethod.name.tr;
}
