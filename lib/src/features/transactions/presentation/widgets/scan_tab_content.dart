import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/styles/app_styles.dart';
import '../controllers/invoice_controller.dart';

class ScanTabContent extends ConsumerStatefulWidget {
  const ScanTabContent({Key? key}) : super(key: key);

  @override
  ConsumerState<ScanTabContent> createState() => _ScanTabContentState();
}

class _ScanTabContentState extends ConsumerState<ScanTabContent>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isPermissionDenied = false;
  File? _scannedImage;
  bool _isProcessing = false;
  final FlutterDocScanner _docScanner = FlutterDocScanner();

  // Tracking scanning folder size and last cleanup time
  DateTime _lastCacheCleanup = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  // Función para determinar la resolución óptima basada en las características del dispositivo
  Future<ResolutionPreset> _getOptimalResolutionPreset() async {
    // Verificamos el espacio disponible para determinar si podemos usar resoluciones altas
    final directory = await getTemporaryDirectory();
    final stat = await directory.stat();
    final freeSpace = stat.size; // Esto es una aproximación

    // Si el dispositivo tiene menos de 100MB libres, usar resolución media
    if (freeSpace < 100 * 1024 * 1024) {
      developer.log('Espacio limitado, usando resolución media',
          name: 'scan_tab_content');
      return ResolutionPreset.medium;
    }

    // También podríamos verificar la memoria RAM disponible, pero eso requiere plugins adicionales

    // Por ahora usamos high como un buen balance entre calidad y rendimiento
    // En lugar de max que podría ser problemático en dispositivos de gama baja
    return ResolutionPreset.high;
  }

  // Limpiar archivos temporales de escaneo más antiguos que una semana
  Future<void> _cleanupScanCache() async {
    // No ejecutar limpieza si ya se hizo en las últimas 24 horas
    if (DateTime.now().difference(_lastCacheCleanup).inHours < 24) {
      return;
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final scanDir = Directory('${tempDir.path}/scan_cache');

      if (!await scanDir.exists()) {
        await scanDir.create(recursive: true);
        _lastCacheCleanup = DateTime.now();
        return;
      }

      // Obtener todos los archivos en el directorio
      final entities = await scanDir.list().toList();
      int filesDeleted = 0;
      int bytesFreed = 0;

      for (var entity in entities) {
        if (entity is File) {
          final stat = await entity.stat();
          // Eliminar archivos más antiguos de 7 días
          if (DateTime.now().difference(stat.modified).inDays > 7) {
            bytesFreed += stat.size;
            await entity.delete();
            filesDeleted++;
          }
        }
      }

      developer.log(
          'Limpieza de caché completada: $filesDeleted archivos eliminados, ${(bytesFreed / 1024 / 1024).toStringAsFixed(2)}MB liberados',
          name: 'scan_tab_content');

      _lastCacheCleanup = DateTime.now();
    } catch (e) {
      developer.log('Error al limpiar caché: $e',
          name: 'scan_tab_content', error: e);
    }
  }

  // Guardar imagen en un directorio específico para escaneos
  Future<String> _saveImageToScanCache(File imageFile) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final scanDir = Directory('${tempDir.path}/scan_cache');

      if (!await scanDir.exists()) {
        await scanDir.create(recursive: true);
      }

      final targetPath =
          '${scanDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final targetFile = await imageFile.copy(targetPath);
      return targetFile.path;
    } catch (e) {
      developer.log('Error al guardar imagen en caché: $e',
          name: 'scan_tab_content', error: e);
      return imageFile.path; // Devolver la ruta original si falla
    }
  }

  Future<void> _initializeCamera() async {
    final status = await Permission.camera.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      setState(() {
        _isPermissionDenied = true;
      });
      return;
    }

    try {
      _cameras = await availableCameras();

      if (_cameras == null || _cameras!.isEmpty) {
        developer.log('No cameras available', name: 'scan_tab_content');
        return;
      }

      final CameraDescription camera = _cameras!.first;

      // Usar resolución adaptativa en lugar de siempre la máxima
      final resolution = await _getOptimalResolutionPreset();
      developer.log('Usando resolución: $resolution', name: 'scan_tab_content');

      _controller = CameraController(
        camera,
        resolution,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      await _controller!.setFlashMode(FlashMode.auto);

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }

      // Ejecutar limpieza de caché al iniciar
      _cleanupScanCache();
    } catch (e) {
      developer.log('Error initializing camera: $e',
          name: 'scan_tab_content', error: e);
    }
  }

  Future<void> _scanDocument() async {
    developer.log('_scanDocument method started', name: 'scan_tab_content');
    if (_isProcessing) {
      developer.log('_scanDocument aborted: already processing',
          name: 'scan_tab_content');
      return;
    }

    setState(() {
      _isProcessing = true;
    });
    developer.log('_isProcessing set to true', name: 'scan_tab_content');

// Añadir un timeout para evitar quedarse en estado de carga indefinidamente
    developer.log('Setting up timeout timer', name: 'scan_tab_content');
    Timer timeout = Timer(const Duration(seconds: 20), () async {
      developer.log('Timeout timer triggered after 20 seconds',
          name: 'scan_tab_content');
      if (_isProcessing && mounted) {
        developer.log('Timeout ocurred, falling back to manual capture',
            name: 'scan_tab_content');

        // Informar al usuario
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'El escáner está tardando demasiado. Usando captura manual.'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        // Ejecutar captura manual como fallback
        await _captureManualImage();
      }
    });

    try {
      developer.log('Attempting to scan document with _docScanner',
          name: 'scan_tab_content');
      // Use the document scanner directly - this will open the native scanner UI
      // which handles edge detection and automatic capture
      List<String>? scannedDocuments;
      try {
        developer.log('Calling getScannedDocumentAsImages()',
            name: 'scan_tab_content');
        scannedDocuments = await _docScanner.getScannedDocumentAsImages();
        developer.log(
            'getScannedDocumentAsImages() completed. Results: ${scannedDocuments?.length ?? 0} documents',
            name: 'scan_tab_content');
      } on PlatformException catch (e) {
        developer.log(
            'Platform exception in document scanning: ${e.code}, ${e.message}',
            name: 'scan_tab_content',
            error: e);

        // Utilizar el método de captura manual
        await _captureManualImage();

        // Cancelar el timeout después de la captura manual
        timeout.cancel();
        developer.log('Timeout timer cancelled', name: 'scan_tab_content');
        return;
      }

      // Check if we got any scanned documents
      developer.log('Checking scanned documents results',
          name: 'scan_tab_content');
      if (scannedDocuments != null && scannedDocuments.isNotEmpty) {
        developer.log(
            'Setting _scannedImage from scanner: ${scannedDocuments.first}',
            name: 'scan_tab_content');

        // Copiar la imagen a nuestra carpeta de caché para mejor gestión
        final savedPath =
            await _saveImageToScanCache(File(scannedDocuments.first));

        setState(() {
          _scannedImage = File(savedPath);
          _isProcessing = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Documento escaneado correctamente'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        developer.log('No documents returned from scanner',
            name: 'scan_tab_content');
        setState(() {
          _isProcessing = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Escaneo cancelado o no se detectó documento'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      developer.log('Unhandled error scanning document: $e',
          name: 'scan_tab_content', error: e);
      setState(() {
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al escanear el documento. Intenta de nuevo.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      timeout.cancel();
      developer.log('Timeout timer cancelled in finally block',
          name: 'scan_tab_content');
      developer.log('_scanDocument method completed', name: 'scan_tab_content');
    }
  }

  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      // Limitar el tamaño máximo de la imagen seleccionada
      maxWidth: 1200,
      maxHeight: 1600,
    );

    if (image != null) {
      setState(() {
        _isProcessing = true;
      });

      try {
        // Guardar en nuestro directorio de caché
        final savedPath = await _saveImageToScanCache(File(image.path));

        setState(() {
          _scannedImage = File(savedPath);
          _isProcessing = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Imagen seleccionada correctamente'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        developer.log('Error processing gallery image: $e',
            name: 'scan_tab_content', error: e);
        setState(() {
          _isProcessing = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al procesar la imagen. Intenta de nuevo.'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _captureManualImage() async {
    developer.log('Falling back to manual camera capture',
        name: 'scan_tab_content');

    final XFile? rawImage = await _controller?.takePicture();
    developer.log(
        'takePicture() completed. Result: ${rawImage != null ? 'success' : 'null'}',
        name: 'scan_tab_content');

    if (rawImage != null) {
      // Guardar en nuestro directorio de caché
      final savedPath = await _saveImageToScanCache(File(rawImage.path));

      developer.log('Setting _scannedImage from camera capture: $savedPath',
          name: 'scan_tab_content');
      setState(() {
        _scannedImage = File(savedPath);
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Imagen capturada correctamente'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      developer.log('Camera capture returned null image',
          name: 'scan_tab_content');
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      setState(() {
        _isPermissionDenied = false;
      });
      await _initializeCamera();
    } else {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Permiso de cámara requerido'),
            content: const Text(
                'Para escanear tickets necesitamos acceso a la cámara. Por favor, habilita el permiso en la configuración de la aplicación.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: const Text('Abrir Configuración'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isPermissionDenied) {
      return _buildPermissionDeniedUI();
    }

    if (_scannedImage != null) {
      return _buildScannedImagePreview();
    }

    if (!_isCameraInitialized || _controller == null) {
      return _buildLoadingUI();
    }

    return _buildCameraUI();
  }

  Widget _buildPermissionDeniedUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.no_photography,
          size: 64.0,
          color: Colors.grey,
        ),
        const SizedBox(height: 16.0),
        const Text(
          'Se requiere acceso a la cámara para escanear tickets',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16.0),
        ),
        const SizedBox(height: 24.0),
        ElevatedButton(
          onPressed: _requestCameraPermission,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppStyles.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text('Permitir acceso a la cámara'),
        ),
        const SizedBox(height: 16.0),
        TextButton(
          onPressed: _pickImageFromGallery,
          child: const Text('Seleccionar desde la galería'),
        ),
      ],
    );
  }

  Widget _buildLoadingUI() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16.0),
          Text('Inicializando cámara...'),
        ],
      ),
    );
  }

  Widget _buildCameraUI() {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CameraPreview(_controller!),
                  Center(
                    child: Container(
                      width: 280,
                      height: 450, // Taller frame for receipts
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppStyles.primaryColor,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16.0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: const Text(
                          'Posiciona el ticket dentro del marco',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 16.0,
          ),
          child: Text(
            'Posiciona el ticket o factura con buena iluminación para mejores resultados. '
            'Nuestra IA extraerá y categorizará los detalles automáticamente.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14.0,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 32.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Material(
                elevation: 2.0,
                shape: const CircleBorder(),
                color: Colors.white,
                child: InkWell(
                  onTap: _pickImageFromGallery,
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 56.0,
                    height: 56.0,
                    padding: const EdgeInsets.all(16.0),
                    child: Icon(
                      Icons.photo_library,
                      size: 24.0,
                      color: AppStyles.primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24.0),
              Material(
                elevation: 4.0,
                shape: const CircleBorder(),
                color: _isProcessing ? Colors.grey : AppStyles.primaryColor,
                child: InkWell(
                  onTap: _isProcessing ? null : _scanDocument,
                  customBorder: const CircleBorder(),
                  child: SizedBox(
                    width: 72.0,
                    height: 72.0,
                    child: _isProcessing
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3.0,
                          )
                        : const Icon(
                            Icons.camera_alt,
                            size: 32.0,
                            color: Colors.white,
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 24.0),
              Material(
                elevation: 2.0,
                shape: const CircleBorder(),
                color: Colors.white,
                child: InkWell(
                  onTap: () async {
                    if (_controller!.value.flashMode == FlashMode.off) {
                      await _controller!.setFlashMode(FlashMode.torch);
                    } else {
                      await _controller!.setFlashMode(FlashMode.off);
                    }
                    setState(() {});
                  },
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 56.0,
                    height: 56.0,
                    padding: const EdgeInsets.all(16.0),
                    child: Icon(
                      _controller!.value.flashMode == FlashMode.torch
                          ? Icons.flash_on
                          : Icons.flash_off,
                      size: 24.0,
                      color: AppStyles.primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24.0),
              // Nuevo botón para cambiar entre cámaras
              Material(
                elevation: 2.0,
                shape: const CircleBorder(),
                color: Colors.white,
                child: InkWell(
                  onTap: () async {
                    if (_cameras != null && _cameras!.length > 1) {
                      int currentCameraIndex =
                          _cameras!.indexOf(_controller!.description);
                      int newCameraIndex =
                          (currentCameraIndex + 1) % _cameras!.length;

                      setState(() {
                        _isCameraInitialized = false;
                      });

                      await _controller?.dispose();

                      _controller = CameraController(
                        _cameras![newCameraIndex],
                        ResolutionPreset.max,
                        enableAudio: false,
                        imageFormatGroup: ImageFormatGroup.jpeg,
                      );

                      await _controller!.initialize();
                      await _controller!.setFlashMode(FlashMode.auto);

                      setState(() {
                        _isCameraInitialized = true;
                      });
                    }
                  },
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 56.0,
                    height: 56.0,
                    padding: const EdgeInsets.all(16.0),
                    child: Icon(
                      Icons.flip_camera_ios,
                      size: 24.0,
                      color: AppStyles.primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScannedImagePreview() {
    final invoiceState = ref.watch(invoiceControllerProvider);
    final bool isUploading = invoiceState == InvoiceUploadState.uploading;

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.file(
                _scannedImage!,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: isUploading
                    ? null
                    : () {
                        setState(() {
                          _scannedImage = null;
                        });
                      },
                icon: const Icon(Icons.refresh),
                label: const Text('Volver a escanear'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              ElevatedButton.icon(
                onPressed: isUploading
                    ? null
                    : () async {
                        if (_scannedImage == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('No hay imagen para procesar')),
                          );
                          return;
                        }

                        // Call invoice controller to upload the image
                        final success = await ref
                            .read(invoiceControllerProvider.notifier)
                            .uploadInvoice(invoiceFile: _scannedImage!);

                        if (success) {
                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Imagen procesada con éxito'),
                              backgroundColor: Colors.green,
                            ),
                          );

                          // Navigate back to dashboard
                          context.go('/dashboard');
                        } else {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Error al procesar la imagen'),
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
                    : const Icon(Icons.check),
                label: Text(isUploading ? 'Procesando...' : 'Continuar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
