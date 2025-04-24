import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/styles/app_styles.dart';
import '../../../audio/presentation/controllers/audio_controller.dart';

class CategoryBottomNavBar extends ConsumerWidget {
  final String categoryId;

  const CategoryBottomNavBar({
    Key? key,
    required this.categoryId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioController = ref.watch(audioControllerProvider.notifier);
    final audioState = ref.watch(audioControllerProvider);

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, Icons.home, 'Inicio'),
          _buildNavItem(context, Icons.pie_chart, 'Estadísticas'),

          // Audio Button - Integrated directly in the navbar (not floating)
          GestureDetector(
            onLongPressStart: (_) async {
              await audioController.initialize();
              audioController.startRecording();
            },
            onLongPressEnd: (_) {
              audioController.stopRecordingAndUploadWithCategoryId(categoryId);
            },
            onLongPressCancel: () {
              audioController.cancelRecording();
            },
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _getButtonColor(audioState),
                shape: BoxShape.circle,
              ),
              child: _buildButtonContent(audioState, context),
            ),
          ),

          _buildNavItem(context, Icons.calendar_today, 'Calendario'),
          _buildNavItem(context, Icons.settings, 'Ajustes'),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label,
      {bool isActive = false}) {
    final color = isActive ? AppStyles.primaryColor : Colors.grey;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
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
        return AppStyles.primaryColor;
    }
  }

  Widget _buildButtonContent(AudioRecordingState state, BuildContext context) {
    switch (state) {
      case AudioRecordingState.recording:
        return _buildPulsatingMic();
      case AudioRecordingState.uploading:
        return const SizedBox(
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
          color: Colors.white,
          size: 28,
        );
      case AudioRecordingState.error:
        return const Icon(
          Icons.error,
          color: Colors.white,
          size: 28,
        );
      case AudioRecordingState.idle:
      default:
        return const Icon(
          Icons.mic,
          color: Colors.white,
          size: 28,
        );
    }
  }

  Widget _buildPulsatingMic() {
    return const Icon(
      Icons.mic,
      color: Colors.white,
      size: 28,
    );
  }
}
