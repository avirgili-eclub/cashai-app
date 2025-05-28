import 'package:flutter/material.dart';
import 'package:cashai/src/core/utils/money_formatter.dart';
import 'package:cashai/src/core/styles/app_styles.dart';

/// A widget to display formatted money amounts consistently throughout the app
class MoneyText extends StatelessWidget {
  /// The amount to display
  final double amount;

  /// Optional currency symbol (defaults to 'Gs.')
  final String? currency;

  /// Text style to apply
  final TextStyle? style;

  /// Whether this is an expense (negative) amount
  final bool isExpense;

  /// Whether this is an income (positive) amount
  final bool isIncome;

  /// Whether to show the sign (+/-) before the amount
  final bool showSign;

  /// Whether to use color coding (green for income, red for expense)
  final bool useColors;

  /// Creates a MoneyText widget
  const MoneyText({
    Key? key,
    required this.amount,
    this.currency,
    this.style,
    this.isExpense = false,
    this.isIncome = false,
    this.showSign = false,
    this.useColors = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine if we need to display a sign
    final shouldDisplaySign = showSign || isIncome || isExpense;

    // Format the amount
    String formattedAmount = MoneyFormatter.formatAmount(
      amount.abs(), // Use absolute value as we'll add the sign manually
      currency: currency,
    );

    // Add sign if needed
    if (shouldDisplaySign) {
      if (isExpense || (amount < 0 && !isIncome)) {
        formattedAmount = '- $formattedAmount';
      } else if (isIncome || (amount > 0 && !isExpense)) {
        formattedAmount = '+ $formattedAmount';
      }
    }

    // Determine the text color
    Color? textColor;
    if (useColors) {
      if (isExpense || amount < 0) {
        textColor = AppStyles.expenseColor;
      } else if (isIncome || amount > 0) {
        textColor = AppStyles.incomeColor;
      }
    }

    return Text(
      formattedAmount,
      style: style?.copyWith(color: textColor) ?? TextStyle(color: textColor),
    );
  }

  /// Create a MoneyText widget for an expense amount
  factory MoneyText.expense({
    Key? key,
    required double amount,
    String? currency,
    TextStyle? style,
    bool showSign = true,
    bool useColors = true,
  }) {
    return MoneyText(
      key: key,
      amount: amount.abs() * -1, // Force negative
      currency: currency,
      style: style,
      isExpense: true,
      showSign: showSign,
      useColors: useColors,
    );
  }

  /// Create a MoneyText widget for an income amount
  factory MoneyText.income({
    Key? key,
    required double amount,
    String? currency,
    TextStyle? style,
    bool showSign = true,
    bool useColors = true,
  }) {
    return MoneyText(
      key: key,
      amount: amount.abs(), // Force positive
      currency: currency,
      style: style,
      isIncome: true,
      showSign: showSign,
      useColors: useColors,
    );
  }
}
