import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/balance.dart';
import '../../domain/repositories/balance_repository.dart';

part 'balance_controller.g.dart';

@riverpod
class BalanceController extends _$BalanceController {
  @override
  Future<Balance> build() async {
    return _fetchBalance();
  }

  Future<Balance> _fetchBalance() async {
    final repository = ref.watch(balanceRepositoryProvider);
    return await repository.getBalance();
  }

  Future<void> refreshBalance() async {
    state = const AsyncValue.loading();
    try {
      final balance = await _fetchBalance();
      state = AsyncValue.data(balance);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
