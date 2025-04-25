import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/styles/app_styles.dart';
import '../controllers/bank_statement_controller.dart';

class ExtractTabContent extends ConsumerStatefulWidget {
  const ExtractTabContent({Key? key}) : super(key: key);

  @override
  ConsumerState<ExtractTabContent> createState() => _ExtractTabContentState();
}

class _ExtractTabContentState extends ConsumerState<ExtractTabContent> {
  File? _selectedFile;
  String? _fileName;
  bool _isUploading = false;

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
      developer.log('Opening file picker from ExtractTabContent',
          name: 'bank_statement_upload');

      // Try to find Downloads directory
      final downloadsPath = await _findDownloadsDirectory();

      // Use file_picker v10.1.2 with appropriate options
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'csv', 'xls', 'xlsx'],
        lockParentWindow: true,
        withData: false,
        withReadStream: true,
        initialDirectory: downloadsPath, // Set initial directory if available
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        if (file.path != null) {
          setState(() {
            _selectedFile = File(file.path!);
            _fileName = file.name;
          });

          // Optionally show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Archivo seleccionado correctamente'),
                backgroundColor: Colors.green,
              ),
            );
          }

          // Optionally proceed with upload
          // await _uploadFile();
        }
      }
    } catch (e) {
      developer.log('Error picking file: $e',
          name: 'bank_statement_upload', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar archivo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Explanatory text
          Text(
            'Aquí puedes subir tu extracto bancario del mes y tus gastos e ingresos serán registrados automáticamente y categorizados por nuestros agentes de IA.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'En breve podrás ver tus transacciones en la aplicación.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 13.0,
            ),
          ),

          // Upload area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: InkWell(
                onTap: _pickFile, // Use the implemented file picker
                borderRadius: BorderRadius.circular(12.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: Colors.grey.shade200,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.upload_file,
                        size: 48.0,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        'Toca para subir tu extracto',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'PDF o Excel',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13.0,
                        ),
                      ),

                      // Show selected file name if any
                      if (_fileName != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            'Seleccionado: $_fileName',
                            style: TextStyle(
                              color: AppStyles.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Add upload button when file is selected
          if (_selectedFile != null)
            ElevatedButton.icon(
              onPressed: _isUploading
                  ? null
                  : () async {
                      // Implement upload functionality
                      setState(() {
                        _isUploading = true;
                      });

                      try {
                        final success = await ref
                            .read(bankStatementControllerProvider.notifier)
                            .uploadBankStatement(
                              bankStatementFile: _selectedFile!,
                            );

                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Extracto procesado exitosamente'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isUploading = false;
                          });
                        }
                      }
                    },
              icon: _isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.upload),
              label: Text(_isUploading ? 'Procesando...' : 'Procesar extracto'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyles.primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              ),
            ),
        ],
      ),
    );
  }
}
