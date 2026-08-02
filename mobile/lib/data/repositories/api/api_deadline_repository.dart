import '../../../core/network/api_client.dart';
import '../../models/deadline.dart';
import '../deadline_repository.dart';

/// Real implementation of [DeadlineRepository] backed by the Adalot Sathi API.
class ApiDeadlineRepository implements DeadlineRepository {
  ApiDeadlineRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<Deadline>> getDeadlines(int caseId, {String? status}) async {
    try {
      final response = await _api.dio.get(
        '/cases/$caseId/deadlines',
        queryParameters: {if (status != null && status.isNotEmpty) 'status': status},
      );
      return _parseList(response.data);
    } catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  @override
  Future<Deadline> getDeadline(int caseId, int deadlineId) async {
    try {
      final response = await _api.dio.get('/cases/$caseId/deadlines/$deadlineId');
      return Deadline.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  @override
  Future<Deadline> createDeadline(int caseId, DeadlineInput input) async {
    try {
      final response = await _api.dio.post('/cases/$caseId/deadlines', data: input.toJson());
      return Deadline.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  @override
  Future<Deadline> updateDeadline(int caseId, int deadlineId, DeadlineInput input) async {
    try {
      final response = await _api.dio.put(
        '/cases/$caseId/deadlines/$deadlineId',
        data: input.toJson(),
      );
      return Deadline.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  @override
  Future<void> deleteDeadline(int caseId, int deadlineId) async {
    try {
      await _api.dio.delete('/cases/$caseId/deadlines/$deadlineId');
    } catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  @override
  Future<Deadline> markCompleted(int caseId, int deadlineId) async {
    try {
      final response =
          await _api.dio.post('/cases/$caseId/deadlines/$deadlineId/complete');
      return Deadline.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  @override
  Future<List<Deadline>> getUpcoming({
    DateTime? from,
    DateTime? to,
    String? eventType,
  }) async {
    try {
      final response = await _api.dio.get(
        '/deadlines/upcoming',
        queryParameters: {
          if (from != null) 'from': _dateOnly(from),
          if (to != null) 'to': _dateOnly(to),
          if (eventType != null && eventType.isNotEmpty) 'event_type': eventType,
        },
      );
      return _parseList(response.data);
    } catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  List<Deadline> _parseList(dynamic data) {
    final list = data as List<dynamic>? ?? const [];
    return list.map((e) => Deadline.fromJson(e as Map<String, dynamic>)).toList();
  }

  String _dateOnly(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-'
      '${dt.month.toString().padLeft(2, '0')}-'
      '${dt.day.toString().padLeft(2, '0')}';
}


