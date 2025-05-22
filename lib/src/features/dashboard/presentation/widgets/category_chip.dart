import 'package:flutter/material.dart';
import '../../../../core/utils/emoji_formatter.dart';
import '../../../../core/utils/color_utils.dart';

class CategoryChip extends StatelessWidget {
  final String emoji;
  final String label;
  final double percentage;
  final VoidCallback? onTap;
  final String color;
  final int expenseCount;

  const CategoryChip({
    Key? key,
    required this.emoji,
    required this.label,
    required this.percentage,
    this.onTap,
    this.color = "#BBDEFB", // Default light pastel blue
    this.expenseCount = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use the EmojiFormatter utility class to handle emoji formatting
    Widget emojiWidget = EmojiFormatter.emojiToWidget(
      emoji,
      fallbackIcon: Icons.category,
      fallbackColor: Colors.blue,
      loggerName: 'category_chip',
    );

    // Parse the color from the hex string or use a default pastel blue
    final Color containerColor = ColorUtils.fromHex(
      color,
      defaultColor: const Color(0xFFBBDEFB), // Light pastel blue
      loggerName: 'category_chip',
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Transaction count at the top
          Text(
            '$expenseCount gastos',
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
              // We'll use the CircularProgressPainter from CategoriesSection
              SizedBox(
                height: 60,
                width: 60,
                child: CustomPaint(
                  painter: CircularProgressPainter(
                    percentage: percentage / 100,
                    color: containerColor,
                    backgroundColor: Colors.grey[200]!,
                  ),
                ),
              ),

              // Emoji container with percentage inside
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: containerColor.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    emojiWidget,
                    // Add a small container with semi-transparent background for the percentage
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 3, vertical: 0),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Category name below the emoji (now without percentage)
          Text(
            label,
            style: const TextStyle(
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
