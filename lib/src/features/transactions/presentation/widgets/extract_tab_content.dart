import 'package:flutter/material.dart';
import '../../../../core/styles/app_styles.dart';

class ExtractTabContent extends StatelessWidget {
  const ExtractTabContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Explanatory text
          Text(
            'Aquí puedes subir tu extracto bancario del mes y tus gastos e ingresos serán registrados automáticamente y categorizados por nuestros agentes de IA.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'En breve podrás ver tus transacciones en la aplicación.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 13.0,
            ),
          ),

          // Upload area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: InkWell(
                onTap: () {
                  // Will implement file picking later
                },
                borderRadius: BorderRadius.circular(12.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: Colors.grey.shade200,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.upload_file,
                        size: 48.0,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        'Toca para subir tu extracto',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'PDF o Excel',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
