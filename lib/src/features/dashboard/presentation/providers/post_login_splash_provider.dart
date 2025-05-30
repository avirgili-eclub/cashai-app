import 'dart:developer' as developer;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'post_login_splash_provider.g.dart';

// Possible navigation states after login
enum PostLoginNavigationState {
  splash, // Show regular splash screen
  onboarding, // Show onboarding for first-time users
  dashboard, // Go directly to dashboard
}

// Enhanced provider that controls both splash and onboarding after login
@riverpod
class PostLoginSplashState extends _$PostLoginSplashState {
  @override
  PostLoginNavigationState build() {
    developer.log('Building PostLoginSplashState', name: 'splash_provider');

    // Default: don't show anything, go directly to dashboard
    return PostLoginNavigationState.dashboard;
  }

  // Show the regular splash screen
  void showSplash() {
    developer.log('Showing splash screen', name: 'splash_provider');
    state = PostLoginNavigationState.splash;
  }

  // Show the onboarding screen for first-time users
  void showOnboarding() {
    developer.log('Showing onboarding screen', name: 'splash_provider');
    state = PostLoginNavigationState.onboarding;
  }

  // Hide any splash/onboarding screen and go to dashboard
  void goToDashboard() {
    developer.log('Navigating to dashboard', name: 'splash_provider');
    state = PostLoginNavigationState.dashboard;
  }

  // Hide the splash screen
  void hideSplash() {
    developer.log('Hiding splash screen', name: 'splash_provider');
    state = PostLoginNavigationState.dashboard;
  }
}
