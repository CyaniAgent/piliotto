import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../utils/storage.dart';
import '../../services/loggeer.dart';

class OldApiService {
  static const String baseUrl = 'https://api.ottohub.cn';
  static const String _tokenKey = 'ottohub_token';

  // 获取token
  static String? getToken() {
    return GStrorage.setting.get(_tokenKey);
  }

  static Future<Map<String, dynamic>> request(
    String module,
    String action,
    Map<String, dynamic> params,
  ) async {
    // 如果需要token，添加到参数中
    if (params.containsKey('token') && params['token'] == null) {
      final token = getToken();
      if (token != null) {
        params['token'] = token;
      }
    }

    // 构建请求URL
    final uri = Uri.parse(baseUrl).replace(
      queryParameters: {
        'module': module,
        'action': action,
        ...params,
      },
    );

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    try {
      final logger = getLogger();
      final response = await http.get(uri, headers: headers);
      logger.d(
          'API Request: ${uri.toString()}, Response Status: ${response.statusCode}, Response Body: ${response.body}');
      final responseData = jsonDecode(response.body);
      return responseData;
    } catch (e) {
      final logger = getLogger();
      logger.e('API Request Error: ${e.toString()}');
      throw Exception('API request failed: $e');
    }
  }

  // 获取视频评论列表
  static Future<Map<String, dynamic>> getVideoComments({
    required int vid,
    int parentVcid = 0,
    int offset = 0,
    int num = 12,
  }) async {
    // 确保num参数不超过12
    if (num > 12) {
      final logger = getLogger();
      logger.w('警告: num参数超过12，自动调整为12');
      num = 12;
    }
    return request(
      'comment',
      'video_comment_list',
      {
        'vid': vid.toString(),
        'parent_vcid': parentVcid.toString(),
        'offset': offset.toString(),
        'num': num.toString(),
      },
    );
  }

  // 获取用户详情
  static Future<Map<String, dynamic>> getUserDetail({required int uid}) async {
    return request(
      'user',
      'get_user_detail',
      {
        'uid': uid.toString(),
      },
    );
  }

  // 获取关注状态
  static Future<Map<String, dynamic>> getFollowStatus(
      {required int followingUid}) async {
    return request(
      'following',
      'follow_status',
      {
        'following_uid': followingUid.toString(),
        'token': null, // 自动添加token
      },
    );
  }

  // 关注/取关用户
  static Future<Map<String, dynamic>> followUser(
      {required int followingUid}) async {
    return request(
      'following',
      'follow',
      {
        'following_uid': followingUid.toString(),
        'token': null, // 自动添加token
      },
    );
  }

  // 评论视频
  static Future<Map<String, dynamic>> commentVideo({
    required int vid,
    int parentVcid = 0,
    required String content,
  }) async {
    return request(
      'comment',
      'comment_video',
      {
        'vid': vid.toString(),
        'parent_vcid': parentVcid.toString(),
        'content': content,
        'token': getToken(),
      },
    );
  }

  // 删除视频评论
  static Future<Map<String, dynamic>> deleteVideoComment({
    required int vcid,
  }) async {
    return request(
      'comment',
      'delete_video_comment',
      {
        'vcid': vcid.toString(),
        'token': getToken(),
      },
    );
  }

  // 获取用户动态列表
  static Future<Map<String, dynamic>> getUserBlogList({
    required int uid,
    int offset = 0,
    int num = 10,
  }) async {
    return request(
      'blog',
      'user_blog_list',
      {
        'uid': uid.toString(),
        'offset': offset.toString(),
        'num': num.toString(),
      },
    );
  }
}
