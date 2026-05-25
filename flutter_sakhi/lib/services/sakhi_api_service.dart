import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:sakhi_ai/services/api_config.dart';

/// HTTP client for Sakhi FastAPI backend.
class SakhiApiService {
  SakhiApiService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  final http.Client _client;
  final String _baseUrl;

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Map<String, String> get _jsonHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // ─────────────────────────────────────────────
  // HEALTH CHECK
  // ─────────────────────────────────────────────

  Future<bool> checkHealth() async {
    try {
      final response = await _client
          .get(_uri(ApiConfig.health))
          .timeout(ApiConfig.connectTimeout);

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // VOICE FILE — MOBILE/DESKTOP
  // ─────────────────────────────────────────────

  Future<VoiceApiResult> sendVoiceFile({
    required File audioFile,
    String languageCode = 'hi',
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
          '$_baseUrl${ApiConfig.voiceQuery}?language=$languageCode',
        ),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          audioFile.path,
        ),
      );

      final streamed =
          await request.send().timeout(ApiConfig.receiveTimeout);
      final bodyBytes = await streamed.stream.toBytes();

      return _parseVoiceResponse(streamed.statusCode, bodyBytes);
    } catch (e) {
      print('sendVoiceFile error: $e');
      return const VoiceApiResult.networkError();
    }
  }

  // ─────────────────────────────────────────────
  // VOICE BYTES — WEB SUPPORT
  // ─────────────────────────────────────────────

  Future<VoiceApiResult> sendVoiceBytes({
    required Uint8List audioBytes,
    String languageCode = 'hi',
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
          '$_baseUrl${ApiConfig.voiceQuery}?language=$languageCode',
        ),
      );

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          audioBytes,
          filename: 'recording.m4a',
        ),
      );

      final streamed =
          await request.send().timeout(ApiConfig.receiveTimeout);
      final bodyBytes = await streamed.stream.toBytes();

      return _parseVoiceResponse(streamed.statusCode, bodyBytes);
    } catch (e) {
      print('sendVoiceBytes error: $e');
      return const VoiceApiResult.networkError();
    }
  }

  VoiceApiResult _parseVoiceResponse(int statusCode, List<int> bodyBytes) {
    final contentType = _looksLikeMp3(bodyBytes);

    if (statusCode == 200 && contentType && bodyBytes.isNotEmpty) {
      return VoiceApiResult(audioBytes: bodyBytes);
    }

    String? serverError;
    try {
      final decoded = jsonDecode(utf8.decode(bodyBytes));
      if (decoded is Map<String, dynamic>) {
        serverError = decoded['error'] as String? ??
            decoded['response'] as String?;
      }
    } catch (_) {}

    print('Voice API error $statusCode: ${utf8.decode(bodyBytes, allowMalformed: true)}');

    if (statusCode == 422 ||
        (serverError?.toLowerCase().contains('transcribe') ?? false)) {
      return const VoiceApiResult.transcriptionFailed();
    }

    return VoiceApiResult(serverError: serverError);
  }

  bool _looksLikeMp3(List<int> bytes) {
    if (bytes.length < 3) return false;
    if (bytes[0] == 0xFF && (bytes[1] & 0xE0) == 0xE0) return true;
    if (bytes.length >= 3 &&
        bytes[0] == 0x49 &&
        bytes[1] == 0x44 &&
        bytes[2] == 0x33) {
      return true;
    }
    return false;
  }

  // ─────────────────────────────────────────────
  // CHAT
  // ─────────────────────────────────────────────

  Future<Map<String, dynamic>> sendChatQuery({
    required String query,
    String languageCode = 'hi',
  }) async {
    final response = await _client
        .post(
          _uri(ApiConfig.chatQuery),
          headers: _jsonHeaders,
          body: jsonEncode({
            'query': query,
            'language': languageCode,
          }),
        )
        .timeout(ApiConfig.receiveTimeout);

    return _decode(response);
  }

  // ─────────────────────────────────────────────
  // MANDI PRICES
  // ─────────────────────────────────────────────

  Future<List<dynamic>> fetchMandiPrices({
    String crop = 'wheat',
    String state = 'UP',
  }) async {
    final uri = _uri(ApiConfig.mandiPrices)
        .replace(queryParameters: {
      'crop': crop,
      'state': state,
    });

    final response =
        await _client.get(uri).timeout(ApiConfig.receiveTimeout);

    final data = _decode(response);

    return (data['prices'] as List<dynamic>?) ?? [];
  }

  // ─────────────────────────────────────────────
  // CROP DISEASE
  // ─────────────────────────────────────────────

  Future<List<int>?> diagnoseCropImage({
    required File imageFile,
    String languageCode = 'hi',
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
          '$_baseUrl${ApiConfig.cropDisease}?language=$languageCode',
        ),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
        ),
      );

      final streamed =
          await request.send().timeout(ApiConfig.receiveTimeout);

      if (streamed.statusCode == 200) {
        return await streamed.stream.toBytes();
      }

      final body = await streamed.stream.bytesToString();

      print('Diagnose API error ${streamed.statusCode}: $body');

      return null;
    } catch (e) {
      print('diagnoseCropImage error: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // GOVT SCHEMES
  // ─────────────────────────────────────────────

  Future<List<dynamic>> fetchGovtSchemes({
    String state = 'UP',
  }) async {
    final uri = _uri(ApiConfig.govtSchemes)
        .replace(queryParameters: {
      'state': state,
    });

    final response =
        await _client.get(uri).timeout(ApiConfig.receiveTimeout);

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw SakhiApiException(
        response.statusCode,
        response.body,
      );
    }

    if (response.body.isEmpty) return [];

    final decoded = jsonDecode(response.body);

    if (decoded is List) return decoded;

    return (decoded as Map<String, dynamic>)['schemes']
            as List<dynamic>? ??
        [];
  }

  // ─────────────────────────────────────────────
  // SOS ALERT
  // ─────────────────────────────────────────────

  Future<void> triggerSos({
    required double latitude,
    required double longitude,
    String message = 'SOS - Madad chahiye!',
  }) async {
    final response = await _client
        .post(
          _uri(ApiConfig.sosAlert),
          headers: _jsonHeaders,
          body: jsonEncode({
            'latitude': latitude,
            'longitude': longitude,
            'message': message,
          }),
        )
        .timeout(ApiConfig.receiveTimeout);

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw SakhiApiException(
        response.statusCode,
        response.body,
      );
    }
  }

  // ─────────────────────────────────────────────
  // SYNC STATUS
  // ─────────────────────────────────────────────

  Future<Map<String, dynamic>> fetchSyncStatus() async {
    try {
      final response = await _client
          .get(_uri(ApiConfig.syncStatus))
          .timeout(ApiConfig.connectTimeout);

      return _decode(response);
    } catch (_) {
      return {
        'last_sync_ago': 'offline',
        'status': 'offline',
      };
    }
  }

  // ─────────────────────────────────────────────
  // INTERNAL JSON DECODER
  // ─────────────────────────────────────────────

  Map<String, dynamic> _decode(http.Response response) {
    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw SakhiApiException(
        response.statusCode,
        response.body,
      );
    }

    if (response.body.isEmpty) return {};

    return jsonDecode(response.body)
        as Map<String, dynamic>;
  }

  void dispose() => _client.close();
}

class VoiceApiResult {
  const VoiceApiResult({this.audioBytes, this.serverError});

  const VoiceApiResult.networkError()
      : audioBytes = null,
        serverError = 'network';

  const VoiceApiResult.transcriptionFailed()
      : audioBytes = null,
        serverError = 'transcription';

  final List<int>? audioBytes;
  final String? serverError;

  bool get isNetworkError => serverError == 'network';
  bool get isTranscriptionFailed => serverError == 'transcription';
}

class SakhiApiException implements Exception {
  SakhiApiException(this.statusCode, this.body);

  final int statusCode;
  final String body;

  @override
  String toString() =>
      'SakhiApiException($statusCode): $body';
}