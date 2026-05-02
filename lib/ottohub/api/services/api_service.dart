import 'package:dio/dio.dart';
import 'package:piliotto/utils/storage.dart';
import 'package:piliotto/services/loggeer.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final bool isNetworkError;
  final bool isTimeout;
  final bool isUnauthorized;

  ApiException(
    this.message, [
    this.statusCode,
    this.isNetworkError = false,
    this.isTimeout = false,
    this.isUnauthorized = false,
  ]);

  @override
  String toString() => 'ApiException: $message';
}

class ApiService {
  static const String baseUrl = 'https://api.ottohub.cn';
  static const String apiPath = '/api';
  static const String _tokenKey = 'ottohub_token';

  static final Dio _dio = Dio(BaseOptions(
    baseUrl: '$baseUrl$apiPath',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
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
        final statusCode = error.response?.statusCode;
        final isSilent = error.requestOptions.extra['silent'] == true;

        if (!isSilent) {
          logger.e('API Error: ${error.message}, Status: $statusCode');
        }

        return handler.next(error);
      },
    ));
  }

  static bool _shouldSkipToken(RequestOptions options) {
    final skipToken = options.extra['skipToken'] as bool?;
    return skipToken == true;
  }

  static void setToken(String token) {
    try {
      GStrorage.setting.put(_tokenKey, token);
    } catch (_) {}
  }

  static String? getToken() {
    try {
      return GStrorage.setting.get(_tokenKey);
    } catch (_) {
      return null;
    }
  }

  static void clearToken() {
    try {
      GStrorage.setting.delete(_tokenKey);
    } catch (_) {}
  }

  static String _getFriendlyErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return '连接超时，请检查网络后重试';
      case DioExceptionType.sendTimeout:
        return '发送超时，请检查网络后重试';
      case DioExceptionType.receiveTimeout:
        return '响应超时，请稍后重试';
      case DioExceptionType.badCertificate:
        return '证书错误，请检查网络环境';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) return '请求未授权';
        if (statusCode == 403) return '访问被拒绝';
        if (statusCode == 404) return '资源不存在';
        if (statusCode == 500) return '服务器错误，请稍后重试';
        if (statusCode == 502) return '网关错误，请稍后重试';
        if (statusCode == 503) return '服务暂不可用，请稍后重试';
        return '请求失败 (${statusCode ?? '未知'})';
      case DioExceptionType.cancel:
        return '请求已取消';
      case DioExceptionType.connectionError:
        return '网络连接失败，请检查网络设置';
      case DioExceptionType.unknown:
        if (e.message?.contains('SocketException') == true) {
          return '网络连接失败，请检查网络设置';
        }
        return '网络错误，请稍后重试';
    }
  }

  static Future<Map<String, dynamic>?> silentRequest(
    String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    bool requireToken = false,
    bool skipToken = false,
  }) async {
    try {
      return await request(
        endpoint,
        method: method,
        body: body,
        headers: headers,
        queryParams: queryParams,
        requireToken: requireToken,
        skipToken: skipToken,
        silent: true,
      );
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> request(
    String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    bool requireToken = false,
    bool skipToken = false,
    bool silent = false,
  }) async {
    init();

    final logger = getLogger();

    final token = getToken();
    if (requireToken && token == null) {
      throw ApiException('请先登录', null, false, false, true);
    }

    final options = Options(
      method: method,
      headers: headers,
      extra: {'skipToken': skipToken, 'silent': silent},
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
          throw ApiException('不支持的请求方法');
      }

      if (!silent) {
        logger.d(
            'API Request: ${response.requestOptions.uri}, Status: ${response.statusCode}');
      }

      final responseData = response.data as Map<String, dynamic>;

      if (responseData['status'] == 'error') {
        throw ApiException(
            responseData['message'] ?? '请求失败', response.statusCode);
      }

      return responseData;
    } on DioException catch (e) {
      final friendlyMessage = _getFriendlyErrorMessage(e);
      final isTimeout = e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout;
      final isNetworkError = e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown;
      final isUnauthorized = e.response?.statusCode == 401;

      throw ApiException(
        friendlyMessage,
        e.response?.statusCode,
        isNetworkError,
        isTimeout,
        isUnauthorized,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      if (!silent) {
        logger.e('API Request Error: ${e.toString()}');
      }
      throw ApiException('请求失败，请稍后重试');
    }
  }
}
