import 'package:intl/intl.dart';

class CurrencyUtils {
  const CurrencyUtils._();

  static String format(
    num amount, {
    String locale = 'en_US',
    String symbol = r'$',
  }) {
    return NumberFormat.currency(locale: locale, symbol: symbol).format(amount);
  }
}
