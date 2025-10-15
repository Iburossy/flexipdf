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
import '../viewer/viewer_screen.dart';

/// Screen for merging multiple PDF files
class MergeScreen extends StatelessWidget {
  const MergeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PdfBloc>(),
      child: const MergeScreenBody(),
    );
  }
}

class MergeScreenBody extends StatefulWidget {
  const MergeScreenBody({super.key});

  @override
  State<MergeScreenBody> createState() => _MergeScreenBodyState();
}

class _MergeScreenBodyState extends State<MergeScreenBody> {
  final List<String> _selectedFiles = [];

  Future<void> _pickFiles() async {
    // Request storage permission first
    final hasPermission = await PermissionHelper.requestStoragePermission();
    if (!hasPermission) {
      if (mounted) {
        context.showErrorSnackBar(
          'Storage permission is required to select PDF files',
        );
      }
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFiles.addAll(
          result.files.map((file) => file.path!).where((path) => path.isNotEmpty),
        );
      });
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  void _reorderFiles(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _selectedFiles.removeAt(oldIndex);
      _selectedFiles.insert(newIndex, item);
    });
  }

  Future<void> _mergePdfs(BuildContext context) async {
    if (_selectedFiles.length < 2) {
      context.showErrorSnackBar('Please select at least 2 PDF files');
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

      final outputPath = '$basePath/merged_$timestamp.pdf';

      context.read<PdfBloc>().add(
            MergePdfs(
              filePaths: _selectedFiles,
              outputPath: outputPath,
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
        title: const Text(AppStrings.merge),
        actions: [
          if (_selectedFiles.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () {
                setState(() {
                  _selectedFiles.clear();
                });
              },
              tooltip: 'Clear all',
            ),
        ],
      ),
      body: BlocConsumer<PdfBloc, PdfState>(
        listener: (context, state) async {
          if (state is PdfOperationSuccess) {
            final document = state.document;
            final documentPath = document?.path;
            
            // Clear files after successful merge
            setState(() {
              _selectedFiles.clear();
            });
            
            // Show success with option to view
            if (document != null && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${state.message}\nSaved in: $documentPath',
                  ),
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
              Column(
                children: [
                  // Instructions
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
                            'Select PDF files to merge. Drag to reorder.',
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // File list
                  Expanded(
                    child: _selectedFiles.isEmpty
                        ? _buildEmptyState(context)
                        : _buildFileList(),
                  ),

                  // Action buttons
                  _buildActionButtons(context, state),
                ],
              ),

              // Loading overlay
              if (state is PdfLoading)
                LoadingOverlay(
                  message: state.message ?? 'Processing...',
                  progress: state.progress,
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickFiles,
        icon: const Icon(Icons.add),
        label: const Text('Add PDFs'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.picture_as_pdf_outlined,
            size: 80,
            color: context.colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No PDFs selected',
            style: context.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to add PDF files',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileList() {
    return ReorderableListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _selectedFiles.length,
      onReorder: _reorderFiles,
      itemBuilder: (context, index) {
        final filePath = _selectedFiles[index];
        final fileName = filePath.split('/').last;

        return Card(
          key: ValueKey(filePath),
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: context.colorScheme.primaryContainer,
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: context.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              filePath,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.drag_handle,
                  color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => _removeFile(index),
                  color: context.colorScheme.error,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context, PdfState state) {
    final canMerge = _selectedFiles.length >= 2 && state is! PdfLoading;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_selectedFiles.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  '${_selectedFiles.length} PDF${_selectedFiles.length > 1 ? 's' : ''} selected',
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: canMerge ? () => _mergePdfs(context) : null,
                icon: const Icon(Icons.merge),
                label: const Text('Merge PDFs'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
