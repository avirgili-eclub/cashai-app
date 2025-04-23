import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Add this import for navigation
import '../../domain/entities/balance.dart';
import '../controllers/balance_controller.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/presentation/widgets/money_text.dart';

// Create a provider to store the visibility state to maintain it across widget rebuilds
final balanceVisibilityProvider = StateProvider<bool>((ref) => true);

class BalanceCard extends ConsumerWidget {
  final Function()? onRefresh;

  const BalanceCard({super.key, this.onRefresh});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    developer.log('Building BalanceCard widget', name: 'balance_card');
    final balanceAsync = ref.watch(balanceControllerProvider);
    // Get the current visibility state
    final isAmountVisible = ref.watch(balanceVisibilityProvider);

    developer.log('Balance state: ${balanceAsync.toString()}',
        name: 'balance_card');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(16.0),
        ),
        padding: const EdgeInsets.all(16.0),
        child: balanceAsync.when(
          data: (balance) {
            developer.log('Displaying balance data: ${balance.totalBalance}',
                name: 'balance_card');
            return _buildBalanceContent(context, balance, isAmountVisible, ref);
          },
          loading: () {
            developer.log('Showing loading state', name: 'balance_card');
            return const SizedBox(
              height: 200,
              child:
                  Center(child: CircularProgressIndicator(color: Colors.white)),
            );
          },
          error: (error, stack) {
            developer.log('Error in balance data: $error',
                name: 'balance_card', error: error, stackTrace: stack);
            return SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Error loading balance: ${error.toString()}',
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    if (onRefresh != null)
                      TextButton.icon(
                        icon: const Icon(Icons.refresh, color: Colors.white70),
                        label: const Text('Retry',
                            style: TextStyle(color: Colors.white)),
                        onPressed: onRefresh,
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBalanceContent(BuildContext context, Balance balance,
      bool isAmountVisible, WidgetRef ref) {
    // Handle authentication required case
    if (balance.isAuthenticationRequired) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Inicie sesión para ver su balance',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  // Navigate to sign-in page
                  context.go('/signIn');
                },
                child: const Text('Iniciar Sesión'),
              ),
            ],
          ),
        ),
      );
    }

    // Continue with regular balance display
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Balance Total',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            Row(
              children: [
                // Eye icon to toggle visibility
                IconButton(
                  icon: Icon(
                    isAmountVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white70,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    // Toggle visibility
                    ref.read(balanceVisibilityProvider.notifier).state =
                        !isAmountVisible;
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  '${balance.month}/${balance.year}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        _buildMoneyTextOrMasked(
          amount: balance.totalBalance,
          currency: balance.currency,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          isVisible: isAmountVisible,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildBalanceItem(
              context,
              'Ingresos',
              balance.totalIncome,
              Icons.arrow_downward,
              balance.currency,
              isAmountVisible,
            ),
            const SizedBox(width: 24),
            _buildBalanceItem(
              context,
              'Gastos',
              balance.expenses,
              Icons.arrow_upward,
              balance.currency,
              isAmountVisible,
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(color: Colors.white30, height: 1),
        const SizedBox(height: 16),
        _buildIncomeDetails(context, balance, isAmountVisible),
      ],
    );
  }

  // Helper method to show either the money amount or masked text
  Widget _buildMoneyTextOrMasked({
    required double amount,
    required String currency,
    required TextStyle style,
    bool isVisible = true,
    bool isExpense = false,
    bool isIncome = false,
    bool showSign = false,
    bool useColors = false,
  }) {
    if (isVisible) {
      return MoneyText(
        amount: amount,
        currency: currency,
        style: style,
        isExpense: isExpense,
        isIncome: isIncome,
        showSign: showSign,
        useColors: useColors,
      );
    } else {
      // Return masked text
      return Text(
        "$currency ********",
        style: style,
      );
    }
  }

  Widget _buildBalanceItem(
    BuildContext context,
    String title,
    double amount,
    IconData icon,
    String currency,
    bool isAmountVisible,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _buildMoneyTextOrMasked(
            amount: amount,
            currency: currency,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            isVisible: isAmountVisible,
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeDetails(
      BuildContext context, Balance balance, bool isAmountVisible) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detalles de Ingresos',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildIncomeItem(
                context,
                'Ingreso Mensual',
                balance.monthlyIncome,
                balance.currency,
                isAmountVisible,
              ),
            ),
            Expanded(
              child: _buildIncomeItem(
                context,
                'Ingreso Extra',
                balance.extraIncome,
                balance.currency,
                isAmountVisible,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIncomeItem(
    BuildContext context,
    String title,
    double amount,
    String currency,
    bool isAmountVisible,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        _buildMoneyTextOrMasked(
          amount: amount,
          currency: currency,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          isVisible: isAmountVisible,
        ),
      ],
    );
  }
}
