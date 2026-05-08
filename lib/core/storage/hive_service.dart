import 'package:hive_flutter/hive_flutter.dart';

import 'hive_boxes.dart';

class HiveService {
  static Future<void> init() async {
    for (final boxName in HiveBoxes.all) {
      if (!Hive.isBoxOpen(boxName)) {
        await Hive.openBox<dynamic>(boxName);
      }
    }
  }

  Box<dynamic> box(String name) => Hive.box<dynamic>(name);

  Box<dynamic> get invoicesBox => box(HiveBoxes.invoices);

  Box<dynamic> get customersBox => box(HiveBoxes.customers);

  Box<dynamic> get shopInfoBox => box(HiveBoxes.shopInfo);

  Box<dynamic> get settingsBox => box(HiveBoxes.settings);

  Box<dynamic> get draftInvoicesBox => box(HiveBoxes.draftInvoices);
}
