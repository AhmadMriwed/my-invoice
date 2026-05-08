import 'package:get/get.dart';

import '../controller/pdf_preview_controller.dart';

class PdfPreviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PdfPreviewController>(() => PdfPreviewController());
  }
}
