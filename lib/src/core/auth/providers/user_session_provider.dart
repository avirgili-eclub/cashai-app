import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_session_provider.g.dart';

class UserSession {
  final String userId;
  final String? token;
  final String? username;
  final String? email;

  UserSession({
    required this.userId,
    this.token,
    this.username,
    this.email,
  });
}

@riverpod
class UserSessionNotifier extends _$UserSessionNotifier {
  @override
  UserSession build() {
    // Default userId for development/testing
    return UserSession(userId: '1');
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
    // Add logic to clear the user session
    state = UserSession(userId: ''); // Reset the session state
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
