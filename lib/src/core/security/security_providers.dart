import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'encryption_service.dart';
import 'security_checker.dart';

final encryptionServiceProvider = Provider<EncryptionService>((ref) {
  return EncryptionService();
});

final securityCheckerProvider = Provider<SecurityChecker>((ref) {
  return SecurityChecker();
});
