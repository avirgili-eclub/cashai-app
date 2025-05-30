import 'package:concentric_transition/concentric_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/auth/providers/user_session_provider.dart';
import '../../../../core/styles/app_styles.dart';
import '../../../dashboard/presentation/providers/post_login_splash_provider.dart';

// State provider to store onboarding user data
final onboardingUserDataProvider = StateProvider<Map<String, dynamic>>((ref) {
  return {
    'monthlyIncome': 0.0,
    'selectedCategories': <String>[],
    'birthDate': null,
    'savingsGoal': 0.0,
  };
});

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  final _incomeController = TextEditingController();
  final _savingsGoalController = TextEditingController();
  DateTime? _selectedDate;
  final List<String> _selectedCategories = [];

  // List of common expense categories
  final List<CategoryOption> _categories = [
    CategoryOption(id: 'food', name: 'Comida', icon: Icons.restaurant),
    CategoryOption(
        id: 'transport', name: 'Transporte', icon: Icons.directions_car),
    CategoryOption(
        id: 'entertainment', name: 'Entretenimiento', icon: Icons.movie),
    CategoryOption(id: 'shopping', name: 'Compras', icon: Icons.shopping_bag),
    CategoryOption(id: 'bills', name: 'Facturas', icon: Icons.receipt),
    CategoryOption(id: 'health', name: 'Salud', icon: Icons.local_hospital),
    CategoryOption(id: 'education', name: 'Educación', icon: Icons.school),
    CategoryOption(id: 'travel', name: 'Viajes', icon: Icons.flight),
    CategoryOption(id: 'home', name: 'Hogar', icon: Icons.home),
    CategoryOption(id: 'other', name: 'Otros', icon: Icons.more_horiz),
  ];

  @override
  void dispose() {
    _incomeController.dispose();
    _savingsGoalController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _updateUserData() {
    ref.read(onboardingUserDataProvider.notifier).state = {
      'monthlyIncome': double.tryParse(_incomeController.text) ?? 0.0,
      'selectedCategories': _selectedCategories,
      'birthDate': _selectedDate,
      'savingsGoal': double.tryParse(_savingsGoalController.text) ?? 0.0,
    };
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ??
          DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6366F1),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _updateUserData();
    }
  }

  void _toggleCategory(String categoryId) {
    setState(() {
      if (_selectedCategories.contains(categoryId)) {
        _selectedCategories.remove(categoryId);
      } else {
        _selectedCategories.add(categoryId);
      }
    });
    _updateUserData();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final pages = [
      // Welcome page
      _buildWelcomePage(context),

      // Monthly Income Page
      _buildIncomePage(context),

      // Categories Selection Page
      _buildCategoriesPage(context),

      // Personal Info Page
      _buildPersonalInfoPage(context),

      // Final Page
      _buildFinalPage(context),
    ];

    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const ClampingScrollPhysics(),
        children: pages,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button
            TextButton(
              onPressed: () {
                if (_pageController.page! > 0) {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                }
              },
              child: const Text(
                'Atrás',
                style: TextStyle(color: Color(0xFF6366F1)),
              ),
            ),

            // Page indicator
            Row(
              children: List.generate(
                pages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _pageController.hasClients &&
                            _pageController.page?.round() == index
                        ? const Color(0xFF6366F1)
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            ),

            // Next/Finish button
            TextButton(
              onPressed: () {
                if (_pageController.page! < pages.length - 1) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                } else {
                  // Complete onboarding
                  _completeOnboarding(ref, context);
                }
              },
              child: Text(
                _pageController.hasClients &&
                        _pageController.page?.round() == pages.length - 1
                    ? 'Finalizar'
                    : 'Siguiente',
                style: const TextStyle(color: Color(0xFF6366F1)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage(BuildContext context) {
    return Container(
      color: const Color(0xFF6366F1),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/onboarding1.png',
            height: 200,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 200,
                width: 200,
                color: Colors.white.withOpacity(0.2),
                child: const Icon(
                  Icons.image_not_supported,
                  color: Colors.white,
                  size: 50,
                ),
              );
            },
          ),
          const SizedBox(height: 30),
          const Text(
            '¡Bienvenido a CashAI!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Vamos a configurar tu cuenta para personalizar tu experiencia',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF6366F1),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            },
            child: const Text(
              'Empezar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomePage(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.account_balance_wallet,
            size: 80,
            color: Color(0xFF6366F1),
          ),
          const SizedBox(height: 30),
          const Text(
            '¿Cuál es tu ingreso mensual?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Esto nos ayudará a establecer metas financieras realistas para ti',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _incomeController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => _updateUserData(),
              decoration: const InputDecoration(
                prefixText: '\$ ',
                hintText: '0',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 15),
              ),
              style: const TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            '¿Cuánto te gustaría ahorrar mensualmente?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _savingsGoalController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => _updateUserData(),
              decoration: const InputDecoration(
                prefixText: '\$ ',
                hintText: '0',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 15),
              ),
              style: const TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesPage(BuildContext context) {
    return Container(
      color: const Color(0xFF34C759),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Text(
            'Selecciona tus categorías de gastos más frecuentes',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Esto nos ayudará a personalizar tu experiencia',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.9,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategories.contains(category.id);

                return GestureDetector(
                  onTap: () => _toggleCategory(category.id),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: const Color(0xFF34C759), width: 2)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF34C759)
                                : Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            category.icon,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF34C759),
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          category.name,
                          style: TextStyle(
                            color: isSelected
                                ? const Color(0xFF34C759)
                                : Colors.white,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF34C759),
                            size: 18,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoPage(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.person,
            size: 80,
            color: Color(0xFF6366F1),
          ),
          const SizedBox(height: 30),
          const Text(
            'Información Personal',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Esta información nos ayudará a personalizar tu experiencia',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.grey),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _selectedDate != null
                          ? 'Fecha de nacimiento: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}'
                          : 'Selecciona tu fecha de nacimiento',
                      style: TextStyle(
                        color:
                            _selectedDate != null ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalPage(BuildContext context) {
    final userData = ref.watch(onboardingUserDataProvider);

    return Container(
      color: const Color(0xFF6366F1),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle,
            size: 100,
            color: Colors.white,
          ),
          const SizedBox(height: 30),
          const Text(
            '¡Todo listo!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Hemos personalizado tu experiencia en base a tus preferencias',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          // Display collected information
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                    'Ingreso mensual:', '\$${userData['monthlyIncome']}'),
                const SizedBox(height: 10),
                _buildInfoRow(
                    'Meta de ahorro:', '\$${userData['savingsGoal']}'),
                const SizedBox(height: 10),
                _buildInfoRow(
                    'Fecha de nacimiento:',
                    userData['birthDate'] != null
                        ? DateFormat('dd/MM/yyyy').format(userData['birthDate'])
                        : 'No especificada'),
                const SizedBox(height: 10),
                const Text(
                  'Categorías seleccionadas:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (userData['selectedCategories'] as List<String>)
                      .map((categoryId) {
                    final category = _categories.firstWhere(
                      (c) => c.id == categoryId,
                      orElse: () =>
                          CategoryOption(id: '', name: '', icon: Icons.error),
                    );
                    return category.id.isNotEmpty
                        ? Chip(
                            backgroundColor: Colors.white,
                            label: Text(
                              category.name,
                              style: const TextStyle(color: Color(0xFF6366F1)),
                            ),
                            avatar: Icon(
                              category.icon,
                              color: const Color(0xFF6366F1),
                              size: 18,
                            ),
                          )
                        : const SizedBox.shrink();
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF6366F1),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => _completeOnboarding(ref, context),
            child: const Text(
              'Comenzar a usar CashAI',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // Extract method to avoid code duplication
  void _completeOnboarding(WidgetRef ref, BuildContext context) async {
    // Send collected data to backend
    final userData = ref.read(onboardingUserDataProvider);

    // TODO: Send data to backend API
    // Example: await apiService.saveUserPreferences(userData);

    // Mark onboarding as completed in user session
    await ref
        .read(userSessionNotifierProvider.notifier)
        .setOnboardingCompleted();

    // Set navigation state to dashboard
    ref.read(postLoginSplashStateProvider.notifier).goToDashboard();

    // Navigate to dashboard
    context.go('/dashboard');
  }
}

// Helper class for category selection
class CategoryOption {
  final String id;
  final String name;
  final IconData icon;

  CategoryOption({
    required this.id,
    required this.name,
    required this.icon,
  });
}
