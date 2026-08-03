/// Type of an attached case document.
enum CaseDocumentType { pdf, image, word }

extension CaseDocumentTypeX on CaseDocumentType {
  String get wire => switch (this) {
        CaseDocumentType.pdf => 'pdf',
        CaseDocumentType.image => 'image',
        CaseDocumentType.word => 'word',
      };

  String get label => switch (this) {
        CaseDocumentType.pdf => 'PDF',
        CaseDocumentType.image => 'Image',
        CaseDocumentType.word => 'Word',
      };

  static CaseDocumentType fromWire(String? value) => switch (value) {
        'image' => CaseDocumentType.image,
        'word' => CaseDocumentType.word,
        _ => CaseDocumentType.pdf,
      };
}

/// A document attached to a legal case.
class CaseDocument {
  final int id;
  final String fileName;
  final String filePath;
  final String? mimeType;
  final int? size;
  final CaseDocumentType type;
  final DateTime? createdAt;

  const CaseDocument({
    required this.id,
    required this.fileName,
    required this.filePath,
    this.mimeType,
    this.size,
    this.type = CaseDocumentType.pdf,
    this.createdAt,
  });

  factory CaseDocument.fromJson(Map<String, dynamic> json) {
    return CaseDocument(
      id: json['id'] as int,
      fileName: json['file_name'] as String? ?? 'file',
      filePath: json['file_path'] as String? ?? '',
      mimeType: json['mime_type'] as String?,
      size: json['size'] as int?,
      type: CaseDocumentTypeX.fromWire(json['type'] as String?),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    );
  }

  /// Human-readable file size (e.g. "1.2 MB").
  String get sizeLabel {
    final s = size;
    if (s == null) return '';
    if (s < 1024) return '$s B';
    if (s < 1024 * 1024) return '${(s / 1024).toStringAsFixed(1)} KB';
    return '${(s / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
