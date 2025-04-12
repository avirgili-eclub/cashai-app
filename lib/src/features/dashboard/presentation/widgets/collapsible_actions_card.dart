import 'package:flutter/material.dart';
import 'quick_action_section.dart';
import 'categories_section.dart';

class CollapsibleActionsCard extends StatefulWidget {
  const CollapsibleActionsCard({Key? key}) : super(key: key);

  @override
  State<CollapsibleActionsCard> createState() => _CollapsibleActionsCardState();
}

class _CollapsibleActionsCardState extends State<CollapsibleActionsCard> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and toggle button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Accesos Rápido',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Toggle button
                InkWell(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      _isExpanded ? Icons.remove : Icons.add,
                      size: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content area that collapses/expands
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Column(
              children: const [
                QuickActionSection(),
                SizedBox(height: 16),
                CategoriesSection(),
                SizedBox(height: 16),
              ],
            ),
            secondChild: const SizedBox(), // Empty when collapsed
          ),
        ],
      ),
    );
  }
}
