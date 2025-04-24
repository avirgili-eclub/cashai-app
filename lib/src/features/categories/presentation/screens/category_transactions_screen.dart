import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/styles/app_styles.dart';
import '../../../../core/utils/emoji_formatter.dart';
import '../../../../core/utils/color_utils.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/presentation/widgets/money_text.dart';
import '../../../dashboard/domain/entities/top_category.dart';
// Import the custom nav bar
import '../widgets/category_bottom_nav_bar.dart';

class CategoryTransactionsScreen extends ConsumerStatefulWidget {
  final String categoryId;
  // Change the type from Category to TopCategory
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
  // Current selected month/year text
  String _selectedPeriod = 'Marzo 2024';

  @override
  Widget build(BuildContext context) {
    developer.log(
        'Building CategoryTransactionsScreen for category: ${widget.categoryId}',
        name: 'category_transactions');

    // We'll use the passed category or fetch it if not provided
    final displayCategory =
        widget.category ?? _getMockTopCategory(widget.categoryId);

    // Use EmojiFormatter for displaying the category icon
    final Widget categoryIcon = EmojiFormatter.emojiToWidget(
      displayCategory.emoji,
      fontSize: 24,
      fallbackIcon: Icons.category,
      fallbackColor: Colors.blue,
      loggerName: 'category_transactions',
    );

    // Parse the color from hex
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
          // Fix the + button to make it clearly visible
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppStyles.primaryColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: AppStyles.primaryColor,
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
          // Date Range Selector with simple month display
          _buildDateRangeSelector(context),

          // Transactions List - now using less space
          Expanded(
            child: _buildTransactionsList(context),
          ),

          // Total footer - moved inside body column
          _buildTotalFooter(context, displayCategory),
        ],
      ),
      // Use the custom nav bar instead of the standard one
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
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedPeriod,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey[700],
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

  // Add a month/year picker method
  void _showMonthYearPicker(BuildContext context) async {
    final months = [
      'Enero 2024',
      'Febrero 2024',
      'Marzo 2024',
      'Abril 2024',
      'Mayo 2024',
      'Junio 2024',
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleccionar mes'),
          content: SizedBox(
            width: double.minPositive,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: months.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(months[index]),
                  onTap: () {
                    setState(() {
                      _selectedPeriod = months[index];
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionsList(BuildContext context) {
    // Mock transaction data
    final transactions = _getMockTransactions(widget.categoryId);

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

        // Show date header if it's the first item or different from previous
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

  Widget _buildTransactionItem(BuildContext context, Transaction transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Transaction icon or avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                transaction.iconData,
                color: AppStyles.primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Transaction details
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
                  transaction.location,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Transaction amount
          MoneyText(
            amount: transaction.amount,
            currency: 'Gs.',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
            isExpense: true,
            useColors: true,
          ),
        ],
      ),
    );
  }

  // Update total footer to be more visible
  Widget _buildTotalFooter(BuildContext context, TopCategory category) {
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
            amount: category.amount,
            currency: 'Gs.',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            isExpense: true,
            useColors: true,
          ),
        ],
      ),
    );
  }

  // Add new method for transaction modal
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

  // Helper method for transaction options in modal
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
        // Handle option selection
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
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

  // Update mock data method to return TopCategory instead of Category
  TopCategory _getMockTopCategory(String id) {
    final mockCategories = {
      '1': TopCategory(
        id: 1,
        name: 'Comida y Bebida',
        emoji: '🍔',
        color: '#E9D5FF',
        amount: 743985,
        percentage: 35.0,
        expenseCount: 42,
      ),
      '2': TopCategory(
        id: 2,
        name: 'Transporte',
        emoji: '🚗',
        color: '#DBEAFE',
        amount: 510550,
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
        amount: 425000,
        percentage: 20.0,
        expenseCount: 15,
      ),
      '5': TopCategory(
        id: 5,
        name: 'Salud',
        emoji: '⚕️',
        color: '#FEE2E2',
        amount: 320000,
        percentage: 15.0,
        expenseCount: 8,
      ),
    };

    int idAsInt;
    try {
      idAsInt = int.parse(id);
    } catch (e) {
      idAsInt = 1; // Default to 1 if parsing fails
    }

    return mockCategories['$idAsInt'] ?? mockCategories['1']!;
  }

  List<Transaction> _getMockTransactions(String categoryId) {
    // Generate mock transactions based on category
    final now = DateTime.now();

    switch (categoryId) {
      case '1': // Food & Drink
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
      case '2': // Transport
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

// Simple transaction model for the mock data
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

// Helper class for date formatting
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
      // Format: "Lunes, 15 de Marzo"
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

      // Adjust for day of week index (DateTime uses 1-7 where 7 is Sunday)
      final dayIndex = (date.weekday % 7) - 1;
      final dayName = days[dayIndex < 0 ? 6 : dayIndex];
      final monthName = months[date.month - 1];

      return '$dayName, ${date.day} de $monthName';
    }
  }
}
