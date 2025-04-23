import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/auth/providers/user_session_provider.dart';
import '../../domain/entities/recent_transaction.dart';
import '../controllers/transaction_controller.dart';
import '../../../../core/utils/emoji_formatter.dart';
import '../../../../core/utils/color_utils.dart';
import '../../../../core/presentation/widgets/money_text.dart';
import 'package:intl/intl.dart';

class DismissibleTransactionItem extends ConsumerStatefulWidget {
  final RecentTransaction transaction;
  final VoidCallback onDeleted;
  final bool showDate;

  const DismissibleTransactionItem({
    Key? key,
    required this.transaction,
    required this.onDeleted,
    this.showDate = true,
  }) : super(key: key);

  @override
  ConsumerState<DismissibleTransactionItem> createState() =>
      _DismissibleTransactionItemState();
}

class _DismissibleTransactionItemState
    extends ConsumerState<DismissibleTransactionItem> {
  bool _isDismissed = false;
  bool _isDeleting = false;
  bool _isRestoring = false;

  @override
  Widget build(BuildContext context) {
    // If already dismissed and not being restored, don't show anything
    if (_isDismissed && !_isRestoring) {
      return const SizedBox.shrink();
    }

    // If being restored, show with a different background to indicate restoration
    if (_isRestoring) {
      return _buildRestoringItem();
    }

    return Dismissible(
      key: ValueKey(
          'transaction-${widget.transaction.id}-${identityHashCode(widget)}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        if (_isDeleting) return false;

        // Show confirmation dialog
        return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text('Eliminar transacción'),
              content: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  children: [
                    const TextSpan(
                      text: '¿Estás seguro que deseas eliminar la transacción ',
                    ),
                    TextSpan(
                      text: widget.transaction.description,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(
                      text: '?\n\n',
                    ),
                    TextSpan(
                      text:
                          'Esta acción eliminará permanentemente esta transacción y no se puede deshacer.',
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('CANCELAR'),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red[700],
                    backgroundColor: Colors.red[50],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('ELIMINAR'),
                ),
              ],
              actionsPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
            );
          },
        );
      },
      onDismissed: (direction) {
        // Mark as dismissed immediately - optimistic update
        setState(() {
          _isDismissed = true;
          _isDeleting = true;
        });

        // Process deletion in the background
        _deleteTransaction();
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red[100]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Eliminar',
              style: TextStyle(
                color: Colors.red[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      child: _buildTransactionItem(context),
    );
  }

  Widget _buildTransactionItem(BuildContext context) {
    final transaction = widget.transaction;
    final isDebit = transaction.type == 'DEBITO';

    // Format date
    final DateFormat dateFormat =
        widget.showDate ? DateFormat('dd MMM, yyyy') : DateFormat('dd MMM');
    final formattedDate = dateFormat.format(transaction.date);

    // Emoji widget
    Widget emojiWidget = EmojiFormatter.emojiToWidget(
      transaction.emoji,
      fallbackIcon: Icons.receipt,
      loggerName: 'dismissible_transaction_item',
    );

    // Background color
    final Color defaultColor = isDebit
        ? const Color(0xFFFFCDD2) // Light red for expenses
        : const Color(0xFFC8E6C9); // Light green for income

    final Color containerColor = ColorUtils.fromHex(
      transaction.color,
      defaultColor: defaultColor.withOpacity(0.5),
      loggerName: 'dismissible_transaction_item',
    );

    return GestureDetector(
      onTap: () {
        // Navigate to transaction details
        developer.log('Tapped on transaction: ${transaction.id}',
            name: 'dismissible_transaction_item');
        context.pushNamed(
          'transactionDetails',
          pathParameters: {'id': transaction.id.toString()},
          extra: transaction,
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

  Widget _buildRestoringItem() {
    final transaction = widget.transaction;
    final isDebit = transaction.type == 'DEBITO';

    return Container(
      decoration: BoxDecoration(
        color: Colors.yellow[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber),
      ),
      child: Column(
        children: [
          _buildTransactionItem(context),
          Container(
            color: Colors.amber.withOpacity(0.2),
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            child: Row(
              children: [
                const Icon(Icons.refresh, size: 16, color: Colors.amber),
                const SizedBox(width: 8),
                const Text(
                  'Restaurando transacción...',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.amber,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.amber[700]!),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTransaction() async {
    try {
      // Get user ID from session
      final userSession = ref.read(userSessionNotifierProvider);
      if (userSession.userId == null) {
        _showErrorMessage('No se pudo obtener el ID de usuario');
        _restoreTransaction();
        return;
      }

      // Call the repository method to delete
      final transactionController =
          ref.read(transactionsControllerProvider.notifier);
      final success =
          await transactionController.deleteTransaction(widget.transaction.id);

      if (mounted) {
        if (success) {
          _showSuccessMessage(
              'Transacción "${widget.transaction.description}" eliminada correctamente');
          // Don't need to refresh list since we've already removed the item (optimistic update)
        } else {
          _showErrorMessage('No se pudo eliminar la transacción');
          _restoreTransaction();
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Error al eliminar la transacción: ${e.toString()}');
        _restoreTransaction();
      }
      developer.log('Error deleting transaction: $e',
          name: 'dismissible_transaction_item', error: e);
    }
  }

  void _restoreTransaction() {
    if (!mounted) return;

    setState(() {
      _isRestoring = true;
      _isDismissed = false;
    });

    // Animate the restoration with a delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isRestoring = false;
          _isDeleting = false;
        });
        widget.onDeleted(); // Refresh the parent list
      }
    });
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
