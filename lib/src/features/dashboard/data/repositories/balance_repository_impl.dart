import 'dart:developer' as developer;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/auth/providers/user_session_provider.dart';
import '../../domain/entities/balance.dart';
import '../../domain/entities/top_category.dart';
import '../../domain/repositories/balance_repository.dart';
import '../datasources/firebase_balance_datasource.dart';

part 'balance_repository_impl.g.dart';

class BalanceRepositoryImpl implements BalanceRepository {
  final FirebaseBalanceDataSource dataSource;
  final String userId;

  BalanceRepositoryImpl({required this.dataSource, required this.userId});

  @override
  Future<Balance> getBalance() async {
    developer.log('Getting balance for userId: $userId',
        name: 'balance_repository');
    try {
      final balance = await dataSource.getMonthlyBalance(userId);
      developer.log('Successfully retrieved balance',
          name: 'balance_repository');
      return balance;
    } catch (e, stack) {
      developer.log('Error getting balance: $e',
          name: 'balance_repository', error: e, stackTrace: stack);

      // Log fallback to mock data
      developer.log('Fallback to mock data', name: 'balance_repository');

      // Fallback to mock data in case of error during development
      return Balance(
        monthlyIncome: 0, // Using more realistic data for debugging
        extraIncome: 0,
        totalIncome: 0,
        expenses: 0,
        totalBalance: 0,
        currency: 'Gs.',
        month: DateTime.now().month,
        year: DateTime.now().year,
      );
    }
  }

  @override
  Future<List<TopCategory>> getTopCategories({int? limit}) async {
    developer.log(
        'Getting top categories for userId: $userId with limit: $limit',
        name: 'balance_repository');
    try {
      final categories =
          await dataSource.getTopCategories(userId, limit: limit);
      developer.log('Successfully retrieved ${categories.length} categories',
          name: 'balance_repository');
      return categories;
    } catch (e, stack) {
      developer.log('Error getting categories: $e',
          name: 'balance_repository', error: e, stackTrace: stack);

      // Log fallback to mock data
      developer.log('Fallback to mock data for categories',
          name: 'balance_repository');

      // Fallback to mock data in case of error during development
      return [
        TopCategory(
          id: 1,
          name: 'Supermercado',
          emoji: '🛒',
          amount: 1450000,
          percentage: 35.0,
          expenseCount: 12,
        ),
        TopCategory(
          id: 2,
          name: 'Restaurantes',
          emoji: '🍔',
          amount: 850000,
          percentage: 20.5,
          expenseCount: 8,
        ),
        TopCategory(
          id: 3,
          name: 'Transporte',
          emoji: '🚗',
          amount: 650000,
          percentage: 15.7,
          expenseCount: 15,
        ),
      ];
    }
  }
}

@Riverpod(keepAlive: true)
BalanceRepository balanceRepositoryImpl(BalanceRepositoryImplRef ref) {
  final dataSource = ref.watch(balanceDataSourceProvider);
  final userSession = ref.watch(userSessionNotifierProvider);

  return BalanceRepositoryImpl(
      dataSource: dataSource, userId: userSession.userId);
}
