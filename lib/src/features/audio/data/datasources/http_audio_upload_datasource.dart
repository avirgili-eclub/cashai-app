import 'dart:developer' as developer;
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'audio_upload_datasource.dart';

/// HTTP implementation of the AudioUploadDataSource interface
class HttpAudioUploadDataSource implements AudioUploadDataSource {
  final String baseUrl;

  HttpAudioUploadDataSource({required this.baseUrl});

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

      // Create a multipart request to the voice endpoint
      final uri = Uri.parse('$baseUrl/api/v1/invoice/voice');
      developer.log('Uploading audio to: $uri', name: 'audio_upload');

      final request = http.MultipartRequest('POST', uri);

      // Add the audio file
      final audioStream = http.ByteStream(audioFile.openRead());
      final audioLength = await audioFile.length();

      final multipartFile = http.MultipartFile(
        'audio', // Must match @RequestParam("audio")
        audioStream,
        audioLength,
        filename: 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a',
      );
      request.files.add(multipartFile);

      // Add the parameters exactly as expected by the backend
      request.fields['userId'] = userId; // Will be converted to Long in backend
      if (categoryId != null) {
        request.fields['categoryId'] = categoryId;
      }
      if (sharedGroupId != null) {
        request.fields['sharedGroupId'] = sharedGroupId;
      }

      // Send the request
      developer.log('Sending audio upload request', name: 'audio_upload');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        developer.log('Audio uploaded successfully: ${response.body}',
            name: 'audio_upload');
        return response.body;
      } else {
        developer.log('Audio upload failed with status: ${response.statusCode}',
            name: 'audio_upload');
        developer.log('Error response: ${response.body}', name: 'audio_upload');
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
  // Choose the correct host based on platform, following the same pattern as in firebase_balance_datasource.dart
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

  final baseUrl = host;
  developer.log('Using API base URL for audio uploads: $baseUrl',
      name: 'audio_upload');

  return HttpAudioUploadDataSource(baseUrl: baseUrl);
});
