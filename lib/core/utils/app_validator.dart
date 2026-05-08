import 'package:get/get.dart';

class AppValidator {
  const AppValidator._();

  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return 'field_required'.trParams({'field': fieldName ?? 'this_field'.tr});
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'invalid_email'.tr;
    }
    return null;
  }
}
