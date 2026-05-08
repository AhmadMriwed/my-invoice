import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../core/utils/app_input_formatters.dart';
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
    final isMobile = ScreenUtils.isMobile(context);
    return AppNavigationScaffold(
      currentRoute: AppRoutes.invoices,
      title: 'invoices'.tr,
      floatingActionButton: isMobile
          ? FloatingActionButton.small(
              onPressed: controller.openCreate,
              tooltip: 'create_invoice'.tr,
              child: const Icon(Icons.add),
            )
          : FloatingActionButton.extended(
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
    if (ScreenUtils.isMobile(context)) {
      return _MobileInvoiceFilters(controller: controller);
    }

    return SizedBox(
      width: double.infinity,
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 1180
                ? 4
                : constraints.maxWidth >= 820
                ? 3
                : 1;
            return GridView.count(
              crossAxisCount: columns,
              childAspectRatio: columns == 1 ? 6.2 : 4.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                AppTextField(
                  controller: controller.queryController,
                  label: 'search_invoice_customer'.tr,
                  prefixIcon: const Icon(Icons.search),
                  onChanged: (value) => controller.query.value = value,
                ),
                Obx(() {
                  final customers = controller.customerOptions;
                  final selected =
                      customers.contains(controller.customerFilter.value)
                      ? controller.customerFilter.value
                      : 'all';
                  return DropdownButtonFormField<String>(
                    initialValue: selected,
                    decoration: InputDecoration(
                      labelText: 'customer_filter'.tr,
                      prefixIcon: const Icon(Icons.person_search_outlined),
                    ),
                    items: [
                      DropdownMenuItem(value: 'all', child: Text('all'.tr)),
                      for (final customer in customers)
                        DropdownMenuItem(
                          value: customer,
                          child: Text(customer),
                        ),
                    ],
                    onChanged: (value) {
                      controller.customerFilter.value = value == 'all'
                          ? ''
                          : value ?? '';
                    },
                  );
                }),
                Obx(
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
                AppTextField(
                  controller: controller.minPriceController,
                  label: 'min_price'.tr,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: AppInputFormatters.decimal,
                  onChanged: (value) =>
                      controller.minPrice.value = double.tryParse(value),
                ),
                AppTextField(
                  controller: controller.maxPriceController,
                  label: 'max_price'.tr,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: AppInputFormatters.decimal,
                  onChanged: (value) =>
                      controller.maxPrice.value = double.tryParse(value),
                ),
                Obx(
                  () => _DateFilterField(
                    label: 'date_from'.tr,
                    value: controller.dateFrom.value,
                    onTap: () => _pickDate(
                      context,
                      initialDate: controller.dateFrom.value,
                      onPicked: controller.setDateFrom,
                    ),
                    onClear: controller.dateFrom.value == null
                        ? null
                        : () => controller.setDateFrom(null),
                  ),
                ),
                Obx(
                  () => _DateFilterField(
                    label: 'date_to'.tr,
                    value: controller.dateTo.value,
                    onTap: () => _pickDate(
                      context,
                      initialDate: controller.dateTo.value,
                      onPicked: controller.setDateTo,
                    ),
                    onClear: controller.dateTo.value == null
                        ? null
                        : () => controller.setDateTo(null),
                  ),
                ),
                AppActionButton(
                  icon: Icons.filter_alt_off_outlined,
                  label: 'reset_filters'.tr,
                  onPressed: controller.resetFilters,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _pickDate(
    BuildContext context, {
    required DateTime? initialDate,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 20),
    );
    if (picked != null) {
      onPicked(picked);
    }
  }
}

class _MobileInvoiceFilters extends StatelessWidget {
  const _MobileInvoiceFilters({required this.controller});

  final InvoicesController controller;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: controller.queryController,
                  label: 'search_invoice_customer'.tr,
                  prefixIcon: const Icon(Icons.search),
                  onChanged: (value) => controller.query.value = value,
                ),
              ),
              const SizedBox(width: 8),
              Obx(() {
                final count = _activeFilterCount(controller);
                return SizedBox.square(
                  dimension: 44,
                  child: Badge.count(
                    count: count,
                    isLabelVisible: count > 0,
                    child: IconButton.filledTonal(
                      tooltip: 'filters'.tr,
                      onPressed: () => _showFilterDialog(context),
                      icon: const Icon(Icons.tune, size: 20),
                    ),
                  ),
                );
              }),
            ],
          ),
          Obx(() {
            final chips = _activeFilterChips(controller);
            if (chips.isEmpty) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Wrap(spacing: 6, runSpacing: 6, children: chips),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: 'reset_filters'.tr,
                    onPressed: controller.resetAdvancedFilters,
                    icon: const Icon(Icons.filter_alt_off_outlined, size: 20),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _showFilterDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('filters'.tr),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(() {
                    final customers = controller.customerOptions;
                    final selected =
                        customers.contains(controller.customerFilter.value)
                        ? controller.customerFilter.value
                        : 'all';
                    return DropdownButtonFormField<String>(
                      initialValue: selected,
                      decoration: InputDecoration(
                        labelText: 'customer_filter'.tr,
                        prefixIcon: const Icon(Icons.person_search_outlined),
                      ),
                      items: [
                        DropdownMenuItem(value: 'all', child: Text('all'.tr)),
                        for (final customer in customers)
                          DropdownMenuItem(
                            value: customer,
                            child: Text(customer),
                          ),
                      ],
                      onChanged: (value) {
                        controller.customerFilter.value = value == 'all'
                            ? ''
                            : value ?? '';
                      },
                    );
                  }),
                  const SizedBox(height: 12),
                  Obx(
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
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: controller.minPriceController,
                    label: 'min_price'.tr,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: AppInputFormatters.decimal,
                    onChanged: (value) =>
                        controller.minPrice.value = double.tryParse(value),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: controller.maxPriceController,
                    label: 'max_price'.tr,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: AppInputFormatters.decimal,
                    onChanged: (value) =>
                        controller.maxPrice.value = double.tryParse(value),
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () => _DateFilterField(
                      label: 'date_from'.tr,
                      value: controller.dateFrom.value,
                      onTap: () => _pickDate(
                        context,
                        initialDate: controller.dateFrom.value,
                        onPicked: controller.setDateFrom,
                      ),
                      onClear: controller.dateFrom.value == null
                          ? null
                          : () => controller.setDateFrom(null),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () => _DateFilterField(
                      label: 'date_to'.tr,
                      value: controller.dateTo.value,
                      onTap: () => _pickDate(
                        context,
                        initialDate: controller.dateTo.value,
                        onPicked: controller.setDateTo,
                      ),
                      onClear: controller.dateTo.value == null
                          ? null
                          : () => controller.setDateTo(null),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: controller.resetAdvancedFilters,
              child: Text('reset_filters'.tr),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('apply'.tr),
            ),
          ],
        );
      },
    );
  }
}

Future<void> _pickDate(
  BuildContext context, {
  required DateTime? initialDate,
  required ValueChanged<DateTime> onPicked,
}) async {
  final now = DateTime.now();
  final picked = await showDatePicker(
    context: context,
    initialDate: initialDate ?? now,
    firstDate: DateTime(2000),
    lastDate: DateTime(now.year + 20),
  );
  if (picked != null) {
    onPicked(picked);
  }
}

int _activeFilterCount(InvoicesController controller) {
  return [
    controller.customerFilter.value.trim().isNotEmpty,
    controller.statusFilter.value != 'all',
    controller.minPrice.value != null,
    controller.maxPrice.value != null,
    controller.dateFrom.value != null,
    controller.dateTo.value != null,
  ].where((active) => active).length;
}

List<Widget> _activeFilterChips(InvoicesController controller) {
  return [
    if (controller.customerFilter.value.trim().isNotEmpty)
      _SmallFilterChip(
        label: controller.customerFilter.value,
        onDeleted: () => controller.customerFilter.value = '',
      ),
    if (controller.statusFilter.value != 'all')
      _SmallFilterChip(
        label: controller.statusFilter.value.tr,
        onDeleted: () => controller.statusFilter.value = 'all',
      ),
    if (controller.minPrice.value != null)
      _SmallFilterChip(
        label: '${'min_price'.tr}: ${controller.minPrice.value}',
        onDeleted: () {
          controller.minPriceController.clear();
          controller.minPrice.value = null;
        },
      ),
    if (controller.maxPrice.value != null)
      _SmallFilterChip(
        label: '${'max_price'.tr}: ${controller.maxPrice.value}',
        onDeleted: () {
          controller.maxPriceController.clear();
          controller.maxPrice.value = null;
        },
      ),
    if (controller.dateFrom.value != null)
      _SmallFilterChip(
        label:
            '${'date_from'.tr}: ${DateTimeUtils.formatDate(controller.dateFrom.value!)}',
        onDeleted: () => controller.setDateFrom(null),
      ),
    if (controller.dateTo.value != null)
      _SmallFilterChip(
        label:
            '${'date_to'.tr}: ${DateTimeUtils.formatDate(controller.dateTo.value!)}',
        onDeleted: () => controller.setDateTo(null),
      ),
  ];
}

class _SmallFilterChip extends StatelessWidget {
  const _SmallFilterChip({required this.label, required this.onDeleted});

  final String label;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    return InputChip(
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      label: Text(label, overflow: TextOverflow.ellipsis),
      labelStyle: Theme.of(context).textTheme.labelSmall,
      onDeleted: onDeleted,
      deleteIcon: const Icon(Icons.close, size: 16),
    );
  }
}

class _DateFilterField extends StatelessWidget {
  const _DateFilterField({
    required this.label,
    required this.value,
    required this.onTap,
    required this.onClear,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_month_outlined),
          suffixIcon: onClear == null
              ? null
              : IconButton(
                  tooltip: 'clear'.tr,
                  onPressed: onClear,
                  icon: const Icon(Icons.close),
                ),
        ),
        child: Text(
          value == null ? 'select_date'.tr : DateTimeUtils.formatDate(value!),
          overflow: TextOverflow.ellipsis,
        ),
      ),
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
              DataCell(
                Text(
                  CurrencyUtils.format(
                    invoice.finalTotal,
                    symbol: invoice.currencySymbol,
                  ),
                ),
              ),
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
            Text(
              CurrencyUtils.format(
                invoice.finalTotal,
                symbol: invoice.currencySymbol,
              ),
            ),
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
