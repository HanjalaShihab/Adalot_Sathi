import '../models/legal_case.dart';

/// Case data source contract.
abstract interface class CaseRepository {
  Future<CasePage> getCases({
    String? search,
    String? status,
    int page = 1,
    int perPage = 20,
  });

  Future<LegalCase> getCase(int id);
  Future<LegalCase> createCase(CaseInput input);
  Future<LegalCase> updateCase(int id, CaseInput input);
  Future<void> deleteCase(int id);
}


