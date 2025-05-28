import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:force_update_helper/force_update_helper.dart';
import 'package:cashai/src/core/styles/app_styles.dart';
import 'package:cashai/src/routing/app_router.dart';
import 'package:cashai/src/routing/app_startup.dart';
import 'package:cashai/src/utils/alert_dialogs.dart';
import 'package:url_launcher/url_launcher.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);
    return MaterialApp.router(
      routerConfig: goRouter,
      builder: (_, child) {
        // * Important: Use AppStartupWidget to wrap ForceUpdateWidget otherwise you will get this error:
        // * Navigator operation requested with a context that does not include a Navigator.
        // * The context used to push or pop routes from the Navigator must be that of a widget that is a descendant of a Navigator widget.
        return AppStartupWidget(
          onLoaded: (_) => ForceUpdateWidget(
            navigatorKey: goRouter.routerDelegate.navigatorKey,
            forceUpdateClient: ForceUpdateClient(
              // * Real apps should fetch this from an API endpoint or via
              // * Firebase Remote Config
              fetchRequiredVersion: () => Future.value('0.0.1'),
              // * Example ID from this app: https://fluttertips.dev/
              // * To avoid mistakes, store the ID as an environment variable and
              // * read it with String.fromEnvironment
              iosAppStoreId: '6482293361',
            ),
            allowCancel: false,
            showForceUpdateAlert: (context, allowCancel) => showAlertDialog(
              context: context,
              title: 'App Update Required',
              content: 'Please update to continue using the app.',
              cancelActionText: allowCancel ? 'Later' : null,
              defaultActionText: 'Update Now',
            ),
            showStoreListing: (storeUrl) async {
              if (await canLaunchUrl(storeUrl)) {
                await launchUrl(
                  storeUrl,
                  // * Open app store app directly (or fallback to browser)
                  mode: LaunchMode.externalApplication,
                );
              } else {
                log('Cannot launch URL: $storeUrl');
              }
            },
            onException: (e, st) {
              log(e.toString());
            },
            child: child!,
          ),
        );
      },
      theme: AppStyles.theme.copyWith(
        // Merge any specific UI customizations not covered in AppStyles
        // while still using AppStyles colors
        unselectedWidgetColor: Colors.grey,
        appBarTheme: AppBarTheme(
          backgroundColor: AppStyles.primaryColor,
          foregroundColor: Colors.white,
          elevation: 2.0,
          centerTitle: true,
        ),
        scaffoldBackgroundColor: Colors.grey[200],
        dividerColor: Colors.grey[400],
        // Add back the elevated button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppStyles.primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
