import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/utils/screen_utils.dart';
import '../../../core/widgets/app_action_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_navigation_scaffold.dart';
import '../../../core/widgets/app_table_container.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controller/customers_controller.dart';
import '../model/customer.dart';

class CustomersView extends GetView<CustomersController> {
  const CustomersView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppNavigationScaffold(
      currentRoute: AppRoutes.customers,
      title: 'customers'.tr,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.openCreate,
        icon: const Icon(Icons.add),
        label: Text('customer'.tr),
      ),
      body: Padding(
        padding: EdgeInsets.all(
          ScreenUtils.responsiveHorizontalPadding(context),
        ),
        child: Column(
          children: [
            AppTextField(
              label: 'search_customers'.tr,
              prefixIcon: const Icon(Icons.search),
              onChanged: (value) => controller.query.value = value,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                final customers = controller.filteredCustomers;
                if (customers.isEmpty) {
                  return AppEmptyState(
                    title: 'no_customers_yet'.tr,
                    message: 'create_customers_message'.tr,
                    icon: Icons.people_alt_outlined,
                    action: AppActionButton(
                      icon: Icons.person_add_alt_outlined,
                      label: 'create_customer'.tr,
                      onPressed: controller.openCreate,
                      isPrimary: true,
                    ),
                  );
                }
                if (ScreenUtils.isDesktop(context)) {
                  return _CustomersTable(
                    customers: customers,
                    controller: controller,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 96),
                  itemCount: customers.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, index) => _CustomerCard(
                    customer: customers[index],
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

class _CustomersTable extends StatelessWidget {
  const _CustomersTable({required this.customers, required this.controller});

  final List<Customer> customers;
  final CustomersController controller;

  @override
  Widget build(BuildContext context) {
    return AppTableContainer(
      child: DataTable(
        columns: [
          DataColumn(label: Text('full_name'.tr)),
          DataColumn(label: Text('phone'.tr)),
          DataColumn(label: Text('city'.tr)),
          DataColumn(label: Text('invoices'.tr)),
          DataColumn(label: Text('actions'.tr)),
        ],
        rows: customers.map((customer) {
          return DataRow(
            cells: [
              DataCell(Text(customer.fullName)),
              DataCell(Text(customer.phone)),
              DataCell(Text(customer.city)),
              DataCell(Text('${controller.invoiceCountFor(customer.id)}')),
              DataCell(
                Wrap(
                  spacing: 4,
                  children: [
                    IconButton(
                      tooltip: 'view'.tr,
                      onPressed: () => controller.openDetails(customer),
                      icon: const Icon(Icons.visibility_outlined),
                    ),
                    IconButton(
                      tooltip: 'edit'.tr,
                      onPressed: () => controller.openEdit(customer),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    IconButton(
                      tooltip: 'delete'.tr,
                      onPressed: () => controller.deleteCustomer(customer),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.customer, required this.controller});

  final Customer customer;
  final CustomersController controller;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      hoverable: true,
      padding: EdgeInsets.zero,
      child: ListTile(
        onTap: () => controller.openDetails(customer),
        title: Text(customer.fullName),
        subtitle: Text('${customer.phone}  ${customer.city}'),
        trailing: PopupMenuButton<String>(
          onSelected: (action) {
            if (action == 'edit') controller.openEdit(customer);
            if (action == 'delete') controller.deleteCustomer(customer);
          },
          itemBuilder: (_) => [
            PopupMenuItem(value: 'edit', child: Text('edit'.tr)),
            PopupMenuItem(value: 'delete', child: Text('delete'.tr)),
          ],
        ),
      ),
    );
  }
}
