import 'dart:developer' as developer;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/recent_transaction.dart';
import '../../domain/repositories/transaction_repository.dart';

part 'transactions_controller.g.dart';

@riverpod
class TransactionsController extends _$TransactionsController {
  @override
  Future<List<RecentTransaction>> build() async {
    developer.log('TransactionsController build called',
        name: 'transactions_controller');
    return _fetchRecentTransactions();
  }

  Future<List<RecentTransaction>> _fetchRecentTransactions() async {
    developer.log('Fetching recent transactions data',
        name: 'transactions_controller');
    final repository = ref.watch(transactionRepositoryProvider);
    try {
      final transactions = await repository.getRecentTransactions();
      developer.log('Transactions fetched successfully: ${transactions.length}',
          name: 'transactions_controller');
      return transactions;
    } catch (e, stack) {
      developer.log('Error fetching transactions: $e',
          name: 'transactions_controller', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> refreshTransactions() async {
    developer.log('Manual refresh triggered', name: 'transactions_controller');
    state = const AsyncValue.loading();
    try {
      final transactions = await _fetchRecentTransactions();
      developer.log('Transactions refreshed successfully',
          name: 'transactions_controller');
      state = AsyncValue.data(transactions);
    } catch (e, st) {
      developer.log('Refresh failed',
          name: 'transactions_controller', error: e, stackTrace: st);
      state = AsyncValue.error(e, st);
    }
  }
}
