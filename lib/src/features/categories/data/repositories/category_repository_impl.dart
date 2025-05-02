import 'dart:developer' as developer;
import 'package:riverpod/riverpod.dart';

import '../../../../core/auth/providers/user_session_provider.dart';
import '../../domain/models/custom_category_request.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/firebase_category_datasource.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final Ref _ref;

  CategoryRepositoryImpl(this._ref);

  @override
  Future<Map<String, dynamic>> createCategory(
      CustomCategoryRequest request) async {
    try {
      final dataSource = _ref.read(categoryDataSourceProvider);
      final userSession = _ref.read(userSessionNotifierProvider);

      if (userSession.userId == null || userSession.userId!.isEmpty) {
        throw Exception('No authenticated user found');
      }

      return await dataSource.createCustomCategory(
          request, userSession.userId!);
    } catch (e, stack) {
      developer.log('Error creating category: $e',
          name: 'category_repository', error: e, stackTrace: stack);
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> updateCategory(
      int categoryId, Map<String, dynamic> updates) async {
    try {
      final dataSource = _ref.read(categoryDataSourceProvider);
      final userSession = _ref.read(userSessionNotifierProvider);

      if (userSession.userId == null || userSession.userId!.isEmpty) {
        throw Exception('No authenticated user found');
      }

      return await dataSource.updateCategory(
          categoryId, updates, userSession.userId!);
    } catch (e, stack) {
      developer.log('Error updating category: $e',
          name: 'category_repository', error: e, stackTrace: stack);
      rethrow;
    }
  }

  @override
  Future<bool> deleteCategory(int categoryId) async {
    try {
      final dataSource = _ref.read(categoryDataSourceProvider);
      final userSession = _ref.read(userSessionNotifierProvider);

      if (userSession.userId == null || userSession.userId!.isEmpty) {
        throw Exception('No authenticated user found');
      }

      return await dataSource.deleteCategory(categoryId, userSession.userId!);
    } catch (e, stack) {
      developer.log('Error deleting category: $e',
          name: 'category_repository', error: e, stackTrace: stack);
      rethrow;
    }
  }
}
