/// Device token (push notification) data source contract.
abstract interface class DeviceTokenRepository {
  /// Register this device's FCM token with the backend.
  Future<void> registerToken(String token, {String platform = 'android'});

  /// Remove this device's FCM token.
  Future<void> removeToken(String token);
}


