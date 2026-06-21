/// HTTP client service for the Sakhi FastAPI backend.
///
/// Provides methods for voice queries, chat, mandi prices, crop disease
/// diagnosis, government schemes, SOS alerts, and sync status. Supports
/// both file-based and byte-based audio uploads for cross-platform use.
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:sakhi_ai/services/api_config.dart';

/// HTTP client for Sakhi FastAPI backend.
///
/// Wraps all API calls with configurable timeouts and centralised error
/// handling. Accepts an optional [http.Client] and [baseUrl] for testing
/// and custom deployments.
class SakhiApiService {
  /// Creates a new API service instance.
  ///
  /// [client] allows injecting a custom HTTP client (useful for testing).
  /// [baseUrl] overrides the default backend URL from [ApiConfig].
  SakhiApiService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  final http.Client _client;
  final String _baseUrl;

  /// Builds a full [Uri] by appending [path] to the base URL.
  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  /// Returns standard JSON request headers.
  Map<String, String> get _jsonHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // ─────────────────────────────────────────────
  // HEALTH CHECK
  // ─────────────────────────────────────────────

  /// Checks if the backend server is reachable and healthy.
  ///
  /// Returns `true` if the server responds with HTTP 200, `false` otherwise.
  /// Catches all exceptions and returns `false` on network errors.
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

  /// Sends an audio file to the backend for voice-to-text processing.
  ///
  /// [audioFile] is the audio file to upload (mobile/desktop).
  /// [languageCode] specifies the language for transcription (default: 'hi' for Hindi).
  /// Returns a [VoiceApiResult] containing either the audio response bytes or an error.
  /// Returns a network error result on exception.
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

  /// Sends raw audio bytes to the backend for voice-to-text processing.
  ///
  /// [audioBytes] is the raw audio data (used for web platform).
  /// [languageCode] specifies the language for transcription (default: 'hi' for Hindi).
  /// Returns a [VoiceApiResult] containing either the audio response bytes or an error.
  /// Returns a network error result on exception.
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

  /// Parses the voice API response into a structured result.
  ///
  /// [statusCode] is the HTTP status code from the response.
  /// [bodyBytes] is the raw response body.
  /// Returns a [VoiceApiResult] with audio bytes on success, or an error
  /// describing transcription failure or server-side error.
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

  /// Checks if the given bytes look like an MP3 file.
  ///
  /// [bytes] is the raw byte data to inspect.
  /// Returns `true` if the bytes start with an MP3 frame sync (0xFFE0 mask)
  /// or an ID3v2 header ('ID3'), `false` otherwise.
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

  /// Sends a text chat query to the backend.
  ///
  /// [query] is the user's text message.
  /// [languageCode] specifies the language (default: 'hi' for Hindi).
  /// Returns the decoded JSON response as a [Map].
  /// Throws [SakhiApiException] on non-2xx HTTP responses.
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

  /// Fetches current mandi (market) prices for a crop in a given state.
  ///
  /// [crop] is the crop name (default: 'wheat').
  /// [state] is the state code (default: 'UP').
  /// Returns a list of price entries from the response, or an empty list
  /// if none are found. Throws [SakhiApiException] on non-2xx responses.
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

  /// Uploads a crop image for disease diagnosis.
  ///
  /// [imageFile] is the image file to upload.
  /// [languageCode] specifies the language for the response (default: 'hi').
  /// Returns the raw response bytes (typically an image) on success (HTTP 200),
  /// or `null` on failure.
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

  /// Fetches government schemes applicable to a given state.
  ///
  /// [state] is the state code (default: 'UP').
  /// Returns a list of scheme entries. Throws [SakhiApiException] on
  /// non-2xx HTTP responses.
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

  /// Triggers an SOS emergency alert with the user's location.
  ///
  /// [latitude] and [longitude] are the GPS coordinates.
  /// [message] is an optional distress message (default: 'SOS - Madad chahiye!').
  /// Throws [SakhiApiException] on non-2xx HTTP responses.
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

  /// Fetches the backend sync status.
  ///
  /// Returns a [Map] with sync information (e.g. last sync time, status).
  /// Returns an offline status map on network failure.
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

  // ─────────────────────────────────────────────
  // INTERNAL JSON DECODER
  // ─────────────────────────────────────────────

  /// Decodes an HTTP response body as JSON.
  ///
  /// [response] is the HTTP response to decode.
  /// Returns the decoded JSON as a [Map<String, dynamic>].
  /// Throws [SakhiApiException] on non-2xx status codes. Returns an empty
  /// map if the response body is empty.
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

  /// Closes the underlying HTTP client and releases resources.
  void dispose() => _client.close();
}

/// Result of a voice API call.
///
/// On success, [audioBytes] contains the TTS audio response.
/// On failure, [serverError] describes the error category:
/// - `'network'` for connectivity issues
/// - `'transcription'` for STT failures
/// - any other string for server-reported errors.
class VoiceApiResult {
  /// Creates a result with either audio bytes or a server error message.
  const VoiceApiResult({this.audioBytes, this.serverError});

  /// Creates a result representing a network/connectivity error.
  const VoiceApiResult.networkError()
      : audioBytes = null,
        serverError = 'network';

  /// Creates a result representing a transcription failure.
  const VoiceApiResult.transcriptionFailed()
      : audioBytes = null,
        serverError = 'transcription';

  /// The raw audio bytes returned by the TTS backend, or `null` on error.
  final List<int>? audioBytes;

  /// Error description, or `null` on success.
  final String? serverError;

  /// Whether this result represents a network error.
  bool get isNetworkError => serverError == 'network';

  /// Whether this result represents a transcription failure.
  bool get isTranscriptionFailed => serverError == 'transcription';
}

/// Exception thrown when the Sakhi API returns a non-2xx HTTP response.
///
/// Contains the HTTP [statusCode] and raw response [body] for diagnostics.
class SakhiApiException implements Exception {
  /// Creates an API exception with the given [statusCode] and response [body].
  SakhiApiException(this.statusCode, this.body);

  /// The HTTP status code returned by the server.
  final int statusCode;

  /// The raw response body string.
  final String body;

  /// Returns a human-readable description of the exception.
  @override
  String toString() =>
      'SakhiApiException($statusCode): $body';
}