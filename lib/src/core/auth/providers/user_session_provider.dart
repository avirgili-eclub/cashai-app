import 'dart:developer' as developer;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'user_session_provider.g.dart';

class UserSession {
  final String? userId;
  final String? token;
  final String? username;
  final String? email;
  final bool hasCompletedOnboarding;

  UserSession({
    this.userId,
    this.token,
    this.username,
    this.email,
    this.hasCompletedOnboarding = false,
  });

  // Add isEmpty utility method
  bool get isEmpty => userId == null || userId!.isEmpty;
}

@riverpod
class UserSessionNotifier extends _$UserSessionNotifier {
  SharedPreferences? _prefs;

  @override
  UserSession build() {
    // Initialize with default state - not async
    return UserSession();
  }

  // Initialize SharedPreferences - call this early in app lifecycle
  Future<void> initialize() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();

      // Check if onboarding has been completed - default to FALSE
      // para garantizar que se muestra el onboarding si no hay información
      final hasCompletedOnboarding =
          _prefs?.getBool('hasCompletedOnboarding') ?? false;

      developer.log(
          'Initializing UserSession, hasCompletedOnboarding from SharedPreferences: $hasCompletedOnboarding',
          name: 'user_session');

      // Update state with the onboarding status
      state = UserSession(
        userId: state.userId,
        token: state.token,
        username: state.username,
        email: state.email,
        hasCompletedOnboarding: hasCompletedOnboarding,
      );
    }
  }

  void setUserId(String userId) {
    state = UserSession(
      userId: userId,
      token: state.token,
      username: state.username,
      email: state.email,
      hasCompletedOnboarding: state.hasCompletedOnboarding,
    );
  }

  void setUserSession({
    required String userId,
    String? token,
    String? username,
    String? email,
  }) {
    state = UserSession(
      userId: userId,
      token: token,
      username: username,
      email: email,
      hasCompletedOnboarding: state.hasCompletedOnboarding,
    );
  }

  // Add a method to mark onboarding as completed
  Future<void> setOnboardingCompleted() async {
    developer.log('Setting onboarding as completed', name: 'user_session');

    // Save to SharedPreferences
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }

    await _prefs!.setBool('hasCompletedOnboarding', true);

    // Update state with new onboarding value
    state = UserSession(
      userId: state.userId,
      token: state.token,
      username: state.username,
      email: state.email,
      hasCompletedOnboarding: state.hasCompletedOnboarding,
    );
  }

  Future<void> clearSession() async {
    // Log session clear
    developer.log('Clearing user session', name: 'user_session');

    // Get current onboarding status
    bool hasCompletedOnboarding = state.hasCompletedOnboarding;

    // If not initialized yet, read from SharedPreferences
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
      hasCompletedOnboarding =
          _prefs?.getBool('hasCompletedOnboarding') ?? false;
    }

    // Completely reset the state with null values but preserve onboarding status
    state = UserSession(
      userId: null,
      token: null,
      username: null,
      email: null,
      hasCompletedOnboarding: hasCompletedOnboarding,
    );
  }

  // Get the authorization header for API requests
  Map<String, String> getAuthHeaders() {
    final headers = {
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json; charset=utf-8',
    };

    if (state.token != null && state.token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${state.token}';
    }

    return headers;
  }

  // Add a specific method for setting user session after login
  // that handles the isFirstLogin flag from the API
  void setUserSessionAfterLogin({
    required String userId,
    String? token,
    String? username,
    String? email,
    required bool isFirstLogin,
  }) async {
    developer.log(
        'Setting user session after login with isFirstLogin: $isFirstLogin',
        name: 'user_session');

    // Cuando isFirstLogin es true, hasCompletedOnboarding debe ser false
    // para mostrar la pantalla de onboarding
    bool hasCompletedOnboarding = !isFirstLogin;

    // Para inicios de sesión por primera vez, siempre queremos mostrar onboarding
    if (isFirstLogin && _prefs != null) {
      await _prefs!.setBool('hasCompletedOnboarding', false);
      developer.log(
          'Setting hasCompletedOnboarding to FALSE in SharedPreferences',
          name: 'user_session');
    }

    // Update the session state
    state = UserSession(
      userId: userId,
      token: token,
      username: username,
      email: email,
      hasCompletedOnboarding: hasCompletedOnboarding,
    );
  }
}
