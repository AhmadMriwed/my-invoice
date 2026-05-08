import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../core/utils/screen_utils.dart';
import '../../../core/widgets/app_action_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_navigation_scaffold.dart';
import '../../../core/widgets/app_table_container.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controller/invoices_controller.dart';
import '../model/invoice.dart';
import '../widgets/invoice_status_chip.dart';

class InvoiceListView extends GetView<InvoicesController> {
  const InvoiceListView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppNavigationScaffold(
      currentRoute: AppRoutes.invoices,
      title: 'invoices'.tr,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.openCreate,
        icon: const Icon(Icons.add),
        label: Text('invoice'.tr),
      ),
      body: Padding(
        padding: EdgeInsets.all(
          ScreenUtils.responsiveHorizontalPadding(context),
        ),
        child: Column(
          children: [
            _InvoiceFilters(controller: controller),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                final invoices = controller.filteredInvoices;
                if (invoices.isEmpty) {
                  return AppEmptyState(
                    title: 'no_invoices_yet'.tr,
                    message: 'create_invoice_message'.tr,
                    icon: Icons.receipt_long_outlined,
                    action: AppActionButton(
                      icon: Icons.add,
                      label: 'create_invoice'.tr,
                      onPressed: controller.openCreate,
                      isPrimary: true,
                    ),
                  );
                }
                if (ScreenUtils.isDesktop(context)) {
                  return _InvoicesTable(
                    invoices: invoices,
                    controller: controller,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 96),
                  itemCount: invoices.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, index) => _InvoiceCard(
                    invoice: invoices[index],
                    controller: controller,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _InvoiceFilters extends StatelessWidget {
  const _InvoiceFilters({required this.controller});

  final InvoicesController controller;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        SizedBox(
          width: ScreenUtils.isDesktop(context) ? 320 : double.infinity,
          child: AppTextField(
            label: 'search_invoice_customer'.tr,
            prefixIcon: const Icon(Icons.search),
            onChanged: (value) => controller.query.value = value,
          ),
        ),
        SizedBox(
          width: 180,
          child: Obx(
            () => DropdownButtonFormField<String>(
              initialValue: controller.statusFilter.value,
              decoration: InputDecoration(labelText: 'status'.tr),
              items:
                  const [
                        'all',
                        'draft',
                        'saved',
                        'paid',
                        'overdue',
                        'cancelled',
                      ]
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.tr),
                        ),
                      )
                      .toList(),
              onChanged: (value) =>
                  controller.statusFilter.value = value ?? 'all',
            ),
          ),
        ),
        SizedBox(
          width: 160,
          child: AppTextField(
            label: 'min_price'.tr,
            keyboardType: TextInputType.number,
            onChanged: (value) =>
                controller.minPrice.value = double.tryParse(value),
          ),
        ),
        SizedBox(
          width: 160,
          child: AppTextField(
            label: 'max_price'.tr,
            keyboardType: TextInputType.number,
            onChanged: (value) =>
                controller.maxPrice.value = double.tryParse(value),
          ),
        ),
      ],
    );
  }
}

class _InvoicesTable extends StatelessWidget {
  const _InvoicesTable({required this.invoices, required this.controller});

  final List<Invoice> invoices;
  final InvoicesController controller;

  @override
  Widget build(BuildContext context) {
    return AppTableContainer(
      child: DataTable(
        columns: [
          DataColumn(label: Text('number'.tr)),
          DataColumn(label: Text('customer'.tr)),
          DataColumn(label: Text('date'.tr)),
          DataColumn(label: Text('total'.tr)),
          DataColumn(label: Text('status'.tr)),
          DataColumn(label: Text('actions'.tr)),
        ],
        rows: invoices.map((invoice) {
          return DataRow(
            cells: [
              DataCell(Text(invoice.invoiceNumber)),
              DataCell(Text(invoice.customerName)),
              DataCell(Text(DateTimeUtils.formatDate(invoice.date))),
              DataCell(Text(CurrencyUtils.format(invoice.finalTotal))),
              DataCell(InvoiceStatusChip(status: invoice.status)),
              DataCell(
                _InvoiceActions(invoice: invoice, controller: controller),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  const _InvoiceCard({required this.invoice, required this.controller});

  final Invoice invoice;
  final InvoicesController controller;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      hoverable: true,
      padding: EdgeInsets.zero,
      child: ListTile(
        onTap: () => controller.openDetails(invoice),
        title: Text(invoice.invoiceNumber),
        subtitle: Text(
          '${invoice.customerName}\n${DateTimeUtils.formatDate(invoice.date)}',
        ),
        isThreeLine: true,
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(CurrencyUtils.format(invoice.finalTotal)),
            InvoiceStatusChip(status: invoice.status),
          ],
        ),
      ),
    );
  }
}

class _InvoiceActions extends StatelessWidget {
  const _InvoiceActions({required this.invoice, required this.controller});

  final Invoice invoice;
  final InvoicesController controller;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      children: [
        IconButton(
          tooltip: 'view'.tr,
          onPressed: () => controller.openDetails(invoice),
          icon: const Icon(Icons.visibility_outlined),
        ),
        IconButton(
          tooltip: 'edit'.tr,
          onPressed: () => controller.openEdit(invoice),
          icon: const Icon(Icons.edit_outlined),
        ),
        IconButton(
          tooltip: 'duplicate'.tr,
          onPressed: () => controller.duplicateInvoice(invoice),
          icon: const Icon(Icons.copy_outlined),
        ),
        IconButton(
          tooltip: 'export_pdf'.tr,
          onPressed: () => controller.exportPdf(invoice),
          icon: const Icon(Icons.picture_as_pdf_outlined),
        ),
        IconButton(
          tooltip: 'delete'.tr,
          onPressed: () => controller.deleteInvoice(invoice),
          icon: const Icon(Icons.delete_outline),
        ),
      ],
    );
  }
}
