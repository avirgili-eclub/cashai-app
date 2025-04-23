import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/emoji_formatter.dart';
import '../../../../core/utils/color_utils.dart';
import '../../../../core/presentation/widgets/money_text.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../domain/entities/recent_transaction.dart';
import '../controllers/transaction_controller.dart';

// Convert to StatefulWidget to manage edit mode
class TransactionDetailsScreen extends ConsumerStatefulWidget {
  final String transactionId;
  final RecentTransaction? transaction;

  const TransactionDetailsScreen({
    Key? key,
    required this.transactionId,
    this.transaction,
  }) : super(key: key);

  @override
  ConsumerState<TransactionDetailsScreen> createState() =>
      _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState
    extends ConsumerState<TransactionDetailsScreen> {
  bool _isEditMode = false;
  late TextEditingController notesController;
  late TextEditingController amountController;
  late TextEditingController
      titleController; // Added controller for title/description
  late String categoryName;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with transaction data
    notesController = TextEditingController(
      text: widget.transaction?.invoiceText ?? '',
    );

    // Format amount using MoneyFormatter for display
    final amount = widget.transaction?.amount ?? 0.0;
    final formattedAmount =
        MoneyFormatter.formatAmount(amount).replaceFirst('Gs. ', '');
    amountController = TextEditingController(text: formattedAmount);

    // Initialize title controller with description
    titleController = TextEditingController(
      text: widget.transaction?.description ?? '',
    );

    // Store category name
    categoryName = widget.transaction?.categoryName ?? 'Sin categoría';
  }

  @override
  void dispose() {
    notesController.dispose();
    amountController.dispose();
    titleController.dispose(); // Dispose the title controller
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  Future<void> _saveChanges() async {
    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text('Guardando cambios...'),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 1),
      ),
    );

    // Parse the formatted amount string back to a number
    double? parsedAmount;
    try {
      // Remove currency symbol, thousand separators, and other non-numeric chars
      final amountStr = amountController.text
          .replaceAll('Gs. ', '')
          .replaceAll('.', '')
          .trim();
      parsedAmount = double.tryParse(amountStr);
    } catch (e) {
      developer.log('Error parsing amount: ${amountController.text}',
          name: 'transaction_details', error: e);
      parsedAmount = null;
    }

    if (parsedAmount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Monto inválido'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.fixed,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Get the transaction ID from the widget parameters
    final transId =
        int.tryParse(widget.transactionId) ?? widget.transaction?.id ?? -1;
    if (transId <= 0) {
      developer.log('Invalid transaction ID: $transId',
          name: 'transaction_details');
      return;
    }

    // Call the API to update the transaction including title
    final success = await ref
        .read(transactionsControllerProvider.notifier)
        .updateTransaction(
          transId,
          parsedAmount,
          titleController.text, // Pass title (previous description)
          notesController.text, // Pass notes (for API description)
        );

    // Handle the response
    if (success) {
      // Exit edit mode
      _toggleEditMode();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cambios guardados con éxito'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.fixed,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al guardar los cambios'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.fixed,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTransaction = widget.transaction;

    if (currentTransaction == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detalles de Transacción'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final isDebit = currentTransaction.type == 'DEBITO';

    // Get color from transaction or use default based on transaction type
    final Color defaultColor = isDebit
        ? const Color(0xFFFFCDD2) // Light red for expenses
        : const Color(0xFFC8E6C9); // Light green for income

    final Color containerColor = ColorUtils.fromHex(
      currentTransaction.color,
      defaultColor: defaultColor.withOpacity(0.5),
      loggerName: 'transaction_details',
    );

    // Use the EmojiFormatter utility class to handle emoji formatting
    Widget emojiWidget = EmojiFormatter.emojiToWidget(
      currentTransaction.emoji,
      fallbackIcon: Icons.receipt,
      loggerName: 'transaction_details',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de Transacción'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Transaction Info Card
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    // Transaction header with icon and description
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: containerColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(child: emojiWidget),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentTransaction.description,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDate(currentTransaction.date),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Description (Title) section - editable or read-only based on mode
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Titulo/Descripción',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                            color: _isEditMode
                                ? Colors.white
                                : Colors.grey.shade50,
                          ),
                          child: TextField(
                            controller: titleController,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.all(16),
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            enabled: _isEditMode,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Amount section - editable or read-only based on mode
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Monto',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _isEditMode
                            ? Container(
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: TextField(
                                  controller: amountController,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    prefixText: 'Gs. ',
                                    border: InputBorder.none,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    // Use a custom formatter for thousands separators
                                    FilteringTextInputFormatter.digitsOnly,
                                    _ThousandsSeparatorInputFormatter(),
                                  ],
                                  onChanged: (value) {
                                    // Optional: real-time validation or other actions
                                  },
                                ),
                              )
                            : Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                  color: _isEditMode
                                      ? Colors.white
                                      : Colors.grey.shade50,
                                ),
                                child: MoneyText(
                                  amount: currentTransaction.amount,
                                  currency: 'Gs.',
                                  isExpense: isDebit,
                                  isIncome: !isDebit,
                                  showSign: true,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Category display - currently read-only in both modes
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Categoría',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey.shade50,
                          ),
                          child: Text(
                            categoryName,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Notes textarea - editable or read-only based on mode
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Notas',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                            color: _isEditMode
                                ? Colors.white
                                : Colors.grey.shade50,
                          ),
                          child: TextField(
                            controller: notesController,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.all(16),
                              border: InputBorder.none,
                              hintText: 'Agrega notas sobre esta transacción',
                            ),
                            maxLines: 3,
                            enabled: _isEditMode,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action buttons
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isEditMode ? _saveChanges : _toggleEditMode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(_isEditMode ? 'Guardar Cambios' : 'Editar Cambios'),
              ),
              const SizedBox(height: 12),
              // Delete button only visible when not in edit mode
              if (!_isEditMode)
                OutlinedButton(
                  onPressed: () {
                    _showDeleteConfirmationDialog(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.grey[200],
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Eliminar Transacción'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre'
    ];
    return '${date.day} de ${months[date.month - 1]}, ${date.year}';
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar Transacción'),
          content: const Text(
              '¿Estás seguro que deseas eliminar esta transacción? Esta acción no se puede deshacer.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
              child: const Text('Cancelar'),
            ),
            Consumer(
              builder: (context, ref, _) {
                return TextButton(
                  onPressed: () async {
                    // Get transaction ID from the transaction object
                    final transId = int.tryParse(widget.transactionId) ??
                        widget.transaction?.id ??
                        -1;

                    if (transId <= 0) {
                      developer.log('Invalid transaction ID: $transId',
                          name: 'transaction_details');
                      Navigator.of(dialogContext).pop();
                      context.pop();
                      return;
                    }

                    // Call delete transaction from controller
                    final success = await ref
                        .read(transactionsControllerProvider.notifier)
                        .deleteTransaction(transId);

                    // Log result
                    developer.log(
                        'Delete transaction result: $success, ID: $transId',
                        name: 'transaction_details');

                    // Close dialog regardless of result
                    Navigator.of(dialogContext).pop();

                    // Return to previous screen on success
                    if (success) {
                      // Show a snackbar indicating successful deletion with safer floating behavior
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Transacción eliminada con éxito'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior
                              .fixed, // Use fixed instead of floating
                          duration: Duration(seconds: 2),
                        ),
                      );
                      context.pop();
                    } else {
                      // Show error message if deletion failed
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Error al eliminar la transacción'),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior
                              .fixed, // Use fixed instead of floating
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Eliminar',
                    style: TextStyle(color: Colors.red),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

// Custom formatter for adding thousands separators
class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static const separator =
      '.'; // Paraguayan format uses dot as thousands separator

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Return early if the new value is empty
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all non-digit characters
    String newValueText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Add thousands separators
    String formattedText = '';
    for (int i = 0; i < newValueText.length; i++) {
      // Add a separator every 3 digits from the right
      if (i > 0 && (newValueText.length - i) % 3 == 0) {
        formattedText += separator;
      }
      formattedText += newValueText[i];
    }

    // Calculate new selection positions
    int selectionIndex =
        newValue.selection.end + (formattedText.length - newValue.text.length);

    // Adjust for possible separator characters that might have been added
    if (selectionIndex < 0) selectionIndex = 0;
    if (selectionIndex > formattedText.length)
      selectionIndex = formattedText.length;

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
