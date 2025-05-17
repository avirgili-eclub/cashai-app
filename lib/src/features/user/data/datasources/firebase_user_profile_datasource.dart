import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/user_profile_dto.dart';
import '../../domain/entities/password_change_dto.dart';
import '../../domain/entities/api_response_dto.dart';
import '../../../../core/auth/providers/user_session_provider.dart';
import '../../../../core/config/api_config.dart'; // Import the API config
import '../../../../features/dashboard/domain/entities/balance.dart';

part 'firebase_user_profile_datasource.g.dart';

class FirebaseUserProfileDataSource {
  final String baseUrl;
  final http.Client client;

  FirebaseUserProfileDataSource({
    required this.baseUrl,
    http.Client? client,
  }) : client = client ?? http.Client();

  Future<UserProfileDTO> getUserProfile(String token, String userId) async {
    // Log token for debugging
    developer.log(
        'Making API request with token: ${token.isNotEmpty ? "Valid Token" : "Empty Token"}',
        name: 'user_profile_datasource');

    // Updated API endpoint
    final url = '$baseUrl/profile';
    developer.log('Making API request to: $url',
        name: 'user_profile_datasource');

    try {
      final response = await client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
      );

      developer.log('Response status code: ${response.statusCode}',
          name: 'user_profile_datasource');

      if (response.statusCode == 200) {
        developer.log('Response body: ${response.body}',
            name: 'user_profile_datasource');

        // Parse the ApiResponseDTO wrapper first
        final Map<String, dynamic> responseData = json.decode(response.body);
        final ApiResponseDTO<Map<String, dynamic>> apiResponse =
            ApiResponseDTO<Map<String, dynamic>>.fromJson(responseData);

        if (!apiResponse.success) {
          throw Exception('API returned error: ${apiResponse.message}');
        }

        // Extract the actual UserProfileDTO data
        if (apiResponse.data == null) {
          throw Exception('API returned null profile data');
        }

        return UserProfileDTO.fromJson(apiResponse.data!);
      } else {
        developer.log('Error response: ${response.body}',
            name: 'user_profile_datasource');
        throw Exception('Failed to load user profile: ${response.statusCode}');
      }
    } catch (e, stack) {
      developer.log('Network error: $e',
          name: 'user_profile_datasource', error: e, stackTrace: stack);
      throw Exception('Failed to connect to the server: $e');
    }
  }

  // Updated method to handle new API response
  Future<UserProfileDTO> updateUserProfile(
      String token, String userId, Map<String, dynamic> updates) async {
    // Updated API endpoint
    final url = '$baseUrl/profile';
    developer.log('Making API request to update profile: $url',
        name: 'user_profile_datasource');

    try {
      final response = await client.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(updates),
      );

      developer.log('Update response status code: ${response.statusCode}',
          name: 'user_profile_datasource');

      if (response.statusCode == 200) {
        developer.log('Update successful: ${response.body}',
            name: 'user_profile_datasource');

        // Parse the ApiResponseDTO wrapper first
        final Map<String, dynamic> responseData = json.decode(response.body);
        final ApiResponseDTO<Map<String, dynamic>> apiResponse =
            ApiResponseDTO<Map<String, dynamic>>.fromJson(responseData);

        if (!apiResponse.success) {
          throw Exception(
              'API returned error on update: ${apiResponse.message}');
        }

        // Extract the actual updated UserProfileDTO
        if (apiResponse.data == null) {
          throw Exception('API returned null profile data after update');
        }

        return UserProfileDTO.fromJson(apiResponse.data!);
      } else {
        developer.log('Error response: ${response.body}',
            name: 'user_profile_datasource');
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } catch (e, stack) {
      developer.log('Network error during update: $e',
          name: 'user_profile_datasource', error: e, stackTrace: stack);
      throw Exception('Failed to connect to the server: $e');
    }
  }

  Future<ApiResponseDTO<void>> changePassword(
      String token, PasswordChangeDTO passwordChangeDTO) async {
    // Updated API endpoint for change password
    final url = '$baseUrl/change-password';
    developer.log('Making API request to change password: $url',
        name: 'user_profile_datasource');

    try {
      final response = await client.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(passwordChangeDTO.toJson()),
      );

      developer.log(
          'Change password response status code: ${response.statusCode}',
          name: 'user_profile_datasource');

      final Map<String, dynamic> data = json.decode(response.body);

      return ApiResponseDTO<void>.fromJson(data);
    } catch (e, stack) {
      developer.log('Network error during password change: $e',
          name: 'user_profile_datasource', error: e, stackTrace: stack);
      return ApiResponseDTO(
        success: false,
        message: 'Error de conexión: $e',
      );
    }
  }

  Future<Balance> getMonthlyBalance(String token,
      {int? month, int? year}) async {
    // Build query parameters for month and year if provided
    final queryParams = <String, String>{};
    if (month != null) {
      queryParams['month'] = month.toString();
    }
    if (year != null) {
      queryParams['year'] = year.toString();
    }

    // Build the URL with query parameters
    final uri = Uri.parse('$baseUrl/monthly-balance').replace(
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    developer.log(
        'Making API request for balance with token: ${token.isNotEmpty ? "Valid Token" : "Empty Token"}',
        name: 'user_profile_datasource');
    developer.log('Making API request to: ${uri.toString()}',
        name: 'user_profile_datasource');

    try {
      final response = await client.get(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
      );

      developer.log('Response status code: ${response.statusCode}',
          name: 'user_profile_datasource');

      if (response.statusCode == 200) {
        developer.log('Response body: ${response.body}',
            name: 'user_profile_datasource');

        // Parse the ApiResponseDTO wrapper first
        final Map<String, dynamic> responseData = json.decode(response.body);
        final ApiResponseDTO<Map<String, dynamic>> apiResponse =
            ApiResponseDTO<Map<String, dynamic>>.fromJson(responseData);

        if (!apiResponse.success) {
          throw Exception('API returned error: ${apiResponse.message}');
        }

        // Extract the actual Balance data
        if (apiResponse.data == null) {
          throw Exception('API returned null balance data');
        }

        return Balance.fromJson(apiResponse.data!);
      } else {
        developer.log('Error response: ${response.body}',
            name: 'user_profile_datasource');
        throw Exception(
            'Failed to load monthly balance: ${response.statusCode}');
      }
    } catch (e, stack) {
      developer.log('Network error: $e',
          name: 'user_profile_datasource', error: e, stackTrace: stack);
      throw Exception('Failed to connect to the server: $e');
    }
  }
}

@riverpod
FirebaseUserProfileDataSource userProfileDataSource(
    UserProfileDataSourceRef ref) {
  // Use the centralized API configuration
  final baseUrl = ApiConfig().getApiUrl('users');
  developer.log('Using API base URL: $baseUrl',
      name: 'user_profile_datasource');

  return FirebaseUserProfileDataSource(baseUrl: baseUrl);
}
