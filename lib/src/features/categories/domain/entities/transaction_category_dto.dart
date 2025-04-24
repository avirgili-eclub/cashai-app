import '../../../dashboard/domain/entities/recent_transaction.dart';

class TransactionCategoryDTO {
  final int id;
  final double amount;
  final DateTime date;
  final String description;
  final String type;
  final int categoryId;
  final String categoryName;
  final String categoryEmoji;
  final String? location;

  TransactionCategoryDTO({
    required this.id,
    required this.amount,
    required this.date,
    required this.description,
    required this.type,
    required this.categoryId,
    required this.categoryName,
    required this.categoryEmoji,
    this.location,
  });

  factory TransactionCategoryDTO.fromJson(Map<String, dynamic> json) {
    return TransactionCategoryDTO(
      id: json['id'],
      amount: json['amount'].toDouble(),
      date: DateTime.parse(json['date']),
      description: json['description'],
      type: json['type'],
      categoryId: json['categoryId'],
      categoryName: json['categoryName'] ?? '',
      categoryEmoji: json['categoryEmoji'] ?? '📋',
      location: json['location'],
    );
  }

  // Add method to convert to RecentTransaction for navigation
  RecentTransaction toRecentTransaction({String? userId = ''}) {
    return RecentTransaction(
      id: id,
      userId: int.tryParse(userId ?? '') ??
          0, // Use provided userId or default to 0
      mccCode: '', // Default value
      systemCategory: categoryId,
      amount: amount,
      type: type,
      date: date,
      description: description,
      categoryId: categoryId,
      categoryName: categoryName,
      emoji: categoryEmoji,
    );
  }
}
