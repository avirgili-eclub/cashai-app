import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/styles/app_styles.dart';
import '../../../../core/auth/providers/user_session_provider.dart';
import '../../data/datasources/firebase_category_datasource.dart';
import '../../domain/models/custom_category_request.dart';

class AddCategoryModal extends ConsumerStatefulWidget {
  const AddCategoryModal({Key? key}) : super(key: key);

  @override
  ConsumerState<AddCategoryModal> createState() => _AddCategoryModalState();
}

class _AddCategoryModalState extends ConsumerState<AddCategoryModal> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedEmoji = '🍔'; // Default emoji
  String _selectedColor = '#FFD3B6'; // Default color (pastel orange)
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
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Helper method to convert hex to Color
  Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 7 || hexString.length == 9) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
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
                    'Nueva Categoría',
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

              // Description Input (Optional)
              const Text(
                'Descripción (Opcional)',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: 'ej., Para gastos de supermercado',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                maxLines: 2,
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

              // Create Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitCategory,
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
                          'Crear Categoría',
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

  Future<void> _submitCategory() async {
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
        'Creating new category: $name with emoji: $_selectedEmoji and color: $_selectedColor',
        name: 'add_category_modal');

    setState(() {
      _isLoading = true;
    });

    try {
      // Get the current user ID from UserSession
      final userSession = ref.read(userSessionNotifierProvider);
      final userId = userSession.userId;

      if (userId.isEmpty) {
        throw Exception("Usuario no autenticado");
      }

      // Create the request object
      final request = CustomCategoryRequest(
        name: name,
        emoji: _selectedEmoji,
        color: _selectedColor,
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
      );

      // Get the datasource
      final dataSource = ref.read(categoryDataSourceProvider);

      // Make the API call
      await dataSource.createCustomCategory(request, userId);

      // Close the modal on success
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Categoría creada exitosamente')),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      developer.log('Error creating category: $e',
          name: 'add_category_modal', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear categoría: $e')),
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
