import 'package:flutter/material.dart';
import '../core/styles/app_styles.dart';

class AppSplashScreen extends StatelessWidget {
  final String loadingText;

  const AppSplashScreen({
    Key? key,
    this.loadingText = 'Cargando tus datos financieros...',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final splashImage = screenSize.height > 1080
        ? 'assets/images/splash_screen1080p.png'
        : 'assets/images/splash_screen.png';

    return Scaffold(
      backgroundColor:
          Colors.transparent, // Use app primary color instead of transparent
      body: Stack(
        children: [
          // Background image container
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(splashImage),
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Bottom loading bar and text overlay
          Positioned(
            left: 0,
            right: 0,
            bottom: 80,
            child: Column(
              children: [
                // Loading text
                Text(
                  loadingText,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),

                // Linear progress indicator
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: const LinearProgressIndicator(
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
