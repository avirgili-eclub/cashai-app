import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Add this import
import '../../../../core/utils/emoji_formatter.dart';
import '../../../../core/utils/color_utils.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/presentation/widgets/money_text.dart';
import '../../domain/entities/top_category.dart';
import '../controllers/categories_controller.dart';

class CategoriesSection extends ConsumerWidget {
  const CategoriesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    developer.log('Building CategoriesSection widget',
        name: 'categories_section');
    final categoriesAsync = ref.watch(categoriesControllerProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Categorías Principales',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Use pushNamed instead of goNamed to maintain navigation history
                  context.pushNamed('categories');
                },
                child: const Text(
                  'Ver Todo',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildCategoriesContent(context, categoriesAsync),
        ],
      ),
    );
  }

  Widget _buildCategoriesContent(
      BuildContext context, AsyncValue<List<TopCategory>> categoriesAsync) {
    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No hay categorías para mostrar'),
            ),
          );
        }
        return Column(
          children: categories
              .map((category) => _buildCategoryItem(context, category))
              .toList(),
        );
      },
      loading: () => const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) {
        developer.log('Error in categories data: $error',
            name: 'categories_section', error: error, stackTrace: stack);
        return SizedBox(
          height: 100,
          child: Center(
            child: Text(
              'Error cargando categorías: ${error.toString()}',
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryItem(BuildContext context, TopCategory category) {
    // Use the EmojiFormatter utility class to handle emoji formatting
    Widget emojiWidget = EmojiFormatter.emojiToWidget(
      category.emoji,
      fallbackIcon: Icons.category,
      fallbackColor: Colors.blue,
      loggerName: 'categories_section',
    );

    // Parse the color from the hex string or use a default pastel blue
    final Color containerColor = ColorUtils.fromHex(
      category.color,
      defaultColor: const Color(0xFFBBDEFB), // Light pastel blue
      loggerName: 'categories_section',
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: containerColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: emojiWidget),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(value: category.percentage / 100),
                const SizedBox(height: 4),
                Text(
                  '${category.expenseCount} gastos · ${category.percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          MoneyText(
            amount: category.amount,
            currency: 'Gs.',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
            isExpense: true,
            useColors: true, // Changed from false to true to enable colors
          ),
        ],
      ),
    );
  }
}
