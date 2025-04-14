import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/styles/app_styles.dart';

class ScanTabContent extends StatefulWidget {
  const ScanTabContent({Key? key}) : super(key: key);

  @override
  State<ScanTabContent> createState() => _ScanTabContentState();
}

class _ScanTabContentState extends State<ScanTabContent>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isPermissionDenied = false;
  File? _scannedImage;
  bool _isProcessing = false;
  final FlutterDocScanner _docScanner = FlutterDocScanner();

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

      _controller = CameraController(
        camera,
        ResolutionPreset.high,
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
        setState(() {
          _scannedImage = File(scannedDocuments!.first);
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
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _isProcessing = true;
      });

      try {
        // For gallery images, we'll directly use the selected image
        // instead of trying to use the document scanner again
        setState(() {
          _scannedImage = File(image.path);
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
      developer.log(
          'Setting _scannedImage from camera capture: ${rawImage.path}',
          name: 'scan_tab_content');
      setState(() {
        _scannedImage = File(rawImage.path);
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
                        ResolutionPreset.medium,
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
                onPressed: () {
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
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Procesando imagen...'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.check),
                label: const Text('Continuar'),
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
