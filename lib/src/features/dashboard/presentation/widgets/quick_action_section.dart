import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../routing/app_router.dart';
import 'quick_action_button.dart';

class QuickActionSection extends StatelessWidget {
  const QuickActionSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title removed as it will be in the parent container
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 8), // Extra space at start
                  QuickActionButton(
                    icon: Icons.arrow_downward,
                    label: 'Ingresos',
                    backgroundColor: Colors.green.withOpacity(0.1),
                    iconColor: Colors.green,
                    onPressed: () {
                      // Navigate to transactions screen with income filter
                      context.pushNamed(
                        AppRoute.allTransactions.name,
                        queryParameters: {'filter': 'CREDITO'},
                      );
                    },
                  ),
                  const SizedBox(
                      width: 24), // Increased spacing between buttons
                  QuickActionButton(
                    icon: Icons.arrow_upward,
                    label: 'Gastos',
                    backgroundColor: Colors.orange.withOpacity(0.1),
                    iconColor: Colors.orange,
                    onPressed: () {
                      // Navigate to transactions screen with expense filter
                      context.pushNamed(
                        AppRoute.allTransactions.name,
                        queryParameters: {'filter': 'DEBITO'},
                      );
                    },
                  ),
                  const SizedBox(
                      width: 24), // Increased spacing between buttons
                  QuickActionButton(
                    icon: Icons.qr_code_scanner,
                    label: 'Escanear',
                    backgroundColor: Colors.grey[200]!,
                    iconColor: Colors.black,
                    onPressed: () {
                      // Navigate to add transaction screen with Scan tab selected
                      context.pushNamed(
                        AppRoute.addTransaction.name,
                        queryParameters: {
                          'tab': '0'
                        }, // 0 is the index for Scan tab
                      );
                    },
                  ),
                  const SizedBox(
                      width: 24), // Increased spacing between buttons
                  QuickActionButton(
                    icon: Icons.upload_file,
                    label: 'Subir',
                    backgroundColor: Colors.grey[200]!,
                    iconColor: Colors.black,
                    onPressed: () {
                      // Navigate to add transaction screen with Extract tab selected
                      context.pushNamed(
                        AppRoute.addTransaction.name,
                        queryParameters: {
                          'tab': '2'
                        }, // 2 is the index for Extract tab
                      );
                    },
                  ),
                  const SizedBox(
                      width: 24), // Increased spacing between buttons
                  QuickActionButton(
                    icon: Icons.access_time,
                    label: 'Recurrente',
                    backgroundColor: Colors.purple.withOpacity(0.1),
                    iconColor: Colors.purple,
                    onPressed: () {
                      // Show dialog that this feature is coming soon
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Recurrentes'),
                            content:
                                const Text('Próximamente estará habilitado'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Aceptar'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(width: 8), // Extra space at end
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
