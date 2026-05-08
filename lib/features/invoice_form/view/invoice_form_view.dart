import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../core/utils/app_input_formatters.dart';
import '../../../core/utils/screen_utils.dart';
import '../../../core/widgets/app_action_button.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_info_tile.dart';
import '../../../core/widgets/app_navigation_scaffold.dart';
import '../../../core/widgets/app_section_title.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/currency_selector.dart';
import '../../customers/model/customer.dart';
import '../../invoices/model/invoice_item.dart';
import '../controller/invoice_form_controller.dart';
import '../widgets/product_form_dialog.dart';

class InvoiceFormView extends GetView<InvoiceFormController> {
  const InvoiceFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppNavigationScaffold(
      currentRoute: AppRoutes.invoiceForm,
      title: controller.editingInvoice == null
          ? 'create_invoice'.tr
          : 'Edit invoice',
      actions: [
        TextButton.icon(
          onPressed: controller.saveDraft,
          icon: const Icon(Icons.drafts_outlined),
          label: Text('draft'.tr),
        ),
        TextButton.icon(
          onPressed: controller.openPdfPreview,
          icon: const Icon(Icons.picture_as_pdf_outlined),
          label: Text('preview_pdf'.tr),
        ),
      ],
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = ScreenUtils.isDesktop(context);
          final content = SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              ScreenUtils.responsiveHorizontalPadding(context),
              18,
              ScreenUtils.responsiveHorizontalPadding(context),
              isDesktop ? 32 : 190,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1240),
                child: isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _InvoiceDocument(controller: controller),
                          ),
                          const SizedBox(width: 20),
                          SizedBox(
                            width: 340,
                            child: _StickyTotalsPanel(controller: controller),
                          ),
                        ],
                      )
                    : _InvoiceDocument(controller: controller),
              ),
            ),
          );

          if (isDesktop) {
            return content;
          }


          return Stack(
            children: [
              content,
              // Positioned(
              //   left: 12,
              //   right: 12,
              //   bottom: 12,
              //   child: _MobileTotalsBar(controller: controller),
              // ),
            ],
          );
        },
      ),
    );
  }
}

class _InvoiceDocument extends StatelessWidget {
  const _InvoiceDocument({required this.controller});

  final InvoiceFormController controller;

  @override
  Widget build(BuildContext context) {
    final isDesktop = ScreenUtils.isDesktop(context);
    return Column(
      children: [
        _DocumentHeader(controller: controller),
        const SizedBox(height: 16),
        _ResponsiveSections(
          left: Column(
            children: [
              _ShopSection(controller: controller),
              const SizedBox(height: 16),
              _CustomerSection(controller: controller),
            ],
          ),
          right: Column(
            children: [
              _DateSection(controller: controller),
              const SizedBox(height: 16),
              _CurrencySection(controller: controller),
              const SizedBox(height: 16),
              _NotesSection(controller: controller),
            ],
          ),
        ),
        if (!ScreenUtils.isDesktop(context)) ...[
          const SizedBox(height: 16),
          _TotalsAdjustmentsSection(controller: controller),
        ],
        const SizedBox(height: 16),
        _ProductsSection(controller: controller),
        const SizedBox(height: 20),
        if(!isDesktop)
        _MobileTotalsBar(controller: controller),
        const SizedBox(height: 20),
        Obx(
          () => AppButton(
            label: 'save_invoice'.tr,
            icon: const Icon(Icons.save_outlined),
            isLoading: controller.isSaving.value,
            onPressed: controller.saveInvoice,
          ),
        ),
      ],
    );
  }
}

class _DocumentHeader extends StatelessWidget {
  const _DocumentHeader({required this.controller});

  final InvoiceFormController controller;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(22),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.receipt_long,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.editingInvoice == null
                      ? 'new_invoice'.tr
                      : 'editing_invoice'.tr,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'invoice_workspace_hint'.tr,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          AppActionButton(
            icon: Icons.picture_as_pdf_outlined,
            label: 'preview'.tr,
            onPressed: controller.openPdfPreview,
            isPrimary: true,
          ),
        ],
      ),
    );
  }
}

class _ResponsiveSections extends StatelessWidget {
  const _ResponsiveSections({required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    if (!ScreenUtils.isDesktop(context)) {
      return Column(children: [left, const SizedBox(height: 16), right]);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: left),
        const SizedBox(width: 16),
        Expanded(child: right),
      ],
    );
  }
}

class _ShopSection extends StatelessWidget {
  const _ShopSection({required this.controller});

  final InvoiceFormController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final shop = controller.shopInfo.value;
      return _SectionCard(
        title: 'shop_info'.tr,
        subtitle: 'business_details_on_invoices'.tr,
        action: AppActionButton(
          onPressed: controller.editShopInfo,
          icon: Icons.edit_outlined,
          label: 'edit'.tr,
        ),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.storefront_outlined),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shop.shopName.isEmpty ? 'shop_name'.tr : shop.shopName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    shop.phoneNumber.isEmpty
                        ? 'Phone not set'
                        : shop.phoneNumber,
                  ),
                  Text(shop.address.isEmpty ? 'Address not set' : shop.address),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _CustomerSection extends StatelessWidget {
  const _CustomerSection({required this.controller});

  final InvoiceFormController controller;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'customer'.tr,
      subtitle: 'select_customer'.tr,
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              padding: const EdgeInsets.all(14),
              hoverable: true,
              onTap: () => _openCustomerSearch(context),
              child: Row(
                children: [
                  CircleAvatar(
                    child: Text(
                      _initial(
                        controller.selectedCustomer.value?.fullName ?? 'C',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: controller.selectedCustomer.value == null
                        ? Text('select_customer'.tr)
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(controller.selectedCustomer.value!.fullName),
                              Text(
                                controller.selectedCustomer.value!.phone,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                  ),
                  const Icon(Icons.search),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (controller.selectedCustomer.value != null)
              AppInfoTile(
                label: 'customer_address'.tr,
                value: controller.selectedCustomer.value!.address,
                icon: Icons.location_on_outlined,
              ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AppActionButton(
                  onPressed: controller.createTemporaryCustomer,
                  icon: Icons.person_add_alt_outlined,
                  label: 'quick_create'.tr,
                ),
                AppActionButton(
                  onPressed:
                      controller.selectedCustomer.value == null ||
                          controller.selectedCustomer.value!.id.startsWith(
                            'temp-',
                          )
                      ? null
                      : controller.editSelectedCustomer,
                  icon: Icons.edit_outlined,
                  label: 'edit'.tr,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCustomerSearch(BuildContext context) async {
    final selected = await showDialog<Customer>(
      context: context,
      builder: (_) => _CustomerSearchDialog(customers: controller.customers),
    );
    if (selected != null) {
      controller.selectCustomer(selected);
    }
  }
}

class _ProductsSection extends StatelessWidget {
  const _ProductsSection({required this.controller});

  final InvoiceFormController controller;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'products'.tr,
      subtitle: 'products_section_hint'.tr,
      action: AppActionButton(
        onPressed: () async {
          final item = await Get.dialog<InvoiceItem>(const ProductFormDialog());
          if (item != null) {
            controller.addOrUpdateItem(item);
          }
        },
        icon: Icons.add,
        label: 'add_product'.tr,
        isPrimary: true,
      ),
      child: Obx(() {
        if (controller.items.isEmpty) {
          return AppEmptyState(
            title: 'no_products'.tr,
            message: 'add_first_product_message'.tr,
            icon: Icons.inventory_2_outlined,
            action: AppActionButton(
              icon: Icons.add,
              label: 'add_product'.tr,
              isPrimary: true,
              onPressed: () async {
                final item = await Get.dialog<InvoiceItem>(
                  const ProductFormDialog(),
                );
                if (item != null) {
                  controller.addOrUpdateItem(item);
                }
              },
            ),
          );
        }
        if (ScreenUtils.isDesktop(context)) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _ProductTable(controller: controller),
          );
        }
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: Column(
            key: ValueKey(controller.items.length),
            children: controller.items
                .map((item) => _ProductCard(item: item, controller: controller))
                .toList(),
          ),
        );
      }),
    );
  }
}

class _ProductTable extends StatelessWidget {
  const _ProductTable({required this.controller});

  final InvoiceFormController controller;

  @override
  Widget build(BuildContext context) {
    return DataTable(
      headingRowHeight: 48,
      dataRowMinHeight: 68,
      dataRowMaxHeight: 78,
      columns: [
        DataColumn(label: Text('image'.tr)),
        DataColumn(label: Text('product'.tr)),
        DataColumn(label: Text('quantity'.tr)),
        DataColumn(label: Text('unit_price'.tr)),
        DataColumn(label: Text('total'.tr)),
        DataColumn(label: Text('actions'.tr)),
      ],
      rows: controller.items.map((item) {
        return DataRow(
          cells: [
            DataCell(
              _ProductImagePlaceholder(
                name: item.name,
                imagePath: item.imagePath,
              ),
            ),
            DataCell(
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name),
                  if (item.notes.isNotEmpty)
                    Text(
                      item.notes,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            DataCell(
              Row(
                children: [
                  IconButton(
                    onPressed: () => controller.decreaseQuantity(item),
                    icon: const Icon(Icons.remove),
                  ),
                  SizedBox(
                    width: 64,
                    child: TextFormField(
                      key: ValueKey('quantity-${item.id}-${item.safeQuantity}'),
                      initialValue: item.safeQuantity.toStringAsFixed(2),
                      textAlign: TextAlign.center,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: AppInputFormatters.decimal,
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                      onChanged: (value) =>
                          controller.updateQuantity(item, value),
                    ),
                  ),
                  IconButton(
                    onPressed: () => controller.increaseQuantity(item),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
            DataCell(Text(controller.formatCurrency(item.safeUnitPrice))),
            DataCell(
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Text(
                  controller.formatCurrency(item.total),
                  key: ValueKey(item.total),
                ),
              ),
            ),
            DataCell(_ProductActions(item: item, controller: controller)),
          ],
        );
      }).toList(),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.item, required this.controller});

  final InvoiceItem item;
  final InvoiceFormController controller;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      hoverable: true,
      child: Row(
        children: [
          _ProductImagePlaceholder(name: item.name, imagePath: item.imagePath),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  '${item.safeQuantity} x ${controller.formatCurrency(item.safeUnitPrice)}',
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Text(
                  controller.formatCurrency(item.total),
                  key: ValueKey(item.total),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              _ProductActions(item: item, controller: controller),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductActions extends StatelessWidget {
  const _ProductActions({required this.item, required this.controller});

  final InvoiceItem item;
  final InvoiceFormController controller;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        IconButton(
          tooltip: 'edit_product'.tr,
          onPressed: () async {
            final updated = await Get.dialog<InvoiceItem>(
              ProductFormDialog(item: item),
            );
            if (updated != null) {
              controller.addOrUpdateItem(updated);
            }
          },
          icon: const Icon(Icons.edit_outlined),
        ),
        IconButton(
          tooltip: 'delete_product'.tr,
          onPressed: () => controller.deleteItem(item),
          icon: const Icon(Icons.delete_outline),
        ),
      ],
    );
  }
}

class _DateSection extends StatelessWidget {
  const _DateSection({required this.controller});

  final InvoiceFormController controller;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'date'.tr,
      child: Obx(
        () => ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.calendar_today_outlined),
          title: Text(DateTimeUtils.formatDate(controller.invoiceDate.value)),
          trailing: TextButton(
            onPressed: () => controller.pickDate(context),
            child: Text('change'.tr),
          ),
        ),
      ),
    );
  }
}

class _CurrencySection extends StatelessWidget {
  const _CurrencySection({required this.controller});

  final InvoiceFormController controller;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'currency'.tr,
      child: CurrencySelector(
        currencyController: controller.currencyController,
        symbolController: controller.currencySymbolController,
        onChanged: controller.refreshCurrency,
      ),
    );
  }
}

class _NotesSection extends StatelessWidget {
  const _NotesSection({required this.controller});

  final InvoiceFormController controller;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'notes'.tr,
      child: AppTextField(
        controller: controller.notesController,
        label: 'invoice_notes'.tr,
      ),
    );
  }
}

class _TotalsAdjustmentsSection extends StatelessWidget {
  const _TotalsAdjustmentsSection({required this.controller});

  final InvoiceFormController controller;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'adjustments'.tr,
      subtitle: 'adjustments_hint'.tr,
      child: Row(
        children: [
          Expanded(
            child: AppTextField(
              controller: controller.discountController,
              label: 'discount'.tr,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: AppInputFormatters.decimal,
              onChanged: (_) => controller.items.refresh(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppTextField(
              controller: controller.taxController,
              label: 'tax'.tr,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: AppInputFormatters.decimal,
              onChanged: (_) => controller.items.refresh(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    this.subtitle,
    this.action,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionTitle(title: title, subtitle: subtitle, action: action),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _StickyTotalsPanel extends StatelessWidget {
  const _StickyTotalsPanel({required this.controller});

  final InvoiceFormController controller;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: _TotalsContent(controller: controller),
    );
  }
}

class _MobileTotalsBar extends StatelessWidget {
  const _MobileTotalsBar({required this.controller});

  final InvoiceFormController controller;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: _TotalsContent(controller: controller, compact: true),
    );
  }
}

class _TotalsContent extends StatelessWidget {
  const _TotalsContent({required this.controller, this.compact = false});

  final InvoiceFormController controller;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppSectionTitle(
          title: 'invoice_totals'.tr,
          subtitle: compact ? null : 'live_calculation_summary'.tr,
        ),
        const SizedBox(height: 14),
        if (!compact) ...[
          AppTextField(
            controller: controller.discountController,
            label: 'discount'.tr,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: AppInputFormatters.decimal,
            onChanged: (_) => controller.items.refresh(),
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: controller.taxController,
            label: 'tax'.tr,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: AppInputFormatters.decimal,
            onChanged: (_) => controller.items.refresh(),
          ),
          const SizedBox(height: 16),
        ],
        Obx(() {
          controller.currencyVersion.value;
          return Column(
            children: [
              _TotalLine(
                label: 'subtotal'.tr,
                value: controller.subtotal,
                symbol: controller.currencySymbol,
              ),
              if (!compact) ...[
                _TotalLine(
                  label: 'discount'.tr,
                  value: controller.discount,
                  symbol: controller.currencySymbol,
                ),
                _TotalLine(
                  label: 'tax'.tr,
                  value: controller.tax,
                  symbol: controller.currencySymbol,
                ),
              ],
              _TotalLine(
                label: 'final_total'.tr,
                value: controller.finalTotal,
                symbol: controller.currencySymbol,
                isStrong: true,
              ),
            ],
          );
        }),
        const SizedBox(height: 12),
        AppActionButton(
          icon: Icons.picture_as_pdf_outlined,
          label: 'preview'.tr,
          onPressed: controller.openPdfPreview,
          isPrimary: true,
        ),
      ],
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
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Text(
              CurrencyUtils.format(value, symbol: symbol),
              key: ValueKey('$label$value$symbol'),
              style: style,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductImagePlaceholder extends StatelessWidget {
  const _ProductImagePlaceholder({required this.name, this.imagePath = ''});

  final String name;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final file = imagePath.trim().isEmpty ? null : File(imagePath.trim());
    if (file != null && file.existsSync()) {
      return ClipOval(
        child: Image.file(file, width: 42, height: 42, fit: BoxFit.cover),
      );
    }
    return CircleAvatar(
      backgroundColor: colorScheme.secondaryContainer,
      child: Text(
        _initial(name.isEmpty ? 'P' : name),
        style: TextStyle(color: colorScheme.onSecondaryContainer),
      ),
    );
  }
}

class _CustomerSearchDialog extends StatefulWidget {
  const _CustomerSearchDialog({required this.customers});

  final List<Customer> customers;

  @override
  State<_CustomerSearchDialog> createState() => _CustomerSearchDialogState();
}

class _CustomerSearchDialogState extends State<_CustomerSearchDialog> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.customers.where((customer) {
      final value = query.toLowerCase();
      return customer.fullName.toLowerCase().contains(value) ||
          customer.phone.toLowerCase().contains(value) ||
          customer.city.toLowerCase().contains(value);
    }).toList();

    return AlertDialog(
      title: Text('select_customer'.tr),
      content: SizedBox(
        width: 520,
        height: 460,
        child: Column(
          children: [
            AppTextField(
              label: 'search_customers'.tr,
              prefixIcon: const Icon(Icons.search),
              onChanged: (value) => setState(() => query = value),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'recent_customers'.tr,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filtered.isEmpty
                  ? AppEmptyState(
                      title: 'no_matching_customers'.tr,
                      message: 'try_different_customer_search'.tr,
                      icon: Icons.person_search_outlined,
                    )
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final customer = filtered[index];
                        return AppCard(
                          padding: const EdgeInsets.all(12),
                          hoverable: true,
                          onTap: () => Get.back(result: customer),
                          child: Row(
                            children: [
                              CircleAvatar(
                                child: Text(_initial(customer.fullName)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(customer.fullName),
                                    Text(
                                      '${customer.phone} ${customer.city}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

String _initial(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return '?';
  }
  return trimmed.characters.first.toUpperCase();
}
