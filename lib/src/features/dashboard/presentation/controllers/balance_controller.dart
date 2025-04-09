import 'dart:developer' as developer;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/balance.dart';
import '../../domain/repositories/balance_repository.dart';

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
    final repository = ref.watch(balanceRepositoryProvider);
    try {
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
