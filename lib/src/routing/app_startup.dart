import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:starter_architecture_flutter_firebase/src/constants/app_sizes.dart';
import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';
import '../core/auth/providers/user_session_provider.dart';
import 'app_router.dart'; // Import for router provider
import '../features/authentication/data/repositories/auth_repository_impl.dart';

part 'app_startup.g.dart';

// Store the initial route for the app
final initialRouteProvider = StateProvider<String>((ref) => '/signIn');

// https://codewithandrea.com/articles/robust-app-initialization-riverpod/
@Riverpod(keepAlive: true)
Future<void> appStartup(Ref ref) async {
  developer.log('Starting app initialization', name: 'app_startup');

  try {
    // Core Firebase initialization
    await Firebase.initializeApp();
    developer.log('Firebase initialized successfully', name: 'app_startup');

    // Wait for auth repository to be ready
    final authRepository = await ref.read(authRepositoryProvider);
    developer.log('Auth repository initialized', name: 'app_startup');

    // Check user session status
    final userSession = ref.read(userSessionNotifierProvider);
    final isAuthenticated = userSession.userId != null &&
        !userSession.isEmpty &&
        userSession.token != null &&
        userSession.token!.isNotEmpty;

    // Also check Firebase auth state as fallback
    final firebaseUser = authRepository.currentUser;

    final bool userIsLoggedIn = isAuthenticated || firebaseUser != null;

    // Set initial route based on authentication status
    if (userIsLoggedIn) {
      developer.log(
          'User already authenticated, setting initial route to dashboard',
          name: 'app_startup');
      // Use state setter instead of method call
      ref.read(initialRouteProvider.notifier).state = '/dashboard';
    } else {
      developer.log(
          'No authenticated session found, will start at login screen',
          name: 'app_startup');
      // Use state setter instead of method call
      ref.read(initialRouteProvider.notifier).state = '/signIn';
    }

    developer.log('App initialization completed', name: 'app_startup');
  } catch (e, stack) {
    developer.log('Error during app initialization: $e',
        name: 'app_startup', error: e, stackTrace: stack);
    rethrow;
  }
}

/// Widget class to manage asynchronous app initialization
class AppStartupWidget extends ConsumerWidget {
  const AppStartupWidget({super.key, required this.onLoaded});
  final WidgetBuilder onLoaded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStartupState = ref.watch(appStartupProvider);
    return appStartupState.when(
      data: (_) => onLoaded(context),
      loading: () => const AppStartupLoadingWidget(),
      error: (e, st) => AppStartupErrorWidget(
        message: e.toString(),
        onRetry: () => ref.invalidate(appStartupProvider),
      ),
    );
  }
}

/// Widget to show while initialization is in progress
class AppStartupLoadingWidget extends StatelessWidget {
  const AppStartupLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

/// Widget to show if initialization fails
class AppStartupErrorWidget extends StatelessWidget {
  const AppStartupErrorWidget(
      {super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, style: Theme.of(context).textTheme.headlineSmall),
            gapH16,
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
