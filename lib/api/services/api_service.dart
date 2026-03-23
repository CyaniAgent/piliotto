import 'package:dio/dio.dart';
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

  static final Dio _dio = Dio(BaseOptions(
    baseUrl: '$baseUrl$apiPath',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  static bool _initialized = false;

  static void init() {
    if (_initialized) return;
    _initialized = true;

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = getToken();
        if (token != null && !_shouldSkipToken(options)) {
          if (options.method == 'GET') {
            options.queryParameters['token'] = token;
          } else {
            if (options.data is Map) {
              options.data['token'] = token;
            }
          }
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (error, handler) {
        final logger = getLogger();
        logger.e('API Error: ${error.message}');
        return handler.next(error);
      },
    ));
  }

  static bool _shouldSkipToken(RequestOptions options) {
    final skipToken = options.extra['skipToken'] as bool?;
    return skipToken == true;
  }

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
    init();

    final logger = getLogger();

    final token = getToken();
    if (requireToken && token == null) {
      throw ApiException('Token required');
    }

    final options = Options(
      method: method,
      headers: headers,
      extra: {'skipToken': skipToken},
    );

    try {
      Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await _dio.get(
            endpoint,
            queryParameters: queryParams,
            options: options,
          );
          break;
        case 'POST':
          response = await _dio.post(
            endpoint,
            data: body,
            queryParameters: queryParams,
            options: options,
          );
          break;
        case 'PUT':
          response = await _dio.put(
            endpoint,
            data: body,
            queryParameters: queryParams,
            options: options,
          );
          break;
        case 'DELETE':
          response = await _dio.delete(
            endpoint,
            data: body,
            queryParameters: queryParams,
            options: options,
          );
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      logger.d(
          'API Request: ${response.requestOptions.uri}, Status: ${response.statusCode}');

      final responseData = response.data as Map<String, dynamic>;

      if (responseData['status'] == 'error') {
        throw ApiException(
            responseData['message'] ?? 'Unknown error', response.statusCode);
      }

      return responseData;
    } on DioException catch (e) {
      logger.e('API Request Error: ${e.message}');
      if (e.response?.data != null && e.response?.data is Map) {
        final data = e.response!.data as Map;
        throw ApiException(data['message'] ?? e.message ?? 'Request failed',
            e.response?.statusCode);
      }
      throw ApiException(e.message ?? 'Request failed', e.response?.statusCode);
    } on ApiException {
      rethrow;
    } catch (e) {
      logger.e('API Request Error: ${e.toString()}');
      throw Exception('API request failed: $e');
    }
  }
}
