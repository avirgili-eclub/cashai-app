import 'dart:developer' as developer;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/auth/providers/user_session_provider.dart';
import '../../../../features/dashboard/data/datasources/firebase_balance_datasource.dart';
import '../../domain/entities/transactions_by_category_dto.dart';

part 'category_transactions_controller.g.dart';

@riverpod
class CategoryTransactionsController extends _$CategoryTransactionsController {
  @override
  Future<TransactionsByCategoryDTO> build(String categoryId) async {
    developer.log('Building category transactions for categoryId: $categoryId',
        name: 'category_transactions_controller');

    return _fetchCategoryTransactions(categoryId);
  }

  Future<TransactionsByCategoryDTO> _fetchCategoryTransactions(
    String categoryId, {
    int? month,
    int? year,
  }) async {
    final userSession = ref.read(userSessionNotifierProvider);
    final dataSource = ref.read(balanceDataSourceProvider);

    if (userSession.userId == null || userSession.isEmpty) {
      developer.log('User not authenticated, cannot fetch transactions',
          name: 'category_transactions_controller');
      throw Exception("User not authenticated");
    }

    // Get current month and year if not provided
    final now = DateTime.now();
    final selectedMonth = month ?? now.month;
    final selectedYear = year ?? now.year;

    try {
      developer.log(
          'Fetching transactions for category: $categoryId, month: $selectedMonth, year: $selectedYear',
          name: 'category_transactions_controller');

      return await dataSource.getTransactionsByCategory(
        userSession.userId!,
        categoryId,
        month: selectedMonth,
        year: selectedYear,
      );
    } catch (e, stack) {
      developer.log('Error fetching category transactions: $e',
          name: 'category_transactions_controller',
          error: e,
          stackTrace: stack);
      rethrow;
    }
  }

  Future<void> refreshTransactions(
    String categoryId, {
    int? month,
    int? year,
  }) async {
    state = const AsyncValue.loading();

    try {
      final result = await _fetchCategoryTransactions(
        categoryId,
        month: month,
        year: year,
      );

      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
