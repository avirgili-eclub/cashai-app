import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../entities/balance.dart';
import '../entities/top_category.dart';
import '../../data/repositories/balance_repository_impl.dart';

part 'balance_repository.g.dart';

abstract class BalanceRepository {
  /// Gets the current balance without specifying month/year
  /// This is a convenience method that calls getAuthenticatedBalance() with default parameters
  Future<Balance> getBalance();

  /// Gets the balance for a specific month and year using the authenticated endpoint
  /// If month and year are null, returns the current month's balance
  Future<Balance> getAuthenticatedBalance({int? month, int? year});

  /// Gets the top spending categories, optionally limited to a specific count
  Future<List<TopCategory>> getTopCategories({int? limit});
}

@riverpod
BalanceRepository balanceRepository(BalanceRepositoryRef ref) {
  return ref.watch(balanceRepositoryImplProvider);
}
