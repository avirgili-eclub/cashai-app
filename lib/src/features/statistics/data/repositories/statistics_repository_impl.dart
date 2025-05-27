import 'dart:developer' as developer;
import 'package:riverpod/riverpod.dart';

import '../../../../core/auth/providers/user_session_provider.dart';
import '../../domain/models/category_stat.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../datasources/statistics_datasource.dart';

class StatisticsRepositoryImpl implements StatisticsRepository {
  final Ref _ref;

  StatisticsRepositoryImpl(this._ref);

  @override
  Future<List<CategoryStat>> getCategoryDistribution({
    String? timeRange,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final dataSource = _ref.read(statisticsDataSourceProvider);
      final userSession = _ref.read(userSessionNotifierProvider);

      if (userSession.userId == null || userSession.userId!.isEmpty) {
        throw Exception('No authenticated user found');
      }

      return await dataSource.getCategoryDistribution(
        timeRange: timeRange,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e, stack) {
      developer.log('Error getting category distribution: $e',
          name: 'statistics_repository', error: e, stackTrace: stack);
      rethrow;
    }
  }
}
