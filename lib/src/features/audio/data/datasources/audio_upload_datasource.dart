import 'dart:io';

/// Data source interface for audio upload operations
abstract class AudioUploadDataSource {
  /// Uploads an audio file to the backend
  /// Returns the response from the server
  Future<String> uploadAudioFile({
    required File audioFile,
    required String userId,
    String? categoryId,
    String? sharedGroupId,
  });
}
