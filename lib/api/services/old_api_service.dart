import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../utils/storage.dart';
import '../../services/loggeer.dart';

class NotLoggedInException implements Exception {
  final String message;
  NotLoggedInException([this.message = '请先登录']);

  @override
  String toString() => message;
}

class OldApiService {
  static const String baseUrl = 'https://api.ottohub.cn';
  static const String _tokenKey = 'ottohub_token';

  // 获取token
  static String? getToken() {
    return GStrorage.setting.get(_tokenKey);
  }

  // 检查是否登录
  static void requireLogin() {
    final token = getToken();
    if (token == null || token.isEmpty) {
      throw NotLoggedInException('请先登录 Ottohub 账号');
    }
  }

  static Future<Map<String, dynamic>> request(
    String module,
    String action,
    Map<String, dynamic> params, {
    bool requireAuth = false,
  }) async {
    // 如果需要认证，检查是否登录
    if (requireAuth) {
      requireLogin();
    }

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

  // 获取关注状态（需要登录）
  static Future<Map<String, dynamic>> getFollowStatus(
      {required int followingUid}) async {
    // 如果没有登录，返回默认的未关注状态
    final token = getToken();
    if (token == null || token.isEmpty) {
      return {
        'status': 'success',
        'data': {
          'follow_status': 1, // 互相未关注
        },
      };
    }

    return request(
      'following',
      'follow_status',
      {
        'following_uid': followingUid.toString(),
        'token': token,
      },
    );
  }

  // 关注/取关用户（需要登录）
  static Future<Map<String, dynamic>> followUser(
      {required int followingUid}) async {
    return request(
      'following',
      'follow',
      {
        'following_uid': followingUid.toString(),
        'token': null, // 自动添加token
      },
      requireAuth: true,
    );
  }

  // 评论视频（需要登录）
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
        'token': null,
      },
      requireAuth: true,
    );
  }

  // 删除视频评论（需要登录）
  static Future<Map<String, dynamic>> deleteVideoComment({
    required int vcid,
  }) async {
    return request(
      'comment',
      'delete_video_comment',
      {
        'vcid': vcid.toString(),
        'token': null,
      },
      requireAuth: true,
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

  // 获取最新动态列表
  static Future<Map<String, dynamic>> getNewBlogList({
    int offset = 0,
    int num = 10,
  }) async {
    return request(
      'blog',
      'new_blog_list',
      {
        'offset': offset.toString(),
        'num': num.toString(),
      },
    );
  }

  // 获取热门动态列表
  static Future<Map<String, dynamic>> getPopularBlogList({
    int timeLimit = 7,
    int offset = 0,
    int num = 10,
  }) async {
    return request(
      'blog',
      'popular_blog_list',
      {
        'time_limit': timeLimit.toString(),
        'offset': offset.toString(),
        'num': num.toString(),
      },
    );
  }

  // 获取动态详情
  static Future<Map<String, dynamic>> getBlogDetail({
    required int bid,
  }) async {
    final token = getToken();
    return request(
      'blog',
      'get_blog_detail',
      {
        'bid': bid.toString(),
        if (token != null) 'token': token,
      },
    );
  }

  // 获取相关动态列表
  static Future<Map<String, dynamic>> getRelatedBlogList({
    required int bid,
    int offset = 0,
    int num = 10,
  }) async {
    return request(
      'blog',
      'related_blog_list',
      {
        'bid': bid.toString(),
        'offset': offset.toString(),
        'num': num.toString(),
      },
    );
  }

  // 点赞动态（需要登录）
  static Future<Map<String, dynamic>> likeBlog({
    required int bid,
  }) async {
    return request(
      'engagement',
      'like_blog',
      {
        'bid': bid.toString(),
        'token': null,
      },
      requireAuth: true,
    );
  }

  // 收藏动态（需要登录）
  static Future<Map<String, dynamic>> favoriteBlog({
    required int bid,
  }) async {
    return request(
      'engagement',
      'favorite_blog',
      {
        'bid': bid.toString(),
        'token': null,
      },
      requireAuth: true,
    );
  }

  // 获取动态评论列表
  static Future<Map<String, dynamic>> getBlogCommentList({
    required int bid,
    int parentBcid = 0,
    int offset = 0,
    int num = 12,
  }) async {
    final token = getToken();
    return request(
      'comment',
      'blog_comment_list',
      {
        'bid': bid.toString(),
        'parent_bcid': parentBcid.toString(),
        'offset': offset.toString(),
        'num': num.toString(),
        if (token != null) 'token': token,
      },
    );
  }

  // 评论动态（需要登录）
  static Future<Map<String, dynamic>> commentBlog({
    required int bid,
    int parentBcid = 0,
    required String content,
  }) async {
    return request(
      'comment',
      'comment_blog',
      {
        'bid': bid.toString(),
        'parent_bcid': parentBcid.toString(),
        'content': content,
        'token': null,
      },
      requireAuth: true,
    );
  }

  // 获取视频历史记录
  static Future<Map<String, dynamic>> getVideoHistory() async {
    return request(
      'profile',
      'history_video_list',
      {
        'token': null,
      },
      requireAuth: true,
    );
  }

  // 获取收藏视频列表
  static Future<Map<String, dynamic>> getFavoriteVideoList({
    int offset = 0,
    int num = 20,
  }) async {
    return request(
      'profile',
      'favorite_video_list',
      {
        'offset': offset.toString(),
        'num': num.toString(),
        'token': null,
      },
      requireAuth: true,
    );
  }

  // 获取收藏动态列表
  static Future<Map<String, dynamic>> getFavoriteBlogList({
    int offset = 0,
    int num = 20,
  }) async {
    return request(
      'profile',
      'favorite_blog_list',
      {
        'offset': offset.toString(),
        'num': num.toString(),
        'token': null,
      },
      requireAuth: true,
    );
  }
}
