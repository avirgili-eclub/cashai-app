import 'dart:developer' as developer;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/auth/providers/user_session_provider.dart';
import '../../../../core/styles/app_styles.dart';
import '../../../../routing/app_router.dart';
import '../../domain/services/dashboard_data_service.dart';
import '../controllers/balance_controller.dart';
import '../controllers/transaction_controller.dart';
import '../widgets/app_header.dart';
import '../widgets/balance_card.dart';
import '../widgets/collapsible_actions_card.dart';
import '../widgets/recent_transactions_list.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/send_audio_button.dart';
import '../providers/post_login_splash_provider.dart';
import '../../../../../src/widgets/app_splash_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _isDataLoading = false;
  bool _forceShowSplash = true; // Add this flag to force splash on first build
  bool _isAnimatingOut =
      false; // Add a boolean to track if animation is in progress
  Timer? _splashHideTimer; // Add a timer field for splash screen auto-hide

  @override
  void initState() {
    super.initState();

    // Always force splash on first build for smoother transition
    _forceShowSplash = true;
    _isDataLoading = true;

    // Set a safety timer to force-hide splash after a maximum time
    _splashHideTimer = Timer(const Duration(seconds: 15), () {
      if (mounted) {
        developer.log('Safety timer triggered to hide splash screen',
            name: 'dashboard_screen');
        setState(() {
          _isAnimatingOut = true;
          _isDataLoading = false;
          _forceShowSplash = false;
        });
      }
    });

    // Check splash status after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final showSplash = ref.read(postLoginSplashStateProvider);
      developer.log(
          'Splash state in initState: $showSplash, forcing show: $_forceShowSplash',
          name: 'dashboard_screen');

      // Begin loading data immediately, splash will be shown by build method
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    // Cancel timer on dispose
    _splashHideTimer?.cancel();
    super.dispose();
  }

  // Method to load all data and hide splash when finished
  Future<void> _loadInitialData() async {
    developer.log('Loading initial dashboard data after login',
        name: 'dashboard_screen');

    try {
      // Set a timeout for data loading to prevent the splash from being stuck
      await ref
          .read(dashboardDataServiceProvider.notifier)
          .refreshAllData()
          .timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          developer.log('Data loading timeout exceeded',
              name: 'dashboard_screen');
          throw TimeoutException('Tiempo de carga excedido');
        },
      );

      // First wait for balance data to be loaded
      await ref.read(balanceControllerProvider.future);

      // Then wait for transactions data to be loaded
      await ref.read(transactionsControllerProvider.future);

      // Add a small delay to ensure data is properly displayed
      await Future.delayed(const Duration(microseconds: 800));

      if (mounted) {
        // Start animation out instead of immediately hiding
        setState(() {
          _isAnimatingOut = true;
          _isDataLoading = false;
        });

        // Let the animation handle splash state
        developer.log('Starting animation to hide splash screen',
            name: 'dashboard_screen');
      }
    } catch (e) {
      // In case of error, still start the animation out
      if (mounted) {
        developer.log(
            'Error during data loading, hiding splash with animation: $e',
            name: 'dashboard_screen',
            error: e);
        setState(() {
          _isAnimatingOut = true;
          _isDataLoading = false;
          _forceShowSplash = false;
        });
      }
    }

    // When loading completes, cancel the safety timer since we no longer need it
    _splashHideTimer?.cancel();
  }

  // Use the shared splash screen widget with animation
  Widget _buildSplashScreen(BuildContext context) {
    return AnimatedOpacity(
      opacity: _isAnimatingOut ? 0.0 : 1.0,
      duration: const Duration(seconds: 1),
      onEnd: () {
        // When animation completes, fully hide splash
        if (_isAnimatingOut && mounted) {
          setState(() {
            _forceShowSplash = false;
            _isAnimatingOut = false;
          });
          ref.read(postLoginSplashStateProvider.notifier).hideSplash();
          developer.log('Animation complete, splash hidden',
              name: 'dashboard_screen');
        }
      },
      child: const AppSplashScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    developer.log('Building DashboardScreen', name: 'dashboard_screen');
    final userSession = ref.watch(userSessionNotifierProvider);

    // Check all splash conditions
    final showSplashFromProvider = ref.watch(postLoginSplashStateProvider);
    final showSplash = showSplashFromProvider ||
        _isDataLoading ||
        _forceShowSplash ||
        _isAnimatingOut;

    developer.log(
        'Splash state: provider=$showSplashFromProvider, local=$_isDataLoading, ' +
            'force=$_forceShowSplash, animating=$_isAnimatingOut, combined=$showSplash',
        name: 'dashboard_screen');

    // Create the dashboard content
    final dashboardContent = Scaffold(
      appBar: AppBar(
        title: const Text('CashAI'),
        backgroundColor: AppStyles.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.person),
          onPressed: () => context.pushNamed(AppRoute.userProfile.name),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: null,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () {
          developer.log('Manual refresh triggered', name: 'dashboard_screen');
          return ref
              .read(dashboardDataServiceProvider.notifier)
              .refreshAllData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppHeader(userName: userSession.username ?? 'Usuario'),
              _buildBalanceCardWithErrorHandler(ref),
              const SizedBox(height: 16),
              const CollapsibleActionsCard(),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Transacciones Recientes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.pushNamed(
                          AppRoute.allTransactions.name,
                          queryParameters: {'filter': ''},
                        );
                      },
                      child: const Text(
                        'Ver Todo',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 420,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: const RecentTransactionsList(
                  limit: 10,
                  showEmpty: true,
                  emptyMessage: 'No hay transacciones recientes',
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 70,
        child: const BottomNavBar(),
      ),
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 15),
        child: SendAudioButton(
          onTransactionAdded: () {
            ref.read(dashboardDataServiceProvider.notifier).refreshAllData();
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );

    // Only show splash screen if needed, otherwise show the dashboard
    if (showSplash) {
      // Create the dashboard OFFSCREEN to force data rendering
      return Stack(
        children: [
          // Hide the dashboard underneath by setting opacity to 0
          Opacity(
            opacity: 0.0,
            child: dashboardContent,
          ),
          // Show the splash screen on top
          _buildSplashScreen(context),
        ],
      );
    }

    // Once splash is dismissed, show the already-built dashboard
    return dashboardContent;
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
}
