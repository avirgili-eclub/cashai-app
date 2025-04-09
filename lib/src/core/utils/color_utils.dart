import 'dart:developer' as developer;
import 'package:flutter/material.dart';

/// Utility class for color operations
class ColorUtils {
  /// Convert a hex color string to a Color object
  ///
  /// Supports formats:
  /// - #RRGGBB
  /// - #AARRGGBB
  ///
  /// If the color is null or invalid, returns the default color
  static Color fromHex(
    String? hexString, {
    Color defaultColor = const Color(0xFFFFC0CB), // Pastel pink as default
    String loggerName = 'color_utils',
  }) {
    if (hexString == null || hexString.isEmpty) {
      return defaultColor;
    }

    try {
      hexString = hexString.trim();

      if (hexString.startsWith('#')) {
        hexString = hexString.substring(1);
      }

      // Handle RGB (assume full opacity)
      if (hexString.length == 6) {
        return Color(int.parse('FF$hexString', radix: 16));
      }

      // Handle ARGB
      else if (hexString.length == 8) {
        return Color(int.parse(hexString, radix: 16));
      }

      developer.log(
        'Invalid hex color format: $hexString, using default',
        name: loggerName,
      );
      return defaultColor;
    } catch (e) {
      developer.log(
        'Error parsing color: $e for $hexString',
        name: loggerName,
        error: e,
      );
      return defaultColor;
    }
  }
}
