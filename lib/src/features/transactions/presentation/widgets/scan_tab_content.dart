import 'package:flutter/material.dart';
import '../../../../core/styles/app_styles.dart';

class ScanTabContent extends StatelessWidget {
  const ScanTabContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Camera Preview Area
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12.0),
              ),
              // This would be replaced with actual camera preview
              child: Stack(
                children: [
                  // Placeholder for camera preview
                  Center(
                    child: Icon(
                      Icons.camera_alt,
                      size: 48.0,
                      color: Colors.grey.shade400,
                    ),
                  ),

                  // Scanner Overlay
                  Center(
                    child: Container(
                      width: 250,
                      height: 350,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppStyles.primaryColor,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.crop_free,
                            size: 60.0,
                            color: Colors.white70,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Positioning instruction
                  Positioned(
                    bottom: 32.0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: const Text(
                          'Posiciona el ticket dentro del marco',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Instructions
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 16.0,
          ),
          child: Text(
            'Posiciona el ticket o factura con buena iluminación para mejores resultados. '
            'Nuestra IA extraerá y categorizará los detalles automáticamente.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14.0,
            ),
          ),
        ),

        // Capture Button
        Padding(
          padding: const EdgeInsets.only(bottom: 32.0),
          child: SizedBox(
            height: 72.0,
            width: 72.0,
            child: Material(
              elevation: 4.0,
              shape: const CircleBorder(),
              color: AppStyles.primaryColor,
              child: InkWell(
                onTap: () {
                  // Will implement camera capture later
                },
                customBorder: const CircleBorder(),
                child: const Icon(
                  Icons.camera_alt,
                  size: 32.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
