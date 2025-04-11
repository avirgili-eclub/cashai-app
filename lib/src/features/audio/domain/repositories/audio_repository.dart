import 'dart:io';

/// Repository interface for handling audio upload operations
abstract class AudioRepository {
  /// Uploads an audio file to the backend
  /// Returns the response from the server
  Future<String> uploadAudio({
    required File audioFile,
    required String userId,
    String? categoryId,
    String? sharedGroupId,
  });
}
