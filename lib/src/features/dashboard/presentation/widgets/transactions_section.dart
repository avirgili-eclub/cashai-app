import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../../../../core/utils/emoji_formatter.dart';
import '../../../../core/utils/color_utils.dart';
import '../../../../core/presentation/widgets/money_text.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../routing/app_router.dart'; // Add this import for AppRoute
import '../../domain/entities/recent_transaction.dart';
// Update this import to the correct path
import '../controllers/transaction_controller.dart';

class TransactionsSection extends ConsumerWidget {
  const TransactionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    developer.log('Building TransactionsSection widget',
        name: 'transactions_section');
    final transactionsAsync = ref.watch(transactionsControllerProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Transacciones Recientes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to full transactions screen
                  developer.log('Navigate to full transactions screen',
                      name: 'transactions_section');
                  // Use AppRoute enum for type-safety
                  context.pushNamed(
                    AppRoute.allTransactions.name,
                    queryParameters: {
                      'filter': ''
                    }, // Explicitly pass empty filter
                  );
                },
                child: const Text(
                  'Ver Todo',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildTransactionsContent(context, transactionsAsync),
        ],
      ),
    );
  }

  Widget _buildTransactionsContent(BuildContext context,
      AsyncValue<List<RecentTransaction>> transactionsAsync) {
    return transactionsAsync.when(
      data: (transactions) {
        if (transactions.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No hay transacciones recientes'),
            ),
          );
        }

        // Log how many transactions we have
        developer.log('Got ${transactions.length} transactions',
            name: 'transactions_section');

        // Set a fixed height for the list to allow proper scrolling within the Column
        return SizedBox(
          height: 280, // Approximate height for 5 items
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              return _buildTransactionItem(context, transactions[index]);
            },
          ),
        );
      },
      loading: () => const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) {
        developer.log('Error in transactions data: $error',
            name: 'transactions_section', error: error, stackTrace: stack);
        return SizedBox(
          height: 100,
          child: Center(
            child: Text(
              'Error cargando transacciones: ${error.toString()}',
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
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
      loggerName: 'transactions_section',
    );

    // Get color from transaction or use default based on transaction type
    final Color defaultColor = isDebit
        ? const Color(0xFFFFCDD2) // Light red for expenses
        : const Color(0xFFC8E6C9); // Light green for income

    final Color containerColor = ColorUtils.fromHex(
      transaction.color,
      defaultColor: defaultColor.withOpacity(0.5),
      loggerName: 'transactions_section',
    );

    return GestureDetector(
      onTap: () {
        // Navigate to transaction details page
        developer.log('Tapped on transaction with ID: ${transaction.id}',
            name: 'transactions_section');
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
