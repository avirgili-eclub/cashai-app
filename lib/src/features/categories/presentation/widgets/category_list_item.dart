import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/emoji_formatter.dart';
import '../../../../core/utils/color_utils.dart';
import '../../../../core/styles/app_styles.dart';
import '../../../../core/presentation/widgets/money_text.dart';
import '../../../dashboard/domain/entities/top_category.dart';

class CategoryListItem extends StatelessWidget {
  final TopCategory topCategory;
  final VoidCallback onTap;

  const CategoryListItem({
    Key? key,
    required this.topCategory,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use the EmojiFormatter utility class to handle emoji formatting
    Widget emojiWidget = EmojiFormatter.emojiToWidget(
      topCategory.emoji,
      fontSize: 24,
      fallbackIcon: Icons.category,
      fallbackColor: Colors.blue,
      loggerName: 'category_list_item',
    );

    // Parse the color from the hex string or use a default pastel blue
    final Color containerColor = ColorUtils.fromHex(
      topCategory.color,
      defaultColor: const Color(0xFFBBDEFB), // Light pastel blue
      loggerName: 'category_list_item',
    );

    // Determine if we should show the percentage circle
    final bool showPercentage = topCategory.percentage > 0;

    // Use real transaction count from TopCategory
    final String transactionsText =
        _getTransactionCountText(topCategory.expenseCount);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Category Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: containerColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(child: emojiWidget),
                ),
                const SizedBox(width: 12),

                // Category Name and Transaction Count
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topCategory.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        transactionsText,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Percentage and Arrow
                Row(
                  children: [
                    if (showPercentage)
                      Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: containerColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${topCategory.percentage.toInt()}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppStyles.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getTransactionCountText(int transactionCount) {
    if (transactionCount == 1) {
      return '1 transacción';
    } else {
      return '$transactionCount transacciones';
    }
  }
}
