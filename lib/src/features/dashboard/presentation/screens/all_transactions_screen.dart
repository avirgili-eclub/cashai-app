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
import '../widgets/dismissible_transaction_item.dart';

// State provider for the transaction filter type
final transactionFilterTypeProvider = StateProvider<String>((ref) => '');

class AllTransactionsScreen extends ConsumerStatefulWidget {
  final String initialFilter;

  const AllTransactionsScreen({
    Key? key,
    this.initialFilter = '', // Default to empty string
  }) : super(key: key);

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

  final List<int> years = [DateTime.now().year, DateTime.now().year - 1];

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

      // Fetch initial data with current month and year filter
      _refreshTransactionsWithDateFilter();
    });

    // Set initial filter if provided
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Safely access initialFilter with null check
      final filter = widget.initialFilter;
      if (filter.isNotEmpty) {
        ref.read(transactionFilterTypeProvider.notifier).state = filter;
      } else {
        ref.read(transactionFilterTypeProvider.notifier).state = '';
      }
    });
  }

  // Helper method to refresh transactions with date filter
  void _refreshTransactionsWithDateFilter() {
    // Find month index (1-based) from the month name
    final monthIndex = months.indexOf(currentMonth) + 1;
    if (monthIndex > 0) {
      // Calculate start and end date for the selected month and year
      final startDate = DateTime(currentYear, monthIndex, 1);
      // End date is the last day of the month
      final endDate = (monthIndex < 12)
          ? DateTime(currentYear, monthIndex + 1, 0)
          : DateTime(currentYear + 1, 1, 0);

      developer.log(
          'Refreshing transactions for date range: ${startDate.toIso8601String()} to ${endDate.toIso8601String()}',
          name: 'all_transactions_screen');

      // Refresh transactions with date filter
      ref.read(transactionsControllerProvider.notifier).refreshTransactions(
            startDate: startDate,
            endDate: endDate,
            limit: 0, // Optional limit for the number of transactions
          );
    }
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
                            // Refresh transactions with the new month filter
                            _refreshTransactionsWithDateFilter();
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
                            // Refresh transactions with the new year filter
                            _refreshTransactionsWithDateFilter();
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
                    // Use DismissibleTransactionItem instead of _buildTransactionItem
                    return DismissibleTransactionItem(
                      transaction: filteredTransactions[index],
                      onDeleted: _refreshTransactionsWithDateFilter,
                      showDate: true,
                    );
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
}
