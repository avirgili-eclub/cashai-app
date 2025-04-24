import 'transaction_category_dto.dart';
import '../../../dashboard/domain/entities/recent_transaction.dart';

class TransactionsByCategoryDTO {
  final List<TransactionCategoryDTO> transactions;
  final double totalAmount;

  TransactionsByCategoryDTO({
    required this.transactions,
    required this.totalAmount,
  });

  factory TransactionsByCategoryDTO.fromJson(Map<String, dynamic> json) {
    return TransactionsByCategoryDTO(
      transactions: (json['transactions'] as List)
          .map((tx) => TransactionCategoryDTO.fromJson(tx))
          .toList(),
      totalAmount: json['totalAmount'],
    );
  }
}
