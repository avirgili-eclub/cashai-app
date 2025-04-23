import 'package:flutter/material.dart';
import '../../../../core/styles/app_styles.dart';

class EditableField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onEdit;

  const EditableField({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppStyles.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppStyles.primaryColor,
        ),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: IconButton(
        icon: Icon(
          Icons.edit,
          color: AppStyles.primaryColor,
        ),
        onPressed: onEdit,
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
}
