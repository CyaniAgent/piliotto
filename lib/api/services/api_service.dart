import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../utils/storage.dart';
import '../../services/loggeer.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message';
}

class ApiService {
  static const String baseUrl = 'https://api.ottohub.cn';
  static const String apiPath = '/api';
  static const String _tokenKey = 'ottohub_token';

  static void setToken(String token) {
    GStrorage.setting.put(_tokenKey, token);
  }

  static String? getToken() {
    return GStrorage.setting.get(_tokenKey);
  }

  static void clearToken() {
    GStrorage.setting.delete(_tokenKey);
  }

  static Future<Map<String, dynamic>> request(
    String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    bool requireToken = false,
  }) async {
    final uri = _buildUri(endpoint, queryParams);
    final logger = getLogger();

    final defaultHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requireToken) {
      final token = getToken();
      if (token != null) {
        if (queryParams != null) {
          queryParams['token'] = token;
        } else {
          queryParams = {'token': token};
        }
      }
    }

    final requestHeaders = {...defaultHeaders, ...?headers};

    http.Response response;

    try {
      if (method == 'GET') {
        response = await http.get(uri, headers: requestHeaders);
      } else if (method == 'POST') {
        response = await http.post(
          uri,
          headers: requestHeaders,
          body: body != null ? jsonEncode(body) : null,
        );
      } else if (method == 'PUT') {
        response = await http.put(
          uri,
          headers: requestHeaders,
          body: body != null ? jsonEncode(body) : null,
        );
      } else if (method == 'DELETE') {
        response = await http.delete(
          uri,
          headers: requestHeaders,
          body: body != null ? jsonEncode(body) : null,
        );
      } else {
        throw Exception('Unsupported HTTP method: $method');
      }

      logger.d(
          'API Request: ${uri.toString()}, Status: ${response.statusCode}, Body: ${response.body}');

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseData['status'] == 'error') {
        throw ApiException(
            responseData['message'] ?? 'Unknown error', response.statusCode);
      }

      return responseData;
    } on ApiException {
      rethrow;
    } catch (e) {
      logger.e('API Request Error: ${e.toString()}');
      throw Exception('API request failed: $e');
    }
  }

  static Uri _buildUri(String endpoint, Map<String, dynamic>? queryParams) {
    var baseUri = Uri.parse('$baseUrl$apiPath$endpoint');
    if (queryParams == null || queryParams.isEmpty) {
      return baseUri;
    }
    return baseUri.replace(
      queryParameters:
          queryParams.map((key, value) => MapEntry(key, value.toString())),
    );
  }
}
