import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Utility class for formatting dates in a consistent way across the app
class DateFormatter {
  /// Returns a user-friendly date string
  /// Examples: "Hoy", "Ayer", "Martes, 15 de Marzo"
  static String formatFullDate(DateTime date) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck.year == now.year &&
        dateToCheck.month == now.month &&
        dateToCheck.day == now.day) {
      return 'Hoy';
    } else if (dateToCheck.year == yesterday.year &&
        dateToCheck.month == yesterday.month &&
        dateToCheck.day == yesterday.day) {
      return 'Ayer';
    } else {
      // Format: "Lunes, 15 de Marzo"
      final months = [
        'Enero',
        'Febrero',
        'Marzo',
        'Abril',
        'Mayo',
        'Junio',
        'Julio',
        'Agosto',
        'Septiembre',
        'Octubre',
        'Noviembre',
        'Diciembre'
      ];
      final days = [
        'Domingo',
        'Lunes',
        'Martes',
        'Miércoles',
        'Jueves',
        'Viernes',
        'Sábado'
      ];

      final dayName = days[date.weekday % 7];
      final monthName = months[date.month - 1];

      return '$dayName, ${date.day} de $monthName';
    }
  }

  /// Returns month and year as string, e.g. "Marzo 2024"
  static String formatMonthYear(DateTime date) {
    final months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];

    return '${months[date.month - 1]} ${date.year}';
  }

  /// Returns short date format like "15/03/2024"
  static String formatShortDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Returns time format like "14:30"
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }
}
