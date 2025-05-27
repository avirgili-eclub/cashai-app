import 'dart:developer' as developer;
import 'dart:convert';

/// Utility class to parse error messages and extract user-friendly content
class ErrorParser {
  /// Extracts a user-friendly message from various error types
  static String extractUserFriendlyMessage(Object error) {
    try {
      // Default error message if we can't parse anything better
      String message = 'Error al cargar datos';

      // Check if the error is in a known format
      final errorString = error.toString();

      developer.log('Parsing error message from: $errorString',
          name: 'error_parser');

      // Try more specific pattern first - extract the JSON part of nested exceptions
      final jsonPattern = RegExp(r'500 - (\{.*\})');
      final jsonMatch = jsonPattern.firstMatch(errorString);

      if (jsonMatch != null && jsonMatch.groupCount >= 1) {
        final jsonStr = jsonMatch.group(1);
        if (jsonStr != null) {
          try {
            final json = jsonDecode(jsonStr);
            if (json is Map<String, dynamic> && json.containsKey('message')) {
              message = json['message'];
              developer.log(
                  'Successfully extracted message from JSON: $message',
                  name: 'error_parser');
              return message;
            }
          } catch (e) {
            developer.log('Failed to parse JSON: $e', name: 'error_parser');
          }
        }
      }

      // Check for direct exception message pattern
      final directPattern = RegExp(r'Exception: ([^:]+)');
      final directMatch = directPattern.firstMatch(errorString);

      if (directMatch != null && directMatch.groupCount >= 1) {
        final extracted = directMatch.group(1);
        if (extracted != null && !extracted.contains('Failed to')) {
          message = extracted.trim();
          developer.log('Extracted direct exception message: $message',
              name: 'error_parser');
          return message;
        }
      }

      // Look for a specific pattern in exception chains that often appears in network errors
      final failedMatch = RegExp(r'Failed to get category data: (\d+) - (.+)$')
          .firstMatch(errorString);
      if (failedMatch != null && failedMatch.groupCount >= 2) {
        final statusCode = failedMatch.group(1);
        final responseBody = failedMatch.group(2);

        // Try to parse the response body as JSON
        try {
          final jsonResponse = jsonDecode(responseBody!);
          if (jsonResponse is Map<String, dynamic> &&
              jsonResponse.containsKey('message')) {
            message = jsonResponse['message'] as String? ?? message;
            developer.log(
                'Extracted error message from response body: $message',
                name: 'error_parser');
            return message;
          }
        } catch (e) {
          // If we can't parse the JSON, just use the status code
          message = 'Error $statusCode al conectar con el servidor';
          developer.log('Using status code in error message: $message',
              name: 'error_parser');
          return message;
        }
      }

      // Try to find "message" in the string directly
      final messagePattern = RegExp(r'"message":"([^"]+)"');
      final messageMatch = messagePattern.firstMatch(errorString);

      if (messageMatch != null && messageMatch.groupCount >= 1) {
        final extracted = messageMatch.group(1);
        if (extracted != null) {
          message = extracted;
          developer.log('Extracted message from string: $message',
              name: 'error_parser');
          return message;
        }
      }

      // Look for other common error patterns
      if (errorString.contains('Failed to connect')) {
        message = 'Error de conexión al servidor';
        developer.log('Detected connection error', name: 'error_parser');
        return message;
      }

      // If we have a short error message (less than 100 chars), use it directly
      if (errorString.length < 100) {
        message = errorString;
        developer.log('Using short error message directly: $message',
            name: 'error_parser');
        return message;
      }

      // Log that we're using the default message
      developer.log('Using default error message', name: 'error_parser');
      return message;
    } catch (e, stack) {
      // If anything goes wrong during parsing, return a generic message
      developer.log('Error while parsing error message: $e',
          name: 'error_parser', error: e, stackTrace: stack);
      return 'Error al procesar los datos';
    }
  }
}
