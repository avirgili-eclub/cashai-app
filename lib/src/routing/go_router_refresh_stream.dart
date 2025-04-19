import 'dart:async';

import 'package:flutter/foundation.dart';

/// A [Listenable] implementation that can be used with Go Router's
/// [GoRouter.refreshListenable] parameter.
class GoRouterRefreshStream extends ChangeNotifier {
  /// Creates a [GoRouterRefreshStream].
  ///
  /// Every time the provided [stream] emits an event, this will notify its
  /// listeners.
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
