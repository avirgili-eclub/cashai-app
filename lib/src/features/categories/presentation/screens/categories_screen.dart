import 'dart:developer' as developer;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../../core/styles/app_styles.dart';
import '../../../../core/auth/providers/user_session_provider.dart';
import '../../../dashboard/domain/entities/top_category.dart';
import '../../../dashboard/presentation/controllers/categories_controller.dart';
import '../../data/datasources/firebase_category_datasource.dart';
import '../widgets/category_list_item.dart';
import '../widgets/add_category_modal.dart';
import '../widgets/edit_category_modal.dart';
import '../../domain/repositories/category_repository.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  // Simplified state - no need to track dismissed items here
  List<TopCategory>? _categories;
  bool _isLoading = false;
  String? _error;
  Timer? _refreshDebounce; // Add timer for debouncing

  @override
  Widget build(BuildContext context) {
    developer.log('Building CategoriesScreen', name: 'categories_screen');

    final categoriesAsync = ref.watch(categoriesWithLimitProvider(limit: 0));

    if (_categories == null && !_isLoading && categoriesAsync is AsyncData) {
      // Add null safety with conditional cast and null check
      final asyncData = categoriesAsync.value;
      if (asyncData != null) {
        _categories = List<TopCategory>.from(asyncData.cast<TopCategory>());
      }
    }

    return PopScope(
      canPop: false,
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
                iconSize: 30, // Increased icon button size
                padding:
                    const EdgeInsets.all(8), // Added padding around the button
                icon: Container(
                  padding: const EdgeInsets.all(10), // Increased inner padding
                  decoration: BoxDecoration(
                    color: AppStyles.primaryColor.withOpacity(0.3),
                    border: Border.all(
                      color: AppStyles.primaryColor.withOpacity(0.5),
                      width: 1.5, // Slightly thicker border
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 24, // Increased icon size from 20 to 24
                  ),
                ),
                onPressed: () => _showAddCategoryModal(context, ref),
                tooltip: 'Añadir categoría',
              ),
              const SizedBox(width: 16), // Increased right spacing
            ],
          ),
          body: _buildBody(categoriesAsync),
        ),
      ),
    );
  }

  Widget _buildBody(AsyncValue<List<dynamic>> categoriesAsync) {
    if (_categories != null) {
      return _buildCategoriesFromLocalState();
    }

    return categoriesAsync.when(
      data: (categories) {
        // Add null check before casting
        if (categories != null) {
          return _buildCategoriesContent(categories.cast<TopCategory>());
        } else {
          // Handle null case
          return const Center(child: Text('No hay categorías disponibles'));
        }
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

  Widget _buildCategoriesFromLocalState() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }

    if (_categories!.isEmpty) {
      return const Center(child: Text('No hay categorías para mostrar'));
    }

    return _buildCategoriesContent(_categories!);
  }

  // Simplified list builder
  Widget _buildCategoriesContent(List<TopCategory> categoryList) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: categoryList.length,
        itemBuilder: (context, index) {
          final category = categoryList[index];

          // Use the new dedicated widget for each item with sliding actions
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: SlidableCategoryItem(
              category: category,
              onDeleted: _refreshCategoriesList,
              onEdited: _refreshCategoriesList,
            ),
          );
        },
      ),
    );
  }

  // Method to refresh categories from the API
  Future<void> _refreshCategoriesList() async {
    _refreshDebounce?.cancel();

    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Set up new refresh with delay to prevent multiple rapid refreshes
    _refreshDebounce = Timer(const Duration(milliseconds: 300), () async {
      try {
        ref.invalidate(categoriesWithLimitProvider(limit: 0));
        // Wait for data to be available
        final data =
            await ref.read(categoriesWithLimitProvider(limit: 0).future);

        if (mounted) {
          setState(() {
            _categories = List<TopCategory>.from(data.cast<TopCategory>());
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _error = e.toString();
            _isLoading = false;
          });

          developer.log('Error refreshing categories: $e',
              name: 'categories_screen', error: e);
        }
      }
    });
  }

  @override
  void dispose() {
    // Clean up timer when widget is disposed
    _refreshDebounce?.cancel();
    super.dispose();
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

  // Show add category modal
  void _showAddCategoryModal(BuildContext context, WidgetRef ref) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddCategoryModal(),
    );

    if (result == true) {
      _refreshCategoriesList();
    }
  }
}

// New widget that handles sliding actions for both edit and delete
class SlidableCategoryItem extends StatefulWidget {
  final TopCategory category;
  final VoidCallback onDeleted;
  final VoidCallback onEdited;

  const SlidableCategoryItem({
    Key? key,
    required this.category,
    required this.onDeleted,
    required this.onEdited,
  }) : super(key: key);

  @override
  State<SlidableCategoryItem> createState() => _SlidableCategoryItemState();
}

class _SlidableCategoryItemState extends State<SlidableCategoryItem> {
  bool _isDeleting = false;
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    // Use Slidable widget for sliding actions
    return Slidable(
      key: ValueKey('category-${widget.category.id}'),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          // Edit action
          CustomSlidableAction(
            onPressed: (_) => _showEditCategoryModal(context),
            backgroundColor: Colors.blue.shade100,
            foregroundColor: Colors.blue.shade800,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.edit_rounded,
                  color: Colors.blue.shade800,
                ),
                const SizedBox(height: 4),
                Text(
                  'Editar',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade800,
                  ),
                ),
              ],
            ),
          ),
          // Delete action
          CustomSlidableAction(
            onPressed: (_) => _confirmDelete(context),
            backgroundColor: Colors.red.shade100,
            foregroundColor: Colors.red.shade800,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.delete_rounded,
                  color: Colors.red.shade800,
                ),
                const SizedBox(height: 4),
                Text(
                  'Eliminar',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      child: CategoryListItem(
        topCategory: widget.category,
        onTap: () {
          // Navigate to category transactions
          developer.log(
            'Navigating to category transactions: ${widget.category.name}',
            name: 'slidable_category_item',
          );
          context.pushNamed(
            'categoryTransactions',
            pathParameters: {'id': widget.category.id.toString()},
            extra: widget.category, // Pass TopCategory as extra
          );
        },
      ),
    );
  }

  // Show edit category modal
  Future<void> _showEditCategoryModal(BuildContext context) async {
    if (_isEditing) return;

    setState(() {
      _isEditing = true;
    });

    try {
      final result = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => EditCategoryModal(
          category: widget.category,
        ),
      );

      if (result == true) {
        widget.onEdited();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isEditing = false;
        });
      }
    }
  }

  // Confirm delete dialog
  Future<void> _confirmDelete(BuildContext context) async {
    if (_isDeleting) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Eliminar categoría'),
          content: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              children: [
                const TextSpan(
                  text: '¿Estás seguro que deseas eliminar la categoría ',
                ),
                TextSpan(
                  text: widget.category.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text: '?\n\n',
                ),
                TextSpan(
                  text:
                      'Esta acción eliminará todos los registros asociados a esta categoría y no se puede deshacer.',
                  style: TextStyle(color: Colors.red[700]),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[700],
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('CANCELAR'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red[700],
                backgroundColor: Colors.red[50],
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('ELIMINAR'),
            ),
          ],
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
        );
      },
    );

    if (result == true) {
      await _deleteCategory();
    }
  }

  // Method to handle category deletion with API
  Future<void> _deleteCategory() async {
    if (!mounted) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      final ref = ProviderScope.containerOf(context);

      // Use the repository pattern
      final repository = ref.read(categoryRepositoryProvider);

      final success = await repository.deleteCategory(widget.category.id);

      if (mounted) {
        if (success) {
          _showSuccessMessage(
              'Categoría ${widget.category.name} eliminada correctamente');
          widget.onDeleted();
        } else {
          _showErrorMessage('No se pudo eliminar la categoría');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Error al eliminar la categoría: ${e.toString()}');
      }

      developer.log('Error deleting category: $e',
          name: 'slidable_category_item', error: e);
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
