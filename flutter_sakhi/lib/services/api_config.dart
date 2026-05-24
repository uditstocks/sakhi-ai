/// FastAPI backend configuration.
///
/// Set [baseUrl] via `--dart-define=SAKHI_API_URL=http://10.0.2.2:8000`
/// for Android emulator, or your machine IP for a physical device.
abstract final class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'SAKHI_API_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // REST paths — align with your FastAPI router prefixes
  static const String health = '/health';
  static const String voiceQuery = '/api/v1/voice/query';
  static const String mandiPrices = '/api/v1/mandi/prices';
  static const String cropDisease = '/api/v1/crop/diagnose';
  static const String govtSchemes = '/api/v1/schemes';
  static const String sosAlert = '/api/v1/sos';
  static const String syncStatus = '/api/v1/sync/status';
}
