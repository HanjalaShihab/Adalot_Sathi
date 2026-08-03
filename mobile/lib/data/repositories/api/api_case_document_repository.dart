import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../models/case_document.dart';
import '../case_document_repository.dart';

/// Real implementation of [CaseDocumentRepository] backed by the Adalot Sathi API.
class ApiCaseDocumentRepository implements CaseDocumentRepository {
  ApiCaseDocumentRepository(this._api);

  final ApiClient _api;

  @override
  Future<CaseDocument> uploadDocument({
    required int caseId,
    required String filePath,
    required String fileName,
    String? mimeType,
    CaseDocumentType type = CaseDocumentType.pdf,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
        'type': type.wire,
      });
      final response = await _api.dio.post(
        '/cases/$caseId/documents',
        data: formData,
      );
      final data = response.data as Map<String, dynamic>;
      return CaseDocument.fromJson(data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  @override
  Future<List<CaseDocument>> getDocuments(int caseId) async {
    try {
      final response = await _api.dio.get('/cases/$caseId/documents');
      final data = response.data as Map<String, dynamic>;
      return (data['data'] as List<dynamic>? ?? const [])
          .map((e) => CaseDocument.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  @override
  Future<List<int>> downloadDocument(int caseId, int documentId) async {
    try {
      final response = await _api.dio.get<List<int>>(
        '/cases/$caseId/documents/$documentId/download',
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data ?? const [];
    } catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  @override
  Future<void> deleteDocument(int caseId, int documentId) async {
    try {
      await _api.dio.delete('/cases/$caseId/documents/$documentId');
    } catch (e) {
      throw ApiClient.mapError(e);
    }
  }
}
