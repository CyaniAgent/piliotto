import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:piliotto/utils/storage.dart';
import 'package:piliotto/services/loggeer.dart';

class NotLoggedInException implements Exception {
  final String message;
  NotLoggedInException([this.message = '请先登录']);

  @override
  String toString() => message;
}

class LegacyApiService {
  static const String baseUrl = 'https://api.ottohub.cn';
  static const String _tokenKey = 'ottohub_token';

  static String? getToken() {
    return GStrorage.setting.get(_tokenKey);
  }

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
    if (requireAuth) {
      requireLogin();
    }

    if (params.containsKey('token') && params['token'] == null) {
      final token = getToken();
      if (token != null) {
        params['token'] = token;
      }
    }

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

  static Future<Map<String, dynamic>> getVideoComments({
    required int vid,
    int parentVcid = 0,
    int offset = 0,
    int num = 12,
  }) async {
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

  static Future<Map<String, dynamic>> getUserDetail({required int uid}) async {
    return request(
      'user',
      'get_user_detail',
      {
        'uid': uid.toString(),
      },
    );
  }

  static Future<Map<String, dynamic>> getFollowStatus(
      {required int followingUid}) async {
    final token = getToken();
    if (token == null || token.isEmpty) {
      return {
        'status': 'success',
        'follow_status': 0,
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

  static Future<Map<String, dynamic>> getFollowingList({
    required int uid,
    int offset = 0,
    int num = 18,
  }) async {
    final token = getToken();
    return request(
      'following',
      'following_list',
      {
        'uid': uid.toString(),
        'offset': offset.toString(),
        'num': num.toString(),
        'token': token ?? '',
      },
    );
  }

  static Future<Map<String, dynamic>> followUser(
      {required int followingUid}) async {
    return request(
      'following',
      'follow',
      {
        'following_uid': followingUid.toString(),
        'token': null,
      },
      requireAuth: true,
    );
  }

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

  static Future<Map<String, dynamic>> getUserProfile() async {
    return request(
      'profile',
      'user_profile',
      {
        'token': null,
      },
      requireAuth: true,
    );
  }

  static Future<Map<String, dynamic>> likeVideo({
    required int vid,
  }) async {
    return request(
      'engagement',
      'like_video',
      {
        'vid': vid.toString(),
        'token': null,
      },
      requireAuth: true,
    );
  }

  static Future<Map<String, dynamic>> favoriteVideo({
    required int vid,
  }) async {
    return request(
      'engagement',
      'favorite_video',
      {
        'vid': vid.toString(),
        'token': null,
      },
      requireAuth: true,
    );
  }

  static Future<Map<String, dynamic>> getUserVideoList({
    required int uid,
    int offset = 0,
    int num = 20,
  }) async {
    return request(
      'video',
      'user_video_list',
      {
        'uid': uid.toString(),
        'offset': offset.toString(),
        'num': num.toString(),
      },
    );
  }

  static Future<Map<String, dynamic>> getManageVideoList({
    int offset = 0,
    int num = 20,
  }) async {
    return request(
      'profile',
      'manage_video_list',
      {
        'offset': offset.toString(),
        'num': num.toString(),
        'token': null,
      },
      requireAuth: true,
    );
  }

  static Future<Map<String, dynamic>> deleteVideo({
    required int vid,
  }) async {
    return request(
      'manage',
      'delete_video',
      {
        'vid': vid.toString(),
        'token': null,
      },
      requireAuth: true,
    );
  }
}
