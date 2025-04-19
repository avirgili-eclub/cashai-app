import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  // Private constructor to prevent instantiation
  ApiConstants._();

  static String getBaseUrl() {
    // Choose the correct host based on platform
    String host;

    if (kIsWeb) {
      // Web uses the current origin
      host = 'http://localhost:8080';
    } else if (Platform.isAndroid) {
      // Android emulator needs special IP for host's localhost
      host = 'http://10.0.2.2:8080';
    } else {
      // iOS simulator and desktop can use localhost
      host = 'http://localhost:8080';
    }

    return '$host/api/v1';
  }

  static String get authBaseUrl => '${getBaseUrl()}/auth';
  static String get bffBaseUrl => '${getBaseUrl()}/bff';
}
