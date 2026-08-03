import '../models/case_document.dart';

/// Case document data source contract.
abstract interface class CaseDocumentRepository {
  /// Upload a document to a case and return the created document.
  Future<CaseDocument> uploadDocument({
    required int caseId,
    required String filePath,
    required String fileName,
    String? mimeType,
    CaseDocumentType type,
  });

  /// List documents attached to a case.
  Future<List<CaseDocument>> getDocuments(int caseId);

  /// Download (fetch) a document's bytes.
  Future<List<int>> downloadDocument(int caseId, int documentId);

  /// Delete a document from a case.
  Future<void> deleteDocument(int caseId, int documentId);
}
