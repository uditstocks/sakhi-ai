/// FastAPI backend configuration.
///
/// Resolves the correct base URL depending on the target platform:
/// - Web: `http://localhost:8000`
/// - Android emulator: `http://10.0.2.2:8000` (loopback to host)
/// - Physical device: `http://YOUR_LAPTOP_IP:8000` (same WiFi)
///
/// Override at compile time with:
///   `flutter run --dart-define=SAKHI_API_URL=http://192.168.x.x:8000`
///
/// Also defines timeout durations and endpoint path constants that
/// must match the FastAPI route definitions exactly.
library;
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

/// Centralised configuration for the Sakhi FastAPI backend.
///
/// Provides the [baseUrl] resolved per-platform, connection/receive
/// [Duration] timeouts, and all endpoint path [String] constants.
abstract final class ApiConfig {
  /// Resolves the backend base URL for the current platform.
  ///
  /// Priority order:
  /// 1. Compile-time `SAKHI_API_URL` environment variable
  /// 2. Platform-specific default (Android emulator loopback or localhost)
  static String get baseUrl {
    const envUrl = String.fromEnvironment('SAKHI_API_URL');
    if (envUrl.isNotEmpty) return envUrl;

    if (kIsWeb) return 'http://localhost:8000';
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8000';
      }
    } catch (_) {}
    return 'http://localhost:8000';
  }

  /// Timeout for establishing a connection to the backend.
  static const Duration connectTimeout = Duration(seconds: 15);

  /// Timeout for receiving a full response from the backend.
  static const Duration receiveTimeout = Duration(seconds: 45);

  // ── Endpoints — match FastAPI exactly ────────────────────────

  /// Health check endpoint. GET.
  static const String health      = '/health';

  /// Voice query endpoint. POST multipart file upload.
  static const String voiceQuery  = '/voice';

  /// Chat query endpoint. POST JSON body.
  static const String chatQuery   = '/chat';

  /// Mandi prices endpoint. GET with `crop` and `state` query params.
  static const String mandiPrices = '/mandi';

  /// Crop disease diagnosis endpoint. POST multipart file upload.
  static const String cropDisease = '/diagnose';

  /// Government schemes endpoint. GET with `state` query param.
  static const String govtSchemes = '/schemes';

  /// SOS alert endpoint. POST JSON body with coordinates.
  static const String sosAlert    = '/sos';

  /// Sync status endpoint. GET.
  static const String syncStatus  = '/sync-status';
}