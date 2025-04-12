import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/emoji_formatter.dart';
import '../../../../core/utils/color_utils.dart';
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
      child: Stack(
        children: [
          // Position the categories content at the top
          Padding(
            padding: const EdgeInsets.only(top: 0), // No padding at top
            child: _buildCategoriesContent(context, categoriesAsync),
          ),

          // Overlay the "Ver Todo" button at the top right
          Positioned(
            top: 0,
            right: 0,
            child: TextButton(
              onPressed: () {
                context.pushNamed('categories');
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero, // Remove default minimum size
                tapTargetSize:
                    MaterialTapTargetSize.shrinkWrap, // Tighten hit area
              ),
              child: const Text(
                'Ver Todo',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
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

        // Use SizedBox with fixed height and horizontal scrolling ListView
        return SizedBox(
          height: 130, // Fixed height for the horizontal list
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) =>
                _buildCategoryItem(context, categories[index]),
          ),
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

    return InkWell(
      onTap: () {
        developer.log(
            'Navigating to category transactions from dashboard: ${category.name}',
            name: 'categories_section');

        context.pushNamed(
          'categoryTransactions',
          pathParameters: {'id': category.id.toString()},
          extra: category,
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6.0),
        width: 100, // Fixed width for each item
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Category name at the top
            Text(
              category.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),

            // Percentage below category name
            Text(
              '${category.percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4),

            // Emoji with circular progress indicator
            Stack(
              alignment: Alignment.center,
              children: [
                // Circular progress indicator
                SizedBox(
                  height: 60,
                  width: 60,
                  child: CustomPaint(
                    painter: CircularProgressPainter(
                      percentage: category.percentage / 100,
                      color: containerColor,
                      backgroundColor: Colors.grey[200]!,
                    ),
                  ),
                ),

                // Emoji container
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: containerColor.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: emojiWidget),
                ),
              ],
            ),

            const SizedBox(height: 4),

            // Transaction count at the bottom center
            Text(
              '${category.expenseCount} gastos',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for circular progress indicator
class CircularProgressPainter extends CustomPainter {
  final double percentage;
  final Color color;
  final Color backgroundColor;

  CircularProgressPainter({
    required this.percentage,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 4.0;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius - strokeWidth / 2, backgroundPaint);

    // Draw progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Start from the bottom center (270 degrees), go clockwise
    const double startAngle = 3 * 3.14159 / 2; // 270 degrees in radians
    final sweepAngle = 2 * 3.14159 * percentage;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
