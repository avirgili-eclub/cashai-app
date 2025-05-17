import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // Importamos intl para formateo de números
import 'package:intl/date_symbol_data_local.dart'; // Para inicializar locales
import 'package:numia/firebase_options.dart';
import 'package:numia/src/app.dart';
import 'package:numia/src/core/config/api_config.dart'; // Import the API config
import 'package:numia/src/core/styles/app_styles.dart';
import 'package:numia/src/localization/string_hardcoded.dart';
// ignore:depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // turn off the # in the URLs on the web
  usePathUrlStrategy();
  // * Register error handlers. For more info, see:
  // * https://docs.flutter.dev/testing/errors
  registerErrorHandlers();
  // * Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize intl date formatting for Spanish locale (Paraguay)
  await initializeDateFormatting('es_PY', null);

  // Set the default number format locale
  Intl.defaultLocale = 'es_PY';

  // Initialize the API configuration
  // Para forzar el uso de la URL de producción, establece isProduction como true
  // O usa const bool forceProduction = true; para pruebas de producción mientras estás en desarrollo
  const bool forceProduction = false; // Forzar modo producción para pruebas
  ApiConfig().init(
    isProduction: forceProduction || kReleaseMode,
    // La URL personalizada solo debe usarse si realmente necesitas una URL diferente
    // Si comentas esta línea, se usará la URL configurada en ApiConfig basada en isProduction
    // customBaseUrl: 'https://dev.ucashai.app',
  );

  // Mostrar la URL base que se está usando para verificar
  debugPrint('API URL base en uso: ${ApiConfig().getBaseHost()}');

  // * Entry point of the app
  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

void registerErrorHandlers() {
  // * Show some error UI if any uncaught exception happens
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint(details.toString());
  };
  // * Handle errors from the underlying platform/OS
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint(error.toString());
    return true;
  };
  // * Show some error UI when any widget in the app fails to build
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text('An error occurred'.hardcoded),
      ),
      body: Center(child: Text(details.toString())),
    );
  };
}
