import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Add this import for GoRouter navigation
import '../../../../core/styles/app_styles.dart';
import '../../../dashboard/domain/entities/category.dart';
import '../../../dashboard/presentation/controllers/categories_controller.dart';
import '../widgets/category_list_item.dart';
import '../widgets/add_category_modal.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    developer.log('Building CategoriesScreen', name: 'categories_screen');

    // We'll use a mock list for now, but this would come from a provider
    final categoriesAsync = ref.watch(categoriesControllerProvider);

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

        // Convert the data to a list of mock Category objects for display
        final mockCategories = _createMockCategories();

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: mockCategories.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: CategoryListItem(
                  category: mockCategories[index],
                  onTap: () {
                    // Navigate to category details
                    developer.log(
                        'Tapped on category: ${mockCategories[index].name}',
                        name: 'categories_screen');
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

  // Mock data for display
  List<Category> _createMockCategories() {
    return [
      Category(
        id: '1',
        name: 'Comida y Bebida',
        icon: '🍔',
        iconBgColor: '#E9D5FF', // Purple light
        amount: 743985,
        percentage: 35.0,
      ),
      Category(
        id: '2',
        name: 'Transporte',
        icon: '🚗',
        iconBgColor: '#DBEAFE', // Blue light
        amount: 510550,
        percentage: 25.0,
      ),
      Category(
        id: '3',
        name: 'Salario',
        icon: '💼',
        iconBgColor: '#D1FAE5', // Green light
        amount: 9562500,
        percentage: 0.0, // No percentage for income
      ),
      Category(
        id: '4',
        name: 'Entretenimiento',
        icon: '🎮',
        iconBgColor: '#D1FAE5', // Green light
        amount: 425000,
        percentage: 20.0,
      ),
      Category(
        id: '5',
        name: 'Salud',
        icon: '⚕️',
        iconBgColor: '#FEE2E2', // Red light
        amount: 320000,
        percentage: 15.0,
      ),
    ];
  }
}
