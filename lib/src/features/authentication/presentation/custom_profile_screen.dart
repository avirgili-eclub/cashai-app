import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:numia/src/core/styles/app_styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;

import '../../../core/auth/providers/user_session_provider.dart';
import '../../../routing/app_router.dart';

class CustomProfileScreen extends ConsumerWidget {
  const CustomProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the current user session
    final userSession = ref.watch(userSessionNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey,
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              userSession.username ?? 'Usuario',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              userSession.email ?? 'usuario@example.com',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            // Show authentication status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: userSession.token != null
                    ? Colors.green[100]
                    : Colors.orange[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                userSession.token != null
                    ? 'Autenticado con token JWT'
                    : 'No autenticado con JWT',
                style: TextStyle(
                  color: userSession.token != null
                      ? Colors.green[800]
                      : Colors.orange[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 40),
            _buildProfileOption(context, 'Editar Perfil', Icons.edit, () {}),
            _buildProfileOption(
                context, 'Cambiar Contraseña', Icons.lock, () {}),
            _buildProfileOption(
                context, 'Notificaciones', Icons.notifications, () {}),
            _buildProfileOption(context, 'Preferencias', Icons.settings, () {}),
            const Divider(),
            _buildProfileOption(context, 'Cerrar Sesión', Icons.logout, () {
              _showSignOutConfirmationDialog(context, ref);
            }, isDestructive: true),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(
      BuildContext context, String title, IconData icon, VoidCallback onPressed,
      {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : null),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : null,
          fontWeight: isDestructive ? FontWeight.bold : null,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onPressed,
    );
  }

  // Show confirmation dialog before signing out
  void _showSignOutConfirmationDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _handleSignOut(context, ref);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleSignOut(BuildContext context, WidgetRef ref) async {
    // Show loading indicator
    final overlay = LoadingOverlay.of(context);
    overlay.show();

    try {
      developer.log('Starting sign out process', name: 'profile_screen');

      // Log JWT token status before clearing
      final sessionBefore = ref.read(userSessionNotifierProvider);
      developer.log(
          'Before logout - userId: ${sessionBefore.userId}, hasToken: ${sessionBefore.token != null}',
          name: 'profile_screen');

      // Sign out from Firebase Auth if using it
      if (FirebaseAuth.instance.currentUser != null) {
        await FirebaseAuth.instance.signOut();
        developer.log('Signed out from Firebase Auth', name: 'profile_screen');
      }

      // Clear the user session - this will remove the JWT token
      await ref.read(userSessionNotifierProvider.notifier).clearSession();

      // Verify the session was cleared
      final sessionAfter = ref.read(userSessionNotifierProvider);
      developer.log(
          'After logout - userId: ${sessionAfter.userId}, hasToken: ${sessionAfter.token != null}',
          name: 'profile_screen');

      // Hide loading indicator
      overlay.hide();

      // Show success message and navigate
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sesión cerrada correctamente'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to sign in screen
        Future.delayed(const Duration(milliseconds: 500), () {
          if (context.mounted) {
            context.go('/signIn');
          }
        });
      }
    } catch (e) {
      // Hide loading indicator
      overlay.hide();

      developer.log('Error signing out: $e', name: 'profile_screen', error: e);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// A simple loading overlay helper
class LoadingOverlay {
  LoadingOverlay._();

  static LoadingOverlay of(BuildContext context) {
    return LoadingOverlay._();
  }

  void show() {
    // Implementation would show a loading indicator
    developer.log('Loading overlay shown', name: 'loading_overlay');
  }

  void hide() {
    // Implementation would hide the loading indicator
    developer.log('Loading overlay hidden', name: 'loading_overlay');
  }
}
