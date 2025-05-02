import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/styles/app_styles.dart';
import '../../../../core/utils/color_utils.dart';
import '../../../dashboard/domain/entities/top_category.dart';
import '../../domain/repositories/category_repository.dart';

class EditCategoryModal extends ConsumerStatefulWidget {
  final TopCategory category;

  const EditCategoryModal({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  ConsumerState<EditCategoryModal> createState() => _EditCategoryModalState();
}

class _EditCategoryModalState extends ConsumerState<EditCategoryModal> {
  late TextEditingController _nameController;
  late String _selectedEmoji;
  late String _selectedColor;
  bool _isLoading = false;

  // Keep track of keyboard visibility to adjust UI
  bool _isKeyboardVisible = false;

  final List<String> _availableEmojis = [
    '🍔',
    '🚗',
    '🎉',
    '🏠',
    '💼',
    '🛒',
    '🎮',
    '📚',
    '✈️',
    '⚡',
    '👕',
    '💄',
    '🎭',
    '🎸',
    '🏋️',
    '🍕',
    '☕',
    '🎬',
    '💻',
    '📱'
  ];

  // Pastel color palette with hex codes
  final List<Map<String, String>> _colorPalette = [
    {'name': 'Pastel Pink', 'hex': '#FADADD'},
    {'name': 'Pastel Orange', 'hex': '#FFD3B6'},
    {'name': 'Pastel Yellow', 'hex': '#FFFACD'},
    {'name': 'Pastel Green', 'hex': '#BDFCC9'},
    {'name': 'Pastel Blue', 'hex': '#B6E3FF'},
    {'name': 'Pastel Purple', 'hex': '#D8BFD8'},
    {'name': 'Pastel Mint', 'hex': '#C9FFE5'},
    {'name': 'Pastel Coral', 'hex': '#FFB6B6'},
    {'name': 'Pastel Lilac', 'hex': '#D8C2FF'},
    {'name': 'Pastel Peach', 'hex': '#FFE5B4'},
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with the current category values, handling null cases
    _nameController = TextEditingController(text: widget.category.name);
    _selectedEmoji = widget.category.emoji ?? '🍔'; // Default emoji if null
    _selectedColor =
        widget.category.color ?? '#B6E3FF'; // Default color if null
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Helper method to convert hex to Color with robust error handling
  Color _hexToColor(String hexString) {
    try {
      return ColorUtils.fromHex(
        hexString,
        defaultColor: const Color(0xFFB6E3FF), // Light pastel blue as default
        loggerName: 'edit_category_modal',
      );
    } catch (e) {
      developer.log('Error converting hex to color: $e',
          name: 'edit_category_modal', error: e);
      // Fallback to a default color in case of any error
      return const Color(0xFFB6E3FF);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate bottom padding to account for keyboard
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    _isKeyboardVisible = bottomPadding > 0;

    return Container(
      // Set a fixed maximum height that fits well on most devices
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      // Make the entire modal scrollable
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Editar Categoría',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Category Name Input
              const Text(
                'Nombre de la Categoría',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'ej., Compras',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),

              // Emoji Selector - Conditionally show shorter size when keyboard is visible
              const Text(
                'Seleccionar Emoji',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                // Adjust height when keyboard is visible to save space
                constraints: BoxConstraints(
                  maxHeight: _isKeyboardVisible ? 120 : 200,
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  // Make emoji grid scrollable when keyboard is visible
                  physics: _isKeyboardVisible
                      ? const AlwaysScrollableScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    childAspectRatio: 1,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _availableEmojis.length,
                  itemBuilder: (context, index) {
                    final emoji = _availableEmojis[index];
                    final isSelected = emoji == _selectedEmoji;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedEmoji = emoji;
                        });
                        // Hide keyboard when selecting an emoji
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppStyles.primaryColor.withOpacity(0.1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? AppStyles.primaryColor
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Color Palette - Also with conditional sizing
              const Text(
                'Seleccionar Color',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                // Adjust height when keyboard is visible to save space
                constraints: BoxConstraints(
                  maxHeight: _isKeyboardVisible ? 120 : 200,
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  // Make color grid scrollable when keyboard is visible
                  physics: _isKeyboardVisible
                      ? const AlwaysScrollableScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    childAspectRatio: 1,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _colorPalette.length,
                  itemBuilder: (context, index) {
                    final color = _colorPalette[index];
                    final hexColor = color['hex'] as String;
                    final isSelected = hexColor == _selectedColor;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = hexColor;
                        });
                        // Hide keyboard when selecting a color
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _hexToColor(hexColor),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? Colors.black
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Update Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateCategory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyles.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          'Actualizar Categoría',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),
              // Add extra bottom padding to ensure the button is not covered
              SizedBox(height: _isKeyboardVisible ? 16 : 0),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateCategory() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      // Show error or validation message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor ingresa un nombre para la categoría')),
      );
      return;
    }

    developer.log(
        'Updating category: ${widget.category.id} - $name with emoji: $_selectedEmoji and color: $_selectedColor',
        name: 'edit_category_modal');

    setState(() {
      _isLoading = true;
    });

    try {
      // Create the updates map
      final updates = <String, dynamic>{
        'name': name,
        'emoji': _selectedEmoji,
        'color': _selectedColor,
      };

      // Use the repository pattern - ensure it exists
      final repository = ref.read(categoryRepositoryProvider);

      // Make sure we're passing the correct type for categoryId
      // Convert to int if the repository expects an int
      final categoryId = widget.category.id;

      // Call update through repository and check the result
      final result = await repository.updateCategory(categoryId, updates);

      final success = result['success'] == true;

      // Close the modal on success
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Categoría actualizada exitosamente')),
          );
          Navigator.pop(context, true); // Return true to indicate success
        } else {
          // Handle API reported failure
          final message = result['message'] as String? ??
              'No se pudo actualizar la categoría';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      }
    } catch (e) {
      developer.log('Error updating category: $e',
          name: 'edit_category_modal', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar categoría: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
