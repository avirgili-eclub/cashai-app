import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/emoji_formatter.dart';
import '../../../../core/utils/color_utils.dart';
import '../../../../core/presentation/widgets/money_text.dart';
import '../../domain/entities/recent_transaction.dart';

class TransactionDetailsScreen extends ConsumerWidget {
  final String transactionId;
  final RecentTransaction? transaction;

  const TransactionDetailsScreen({
    Key? key,
    required this.transactionId,
    this.transaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    developer.log('Building TransactionDetailsScreen for ID: $transactionId',
        name: 'transaction_details');

    // Use the passed transaction or fetch it from a provider in a real app
    final currentTransaction = transaction;

    // Create a TextEditingController for the notes field
    final TextEditingController notesController = TextEditingController(
      text: currentTransaction?.invoiceText ?? '',
    );

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

                    // Amount
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
                        MoneyText(
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
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Category dropdown
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
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 16),
                              border: InputBorder.none,
                            ),
                            value: 'Comida y Bebida',
                            items: [
                              'Comida y Bebida',
                              'Transporte',
                              'Entretenimiento',
                              'Salud',
                              'Otro',
                            ].map((String category) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                            onChanged: (value) {
                              // Handle category change
                              developer.log('Category changed to: $value',
                                  name: 'transaction_details');
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Notes textarea
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
                          ),
                          child: TextField(
                            controller: notesController, // Apply the controller
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.all(16),
                              border: InputBorder.none,
                              hintText: 'Agrega notas sobre esta transacción',
                            ),
                            maxLines: 3,
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
                onPressed: () {
                  // Save changes logic
                  developer.log(
                      'Save changes pressed with notes: ${notesController.text}',
                      name: 'transaction_details');
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Guardar Cambios'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  // Delete transaction logic
                  developer.log('Delete transaction pressed',
                      name: 'transaction_details');
                  // Show confirmation dialog before deleting
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
            TextButton(
              onPressed: () {
                // Delete logic here
                developer.log('Confirmed delete transaction',
                    name: 'transaction_details');
                Navigator.of(dialogContext).pop(); // Close the dialog
                context.pop(); // Return to previous screen
              },
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
