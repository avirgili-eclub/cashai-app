import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:currency_picker/currency_picker.dart';
import '../../../../core/auth/providers/user_session_provider.dart';
import '../../../../core/styles/app_styles.dart';
import '../../../../routing/app_router.dart';
import '../../domain/entities/user_subscription_type.dart';
import '../widgets/editable_field.dart';
// Add controller imports
import '../../../dashboard/presentation/controllers/balance_controller.dart';
import '../../../dashboard/presentation/controllers/categories_controller.dart';
import '../../../dashboard/presentation/controllers/transaction_controller.dart';
// Import the user profile controller
import '../controllers/user_profile_controller.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the current user session
    final userSession = ref.watch(userSessionNotifierProvider);

    // Watch the user profile data
    final userProfileAsync = ref.watch(userProfileControllerProvider);

    return userProfileAsync.when(
      data: (userProfile) {
        // Initialize controllers with data from profile
        final monthlyIncomeController = TextEditingController(
            text: userProfile.monthlyIncome?.toString() ?? '0');

        final shouldPromptCategorization =
            ValueNotifier<bool>(userProfile.askForAudioCategory);
        final shouldNotifyTransactions = ValueNotifier<bool>(
            userProfile.askForTransactionCategoryNotification);
        final shouldUseBiometrics =
            ValueNotifier<bool>(userProfile.authBiometric);

        // Currency selection state - get from profile if available
        final selectedCurrency = ValueNotifier<Currency>(
            userProfile.principalCurrency?.code != null
                ? CurrencyService()
                        .findByCode(userProfile.principalCurrency!.code!) ??
                    CurrencyService().findByCode('PYG') ??
                    CurrencyService().getAll().first
                : CurrencyService().findByCode('PYG') ??
                    CurrencyService().getAll().first);

        // Get subscription type from profile if available
        final subscriptionType = _getSubscriptionTypeFromString(
            userProfile.subscription?.type ?? 'FREE');

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
                // Refresh button
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => ref
                      .read(userProfileControllerProvider.notifier)
                      .refreshUserProfile(),
                  tooltip: 'Actualizar datos',
                ),
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
                        userProfile.username ??
                            userSession.username ??
                            'Usuario',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Subscription badge
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
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
                              value: userProfile.email ??
                                  userSession.email ??
                                  'No disponible',
                              icon: Icons.email_outlined,
                              onEdit: () => _showEditDialog(
                                context,
                                'Correo electrónico',
                                userProfile.email ?? userSession.email ?? '',
                                (newEmail) {
                                  // Update email through controller
                                  ref
                                      .read(userProfileControllerProvider
                                          .notifier)
                                      .updateUserProfile({'email': newEmail});
                                },
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Nickname field
                            EditableField(
                              label: 'Nombre de usuario',
                              value: userProfile.username ??
                                  userSession.username ??
                                  'No disponible',
                              icon: Icons.person_outline,
                              onEdit: () => _showEditDialog(
                                context,
                                'Nombre de usuario',
                                userProfile.username ??
                                    userSession.username ??
                                    '',
                                (newUsername) {
                                  // Update username through controller
                                  ref
                                      .read(userProfileControllerProvider
                                          .notifier)
                                      .updateUserProfile(
                                          {'username': newUsername});
                                },
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Phone field (now editable using profile data)
                            EditableField(
                              label: 'Teléfono',
                              value: userProfile.celular ?? '+595 981 123456',
                              icon: Icons.phone_android,
                              onEdit: () => _showEditDialog(
                                context,
                                'Teléfono',
                                userProfile.celular ?? '',
                                (newPhone) {
                                  // Update phone through controller
                                  ref
                                      .read(userProfileControllerProvider
                                          .notifier)
                                      .updateUserProfile({'celular': newPhone});
                                },
                              ),
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade300),
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
                                      // Update monthly income through controller
                                      if (value.isNotEmpty) {
                                        double? amount = double.tryParse(value);
                                        if (amount != null) {
                                          ref
                                              .read(
                                                  userProfileControllerProvider
                                                      .notifier)
                                              .updateUserProfile(
                                                  {'monthlyIncome': amount});
                                        }
                                      }
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
                                  color:
                                      AppStyles.primaryColor.withOpacity(0.1),
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

                            // Audio categorization prompt preference with icon
                            ValueListenableBuilder(
                              valueListenable: shouldPromptCategorization,
                              builder: (context, value, child) {
                                return SwitchListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text(
                                    'Confirmar categoría en audios',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  subtitle: const Text(
                                    'Preguntar qué categoría asignar al enviar un audio',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  value: value,
                                  activeColor: AppStyles.primaryColor,
                                  onChanged: (newValue) {
                                    shouldPromptCategorization.value = newValue;
                                    // Update preference through controller
                                    ref
                                        .read(userProfileControllerProvider
                                            .notifier)
                                        .updateUserProfile(
                                            {'askForAudioCategory': newValue});
                                  },
                                  secondary: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppStyles.primaryColor
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.mic_outlined,
                                      color: AppStyles.primaryColor,
                                    ),
                                  ),
                                );
                              },
                            ),

                            // Transaction notification preference with icon
                            ValueListenableBuilder(
                              valueListenable: shouldNotifyTransactions,
                              builder: (context, value, child) {
                                return SwitchListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text(
                                    'Notificar categorización',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  subtitle: const Text(
                                    'Notificar la categoría asignada a cada transacción',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  value: value,
                                  activeColor: AppStyles.primaryColor,
                                  onChanged: (newValue) {
                                    shouldNotifyTransactions.value = newValue;
                                    // Update preference through controller
                                    ref
                                        .read(userProfileControllerProvider
                                            .notifier)
                                        .updateUserProfile({
                                      'askForTransactionCategoryNotification':
                                          newValue
                                    });
                                  },
                                  secondary: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppStyles.primaryColor
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.notifications_outlined,
                                      color: AppStyles.primaryColor,
                                    ),
                                  ),
                                );
                              },
                            ),

                            // Biometric authentication preference
                            ValueListenableBuilder(
                              valueListenable: shouldUseBiometrics,
                              builder: (context, value, child) {
                                return SwitchListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text(
                                    'Usar autenticación biométrica',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  subtitle: const Text(
                                    'Iniciar sesión con Face ID o huella digital',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  value: value,
                                  activeColor: AppStyles.primaryColor,
                                  onChanged: (newValue) {
                                    shouldUseBiometrics.value = newValue;
                                    // Update preference through controller
                                    ref
                                        .read(userProfileControllerProvider
                                            .notifier)
                                        .updateUserProfile(
                                            {'authBiometric': newValue});
                                  },
                                  secondary: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppStyles.primaryColor
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.fingerprint,
                                      color: AppStyles.primaryColor,
                                    ),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 24),

                            // Currency selection moved to the end
                            const Text(
                              'Moneda',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),

                            ValueListenableBuilder(
                              valueListenable: selectedCurrency,
                              builder: (context, currency, _) {
                                return InkWell(
                                  onTap: () {
                                    showCurrencyPicker(
                                      context: context,
                                      showFlag: true,
                                      showCurrencyName: true,
                                      showCurrencyCode: true,
                                      onSelect: (Currency currency) {
                                        selectedCurrency.value = currency;
                                        // Update currency through controller
                                        ref
                                            .read(userProfileControllerProvider
                                                .notifier)
                                            .updateUserProfile({
                                          'principalCurrency': {
                                            'code': currency.code,
                                            'symbol': currency.symbol,
                                            'name': currency.name
                                          }
                                        });
                                      },
                                      favorite: [
                                        'PYG',
                                        'USD',
                                        'EUR',
                                        'BRL',
                                        'ARS'
                                      ],
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              CurrencyUtils.currencyToEmoji(
                                                  currency),
                                              style:
                                                  const TextStyle(fontSize: 24),
                                            ),
                                            const SizedBox(width: 12),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  currency.name,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Text(
                                                  currency.code,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const Icon(Icons.arrow_drop_down),
                                      ],
                                    ),
                                  ),
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
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: Text(
                                          userProfile.subscription?.status ??
                                              'Actual',
                                          style: const TextStyle(
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
                                    userProfile.subscription?.description ??
                                        _getSubscriptionDescription(
                                            subscriptionType),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),

                                  // Add subscription dates if available
                                  if (userProfile.subscription?.startDate !=
                                      null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 16.0),
                                      child: Text(
                                        'Desde: ${_formatDate(userProfile.subscription?.startDate)}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),

                                  if (userProfile.subscription?.endDate != null)
                                    Text(
                                      'Hasta: ${_formatDate(userProfile.subscription?.endDate)}',
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
      },
      loading: () => Scaffold(
        appBar: AppBar(
          title: const Text('Mi Perfil'),
          backgroundColor: AppStyles.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(
          title: const Text('Mi Perfil'),
          backgroundColor: AppStyles.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Error al cargar el perfil',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(userProfileControllerProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to format dates
  String _formatDate(DateTime? date) {
    if (date == null) return 'No disponible';
    return '${date.day}/${date.month}/${date.year}';
  }

  // Helper method to convert subscription type from string to enum
  UserSubscriptionType _getSubscriptionTypeFromString(String type) {
    switch (type.toUpperCase()) {
      case 'FREE':
        return UserSubscriptionType.free;
      case 'ADVANCE':
        return UserSubscriptionType.advance;
      case 'PRO':
        return UserSubscriptionType.pro;
      case 'PRO_ANNUAL':
        return UserSubscriptionType.proAnnual;
      default:
        return UserSubscriptionType.free;
    }
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
            onPressed: () async {
              // Close the dialog first
              Navigator.pop(context);
              // Invalidate data providers BEFORE clearing session
              ref.invalidate(balanceControllerProvider);
              ref.invalidate(categoriesControllerProvider);
              ref.invalidate(transactionsControllerProvider);

              // Clear the session
              await ref
                  .read(userSessionNotifierProvider.notifier)
                  .clearSession();

              // Navigate to sign-in page
              if (context.mounted) {
                context.go('/signIn');
              }
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
