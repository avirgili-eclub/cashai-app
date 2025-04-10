import 'package:flutter/material.dart';
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Accesos Rápido',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              QuickActionButton(
                icon: Icons.arrow_downward,
                label: 'Ingresos',
                backgroundColor: Colors.green.withOpacity(0.1),
                iconColor: Colors.green,
                onPressed: () {},
              ),
              QuickActionButton(
                icon: Icons.arrow_upward,
                label: 'Gastos',
                backgroundColor: Colors.orange.withOpacity(0.1),
                iconColor: Colors.orange,
                onPressed: () {},
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
