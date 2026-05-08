import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfFontLoader {
  const PdfFontLoader._();

  static pw.Font? _arabicFont;
  static pw.Font? _unicodeFont;

  static Future<pw.Font> arabicFont() async {
    final cached = _arabicFont;
    if (cached != null) {
      return cached;
    }

    final data = await rootBundle.load('assets/fonts/SFArabic.ttf');
    final font = pw.Font.ttf(data);
    _arabicFont = font;
    return font;
  }

  static Future<pw.Font> unicodeFont() async {
    final cached = _unicodeFont;
    if (cached != null) {
      return cached;
    }

    final data = await rootBundle.load('assets/fonts/ArialUnicode.ttf');
    final font = pw.Font.ttf(data);
    _unicodeFont = font;
    return font;
  }
}
