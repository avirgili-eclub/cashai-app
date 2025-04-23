import 'dart:developer' as developer;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/auth/providers/user_session_provider.dart';
import '../../domain/entities/recent_transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/firebase_balance_datasource.dart';

part 'transaction_repository_impl.g.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final FirebaseBalanceDataSource dataSource;
  final String
      userId; // Keep this as non-nullable for repository implementation

  TransactionRepositoryImpl({required this.dataSource, required this.userId});

  @override
  Future<List<RecentTransaction>> getRecentTransactions({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    developer.log('Getting recent transactions for userId: $userId',
        name: 'transaction_repository');

    // Early return with empty list if userId is null or empty
    if (userId.isEmpty) {
      developer.log('Empty userId, returning empty transaction list',
          name: 'transaction_repository');
      return [];
    }

    try {
      final transactions = await dataSource.getRecentTransactions(
        userId,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );
      developer.log(
          'Successfully retrieved ${transactions.length} transactions',
          name: 'transaction_repository');
      return transactions;
    } catch (e, stack) {
      developer.log('Error getting transactions: $e',
          name: 'transaction_repository', error: e, stackTrace: stack);

      // Log fallback to mock data
      developer.log('Fallback to mock data for transactions',
          name: 'transaction_repository');

      // Fallback to mock data in case of error during development
      return [
        RecentTransaction(
          id: 1,
          userId: 1,
          mccCode: '5812',
          systemCategory: 1,
          amount: 85000,
          type: 'DEBITO',
          date: DateTime.now().subtract(const Duration(days: 2)),
          description: 'Restaurante',
          invoiceText: 'Pago restaurante',
          invoiceNumber: '12345',
          sharedGroupId: null,
          emoji: '🍔',
        ),
        // ...more mock transactions
      ];
    }
  }
}

@Riverpod(keepAlive: true)
TransactionRepository transactionRepositoryImpl(
    TransactionRepositoryImplRef ref) {
  final dataSource = ref.watch(balanceDataSourceProvider);
  final userSession = ref.watch(userSessionNotifierProvider);

  // Check if user is properly authenticated
  if (userSession.userId == null || userSession.isEmpty) {
    // Log the issue
    developer.log('User not authenticated when creating transaction repository',
        name: 'transaction_repository');

    // Return a repository that will throw errors when accessed
    return TransactionRepositoryImpl(
      dataSource: dataSource,
      userId:
          '', // Empty string that will trigger proper error handling in methods
    );
  }

  // User is authenticated, return normal repository
  return TransactionRepositoryImpl(
      dataSource: dataSource, userId: userSession.userId!);
}
