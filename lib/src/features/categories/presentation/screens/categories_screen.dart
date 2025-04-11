import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/styles/app_styles.dart';
import '../../../dashboard/domain/entities/top_category.dart';
import '../../../dashboard/presentation/controllers/categories_controller.dart';
import '../widgets/category_list_item.dart';
import '../widgets/add_category_modal.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    developer.log('Building CategoriesScreen', name: 'categories_screen');

    // Use the new categoriesWithLimit provider instead
    final categoriesAsync = ref.watch(categoriesWithLimitProvider(limit: 0));

    return PopScope(
      canPop: false, // Handle back navigation manually
      onPopInvoked: (didPop) {
        if (!didPop) {
          _navigateBack(context);
        }
      },
      child: GestureDetector(
        // Add support for swipe from left edge to go back
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null &&
              details.primaryVelocity! > 300) {
            _navigateBack(context);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => _navigateBack(context),
            ),
            title: const Text('Mis Categorías'),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppStyles.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add,
                    color: AppStyles.primaryColor,
                    size: 20,
                  ),
                ),
                onPressed: () => _showAddCategoryModal(context),
              ),
            ],
          ),
          body: _buildCategoriesContent(context, categoriesAsync),
        ),
      ),
    );
  }

  // Safe navigation back method
  void _navigateBack(BuildContext context) {
    try {
      // Try to pop first
      if (Navigator.canPop(context)) {
        context.pop();
      } else {
        // If can't pop, go back to dashboard
        context.goNamed('dashboard');
      }
    } catch (e) {
      // If any error occurs, fallback to dashboard
      developer.log('Error when navigating back: $e',
          name: 'categories_screen', error: e);
      context.goNamed('dashboard');
    }
  }

  Widget _buildCategoriesContent(
      BuildContext context, AsyncValue<List<dynamic>> categoriesAsync) {
    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
          return const Center(
            child: Text('No hay categorías para mostrar'),
          );
        }

        // Use TopCategory objects directly
        final categoryList = categories.cast<TopCategory>();

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: categoryList.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: CategoryListItem(
                  topCategory: categoryList[index], // Pass TopCategory directly
                  onTap: () {
                    // Navigate to category transactions
                    final category = categoryList[index];
                    developer.log(
                        'Navigating to category transactions: ${category.name}',
                        name: 'categories_screen');
                    context.pushNamed(
                      'categoryTransactions',
                      pathParameters: {'id': category.id.toString()},
                      extra: category, // Pass TopCategory as extra
                    );
                  },
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) {
        developer.log('Error loading categories: $error',
            name: 'categories_screen', error: error, stackTrace: stack);
        return Center(
          child: Text('Error cargando categorías: ${error.toString()}'),
        );
      },
    );
  }

  void _showAddCategoryModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddCategoryModal(),
    );
  }
}
