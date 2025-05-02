import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/auth/providers/user_session_provider.dart';
import '../../data/repositories/invoice_repository_impl.dart';
import '../../../dashboard/presentation/controllers/transaction_controller.dart';

part 'invoice_controller.g.dart';

enum InvoiceUploadState {
  idle,
  uploading,
  success,
  error,
}

@Riverpod(keepAlive: true)
class InvoiceController extends _$InvoiceController {
  Timer? _stateResetTimer;

  @override
  InvoiceUploadState build() {
    ref.onDispose(() {
      _stateResetTimer?.cancel();
    });
    return InvoiceUploadState.idle;
  }

  Future<bool> uploadInvoice({
    required File invoiceFile,
    bool useOpenCV = true,
    String? categoryId,
    String? sharedGroupId,
  }) async {
    try {
      state = InvoiceUploadState.uploading;

      // Get user ID from session
      final userSession = ref.read(userSessionNotifierProvider);
      final userId = userSession.userId;

      if (userId == null || userId.isEmpty) {
        developer.log('User ID is null or empty, cannot upload invoice',
            name: 'invoice_controller');
        state = InvoiceUploadState.error;
        return false;
      }

      // Upload invoice
      final repository = ref.read(invoiceRepositoryProvider);
      final response = await repository.uploadInvoice(
        invoiceFile: invoiceFile,
        userId: userId,
        useOpenCV: useOpenCV,
        categoryId: categoryId,
        sharedGroupId: sharedGroupId,
      );

      developer.log('Invoice upload completed with response: $response',
          name: 'invoice_controller');

      // Refresh transactions to show the new transaction created from invoice
      ref.read(transactionsControllerProvider.notifier).refreshTransactions();

      // Update state
      state = InvoiceUploadState.success;

      // Reset state after a short delay
      _stateResetTimer?.cancel();
      _stateResetTimer = Timer(const Duration(seconds: 2), () {
        state = InvoiceUploadState.idle;
      });

      return true;
    } catch (e) {
      developer.log('Error uploading invoice: $e',
          name: 'invoice_controller', error: e);
      state = InvoiceUploadState.error;

      // Reset state after a short delay
      _stateResetTimer?.cancel();
      _stateResetTimer = Timer(const Duration(seconds: 2), () {
        state = InvoiceUploadState.idle;
      });

      return false;
    }
  }

  void resetState() {
    state = InvoiceUploadState.idle;
  }
}
