import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/permission_helper.dart';
import '../../../domain/repositories/storage_repository.dart';
import '../../bloc/pdf/pdf_bloc.dart';
import '../../bloc/pdf/pdf_event.dart';
import '../../bloc/pdf/pdf_state.dart';
import '../../widgets/loading_overlay.dart';

/// Screen for splitting PDF files
class SplitScreen extends StatelessWidget {
  const SplitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PdfBloc>(),
      child: const SplitScreenBody(),
    );
  }
}

class SplitScreenBody extends StatefulWidget {
  const SplitScreenBody({super.key});

  @override
  State<SplitScreenBody> createState() => _SplitScreenBodyState();
}

class _SplitScreenBodyState extends State<SplitScreenBody> {
  String? _selectedFile;
  int _pagesPerFile = 1;
  final _pagesController = TextEditingController(text: '1');

  @override
  void dispose() {
    _pagesController.dispose();
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
      setState(() {
        _selectedFile = result.files.first.path;
      });
    }
  }

  Future<void> _splitPdf(BuildContext context) async {
    if (_selectedFile == null) {
      context.showErrorSnackBar('Please select a PDF file');
      return;
    }

    if (_pagesPerFile < 1) {
      context.showErrorSnackBar('Pages per file must be at least 1');
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

      final outputDir = '$basePath/split_$timestamp';

      context.read<PdfBloc>().add(
            SplitPdf(
              filePath: _selectedFile!,
              outputDirectory: outputDir,
              pagesPerFile: _pagesPerFile,
            ),
          );
    } catch (e) {
      if (context.mounted) {
        context.showErrorSnackBar('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.split),
      ),
      body: BlocConsumer<PdfBloc, PdfState>(
        listener: (context, state) async {
          if (state is PdfDocumentsLoaded) {
            final storageRepository = getIt<StorageRepository>();
            final downloadResult = await storageRepository.getDownloadDirectory();
            final basePath = downloadResult.fold<String?>(
              onSuccess: (path) => path,
              onFailure: (_) => null,
            );
            final samplePath = state.documents.isNotEmpty
                ? state.documents.first.path
                : basePath;
            context.showSnackBar(
              [
                'PDF split into ${state.documents.length} files',
                if (samplePath != null) 'Saved in: $samplePath',
              ].join('\n'),
            );
            setState(() {
              _selectedFile = null;
            });
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
                              'Split a PDF into multiple files',
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

                    // Pages per file input
                    if (_selectedFile != null) ...[
                      Text(
                        'Pages per file',
                        style: context.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _pagesController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Enter number of pages',
                          prefixIcon: Icon(Icons.pages),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _pagesPerFile = int.tryParse(value) ?? 1;
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      // Split button
                      ElevatedButton.icon(
                        onPressed: state is! PdfLoading
                            ? () => _splitPdf(context)
                            : null,
                        icon: const Icon(Icons.call_split),
                        label: const Text('Split PDF'),
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
                  message: state.message ?? 'Processing...',
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
                  Text(
                    _selectedFile!,
                    style: context.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _selectedFile = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
