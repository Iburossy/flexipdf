import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/permission_helper.dart';
import '../../../domain/entities/compression_options.dart';
import '../../../domain/repositories/storage_repository.dart';
import '../../bloc/pdf/pdf_bloc.dart';
import '../../bloc/pdf/pdf_event.dart';
import '../../bloc/pdf/pdf_state.dart';
import '../../widgets/loading_overlay.dart';
import '../viewer/viewer_screen.dart';

/// Screen for compressing PDF files
class CompressScreen extends StatelessWidget {
  const CompressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PdfBloc>(),
      child: const CompressScreenBody(),
    );
  }
}

class CompressScreenBody extends StatefulWidget {
  const CompressScreenBody({super.key});

  @override
  State<CompressScreenBody> createState() => _CompressScreenBodyState();
}

class _CompressScreenBodyState extends State<CompressScreenBody> {
  String? _selectedFile;
  CompressionLevel _compressionLevel = CompressionLevel.medium;
  int? _originalSize;
  int? _estimatedSize;

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _pickFile() async {
    final hasPermission = await PermissionHelper.requestStoragePermission();
    if (!hasPermission) {
      if (mounted) {
        context.showErrorSnackBar('Storage permission required');
      }
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      setState(() {
        _selectedFile = file.path;
        _originalSize = file.size;
        _estimateCompressedSize();
      });
    }
  }

  void _estimateCompressedSize() {
    if (_originalSize == null) return;

    // Estimation basée sur le niveau de compression
    double compressionRatio;
    switch (_compressionLevel) {
      case CompressionLevel.low:
        compressionRatio = 0.8; // 20% reduction
        break;
      case CompressionLevel.medium:
        compressionRatio = 0.6; // 40% reduction
        break;
      case CompressionLevel.high:
        compressionRatio = 0.4; // 60% reduction
        break;
    }

    setState(() {
      _estimatedSize = (_originalSize! * compressionRatio).toInt();
    });
  }

  Future<void> _compressPdf(BuildContext context) async {
    if (_selectedFile == null) {
      context.showErrorSnackBar('Please select a PDF file');
      return;
    }

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storageRepository = getIt<StorageRepository>();
      final downloadResult = await storageRepository.getDownloadDirectory();

      final basePath = downloadResult.fold<String?>(
        onSuccess: (path) => path,
        onFailure: (failure) {
          if (context.mounted) {
            context.showErrorSnackBar(
              'Failed to access downloads: ${failure.message}',
            );
          }
          return null;
        },
      );

      if (basePath == null) {
        return;
      }

      final outputPath = '$basePath/compressed_$timestamp.pdf';

      context.read<PdfBloc>().add(
            CompressPdf(
              filePath: _selectedFile!,
              outputPath: outputPath,
              options: CompressionOptions(
                level: _compressionLevel,
                optimizeImages: true,
                imageQuality: _compressionLevel == CompressionLevel.high ? 50 : 75,
                removeMetadata: false,
              ),
            ),
          );
    } catch (e) {
      if (context.mounted) {
        context.showErrorSnackBar('Error: $e');
      }
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.compress),
      ),
      body: BlocConsumer<PdfBloc, PdfState>(
        listener: (context, state) {
          if (state is PdfOperationSuccess) {
            final document = state.document;
            final documentPath = document?.path;
            final originalSize = _originalSize;
            final compressedSize = document?.sizeInBytes;

            String message = state.message;
            if (originalSize != null && compressedSize != null) {
              final reduction =
                  ((originalSize - compressedSize) / originalSize * 100)
                      .toStringAsFixed(1);
              message += '\nReduced by $reduction%';
              message +=
                  '\n${_formatBytes(originalSize)} → ${_formatBytes(compressedSize)}';
            }
            if (documentPath != null) {
              message += '\nSaved in: $documentPath';
            }

            setState(() {
              _selectedFile = null;
              _originalSize = null;
              _estimatedSize = null;
            });

            if (document != null && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  action: SnackBarAction(
                    label: 'View',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ViewerScreen(
                            filePath: document.path,
                            fileName: document.name,
                          ),
                        ),
                      );
                    },
                  ),
                  duration: const Duration(seconds: 5),
                ),
              );
            }
          } else if (state is PdfError) {
            context.showErrorSnackBar(state.message);
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Info card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: context.colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Reduce PDF file size while maintaining quality',
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: context.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // File selection
                    if (_selectedFile == null)
                      _buildFileSelector(context)
                    else
                      _buildSelectedFile(context),

                    const SizedBox(height: 24),

                    // Compression level
                    if (_selectedFile != null) ...[
                      Text(
                        'Compression Level',
                        style: context.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      _buildCompressionLevelSelector(context),
                      const SizedBox(height: 24),

                      // Size comparison
                      if (_originalSize != null && _estimatedSize != null)
                        _buildSizeComparison(context),

                      const SizedBox(height: 24),

                      // Compress button
                      ElevatedButton.icon(
                        onPressed: state is! PdfLoading
                            ? () => _compressPdf(context)
                            : null,
                        icon: const Icon(Icons.compress),
                        label: const Text('Compress PDF'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              if (state is PdfLoading)
                LoadingOverlay(
                  message: state.message ?? 'Compressing...',
                  progress: state.progress,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFileSelector(BuildContext context) {
    return InkWell(
      onTap: _pickFile,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          border: Border.all(
            color: context.colorScheme.outline,
            width: 2,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              Icons.upload_file,
              size: 64,
              color: context.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Select PDF file',
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap to browse',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedFile(BuildContext context) {
    final fileName = _selectedFile!.split('/').last;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.picture_as_pdf,
              size: 48,
              color: context.colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    style: context.textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (_originalSize != null)
                    Text(
                      'Size: ${_formatBytes(_originalSize!)}',
                      style: context.textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _selectedFile = null;
                  _originalSize = null;
                  _estimatedSize = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompressionLevelSelector(BuildContext context) {
    return Column(
      children: [
        _buildCompressionOption(
          context,
          CompressionLevel.low,
          'Low',
          'Minimal compression, best quality',
          Icons.looks_one,
          Colors.green,
        ),
        const SizedBox(height: 8),
        _buildCompressionOption(
          context,
          CompressionLevel.medium,
          'Medium',
          'Balanced compression and quality',
          Icons.looks_two,
          Colors.orange,
        ),
        const SizedBox(height: 8),
        _buildCompressionOption(
          context,
          CompressionLevel.high,
          'High',
          'Maximum compression, reduced quality',
          Icons.looks_3,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildCompressionOption(
    BuildContext context,
    CompressionLevel level,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    final isSelected = _compressionLevel == level;

    return InkWell(
      onTap: () {
        setState(() {
          _compressionLevel = level;
          _estimateCompressedSize();
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? color : context.colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  Text(
                    description,
                    style: context.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeComparison(BuildContext context) {
    final reduction =
        ((_originalSize! - _estimatedSize!) / _originalSize! * 100)
            .toStringAsFixed(0);

    return Card(
      color: context.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Estimated Size Reduction',
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSizeInfo(
                  context,
                  'Original',
                  _formatBytes(_originalSize!),
                  Icons.file_present,
                ),
                Icon(
                  Icons.arrow_forward,
                  color: context.colorScheme.onSecondaryContainer,
                ),
                _buildSizeInfo(
                  context,
                  'Compressed',
                  _formatBytes(_estimatedSize!),
                  Icons.compress,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '~$reduction% smaller',
                style: context.textTheme.titleMedium?.copyWith(
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeInfo(
    BuildContext context,
    String label,
    String size,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
          color: context.colorScheme.onSecondaryContainer,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: context.textTheme.bodySmall,
        ),
        Text(
          size,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
