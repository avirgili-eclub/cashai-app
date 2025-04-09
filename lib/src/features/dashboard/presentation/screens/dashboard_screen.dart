import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/app_header.dart';
import '../widgets/balance_card.dart';
import '../widgets/quick_action_section.dart';
import '../widgets/categories_section.dart';
import '../widgets/transactions_section.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/chat_agent_button.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(userName: 'Ale V.'),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    BalanceCard(),
                    SizedBox(height: 24),
                    QuickActionSection(),
                    SizedBox(height: 24),
                    CategoriesSection(),
                    SizedBox(height: 24),
                    TransactionsSection(),
                    // Extra space at bottom for navigation bar
                    SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(),
      floatingActionButton: const ChatAgentButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
