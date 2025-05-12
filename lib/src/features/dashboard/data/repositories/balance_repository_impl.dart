import 'dart:developer' as developer;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/auth/providers/user_session_provider.dart';
import '../../domain/entities/balance.dart';
import '../../domain/entities/top_category.dart';
import '../../domain/repositories/balance_repository.dart';
import '../datasources/firebase_balance_datasource.dart';
import '../../../../features/user/data/datasources/firebase_user_profile_datasource.dart';

part 'balance_repository_impl.g.dart';

class BalanceRepositoryImpl implements BalanceRepository {
  final FirebaseBalanceDataSource dataSource;
  final FirebaseUserProfileDataSource userProfileDataSource;
  final String userId;
  final String token;

  BalanceRepositoryImpl({
    required this.dataSource,
    required this.userProfileDataSource,
    required this.userId,
    required this.token,
  });

  @override
  Future<Balance> getBalance() async {
    // Simply delegate to the authenticated method
    return getAuthenticatedBalance();
  }

  @override
  Future<Balance> getAuthenticatedBalance({int? month, int? year}) async {
    developer.log(
        'Getting authenticated balance with token: ${token.isNotEmpty ? "Valid Token" : "Empty Token"}',
        name: 'balance_repository');

    if (token.isEmpty) {
      developer.log('No authentication token available',
          name: 'balance_repository');
      throw Exception('No authentication token available');
    }

    try {
      final balance = await userProfileDataSource.getMonthlyBalance(
        token,
        month: month,
        year: year,
      );
      developer.log('Successfully retrieved authenticated balance',
          name: 'balance_repository');
      return balance;
    } catch (e, stack) {
      developer.log('Error getting authenticated balance: $e',
          name: 'balance_repository', error: e, stackTrace: stack);

      // Fallback to mock data in case of error during development
      developer.log('Fallback to mock data', name: 'balance_repository');
      return Balance(
        monthlyIncome: 0,
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
  final userProfileDataSource =
      ref.watch(userProfileDataSourceProvider); // Add this
  final userSession = ref.watch(userSessionNotifierProvider);

  // Check if user is properly authenticated
  if (userSession.userId == null || userSession.isEmpty) {
    // Log the issue
    developer.log('User not authenticated when creating balance repository',
        name: 'balance_repository');

    // Return a repository that will throw errors when accessed
    return BalanceRepositoryImpl(
      dataSource: dataSource,
      userProfileDataSource: userProfileDataSource, // Add this
      userId:
          '', // Empty string that will trigger proper error handling in methods
      token: '', // Empty token
    );
  }

  // User is authenticated, return normal repository
  return BalanceRepositoryImpl(
    dataSource: dataSource,
    userProfileDataSource: userProfileDataSource, // Add this
    userId: userSession.userId!,
    token: userSession.token ?? '', // Add token
  );
}
