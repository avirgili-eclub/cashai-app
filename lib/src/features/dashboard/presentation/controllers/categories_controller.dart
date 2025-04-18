import 'dart:developer' as developer;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/top_category.dart';
import '../../domain/repositories/balance_repository.dart';

part 'categories_controller.g.dart';

// Create a separate family provider for categories with limit
@riverpod
Future<List<TopCategory>> categoriesWithLimit(CategoriesWithLimitRef ref,
    {required int? limit}) async {
  developer.log('Fetching categories with limit: $limit',
      name: 'categories_controller');
  final repository = ref.watch(balanceRepositoryProvider);
  try {
    final categories = await repository.getTopCategories(limit: limit);
    developer.log(
        'categoriesWithLimit fetched successfully: ${categories.length}',
        name: 'categories_controller');
    return categories;
  } catch (e, stack) {
    developer.log('Error fetching categories: $e',
        name: 'categories_controller', error: e, stackTrace: stack);
    rethrow;
  }
}

@riverpod
class CategoriesController extends _$CategoriesController {
  @override
  Future<List<TopCategory>> build() async {
    developer.log('CategoriesController build called',
        name: 'categories_controller');
    return _fetchTopCategories();
  }

  Future<List<TopCategory>> _fetchTopCategories({int? limit}) async {
    developer.log('Fetching top categories data with limit: $limit',
        name: 'categories_controller');
    final repository = ref.watch(balanceRepositoryProvider);
    try {
      final categories = await repository.getTopCategories(limit: limit);
      developer.log('Categories fetched successfully: ${categories.length}',
          name: 'categories_controller');
      return categories;
    } catch (e, stack) {
      developer.log('Error fetching categories: $e',
          name: 'categories_controller', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> refreshCategories({int? limit}) async {
    developer.log('Manual refresh triggered', name: 'categories_controller');
    state = const AsyncValue.loading();
    try {
      final categories = await _fetchTopCategories(limit: limit);
      developer.log('Categories refreshed successfully',
          name: 'categories_controller');
      state = AsyncValue.data(categories);
    } catch (e, st) {
      developer.log('Refresh failed',
          name: 'categories_controller', error: e, stackTrace: st);
      state = AsyncValue.error(e, st);
    }
  }
}
