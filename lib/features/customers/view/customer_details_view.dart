import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/date_time_utils.dart';
import '../../../core/utils/screen_utils.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../controller/customer_details_controller.dart';
import '../widgets/customer_info_tile.dart';

class CustomerDetailsView extends GetView<CustomerDetailsController> {
  const CustomerDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final customer = controller.customer.value;
      return Scaffold(
        appBar: AppBar(
          title: Text('customer_details'.tr),
          actions: [
            IconButton(
              onPressed: controller.editCustomer,
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              onPressed: controller.deleteCustomer,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
        body: customer == null
            ? AppEmptyState(title: 'customer_not_found'.tr)
            : SingleChildScrollView(
                padding: EdgeInsets.all(
                  ScreenUtils.responsiveHorizontalPadding(context),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Column(
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                CustomerInfoTile(
                                  label: 'full_name'.tr,
                                  value: customer.fullName,
                                  icon: Icons.person_outline,
                                ),
                                CustomerInfoTile(
                                  label: 'phone'.tr,
                                  value: customer.phone,
                                  icon: Icons.phone_outlined,
                                ),
                                CustomerInfoTile(
                                  label: 'alternative_phone'.tr,
                                  value: customer.alternativePhone,
                                  icon: Icons.phone_android_outlined,
                                ),
                                CustomerInfoTile(
                                  label: 'email'.tr,
                                  value: customer.email,
                                  icon: Icons.email_outlined,
                                ),
                                CustomerInfoTile(
                                  label: 'address'.tr,
                                  value: '${customer.address} ${customer.city}',
                                  icon: Icons.location_on_outlined,
                                ),
                                CustomerInfoTile(
                                  label: 'notes'.tr,
                                  value: customer.notes,
                                  icon: Icons.notes_outlined,
                                ),
                                CustomerInfoTile(
                                  label: 'created_date'.tr,
                                  value: DateTimeUtils.formatDateTime(
                                    customer.createdAt,
                                  ),
                                  icon: Icons.calendar_today_outlined,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: AppEmptyState(
                              title: 'invoice_history'.tr,
                              message: 'saved_invoices_history_message'
                                  .trParams({
                                    'count': '${controller.invoices.length}',
                                  }),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      );
    });
  }
}
