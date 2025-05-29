import 'package:flutter/services.dart';
import 'dart:developer' as developer;

/// Servicio para gestionar SSL Pinning y verificaciones de seguridad de red
class SSLPinningService {
  static final SSLPinningService _instance = SSLPinningService._internal();
  factory SSLPinningService() => _instance;
  SSLPinningService._internal();

  static const MethodChannel _platform = MethodChannel(
    'com.cashai.app/security',
  );

  /// Configura el SSL Pinning
  ///
  /// [enable] - activa o desactiva el pinning (por defecto: true)
  /// Retorna true si la configuración fue exitosa
  Future<bool> setupSSLPinning({bool enable = true}) async {
    try {
      final result = await _platform.invokeMethod<bool>('setupSSLPinning', {
        'enable': enable,
      });
      developer.log(
        'SSL Pinning ${enable ? 'activado' : 'desactivado'}: ${result ?? false}',
        name: 'ssl_pinning',
      );
      return result ?? false;
    } catch (e) {
      developer.log(
        'Error configurando SSL Pinning: $e',
        name: 'ssl_pinning',
        error: e,
      );
      return false;
    }
  }

  /// Verifica si una conexión a un URL es segura según las reglas de pinning
  ///
  /// [url] - URL a verificar
  /// Retorna true si la conexión es segura
  Future<bool> checkSecureConnection(String url) async {
    try {
      final result = await _platform.invokeMethod<bool>('checkConnection', {
        'url': url,
      });
      developer.log(
        'Verificación de conexión a $url: ${result ?? false}',
        name: 'ssl_pinning',
      );
      return result ?? false;
    } catch (e) {
      developer.log(
        'Error verificando conexión: $e',
        name: 'ssl_pinning',
        error: e,
      );
      return false;
    }
  }

  /// Verifica si el SSL Pinning está habilitado
  Future<bool> isPinningEnabled() async {
    try {
      final result = await _platform.invokeMethod<bool>('isPinningEnabled');
      return result ?? false;
    } catch (e) {
      developer.log(
        'Error consultando estado de SSL Pinning: $e',
        name: 'ssl_pinning',
        error: e,
      );
      return false;
    }
  }
}
