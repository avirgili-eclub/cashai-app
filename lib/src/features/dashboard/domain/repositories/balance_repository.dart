import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../entities/balance.dart';
import '../entities/top_category.dart';
import '../../data/repositories/balance_repository_impl.dart';

part 'balance_repository.g.dart';

abstract class BalanceRepository {
  Future<Balance> getBalance();
  Future<List<TopCategory>> getTopCategories({int? limit});
}

@riverpod
BalanceRepository balanceRepository(BalanceRepositoryRef ref) {
  return ref.watch(balanceRepositoryImplProvider);
}
