import 'dart:developer' as developer;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/styles/app_styles.dart';
import '../../../../core/auth/providers/user_session_provider.dart';
import '../../../dashboard/domain/entities/top_category.dart';
import '../../../dashboard/presentation/controllers/categories_controller.dart';
import '../../data/datasources/firebase_category_datasource.dart';
import '../widgets/category_list_item.dart';
import '../widgets/add_category_modal.dart';

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

          // Use the new dedicated widget for each item
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: DismissibleCategoryItem(
              category: category,
              onDeleted: _refreshCategoriesList,
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

  // Show success message using SnackBar
  void _showSuccessMessage(BuildContext context, String message) {
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

  // Show error message using SnackBar
  void _showErrorMessage(BuildContext context, String message) {
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

// New dedicated widget that handles its own dismissal state
class DismissibleCategoryItem extends StatefulWidget {
  final TopCategory category;
  final VoidCallback onDeleted;

  const DismissibleCategoryItem({
    Key? key,
    required this.category,
    required this.onDeleted,
  }) : super(key: key);

  @override
  State<DismissibleCategoryItem> createState() =>
      _DismissibleCategoryItemState();
}

class _DismissibleCategoryItemState extends State<DismissibleCategoryItem> {
  // Local state to track if this item has been dismissed
  bool _isDismissed = false;
  bool _isDeleting = false;
  bool _isRestoring = false; // New flag for tracking restoration

  @override
  Widget build(BuildContext context) {
    // If already dismissed and not being restored, don't show anything
    if (_isDismissed && !_isRestoring) {
      return const SizedBox.shrink();
    }

    // If being restored, show with a different background to indicate restoration
    if (_isRestoring) {
      return _buildRestoringItem();
    }

    return Dismissible(
      key: ValueKey(
          'category-${widget.category.id}-${identityHashCode(widget)}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        if (_isDeleting) return false;

        // Show confirmation dialog
        return await showDialog<bool>(
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
      },
      onDismissed: (direction) {
        // Mark as dismissed immediately to remove from tree - optimistic update
        setState(() {
          _isDismissed = true;
          _isDeleting = true;
        });

        // Process deletion in the background
        _deleteCategory();
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red[100]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Eliminar',
              style: TextStyle(
                color: Colors.red[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      child: CategoryListItem(
        topCategory: widget.category,
        onTap: () {
          // Navigate to category transactions
          developer.log(
            'Navigating to category transactions: ${widget.category.name}',
            name: 'dismissible_category_item',
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

  // New widget to show when a category is being restored
  Widget _buildRestoringItem() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.yellow[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber),
      ),
      child: Column(
        children: [
          CategoryListItem(
            topCategory: widget.category,
            onTap: () {
              // Disable navigation while restoring
              _showInfoMessage('Restaurando categoría...');
            },
          ),
          Container(
            color: Colors.amber.withOpacity(0.2),
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            child: Row(
              children: [
                const Icon(Icons.refresh, size: 16, color: Colors.amber),
                const SizedBox(width: 8),
                const Text(
                  'Restaurando categoría...',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.amber,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.amber[700]!),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Method to handle category deletion with API
  Future<void> _deleteCategory() async {
    try {
      final ref = ProviderScope.containerOf(context);

      // Get userId from session
      final userSession = ref.read(userSessionNotifierProvider);
      final userId = userSession.userId;

      if (userId == null) {
        _showErrorMessage('No se pudo obtener el ID de usuario');
        _restoreCategory(); // Restore on error
        return;
      }

      // Call the API
      final categoryDataSource = ref.read(categoryDataSourceProvider);
      final success =
          await categoryDataSource.deleteCategory(widget.category.id, userId);

      if (mounted) {
        if (success) {
          _showSuccessMessage(
              'Categoría ${widget.category.name} eliminada correctamente');
          // Notify parent about successful deletion to refresh data from server
          widget.onDeleted();
        } else {
          _showErrorMessage('No se pudo eliminar la categoría');
          _restoreCategory(); // Restore on failure
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Error al eliminar la categoría: ${e.toString()}');
        _restoreCategory(); // Restore on exception
      }

      developer.log('Error deleting category: $e',
          name: 'dismissible_category_item', error: e);
    }
  }

  // New method to restore the category if delete fails
  void _restoreCategory() {
    if (!mounted) return;

    setState(() {
      _isRestoring = true;
      _isDismissed = false;
    });

    // Animate the restoration with a brief delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isRestoring = false;
          _isDeleting = false;
        });
        widget.onDeleted(); // Refresh the parent list
      }
    });
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

  // New method for info messages
  void _showInfoMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.amber,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
