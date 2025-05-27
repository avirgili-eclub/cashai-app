import 'dart:developer' as developer;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../domain/models/category_stat.dart';
import '../controllers/category_distribution_controller.dart';
import '../../../../core/utils/emoji_formatter.dart';
import '../../../../core/utils/error_parser.dart';
import '../../../../core/styles/app_styles.dart';
import '../../../../core/presentation/widgets/money_text.dart';
import '../../../../core/utils/money_formatter.dart'; // Use MoneyFormatter instead of CurrencyFormatter
import '../../../dashboard/data/mock/stats_mock_data.dart';

class CategoryDistributionChart extends ConsumerStatefulWidget {
  final String? timeRange;

  const CategoryDistributionChart({
    Key? key,
    this.timeRange,
  }) : super(key: key);

  @override
  ConsumerState<CategoryDistributionChart> createState() =>
      _CategoryDistributionChartState();
}

class _CategoryDistributionChartState
    extends ConsumerState<CategoryDistributionChart> {
  // Track the selected category index
  final ValueNotifier<int?> _selectedIndex = ValueNotifier<int?>(null);
  // Timer for auto-dismissing the tooltip
  Timer? _autoHideTimer;

  @override
  void dispose() {
    _selectedIndex.dispose();
    _autoHideTimer?.cancel();
    super.dispose();
  }

  // Start auto-hide timer for the tooltip
  void _startAutoHideTimer() {
    _autoHideTimer?.cancel();
    _autoHideTimer = Timer(const Duration(seconds: 8), () {
      _selectedIndex.value = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    developer.log(
        'Building CategoryDistributionChart with timeRange: ${widget.timeRange}',
        name: 'category_distribution_chart');

    final categoriesAsync = ref.watch(
        categoryDistributionControllerProvider(timeRange: widget.timeRange));

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
    return SingleChildScrollView(
      // Make the whole content scrollable to prevent overflow
      child: Column(
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
          _buildPieChart(context, categories),
          const SizedBox(height: 16),
          _buildCategoryLegends(categories),
        ],
      ),
    );
  }

  // Pass BuildContext to the pie chart
  Widget _buildPieChart(BuildContext context, List<CategoryStat> categories) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min, // Use minimum required space
        children: [
          // Add a container to show detailed info when a category is selected
          ValueListenableBuilder<int?>(
            valueListenable: _selectedIndex,
            builder: (context, index, _) {
              if (index == null || index < 0 || index >= categories.length) {
                return const SizedBox(height: 0);
              }

              final category = categories[index];

              // Use totalAmount from the model instead of calculating it here
              final totalAmount = category.totalAmount > 0
                  ? category.totalAmount
                  : categories.fold(0.0, (sum, cat) => sum + cat.amount);

              // Start auto-hide timer when tooltip is shown
              _startAutoHideTimer();

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: category.getColorObject().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: category.getColorObject().withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Stack(
                  children: [
                    // Close button in the top-right corner
                    Positioned(
                      top: -8,
                      right: -8,
                      child: IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 2,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        onPressed: () {
                          _autoHideTimer?.cancel();
                          _selectedIndex.value = null;
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        iconSize: 20,
                        splashRadius: 20,
                      ),
                    ),

                    // Content
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Category emoji and color indicator
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color:
                                    category.getColorObject().withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: EmojiFormatter.emojiToWidget(
                                  category.emoji,
                                  fontSize: 24,
                                  fallbackIcon: Icons.category,
                                  fallbackColor: category.getColorObject(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Category details - expanded to take available space
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${category.percentage.toStringAsFixed(1)}% de tus gastos',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Show amount and transaction count in a separate row
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Show total amount using MoneyText for proper formatting
                            if (totalAmount > 0)
                              Row(
                                children: [
                                  Text(
                                    'Total: ',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  // Use MoneyText with proper currency
                                  MoneyText(
                                    amount: totalAmount,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                    useColors: false,
                                  ),
                                ],
                              ),

                            // Amount and transaction count
                            Row(
                              children: [
                                Text(
                                  '${category.transactionCount} ${category.transactionCount == 1 ? 'transacción' : 'transacciones'}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Use MoneyText instead of custom formatting with CLP
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          // The pie chart with fixed height to avoid layout issues
          SizedBox(
            height: 240,
            child: PieChart(
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
                    // Handle tap events to show detailed information
                    if (event is! FlTapUpEvent) return;
                    if (pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      // If tapped outside any section, clear the selection
                      _selectedIndex.value = null;
                      return;
                    }

                    final touchedIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                    if (touchedIndex < 0 || touchedIndex >= categories.length)
                      return;

                    // Update the selected index to show details
                    _selectedIndex.value = touchedIndex;

                    // Cancel any previous timer
                    _autoHideTimer?.cancel();

                    // Start auto-hide timer
                    _startAutoHideTimer();

                    // Add haptic feedback for better UX
                    HapticFeedback.lightImpact();

                    // Log for debugging
                    developer.log(
                        'Tapped on category: ${categories[touchedIndex].name} (${MoneyFormatter.formatAmount(categories[touchedIndex].amount)})',
                        name: 'category_distribution_chart');
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryLegends(List<CategoryStat> categories) {
    return SizedBox(
      width: double.infinity, // Make sure it takes full width
      child: Wrap(
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
      ),
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
