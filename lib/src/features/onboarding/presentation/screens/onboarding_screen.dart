import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/auth/providers/user_session_provider.dart';
import '../../../../core/styles/app_styles.dart';
import '../../../categories/data/datasources/firebase_category_datasource.dart';
import '../../../categories/domain/models/custom_category_request.dart';
import '../../../dashboard/presentation/providers/post_login_splash_provider.dart';
import '../../../user/presentation/controllers/user_profile_controller.dart';

// ---------------------------------------------------------------------------
// Local model for a category draft (lives in memory until submission)
// ---------------------------------------------------------------------------

class _CategoryDraft {
  final String name;
  final String emoji;
  final String color;
  final String? description;

  const _CategoryDraft({
    required this.name,
    required this.emoji,
    required this.color,
    this.description,
  });

  _CategoryDraft copyWith({
    String? name,
    String? emoji,
    String? color,
    String? description,
  }) {
    return _CategoryDraft(
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      color: color ?? this.color,
      description: description ?? this.description,
    );
  }
}

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const List<_CategoryDraft> _defaultCategories = [
  _CategoryDraft(
    name: 'Supermercado',
    emoji: '🛒',
    color: '#BDFCC9',
    description: 'Compras en el supermercado',
  ),
  _CategoryDraft(
    name: 'Ocio',
    emoji: '🎉',
    color: '#D8C2FF',
    description: 'Entretenimiento y diversión',
  ),
  _CategoryDraft(
    name: 'Restaurantes',
    emoji: '🍕',
    color: '#FFD3B6',
    description: 'Comidas fuera de casa',
  ),
];

const List<String> _availableEmojis = [
  '🍔', '🚗', '🎉', '🏠', '💼',
  '🛒', '🎮', '📚', '✈️', '⚡',
  '👕', '💄', '🎭', '🎸', '🏋️',
  '🍕', '☕', '🎬', '💻', '📱',
];

const List<String> _colorPalette = [
  '#FADADD', '#FFD3B6', '#FFFACD', '#BDFCC9', '#B6E3FF',
  '#D8BFD8', '#C9FFE5', '#FFB6B6', '#D8C2FF', '#FFE5B4',
];

const int _minCategories = 3;

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageController = PageController();
  final _incomeController = TextEditingController();

  // --- Categories state ---
  List<_CategoryDraft> _categories = List.from(_defaultCategories);

  // --- Inline form state ---
  bool _showAddForm = false;
  int? _editingIndex;
  final _formNameController = TextEditingController();
  final _formDescController = TextEditingController();
  String _formEmoji = '🍔';
  String _formColor = '#FFD3B6';

  // --- Completion page state ---
  bool _isSubmitting = false;
  bool _hasError = false;
  bool _isCompleted = false;

  // --- Page tracking ---
  int _currentPage = 0;

  // --- Check animation ---
  late final AnimationController _checkAnimController;
  late final Animation<double> _checkScale;

  @override
  void initState() {
    super.initState();
    _checkAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _checkScale = CurvedAnimation(
      parent: _checkAnimController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _incomeController.dispose();
    _formNameController.dispose();
    _formDescController.dispose();
    _checkAnimController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Color _hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 7 || hex.length == 9) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOutCubic,
    );
  }

  bool get _canAdvanceFromCategories => _categories.length >= _minCategories;

  void _handleNext() {
    if (_currentPage == 2 && !_canAdvanceFromCategories) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Necesitás al menos 3 categorías para continuar'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_currentPage < 3) _goToPage(_currentPage + 1);
  }

  void _handleBack() {
    if (_currentPage > 0) _goToPage(_currentPage - 1);
  }

  // --- Form helpers ---

  void _openAddForm() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _editingIndex = null;
      _formNameController.clear();
      _formDescController.clear();
      _formEmoji = '🍔';
      _formColor = '#FFD3B6';
      _showAddForm = true;
    });
  }

  void _openEditForm(int index) {
    FocusManager.instance.primaryFocus?.unfocus();
    final cat = _categories[index];
    setState(() {
      _editingIndex = index;
      _formNameController.text = cat.name;
      _formDescController.text = cat.description ?? '';
      _formEmoji = cat.emoji;
      _formColor = cat.color;
      _showAddForm = true;
    });
  }

  void _closeForm() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _showAddForm = false;
      _editingIndex = null;
    });
  }

  void _submitForm() {
    final name = _formNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El nombre de la categoría es obligatorio'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final draft = _CategoryDraft(
      name: name,
      emoji: _formEmoji,
      color: _formColor,
      description: _formDescController.text.trim().isNotEmpty
          ? _formDescController.text.trim()
          : null,
    );

    setState(() {
      if (_editingIndex != null) {
        final updated = List<_CategoryDraft>.from(_categories);
        updated[_editingIndex!] = draft;
        _categories = updated;
      } else {
        _categories = [..._categories, draft];
      }
      _showAddForm = false;
      _editingIndex = null;
    });
  }

  void _deleteCategory(int index) {
    setState(() {
      final updated = List<_CategoryDraft>.from(_categories);
      updated.removeAt(index);
      _categories = updated;
    });
  }

  // ---------------------------------------------------------------------------
  // API submission
  // ---------------------------------------------------------------------------

  Future<void> _completeOnboarding() async {
    if (_isSubmitting || _isCompleted) return;

    setState(() {
      _isSubmitting = true;
      _hasError = false;
    });

    try {
      final userSession = ref.read(userSessionNotifierProvider);
      final userId = userSession.userId;
      if (userId == null || userId.isEmpty) {
        throw Exception('Usuario no autenticado');
      }

      final income = double.tryParse(_incomeController.text) ?? 0.0;

      // 1. Update monthly income
      await ref
          .read(userProfileControllerProvider.notifier)
          .updateUserProfile({'monthlyIncome': income});

      // 2. Create all categories in parallel
      final dataSource = ref.read(categoryDataSourceProvider);
      await dataSource.createCustomCategories(
        _categories
            .map((c) => CustomCategoryRequest(
                  name: c.name,
                  emoji: c.emoji,
                  color: c.color,
                  description: c.description,
                ))
            .toList(),
        userId,
      );

      // 3. Mark onboarding complete and navigate
      await ref
          .read(userSessionNotifierProvider.notifier)
          .setOnboardingCompleted();

      ref.read(postLoginSplashStateProvider.notifier).goToDashboard();

      setState(() {
        _isSubmitting = false;
        _isCompleted = true;
      });
      _checkAnimController.forward();

      // Brief visual feedback before navigating
      await Future.delayed(const Duration(milliseconds: 1400));
      if (mounted) context.go('/dashboard');
    } catch (e, st) {
      developer.log(
        'Error completing onboarding: $e',
        name: 'onboarding_screen',
        error: e,
        stackTrace: st,
      );
      setState(() {
        _isSubmitting = false;
        _hasError = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar la configuración: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (page) {
          setState(() => _currentPage = page);
          if (page == 3) _completeOnboarding();
        },
        children: [
          _buildWelcomePage(),
          _buildIncomePage(),
          _buildCategoriesPage(),
          _buildCompletionPage(),
        ],
      ),
      bottomNavigationBar:
          _currentPage < 3 ? _buildBottomNav() : const SizedBox.shrink(),
    );
  }

  // ---------------------------------------------------------------------------
  // Bottom navigation bar (pages 0–2)
  // ---------------------------------------------------------------------------

  Widget _buildBottomNav() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, 16 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          TextButton(
            onPressed: _currentPage > 0 ? _handleBack : null,
            child: Text(
              'Atrás',
              style: TextStyle(
                color: _currentPage > 0
                    ? AppStyles.primaryColor
                    : Colors.grey.shade300,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ),

          // Page dots (only pages 0-2)
          Row(
            children: List.generate(3, (i) {
              final active = _currentPage == i;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: active ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: active
                      ? AppStyles.primaryColor
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),

          // Next / Finish button
          TextButton(
            onPressed: _handleNext,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _currentPage == 2 ? 'Finalizar' : 'Siguiente',
                  style: TextStyle(
                    color: AppStyles.primaryColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios,
                    size: 12, color: AppStyles.primaryColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Page 0 — Welcome
  // ---------------------------------------------------------------------------

  Widget _buildWelcomePage() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFFFF), Color(0xFFEEF2FF)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('💸', style: TextStyle(fontSize: 80)),
              const SizedBox(height: 32),
              const Text(
                'ANTES DE\nEMPEZAR',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E1B4B),
                  letterSpacing: 1.5,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Vamos a configurar las bases de tus finanzas en 2 simples pasos',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStepChip('1', '💰', 'Ingreso mensual'),
                  const SizedBox(width: 12),
                  _buildStepChip('2', '🗂️', 'Tus categorías'),
                ],
              ),
              const SizedBox(height: 52),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _goToPage(1),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyles.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Empezar',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepChip(String number, String emoji, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E7FF), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: AppStyles.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(emoji, style: const TextStyle(fontSize: 15)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E1B4B),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Page 1 — Monthly Income
  // ---------------------------------------------------------------------------

  Widget _buildIncomePage() {
    return Container(
      color: const Color(0xFFF8FAFF),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              const Text('💰', style: TextStyle(fontSize: 72)),
              const SizedBox(height: 28),
              const Text(
                '¿Cuánto ganás\npor mes?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E1B4B),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Este dato nos ayuda a analizar tus gastos en contexto',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE0E7FF),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(14),
                          bottomLeft: Radius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Gs.',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppStyles.primaryColor,
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _incomeController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E1B4B),
                        ),
                        decoration: const InputDecoration(
                          hintText: '0',
                          hintStyle: TextStyle(
                            color: Colors.black26,
                            fontSize: 28,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Podés actualizar esto en cualquier momento desde tu perfil',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Page 2 — Categories
  // ---------------------------------------------------------------------------

  Widget _buildCategoriesPage() {
    return Container(
      color: const Color(0xFFF0FFF4),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                children: [
                  const Text('🗂️', style: TextStyle(fontSize: 44)),
                  const SizedBox(height: 10),
                  const Text(
                    'Tus categorías de gastos',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E1B4B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Modificá, eliminá o agregá las que usás más seguido',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  // Category counter badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _canAdvanceFromCategories
                          ? const Color(0xFF22C55E).withValues(alpha: 0.13)
                          : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_categories.length} categoría${_categories.length == 1 ? '' : 's'} · mínimo $_minCategories',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _canAdvanceFromCategories
                            ? const Color(0xFF16A34A)
                            : Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                children: [
                  ..._categories.asMap().entries.map(
                        (e) => _buildCategoryCard(e.value, e.key),
                      ),
                  const SizedBox(height: 4),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: _showAddForm
                        ? _buildInlineForm()
                        : _buildAddButton(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(_CategoryDraft cat, int index) {
    final bgColor = _hexToColor(cat.color);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bgColor.withValues(alpha: 0.7), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: bgColor.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Emoji circle with category color
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(cat.emoji,
                  style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14),
          // Name and description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cat.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E1B4B),
                  ),
                ),
                if (cat.description != null &&
                    cat.description!.isNotEmpty)
                  Text(
                    cat.description!,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          // Edit button
          GestureDetector(
            onTap: () => _openEditForm(index),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(Icons.edit_outlined,
                  size: 20, color: Colors.grey.shade500),
            ),
          ),
          const SizedBox(width: 2),
          // Delete button (disabled if only 1 category left)
          GestureDetector(
            onTap: _categories.length > 1
                ? () => _deleteCategory(index)
                : null,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                Icons.delete_outline,
                size: 20,
                color: _categories.length > 1
                    ? Colors.red.shade300
                    : Colors.grey.shade200,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return OutlinedButton.icon(
      key: const ValueKey('add_btn'),
      onPressed: _openAddForm,
      icon: const Icon(Icons.add_circle_outline, size: 20),
      label: const Text('Agregar categoría'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppStyles.primaryColor,
        side: BorderSide(
            color: AppStyles.primaryColor.withValues(alpha: 0.5), width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding:
            const EdgeInsets.symmetric(vertical: 13, horizontal: 20),
        textStyle: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildInlineForm() {
    return Container(
      key: const ValueKey('inline_form'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E7FF), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Form header
          Row(
            children: [
              Text(
                _editingIndex != null
                    ? 'Editar categoría'
                    : 'Nueva categoría',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E1B4B),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _closeForm,
                child: Icon(Icons.close,
                    size: 20, color: Colors.grey.shade500),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Name field
          _formLabel('Nombre'),
          const SizedBox(height: 6),
          TextField(
            controller: _formNameController,
            textCapitalization: TextCapitalization.sentences,
            decoration: _inputDecoration('ej. Supermercado'),
          ),
          const SizedBox(height: 12),

          // Description field
          _formLabel('Descripción (opcional)'),
          const SizedBox(height: 6),
          TextField(
            controller: _formDescController,
            maxLines: 2,
            decoration:
                _inputDecoration('ej. Para gastos de supermercado'),
          ),
          const SizedBox(height: 14),

          // Emoji picker
          _formLabel('Emoji'),
          const SizedBox(height: 8),
          SizedBox(
            height: 96,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 10,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemCount: _availableEmojis.length,
              itemBuilder: (context, i) {
                final emoji = _availableEmojis[i];
                final selected = emoji == _formEmoji;
                return GestureDetector(
                  onTap: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    setState(() => _formEmoji = emoji);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: selected
                          ? AppStyles.primaryColor.withValues(alpha: 0.1)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: selected
                            ? AppStyles.primaryColor
                            : Colors.grey.shade200,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(emoji,
                          style: const TextStyle(fontSize: 17)),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),

          // Color picker
          _formLabel('Color'),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _colorPalette.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final hex = _colorPalette[i];
                final selected = hex == _formColor;
                return GestureDetector(
                  onTap: () => setState(() => _formColor = hex),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _hexToColor(hex),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected
                            ? Colors.black54
                            : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                    child: selected
                        ? const Icon(Icons.check,
                            size: 16, color: Colors.black54)
                        : null,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 18),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyles.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 13),
                elevation: 0,
              ),
              child: Text(
                _editingIndex != null ? 'Guardar cambios' : 'Agregar',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _formLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.grey,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppStyles.primaryColor, width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    );
  }

  // ---------------------------------------------------------------------------
  // Page 3 — Completion
  // ---------------------------------------------------------------------------

  Widget _buildCompletionPage() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: _buildCompletionContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionContent() {
    if (_isCompleted) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _checkScale,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('✅', style: TextStyle(fontSize: 52)),
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            '¡Todo listo!',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '¡Configuración guardada!\nEntrando a CashAI...',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.85),
              height: 1.5,
            ),
          ),
        ],
      );
    }

    if (_hasError) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 72)),
          const SizedBox(height: 24),
          const Text(
            'Algo salió mal',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No se pudo guardar tu configuración.\nRevisá tu conexión e intentá de nuevo.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: _completeOnboarding,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text(
              'Reintentar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppStyles.primaryColor,
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
          ),
        ],
      );
    }

    // Default: submitting / loading
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 64,
          height: 64,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3,
          ),
        ),
        const SizedBox(height: 36),
        const Text(
          'Guardando tu\nconfiguración...',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Estamos creando tus categorías e ingreso mensual',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Colors.white.withValues(alpha: 0.75),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
