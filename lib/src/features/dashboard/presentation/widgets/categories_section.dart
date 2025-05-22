import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/top_category.dart';
import '../../domain/services/dashboard_data_service.dart';
import '../../../../routing/app_router.dart';
import '../../../../core/utils/color_utils.dart';
import 'category_chip.dart';

class CategoriesSection extends ConsumerWidget {
  const CategoriesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    developer.log('Building CategoriesSection widget',
        name: 'categories_section');
    // Use the dependent categories provider instead of the controller directly
    // Limit to 3 categories instead of 5
    final categoriesAsync = ref.watch(dependentTopCategoriesProvider(limit: 3));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          categoriesAsync.when(
            data: (categories) {
              if (categories.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: Text(
                      'No hay categorías disponibles',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }

              // Calculate the sum of all percentages to determine what's left
              final totalPercentage = categories.fold<double>(
                  0, (sum, category) => sum + category.percentage);
              final remainingPercentage = 100.0 - totalPercentage;

              // Fixed item width and spacing for consistent layout
              const itemWidth = 100.0;
              const horizontalSpacing = 12.0;

              return SizedBox(
                height: 130,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length + 1, // +1 for "Ver Más" button
                  itemBuilder: (context, index) {
                    // If this is the last item, render the "Ver Más" button
                    if (index == categories.length) {
                      return Container(
                        width: itemWidth,
                        margin: EdgeInsets.only(
                          left: horizontalSpacing,
                          right: 16.0, // Add padding on the right edge
                        ),
                        child: _buildVerMasItem(context, remainingPercentage),
                      );
                    }

                    // For the first item, no left margin to align with the start
                    final leftMargin = index == 0 ? 0.0 : horizontalSpacing;

                    // Otherwise render a regular category
                    return Container(
                      width: itemWidth,
                      margin: EdgeInsets.only(left: leftMargin),
                      child: CategoryChip(
                        emoji: categories[index].emoji,
                        label: categories[index].name,
                        percentage: categories[index].percentage,
                        color: categories[index].color ?? "#BBDEFB",
                        expenseCount: categories[index].expenseCount ?? 0,
                        onTap: () {
                          context.pushNamed(
                            AppRoute.categoryTransactions.name,
                            pathParameters: {
                              'id': categories[index].id.toString(),
                            },
                            extra: categories[index],
                          );
                        },
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => SizedBox(
              height: 100,
              child: Center(
                child: Text(
                  'Error cargando categorías: ${error.toString()}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method to build the "Ver Más" button
  Widget _buildVerMasItem(BuildContext context, double remainingPercentage) {
    // Use a slightly different color to make it stand out
    final Color containerColor = Colors.blue.withOpacity(0.1);

    return InkWell(
      onTap: () {
        // Navigate to categories page
        context.pushNamed('categories');
      },
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Add similar text as in category items to maintain consistent spacing
          Text(
            'Ver todas',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
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
                    percentage: remainingPercentage / 100,
                    color: Colors.blue,
                    backgroundColor: Colors.grey[200]!,
                  ),
                ),
              ),

              // Icon container - properly centered without percentage
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: containerColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.grid_view_rounded,
                    color: Colors.blue,
                    size: 28, // Larger icon size to fill the space
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // "Ver Más" text - keep the same structure as CategoryChip
          const Text(
            'Ver Más',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Custom painter for circular progress indicator - moved from CategoryChip
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
