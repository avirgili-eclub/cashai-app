import 'dart:developer' as developer;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/balance.dart';
import '../../domain/repositories/balance_repository.dart';
import '../../../../core/auth/providers/user_session_provider.dart';
import '../../../../routing/app_router.dart';

part 'balance_controller.g.dart';

@riverpod
class BalanceController extends _$BalanceController {
  @override
  Future<Balance> build() async {
    developer.log('BalanceController build called', name: 'balance_controller');
    return _fetchBalance();
  }

  Future<Balance> _fetchBalance() async {
    developer.log('Fetching balance data', name: 'balance_controller');

    // Check for valid user ID first
    final userSession = ref.read(userSessionNotifierProvider);
    if (userSession.userId == null || userSession.isEmpty) {
      developer.log('No authenticated user found, cannot fetch balance',
          name: 'balance_controller');

      // Trigger navigation to sign-in page using the router
      Future.microtask(() {
        final router = ref.read(goRouterProvider);
        router.go('/signIn');
      });

      // Return a special "unauthenticated" balance
      return Balance(
        monthlyIncome: 0.0,
        extraIncome: 0.0,
        totalIncome: 0.0,
        expenses: 0.0,
        totalBalance: 0.0,
        currency: 'Gs.',
        month: DateTime.now().month,
        year: DateTime.now().year,
        isAuthenticationRequired: true, // Set flag to true
      );
    }

    final repository = ref.watch(balanceRepositoryProvider);
    try {
      // Use the authenticated endpoint when user has a token
      if (userSession.token != null && userSession.token!.isNotEmpty) {
        developer.log('Using authenticated balance endpoint',
            name: 'balance_controller');
        final balance = await repository.getAuthenticatedBalance();
        developer.log(
            'Authenticated balance fetched successfully: ${balance.totalBalance}',
            name: 'balance_controller');
        return balance;
      }

      // Fallback to the original endpoint
      final balance = await repository.getBalance();
      developer.log('Balance fetched successfully: ${balance.totalBalance}',
          name: 'balance_controller');
      return balance;
    } catch (e, stack) {
      developer.log('Error fetching balance: $e',
          name: 'balance_controller', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> refreshBalance() async {
    developer.log('Manual refresh triggered', name: 'balance_controller');
    state = const AsyncValue.loading();
    try {
      final balance = await _fetchBalance();
      developer.log('Balance refreshed successfully',
          name: 'balance_controller');
      state = AsyncValue.data(balance);
    } catch (e, st) {
      developer.log('Refresh failed',
          name: 'balance_controller', error: e, stackTrace: st);
      state = AsyncValue.error(e, st);
    }
  }
}
