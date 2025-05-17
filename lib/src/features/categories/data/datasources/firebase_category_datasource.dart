import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/auth/providers/user_session_provider.dart';
import '../../../../core/config/api_config.dart'; // Import the API config
import '../../domain/models/custom_category_request.dart';

part 'firebase_category_datasource.g.dart';

class FirebaseCategoryDataSource {
  final String baseUrl;
  final http.Client client;
  final UserSessionNotifier? userSession;

  FirebaseCategoryDataSource({
    required this.baseUrl,
    http.Client? client,
    this.userSession,
  }) : client = client ?? http.Client();

  Future<Map<String, dynamic>> createCustomCategory(
      CustomCategoryRequest request, String userId) async {
    final url = '$baseUrl/create?userId=$userId';
    developer.log('Making API request to create category: $url',
        name: 'category_datasource');

    try {
      // Get auth headers from user session if available
      final headers = {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json; charset=utf-8',
      };

      // Add authentication token if available
      if (userSession != null && userSession!.state.token != null) {
        headers['Authorization'] = 'Bearer ${userSession!.state.token}';
        developer.log('Adding authorization header with token',
            name: 'category_datasource');
      } else {
        developer.log('No authentication token available',
            name: 'category_datasource');
      }

      final response = await client.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(request.toJson()),
      );

      developer.log('Response status code: ${response.statusCode}',
          name: 'category_datasource');

      if (response.statusCode == 200 || response.statusCode == 201) {
        developer.log('Response body: ${response.body}',
            name: 'category_datasource');
        return jsonDecode(response.body);
      } else {
        developer.log('Error response: ${response.body}',
            name: 'category_datasource');
        throw Exception(
            'Failed to create category: ${response.statusCode} - ${response.body}');
      }
    } catch (e, stack) {
      developer.log('Network error: $e',
          name: 'category_datasource', error: e, stackTrace: stack);
      throw Exception('Failed to connect to the server: $e');
    }
  }

  Future<bool> deleteCategory(int categoryId, String userId) async {
    final url = '$baseUrl/$categoryId?userId=$userId';
    developer.log('Making API request to delete category: $url',
        name: 'category_datasource');

    try {
      // Get auth headers from user session if available
      final headers = {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json; charset=utf-8',
      };

      // Add authentication token if available
      if (userSession != null && userSession!.state.token != null) {
        headers['Authorization'] = 'Bearer ${userSession!.state.token}';
        developer.log('Adding authorization header with token',
            name: 'category_datasource');
      } else {
        developer.log('No authentication token available',
            name: 'category_datasource');
      }

      final response = await client.delete(
        Uri.parse(url),
        headers: headers,
      );

      developer.log('Delete response status code: ${response.statusCode}',
          name: 'category_datasource');

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        developer.log('Delete response body: $responseBody',
            name: 'category_datasource');
        return responseBody['success'] == true;
      } else {
        developer.log('Error response: ${response.body}',
            name: 'category_datasource');
        throw Exception(
            'Failed to delete category: ${response.statusCode} - ${response.body}');
      }
    } catch (e, stack) {
      developer.log('Network error during delete: $e',
          name: 'category_datasource', error: e, stackTrace: stack);
      throw Exception('Failed to connect to the server: $e');
    }
  }

  Future<Map<String, dynamic>> updateCategory(
      int categoryId, Map<String, dynamic> updates, String userId) async {
    final url = '$baseUrl/$categoryId?userId=$userId';
    developer.log('Making API request to update category: $url',
        name: 'category_datasource');

    try {
      // Get auth headers from user session if available
      final headers = {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json; charset=utf-8',
      };

      // Add authentication token if available
      if (userSession != null && userSession!.state.token != null) {
        headers['Authorization'] = 'Bearer ${userSession!.state.token}';
        developer.log('Adding authorization header with token',
            name: 'category_datasource');
      } else {
        developer.log('No authentication token available',
            name: 'category_datasource');
      }

      final response = await client.patch(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(updates),
      );

      developer.log('Update response status code: ${response.statusCode}',
          name: 'category_datasource');

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        developer.log('Update response body: $responseBody',
            name: 'category_datasource');
        return responseBody;
      } else {
        developer.log('Error response: ${response.body}',
            name: 'category_datasource');
        throw Exception(
            'Failed to update category: ${response.statusCode} - ${response.body}');
      }
    } catch (e, stack) {
      developer.log('Network error during update: $e',
          name: 'category_datasource', error: e, stackTrace: stack);
      throw Exception('Failed to connect to the server: $e');
    }
  }
}

@riverpod
FirebaseCategoryDataSource categoryDataSource(CategoryDataSourceRef ref) {
  // Use the centralized API configuration
  final baseUrl = ApiConfig().getApiUrl('custom_category');
  developer.log('Using API base URL: $baseUrl', name: 'category_datasource');

  // Get the userSessionNotifier to access the authentication token
  final userSessionNotifier = ref.read(userSessionNotifierProvider.notifier);

  return FirebaseCategoryDataSource(
    baseUrl: baseUrl,
    userSession: userSessionNotifier,
  );
}
