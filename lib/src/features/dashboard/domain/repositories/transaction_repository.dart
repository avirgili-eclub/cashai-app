import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../entities/recent_transaction.dart';
import '../../data/repositories/transaction_repository_impl.dart';

part 'transaction_repository.g.dart';

abstract class TransactionRepository {
  Future<List<RecentTransaction>> getRecentTransactions();
}

@riverpod
TransactionRepository transactionRepository(TransactionRepositoryRef ref) {
  return ref.watch(transactionRepositoryImplProvider);
}
