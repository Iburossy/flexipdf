import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/extensions/context_extensions.dart';

/// Screen for viewing PDF documents
class ViewerScreen extends StatefulWidget {
  final String filePath;
  final String? fileName;

  const ViewerScreen({
    super.key,
    required this.filePath,
    this.fileName,
  });

  @override
  State<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends State<ViewerScreen> {
  late PdfController _pdfController;
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _initializePdf();
  }

  Future<void> _initializePdf() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      _pdfController = PdfController(
        document: PdfDocument.openFile(widget.filePath),
      );

      // Wait for document to load to get page count
      final document = await PdfDocument.openFile(widget.filePath);
      final pageCount = document.pagesCount;

      setState(() {
        _totalPages = pageCount;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load PDF: $e';
      });
    }
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    if (page >= 1 && page <= _totalPages) {
      _pdfController.jumpToPage(page);
      setState(() {
        _currentPage = page;
      });
    }
  }

  void _showPageSelector() {
    showDialog(
      context: context,
      builder: (context) {
        int selectedPage = _currentPage;
        return AlertDialog(
          title: const Text('Go to Page'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Page number (1-$_totalPages)',
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) {
                  selectedPage = int.tryParse(value) ?? _currentPage;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _goToPage(selectedPage);
              },
              child: const Text('Go'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName ?? 'PDF Viewer'),
        actions: [
          if (!_isLoading && _errorMessage == null) ...[
            IconButton(
              icon: const Icon(Icons.first_page),
              onPressed: () => _goToPage(1),
              tooltip: 'First page',
            ),
            IconButton(
              icon: const Icon(Icons.last_page),
              onPressed: () => _goToPage(_totalPages),
              tooltip: 'Last page',
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _showPageSelector,
              tooltip: 'Go to page',
            ),
          ],
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: !_isLoading && _errorMessage == null
          ? _buildBottomBar()
          : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading PDF...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: context.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _initializePdf,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return PdfView(
      controller: _pdfController,
      onPageChanged: (page) {
        setState(() {
          _currentPage = page;
        });
      },
      onDocumentLoaded: (document) {
        setState(() {
          _totalPages = document.pagesCount;
        });
      },
      scrollDirection: Axis.vertical,
      pageSnapping: true,
      physics: const BouncingScrollPhysics(),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous page button
          IconButton.filled(
            onPressed: _currentPage > 1 ? () => _goToPage(_currentPage - 1) : null,
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous page',
          ),

          // Page indicator
          InkWell(
            onTap: _showPageSelector,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: context.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Page $_currentPage / $_totalPages',
                style: context.textTheme.titleMedium?.copyWith(
                  color: context.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Next page button
          IconButton.filled(
            onPressed:
                _currentPage < _totalPages ? () => _goToPage(_currentPage + 1) : null,
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Next page',
          ),
        ],
      ),
    );
  }
}
