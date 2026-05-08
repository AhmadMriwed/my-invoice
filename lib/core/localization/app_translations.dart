import 'package:get/get.dart';

import 'ar.dart';
import 'en.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en': en,
    'en_US': en,
    'ar': ar,
    'ar_SA': ar,
  };
}
