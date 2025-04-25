import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/auth/providers/user_session_provider.dart';
import '../../data/repositories/bank_statement_repository_impl.dart';
import '../../../dashboard/presentation/controllers/transaction_controller.dart';

part 'bank_statement_controller.g.dart';

enum BankStatementUploadState {
  idle,
  uploading,
  success,
  error,
}

@Riverpod(keepAlive: true)
class BankStatementController extends _$BankStatementController {
  Timer? _stateResetTimer;

  @override
  BankStatementUploadState build() {
    ref.onDispose(() {
      _stateResetTimer?.cancel();
    });
    return BankStatementUploadState.idle;
  }

  Future<bool> uploadBankStatement({
    required File bankStatementFile,
  }) async {
    try {
      state = BankStatementUploadState.uploading;

      // Get user ID from session
      final userSession = ref.read(userSessionNotifierProvider);
      final userId = userSession.userId;

      if (userId == null || userId.isEmpty) {
        developer.log('User ID is null or empty, cannot upload bank statement',
            name: 'bank_statement_controller');
        state = BankStatementUploadState.error;
        return false;
      }

      // Upload bank statement
      final repository = ref.read(bankStatementRepositoryProvider);
      final response = await repository.uploadBankStatement(
        bankStatementFile: bankStatementFile,
        userId: userId,
      );

      developer.log('Bank statement upload completed with response: $response',
          name: 'bank_statement_controller');

      // Refresh transactions to show the new transactions created from bank statement
      ref.read(transactionsControllerProvider.notifier).refreshTransactions();

      // Update state
      state = BankStatementUploadState.success;

      // Reset state after a short delay
      _stateResetTimer?.cancel();
      _stateResetTimer = Timer(const Duration(seconds: 2), () {
        state = BankStatementUploadState.idle;
      });

      return true;
    } catch (e) {
      developer.log('Error uploading bank statement: $e',
          name: 'bank_statement_controller', error: e);
      state = BankStatementUploadState.error;

      // Reset state after a short delay
      _stateResetTimer?.cancel();
      _stateResetTimer = Timer(const Duration(seconds: 2), () {
        state = BankStatementUploadState.idle;
      });

      return false;
    }
  }

  void resetState() {
    state = BankStatementUploadState.idle;
  }
}
