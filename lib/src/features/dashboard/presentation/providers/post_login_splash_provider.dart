import 'dart:developer' as developer;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'post_login_splash_provider.g.dart';

// Este provider controla si se debe mostrar el splash después del login
@riverpod
class PostLoginSplashState extends _$PostLoginSplashState {
  @override
  bool build() {
    developer.log('Initial build of PostLoginSplashState: false',
        name: 'splash_provider');
    // Por defecto, no mostrar el splash
    return false;
  }

  // Método para mostrar el splash
  void showSplash() {
    developer.log('Showing splash screen (current state: $state)',
        name: 'splash_provider');
    state = true;
  }

  // Método para ocultar el splash
  void hideSplash() {
    developer.log('Hiding splash screen (current state: $state)',
        name: 'splash_provider');
    state = false;
  }
}
