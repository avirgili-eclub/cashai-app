import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import '../../../../core/styles/app_styles.dart';
import '../../../../core/utils/emoji_formatter.dart';
import '../../../../core/utils/color_utils.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/presentation/widgets/money_text.dart';
import '../../../dashboard/domain/entities/top_category.dart';
import '../../../dashboard/domain/entities/recent_transaction.dart';
import '../widgets/category_bottom_nav_bar.dart';
import '../controllers/category_transactions_controller.dart';
import '../../domain/entities/transaction_category_dto.dart';
import '../../../../core/auth/providers/user_session_provider.dart';

class CategoryTransactionsScreen extends ConsumerStatefulWidget {
  final String categoryId;
  final TopCategory? category;

  const CategoryTransactionsScreen({
    Key? key,
    required this.categoryId,
    this.category,
  }) : super(key: key);

  @override
  ConsumerState<CategoryTransactionsScreen> createState() =>
      _CategoryTransactionsScreenState();
}

class _CategoryTransactionsScreenState
    extends ConsumerState<CategoryTransactionsScreen> {
  String _selectedPeriod = '';
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;
    _selectedPeriod =
        DateFormat('MMMM yyyy', 'es_ES').format(DateTime(now.year, now.month));
  }

  @override
  Widget build(BuildContext context) {
    developer.log(
        'Building CategoryTransactionsScreen for category: ${widget.categoryId}',
        name: 'category_transactions');

    final categoryTransactions = ref.watch(
      categoryTransactionsControllerProvider(widget.categoryId),
    );

    final displayCategory =
        widget.category ?? _getMockTopCategory(widget.categoryId);

    final Widget categoryIcon = EmojiFormatter.emojiToWidget(
      displayCategory.emoji,
      fontSize: 24,
      fallbackIcon: Icons.category,
      fallbackColor: Colors.blue,
      loggerName: 'category_transactions',
    );

    final Color categoryColor = ColorUtils.fromHex(
      displayCategory.color,
      defaultColor: const Color(0xFFBBDEFB),
      loggerName: 'category_transactions',
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: categoryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: categoryIcon,
            ),
            const SizedBox(width: 12),
            Text(displayCategory.name),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppStyles.primaryColor.withOpacity(0.8),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppStyles.primaryColor.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 24,
              ),
            ),
            onPressed: () {
              _showTransactionModal(context);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildDateRangeSelector(context),
          Expanded(
            child: categoryTransactions.when(
              data: (data) =>
                  _buildTransactionsList(context, data.transactions),
              error: (error, stack) => Center(
                child: Text('Error: ${error.toString()}'),
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
          categoryTransactions.when(
            data: (data) =>
                _buildTotalFooter(context, displayCategory, data.totalAmount),
            error: (_, __) => _buildTotalFooter(
                context, displayCategory, displayCategory.amount),
            loading: () => _buildTotalFooter(
                context, displayCategory, displayCategory.amount),
          ),
        ],
      ),
      bottomNavigationBar: CategoryBottomNavBar(
        categoryId: widget.categoryId,
      ),
    );
  }

  Widget _buildDateRangeSelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _showMonthYearPicker(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppStyles.primaryColor.withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedPeriod,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppStyles.primaryTextColor,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppStyles.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.calendar_today_rounded,
                        size: 18,
                        color: AppStyles.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showMonthYearPicker(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = DateTime(_selectedYear, _selectedMonth);
    final firstDate = DateTime(now.year - 2, 1); // 2 years back
    final lastDate = DateTime(now.year, now.month); // Up to current month

    try {
      // Get the current theme and only override what we need
      final baseTheme = Theme.of(context);

      // Use the themed context for the dialog
      final selectedDate = await showMonthPicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
        monthPickerDialogSettings: MonthPickerDialogSettings(
          // Dialog settings for locale and background color
          dialogSettings: PickerDialogSettings(
            dialogBackgroundColor: Colors.white,
            locale: const Locale('es', 'ES'),
            dialogRoundedCornersRadius: 12,
            // Add a subtle border to create shadow effect
            dialogBorderSide: BorderSide(
              color: Colors.grey.shade300,
              width: 0.5,
            ),
            // Add some inset padding to create space around the dialog
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          ),
          // Enhanced header settings with improved styling
          headerSettings: PickerHeaderSettings(
            // Add background color that slightly contrasts with dialog background
            headerBackgroundColor: Colors.grey.shade50,
            // Improve current page text style
            headerCurrentPageTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: AppStyles.primaryTextColor,
            ),
            // Customize header icons for better visibility
            headerIconsSize: 24.0,
            headerIconsColor: AppStyles.primaryColor,
            // Add padding around header elements
            headerPadding: const EdgeInsets.all(20.0),
            // Use different icons that match app style better
            previousIcon: Icons.chevron_left,
            nextIcon: Icons.chevron_right,
          ),
          // Action bar settings with widgets
          actionBarSettings: PickerActionBarSettings(
            confirmWidget: Text(
              'Confirmar',
              style: TextStyle(
                color: AppStyles.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            cancelWidget: Text(
              'Cancelar',
              style: TextStyle(
                color: AppStyles.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          // Date button settings with app style colors for consistency
          dateButtonsSettings: PickerDateButtonsSettings(
            selectedMonthBackgroundColor: AppStyles.primaryColor,
            selectedMonthTextColor: Colors.white,
            currentMonthTextColor: AppStyles.primaryTextColor,
            unselectedMonthsTextColor: AppStyles.secondaryTextColor,
            monthTextStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            selectedDateRadius: 8.0,
          ),
        ),
      );

      if (selectedDate != null && mounted) {
        setState(() {
          _selectedMonth = selectedDate.month;
          _selectedYear = selectedDate.year;
          _selectedPeriod = DateFormat('MMMM yyyy', 'es_ES')
              .format(DateTime(_selectedYear, _selectedMonth));
        });

        // Refresh transactions with the new month and year
        await ref
            .read(categoryTransactionsControllerProvider(widget.categoryId)
                .notifier)
            .refreshTransactions(
              widget.categoryId,
              month: _selectedMonth,
              year: _selectedYear,
            );

        developer.log(
          'Month selected: $_selectedPeriod',
          name: 'category_transactions',
        );
      } else {
        developer.log(
          'No month selected or dialog cancelled',
          name: 'category_transactions',
        );
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error showing month picker: $e',
        name: 'category_transactions',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar el mes: $e')),
        );
      }
    }
  }

  Widget _buildTransactionsList(
      BuildContext context, List<TransactionCategoryDTO> transactions) {
    if (transactions.isEmpty) {
      return const Center(
        child: Text('No hay transacciones para esta categoría'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];

        bool showDateHeader = index == 0 ||
            transactions[index].date.day != transactions[index - 1].date.day;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showDateHeader) _buildDateHeader(transaction.date),
            _buildTransactionItem(context, transaction),
          ],
        );
      },
    );
  }

  Widget _buildDateHeader(DateTime date) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        DateFormatter.formatFullDate(date),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
      BuildContext context, TransactionCategoryDTO transaction) {
    return InkWell(
      onTap: () => _navigateToTransactionDetails(context, transaction),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: EmojiFormatter.emojiToWidget(
                  transaction.categoryEmoji,
                  fontSize: 20,
                  fallbackIcon: Icons.category,
                  fallbackColor: Colors.grey.shade600,
                  loggerName: 'category_transactions',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction.location ?? 'No location',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            MoneyText(
              amount: transaction.amount,
              currency: 'Gs.',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
              isExpense: transaction.type == 'DEBITO',
              useColors: true,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToTransactionDetails(
      BuildContext context, TransactionCategoryDTO transaction) {
    final userSession = ref.read(userSessionNotifierProvider);
    final userId = userSession.userId;

    final recentTransaction = transaction.toRecentTransaction(userId: userId);

    developer.log(
      'Navigating to transaction details for transaction ID: ${transaction.id} with user ID: ${userId ?? "none"}',
      name: 'category_transactions',
    );

    context.push(
      '/transactions/${transaction.id}',
      extra: recentTransaction,
    );
  }

  Widget _buildTotalFooter(
      BuildContext context, TopCategory category, double totalAmount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            spreadRadius: 1,
            blurRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total en ${category.name}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          MoneyText(
            amount: totalAmount,
            currency: 'Gs.',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            isExpense: true,
            useColors: true,
          ),
        ],
      ),
    );
  }

  void _showTransactionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Nueva Transacción',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              '¿Cómo deseas agregar la transacción?',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildTransactionOption(
                  context,
                  title: 'Manual',
                  icon: Icons.edit,
                  color: AppStyles.primaryColor.withOpacity(0.1),
                  iconColor: AppStyles.primaryColor,
                ),
                _buildTransactionOption(
                  context,
                  title: 'Voz',
                  icon: Icons.mic,
                  color: Colors.grey[100]!,
                ),
                _buildTransactionOption(
                  context,
                  title: 'Cámara',
                  icon: Icons.camera_alt,
                  color: Colors.grey[100]!,
                ),
                _buildTransactionOption(
                  context,
                  title: 'Subir',
                  icon: Icons.upload_file,
                  color: Colors.grey[100]!,
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    Color iconColor = Colors.black,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[200]!,
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  TopCategory _getMockTopCategory(String id) {
    final mockCategories = {
      '1': TopCategory(
        id: 1,
        name: 'Comida y Bebida',
        emoji: '🍔',
        color: '#E9D5FF',
        amount: 7439850,
        percentage: 35.0,
        expenseCount: 42,
      ),
      '2': TopCategory(
        id: 2,
        name: 'Transporte',
        emoji: '🚗',
        color: '#DBEAFE',
        amount: 5105500,
        percentage: 25.0,
        expenseCount: 28,
      ),
      '3': TopCategory(
        id: 3,
        name: 'Salario',
        emoji: '💼',
        color: '#D1FAE5',
        amount: 9562500,
        percentage: 0.0,
        expenseCount: 1,
      ),
      '4': TopCategory(
        id: 4,
        name: 'Entretenimiento',
        emoji: '🎮',
        color: '#D1FAE5',
        amount: 4250000,
        percentage: 20.0,
        expenseCount: 15,
      ),
      '5': TopCategory(
        id: 5,
        name: 'Salud',
        emoji: '⚕️',
        color: '#FEE2E2',
        amount: 3200000,
        percentage: 15.0,
        expenseCount: 8,
      ),
    };
    int idAsInt;
    try {
      idAsInt = int.parse(id);
    } catch (e) {
      idAsInt = 1;
    }
    return mockCategories['$idAsInt'] ?? mockCategories['1']!;
  }

  List<Transaction> _getMockTransactions(String categoryId) {
    final now = DateTime.now();
    switch (categoryId) {
      case '1':
        return [
          Transaction(
            id: '101',
            description: 'McDonald\'s',
            amount: 85000,
            date: now.subtract(const Duration(days: 1)),
            location: 'Shopping del Sol',
            iconData: Icons.fastfood,
          ),
          Transaction(
            id: '102',
            description: 'Pizza Hut',
            amount: 120000,
            date: now.subtract(const Duration(days: 1)),
            location: 'Shopping Mariscal',
            iconData: Icons.local_pizza,
          ),
          Transaction(
            id: '103',
            description: 'Café Havanna',
            amount: 45000,
            date: now.subtract(const Duration(days: 3)),
            location: 'Paseo La Galería',
            iconData: Icons.coffee,
          ),
          Transaction(
            id: '104',
            description: 'Supermercado Stock',
            amount: 237500,
            date: now.subtract(const Duration(days: 5)),
            location: 'Villa Morra',
            iconData: Icons.shopping_cart,
          ),
          Transaction(
            id: '105',
            description: 'La Cabrera',
            amount: 345000,
            date: now.subtract(const Duration(days: 10)),
            location: 'Carmelitas',
            iconData: Icons.restaurant,
          ),
        ];
      case '2':
        return [
          Transaction(
            id: '201',
            description: 'Uber',
            amount: 35000,
            date: now.subtract(const Duration(days: 2)),
            location: 'Asunción - Lambaré',
            iconData: Icons.car_rental,
          ),
          Transaction(
            id: '202',
            description: 'Combustible',
            amount: 210000,
            date: now.subtract(const Duration(days: 4)),
            location: 'Petrobras - Aviadores',
            iconData: Icons.local_gas_station,
          ),
        ];
      default:
        return [];
    }
  }
}

class Transaction {
  final String id;
  final String description;
  final double amount;
  final DateTime date;
  final String location;
  final IconData iconData;
  Transaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.location,
    required this.iconData,
  });
}

class DateFormatter {
  static String formatFullDate(DateTime date) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateToCheck = DateTime(date.year, date.month, date.day);
    if (dateToCheck.year == now.year &&
        dateToCheck.month == now.month &&
        dateToCheck.day == now.day) {
      return 'Hoy';
    } else if (dateToCheck.year == yesterday.year &&
        dateToCheck.month == yesterday.month &&
        dateToCheck.day == yesterday.day) {
      return 'Ayer';
    } else {
      final months = [
        'Enero',
        'Febrero',
        'Marzo',
        'Abril',
        'Mayo',
        'Junio',
        'Julio',
        'Agosto',
        'Septiembre',
        'Octubre',
        'Noviembre',
        'Diciembre'
      ];
      final days = [
        'Lunes',
        'Martes',
        'Miércoles',
        'Jueves',
        'Viernes',
        'Sábado',
        'Domingo'
      ];
      final dayIndex = (date.weekday % 7) - 1;
      final dayName = days[dayIndex < 0 ? 6 : dayIndex];
      final monthName = months[date.month - 1];
      return '$dayName, ${date.day} de $monthName';
    }
  }
}
