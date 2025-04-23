class RecentTransaction {
  final int id;
  final int userId;
  final String mccCode;
  final int systemCategory;
  final double amount;
  final String type; // "DEBITO" o "CREDITO"
  final DateTime date;
  final String description;
  final String? invoiceText; // Changed to nullable
  final String? invoiceNumber; // Changed to nullable
  final String? source;
  final int? sharedGroupId;
  final String?
      emoji; // Changed to nullable since it can be null in the response
  final String? color;
  final int? categoryId; // Added new property for category ID
  final String? categoryName; // Added new property for category name

  RecentTransaction({
    required this.id,
    required this.userId,
    required this.mccCode,
    required this.systemCategory,
    required this.amount,
    required this.type,
    required this.date,
    required this.description,
    this.invoiceText,
    this.invoiceNumber,
    this.source,
    this.sharedGroupId,
    this.emoji,
    this.color,
    this.categoryId,
    this.categoryName,
  });

  factory RecentTransaction.fromJson(Map<String, dynamic> json) {
    return RecentTransaction(
      id: json['id'] as int,
      userId: json['userId'] as int,
      mccCode: json['mccCode'] as String,
      systemCategory: json['systemCategory'] as int,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String,
      invoiceText: json['invoiceText'] as String?, // Handle null safely
      invoiceNumber: json['invoiceNumber'] as String?, // Handle null safely
      source: json['source'] as String?,
      sharedGroupId: json['sharedGroupId'] as int?,
      emoji: json['emoji'] as String?, // Handle null safely
      color: json['color'] as String?, // Handle null safely
      categoryId: json['categoryId'] as int?, // Parse category ID
      categoryName: json['categoryName'] as String?, // Parse category name
    );
  }
}
