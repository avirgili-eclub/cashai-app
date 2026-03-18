import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../screens/invoice_image_viewer_screen.dart';

class InvoiceImageWidget extends StatelessWidget {
  final String? invoiceImageUrl;

  const InvoiceImageWidget({super.key, this.invoiceImageUrl});

  @override
  Widget build(BuildContext context) {
    if (invoiceImageUrl == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              InvoiceImageViewerScreen(imageUrl: invoiceImageUrl!),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: invoiceImageUrl!,
          placeholder: (context, url) => const AspectRatio(
            aspectRatio: 4 / 3,
            child: Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.broken_image_outlined, color: Colors.grey),
            ),
          ),
          fit: BoxFit.cover,
          // No headers — AWS pre-signed URL has auth in query params
        ),
      ),
    );
  }
}
