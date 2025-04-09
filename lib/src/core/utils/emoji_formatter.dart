import 'dart:developer' as developer;
import 'package:flutter/material.dart';

/// Utility class to handle emoji formatting from different formats
class EmojiFormatter {
  /// Converts an emoji string to a Widget
  ///
  /// Handles multiple emoji formats:
  /// - Direct emoji characters (e.g. 🍕)
  /// - Unicode format with U+ prefix (e.g. U+1F355)
  /// - Java/JavaScript style Unicode escapes (e.g. \uD83C\uDF55)
  /// - Null values (returns default emoji)
  ///
  /// Returns a Text widget with the emoji or a fallback icon if parsing fails
  static Widget emojiToWidget(
    String? emoji, {
    double fontSize = 24,
    Color fallbackColor = Colors.grey,
    IconData fallbackIcon = Icons.emoji_emotions,
    String loggerName = 'emoji_formatter',
    String defaultEmoji = '🏷️', // Default emoji tag
  }) {
    // Handle null emoji
    if (emoji == null || emoji.isEmpty) {
      developer.log('Null or empty emoji, using default', name: loggerName);
      return Text(
        defaultEmoji,
        style: TextStyle(fontSize: fontSize),
      );
    }

    developer.log('Processing emoji: $emoji', name: loggerName);

    // Case 1: Handle Unicode format (e.g., U+1F354)
    if (emoji.startsWith('U+')) {
      try {
        final codePoint = int.parse(emoji.substring(2), radix: 16);
        return Text(
          String.fromCharCode(codePoint),
          style: TextStyle(fontSize: fontSize),
        );
      } catch (e) {
        developer.log(
          'Error parsing U+ format emoji: $emoji - $e',
          name: loggerName,
          error: e,
        );
        return Icon(fallbackIcon, color: fallbackColor);
      }
    }

    // Case 2: Handle Java/JavaScript style Unicode escapes (e.g. \uD83C\uDF55)
    else if (emoji.contains(r'\u')) {
      try {
        // Process the Java/JavaScript Unicode escape sequences
        final processed = _processJavaScriptUnicodeEscapes(emoji);
        developer.log('Processed emoji: $processed', name: loggerName);

        return Text(
          processed,
          style: TextStyle(fontSize: fontSize),
        );
      } catch (e) {
        developer.log(
          'Error parsing JavaScript Unicode emoji: $emoji - $e',
          name: loggerName,
          error: e,
        );
        return Icon(fallbackIcon, color: fallbackColor);
      }
    }

    // Case 3: Direct emoji representation or text
    else {
      return Text(
        emoji,
        style: TextStyle(fontSize: fontSize),
      );
    }
  }

  /// Processes JavaScript style Unicode escape sequences like \uD83C\uDF55
  /// Returns the actual emoji string
  static String _processJavaScriptUnicodeEscapes(String input) {
    if (!input.contains(r'\u')) return input;

    // Regular expression to find all \uXXXX sequences
    final regex = RegExp(r'\\u([0-9A-Fa-f]{4})');

    // Replace each match with the actual character
    String result = input;
    final matches = regex.allMatches(input);

    for (final match in matches) {
      final hexValue = match.group(1)!;
      final codePoint = int.parse(hexValue, radix: 16);
      final char = String.fromCharCode(codePoint);

      // Replace the \uXXXX with the actual character
      result = result.replaceFirst(match.group(0)!, char);
    }

    return result;
  }
}
