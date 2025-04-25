import 'package:numia/src/features/dashboard/domain/enums/transaction_type.dart';

class Transaction {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String iconBgColor;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final String categoryId;

  Transaction({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.iconBgColor,
    required this.amount,
    required this.date,
    required this.type,
    required this.categoryId,
  });
}
