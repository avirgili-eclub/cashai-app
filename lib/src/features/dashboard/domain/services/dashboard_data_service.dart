import 'dart:developer' as developer;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/top_category.dart';
import '../../domain/entities/recent_transaction.dart';
import '../../domain/repositories/balance_repository.dart';
import '../../presentation/controllers/balance_controller.dart';
import '../../presentation/controllers/transaction_controller.dart';
import '../../presentation/controllers/categories_controller.dart';

part 'dashboard_data_service.g.dart';

/// A service that coordinates refreshing all dashboard data components
@riverpod
class DashboardDataService extends _$DashboardDataService {
  @override
  Future<void> build() async {
    // Initial build doesn't need to do anything
    return;
  }

  /// Refresh all dashboard data at once
  Future<void> refreshAllData() async {
    developer.log('Refreshing all dashboard data', name: 'dashboard_service');
    state = const AsyncValue.loading();

    try {
      // Use all controllers to refresh their data
      await Future.wait([
        ref.read(balanceControllerProvider.notifier).refreshBalance(),
        ref.read(transactionsControllerProvider.notifier).refreshTransactions(),
        ref.read(categoriesControllerProvider.notifier).refreshCategories(),
      ]);

      // Also invalidate the categories with limit provider
      ref.invalidate(categoriesWithLimitProvider);

      state = const AsyncValue.data(null);
      developer.log('All dashboard data refreshed successfully',
          name: 'dashboard_service');
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      developer.log('Error refreshing dashboard data',
          name: 'dashboard_service', error: e, stackTrace: st);
    }
  }
}

/// A provider that makes top categories depend on transactions
/// This will automatically refresh categories when transactions change
@riverpod
Future<List<TopCategory>> dependentTopCategories(DependentTopCategoriesRef ref,
    {int? limit}) async {
  // Watch transactions so this will rebuild when transactions change
  final _ = await ref.watch(transactionsControllerProvider.future);
  developer.log('Transactions changed, refreshing top categories',
      name: 'dashboard_service');

  final repository = ref.watch(balanceRepositoryProvider);
  return repository.getTopCategories(limit: limit);
}

/// A provider that combines transaction and category data for a complete dashboard state
@riverpod
Future<({List<RecentTransaction> transactions, List<TopCategory> categories})>
    dashboardData(DashboardDataRef ref) async {
  // This will cause the provider to refresh when either transactions or categories change
  final transactions = await ref.watch(transactionsControllerProvider.future);
  final categories =
      await ref.watch(dependentTopCategoriesProvider(limit: 5).future);

  return (transactions: transactions, categories: categories);
}
