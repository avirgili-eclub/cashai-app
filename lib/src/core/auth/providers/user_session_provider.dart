import 'dart:developer' as developer;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_session_provider.g.dart';

class UserSession {
  final String? userId;
  final String? token;
  final String? username;
  final String? email;

  UserSession({
    this.userId,
    this.token,
    this.username,
    this.email,
  });

  // Add isEmpty utility method
  bool get isEmpty => userId == null || userId!.isEmpty;
}

@riverpod
class UserSessionNotifier extends _$UserSessionNotifier {
  @override
  UserSession build() {
    // Initialize with empty session instead of default user
    return UserSession();
  }

  void setUserId(String userId) {
    state = UserSession(
        userId: userId,
        token: state.token,
        username: state.username,
        email: state.email);
  }

  void setUserSession({
    required String userId,
    String? token,
    String? username,
    String? email,
  }) {
    state = UserSession(
        userId: userId, token: token, username: username, email: email);
  }

  Future<void> clearSession() async {
    // Log session clear
    developer.log('Clearing user session', name: 'user_session');

    // Completely reset the state with null values
    state = UserSession(
      userId: null,
      token: null,
      username: null,
      email: null,
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
}
