import 'package:equatable/equatable.dart';

/// Represents a PDF document entity
class PdfDocument extends Equatable {
  final String id;
  final String name;
  final String path;
  final int sizeInBytes;
  final int pageCount;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final bool isEncrypted;
  final PdfMetadata? metadata;

  const PdfDocument({
    required this.id,
    required this.name,
    required this.path,
    required this.sizeInBytes,
    required this.pageCount,
    required this.createdAt,
    required this.modifiedAt,
    this.isEncrypted = false,
    this.metadata,
  });

  /// Get file size in MB
  double get sizeInMB => sizeInBytes / (1024 * 1024);

  /// Get file size formatted
  String get formattedSize {
    if (sizeInBytes < 1024) {
      return '$sizeInBytes B';
    } else if (sizeInBytes < 1024 * 1024) {
      return '${(sizeInBytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }

  PdfDocument copyWith({
    String? id,
    String? name,
    String? path,
    int? sizeInBytes,
    int? pageCount,
    DateTime? createdAt,
    DateTime? modifiedAt,
    bool? isEncrypted,
    PdfMetadata? metadata,
  }) {
    return PdfDocument(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      sizeInBytes: sizeInBytes ?? this.sizeInBytes,
      pageCount: pageCount ?? this.pageCount,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        path,
        sizeInBytes,
        pageCount,
        createdAt,
        modifiedAt,
        isEncrypted,
        metadata,
      ];
}

/// PDF metadata
class PdfMetadata extends Equatable {
  final String? title;
  final String? author;
  final String? subject;
  final String? keywords;
  final String? creator;
  final String? producer;
  final DateTime? creationDate;
  final DateTime? modificationDate;

  const PdfMetadata({
    this.title,
    this.author,
    this.subject,
    this.keywords,
    this.creator,
    this.producer,
    this.creationDate,
    this.modificationDate,
  });

  PdfMetadata copyWith({
    String? title,
    String? author,
    String? subject,
    String? keywords,
    String? creator,
    String? producer,
    DateTime? creationDate,
    DateTime? modificationDate,
  }) {
    return PdfMetadata(
      title: title ?? this.title,
      author: author ?? this.author,
      subject: subject ?? this.subject,
      keywords: keywords ?? this.keywords,
      creator: creator ?? this.creator,
      producer: producer ?? this.producer,
      creationDate: creationDate ?? this.creationDate,
      modificationDate: modificationDate ?? this.modificationDate,
    );
  }

  @override
  List<Object?> get props => [
        title,
        author,
        subject,
        keywords,
        creator,
        producer,
        creationDate,
        modificationDate,
      ];
}
