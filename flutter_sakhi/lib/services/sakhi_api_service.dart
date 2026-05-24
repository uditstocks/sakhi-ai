import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sakhi_ai/services/api_config.dart';

/// HTTP client for Sakhi FastAPI backend. Inject [http.Client] in tests.
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

  /// GET /health — use on app start to verify backend reachability.
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

  /// POST /api/v1/voice/query — send recorded audio metadata or base64 payload.
  Future<Map<String, dynamic>> sendVoiceQuery({
    required String languageCode,
    String? audioBase64,
    String? transcript,
  }) async {
    final body = jsonEncode({
      'language': languageCode,
      'audio_base64': ?audioBase64,
      'transcript': ?transcript,
    });
    final response = await _client
        .post(
          _uri(ApiConfig.voiceQuery),
          headers: _jsonHeaders,
          body: body,
        )
        .timeout(ApiConfig.receiveTimeout);
    return _decode(response);
  }

  /// GET /api/v1/mandi/prices?crop=wheat&state=UP
  Future<List<dynamic>> fetchMandiPrices({
    String? crop,
    String? state,
    String? district,
  }) async {
    final query = <String, String>{
      'crop': ?crop,
      'state': ?state,
      'district': ?district,
    };
    final response = await _client
        .get(_uri(ApiConfig.mandiPrices).replace(queryParameters: query))
        .timeout(ApiConfig.receiveTimeout);
    final data = _decode(response);
    return (data['prices'] as List<dynamic>?) ?? [];
  }

  Future<Map<String, dynamic>> diagnoseCrop({
    required String description,
    String? imageBase64,
  }) async {
    final response = await _client
        .post(
          _uri(ApiConfig.cropDisease),
          headers: _jsonHeaders,
          body: jsonEncode({
            'description': description,
            'image_base64': ?imageBase64,
          }),
        )
        .timeout(ApiConfig.receiveTimeout);
    return _decode(response);
  }

  Future<List<dynamic>> fetchGovtSchemes({String? state}) async {
    final response = await _client
        .get(
          _uri(ApiConfig.govtSchemes).replace(
            queryParameters: state != null ? {'state': state} : null,
          ),
        )
        .timeout(ApiConfig.receiveTimeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw SakhiApiException(response.statusCode, response.body);
    }
    if (response.body.isEmpty) return [];
    final decoded = jsonDecode(response.body);
    if (decoded is List) return decoded;
    final data = decoded as Map<String, dynamic>;
    return (data['schemes'] as List<dynamic>?) ?? [];
  }

  Future<void> triggerSos({
    required double latitude,
    required double longitude,
    String? message,
  }) async {
    final response = await _client
        .post(
          _uri(ApiConfig.sosAlert),
          headers: _jsonHeaders,
          body: jsonEncode({
            'latitude': latitude,
            'longitude': longitude,
            'message': ?message,
          }),
        )
        .timeout(ApiConfig.receiveTimeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw SakhiApiException(response.statusCode, response.body);
    }
  }

  Future<Map<String, dynamic>> fetchSyncStatus() async {
    final response = await _client
        .get(_uri(ApiConfig.syncStatus))
        .timeout(ApiConfig.connectTimeout);
    return _decode(response);
  }

  Map<String, dynamic> _decode(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw SakhiApiException(response.statusCode, response.body);
    }
    if (response.body.isEmpty) return {};
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  void dispose() => _client.close();
}

class SakhiApiException implements Exception {
  SakhiApiException(this.statusCode, this.body);
  final int statusCode;
  final String body;

  @override
  String toString() => 'SakhiApiException($statusCode): $body';
}
