import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/styles/app_styles.dart';
import '../controllers/transaction_controller.dart';
import '../screens/invoice_image_viewer_screen.dart';

enum _CardState { idle, loading }

class InvoicePreviewCard extends ConsumerStatefulWidget {
  final String transactionId;

  const InvoicePreviewCard({super.key, required this.transactionId});

  @override
  ConsumerState<InvoicePreviewCard> createState() => _InvoicePreviewCardState();
}

class _InvoicePreviewCardState extends ConsumerState<InvoicePreviewCard> {
  _CardState _cardState = _CardState.idle;
  String? _cachedUrl;
  DateTime? _fetchedAt;

  static const _urlTtl = Duration(minutes: 55);

  bool get _isCacheValid =>
      _cachedUrl != null &&
      _fetchedAt != null &&
      DateTime.now().difference(_fetchedAt!) < _urlTtl;

  Future<void> _onTap() async {
    if (_cardState == _CardState.loading) return;

    // URL cacheada y vigente → abre viewer sin request al backend
    if (_isCacheValid) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => InvoiceImageViewerScreen(imageUrl: _cachedUrl!),
        ),
      );
      return;
    }

    setState(() => _cardState = _CardState.loading);

    try {
      final detail = await ref.read(
        transactionDetailProvider(widget.transactionId).future,
      );

      if (!mounted) return;

      final url = detail.invoiceImageUrl;
      if (url == null || url.isEmpty) {
        _showError('No se encontró imagen de factura');
        return;
      }

      _cachedUrl = url;
      _fetchedAt = DateTime.now();

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => InvoiceImageViewerScreen(imageUrl: url),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      _showError('Error al cargar la factura. Intentá de nuevo.');
    } finally {
      if (mounted) {
        setState(() => _cardState = _CardState.idle);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.fixed,
        duration: const Duration(seconds: 3),
      ),
    );
    setState(() => _cardState = _CardState.idle);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _cardState == _CardState.loading;

    return GestureDetector(
      onTap: isLoading ? null : _onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppStyles.primaryColor.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppStyles.primaryColor.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppStyles.primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppStyles.primaryColor,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.receipt_long_outlined,
                      color: AppStyles.primaryColor,
                      size: 22,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isLoading ? 'Cargando factura...' : 'Ver Factura',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppStyles.primaryColor,
                    ),
                  ),
                  if (!isLoading) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Toca para ver el comprobante',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppStyles.secondaryTextColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!isLoading)
              const Icon(
                Icons.chevron_right,
                color: AppStyles.primaryColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
