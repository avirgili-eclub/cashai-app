import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/auth/providers/user_session_provider.dart';
import '../../data/repositories/audio_repository_impl.dart';
// Add this import to fix the transactionsControllerProvider reference
import '../../../dashboard/presentation/controllers/transaction_controller.dart';

part 'audio_controller.g.dart';

enum AudioRecordingState {
  idle,
  recording,
  uploading,
  success,
  error,
}

enum RecorderState {
  isStopped,
  isRecording,
  isPaused,
}

@Riverpod(keepAlive: true)
class AudioController extends _$AudioController {
  FlutterSoundRecorder? _audioRecorder;
  String? _recordingPath;
  Timer? _stateResetTimer;

  @override
  AudioRecordingState build() {
    ref.onDispose(() {
      _closeRecorder();
      _stateResetTimer?.cancel();
    });
    return AudioRecordingState.idle;
  }

  Future<void> initialize() async {
    if (_audioRecorder != null) return;

    try {
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        developer.log('Microphone permission denied', name: 'audio_controller');
        state = AudioRecordingState.error;
        return;
      }

      _audioRecorder = FlutterSoundRecorder();
      await _audioRecorder!.openRecorder();
      developer.log('Audio recorder initialized', name: 'audio_controller');
    } catch (e, stack) {
      developer.log('Failed to initialize audio recorder: $e',
          name: 'audio_controller', error: e, stackTrace: stack);
      state = AudioRecordingState.error;
    }
  }

  Future<void> startRecording() async {
    if (_audioRecorder == null ||
        _audioRecorder!.recorderState == RecorderState.isStopped) {
      await initialize();
    }
    // Only proceed if initialization was successful
    if (_audioRecorder == null) {
      state = AudioRecordingState.error;
      return;
    }
    if (_audioRecorder!.isRecording) {
      developer.log('Already recording', name: 'audio_controller');
      return;
    }
    try {
      // Get temp directory for recording
      final tempDir = await getTemporaryDirectory();
      _recordingPath =
          '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

      // Start recording
      await _audioRecorder!.startRecorder(
        toFile: _recordingPath,
        codec: Codec.aacMP4,
      );

      developer.log('Started recording to: $_recordingPath',
          name: 'audio_controller');
      state = AudioRecordingState.recording;
    } catch (e, stack) {
      developer.log('Error starting recording: $e',
          name: 'audio_controller', error: e, stackTrace: stack);
      state = AudioRecordingState.error;
    }
  }

  Future<void> stopRecordingAndUpload() async {
    await _stopRecordingAndUpload(null);
  }

  // Add new method that accepts a categoryId
  Future<void> stopRecordingAndUploadWithCategoryId(String categoryId) async {
    await _stopRecordingAndUpload(categoryId);
  }

  // Common implementation for both upload methods
  Future<void> _stopRecordingAndUpload(String? categoryId) async {
    if (_audioRecorder == null || !_audioRecorder!.isRecording) {
      developer.log('No active recording to stop', name: 'audio_controller');
      return;
    }

    try {
      // Stop recording
      await _audioRecorder!.stopRecorder();
      developer.log('Recording stopped', name: 'audio_controller');

      if (_recordingPath == null) {
        developer.log('No recording path available', name: 'audio_controller');
        state = AudioRecordingState.error;
        return;
      }

      // Set state to uploading
      state = AudioRecordingState.uploading;

      // Prepare the file
      final audioFile = File(_recordingPath!);
      if (!await audioFile.exists()) {
        developer.log('Audio file does not exist at path: $_recordingPath',
            name: 'audio_controller');
        state = AudioRecordingState.error;
        return;
      } // Get user session - we need the token for authentication
      final userSession = ref.read(userSessionNotifierProvider);
      final token = userSession.token;
      final userId = userSession.userId;

      // We need both token and userId to be valid
      if (token == null || token.isEmpty) {
        developer.log('Token is null or empty, cannot upload',
            name: 'audio_controller');
        state = AudioRecordingState.error;
        return;
      }

      if (userId == null || userId.isEmpty) {
        developer.log('User ID is null or empty, cannot upload',
            name: 'audio_controller');
        state = AudioRecordingState.error;
        return;
      }

      // Upload the file - use token for authentication
      // Note: We're passing the token in the userId field of the repository
      // This is a temporary solution to maintain compatibility with the interface
      final repository = ref.read(audioRepositoryProvider);
      final response = await repository.uploadAudio(
        audioFile: audioFile,
        userId: token, // Using the token for authentication instead of userId
        categoryId: categoryId, // Pass the categoryId if provided
        sharedGroupId: null, // Can be added in the future if needed
      );

      developer.log('Upload completed with response: $response',
          name: 'audio_controller');

      // Log category context if provided
      if (categoryId != null) {
        developer.log('Audio uploaded with category context: $categoryId',
            name: 'audio_controller');
      }

      // Clean up the file
      await audioFile.delete();
      developer.log('Temporary audio file deleted', name: 'audio_controller');

      // Update state
      state = AudioRecordingState.success;

      // Refresh transactions to show the new transaction created from audio
      ref.read(transactionsControllerProvider.notifier).refreshTransactions();

      // Reset state after a short delay
      _stateResetTimer?.cancel();
      _stateResetTimer = Timer(const Duration(seconds: 2), () {
        state = AudioRecordingState.idle;
      });
    } catch (e, stack) {
      developer.log('Error in stop recording and upload: $e',
          name: 'audio_controller', error: e, stackTrace: stack);
      state = AudioRecordingState.error;

      // Reset state after a short delay
      _stateResetTimer?.cancel();
      _stateResetTimer = Timer(const Duration(seconds: 2), () {
        state = AudioRecordingState.idle;
      });
    }
  }

  Future<void> cancelRecording() async {
    if (_audioRecorder == null || !_audioRecorder!.isRecording) {
      return;
    }

    try {
      // Stop recording
      await _audioRecorder!.stopRecorder();

      // Delete the temporary file if it exists
      if (_recordingPath != null) {
        final file = File(_recordingPath!);
        if (await file.exists()) {
          await file.delete();
          developer.log('Temporary recording file deleted',
              name: 'audio_controller');
        }
      }

      state = AudioRecordingState.idle;
    } catch (e, stack) {
      developer.log('Error cancelling recording: $e',
          name: 'audio_controller', error: e, stackTrace: stack);
      state = AudioRecordingState.error;
    }
  }

  Future<void> _closeRecorder() async {
    if (_audioRecorder != null) {
      try {
        await _audioRecorder!.closeRecorder();
        _audioRecorder = null;
        developer.log('Audio recorder closed', name: 'audio_controller');
      } catch (e, stack) {
        developer.log('Error closing audio recorder: $e',
            name: 'audio_controller', error: e, stackTrace: stack);
      }
    }
  }
}
