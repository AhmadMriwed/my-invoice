import 'package:get/get.dart';

import '../../features/settings/controller/settings_controller.dart';
import '../storage/hive_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<HiveService>(HiveService(), permanent: true);
    Get.put<SettingsController>(SettingsController(), permanent: true);
  }
}
