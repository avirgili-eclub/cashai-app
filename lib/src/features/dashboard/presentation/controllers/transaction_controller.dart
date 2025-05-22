import 'dart:developer' as developer;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/recent_transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../../../core/auth/providers/user_session_provider.dart';
import '../../../../routing/app_router.dart';
import '../../data/datasources/firebase_balance_datasource.dart';

part 'transaction_controller.g.dart';

@riverpod
class TransactionsController extends _$TransactionsController {
  @override
  Future<List<RecentTransaction>> build() async {
    developer.log('TransactionsController build called',
        name: 'transactions_controller');
    return _fetchTransactions();
  }

  Future<List<RecentTransaction>> _fetchTransactions({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    developer.log(
        'Fetching transactions data with date range: ${startDate?.toIso8601String()} to ${endDate?.toIso8601String()}, limit: $limit',
        name: 'transactions_controller');

    // Check for valid user ID first
    final userSession = ref.read(userSessionNotifierProvider);
    if (userSession.userId == null || userSession.isEmpty) {
      developer.log('No authenticated user found, cannot fetch transactions',
          name: 'transactions_controller');

      // Trigger navigation to sign-in page using the router
      Future.microtask(() {
        final router = ref.read(goRouterProvider);
        router.go('/signIn');
      });

      // Return an empty list for unauthenticated users
      return [];
    }

    final repository = ref.watch(transactionRepositoryProvider);
    try {
      final transactions = await repository.getRecentTransactions(
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );
      developer.log('Transactions fetched successfully: ${transactions.length}',
          name: 'transactions_controller');
      return transactions;
    } catch (e, stack) {
      developer.log('Error fetching transactions: $e',
          name: 'transactions_controller', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> refreshTransactions({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    developer.log(
        'Manual refresh triggered with date range: ${startDate?.toIso8601String()} to ${endDate?.toIso8601String()}, limit: $limit',
        name: 'transactions_controller');
    state = const AsyncValue.loading();
    try {
      final transactions = await _fetchTransactions(
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );
      developer.log('Transactions refreshed successfully',
          name: 'transactions_controller');
      state = AsyncValue.data(transactions);
    } catch (e, st) {
      developer.log('Refresh failed',
          name: 'transactions_controller', error: e, stackTrace: st);
      state = AsyncValue.error(e, st);
    }
  }

  // Updated method for transaction deletion that explicitly checks for userId
  Future<bool> deleteTransaction(int transactionId) async {
    developer.log('Attempting to delete transaction with ID: $transactionId',
        name: 'transactions_controller');

    try {
      // Check for valid user ID first - even though the repository handles this,
      // checking it here provides better error messages and UX
      final userSession = ref.read(userSessionNotifierProvider);
      if (userSession.userId == null || userSession.isEmpty) {
        developer.log('No authenticated user found, cannot delete transaction',
            name: 'transactions_controller');

        // Show authentication error by navigating to sign in page
        Future.microtask(() {
          final router = ref.read(goRouterProvider);
          router.go('/signIn');
        });

        return false;
      } // Call the repository method, which internally uses the userId
      // from when the repository was created
      final repository = ref.read(transactionRepositoryProvider);
      final success = await repository.deleteTransaction(transactionId);

      if (success) {
        developer.log('Transaction deleted successfully',
            name: 'transactions_controller');

        // No optimistic update here since the UI is already updated by the widget
        // This avoids the double deletion effect
      } else if (state is AsyncData) {
        // Only refresh the list in case of failure to resynchronize
        developer.log(
            'Deletion failed, refreshing transactions to resynchronize',
            name: 'transactions_controller');
        refreshTransactions();
      }

      return success;
    } catch (e, stack) {
      developer.log('Error deleting transaction: $e',
          name: 'transactions_controller', error: e, stackTrace: stack);
      return false;
    }
  }

  Future<bool> updateTransaction(
      int transactionId, double amount, String title, String notes) async {
    developer.log('Attempting to update transaction with ID: $transactionId',
        name: 'transactions_controller');

    try {
      // Check for valid user ID first
      final userSession = ref.read(userSessionNotifierProvider);
      if (userSession.userId == null || userSession.isEmpty) {
        developer.log('No authenticated user found, cannot update transaction',
            name: 'transactions_controller');

        // Trigger navigation to sign-in page using the router
        Future.microtask(() {
          final router = ref.read(goRouterProvider);
          router.go('/signIn');
        });

        return false;
      }

      // Call the dataSource directly for this simple implementation
      final dataSource = ref.read(balanceDataSourceProvider);
      final success = await dataSource.updateTransaction(
          transactionId, userSession.userId!, amount, title, notes);

      if (success) {
        developer.log('Transaction updated successfully, refreshing data',
            name: 'transactions_controller');

        // Refresh transactions to get the updated data
        refreshTransactions();
      }

      return success;
    } catch (e, stack) {
      developer.log('Error updating transaction: $e',
          name: 'transactions_controller', error: e, stackTrace: stack);
      return false;
    }
  }

  // Filter methods - these don't request data from repository but filter in-memory
  List<RecentTransaction> filterTransactionsByType(
      List<RecentTransaction> transactions, String type) {
    if (type.isEmpty) return transactions;
    return transactions
        .where((transaction) => transaction.type == type)
        .toList();
  }
}
