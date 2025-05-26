import 'package:flutter/material.dart';

/// Mock data class for statistics screen charts
class StatsMockData {
  static final List<String> months = ['Abril 2025', 'Mayo 2025', 'Junio 2025'];

  static final Map<String, MonthData> monthlyData = {
    'Abril 2025': MonthData(
      balance: 3240000,
      change: -5.2,
      weeks: [
        WeekData(income: 75, expense: 45),
        WeekData(income: 85, expense: 55),
        WeekData(income: 60, expense: 40),
        WeekData(income: 70, expense: 50),
      ],
    ),
    'Mayo 2025': MonthData(
      balance: 4050000,
      change: 12.5,
      weeks: [
        WeekData(income: 85, expense: 45),
        WeekData(income: 65, expense: 35),
        WeekData(income: 95, expense: 75),
        WeekData(income: 55, expense: 25),
      ],
    ),
    'Junio 2025': MonthData(
      balance: 0,
      change: 0,
      weeks: [
        WeekData(income: 0, expense: 0),
        WeekData(income: 0, expense: 0),
        WeekData(income: 0, expense: 0),
        WeekData(income: 0, expense: 0),
      ],
    ),
  };

  static final List<CategoryData> categoryDistribution = [
    CategoryData(
      name: 'Comida y Bebida',
      emoji: '🍔',
      percentage: 35,
      color: Colors.purple.shade400,
    ),
    CategoryData(
      name: 'Transporte',
      emoji: '🚗',
      percentage: 25,
      color: Colors.blue.shade400,
    ),
    CategoryData(
      name: 'Entretenimiento',
      emoji: '🎮',
      percentage: 20,
      color: Colors.green.shade400,
    ),
    CategoryData(
      name: 'Salud',
      emoji: '⚕️',
      percentage: 15,
      color: Colors.red.shade200,
    ),
  ];
}

class MonthData {
  final double balance;
  final double change;
  final List<WeekData> weeks;

  MonthData({
    required this.balance,
    required this.change,
    required this.weeks,
  });
}

class WeekData {
  final double income;
  final double expense;

  WeekData({
    required this.income,
    required this.expense,
  });
}

class CategoryData {
  final String name;
  final String emoji;
  final double percentage;
  final Color color;

  CategoryData({
    required this.name,
    required this.emoji,
    required this.percentage,
    required this.color,
  });
}
