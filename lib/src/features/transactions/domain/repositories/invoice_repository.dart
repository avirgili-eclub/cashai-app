import 'dart:io';

/// Repository interface for handling invoice upload operations
abstract class InvoiceRepository {
  /// Uploads an invoice image to the backend
  /// Returns the response from the server
  Future<String> uploadInvoice({
    required File invoiceFile,
    required String userId,
    bool useOpenCV = false,
    String? categoryId,
    String? sharedGroupId,
  });
}
