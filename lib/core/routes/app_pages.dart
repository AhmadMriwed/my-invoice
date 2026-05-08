import 'package:get/get.dart';

import '../../features/customers/binding/customer_details_binding.dart';
import '../../features/customers/binding/customer_form_binding.dart';
import '../../features/customers/binding/customers_binding.dart';
import '../../features/customers/view/customer_details_view.dart';
import '../../features/customers/view/customer_form_view.dart';
import '../../features/customers/view/customers_view.dart';
import '../../features/invoice_form/binding/invoice_form_binding.dart';
import '../../features/invoice_form/binding/pdf_preview_binding.dart';
import '../../features/invoice_form/view/invoice_form_view.dart';
import '../../features/invoice_form/view/pdf_preview_view.dart';
import '../../features/invoices/binding/invoices_binding.dart';
import '../../features/invoices/view/invoice_details_view.dart';
import '../../features/invoices/view/invoice_list_view.dart';
import '../../features/shop/binding/shop_binding.dart';
import '../../features/shop/view/shop_view.dart';
import '../../features/splash/binding/splash_binding.dart';
import '../../features/splash/view/splash_view.dart';
import '../../features/settings/binding/settings_binding.dart';
import '../../features/settings/view/settings_view.dart';
import 'app_routes.dart';

class AppPages {
  const AppPages._();

  static const _transition = Transition.fadeIn;
  static const _transitionDuration = Duration(milliseconds: 220);

  static final List<GetPage<dynamic>> routes = [
    GetPage<dynamic>(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
      transition: _transition,
      transitionDuration: _transitionDuration,
    ),
    GetPage<dynamic>(
      name: AppRoutes.shop,
      page: () => const ShopView(),
      binding: ShopBinding(),
      transition: _transition,
      transitionDuration: _transitionDuration,
    ),
    GetPage<dynamic>(
      name: AppRoutes.customers,
      page: () => const CustomersView(),
      binding: CustomersBinding(),
      transition: _transition,
      transitionDuration: _transitionDuration,
    ),
    GetPage<dynamic>(
      name: AppRoutes.customerForm,
      page: () => const CustomerFormView(),
      binding: CustomerFormBinding(),
      transition: _transition,
      transitionDuration: _transitionDuration,
    ),
    GetPage<dynamic>(
      name: AppRoutes.customerDetails,
      page: () => const CustomerDetailsView(),
      binding: CustomerDetailsBinding(),
      transition: _transition,
      transitionDuration: _transitionDuration,
    ),
    GetPage<dynamic>(
      name: AppRoutes.invoices,
      page: () => const InvoiceListView(),
      binding: InvoicesBinding(),
      transition: _transition,
      transitionDuration: _transitionDuration,
    ),
    GetPage<dynamic>(
      name: AppRoutes.invoiceDetails,
      page: () => const InvoiceDetailsView(),
      binding: InvoicesBinding(),
      transition: _transition,
      transitionDuration: _transitionDuration,
    ),
    GetPage<dynamic>(
      name: AppRoutes.invoiceForm,
      page: () => const InvoiceFormView(),
      binding: InvoiceFormBinding(),
      transition: _transition,
      transitionDuration: _transitionDuration,
    ),
    GetPage<dynamic>(
      name: AppRoutes.pdfPreview,
      page: () => const PdfPreviewView(),
      binding: PdfPreviewBinding(),
      transition: _transition,
      transitionDuration: _transitionDuration,
    ),
    GetPage<dynamic>(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
      transition: _transition,
      transitionDuration: _transitionDuration,
    ),
  ];
}
