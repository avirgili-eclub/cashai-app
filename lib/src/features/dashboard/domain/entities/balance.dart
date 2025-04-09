class Balance {
  final double monthlyIncome;
  final double extraIncome;
  final double totalIncome;
  final double expenses;
  final double totalBalance;
  final String currency;
  final int month;
  final int year;

  Balance({
    required this.monthlyIncome,
    required this.extraIncome,
    required this.totalIncome,
    required this.expenses,
    required this.totalBalance,
    required this.currency,
    required this.month,
    required this.year,
  });

  factory Balance.fromJson(Map<String, dynamic> json) {
    return Balance(
      monthlyIncome: (json['monthlyIncome'] as num).toDouble(),
      extraIncome: (json['extraIncome'] as num).toDouble(),
      totalIncome: (json['totalIncome'] as num).toDouble(),
      expenses: (json['expenses'] as num).toDouble(),
      totalBalance: (json['totalBalance'] as num).toDouble(),
      currency: json['currency'] as String,
      month: json['month'] as int,
      year: json['year'] as int,
    );
  }
}
