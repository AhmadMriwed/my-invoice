import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _prepareApp();
  }

  Future<void> _prepareApp() async {
    await Future<void>.delayed(const Duration(seconds: 2));

    Get.offNamed(AppRoutes.invoices);
  }
}
