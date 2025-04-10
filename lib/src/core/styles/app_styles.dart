import 'package:flutter/material.dart';

/// Centralized styles for the CashAI application
class AppStyles {
  // Private constructor to prevent instantiation
  AppStyles._();

  /// Primary color from HTML design - rgb(99, 102, 241)
  static const Color primaryColor = Color.fromRGBO(99, 102, 241, 1.0);

  /// Secondary color from HTML design
  static const Color secondaryColor =
      Color.fromRGBO(165, 180, 252, 1.0); // #A5B4FC

  /// Income color (green)
  static const Color incomeColor = Color.fromRGBO(52, 199, 89, 1.0); // #34C759

  /// Expense color (orange)
  static const Color expenseColor = Color.fromRGBO(255, 149, 0, 1.0); // #FF9500

  /// Background color
  static const Color backgroundColor =
      Color.fromRGBO(243, 244, 246, 1.0); // #F3F4F6

  /// Create a theme using the app colors
  static ThemeData get theme => ThemeData(
        primaryColor: primaryColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          secondary: secondaryColor,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primaryColor,
          ),
        ),
        scaffoldBackgroundColor: Colors.white,
      );

  /// Helper to create a material color from a single color
  static MaterialColor createMaterialColor(Color color) {
    List<double> strengths = [.05, .1, .2, .3, .4, .5, .6, .7, .8, .9];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (final strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}
