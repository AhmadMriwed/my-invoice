import 'package:flutter_test/flutter_test.dart';

import 'package:test_invoice/core/pdf/pdf_options.dart';
import 'package:test_invoice/features/invoice_form/widgets/invoice_pdf_builder.dart';
import 'package:test_invoice/features/invoices/model/invoice.dart';
import 'package:test_invoice/features/invoices/model/invoice_item.dart';
import 'package:test_invoice/features/shop/model/shop_info.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('invoice calculations normalize invalid values', () {
    final now = DateTime(2026);
    final invoice = Invoice(
      id: 'invoice-1',
      invoiceNumber: 'INV-1',
      date: now,
      createdAt: now,
      updatedAt: now,
      discount: -10,
      tax: -5,
      items: [
        InvoiceItem(
          id: 'item-1',
          name: 'Service',
          createdAt: now,
          updatedAt: now,
          quantity: 2,
          unitPrice: 50,
        ),
        InvoiceItem(
          id: 'item-2',
          name: 'Invalid item',
          createdAt: now,
          updatedAt: now,
          quantity: -3,
          unitPrice: -20,
        ),
      ],
    );

    expect(invoice.subtotal, 100);
    expect(invoice.safeDiscount, 0);
    expect(invoice.safeTax, 0);
    expect(invoice.finalTotal, 100);
  });

  test(
    'pdf generation works for every theme with empty optional fields',
    () async {
      final now = DateTime(2026);
      final invoice = Invoice(
        id: 'invoice-1',
        invoiceNumber: 'INV-1',
        customerName: 'Walk-in customer',
        date: now,
        createdAt: now,
        updatedAt: now,
        items: [
          InvoiceItem(
            id: 'item-1',
            name: 'Service',
            createdAt: now,
            updatedAt: now,
            quantity: 1,
            unitPrice: 100,
          ),
        ],
      );

      for (final theme in InvoicePdfTheme.values) {
        final bytes = await InvoicePdfBuilder.build(
          invoice,
          shopInfo: ShopInfo.fromMap(null),
          theme: theme,
        );

        expect(bytes, isNotEmpty);
      }
    },
  );

  test(
    'pdf generation supports Arabic, English, mixed text, and thermal mode',
    () async {
      final now = DateTime(2026);
      final invoices = [
        _invoice(now, customerName: 'Walk-in customer', itemName: 'Service'),
        _invoice(now, customerName: 'عميل عربي', itemName: 'خدمة تصميم'),
        _invoice(
          now,
          customerName: 'عميل عربي / John',
          itemName: 'Service خدمة',
        ),
      ];

      for (final invoice in invoices) {
        final a4 = await InvoicePdfBuilder.build(
          invoice,
          shopInfo: ShopInfo.fromMap({
            'shopName': 'متجر الاختبار Test Shop',
            'phoneNumber': '+963000000',
            'address': 'دمشق - Syria',
          }),
          theme: InvoicePdfTheme.modern,
          paperSize: PaperSizeOption.a4,
        );
        final thermal = await InvoicePdfBuilder.build(
          invoice,
          shopInfo: ShopInfo.fromMap(null),
          theme: InvoicePdfTheme.dark,
          paperSize: PaperSizeOption.thermal,
        );

        expect(a4, isNotEmpty);
        expect(thermal, isNotEmpty);
      }
    },
  );
}

Invoice _invoice(
  DateTime now, {
  required String customerName,
  required String itemName,
}) {
  return Invoice(
    id: 'invoice-$customerName',
    invoiceNumber: 'INV-1',
    customerName: customerName,
    date: now,
    createdAt: now,
    updatedAt: now,
    notes: 'شكراً لك Thank you',
    items: [
      InvoiceItem(
        id: 'item-1',
        name: itemName,
        createdAt: now,
        updatedAt: now,
        quantity: 1,
        unitPrice: 100,
      ),
    ],
  );
}
