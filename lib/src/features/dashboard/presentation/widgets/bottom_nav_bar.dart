import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/balance.dart';
import '../controllers/balance_controller.dart';
import '../providers/active_screen_provider.dart';
import '../../../../routing/app_router.dart';

class BottomNavBar extends ConsumerWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(balanceControllerProvider);
    final activeScreen = ref.watch(activeScreenProvider);

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(
              context,
              Icons.home,
              'Inicio',
              activeScreen == ActiveScreen.home,
              () {
                // Only navigate if not already on home screen
                if (activeScreen != ActiveScreen.home) {
                  ref.read(activeScreenProvider.notifier).state =
                      ActiveScreen.home;
                  context.go('/dashboard');
                }
              },
            ),
            _buildNavItem(
              context,
              Icons.pie_chart,
              'Estadísticas',
              activeScreen == ActiveScreen.statistics,
              () {
                // Only navigate if not already on statistics screen
                if (activeScreen != ActiveScreen.statistics) {
                  ref.read(activeScreenProvider.notifier).state =
                      ActiveScreen.statistics;
                  // Get balance data to pass to statistics screen
                  balanceAsync.whenData((balance) {
                    context.pushNamed('statistics', extra: balance);
                  });
                }
              },
            ),
            const SizedBox(width: 48), // Space for FAB
            _buildNavItem(
              context,
              Icons.calendar_today,
              'Calendario',
              activeScreen == ActiveScreen.calendar,
              () {
                if (activeScreen != ActiveScreen.calendar) {
                  ref.read(activeScreenProvider.notifier).state =
                      ActiveScreen.calendar;
                  // Calendar navigation would go here
                }
              },
            ),
            _buildNavItem(
              context,
              Icons.settings,
              'Ajustes',
              activeScreen == ActiveScreen.settings,
              () {
                if (activeScreen != ActiveScreen.settings) {
                  ref.read(activeScreenProvider.notifier).state =
                      ActiveScreen.settings;
                  // Settings navigation would go here
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label,
      bool isActive, Function onTap) {
    final color = isActive ? Theme.of(context).primaryColor : Colors.grey;

    return GestureDetector(
      onTap: () => onTap(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
