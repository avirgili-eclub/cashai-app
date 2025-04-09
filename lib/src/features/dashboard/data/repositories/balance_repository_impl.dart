import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/balance.dart';
import '../../domain/repositories/balance_repository.dart';

part 'balance_repository_impl.g.dart'; // Fix: This should point to the same directory

class BalanceRepositoryImpl implements BalanceRepository {
  @override
  Future<Balance> getBalance() async {
    // In a real app, this would fetch data from a data source
    // For now, return mock data
    await Future.delayed(const Duration(seconds: 1));
    return Balance(
      total: 8562710,
      income: 9710300,
      expenses: 4147590,
    );
  }
}

@Riverpod(keepAlive: true)
BalanceRepository balanceRepositoryImpl(BalanceRepositoryImplRef ref) {
  return BalanceRepositoryImpl();
}
