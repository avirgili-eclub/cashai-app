import 'dart:developer' as developer;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/top_category.dart';
import '../../domain/repositories/balance_repository.dart';
import '../../../../core/auth/providers/user_session_provider.dart';
import '../../../../routing/app_router.dart';
import '../../../categories/domain/repositories/category_repository.dart';
import '../../../categories/data/datasources/firebase_category_datasource.dart';

part 'categories_controller.g.dart';

// Create a separate family provider for categories with limit
@riverpod
Future<List<TopCategory>> categoriesWithLimit(CategoriesWithLimitRef ref,
    {required int? limit}) async {
  developer.log('Fetching categories with limit: $limit',
      name: 'categories_controller');

  // Check for valid user ID first
  final userSession = ref.read(userSessionNotifierProvider);
  if (userSession.userId == null || userSession.isEmpty) {
    developer.log('No authenticated user found, cannot fetch categories',
        name: 'categories_controller');

    // Trigger navigation to sign-in page using the router
    Future.microtask(() {
      final router = ref.read(goRouterProvider);
      router.go('/signIn');
    });

    // Return an empty list for unauthenticated users
    return [];
  }

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

    // Check for valid user ID first
    final userSession = ref.read(userSessionNotifierProvider);
    if (userSession.userId == null || userSession.isEmpty) {
      developer.log('No authenticated user found, cannot fetch categories',
          name: 'categories_controller');

      // Trigger navigation to sign-in page using the router
      Future.microtask(() {
        final router = ref.read(goRouterProvider);
        router.go('/signIn');
      });

      // Return an empty list for unauthenticated users
      return [];
    }

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

  Future<bool> updateCategory(
    int categoryId, {
    String? name,
    String? emoji,
    String? color,
  }) async {
    developer.log(
        'Updating category: $categoryId with name: $name, emoji: $emoji, color: $color',
        name: 'categories_controller');

    try {
      // Use the new repository pattern instead of directly using dataSource
      final repository = ref.read(categoryRepositoryProvider);

      // Create the updates object with only the non-null fields
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (emoji != null) updates['emoji'] = emoji;
      if (color != null) updates['color'] = color;

      // No need to send update if there are no fields to update
      if (updates.isEmpty) {
        developer.log('No updates provided for category',
            name: 'categories_controller');
        return false;
      }

      final response = await repository.updateCategory(categoryId, updates);

      // Refresh categories after updating
      await refreshCategories();

      return response['success'] == true;
    } catch (e, stack) {
      developer.log('Error updating category: $e',
          name: 'categories_controller', error: e, stackTrace: stack);
      return false;
    }
  }
}
