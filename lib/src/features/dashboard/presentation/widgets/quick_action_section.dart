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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
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
              QuickActionButton(
                icon: Icons.qr_code_scanner,
                label: 'Escanear',
                backgroundColor: Colors.grey[200]!,
                iconColor: Colors.black,
                onPressed: () {},
              ),
              QuickActionButton(
                icon: Icons.upload_file,
                label: 'Subir',
                backgroundColor: Colors.grey[200]!,
                iconColor: Colors.black,
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
