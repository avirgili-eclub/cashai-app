import 'dart:developer' as developer;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/models/category_stat.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../../../../core/auth/providers/user_session_provider.dart';
import '../../../../routing/app_router.dart';

part 'category_distribution_controller.g.dart';

@riverpod
class CategoryDistributionController extends _$CategoryDistributionController {
  @override
  Future<List<CategoryStat>> build({String? timeRange}) async {
    developer.log(
        'Building CategoryDistributionController with timeRange: $timeRange',
        name: 'category_distribution_controller');

    // Default time range is 'month' if not provided
    final selectedTimeRange = timeRange ?? 'month';

    return _fetchCategoryDistribution(timeRange: selectedTimeRange);
  }

  Future<List<CategoryStat>> _fetchCategoryDistribution({
    required String timeRange,
    String? startDate,
    String? endDate,
  }) async {
    developer.log('Fetching category distribution with timeRange: $timeRange',
        name: 'category_distribution_controller');

    // Check for valid user ID first
    final userSession = ref.read(userSessionNotifierProvider);
    if (userSession.userId == null || userSession.isEmpty) {
      developer.log(
          'No authenticated user found, cannot fetch category distribution',
          name: 'category_distribution_controller');

      // Trigger navigation to sign-in page using the router
      Future.microtask(() {
        final router = ref.read(goRouterProvider);
        router.go('/signIn');
      });

      // Return an empty list for unauthenticated users
      return [];
    }

    final repository = ref.read(statisticsRepositoryProvider);
    try {
      developer.log('Calling repository.getCategoryDistribution',
          name: 'category_distribution_controller');

      final categories = await repository.getCategoryDistribution(
        timeRange: timeRange,
        startDate: startDate,
        endDate: endDate,
      );

      developer.log(
          'Category distribution fetched successfully: ${categories.length}',
          name: 'category_distribution_controller');

      return categories;
    } catch (e, stack) {
      developer.log('Error fetching category distribution: $e',
          name: 'category_distribution_controller',
          error: e,
          stackTrace: stack);

      // Just pass the error through without adding another layer of exception
      rethrow;
    }
  }

  Future<void> refreshCategoryDistribution({
    String? timeRange,
    String? startDate,
    String? endDate,
  }) async {
    developer.log('Manual refresh of category distribution triggered',
        name: 'category_distribution_controller');

    state = const AsyncValue.loading();
    try {
      final selectedTimeRange = timeRange ?? 'month';
      final categories = await _fetchCategoryDistribution(
        timeRange: selectedTimeRange,
        startDate: startDate,
        endDate: endDate,
      );

      developer.log(
          'Category distribution refreshed successfully: ${categories.length} items',
          name: 'category_distribution_controller');

      state = AsyncValue.data(categories);
    } catch (e, st) {
      developer.log('Refresh failed: $e',
          name: 'category_distribution_controller', error: e, stackTrace: st);

      state = AsyncValue.error(e, st);
    }
  }
}
