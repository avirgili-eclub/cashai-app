import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_session_provider.g.dart';

class UserSession {
  final String userId;

  UserSession({required this.userId});
}

@riverpod
class UserSessionNotifier extends _$UserSessionNotifier {
  @override
  UserSession build() {
    // Default userId for development/testing
    return UserSession(userId: '3');
  }

  void setUserId(String userId) {
    state = UserSession(userId: userId);
  }
}
