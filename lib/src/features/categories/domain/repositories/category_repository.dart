import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/category_repository_impl.dart';
import '../models/custom_category_request.dart';

part 'category_repository.g.dart';

abstract class CategoryRepository {
  /// Creates a new custom category
  Future<Map<String, dynamic>> createCategory(CustomCategoryRequest request);

  /// Updates an existing category by ID
  Future<Map<String, dynamic>> updateCategory(
      int categoryId, Map<String, dynamic> updates);

  /// Deletes a category by ID
  Future<bool> deleteCategory(int categoryId);
}

@riverpod
CategoryRepository categoryRepository(CategoryRepositoryRef ref) {
  return CategoryRepositoryImpl(ref);
}
