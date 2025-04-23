import 'dart:io';

/// Data source interface for invoice upload operations
abstract class InvoiceUploadDataSource {
  /// Uploads an invoice file to the backend
  /// Returns the response from the server
  Future<String> uploadInvoiceFile({
    required File invoiceFile,
    required String userId,
    bool useOpenCV = false,
    String? categoryId,
    String? sharedGroupId,
  });
}
