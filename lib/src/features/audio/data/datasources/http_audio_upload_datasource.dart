import 'dart:developer' as developer;
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/api_config.dart'; // Import the API config
import '../../../../core/auth/providers/user_session_provider.dart'; // Import UserSession provider
import '../../../user/domain/entities/api_response_dto.dart';
import 'audio_upload_datasource.dart';

/// HTTP implementation of the AudioUploadDataSource interface
class HttpAudioUploadDataSource implements AudioUploadDataSource {
  final String baseUrl;
  final Ref? ref; // Add reference to Riverpod Ref

  HttpAudioUploadDataSource({required this.baseUrl, this.ref});

  @override
  Future<String> uploadAudioFile({
    required File audioFile,
    required String userId,
    String? categoryId,
    String? sharedGroupId,
  }) async {
    try {
      developer.log('Starting audio upload for user: $userId',
          name: 'audio_upload');

      // Get the actual userId from UserSessionNotifier if possible
      String actualUserId = "user"; // Default placeholder

      if (ref != null) {
        try {
          // Access the UserSession to get the real userId
          final userSession = ref!.read(userSessionNotifierProvider);
          if (userSession.userId != null && userSession.userId!.isNotEmpty) {
            actualUserId = userSession.userId!;
            developer.log('Using userId from UserSession: $actualUserId',
                name: 'audio_upload');
          }
        } catch (e) {
          // If reading from provider fails, fallback to default
          developer.log('Failed to get userId from UserSession provider: $e',
              name: 'audio_upload');
        }
      } else {
        developer.log('No reference to Riverpod Ref, using default userId',
            name: 'audio_upload');
      }

      // Create a filename with timestamp and userId
      final uniqueFilename =
          'audio_${DateTime.now().millisecondsSinceEpoch}_$actualUserId'; // Build the URI with query parameters - remove duplicate path segments
      // The baseUrl already includes '/api/v1/invoice', so don't repeat it
      var uriString = '$baseUrl/audio-transactions?file=$uniqueFilename';

      developer.log('Base URL: $baseUrl', name: 'audio_upload');

      // Add optional parameters if provided
      if (categoryId != null) {
        uriString += '&categoryId=$categoryId';
      }
      if (sharedGroupId != null) {
        uriString += '&sharedGroupId=$sharedGroupId';
      }

      final uri = Uri.parse(uriString);
      developer.log('Uploading audio to new endpoint: $uri',
          name: 'audio_upload');

      final request = http.MultipartRequest('POST', uri);

      // Add the audio file - now with param name 'file' instead of 'audio'
      final audioStream = http.ByteStream(audioFile.openRead());
      final audioLength = await audioFile
          .length(); // Use the same unique filename for the file upload to match the query parameter
      final multipartFile = http.MultipartFile(
        'file', // Must match @RequestParam("file") in the backend
        audioStream,
        audioLength,
        filename: '$uniqueFilename.wav',
      );
      request.files.add(
          multipartFile); // No need to add userId as a field now, it comes from Authentication
      // Use the token passed from the controller
      if (userId.isNotEmpty) {
        // In a real scenario with proper DI, we'd get the token differently
        // For now, we're just using the token from the audio controller that calls this method
        request.headers['Authorization'] =
            'Bearer $userId'; // Using userId parameter as token

        // Add necessary Content-Type headers for multipart requests
        request.headers['Accept'] = 'application/json';

        developer.log('Added authentication token to request',
            name: 'audio_upload');
        developer.log('Request headers: ${request.headers}',
            name: 'audio_upload');
      } else {
        developer.log('No authentication token available',
            name: 'audio_upload');
      }

      // Send the request
      developer.log('Sending audio upload request to new endpoint',
          name: 'audio_upload');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        developer.log('Audio uploaded successfully: ${response.body}',
            name: 'audio_upload');

        // Parse the ApiResponseDTO wrapper that the new endpoint returns
        final Map<String, dynamic> responseData = json.decode(response.body);
        final apiResponse = ApiResponseDTO<dynamic>.fromJson(responseData);

        if (!apiResponse.success) {
          throw Exception('API returned error: ${apiResponse.message}');
        }

        developer.log(
            'Processed ${apiResponse.data?.length ?? 0} transactions from audio',
            name: 'audio_upload');

        // Return the original response for backward compatibility
        return response.body;
      } else if (response.statusCode == 302) {
        // Specific handling for 302 redirect
        final redirectLocation = response.headers['location'];
        developer.log('Redirect detected (302) to: $redirectLocation',
            name: 'audio_upload');
        developer.log('Response headers: ${response.headers}',
            name: 'audio_upload');

        if (redirectLocation != null) {
          developer.log('Attempting to follow redirect to $redirectLocation',
              name: 'audio_upload');
          // You could implement redirect following here if needed
          throw Exception(
              'Server redirected to: $redirectLocation - Your authentication may have expired or security settings are blocking direct access');
        } else {
          throw Exception(
              'Server returned redirect (302) without Location header. Check server security configuration.');
        }
      } else {
        developer.log('Audio upload failed with status: ${response.statusCode}',
            name: 'audio_upload');
        developer.log('Error response: ${response.body}', name: 'audio_upload');
        developer.log('Response headers: ${response.headers}',
            name: 'audio_upload');
        throw Exception(
            'Failed to upload audio: ${response.statusCode} ${response.body}');
      }
    } catch (e, stack) {
      developer.log('Error uploading audio: $e',
          name: 'audio_upload', error: e, stackTrace: stack);
      throw Exception('Failed to upload audio: $e');
    }
  }
}

/// Provider for the audio upload data source implementation
final audioUploadDataSourceProvider = Provider<AudioUploadDataSource>((ref) {
  // Use the centralized API configuration
  final baseUrl = ApiConfig().getApiUrl('invoice');
  developer.log('Using API base URL for audio uploads: $baseUrl',
      name: 'audio_upload');

  // Pass the ref to allow access to other providers
  return HttpAudioUploadDataSource(baseUrl: baseUrl, ref: ref);
});
