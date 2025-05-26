import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
// Updated import path
import 'package:numia/src/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:numia/src/features/authentication/presentation/custom_profile_screen.dart';
import 'package:numia/src/features/authentication/presentation/custom_sign_in_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:numia/src/routing/go_router_refresh_stream.dart';
import 'package:numia/src/routing/jwt_router_refresh_listenable.dart';
import 'package:numia/src/routing/not_found_screen.dart';
import 'package:numia/src/routing/scaffold_with_nested_navigation.dart';
// Finance app imports
import 'package:numia/src/features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/categories/presentation/screens/categories_screen.dart';
import '../features/categories/presentation/screens/category_transactions_screen.dart';
import '../features/dashboard/domain/entities/recent_transaction.dart';
import '../features/dashboard/domain/entities/top_category.dart';
import '../features/statistics/presentation/screens/statistics_screen.dart';
import '../features/dashboard/presentation/screens/transaction_details_screen.dart';
import '../features/dashboard/presentation/screens/all_transactions_screen.dart';
import '../features/transactions/presentation/screens/add_transaction_screen.dart';
import '../core/auth/providers/user_session_provider.dart';
import '../features/user/presentation/screens/user_profile_screen.dart';

part 'app_router.g.dart';

// private navigators
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _accountNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'account');
final _dashboardNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'dashboard');

enum AppRoute {
  // Remove onboarding
  signIn,
  profile,
  // Finance app routes
  dashboard,
  categories,
  categoryTransactions,
  transactionDetails,
  allTransactions,
  addTransaction,
  expenses,
  incomes,
  userProfile,
  statistics, // Add statistics route
}

// Extension to combine multiple refresh sources
extension GoRouterRefreshListenableExtension on Listenable {
  Listenable combineListenable(Listenable other) {
    return CombinedListenable([this, other]);
  }
}

// Combined listenable class
class CombinedListenable extends ChangeNotifier {
  CombinedListenable(this.listenables) {
    for (var listenable in listenables) {
      listenable.addListener(notifyListeners);
    }
  }

  final List<Listenable> listenables;

  @override
  void dispose() {
    for (var listenable in listenables) {
      listenable.removeListener(notifyListeners);
    }
    super.dispose();
  }
}

// Store the initial route for the app - revert back to StateProvider for simplicity
final initialRouteProvider = StateProvider<String>((ref) => '/signIn');

@riverpod
GoRouter goRouter(Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final userSession = ref.watch(userSessionNotifierProvider);
  final jwtRefreshListenable = ref.watch(jwtAuthRefreshListenableProvider);

  // Get the initial route from initialRoute provider
  final initialRoute = ref.watch(initialRouteProvider);

  return GoRouter(
    initialLocation: initialRoute,
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // Remove onboarding check code
      final path = state.uri.path;

      // Check both Firebase auth and JWT token authentication
      final isFirebaseLoggedIn = authRepository.currentUser != null;
      // Check if user session is empty or token is missing
      final hasJwtToken = userSession.userId != null &&
          !userSession.isEmpty &&
          userSession.token != null &&
          userSession.token!.isNotEmpty;
      final isLoggedIn = isFirebaseLoggedIn || hasJwtToken;

      // Log auth state for debugging
      debugPrint(
          'Firebase auth: $isFirebaseLoggedIn, JWT auth: $hasJwtToken, path: $path');

      if (isLoggedIn) {
        if (path.startsWith('/signIn')) {
          return '/dashboard'; // Redirect to dashboard when logged in
        }
      } else {
        // Protected routes require authentication
        if (path.startsWith('/account') ||
            path.startsWith('/expenses') ||
            path.startsWith('/incomes') ||
            path.startsWith('/dashboard')) {
          return '/signIn';
        }
      }
      return null;
    },
    // Use a ListenableList to combine multiple refresh sources
    refreshListenable: GoRouterRefreshStream(authRepository.authStateChanges())
        .combineListenable(jwtRefreshListenable),
    routes: [
      // Finance app routes
      GoRoute(
        path: '/dashboard',
        name: AppRoute.dashboard.name,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: DashboardScreen(),
        ),
      ),
      // Remove onboarding route
      GoRoute(
        path: '/signIn',
        name: AppRoute.signIn.name,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: CustomSignInScreen(),
        ),
      ),
      // Additional finance app routes
      GoRoute(
        path: '/categories',
        name: AppRoute.categories.name,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: CategoriesScreen(),
        ),
      ),
      GoRoute(
        path: '/expenses',
        name: AppRoute.expenses.name,
        pageBuilder: (context, state) => NoTransitionPage(
          child: Scaffold(
            appBar: AppBar(title: const Text('Gastos')),
            body: const Center(child: Text('Pantalla de Gastos')),
          ),
        ),
      ),
      GoRoute(
        path: '/incomes',
        name: AppRoute.incomes.name,
        pageBuilder: (context, state) => NoTransitionPage(
          child: Scaffold(
            appBar: AppBar(title: const Text('Ingresos')),
            body: const Center(child: Text('Pantalla de Ingresos')),
          ),
        ),
      ),
      // Category transactions route
      GoRoute(
        path: '/categories/:id',
        name: AppRoute.categoryTransactions.name,
        pageBuilder: (context, state) {
          final categoryId = state.pathParameters['id'] ?? '';
          final category = state.extra as TopCategory?;
          return NoTransitionPage(
            child: CategoryTransactionsScreen(
              categoryId: categoryId,
              category: category,
            ),
          );
        },
      ),
      // Transaction details route
      GoRoute(
        path: '/transactions/:id',
        name: AppRoute.transactionDetails.name,
        pageBuilder: (context, state) {
          final transactionId = state.pathParameters['id'] ?? '';
          final transaction = state.extra as RecentTransaction?;
          return NoTransitionPage(
            child: TransactionDetailsScreen(
              transactionId: transactionId,
              transaction: transaction,
            ),
          );
        },
      ),
      // All transactions route
      GoRoute(
        path: '/all-transactions',
        name: AppRoute.allTransactions.name,
        pageBuilder: (context, state) {
          final initialFilter = state.uri.queryParameters['filter'] ?? '';
          return NoTransitionPage(
            child: AllTransactionsScreen(initialFilter: initialFilter),
          );
        },
      ),
      // Add Transaction route
      GoRoute(
        path: '/add-transaction',
        name: AppRoute.addTransaction.name,
        pageBuilder: (context, state) {
          final tabParam = state.uri.queryParameters['tab'];
          final initialTabIndex =
              tabParam != null ? int.tryParse(tabParam) ?? 0 : 0;

          return NoTransitionPage(
            child: AddTransactionScreen(initialTabIndex: initialTabIndex),
          );
        },
      ),
      // User profile route - updated to use AppRoute enum
      GoRoute(
        path: '/user-profile',
        name: AppRoute
            .userProfile.name, // Use enum value instead of string literal
        pageBuilder: (context, state) => const NoTransitionPage(
          child: UserProfileScreen(),
        ),
      ),
      // Statistics route - new addition
      GoRoute(
        path: '/statistics',
        name: AppRoute.statistics.name,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: StatisticsScreen(),
        ),
      ),
      // Bottom navigation with tabs
      StatefulShellRoute.indexedStack(
        pageBuilder: (context, state, navigationShell) => NoTransitionPage(
          child: ScaffoldWithNestedNavigation(navigationShell: navigationShell),
        ),
        branches: [
          // Dashboard tab
          StatefulShellBranch(
            navigatorKey: _dashboardNavigatorKey,
            routes: [
              GoRoute(
                path: '/dashboard-tab',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: DashboardScreen(),
                ),
              ),
            ],
          ),
          // Account/profile tab
          StatefulShellBranch(
            navigatorKey: _accountNavigatorKey,
            routes: [
              GoRoute(
                path: '/account',
                name: AppRoute.profile.name,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: CustomProfileScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
    errorPageBuilder: (context, state) => const NoTransitionPage(
      child: NotFoundScreen(),
    ),
  );
}
