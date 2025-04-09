import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/auth/providers/user_session_provider.dart';
import '../controllers/balance_controller.dart';
import '../widgets/app_header.dart';
import '../widgets/balance_card.dart';
import '../widgets/quick_action_section.dart';
import '../widgets/categories_section.dart';
import '../widgets/transactions_section.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/send_audio_button.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    developer.log('Building DashboardScreen', name: 'dashboard_screen');

    // Get the current user ID
    final userSession = ref.watch(userSessionNotifierProvider);
    developer.log('Current userId: ${userSession.userId}',
        name: 'dashboard_screen');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash AI'),
        actions: [
          // This is just for testing purposes - you'd remove this in production
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => _showUserSelector(context, ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () {
          developer.log('Manual refresh triggered', name: 'dashboard_screen');
          return ref.read(balanceControllerProvider.notifier).refreshBalance();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display current user ID for debugging
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Current User ID: ${userSession.userId}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const AppHeader(userName: 'Ale V.'),
              _buildBalanceCardWithErrorHandler(ref),
              const SizedBox(height: 24),
              const QuickActionSection(),
              const SizedBox(height: 24),
              const CategoriesSection(),
              const SizedBox(height: 24),
              const TransactionsSection(),
              // Extra space at bottom for navigation bar
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        // Adding a container around BottomNavBar to control its height
        height: 80, // Increased height (was typically around 56-60px)
        child: const BottomNavBar(),
      ),
      floatingActionButton: Transform.translate(
        // Offsetting the button position
        offset: const Offset(0, 20), // Positive y value moves it down
        child: const SendAudioButton(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // Wrap BalanceCard with error handling for debugging
  Widget _buildBalanceCardWithErrorHandler(WidgetRef ref) {
    try {
      developer.log('Building BalanceCard', name: 'dashboard_screen');
      return BalanceCard(
        onRefresh: () {
          developer.log('Balance refresh requested', name: 'dashboard_screen');
          ref.read(balanceControllerProvider.notifier).refreshBalance();
        },
      );
    } catch (e, stackTrace) {
      developer.log('Error building BalanceCard: $e',
          name: 'dashboard_screen', error: e, stackTrace: stackTrace);
      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Error rendering Balance Card:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(e.toString()),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  ref.read(balanceControllerProvider.notifier).refreshBalance(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
  }

  // Simple user selector dialog for testing
  void _showUserSelector(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(
      text: ref.read(userSessionNotifierProvider).userId,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Test User ID'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'User ID',
            hintText: 'Enter a user ID for testing',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final userId = controller.text.trim();
              if (userId.isNotEmpty) {
                ref
                    .read(userSessionNotifierProvider.notifier)
                    .setUserId(userId);
                // Refresh the balance with the new user ID
                ref.read(balanceControllerProvider.notifier).refreshBalance();
              }
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}
