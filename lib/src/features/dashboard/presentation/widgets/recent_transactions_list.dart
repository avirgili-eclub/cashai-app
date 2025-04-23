import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/recent_transaction.dart';
import '../controllers/transaction_controller.dart';
import './dismissible_transaction_item.dart';

class RecentTransactionsList extends ConsumerWidget {
  final int? limit;
  final bool showDate;
  final bool showEmpty;
  final String emptyMessage;
  final VoidCallback? onRefreshNeeded;

  const RecentTransactionsList({
    Key? key,
    this.limit,
    this.showDate = false,
    this.showEmpty = true,
    this.emptyMessage = 'No hay transacciones recientes',
    this.onRefreshNeeded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsControllerProvider);

    return transactionsAsync.when(
      data: (transactions) {
        // Take only the limited number of transactions if specified
        final displayTransactions = limit != null && limit! > 0
            ? transactions.take(limit!).toList()
            : transactions;

        if (displayTransactions.isEmpty && showEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                emptyMessage,
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayTransactions.length,
          itemBuilder: (context, index) {
            return DismissibleTransactionItem(
              transaction: displayTransactions[index],
              onDeleted: () {
                if (onRefreshNeeded != null) {
                  onRefreshNeeded!();
                }
              },
              showDate: showDate,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) {
        developer.log('Error loading recent transactions: $error',
            name: 'recent_transactions_list', error: error, stackTrace: stack);
        return Center(
          child: Text('Error: ${error.toString()}'),
        );
      },
    );
  }
}
