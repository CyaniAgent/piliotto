import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../utils/storage.dart';

class ApiService {
  static const String baseUrl = 'https://api.ottohub.cn';
  static const String apiPath = '/api';
  static const String _tokenKey = 'ottohub_token';

  // 设置token
  static void setToken(String token) {
    GStrorage.setting.put(_tokenKey, token);
  }

  // 获取token
  static String? getToken() {
    return GStrorage.setting.get(_tokenKey);
  }

  // 清除token
  static void clearToken() {
    GStrorage.setting.delete(_tokenKey);
  }

  static Future<Map<String, dynamic>> request(
    String endpoint,
    {
    String method = 'GET',
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    bool requireToken = true,
  }) async {
    final uri = _buildUri(endpoint, queryParams);
    final defaultHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // 添加token到请求头
    if (requireToken) {
      final token = getToken();
      if (token != null) {
        defaultHeaders['Authorization'] = 'Bearer $token';
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

      final responseData = jsonDecode(response.body);
      return responseData;
    } catch (e) {
      throw Exception('API request failed: $e');
    }
  }

  static Uri _buildUri(String endpoint, Map<String, dynamic>? queryParams) {
    final baseUri = Uri.parse('$baseUrl$apiPath$endpoint');
    if (queryParams == null || queryParams.isEmpty) {
      return baseUri;
    }
    return baseUri.replace(
      queryParameters: queryParams.map((key, value) => MapEntry(key, value.toString())),
    );
  }
}
