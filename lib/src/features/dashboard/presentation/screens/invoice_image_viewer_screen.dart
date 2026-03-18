import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class InvoiceImageViewerScreen extends StatefulWidget {
  final String imageUrl;

  const InvoiceImageViewerScreen({super.key, required this.imageUrl});

  @override
  State<InvoiceImageViewerScreen> createState() =>
      _InvoiceImageViewerScreenState();
}

class _InvoiceImageViewerScreenState extends State<InvoiceImageViewerScreen> {
  bool _isLoading = false;

  Future<Uint8List?> _downloadImageBytes() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse(widget.imageUrl));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      return null;
    } catch (_) {
      return null;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _shareImage() async {
    final bytes = await _downloadImageBytes();
    if (bytes == null) {
      _showSnackBar('Error al compartir la imagen', isError: true);
      return;
    }
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/invoice_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(file.path)], text: 'Factura');
  }

  Future<void> _saveImage() async {
    final bytes = await _downloadImageBytes();
    if (bytes == null) {
      _showSnackBar('Error al guardar la imagen', isError: true);
      return;
    }
    try {
      await Gal.putImageBytes(bytes);
      _showSnackBar('Imagen guardada');
    } catch (_) {
      _showSnackBar('Error al guardar', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Factura'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: 'Compartir',
              onPressed: _shareImage,
            ),
            IconButton(
              icon: const Icon(Icons.save_alt),
              tooltip: 'Guardar en galería',
              onPressed: _saveImage,
            ),
          ],
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: CachedNetworkImage(
            imageUrl: widget.imageUrl,
            placeholder: (context, url) => const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            errorWidget: (context, url, error) => const Icon(
              Icons.broken_image_outlined,
              color: Colors.white54,
              size: 64,
            ),
            fit: BoxFit.contain,
            // No headers — AWS pre-signed URL has auth in query params
          ),
        ),
      ),
    );
  }
}
