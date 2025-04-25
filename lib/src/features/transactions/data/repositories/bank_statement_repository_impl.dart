import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/bank_statement_repository.dart';
import '../datasources/bank_statement_upload_datasource.dart';
import '../datasources/http_bank_statement_upload_datasource.dart';

/// Implementation of the BankStatementRepository interface
class BankStatementRepositoryImpl implements BankStatementRepository {
  final BankStatementUploadDataSource dataSource;

  BankStatementRepositoryImpl({required this.dataSource});

  @override
  Future<String> uploadBankStatement({
    required File bankStatementFile,
    required String userId,
  }) async {
    return await dataSource.uploadBankStatementFile(
      bankStatementFile: bankStatementFile,
      userId: userId,
    );
  }
}

/// Provider for BankStatementRepository
final bankStatementRepositoryProvider =
    Provider<BankStatementRepository>((ref) {
  final dataSource = ref.watch(bankStatementUploadDataSourceProvider);
  return BankStatementRepositoryImpl(dataSource: dataSource);
});
