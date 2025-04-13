import 'package:flutter/material.dart';

class ManualTabContent extends StatelessWidget {
  const ManualTabContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // For now just a placeholder (will implement form later)
    return const Center(
      child: Text(
        'Formulario de ingreso manual próximamente',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.grey,
          fontSize: 16.0,
        ),
      ),
    );
  }
}
