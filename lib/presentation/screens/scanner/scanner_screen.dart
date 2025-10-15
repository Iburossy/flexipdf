import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/permission_helper.dart';
import '../../../domain/repositories/storage_repository.dart';
import '../../../domain/usecases/pdf/create_pdf_from_images_usecase.dart';

/// Screen for scanning documents and converting to PDF
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final List<String> _scannedImages = [];
  final ImagePicker _imagePicker = ImagePicker();
  bool _isProcessing = false;

  Future<void> _captureImage(ImageSource source) async {
    try {
      // Request appropriate permission
      bool hasPermission = false;
      if (source == ImageSource.camera) {
        hasPermission = await PermissionHelper.requestCameraPermission();
      } else {
        hasPermission = await PermissionHelper.requestPhotosPermission();
      }

      if (!hasPermission) {
        if (mounted) {
          context.showErrorSnackBar(
            'Permission required to access ${source == ImageSource.camera ? 'camera' : 'photos'}',
          );
        }
        return;
      }

      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 100,
      );

      if (image != null) {
        // Add image directly without cropping to avoid crashes
        // Cropping can be added later if needed
        if (mounted) {
          setState(() {
            _scannedImages.add(image.path);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Error capturing image: $e');
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _scannedImages.removeAt(index);
    });
  }

  void _reorderImages(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _scannedImages.removeAt(oldIndex);
      _scannedImages.insert(newIndex, item);
    });
  }

  Future<void> _createPdf() async {
    if (_scannedImages.isEmpty) {
      context.showErrorSnackBar('Please scan at least one document');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final storageRepository = getIt<StorageRepository>();
      final downloadResult = await storageRepository.getDownloadDirectory();

      final basePath = downloadResult.fold<String?>(
        onSuccess: (path) => path,
        onFailure: (failure) {
          if (mounted) {
            context.showErrorSnackBar(
              'Failed to access downloads: ${failure.message}',
            );
          }
          return null;
        },
      );

      if (basePath == null) {
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputPath = '$basePath/scanned_$timestamp.pdf';

      // Import use case
      final createPdfUseCase = getIt<CreatePdfFromImagesUseCase>();
      final result = await createPdfUseCase(
        CreatePdfFromImagesParams(
          imagePaths: _scannedImages,
          outputPath: outputPath,
        ),
      );

      setState(() {
        _isProcessing = false;
      });

      if (mounted) {
        result.fold(
          onSuccess: (document) {
            context.showSnackBar(
              'PDF created successfully\n'
              '${_scannedImages.length} pages\n'
              'Saved in: ${document.path}',
            );
            setState(() {
              _scannedImages.clear();
            });
          },
          onFailure: (failure) {
            context.showErrorSnackBar('Failed to create PDF: ${failure.message}');
          },
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      if (mounted) {
        context.showErrorSnackBar('Error creating PDF: $e');
      }
    }
  }

  void _showCaptureOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _captureImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _captureImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Scanner'),
        actions: [
          if (_scannedImages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () {
                setState(() {
                  _scannedImages.clear();
                });
              },
              tooltip: 'Clear all',
            ),
        ],
      ),
      body: _scannedImages.isEmpty ? _buildEmptyState() : _buildImageList(),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_scannedImages.isNotEmpty) ...[
            FloatingActionButton(
              onPressed: _isProcessing ? null : _createPdf,
              heroTag: 'create_pdf',
              child: _isProcessing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.picture_as_pdf),
            ),
            const SizedBox(height: 16),
          ],
          FloatingActionButton.extended(
            onPressed: _showCaptureOptions,
            heroTag: 'scan',
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Scan'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.document_scanner,
              size: 120,
              color: context.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No documents scanned',
              style: context.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Tap the scan button to capture documents\nwith your camera or choose from gallery',
              style: context.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageList() {
    return Column(
      children: [
        // Info banner
        Container(
          padding: const EdgeInsets.all(16),
          color: context.colorScheme.primaryContainer,
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: context.colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${_scannedImages.length} page(s) scanned. Long press to reorder.',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Image grid
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _scannedImages.length,
            onReorder: _reorderImages,
            itemBuilder: (context, index) {
              return _buildImageCard(index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildImageCard(int index) {
    return Card(
      key: ValueKey(_scannedImages[index]),
      margin: const EdgeInsets.only(bottom: 16),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image preview
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.file(
                  File(_scannedImages[index]),
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),

              // Page number
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Page ${index + 1}',
                      style: context.textTheme.titleMedium,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _removeImage(index),
                      color: context.colorScheme.error,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Drag handle
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.drag_handle,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
