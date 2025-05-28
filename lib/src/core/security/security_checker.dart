import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:jailbreak_root_detection/jailbreak_root_detection.dart';

class SecurityChecker {
  static final SecurityChecker _instance = SecurityChecker._internal();
  factory SecurityChecker() => _instance;
  SecurityChecker._internal();

  Future<bool> isDeviceSecure() async {
    // Omitir verificaciones en modo debug
    if (kDebugMode) return true;

    try {
      // Verificar si el dispositivo no es confiable (rooteado o con jailbreak)
      final isNotTrust = await JailbreakRootDetection.instance.isNotTrust;

      // Verificar si está en modo desarrollador (solo para Android)
      bool isDeveloperMode = false;
      if (Platform.isAndroid) {
        isDeveloperMode = await JailbreakRootDetection.instance.isDevMode;
      }

      // Verificaciones adicionales para mayor seguridad
      final checkForIssues =
          await JailbreakRootDetection.instance.checkForIssues;
      final hasSecurityIssues = checkForIssues.isNotEmpty;

      // Para iOS, verificar si la aplicación ha sido manipulada
      bool isTampered = false;
      if (Platform.isIOS) {
        // Bundle ID para iOS
        const bundleId = 'com.virtech.numia';
        isTampered = await JailbreakRootDetection.instance.isTampered(bundleId);
      } else if (Platform.isAndroid) {
        // Application ID para Android
        const applicationId = 'com.cashai.app';
        // En Android, isTampered() no requiere el applicationId, pero lo dejamos comentado
        // para futuras referencias o cambios en la API
        isTampered =
            await JailbreakRootDetection.instance.isTampered(applicationId);
      }

      // Verificar si está instalado en almacenamiento externo (solo Android)
      bool isOnExternalStorage = false;
      if (Platform.isAndroid) {
        isOnExternalStorage =
            await JailbreakRootDetection.instance.isOnExternalStorage;
      }

      // El dispositivo se considera seguro si:
      // - No es rooteado/jailbreak
      // - No está en modo desarrollador (Android)
      // - No tiene problemas de seguridad detectados
      // - No ha sido manipulado (iOS)
      // - No está instalado en almacenamiento externo (Android)
      return !isNotTrust &&
          !isDeveloperMode &&
          !hasSecurityIssues &&
          !isTampered &&
          !isOnExternalStorage;
    } catch (e) {
      debugPrint('Error checking device security: $e');
      // Si hay un error en la detección, asume que es seguro para evitar bloqueos
      return true;
    }
  }
}
