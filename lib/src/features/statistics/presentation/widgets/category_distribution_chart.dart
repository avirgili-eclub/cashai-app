import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../domain/models/category_stat.dart';
import '../controllers/category_distribution_controller.dart';
import '../../../../core/utils/emoji_formatter.dart';
import '../../../dashboard/data/mock/stats_mock_data.dart'; // For fallback data
import '../../../../core/utils/error_parser.dart'; // Import utility for error parsing

class CategoryDistributionChart extends ConsumerWidget {
  final String? timeRange;

  const CategoryDistributionChart({
    Key? key,
    this.timeRange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    developer.log(
        'Building CategoryDistributionChart with timeRange: $timeRange',
        name: 'category_distribution_chart');

    final categoriesAsync =
        ref.watch(categoryDistributionControllerProvider(timeRange: timeRange));

    return categoriesAsync.when(
      data: (categories) {
        developer.log('Received ${categories.length} categories',
            name: 'category_distribution_chart');

        // Filter out categories with 0% percentage
        final nonZeroCategories =
            categories.where((cat) => cat.percentage > 0).toList();
        developer.log(
            'Filtered to ${nonZeroCategories.length} non-zero categories',
            name: 'category_distribution_chart');

        if (nonZeroCategories.isEmpty) {
          // If we have no non-zero categories, show a message
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32.0),
              child: Text(
                'No hay datos de categorías con gastos disponibles',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return _buildChart(context, nonZeroCategories);
      },
      loading: () => const SizedBox(
        height: 240,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) {
        developer.log('Error in CategoryDistributionChart: $error',
            name: 'category_distribution_chart',
            error: error,
            stackTrace: stack);

        // Extract the user-friendly message from the error
        final errorMessage = ErrorParser.extractUserFriendlyMessage(error);

        // Debug print to verify what message is being extracted
        developer.log('Extracted error message: $errorMessage',
            name: 'category_distribution_chart');

        // On error, also show mock data for development
        final mockCategories = StatsMockData.categoryDistribution
            .map((mockCat) => CategoryStat(
                  id: 0,
                  name: mockCat.name,
                  emoji: mockCat.emoji,
                  color:
                      '#${mockCat.color.value.toRadixString(16).substring(2)}',
                  amount: 0,
                  percentage: mockCat.percentage,
                  transactionCount: 0,
                ))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red.shade800),
              ),
            ),
            _buildChart(context, mockCategories, isMockData: true),
          ],
        );
      },
    );
  }

  // Pass BuildContext to the chart building method
  Widget _buildChart(BuildContext context, List<CategoryStat> categories,
      {bool isMockData = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isMockData)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: const Text(
              'Mostrando datos de ejemplo',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        SizedBox(
          height: 240,
          child: _buildPieChart(context, categories),
        ),
        const SizedBox(height: 16),
        _buildCategoryLegends(categories),
      ],
    );
  }

  // Pass BuildContext to the pie chart
  Widget _buildPieChart(BuildContext context, List<CategoryStat> categories) {
    return PieChart(
      PieChartData(
        sections: categories
            .map((category) => PieChartSectionData(
                  value: category.percentage,
                  color: category.getColorObject(),
                  title: '${category.percentage.toStringAsFixed(1)}%',
                  radius: 80,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ))
            .toList(),
        centerSpaceRadius: 40,
        sectionsSpace: 2,
        pieTouchData: PieTouchData(
          enabled: true,
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            // Fix: Use the BuildContext passed from the build method
            if (event is! FlTapUpEvent) return;
            if (pieTouchResponse == null ||
                pieTouchResponse.touchedSection == null) return;

            final touchedIndex =
                pieTouchResponse.touchedSection!.touchedSectionIndex;
            if (touchedIndex < 0 || touchedIndex >= categories.length) return;

            final category = categories[touchedIndex];

            // Use the context parameter passed to this method instead of trying to extract from event
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    EmojiFormatter.emojiToWidget(
                      category.emoji,
                      fontSize: 20,
                      fallbackIcon: Icons.category,
                      fallbackColor: category.getColorObject(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        category.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '\$${category.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                backgroundColor: category.getColorObject().withOpacity(0.9),
                margin: const EdgeInsets.all(8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );

            // Log for debugging
            developer.log('Tapped on category: ${category.name}',
                name: 'category_distribution_chart');
          },
        ),
      ),
    );
  }

  Widget _buildCategoryLegends(List<CategoryStat> categories) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 12,
      children: categories
          .map(
            (category) => _buildCategoryLegendItem(
              emoji: category.emoji,
              color: category.getColorObject(),
              percentage: category.percentage.toStringAsFixed(1),
              name: category.name,
              amount: category.amount,
            ),
          )
          .toList(),
    );
  }

  Widget _buildCategoryLegendItem({
    required String emoji,
    required Color color,
    required String percentage,
    required String name,
    required double amount,
  }) {
    return Tooltip(
      message: '$name - \$${amount.toStringAsFixed(2)}',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Use the EmojiFormatter for consistent emoji display
          EmojiFormatter.emojiToWidget(
            emoji,
            fontSize: 18,
            fallbackIcon: Icons.category,
            fallbackColor: color,
          ),
          const SizedBox(width: 4),
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '$percentage%',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
