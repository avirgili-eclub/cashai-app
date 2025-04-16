import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/data/firebase_auth_repository.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/presentation/custom_profile_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/features/authentication/presentation/custom_sign_in_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/features/entries/presentation/entries_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/features/entries/domain/entry.dart';
import 'package:starter_architecture_flutter_firebase/src/features/jobs/domain/job.dart';
import 'package:starter_architecture_flutter_firebase/src/features/entries/presentation/entry_screen/entry_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/features/jobs/presentation/job_entries_screen/job_entries_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/features/jobs/presentation/edit_job_screen/edit_job_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/features/jobs/presentation/jobs_screen/jobs_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/features/onboarding/data/onboarding_repository.dart';
import 'package:starter_architecture_flutter_firebase/src/features/onboarding/presentation/onboarding_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/go_router_refresh_stream.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/not_found_screen.dart';
import 'package:starter_architecture_flutter_firebase/src/routing/scaffold_with_nested_navigation.dart';
// Importar el DashboardScreen
import 'package:starter_architecture_flutter_firebase/src/features/dashboard/presentation/screens/dashboard_screen.dart';
// Update the import for CategoriesScreen
import '../features/categories/presentation/screens/categories_screen.dart';
// Add this import for the new screen
import '../features/categories/presentation/screens/category_transactions_screen.dart';
// Import the Category entity
import '../features/dashboard/domain/entities/category.dart';
// Add this import for TopCategory
import '../features/dashboard/domain/entities/recent_transaction.dart';
import '../features/dashboard/domain/entities/top_category.dart';
import '../features/dashboard/presentation/screens/transaction_details_screen.dart';
import '../features/dashboard/presentation/screens/all_transactions_screen.dart';
// Add this import at the top with the other imports
import '../features/transactions/presentation/screens/add_transaction_screen.dart';

part 'app_router.g.dart';

// private navigators
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _jobsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'jobs');
final _entriesNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'entries');
final _accountNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'account');
final _dashboardNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'dashboard');

enum AppRoute {
  onboarding,
  signIn,
  jobs,
  job,
  addJob,
  editJob,
  entry,
  addEntry,
  editEntry,
  entries,
  profile,
  // Nuevas rutas para la app de finanzas
  dashboard,
  categories,
  categoryTransactions,
  transactionDetails, // Add this new route
  allTransactions, // Add this new route
  addTransaction, // Add this new route enum
  expenses,
  incomes,
}

@riverpod
GoRouter goRouter(Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return GoRouter(
    //initialLocation: '/dashboard',
    initialLocation: '/signIn', // Change initial location to sign-in screen
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final onboardingRepository =
          ref.read(onboardingRepositoryProvider).requireValue;
      final didCompleteOnboarding = onboardingRepository.isOnboardingComplete();
      final path = state.uri.path;

      // Permitir acceso al dashboard, categories y transactions sin redirección
      // if (path.startsWith('/dashboard') ||
      //     path.startsWith('/categories') ||
      //     path.startsWith('/transactions') ||
      //     path.startsWith('/all-transactions') ||
      //     path.startsWith('/add-transaction')) {
      //   // Add this path
      //   return null;
      // }

      if (!didCompleteOnboarding) {
        if (path != '/onboarding') {
          return '/onboarding';
        }
        return null;
      }

      final isLoggedIn = authRepository.currentUser != null;
      if (isLoggedIn) {
        if (path.startsWith('/onboarding') || path.startsWith('/signIn')) {
          return '/dashboard'; // Redirect to dashboard instead of jobs when logged in
        }
      } else {
        if (path.startsWith('/onboarding') ||
            path.startsWith('/jobs') ||
            path.startsWith('/entries') ||
            path.startsWith('/account') ||
            path.startsWith('/expenses') ||
            path.startsWith('/incomes') ||
            path.startsWith('/dashboard')) {
          // Add dashboard to protected routes
          return '/signIn';
        }
      }
      return null;
    },
    refreshListenable: GoRouterRefreshStream(authRepository.authStateChanges()),
    routes: [
      // Ruta del Dashboard
      GoRoute(
        path: '/dashboard',
        name: AppRoute.dashboard.name,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: DashboardScreen(),
        ),
      ),
      GoRoute(
        path: '/onboarding',
        name: AppRoute.onboarding.name,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: '/signIn',
        name: AppRoute.signIn.name,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: CustomSignInScreen(),
        ),
      ),
      // Rutas adicionales para las nuevas secciones
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
      // Add the new route for category transactions
      GoRoute(
        path: '/categories/:id',
        name: AppRoute.categoryTransactions.name,
        pageBuilder: (context, state) {
          final categoryId = state.pathParameters['id'] ?? '';
          // Change the type cast from Category to TopCategory
          final category = state.extra as TopCategory?;
          return NoTransitionPage(
            child: CategoryTransactionsScreen(
              categoryId: categoryId,
              category: category,
            ),
          );
        },
      ),
      // Add the new route for transaction details
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
      // Add the new route for all transactions
      GoRoute(
        path: '/all-transactions',
        name: AppRoute.allTransactions.name,
        pageBuilder: (context, state) {
          // Extract filter from query parameters if available
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
          // Get the tab parameter from query parameters and convert to int
          final tabParam = state.uri.queryParameters['tab'];
          final initialTabIndex =
              tabParam != null ? int.tryParse(tabParam) ?? 0 : 0;

          return NoTransitionPage(
            child: AddTransactionScreen(initialTabIndex: initialTabIndex),
          );
        },
      ),
      // Stateful navigation based on:
      // https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/stateful_shell_route.dart
      StatefulShellRoute.indexedStack(
        pageBuilder: (context, state, navigationShell) => NoTransitionPage(
          child: ScaffoldWithNestedNavigation(navigationShell: navigationShell),
        ),
        branches: [
          StatefulShellBranch(
            navigatorKey:
                _dashboardNavigatorKey, // Nueva rama para el dashboard
            routes: [
              GoRoute(
                path: '/dashboard-tab',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: DashboardScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _jobsNavigatorKey,
            routes: [
              GoRoute(
                path: '/jobs',
                name: AppRoute.jobs.name,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: JobsScreen(),
                ),
                routes: [
                  // Rutas anidadas existentes...
                  GoRoute(
                    path: 'add',
                    name: AppRoute.addJob.name,
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) {
                      return const MaterialPage(
                        fullscreenDialog: true,
                        child: EditJobScreen(),
                      );
                    },
                  ),
                  GoRoute(
                    path: ':id',
                    name: AppRoute.job.name,
                    pageBuilder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return MaterialPage(
                        child: JobEntriesScreen(jobId: id),
                      );
                    },
                    routes: [
                      GoRoute(
                        path: 'entries/add',
                        name: AppRoute.addEntry.name,
                        parentNavigatorKey: _rootNavigatorKey,
                        pageBuilder: (context, state) {
                          final jobId = state.pathParameters['id']!;
                          return MaterialPage(
                            fullscreenDialog: true,
                            child: EntryScreen(
                              jobId: jobId,
                            ),
                          );
                        },
                      ),
                      GoRoute(
                        path: 'entries/:eid',
                        name: AppRoute.entry.name,
                        pageBuilder: (context, state) {
                          final jobId = state.pathParameters['id']!;
                          final entryId = state.pathParameters['eid']!;
                          final entry = state.extra as Entry?;
                          return MaterialPage(
                            child: EntryScreen(
                              jobId: jobId,
                              entryId: entryId,
                              entry: entry,
                            ),
                          );
                        },
                      ),
                      GoRoute(
                        path: 'edit',
                        name: AppRoute.editJob.name,
                        pageBuilder: (context, state) {
                          final jobId = state.pathParameters['id'];
                          final job = state.extra as Job?;
                          return MaterialPage(
                            fullscreenDialog: true,
                            child: EditJobScreen(jobId: jobId, job: job),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _entriesNavigatorKey,
            routes: [
              GoRoute(
                path: '/entries',
                name: AppRoute.entries.name,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: EntriesScreen(),
                ),
              ),
            ],
          ),
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
