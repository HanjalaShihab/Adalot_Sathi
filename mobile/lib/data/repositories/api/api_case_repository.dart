import '../../../core/network/api_client.dart';
import '../../models/legal_case.dart';
import '../case_repository.dart';

/// Real implementation of [CaseRepository] backed by the Adalot Sathi API.
class ApiCaseRepository implements CaseRepository {
  ApiCaseRepository(this._api);

  final ApiClient _api;

  @override
  Future<CasePage> getCases({
    String? search,
    String? status,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _api.dio.get(
        '/cases',
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          if (status != null && status.isNotEmpty) 'status': status,
          'page': page,
          'per_page': perPage,
        },
      );
      return CasePage.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  @override
  Future<LegalCase> getCase(int id) async {
    try {
      final response = await _api.dio.get('/cases/$id');
      return LegalCase.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  @override
  Future<LegalCase> createCase(CaseInput input) async {
    try {
      final response = await _api.dio.post('/cases', data: input.toJson());
      return LegalCase.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  @override
  Future<LegalCase> updateCase(int id, CaseInput input) async {
    try {
      final response = await _api.dio.put('/cases/$id', data: input.toJson());
      return LegalCase.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  @override
  Future<void> deleteCase(int id) async {
    try {
      await _api.dio.delete('/cases/$id');
    } catch (e) {
      throw ApiClient.mapError(e);
    }
  }
}


