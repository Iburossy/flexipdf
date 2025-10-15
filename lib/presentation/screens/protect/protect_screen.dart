import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/permission_helper.dart';
import '../../../domain/repositories/storage_repository.dart';
import '../../../domain/usecases/pdf/protect_pdf_usecase.dart';
import '../../widgets/loading_overlay.dart';

class ProtectScreen extends StatefulWidget {
  const ProtectScreen({super.key});

  @override
  State<ProtectScreen> createState() => _ProtectScreenState();
}

class _ProtectScreenState extends State<ProtectScreen> {
  String? _selectedFile;
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isProcessing = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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

  Future<void> _protectPdf() async {
    if (_selectedFile == null) {
      context.showErrorSnackBar('Please select a PDF file');
      return;
    }

    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password.isEmpty) {
      context.showErrorSnackBar('Please enter a password');
      return;
    }

    if (password.length < 6) {
      context.showErrorSnackBar('Password must be at least 6 characters');
      return;
    }

    if (password != confirmPassword) {
      context.showErrorSnackBar('Passwords do not match');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final storageRepository = getIt<StorageRepository>();
      final downloadResult = await storageRepository.getDownloadDirectory();

      final basePath = downloadResult.fold<String?>(
        onSuccess: (path) => path,
        onFailure: (failure) {
          if (mounted) {
            context.showErrorSnackBar('Failed to access downloads: ${failure.message}');
          }
          return null;
        },
      );

      if (basePath == null) {
        setState(() => _isProcessing = false);
        return;
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputPath = '$basePath/protected_$timestamp.pdf';

      final protectUseCase = getIt<ProtectPdfUseCase>();
      final result = await protectUseCase(
        ProtectPdfParams(
          filePath: _selectedFile!,
          outputPath: outputPath,
          password: password,
        ),
      );

      setState(() => _isProcessing = false);

      if (mounted) {
        result.fold(
          onSuccess: (document) {
            context.showSnackBar(
              'PDF protected successfully\nSaved in: ${document.path}',
            );
            setState(() {
              _selectedFile = null;
              _passwordController.clear();
              _confirmPasswordController.clear();
            });
          },
          onFailure: (failure) {
            context.showErrorSnackBar('Failed to protect PDF: ${failure.message}');
          },
        );
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        context.showErrorSnackBar('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Protect PDF'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lock, color: context.colorScheme.onPrimaryContainer),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Protect your PDF with a password',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                if (_selectedFile == null)
                  _buildFileSelector()
                else
                  _buildSelectedFile(),

                const SizedBox(height: 24),

                if (_selectedFile != null) ...[
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter password (min 6 characters)',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirm,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      hintText: 'Re-enter password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirm ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _protectPdf,
                    icon: const Icon(Icons.shield),
                    label: const Text('Protect PDF'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_isProcessing)
            const LoadingOverlay(message: 'Protecting PDF...'),
        ],
      ),
    );
  }

  Widget _buildFileSelector() {
    return InkWell(
      onTap: _pickFile,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          border: Border.all(color: context.colorScheme.outline, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(Icons.upload_file, size: 64, color: context.colorScheme.primary),
            const SizedBox(height: 16),
            Text('Select PDF file', style: context.textTheme.titleMedium),
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

  Widget _buildSelectedFile() {
    final fileName = _selectedFile!.split('/').last;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.picture_as_pdf, size: 48, color: context.colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(fileName, style: context.textTheme.titleMedium, maxLines: 2),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _selectedFile = null),
            ),
          ],
        ),
      ),
    );
  }
}
