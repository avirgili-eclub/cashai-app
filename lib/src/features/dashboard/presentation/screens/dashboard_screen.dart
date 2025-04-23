import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Add this import
import '../../../../core/auth/providers/user_session_provider.dart';
import '../../../../core/styles/app_styles.dart';
import '../../../../routing/app_router.dart'; // Add this import for AppRoute
import '../controllers/balance_controller.dart';
import '../widgets/app_header.dart';
import '../widgets/balance_card.dart';
import '../widgets/collapsible_actions_card.dart';
import '../widgets/transactions_section.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/send_audio_button.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    developer.log('Building DashboardScreen', name: 'dashboard_screen');

    // Get the current user session
    final userSession = ref.watch(userSessionNotifierProvider);
    developer.log(
        'Current userId in dashboard: ${userSession.userId}, username: ${userSession.username}',
        name: 'dashboard_screen');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash AI'),
        backgroundColor: AppStyles.primaryColor,
        foregroundColor: Colors.white,
        // Move profile icon to the leading position
        leading: IconButton(
          icon: const Icon(Icons.person),
          onPressed: () => context.pushNamed(AppRoute.userProfile.name),
        ),
        actions: [
          // Add notification bell icon without any action for now
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: null, // Disabled for now, will be implemented later
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
              // Remove the debug information section
              // Use username from session if available, otherwise fallback to "Usuario"
              AppHeader(userName: userSession.username ?? 'Usuario'),
              _buildBalanceCardWithErrorHandler(ref),
              const SizedBox(height: 16),
              // New collapsible card that contains both QuickAction and Categories sections
              const CollapsibleActionsCard(),
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
        offset: const Offset(0, 15), // Positive y value moves it down
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

  // I've removed the _showUserSelector method as it's no longer needed
  // since we're now navigating to the user profile screen
}
