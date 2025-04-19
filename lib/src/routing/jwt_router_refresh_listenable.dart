import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/auth/providers/user_session_provider.dart';

/// A [ChangeNotifier] that watches JWT authentication state from UserSession
class JwtAuthRefreshListenable extends ChangeNotifier {
  JwtAuthRefreshListenable(this._ref) {
    _subscription = _ref.listen<UserSession>(
      userSessionNotifierProvider,
      (previous, next) {
        // Notify listeners when token status changes
        if ((previous?.token == null && next.token != null) ||
            (previous?.token != null && next.token == null) ||
            previous?.userId != next.userId) {
          notifyListeners();
        }
      },
    );
  }

  final Ref _ref;
  late final ProviderSubscription<UserSession> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}

/// Provider for the JWT auth refresh listenable
final jwtAuthRefreshListenableProvider = Provider<JwtAuthRefreshListenable>(
  (ref) => JwtAuthRefreshListenable(ref),
);
