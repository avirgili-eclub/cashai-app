import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/audio/presentation/controllers/audio_controller.dart';

class SendAudioButton extends ConsumerStatefulWidget {
  // Add parameter for categoryId
  final String? categoryId;
  // Add callback for when a transaction is successfully added
  final VoidCallback? onTransactionAdded;
  // Add parameter for maximum recording duration
  final int maxRecordingDurationInSeconds;

  const SendAudioButton({
    Key? key,
    this.categoryId,
    this.onTransactionAdded,
    this.maxRecordingDurationInSeconds = 12, // Default to 12 seconds
  }) : super(key: key);

  @override
  ConsumerState<SendAudioButton> createState() => _SendAudioButtonState();
}

class _SendAudioButtonState extends ConsumerState<SendAudioButton>
    with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  Timer? _recordingTimer;
  int _currentRecordingSeconds = 0;

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
    _recordingTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startRecordingWithTimer() {
    _currentRecordingSeconds = 0;

    // Start the recording
    ref.read(audioControllerProvider.notifier).startRecording();

    // Start the timer to limit recording duration
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentRecordingSeconds++;
      });

      // If maximum duration reached, stop recording automatically
      if (_currentRecordingSeconds >= widget.maxRecordingDurationInSeconds) {
        _stopRecording();
      }
    });
  }

  void _stopRecording() {
    // Cancel the timer
    _recordingTimer?.cancel();
    _recordingTimer = null;

    setState(() {
      _isRecording = false;
      _currentRecordingSeconds = 0;
    });

    // Stop recording and upload with category ID if provided
    if (widget.categoryId != null) {
      ref
          .read(audioControllerProvider.notifier)
          .stopRecordingAndUploadWithCategoryId(widget.categoryId!);
    } else {
      ref.read(audioControllerProvider.notifier).stopRecordingAndUpload();
    }
  }

  void _cancelRecording() {
    // Cancel the timer
    _recordingTimer?.cancel();
    _recordingTimer = null;

    setState(() {
      _isRecording = false;
      _currentRecordingSeconds = 0;
    });

    // Cancel recording
    ref.read(audioControllerProvider.notifier).cancelRecording();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the audio controller state
    final audioState = ref.watch(audioControllerProvider);

    // Listen to state changes to detect successful uploads
    ref.listen(audioControllerProvider, (previous, current) {
      // If the state changed from uploading to success, trigger the callback
      if (previous == AudioRecordingState.uploading &&
          current == AudioRecordingState.success) {
        if (widget.onTransactionAdded != null) {
          widget.onTransactionAdded!();
        }
      }
    });

    return GestureDetector(
      onLongPressStart: (_) {
        setState(() {
          _isRecording = true;
        });
        // Start recording with timer
        _startRecordingWithTimer();
      },
      onLongPressEnd: (_) {
        if (_isRecording) {
          _stopRecording();
        }
      },
      onLongPressCancel: () {
        if (_isRecording) {
          _cancelRecording();
        }
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
        return const Icon(
          Icons.mic,
          key: ValueKey('mic_icon'),
          color: Colors.white,
          size: 32,
        );
    }
  }

  Widget _buildRecordingIcon() {
    // Calculate progress as a percentage for visual feedback
    double progress = _isRecording
        ? (_currentRecordingSeconds / widget.maxRecordingDurationInSeconds)
        : 0.0;

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
              // Timer countdown indicator
              if (_isRecording)
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 2.0,
                  color: Colors.white,
                  backgroundColor: Colors.white.withOpacity(0.2),
                ),
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
