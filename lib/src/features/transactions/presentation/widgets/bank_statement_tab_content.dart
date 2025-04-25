import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/styles/app_styles.dart';
import '../controllers/bank_statement_controller.dart';

class BankStatementTabContent extends ConsumerStatefulWidget {
  const BankStatementTabContent({Key? key}) : super(key: key);

  @override
  ConsumerState<BankStatementTabContent> createState() =>
      _BankStatementTabContentState();
}

class _BankStatementTabContentState
    extends ConsumerState<BankStatementTabContent> {
  File? _selectedFile;
  String? _fileName;
  bool _isFileTypeValid = true;
  String? _errorMessage;

  /// Find the Downloads directory if available
  Future<String?> _findDownloadsDirectory() async {
    try {
      // First try the standard Downloads directory
      if (Platform.isAndroid) {
        // On Android, check for sdcard/Download directory
        final externalDir = '/storage/emulated/0/Download';
        final directory = Directory(externalDir);

        if (await directory.exists()) {
          developer.log('Found Downloads directory at: $externalDir',
              name: 'bank_statement_upload');
          return externalDir;
        }

        // Try alternative paths for different Android devices
        final alternatives = [
          '/sdcard/Download',
          '/storage/sdcard0/Download',
          '/storage/sdcard/Download'
        ];

        for (final path in alternatives) {
          final dir = Directory(path);
          if (await dir.exists()) {
            developer.log(
                'Found Downloads directory at alternative path: $path',
                name: 'bank_statement_upload');
            return path;
          }
        }
      } else if (Platform.isIOS) {
        // On iOS, use the application documents directory
        final directory = await getApplicationDocumentsDirectory();
        return directory.path;
      }
    } catch (e) {
      developer.log('Error finding Downloads directory: $e',
          name: 'bank_statement_upload', error: e);
    }
    return null;
  }

  Future<void> _pickFile() async {
    try {
      // Clear previous error state
      setState(() {
        _errorMessage = null;
        _isFileTypeValid = true;
      });

      developer.log('Opening file picker dialog',
          name: 'bank_statement_upload');

      // Try to find Downloads directory
      final downloadsPath = await _findDownloadsDirectory();

      // Open file picker with more options configured for v10.1.2
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'csv'],
        lockParentWindow:
            true, // Prevents dialog dismissal on tap outside (new in v10+)
        allowMultiple: false,
        withData: false, // Don't load file data in memory for large files
        withReadStream: true, // Use file streams for better memory management
        initialDirectory: downloadsPath, // Set initial directory if available
      );

      developer.log('File picker dialog closed', name: 'bank_statement_upload');

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // Log file information
        developer.log(
            'Selected file: ${file.name}, ${file.size} bytes, path: ${file.path}',
            name: 'bank_statement_upload');

        // More robust file type validation
        final lowerCaseName = file.name.toLowerCase();
        final validExtension =
            lowerCaseName.endsWith('.pdf') || lowerCaseName.endsWith('.csv');

        if (!validExtension) {
          setState(() {
            _isFileTypeValid = false;
            _errorMessage =
                'Tipo de archivo inválido. Solo se aceptan PDF y CSV.';
            _selectedFile = null;
            _fileName = null;
          });
          return;
        }

        // Check file size (optional - limit to e.g., 10MB)
        if (file.size > 10 * 1024 * 1024) {
          setState(() {
            _isFileTypeValid = false;
            _errorMessage = 'El archivo es demasiado grande. Límite: 10MB.';
            _selectedFile = null;
            _fileName = null;
          });
          return;
        }

        // Set selected file - handle potential null path more gracefully
        if (file.path != null) {
          setState(() {
            _selectedFile = File(file.path!);
            _fileName = file.name;
          });
        } else {
          setState(() {
            _isFileTypeValid = false;
            _errorMessage = 'No se pudo acceder al archivo seleccionado.';
          });
        }
      } else {
        // User canceled selection - this is not an error
        developer.log('File selection canceled by user',
            name: 'bank_statement_upload');
      }
    } catch (e) {
      developer.log('Error picking file: $e',
          name: 'bank_statement_upload', error: e);
      setState(() {
        _errorMessage = 'Error al seleccionar el archivo: $e';
      });
    }
  }

  // Add this method to clear file selection
  void _clearSelectedFile() {
    setState(() {
      _selectedFile = null;
      _fileName = null;
      _errorMessage = null;
      _isFileTypeValid = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(bankStatementControllerProvider);
    final bool isUploading = uploadState == BankStatementUploadState.uploading;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),

          // Title and description
          const Text(
            'Extracto Bancario',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Sube un extracto bancario en formato PDF o CSV para importar múltiples transacciones de una vez.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),

          // File selection area
          if (_selectedFile == null)
            InkWell(
              onTap: !isUploading ? _pickFile : null,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _isFileTypeValid ? Colors.grey.shade300 : Colors.red,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.upload_file,
                      size: 60,
                      color: _isFileTypeValid
                          ? AppStyles.primaryColor
                          : Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Toca para seleccionar un archivo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _isFileTypeValid ? Colors.black87 : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Formatos soportados: PDF, CSV',
                      style: TextStyle(
                        fontSize: 14,
                        color: _isFileTypeValid
                            ? Colors.grey
                            : Colors.red.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _fileName?.toLowerCase().endsWith('.pdf') == true
                            ? Icons.picture_as_pdf
                            : Icons.table_chart,
                        color: AppStyles.primaryColor,
                        size: 40,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _fileName ?? 'Archivo seleccionado',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${(_selectedFile!.lengthSync() / 1024).toStringAsFixed(1)} KB',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: !isUploading
                            ? () {
                                setState(() {
                                  _selectedFile = null;
                                  _fileName = null;
                                });
                              }
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Error message
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            ),

          const Spacer(),

          // Bottom action buttons
          if (_selectedFile != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ElevatedButton.icon(
                onPressed: isUploading
                    ? null
                    : () async {
                        if (_selectedFile == null) return;

                        final success = await ref
                            .read(bankStatementControllerProvider.notifier)
                            .uploadBankStatement(
                              bankStatementFile: _selectedFile!,
                            );

                        if (success) {
                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Extracto bancario procesado exitosamente'),
                              backgroundColor: Colors.green,
                            ),
                          );

                          // Navigate back to dashboard
                          context.go('/dashboard');
                        } else {
                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Error al procesar el extracto bancario'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                icon: isUploading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.cloud_upload),
                label: Text(
                  isUploading ? 'Procesando...' : 'Subir extracto bancario',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyles.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),

          // Bottom instructions
          if (_selectedFile == null)
            const Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: Text(
                'El sistema analizará automáticamente tu extracto bancario e importará las transacciones que encuentre.',
                style: TextStyle(color: Colors.grey, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
