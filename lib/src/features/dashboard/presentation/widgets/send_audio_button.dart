import 'package:flutter/material.dart';

class SendAudioButton extends StatefulWidget {
  const SendAudioButton({Key? key}) : super(key: key);

  @override
  State<SendAudioButton> createState() => _SendAudioButtonState();
}

class _SendAudioButtonState extends State<SendAudioButton>
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) {
        setState(() {
          _isRecording = true;
        });
      },
      onLongPressEnd: (_) {
        setState(() {
          _isRecording = false;
        });
      },
      child: SizedBox(
        width: 72, // Explicit size for the FloatingActionButton
        height: 72, // Explicit size for the FloatingActionButton
        child: FittedBox(
          child: FloatingActionButton(
            onPressed: () {
              // Single tap action can be added here if needed
            },
            backgroundColor: Theme.of(context).primaryColor,
            elevation: 4.0,
            // Ensure the FAB doesn't use a preset size
            mini: false,
            heroTag: 'sendAudioButton',
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 100),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: _isRecording
                  ? _buildRecordingIcon()
                  : const Icon(
                      Icons.mic,
                      key: ValueKey('mic_icon'),
                      color: Colors.white,
                      size: 32,
                    ),
            ),
          ),
        ),
      ),
    );
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
