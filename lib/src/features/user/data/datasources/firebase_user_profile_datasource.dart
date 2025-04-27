import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/user_profile_dto.dart';
import '../../../../core/auth/providers/user_session_provider.dart';

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

    // Remove userId from URL - backend should extract it from JWT
    final url = '$baseUrl/users/profile';
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
        final Map<String, dynamic> data = json.decode(response.body);
        return UserProfileDTO.fromJson(data);
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
    // Use updated endpoint without userId parameter
    final url = '$baseUrl/users/profile';
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
        // Parse the returned user profile
        final Map<String, dynamic> data = json.decode(response.body);
        return UserProfileDTO.fromJson(data);
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
}

@riverpod
FirebaseUserProfileDataSource userProfileDataSource(
    UserProfileDataSourceRef ref) {
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

  final baseUrl = '$host/api/v1/bff';
  developer.log('Using API base URL: $baseUrl',
      name: 'user_profile_datasource');

  return FirebaseUserProfileDataSource(baseUrl: baseUrl);
}
