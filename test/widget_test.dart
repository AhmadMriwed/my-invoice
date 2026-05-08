import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:my_invoice/app.dart';
import 'package:my_invoice/core/storage/hive_service.dart';

void main() {
  late Directory hiveTempDirectory;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    hiveTempDirectory = await Directory.systemTemp.createTemp('invoice_app_');
    Hive.init(hiveTempDirectory.path);
    await HiveService.init();
  });

  testWidgets('shows splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('تطبيق الفواتير'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
  });

  tearDownAll(() async {
    await Hive.close();
    await hiveTempDirectory.delete(recursive: true);
  });
}
