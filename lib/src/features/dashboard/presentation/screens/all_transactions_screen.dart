import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Add this import for locale support
import '../../../../core/utils/emoji_formatter.dart';
import '../../../../core/utils/color_utils.dart';
import '../../../../core/presentation/widgets/money_text.dart';
import '../../domain/entities/recent_transaction.dart';
import '../controllers/transaction_controller.dart';

// State provider for the transaction filter type
final transactionFilterTypeProvider = StateProvider<String>((ref) => '');

class AllTransactionsScreen extends ConsumerStatefulWidget {
  const AllTransactionsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AllTransactionsScreen> createState() =>
      _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends ConsumerState<AllTransactionsScreen> {
  // Current filter selections
  String currentMonth =
      ''; // Initialize with default value instead of using 'late'
  int currentYear = DateTime.now().year;

  // Filter options with Spanish month names
  final List<String> months = [
    'enero', // January
    'febrero', // February
    'marzo', // March
    'abril', // April
    'mayo', // May
    'junio', // June
    'julio', // July
    'agosto', // August
    'septiembre', // September
    'octubre', // October
    'noviembre', // November
    'diciembre' // December
  ];

  final List<int> years = [
    DateTime.now().year,
    DateTime.now().year - 1,
    DateTime.now().year - 2
  ];

  @override
  void initState() {
    super.initState();

    // Set a default value for currentMonth immediately
    currentMonth =
        months[DateTime.now().month - 1]; // Default to current month name

    // Initialize date formatting for Spanish locale
    initializeDateFormatting('es', null).then((_) {
      setState(() {
        // Format the current month name with Spanish locale
        currentMonth =
            DateFormat('MMMM', 'es').format(DateTime.now()).toLowerCase();
      });
    });

    // Reset filter when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transactionFilterTypeProvider.notifier).state = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    developer.log('Building AllTransactionsScreen',
        name: 'all_transactions_screen');

    // Watch transactions and filter type
    final transactionsAsync = ref.watch(transactionsControllerProvider);
    final filterType = ref.watch(transactionFilterTypeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transacciones'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Month and Year Selector
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Month dropdown
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: currentMonth,
                        items: months.map((String month) {
                          return DropdownMenuItem<String>(
                            value: month,
                            child: Text(month),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              currentMonth = newValue;
                            });
                            // Here you would refresh transactions based on new month
                            // This would be implemented in a real app
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Year dropdown
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        isExpanded: true,
                        value: currentYear,
                        items: years.map((int year) {
                          return DropdownMenuItem<int>(
                            value: year,
                            child: Text(year.toString()),
                          );
                        }).toList(),
                        onChanged: (int? newValue) {
                          if (newValue != null) {
                            setState(() {
                              currentYear = newValue;
                            });
                            // Here you would refresh transactions based on new year
                            // This would be implemented in a real app
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Type Filter Slider
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  // Expenses button
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // Toggle filter
                        final newFilter =
                            filterType == 'DEBITO' ? '' : 'DEBITO';
                        ref.read(transactionFilterTypeProvider.notifier).state =
                            newFilter;
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: filterType == 'DEBITO'
                              ? Theme.of(context).primaryColor.withOpacity(0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Gastos',
                          style: TextStyle(
                            fontWeight: filterType == 'DEBITO'
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: filterType == 'DEBITO'
                                ? Theme.of(context).primaryColor
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Income button
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // Toggle filter
                        final newFilter =
                            filterType == 'CREDITO' ? '' : 'CREDITO';
                        ref.read(transactionFilterTypeProvider.notifier).state =
                            newFilter;
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: filterType == 'CREDITO'
                              ? Theme.of(context).primaryColor.withOpacity(0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Ingresos',
                          style: TextStyle(
                            fontWeight: filterType == 'CREDITO'
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: filterType == 'CREDITO'
                                ? Theme.of(context).primaryColor
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Transactions List
          Expanded(
            child: transactionsAsync.when(
              data: (transactions) {
                // Apply filter
                final filteredTransactions = ref
                    .read(transactionsControllerProvider.notifier)
                    .filterTransactionsByType(transactions, filterType);

                if (filteredTransactions.isEmpty) {
                  return Center(
                    child: Text(
                      filterType.isEmpty
                          ? 'No hay transacciones para mostrar'
                          : filterType == 'DEBITO'
                              ? 'No hay gastos para mostrar'
                              : 'No hay ingresos para mostrar',
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: filteredTransactions.length,
                  itemBuilder: (context, index) {
                    return _buildTransactionItem(
                        context, filteredTransactions[index]);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) {
                developer.log('Error loading transactions: $error',
                    name: 'all_transactions_screen',
                    error: error,
                    stackTrace: stack);
                return Center(
                  child:
                      Text('Error cargando transacciones: ${error.toString()}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
      BuildContext context, RecentTransaction transaction) {
    final isDebit = transaction.type == 'DEBITO';
    final formattedDate = DateFormat('dd MMMM, yyyy').format(transaction.date);

    // Use the EmojiFormatter utility class to handle emoji formatting
    Widget emojiWidget = EmojiFormatter.emojiToWidget(
      transaction.emoji,
      fallbackIcon: Icons.receipt,
      loggerName: 'all_transactions_screen',
    );

    // Get color from transaction or use default based on transaction type
    final Color defaultColor = isDebit
        ? const Color(0xFFFFCDD2) // Light red for expenses
        : const Color(0xFFC8E6C9); // Light green for income

    final Color containerColor = ColorUtils.fromHex(
      transaction.color,
      defaultColor: defaultColor.withOpacity(0.5),
      loggerName: 'all_transactions_screen',
    );

    return GestureDetector(
      onTap: () {
        // Navigate to transaction details screen
        developer.log('Tapped on transaction with ID: ${transaction.id}',
            name: 'all_transactions_screen');
        context.pushNamed(
          'transactionDetails',
          pathParameters: {'id': transaction.id.toString()},
          extra: transaction, // Pass the transaction object directly
        );
      },
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
                color: containerColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: emojiWidget),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            MoneyText(
              amount: transaction.amount,
              currency: 'Gs.',
              isExpense: isDebit,
              isIncome: !isDebit,
              showSign: true,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
