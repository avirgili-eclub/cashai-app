class TopCategory {
  final int id;
  final String name;
  final String emoji;
  final double amount;
  final double percentage;
  final int expenseCount;
  final String? color; // Added color field

  TopCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.amount,
    required this.percentage,
    required this.expenseCount,
    this.color,
  });

  factory TopCategory.fromJson(Map<String, dynamic> json) {
    return TopCategory(
      id: json['id'] as int,
      name: json['name'] as String,
      emoji: json['emoji'] as String,
      amount: (json['amount'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
      expenseCount: (json['expenseCount'] as num).toInt(),
      color: json['color'] as String?,
    );
  }
}
