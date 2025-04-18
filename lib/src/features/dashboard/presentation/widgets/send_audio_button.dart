import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/audio/presentation/controllers/audio_controller.dart';

class SendAudioButton extends ConsumerStatefulWidget {
  const SendAudioButton({Key? key}) : super(key: key);

  @override
  ConsumerState<SendAudioButton> createState() => _SendAudioButtonState();
}

class _SendAudioButtonState extends ConsumerState<SendAudioButton>
    with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animation controller for the pulsating effect - FASTER (0.5s instead of 1s)
    _animationController = AnimationController(
      vsync: this,
      duration:
          const Duration(milliseconds: 800), // Reduced from 1000ms to 500ms
    )..repeat(reverse: true);

    // Create a pulsating animation
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.4).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Initialize the audio controller
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioControllerProvider.notifier).initialize();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the audio controller state
    final audioState = ref.watch(audioControllerProvider);

    return GestureDetector(
      onLongPressStart: (_) {
        setState(() {
          _isRecording = true;
        });
        // Start recording
        ref.read(audioControllerProvider.notifier).startRecording();
      },
      onLongPressEnd: (_) {
        setState(() {
          _isRecording = false;
        });
        // Stop recording and upload
        ref.read(audioControllerProvider.notifier).stopRecordingAndUpload();
      },
      onLongPressCancel: () {
        setState(() {
          _isRecording = false;
        });
        // Cancel recording
        ref.read(audioControllerProvider.notifier).cancelRecording();
      },
      child: SizedBox(
        width: 72, // Explicit size for the FloatingActionButton
        height: 72, // Explicit size for the FloatingActionButton
        child: FittedBox(
          child: FloatingActionButton(
            onPressed: () {
              // Single tap action can be added here if needed
            },
            backgroundColor: _getButtonColor(audioState),
            elevation: 4.0,
            // Ensure the FAB doesn't use a preset size
            mini: false,
            heroTag: 'sendAudioButton',
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 100),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: _buildButtonContent(audioState),
            ),
          ),
        ),
      ),
    );
  }

  Color _getButtonColor(AudioRecordingState state) {
    switch (state) {
      case AudioRecordingState.recording:
        return Colors.red;
      case AudioRecordingState.uploading:
        return Colors.orange;
      case AudioRecordingState.success:
        return Colors.green;
      case AudioRecordingState.error:
        return Colors.redAccent;
      case AudioRecordingState.idle:
      default:
        return Theme.of(context).primaryColor;
    }
  }

  Widget _buildButtonContent(AudioRecordingState state) {
    switch (state) {
      case AudioRecordingState.recording:
        return _buildRecordingIcon();
      case AudioRecordingState.uploading:
        return const SizedBox(
          key: ValueKey('uploading_icon'),
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2.5,
          ),
        );
      case AudioRecordingState.success:
        return const Icon(
          Icons.check,
          key: ValueKey('success_icon'),
          color: Colors.white,
          size: 32,
        );
      case AudioRecordingState.error:
        return const Icon(
          Icons.error,
          key: ValueKey('error_icon'),
          color: Colors.white,
          size: 32,
        );
      case AudioRecordingState.idle:
      default:
        return const Icon(
          Icons.mic,
          key: ValueKey('mic_icon'),
          color: Colors.white,
          size: 32,
        );
    }
  }

  Widget _buildRecordingIcon() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          key: const ValueKey('recording_icon'),
          width: 32, // Increased from 28
          height: 32, // Increased from 28
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulsating circle
              Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 28, // Increased from 24
                  height: 28, // Increased from 24
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Middle circle
              Container(
                width: 20, // Increased from 16
                height: 20, // Increased from 16
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
              // Inner circle (center dot)
              Container(
                width: 10, // Increased from 8
                height: 10, // Increased from 8
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
