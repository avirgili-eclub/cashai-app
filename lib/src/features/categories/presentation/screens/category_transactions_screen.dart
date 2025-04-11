import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/styles/app_styles.dart';
import '../../../../core/utils/emoji_formatter.dart';
import '../../../../core/utils/color_utils.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/presentation/widgets/money_text.dart';
// Update import to use TopCategory instead of Category
import '../../../dashboard/domain/entities/top_category.dart';

class CategoryTransactionsScreen extends ConsumerWidget {
  final String categoryId;
  // Change the type from Category to TopCategory
  final TopCategory? category;

  const CategoryTransactionsScreen({
    Key? key,
    required this.categoryId,
    this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    developer.log(
        'Building CategoryTransactionsScreen for category: $categoryId',
        name: 'category_transactions');

    // We'll use the passed category or fetch it if not provided
    final displayCategory = category ?? _getMockTopCategory(categoryId);

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
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterOptions(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Card
          _buildSummaryCard(context, displayCategory),

          // Date Range Selector
          _buildDateRangeSelector(context),

          // Transactions List
          Expanded(
            child: _buildTransactionsList(context),
          ),
        ],
      ),
    );
  }

  // Update summary card method to use TopCategory
  Widget _buildSummaryCard(BuildContext context, TopCategory category) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Resumen del Mes',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('Total', category.amount, true),
              _buildSummaryItem('Promedio', category.amount / 4, true),
              _buildSummaryItem('Transacciones', 12, false, isCount: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, double value, bool isExpense,
      {bool isCount = false}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        isCount
            ? Text(
                value.toInt().toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              )
            : MoneyText(
                amount: value,
                currency: 'Gs.',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                isExpense: isExpense,
                useColors: true,
              ),
      ],
    );
  }

  Widget _buildDateRangeSelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Marzo 2024',
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
        ],
      ),
    );
  }

  Widget _buildTransactionsList(BuildContext context) {
    // Mock transaction data
    final transactions = _getMockTransactions(categoryId);

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

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filtrar por',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              _buildFilterOption(context, 'Más reciente', Icons.access_time),
              _buildFilterOption(context, 'Mayor monto', Icons.arrow_downward),
              _buildFilterOption(context, 'Menor monto', Icons.arrow_upward),
              _buildFilterOption(context, 'Por ubicación', Icons.location_on),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(BuildContext context, String text, IconData icon) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        // Apply filter logic
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[700]),
            const SizedBox(width: 16),
            Text(text),
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
