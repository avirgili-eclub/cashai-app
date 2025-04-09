import 'package:flutter/material.dart';

class ChatAgentButton extends StatelessWidget {
  const ChatAgentButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        // Show chat dialog
      },
      child: const Icon(Icons.chat),
    );
  }
}
