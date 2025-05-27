import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/category_stat.dart';
import '../../data/repositories/statistics_repository_impl.dart';

part 'statistics_repository.g.dart';

abstract class StatisticsRepository {
  /// Fetches category distribution statistics
  Future<List<CategoryStat>> getCategoryDistribution({
    String? timeRange,
    String? startDate,
    String? endDate,
  });
}

@riverpod
StatisticsRepository statisticsRepository(StatisticsRepositoryRef ref) {
  return StatisticsRepositoryImpl(ref);
}
