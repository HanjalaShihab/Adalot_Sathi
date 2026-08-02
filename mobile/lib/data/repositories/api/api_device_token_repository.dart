import '../../../core/network/api_client.dart';
import '../device_token_repository.dart';

/// Real implementation of [DeviceTokenRepository] backed by the Adalot Sathi API.
class ApiDeviceTokenRepository implements DeviceTokenRepository {
  ApiDeviceTokenRepository(this._api);

  final ApiClient _api;

  @override
  Future<void> registerToken(String token, {String platform = 'android'}) async {
    try {
      await _api.dio.post(
        '/device-tokens',
        data: {'token': token, 'platform': platform},
      );
    } catch (e) {
      throw ApiClient.mapError(e);
    }
  }

  @override
  Future<void> removeToken(String token) async {
    try {
      await _api.dio.delete('/device-tokens', data: {'token': token});
    } catch (e) {
      throw ApiClient.mapError(e);
    }
  }
}


