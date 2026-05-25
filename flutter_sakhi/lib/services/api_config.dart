/// FastAPI backend configuration.
///
/// Run Flutter with your machine IP:
///   flutter run --dart-define=SAKHI_API_URL=http://192.168.x.x:8000
///
/// Android emulator default: http://10.0.2.2:8000
/// Physical device:          http://YOUR_LAPTOP_IP:8000  (same WiFi)
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

abstract final class ApiConfig {
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

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 45);

  // ── Endpoints — match FastAPI exactly ────────────────────────
  static const String health      = '/health';
  static const String voiceQuery  = '/voice';        // POST multipart file
  static const String chatQuery   = '/chat';         // POST JSON
  static const String mandiPrices = '/mandi';        // GET ?crop=wheat&state=UP
  static const String cropDisease = '/diagnose';     // POST multipart file
  static const String govtSchemes = '/schemes';      // GET ?state=UP
  static const String sosAlert    = '/sos';          // POST JSON
  static const String syncStatus  = '/sync-status';  // GET
}