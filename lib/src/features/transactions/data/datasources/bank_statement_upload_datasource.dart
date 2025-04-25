import 'dart:io';

/// Data source interface for bank statement upload operations
abstract class BankStatementUploadDataSource {
  /// Uploads a bank statement file (PDF or CSV) to the backend
  /// Returns the response from the server
  Future<String> uploadBankStatementFile({
    required File bankStatementFile,
    required String userId,
  });
}
