import 'dart:developer' as developer;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/top_category.dart';
import '../../domain/repositories/balance_repository.dart';

part 'categories_controller.g.dart';

@riverpod
class CategoriesController extends _$CategoriesController {
  @override
  Future<List<TopCategory>> build() async {
    developer.log('CategoriesController build called',
        name: 'categories_controller');
    return _fetchTopCategories();
  }

  Future<List<TopCategory>> _fetchTopCategories() async {
    developer.log('Fetching top categories data',
        name: 'categories_controller');
    final repository = ref.watch(balanceRepositoryProvider);
    try {
      final categories = await repository.getTopCategories();
      developer.log('Categories fetched successfully: ${categories.length}',
          name: 'categories_controller');
      return categories;
    } catch (e, stack) {
      developer.log('Error fetching categories: $e',
          name: 'categories_controller', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> refreshCategories() async {
    developer.log('Manual refresh triggered', name: 'categories_controller');
    state = const AsyncValue.loading();
    try {
      final categories = await _fetchTopCategories();
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
