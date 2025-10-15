import 'dart:io';
import 'dart:ui';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;
import 'package:uuid/uuid.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/compression_options.dart';
import '../../domain/entities/pdf_document.dart';
import '../../domain/entities/pdf_page.dart';
import '../models/pdf_document_model.dart';
import '../models/pdf_page_model.dart';
import 'pdf_local_datasource.dart';

/// Implementation of PDF local data source using Syncfusion
class PdfLocalDataSourceImpl implements PdfLocalDataSource {
  final Logger _logger = Logger('PdfLocalDataSourceImpl');
  final Uuid _uuid = const Uuid();

  @override
  Future<PdfDocument> loadDocument(String filePath) async {
    try {
      _logger.info('Loading PDF document: $filePath');
      
      final file = File(filePath);
      if (!await file.exists()) {
        throw FileException(message: 'File not found: $filePath');
      }

      final bytes = await file.readAsBytes();
      final pdfDoc = sf.PdfDocument(inputBytes: bytes);
      
      final pageCount = pdfDoc.pages.count;
      final isEncrypted = pdfDoc.security.userPassword.isNotEmpty;
      
      // Extract metadata
      final metadata = _extractMetadata(pdfDoc);
      
      pdfDoc.dispose();

      return await PdfDocumentModel.fromFile(
        id: _uuid.v4(),
        file: file,
        pageCount: pageCount,
        isEncrypted: isEncrypted,
        metadata: metadata,
      );
    } catch (e) {
      _logger.error('Error loading document', e);
      if (e is FileException) rethrow;
      throw PdfProcessingException(message: 'Failed to load PDF: $e');
    }
  }

  @override
  Future<List<PdfPage>> getPages(String filePath) async {
    try {
      _logger.info('Getting pages from: $filePath');
      
      final file = File(filePath);
      if (!await file.exists()) {
        throw FileException(message: 'File not found: $filePath');
      }

      final bytes = await file.readAsBytes();
      final pdfDoc = sf.PdfDocument(inputBytes: bytes);
      
      final pages = <PdfPage>[];
      for (int i = 0; i < pdfDoc.pages.count; i++) {
        final page = pdfDoc.pages[i];
        pages.add(PdfPageModel(
          pageNumber: i + 1,
          width: page.size.width,
          height: page.size.height,
          rotation: page.rotation.index * 90,
        ));
      }
      
      pdfDoc.dispose();
      return pages;
    } catch (e) {
      _logger.error('Error getting pages', e);
      if (e is FileException) rethrow;
      throw PdfProcessingException(message: 'Failed to get pages: $e');
    }
  }

  @override
  Future<PdfDocument> mergePdfs({
    required List<String> filePaths,
    required String outputPath,
    List<int>? pageRanges,
  }) async {
    try {
      _logger.info('Merging ${filePaths.length} PDFs');
      
      // Flutter PDF doesn't support direct import, so we merge by copying content
      final mergedDoc = sf.PdfDocument();
      
      for (final filePath in filePaths) {
        final file = File(filePath);
        if (!await file.exists()) {
          throw FileException(message: 'File not found: $filePath');
        }
        
        final bytes = await file.readAsBytes();
        final sourceDoc = sf.PdfDocument(inputBytes: bytes);
        
        // Copy each page content to merged document
        for (int i = 0; i < sourceDoc.pages.count; i++) {
          final sourcePage = sourceDoc.pages[i];
          final page = mergedDoc.pages.add();
          
          // Import page content using template
          final template = sourcePage.createTemplate();
          page.graphics.drawPdfTemplate(template, Offset.zero);
        }
        
        sourceDoc.dispose();
      }
      
      // Save merged document
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(await mergedDoc.save());
      mergedDoc.dispose();
      
      return await loadDocument(outputPath);
    } catch (e) {
      _logger.error('Error merging PDFs', e);
      if (e is FileException) rethrow;
      throw PdfProcessingException(message: 'Failed to merge PDFs: $e');
    }
  }

  @override
  Future<List<PdfDocument>> splitPdf({
    required String filePath,
    required String outputDirectory,
    List<int>? pageNumbers,
    int? pagesPerFile,
  }) async {
    try {
      _logger.info('Splitting PDF: $filePath');
      
      final file = File(filePath);
      if (!await file.exists()) {
        throw FileException(message: 'File not found: $filePath');
      }

      // Create output directory if it doesn't exist
      final outputDir = Directory(outputDirectory);
      if (!await outputDir.exists()) {
        await outputDir.create(recursive: true);
        _logger.info('Created output directory: $outputDirectory');
      }

      final bytes = await file.readAsBytes();
      final sourceDoc = sf.PdfDocument(inputBytes: bytes);
      final totalPages = sourceDoc.pages.count;
      
      final outputDocs = <PdfDocument>[];
      
      if (pageNumbers != null) {
        // Split by specific page numbers
        for (final pageNum in pageNumbers) {
          if (pageNum < 1 || pageNum > totalPages) continue;
          
          final newDoc = sf.PdfDocument();
          final sourcePage = sourceDoc.pages[pageNum - 1];
          final newPage = newDoc.pages.add();
          final template = sourcePage.createTemplate();
          newPage.graphics.drawPdfTemplate(template, Offset.zero);
          
          final outputPath = '$outputDirectory/page_$pageNum.pdf';
          await File(outputPath).writeAsBytes(await newDoc.save());
          newDoc.dispose();
          
          outputDocs.add(await loadDocument(outputPath));
        }
      } else if (pagesPerFile != null) {
        // Split by pages per file
        int fileIndex = 1;
        for (int i = 0; i < totalPages; i += pagesPerFile) {
          final newDoc = sf.PdfDocument();
          final endPage = (i + pagesPerFile > totalPages) ? totalPages : i + pagesPerFile;
          
          for (int j = i; j < endPage; j++) {
            final sourcePage = sourceDoc.pages[j];
            final newPage = newDoc.pages.add();
            final template = sourcePage.createTemplate();
            newPage.graphics.drawPdfTemplate(template, Offset.zero);
          }
          
          final outputPath = '$outputDirectory/split_$fileIndex.pdf';
          await File(outputPath).writeAsBytes(await newDoc.save());
          newDoc.dispose();
          
          outputDocs.add(await loadDocument(outputPath));
          fileIndex++;
        }
      }
      
      sourceDoc.dispose();
      return outputDocs;
    } catch (e) {
      _logger.error('Error splitting PDF', e);
      if (e is FileException) rethrow;
      throw PdfProcessingException(message: 'Failed to split PDF: $e');
    }
  }

  @override
  Future<PdfDocument> extractPages({
    required String filePath,
    required String outputPath,
    required List<int> pageNumbers,
  }) async {
    try {
      _logger.info('Extracting pages from: $filePath');
      
      final file = File(filePath);
      if (!await file.exists()) {
        throw FileException(message: 'File not found: $filePath');
      }

      final bytes = await file.readAsBytes();
      final sourceDoc = sf.PdfDocument(inputBytes: bytes);
      final newDoc = sf.PdfDocument();
      
      for (final pageNum in pageNumbers) {
        if (pageNum < 1 || pageNum > sourceDoc.pages.count) continue;
        final sourcePage = sourceDoc.pages[pageNum - 1];
        final newPage = newDoc.pages.add();
        final template = sourcePage.createTemplate();
        newPage.graphics.drawPdfTemplate(template, Offset.zero);
      }
      
      await File(outputPath).writeAsBytes(await newDoc.save());
      
      sourceDoc.dispose();
      newDoc.dispose();
      
      return await loadDocument(outputPath);
    } catch (e) {
      _logger.error('Error extracting pages', e);
      if (e is FileException) rethrow;
      throw PdfProcessingException(message: 'Failed to extract pages: $e');
    }
  }

  @override
  Future<PdfDocument> deletePages({
    required String filePath,
    required String outputPath,
    required List<int> pageNumbers,
  }) async {
    try {
      _logger.info('Deleting pages from: $filePath');
      
      final file = File(filePath);
      if (!await file.exists()) {
        throw FileException(message: 'File not found: $filePath');
      }

      final bytes = await file.readAsBytes();
      final sourceDoc = sf.PdfDocument(inputBytes: bytes);
      
      // Sort in descending order to avoid index issues
      final sortedPages = pageNumbers.toList()..sort((a, b) => b.compareTo(a));
      
      for (final pageNum in sortedPages) {
        if (pageNum < 1 || pageNum > sourceDoc.pages.count) continue;
        sourceDoc.pages.removeAt(pageNum - 1);
      }
      
      await File(outputPath).writeAsBytes(await sourceDoc.save());
      sourceDoc.dispose();
      
      return await loadDocument(outputPath);
    } catch (e) {
      _logger.error('Error deleting pages', e);
      if (e is FileException) rethrow;
      throw PdfProcessingException(message: 'Failed to delete pages: $e');
    }
  }

  @override
  Future<PdfDocument> rotatePages({
    required String filePath,
    required String outputPath,
    required Map<int, int> pageRotations,
  }) async {
    try {
      _logger.info('Rotating pages in: $filePath');
      
      final file = File(filePath);
      if (!await file.exists()) {
        throw FileException(message: 'File not found: $filePath');
      }

      final bytes = await file.readAsBytes();
      final pdfDoc = sf.PdfDocument(inputBytes: bytes);
      
      pageRotations.forEach((pageNum, rotation) {
        if (pageNum < 1 || pageNum > pdfDoc.pages.count) return;
        
        final page = pdfDoc.pages[pageNum - 1];
        page.rotation = _getRotationEnum(rotation);
      });
      
      await File(outputPath).writeAsBytes(await pdfDoc.save());
      pdfDoc.dispose();
      
      return await loadDocument(outputPath);
    } catch (e) {
      _logger.error('Error rotating pages', e);
      if (e is FileException) rethrow;
      throw PdfProcessingException(message: 'Failed to rotate pages: $e');
    }
  }

  @override
  Future<PdfDocument> compressPdf({
    required String filePath,
    required String outputPath,
    required CompressionOptions options,
  }) async {
    try {
      _logger.info('Compressing PDF: $filePath');
      
      final file = File(filePath);
      if (!await file.exists()) {
        throw FileException(message: 'File not found: $filePath');
      }

      final bytes = await file.readAsBytes();
      final pdfDoc = sf.PdfDocument(inputBytes: bytes);
      
      // Apply compression settings
      // Note: Syncfusion Flutter PDF has limited compression options
      // For advanced compression, consider using native platform code
      
      if (options.removeMetadata) {
        pdfDoc.documentInformation.title = '';
        pdfDoc.documentInformation.author = '';
        pdfDoc.documentInformation.subject = '';
        pdfDoc.documentInformation.keywords = '';
      }
      
      await File(outputPath).writeAsBytes(await pdfDoc.save());
      pdfDoc.dispose();
      
      return await loadDocument(outputPath);
    } catch (e) {
      _logger.error('Error compressing PDF', e);
      if (e is FileException) rethrow;
      throw PdfProcessingException(message: 'Failed to compress PDF: $e');
    }
  }

  @override
  Future<PdfDocument> protectPdf({
    required String filePath,
    required String outputPath,
    required String password,
    String? ownerPassword,
  }) async {
    try {
      _logger.info('Protecting PDF: $filePath');
      
      final file = File(filePath);
      if (!await file.exists()) {
        throw FileException(message: 'File not found: $filePath');
      }

      final bytes = await file.readAsBytes();
      final pdfDoc = sf.PdfDocument(inputBytes: bytes);
      
      pdfDoc.security.userPassword = password;
      pdfDoc.security.ownerPassword = ownerPassword ?? password;
      pdfDoc.security.algorithm = sf.PdfEncryptionAlgorithm.rc4x128Bit;
      
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(await pdfDoc.save());
      
      final stat = await outputFile.stat();
      final result = PdfDocumentModel(
        id: const Uuid().v4(),
        name: outputPath.split('/').last,
        path: outputPath,
        sizeInBytes: stat.size,
        pageCount: pdfDoc.pages.count,
        createdAt: stat.changed,
        modifiedAt: stat.modified,
        isEncrypted: true,
      );
      
      pdfDoc.dispose();
      return result;
    } catch (e) {
      _logger.error('Error protecting PDF', e);
      if (e is FileException) rethrow;
      throw CryptoException(message: 'Failed to protect PDF: $e');
    }
  }

  @override
  Future<PdfDocument> unlockPdf({
    required String filePath,
    required String outputPath,
    required String password,
  }) async {
    try {
      _logger.info('Unlocking PDF: $filePath');
      
      final file = File(filePath);
      if (!await file.exists()) {
        throw FileException(message: 'File not found: $filePath');
      }

      final bytes = await file.readAsBytes();
      final pdfDoc = sf.PdfDocument(inputBytes: bytes, password: password);
      
      // Remove security
      pdfDoc.security.userPassword = '';
      pdfDoc.security.ownerPassword = '';
      
      await File(outputPath).writeAsBytes(await pdfDoc.save());
      pdfDoc.dispose();
      
      return await loadDocument(outputPath);
    } catch (e) {
      _logger.error('Error unlocking PDF', e);
      if (e is FileException) rethrow;
      throw CryptoException(message: 'Failed to unlock PDF: $e');
    }
  }

  @override
  Future<PdfDocument> addWatermark({
    required String filePath,
    required String outputPath,
    required String watermarkText,
    double opacity = 0.5,
    List<int>? pageNumbers,
  }) async {
    try {
      _logger.info('Adding watermark to: $filePath');
      
      final file = File(filePath);
      if (!await file.exists()) {
        throw FileException(message: 'File not found: $filePath');
      }

      final bytes = await file.readAsBytes();
      final pdfDoc = sf.PdfDocument(inputBytes: bytes);
      
      final pagesToWatermark = pageNumbers ?? 
          List.generate(pdfDoc.pages.count, (i) => i + 1);
      
      for (final pageNum in pagesToWatermark) {
        if (pageNum < 1 || pageNum > pdfDoc.pages.count) continue;
        
        final page = pdfDoc.pages[pageNum - 1];
        final graphics = page.graphics;
        
        graphics.save();
        graphics.setTransparency(opacity);
        graphics.translateTransform(
          page.size.width / 2,
          page.size.height / 2,
        );
        graphics.rotateTransform(-45);
        
        final font = sf.PdfStandardFont(sf.PdfFontFamily.helvetica, 48);
        final brush = sf.PdfSolidBrush(sf.PdfColor(128, 128, 128));
        final format = sf.PdfStringFormat(
          alignment: sf.PdfTextAlignment.center,
          lineAlignment: sf.PdfVerticalAlignment.middle,
        );
        
        graphics.drawString(
          watermarkText,
          font,
          brush: brush,
          bounds: Rect.fromLTWH(-200, 0, 400, 100),
          format: format,
        );
        
        graphics.restore();
      }
      
      await File(outputPath).writeAsBytes(await pdfDoc.save());
      pdfDoc.dispose();
      
      return await loadDocument(outputPath);
    } catch (e) {
      _logger.error('Error adding watermark', e);
      if (e is FileException) rethrow;
      throw PdfProcessingException(message: 'Failed to add watermark: $e');
    }
  }

  @override
  Future<PdfMetadata> getMetadata(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw FileException(message: 'File not found: $filePath');
      }

      final bytes = await file.readAsBytes();
      final pdfDoc = sf.PdfDocument(inputBytes: bytes);
      
      final metadata = _extractMetadata(pdfDoc);
      pdfDoc.dispose();
      
      return metadata;
    } catch (e) {
      _logger.error('Error getting metadata', e);
      if (e is FileException) rethrow;
      throw PdfProcessingException(message: 'Failed to get metadata: $e');
    }
  }

  @override
  Future<PdfDocument> updateMetadata({
    required String filePath,
    required String outputPath,
    required PdfMetadata metadata,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw FileException(message: 'File not found: $filePath');
      }

      final bytes = await file.readAsBytes();
      final pdfDoc = sf.PdfDocument(inputBytes: bytes);
      
      if (metadata.title != null) {
        pdfDoc.documentInformation.title = metadata.title!;
      }
      if (metadata.author != null) {
        pdfDoc.documentInformation.author = metadata.author!;
      }
      if (metadata.subject != null) {
        pdfDoc.documentInformation.subject = metadata.subject!;
      }
      if (metadata.keywords != null) {
        pdfDoc.documentInformation.keywords = metadata.keywords!;
      }
      if (metadata.creator != null) {
        pdfDoc.documentInformation.creator = metadata.creator!;
      }
      
      await File(outputPath).writeAsBytes(await pdfDoc.save());
      pdfDoc.dispose();
      
      return await loadDocument(outputPath);
    } catch (e) {
      _logger.error('Error updating metadata', e);
      if (e is FileException) rethrow;
      throw PdfProcessingException(message: 'Failed to update metadata: $e');
    }
  }

  @override
  Future<String> extractText(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw FileException(message: 'File not found: $filePath');
      }

      final bytes = await file.readAsBytes();
      final pdfDoc = sf.PdfDocument(inputBytes: bytes);
      
      final textBuffer = StringBuffer();
      for (int i = 0; i < pdfDoc.pages.count; i++) {
        final text = sf.PdfTextExtractor(pdfDoc).extractText(startPageIndex: i);
        textBuffer.writeln(text);
      }
      
      pdfDoc.dispose();
      return textBuffer.toString();
    } catch (e) {
      _logger.error('Error extracting text', e);
      if (e is FileException) rethrow;
      throw PdfProcessingException(message: 'Failed to extract text: $e');
    }
  }

  @override
  Future<List<int>> searchText({
    required String filePath,
    required String searchQuery,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw FileException(message: 'File not found: $filePath');
      }

      final bytes = await file.readAsBytes();
      final pdfDoc = sf.PdfDocument(inputBytes: bytes);
      
      final pagesWithMatch = <int>[];
      for (int i = 0; i < pdfDoc.pages.count; i++) {
        final text = sf.PdfTextExtractor(pdfDoc).extractText(startPageIndex: i);
        if (text.toLowerCase().contains(searchQuery.toLowerCase())) {
          pagesWithMatch.add(i + 1);
        }
      }
      
      pdfDoc.dispose();
      return pagesWithMatch;
    } catch (e) {
      _logger.error('Error searching text', e);
      if (e is FileException) rethrow;
      throw PdfProcessingException(message: 'Failed to search text: $e');
    }
  }

  @override
  Future<PdfDocument> createPdfFromImages({
    required List<String> imagePaths,
    required String outputPath,
  }) async {
    try {
      _logger.info('Creating PDF from ${imagePaths.length} images');
      
      final pdfDoc = sf.PdfDocument();
      
      for (final imagePath in imagePaths) {
        final imageFile = File(imagePath);
        if (!await imageFile.exists()) {
          throw FileException(message: 'Image not found: $imagePath');
        }
        
        final imageBytes = await imageFile.readAsBytes();
        final page = pdfDoc.pages.add();
        
        // Load image and draw on page
        final image = sf.PdfBitmap(imageBytes);
        final pageSize = page.getClientSize();
        
        // Calculate aspect ratio to fit image on page
        final imageAspect = image.width / image.height;
        final pageAspect = pageSize.width / pageSize.height;
        
        double drawWidth, drawHeight;
        if (imageAspect > pageAspect) {
          drawWidth = pageSize.width;
          drawHeight = pageSize.width / imageAspect;
        } else {
          drawHeight = pageSize.height;
          drawWidth = pageSize.height * imageAspect;
        }
        
        final x = (pageSize.width - drawWidth) / 2;
        final y = (pageSize.height - drawHeight) / 2;
        
        page.graphics.drawImage(
          image,
          Rect.fromLTWH(x, y, drawWidth, drawHeight),
        );
      }
      
      await File(outputPath).writeAsBytes(await pdfDoc.save());
      pdfDoc.dispose();
      
      return await loadDocument(outputPath);
    } catch (e) {
      _logger.error('Error creating PDF from images', e);
      if (e is FileException) rethrow;
      throw PdfProcessingException(message: 'Failed to create PDF from images: $e');
    }
  }

  // Helper methods
  
  PdfMetadata _extractMetadata(sf.PdfDocument pdfDoc) {
    final info = pdfDoc.documentInformation;
    
    return PdfMetadata(
      title: info.title.isNotEmpty ? info.title : null,
      author: info.author.isNotEmpty ? info.author : null,
      subject: info.subject.isNotEmpty ? info.subject : null,
      keywords: info.keywords.isNotEmpty ? info.keywords : null,
      creator: info.creator.isNotEmpty ? info.creator : null,
      producer: info.producer.isNotEmpty ? info.producer : null,
      creationDate: info.creationDate,
      modificationDate: info.modificationDate,
    );
  }

  sf.PdfPageRotateAngle _getRotationEnum(int degrees) {
    switch (degrees % 360) {
      case 90:
        return sf.PdfPageRotateAngle.rotateAngle90;
      case 180:
        return sf.PdfPageRotateAngle.rotateAngle180;
      case 270:
        return sf.PdfPageRotateAngle.rotateAngle270;
      default:
        return sf.PdfPageRotateAngle.rotateAngle0;
    }
  }
}
