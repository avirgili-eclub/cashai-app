import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/auth/providers/user_session_provider.dart';
import '../../../../core/config/api_config.dart';
import '../../../../features/user/domain/entities/api_response_dto.dart';
import '../../domain/models/category_stat.dart';

part 'statistics_datasource.g.dart';

class StatisticsDataSource {
  final String baseUrl;
  final http.Client client;
  final UserSessionNotifier? userSession;

  StatisticsDataSource({
    required this.baseUrl,
    http.Client? client,
    this.userSession,
  }) : client = client ?? http.Client();

  Future<List<CategoryStat>> getCategoryDistribution({
    String? timeRange,
    String? startDate,
    String? endDate,
  }) async {
    final userId = userSession?.state.userId;
    if (userId == null || userId.isEmpty) {
      throw Exception('No authenticated user found');
    }

    // Build the query parameters
    final queryParams = <String, String>{
      'userId': userId,
    };

    if (timeRange != null) {
      queryParams['timeRange'] = timeRange;
    }
    if (startDate != null) {
      queryParams['startDate'] = startDate;
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate;
    }

    // Add "/distribution" to the endpoint URL to match the backend API
    final uri = Uri.parse('$baseUrl/distribution')
        .replace(queryParameters: queryParams);

    developer.log('Making API request to get category distribution: $uri',
        name: 'statistics_datasource');

    try {
      // Prepare headers
      final headers = {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json; charset=utf-8',
      };

      // Add authentication token if available
      if (userSession != null && userSession!.state.token != null) {
        headers['Authorization'] = 'Bearer ${userSession!.state.token}';
        developer.log('Adding authorization header with token',
            name: 'statistics_datasource');
      } else {
        developer.log('No authentication token available',
            name: 'statistics_datasource');
      }

      final response = await client.get(
        uri,
        headers: headers,
      );

      developer.log('Response status code: ${response.statusCode}',
          name: 'statistics_datasource');

      // Log a shorter version of the response body for debugging
      if (response.body.isNotEmpty) {
        final shortBody = response.body.length > 200
            ? '${response.body.substring(0, 200)}...'
            : response.body;
        developer.log('Response body: $shortBody',
            name: 'statistics_datasource');
      }

      if (response.statusCode == 200) {
        try {
          final jsonData = jsonDecode(response.body);
          final apiResponse = ApiResponseDTO<List<dynamic>>.fromJson(jsonData);

          if (apiResponse.success && apiResponse.data != null) {
            return apiResponse.data!
                .map((item) =>
                    CategoryStat.fromJson(item as Map<String, dynamic>))
                .toList();
          } else {
            // Return the API error message directly without wrapping in another Exception
            throw Exception(apiResponse.message);
          }
        } catch (parseError, parseStack) {
          developer.log('JSON parsing error: $parseError',
              name: 'statistics_datasource',
              error: parseError,
              stackTrace: parseStack);
          throw Exception('Error al procesar la respuesta del servidor');
        }
      } else {
        developer.log('Error response: ${response.body}',
            name: 'statistics_datasource');

        // Try to extract the message from the error response
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map<String, dynamic> &&
              errorData.containsKey('message')) {
            // Return the error message directly without nesting exceptions
            throw Exception(errorData['message']);
          }
        } catch (_) {
          // If we can't parse the response, fall back to a generic error
        }

        throw Exception('Error al obtener datos de categorías');
      }
    } catch (e, stack) {
      developer.log('Network error: $e',
          name: 'statistics_datasource', error: e, stackTrace: stack);

      // If this is already an Exception with a message, just rethrow it
      if (e is Exception) {
        rethrow;
      }

      throw Exception('Error de conexión al servidor');
    }
  }
}

@riverpod
StatisticsDataSource statisticsDataSource(StatisticsDataSourceRef ref) {
  // Use the centralized API configuration for the category distribution endpoint
  final baseUrl = ApiConfig().getApiUrl('custom_category');
  developer.log('Using API base URL: $baseUrl', name: 'statistics_datasource');

  // Get the userSessionNotifier to access the authentication token
  final userSessionNotifier = ref.read(userSessionNotifierProvider.notifier);

  return StatisticsDataSource(
    baseUrl: baseUrl,
    userSession: userSessionNotifier,
  );
}

// Helper function to get min value
int min(int a, int b) => a < b ? a : b;
