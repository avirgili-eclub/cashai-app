import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/auth/providers/user_session_provider.dart';
import '../../../../core/styles/app_styles.dart';
import '../../domain/entities/user_subscription_type.dart';
import '../widgets/editable_field.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the current user session
    final userSession = ref.watch(userSessionNotifierProvider);

    // Default values for user preferences
    final monthlyIncomeController = TextEditingController(text: '0');
    final shouldPromptCategorization = ValueNotifier<bool>(true);
    final shouldNotifyTransactions = ValueNotifier<bool>(false);

    // TODO: Replace with actual subscription retrieval
    const subscriptionType = UserSubscriptionType.free;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mi Perfil'),
          backgroundColor: AppStyles.primaryColor,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          actions: [
            // Logout button in the app bar for easy access
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _confirmLogout(context, ref),
              tooltip: 'Cerrar sesión',
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(
                text: 'Información',
                icon: Icon(Icons.person_outline),
              ),
              Tab(
                text: 'Preferencias',
                icon: Icon(Icons.settings_outlined),
              ),
              Tab(
                text: 'Suscripción',
                icon: Icon(Icons.card_membership_outlined),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            // User information header - stays visible across all tabs
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // User avatar
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: AppStyles.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.person,
                        size: 48,
                        color: AppStyles.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Username
                  Text(
                    userSession.username ?? 'Usuario',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Subscription badge
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getSubscriptionColor(subscriptionType),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _getSubscriptionLabel(subscriptionType),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tab content takes the rest of the screen
            Expanded(
              child: TabBarView(
                children: [
                  // Tab 1: Personal Information
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Información Personal',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Email field
                        EditableField(
                          label: 'Correo electrónico',
                          value: userSession.email ?? 'No disponible',
                          icon: Icons.email_outlined,
                          onEdit: () => _showEditDialog(
                            context,
                            'Correo electrónico',
                            userSession.email ?? '',
                            (newEmail) {
                              // TODO: Implement email update logic
                            },
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Nickname field
                        EditableField(
                          label: 'Nombre de usuario',
                          value: userSession.username ?? 'No disponible',
                          icon: Icons.person_outline,
                          onEdit: () => _showEditDialog(
                            context,
                            'Nombre de usuario',
                            userSession.username ?? '',
                            (newUsername) {
                              // TODO: Implement username update logic
                            },
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Phone field (read-only for now)
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppStyles.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.phone_android,
                              color: AppStyles.primaryColor,
                            ),
                          ),
                          title: const Text(
                            'Teléfono',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          subtitle: Text(
                            '+595 981 123456', // Replace with actual phone number
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),

                        const SizedBox(height: 16),

                        // Monthly income field moved to Personal Information
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ingreso mensual',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextField(
                                controller: monthlyIncomeController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  prefixText: 'Gs. ',
                                  hintText: '0',
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  // TODO: Save the monthly income value
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Password change option
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppStyles.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.lock_outline,
                              color: AppStyles.primaryColor,
                            ),
                          ),
                          title: const Text('Cambiar contraseña'),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          contentPadding: EdgeInsets.zero,
                          onTap: () => _showPasswordChangeDialog(context),
                        ),
                      ],
                    ),
                  ),

                  // Tab 2: Preferences
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Preferencias',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Audio categorization prompt preference
                        ValueListenableBuilder(
                          valueListenable: shouldPromptCategorization,
                          builder: (context, value, child) {
                            return SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text(
                                'Confirmar categoría en audios',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              subtitle: const Text(
                                'Preguntar qué categoría asignar al enviar un audio',
                                style: TextStyle(fontSize: 12),
                              ),
                              value: value,
                              activeColor: AppStyles.primaryColor,
                              onChanged: (newValue) {
                                shouldPromptCategorization.value = newValue;
                                // TODO: Save the preference
                              },
                            );
                          },
                        ),

                        // Transaction notification preference
                        ValueListenableBuilder(
                          valueListenable: shouldNotifyTransactions,
                          builder: (context, value, child) {
                            return SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text(
                                'Notificar categorización',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              subtitle: const Text(
                                'Notificar la categoría asignada a cada transacción',
                                style: TextStyle(fontSize: 12),
                              ),
                              value: value,
                              activeColor: AppStyles.primaryColor,
                              onChanged: (newValue) {
                                shouldNotifyTransactions.value = newValue;
                                // TODO: Save the preference
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // Tab 3: Subscription
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mi Suscripción',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Current subscription card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                            color: _getSubscriptionColor(subscriptionType)
                                .withOpacity(0.1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _getSubscriptionLabel(subscriptionType),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: _getSubscriptionColor(
                                          subscriptionType),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getSubscriptionColor(
                                          subscriptionType),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Text(
                                      'Actual',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _getSubscriptionDescription(subscriptionType),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    String field,
    String initialValue,
    Function(String) onSave,
  ) {
    final controller = TextEditingController(text: initialValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar $field'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Ingresa tu $field',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                onSave(controller.text);
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppStyles.primaryColor,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showPasswordChangeDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar contraseña'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              decoration: const InputDecoration(
                labelText: 'Contraseña actual',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(
                labelText: 'Nueva contraseña',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirmar nueva contraseña',
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement password change logic
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppStyles.primaryColor,
            ),
            child: const Text('Cambiar'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // Logout logic
              ref.read(userSessionNotifierProvider.notifier).clearSession();
              Navigator.pop(context);
              context.go('/login'); // Navigate to login screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  Color _getSubscriptionColor(UserSubscriptionType type) {
    switch (type) {
      case UserSubscriptionType.free:
        return Colors.green;
      case UserSubscriptionType.advance:
        return Colors.blue;
      case UserSubscriptionType.pro:
        return Colors.purple;
      case UserSubscriptionType.proAnnual:
        return Colors.indigo;
    }
  }

  String _getSubscriptionLabel(UserSubscriptionType type) {
    switch (type) {
      case UserSubscriptionType.free:
        return 'Plan Gratuito';
      case UserSubscriptionType.advance:
        return 'Plan Advance';
      case UserSubscriptionType.pro:
        return 'Plan Pro';
      case UserSubscriptionType.proAnnual:
        return 'Plan Pro Anual';
    }
  }

  String _getSubscriptionDescription(UserSubscriptionType type) {
    switch (type) {
      case UserSubscriptionType.free:
        return 'Incluye funcionalidades básicas para el manejo de tus finanzas personales.';
      case UserSubscriptionType.advance:
        return 'Incluye funcionalidades avanzadas para mejor manejo de tus finanzas.';
      case UserSubscriptionType.pro:
        return 'Acceso completo a todas las funcionalidades premium por mes.';
      case UserSubscriptionType.proAnnual:
        return 'Acceso completo a todas las funcionalidades premium por un año.';
    }
  }
}
