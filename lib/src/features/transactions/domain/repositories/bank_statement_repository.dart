import 'dart:io';

/// Repository interface for handling bank statement upload operations
abstract class BankStatementRepository {
  /// Uploads a bank statement file (PDF or CSV) to the backend
  /// Returns the response from the server
  Future<String> uploadBankStatement({
    required File bankStatementFile,
    required String userId,
  });
}
