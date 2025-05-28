import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  final _secureStorage = FlutterSecureStorage();
  late encrypt.Key _encryptionKey;
  late encrypt.IV _iv;
  late encrypt.Encrypter _encrypter;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Obtener o generar clave de cifrado
      String? storedKey = await _secureStorage.read(key: 'encryption_key');
      if (storedKey == null) {
        // Generar nueva clave si no existe
        final key = generateRandomKey();
        await _secureStorage.write(
            key: 'encryption_key', value: base64Encode(key.bytes));
        _encryptionKey = key;
        debugPrint('Generated new encryption key');
      } else {
        _encryptionKey = encrypt.Key(base64Decode(storedKey));
        debugPrint('Using existing encryption key');
      }

      // Configurar IV (vector de inicialización)
      _iv = encrypt.IV.fromLength(16);

      // Crear encriptador AES
      _encrypter = encrypt.Encrypter(encrypt.AES(_encryptionKey));

      _isInitialized = true;
      debugPrint('EncryptionService initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('Error initializing EncryptionService: $e');
      debugPrint(stackTrace.toString());
      rethrow;
    }
  }

  // Cifrar datos sensibles
  String encryptData(String plainText) {
    _ensureInitialized();
    final encrypted = _encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }

  // Descifrar datos
  String decryptData(String encryptedText) {
    _ensureInitialized();
    final encrypted = encrypt.Encrypted.fromBase64(encryptedText);
    return _encrypter.decrypt(encrypted, iv: _iv);
  }

  // Generar hash para contraseñas o verificaciones
  String hashData(String data) {
    final bytes = utf8.encode(data);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw Exception('EncryptionService must be initialized before use');
    }
  }

  // Genera una clave aleatoria para AES-256
  encrypt.Key generateRandomKey() => encrypt.Key.fromSecureRandom(32);

  // Add this method to allow checking initialization status from anywhere
  bool get isInitialized => _isInitialized;
}
