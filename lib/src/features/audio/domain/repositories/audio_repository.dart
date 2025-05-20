import 'dart:io';

/// Repository interface for handling audio upload operations
abstract class AudioRepository {
  /// Uploads an audio file to the backend
  /// Returns the response from the server as a JSON string
  /// The new endpoint returns a list of transactions in the response
  Future<String> uploadAudio({
    required File audioFile,
    required String
        userId, // This will be used as the token in the new implementation
    String? categoryId,
    String? sharedGroupId,
  });
}
