import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../datasources/invoice_upload_datasource.dart';
import '../datasources/http_invoice_upload_datasource.dart';

/// Implementation of the InvoiceRepository interface
class InvoiceRepositoryImpl implements InvoiceRepository {
  final InvoiceUploadDataSource dataSource;

  InvoiceRepositoryImpl({required this.dataSource});

  @override
  Future<String> uploadInvoice({
    required File invoiceFile,
    required String userId,
    bool useOpenCV = false,
    String? categoryId,
    String? sharedGroupId,
  }) async {
    return await dataSource.uploadInvoiceFile(
      invoiceFile: invoiceFile,
      userId: userId,
      useOpenCV: useOpenCV,
      categoryId: categoryId,
      sharedGroupId: sharedGroupId,
    );
  }
}

/// Provider for InvoiceRepository
final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  final dataSource = ref.watch(invoiceUploadDataSourceProvider);
  return InvoiceRepositoryImpl(dataSource: dataSource);
});
