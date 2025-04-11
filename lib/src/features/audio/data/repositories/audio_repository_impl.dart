import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/audio_repository.dart';
import '../datasources/audio_upload_datasource.dart';
import '../datasources/http_audio_upload_datasource.dart';

/// Implementation of the AudioRepository interface
class AudioRepositoryImpl implements AudioRepository {
  final AudioUploadDataSource dataSource;

  AudioRepositoryImpl({required this.dataSource});

  @override
  Future<String> uploadAudio({
    required File audioFile,
    required String userId,
    String? categoryId,
    String? sharedGroupId,
  }) async {
    return await dataSource.uploadAudioFile(
      audioFile: audioFile,
      userId: userId,
      categoryId: categoryId,
      sharedGroupId: sharedGroupId,
    );
  }
}

/// Provider for AudioRepository
final audioRepositoryProvider = Provider<AudioRepository>((ref) {
  final dataSource = ref.watch(audioUploadDataSourceProvider);
  return AudioRepositoryImpl(dataSource: dataSource);
});
