import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../../../../core/utils/emoji_formatter.dart';
import '../../domain/entities/recent_transaction.dart';
import '../controllers/transactions_controller.dart';

class TransactionsSection extends ConsumerStatefulWidget {
  const TransactionsSection({super.key});

  @override
  ConsumerState<TransactionsSection> createState() =>
      _TransactionsSectionState();
}

class _TransactionsSectionState extends ConsumerState<TransactionsSection> {
  final ScrollController _scrollController = ScrollController();
  int _visibleItemCount = 5; // Default to showing 5 items initially

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;
      final scrollPercentage = currentScroll / maxScroll;

      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        // Scrolling down - gradually show more items
        if (currentScroll > 50 && _visibleItemCount < 10) {
          // Calculate how many more items to show (up to 10)
          int newCount = 5 + (scrollPercentage * 5).round();
          newCount = newCount.clamp(5, 10);

          if (newCount != _visibleItemCount) {
            setState(() {
              _visibleItemCount = newCount;
            });
          }
        }
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        // Scrolling up - gradually hide items again
        if (currentScroll < maxScroll * 0.5 && _visibleItemCount > 5) {
          // Calculate how many items to show when scrolling back up
          int newCount = 10 - ((1 - scrollPercentage) * 5).round();
          newCount = newCount.clamp(5, 10);

          if (newCount != _visibleItemCount) {
            setState(() {
              _visibleItemCount = newCount;
            });
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  // This will navigate to a full transactions screen later
                  developer.log('Navigate to full transactions screen',
                      name: 'transactions_section');
                  // TODO: Navigate to full transactions screen
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

        // Determine how many items to show (max 10)
        final totalItems = transactions.length;
        final itemsToShow = _visibleItemCount.clamp(0, totalItems);

        developer.log('Showing $itemsToShow of $totalItems transactions',
            name: 'transactions_section');

        // Set a fixed height for the list to allow proper scrolling within the Column
        return SizedBox(
          height: 280, // Approximate height for 5 items
          child: ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: itemsToShow,
            itemBuilder: (context, index) {
              // Animate the opacity of the extra items for a smooth appearance
              final opacity = index < 5 ? 1.0 : ((index - 4) / 5);
              return Opacity(
                opacity: opacity,
                child: _buildTransactionItem(context, transactions[index]),
              );
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

    return GestureDetector(
      onTap: () {
        // Navigate to transaction details page (to be implemented)
        developer.log('Tapped on transaction with ID: ${transaction.id}',
            name: 'transactions_section');
        // TODO: Navigate to transaction details screen
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
                color: (isDebit ? Colors.red : Colors.green).withOpacity(0.1),
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
            Text(
              '${isDebit ? '- ' : '+ '}Gs. ${transaction.amount.toStringAsFixed(0)}',
              style: TextStyle(
                color: isDebit ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
