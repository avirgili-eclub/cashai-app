import 'package:intl/intl.dart';

/// Utility class to handle money formatting throughout the app
class MoneyFormatter {
  /// Private constructor to prevent instantiation
  MoneyFormatter._();

  /// Default currency symbol
  static const String defaultCurrency = 'Gs.';

  /// Format a number as currency with thousand separators
  ///
  /// Example: `formatAmount(10000)` returns `Gs. 10.000`
  static String formatAmount(double amount, {String? currency}) {
    // Create a number format with the Paraguayan locale (uses dot as thousands separator)
    final formatter = NumberFormat('#,###', 'es_PY');

    // Format the amount with thousand separators
    final formattedNumber = formatter.format(amount);

    // Add the currency symbol
    return '${currency ?? defaultCurrency} $formattedNumber';
  }

  /// Format a string representation of an amount
  ///
  /// Safely handles parsing before formatting
  static String formatStringAmount(String amountStr, {String? currency}) {
    try {
      // Remove any non-numeric characters except decimal point
      final cleanedStr = amountStr.replaceAll(RegExp(r'[^\d.]'), '');

      // Parse the string to a double
      final amount = double.parse(cleanedStr);

      // Return the formatted amount
      return formatAmount(amount, currency: currency);
    } catch (e) {
      // If parsing fails, return the original string
      return amountStr;
    }
  }
}

/// Extension on num to format as currency easily
extension MoneyFormatting on num {
  /// Format this number as currency
  ///
  /// Example: `10000.toCurrency()` returns `Gs. 10.000`
  String toCurrency({String? currency}) {
    return MoneyFormatter.formatAmount(toDouble(), currency: currency);
  }
}
