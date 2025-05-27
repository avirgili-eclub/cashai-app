import 'package:flutter/material.dart';

class CategoryStat {
  final int id;
  final String name;
  final String emoji;
  final String color;
  final double amount;
  final double percentage;
  final int transactionCount;
  final double
      totalAmount; // New field for the total amount from all categories

  CategoryStat({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    required this.amount,
    required this.percentage,
    required this.transactionCount,
    this.totalAmount = 0.0, // Default value if not provided
  });

  factory CategoryStat.fromJson(Map<String, dynamic> json) {
    // Add debug print for incoming JSON data
    debugPrint('Parsing CategoryStat from JSON: $json');

    return CategoryStat(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      emoji: json['emoji'] ?? '📊',
      color: json['color'] ?? '#BBDEFB',
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : 0.0,
      percentage: json['percentage'] != null
          ? (json['percentage'] as num).toDouble()
          : 0.0,
      transactionCount: json['transactionCount'] ?? 0,
      totalAmount: json['totalAmount'] != null
          ? (json['totalAmount'] as num).toDouble()
          : 0.0,
    );
  }

  Color getColorObject() {
    try {
      // Support both formats: with or without # prefix
      final colorString = color.startsWith('#') ? color : '#$color';
      return Color(int.parse(colorString.replaceAll('#', '0xFF')));
    } catch (e) {
      debugPrint('Error parsing color: $color - $e');
      return Colors.blue.shade400; // Default color
    }
  }
}
