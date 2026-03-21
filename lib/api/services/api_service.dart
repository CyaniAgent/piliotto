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
    bool skipToken = false,
  }) async {
    final logger = getLogger();

    final defaultHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final token = getToken();
    if (requireToken && token == null) {
      throw ApiException('Token required');
    }

    // 对于 GET 请求，token 放在 query parameters 中
    // 对于 POST/PUT/DELETE 请求，token 放在 body 中
    Map<String, dynamic> finalBody = body != null ? Map.from(body) : {};
    Uri uri;

    if (!skipToken && token != null) {
      if (method == 'GET') {
        queryParams ??= {};
        queryParams['token'] = token;
        uri = _buildUri(endpoint, queryParams);
      } else {
        finalBody['token'] = token;
        uri = _buildUri(endpoint, queryParams);
      }
    } else {
      uri = _buildUri(endpoint, queryParams);
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
          body: finalBody.isNotEmpty ? jsonEncode(finalBody) : null,
        );
      } else if (method == 'PUT') {
        response = await http.put(
          uri,
          headers: requestHeaders,
          body: finalBody.isNotEmpty ? jsonEncode(finalBody) : null,
        );
      } else if (method == 'DELETE') {
        response = await http.delete(
          uri,
          headers: requestHeaders,
          body: finalBody.isNotEmpty ? jsonEncode(finalBody) : null,
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
