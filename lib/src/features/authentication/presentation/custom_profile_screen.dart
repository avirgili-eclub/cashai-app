import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:starter_architecture_flutter_firebase/src/core/styles/app_styles.dart';

class CustomProfileScreen extends ConsumerWidget {
  const CustomProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This is a custom implementation that doesn't rely on Firebase UI Auth
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
            const Text(
              'Usuario',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'usuario@example.com',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
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
              // Implement logout functionality
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
}
