import 'dart:io';
import 'package:flutter/foundation.dart';

/// Configuration class to manage API URLs across the app
class ApiConfig {
  /// Singleton instance
  static final ApiConfig _instance = ApiConfig._internal();

  /// Factory constructor to return the singleton instance
  factory ApiConfig() => _instance;

  /// Private constructor
  ApiConfig._internal();

  /// The base API URL
  String? _customBaseUrl;

  /// Environment flag - defaults to debug mode for safety
  bool _isProduction = true;

  /// Initialize the API configuration
  void init({
    bool isProduction = true,
    String? customBaseUrl,
  }) {
    _isProduction = isProduction;
    _customBaseUrl = customBaseUrl;
    debugPrint(
        'ApiConfig initialized: ${isProduction ? 'PRODUCTION' : 'DEVELOPMENT'} mode');
    if (_customBaseUrl != null) {
      debugPrint('Using custom base URL: $_customBaseUrl');
    }
  }

  /// Get the base host URL, without any path segments
  String getBaseHost() {
    // If a custom URL is provided, use it
    if (_customBaseUrl != null) {
      return _customBaseUrl!;
    }

    // Otherwise determine based on platform and environment
    if (_isProduction) {
      // Production environment - always use HTTPS without port number
      return 'https://dev.ucashai.app';
    } else {
      // Development environment - use appropriate localhost URL with port
      if (kIsWeb) {
        return 'http://localhost:8080';
      } else if (Platform.isAndroid) {
        return 'http://10.0.2.2:8080'; // Special IP for Android emulator
      } else {
        return 'http://localhost:8080';
      }
    }
  }

  /// Get the API URL for a specific service
  String getApiUrl(String service) {
    final host = getBaseHost();
    return '$host/api/v1/$service';
  }
}
