import '../services/api_service.dart';
import '../models/moderation.dart';

class ModerationService {
  static const String baseEndpoint = '/moderation';

  // 获取视频审核列表
  static Future<VideoModerationList> getVideoModerationList({
    int offset = 0,
    int num = 20,
  }) async {
    final response = await ApiService.request(
      '$baseEndpoint/videos',
      queryParams: {
        'offset': offset,
        'num': num,
      },
    );
    return VideoModerationList.fromJson(response['data']);
  }

  // 获取动态审核列表
  static Future<BlogModerationList> getBlogModerationList({
    int offset = 0,
    int num = 20,
  }) async {
    final response = await ApiService.request(
      '$baseEndpoint/blogs',
      queryParams: {
        'offset': offset,
        'num': num,
      },
    );
    return BlogModerationList.fromJson(response['data']);
  }

  // 获取头像审核列表
  static Future<AvatarModerationList> getAvatarModerationList({
    int offset = 0,
    int num = 20,
  }) async {
    final response = await ApiService.request(
      '$baseEndpoint/avatars',
      queryParams: {
        'offset': offset,
        'num': num,
      },
    );
    return AvatarModerationList.fromJson(response['data']);
  }

  // 获取封面审核列表
  static Future<CoverModerationList> getCoverModerationList({
    int offset = 0,
    int num = 20,
  }) async {
    final response = await ApiService.request(
      '$baseEndpoint/covers',
      queryParams: {
        'offset': offset,
        'num': num,
      },
    );
    return CoverModerationList.fromJson(response['data']);
  }

  // 获取弹幕审核列表
  static Future<DanmakuModerationList> getDanmakuModerationList({
    int offset = 0,
    int num = 20,
  }) async {
    final response = await ApiService.request(
      '$baseEndpoint/danmakus',
      queryParams: {
        'offset': offset,
        'num': num,
      },
    );
    return DanmakuModerationList.fromJson(response['data']);
  }

  // 获取视频评论审核列表
  static Future<VideoCommentModerationList> getVideoCommentModerationList({
    int offset = 0,
    int num = 20,
  }) async {
    final response = await ApiService.request(
      '$baseEndpoint/video-comments',
      queryParams: {
        'offset': offset,
        'num': num,
      },
    );
    return VideoCommentModerationList.fromJson(response['data']);
  }

  // 获取动态评论审核列表
  static Future<BlogCommentModerationList> getBlogCommentModerationList({
    int offset = 0,
    int num = 20,
  }) async {
    final response = await ApiService.request(
      '$baseEndpoint/blog-comments',
      queryParams: {
        'offset': offset,
        'num': num,
      },
    );
    return BlogCommentModerationList.fromJson(response['data']);
  }

  // 获取未读审核结果数量
  static Future<UnreadCountResponse> getUnreadCount({
    int? isAdmin,
    int? isAudit,
  }) async {
    final queryParams = {
      'is_admin': isAdmin,
      'is_audit': isAudit,
    }..removeWhere((key, value) => value == null);

    final response = await ApiService.request(
      '$baseEndpoint/logs/unread-count',
      queryParams: queryParams,
    );
    return UnreadCountResponse.fromJson(response['data']);
  }

  // 获取审核日志列表
  static Future<LogsResponse> getModerationLogs({
    int offset = 0,
    int num = 20,
    String? auditType,
    int? action,
    int? isRead,
    int? isAdmin,
    int? isAudit,
  }) async {
    final queryParams = {
      'offset': offset,
      'num': num,
      'audit_type': auditType,
      'action': action,
      'is_read': isRead,
      'is_admin': isAdmin,
      'is_audit': isAudit,
    }..removeWhere((key, value) => value == null);

    final response = await ApiService.request(
      '$baseEndpoint/logs',
      queryParams: queryParams,
    );
    return LogsResponse.fromJson(response['data']);
  }

  // 通过视频
  static Future<void> approveVideo({
    required int vid,
  }) async {
    await ApiService.request(
      '$baseEndpoint/videos/$vid/approve',
      method: 'PUT',
    );
  }

  // 通过动态
  static Future<void> approveBlog({
    required int bid,
  }) async {
    await ApiService.request(
      '$baseEndpoint/blogs/$bid/approve',
      method: 'PUT',
    );
  }

  // 通过头像
  static Future<void> approveAvatar({
    required int uid,
  }) async {
    await ApiService.request(
      '$baseEndpoint/avatars/$uid/approve',
      method: 'PUT',
    );
  }

  // 通过封面
  static Future<void> approveCover({
    required int uid,
  }) async {
    await ApiService.request(
      '$baseEndpoint/covers/$uid/approve',
      method: 'PUT',
    );
  }

  // 通过弹幕
  static Future<void> approveDanmaku({
    required int danmakuId,
  }) async {
    await ApiService.request(
      '$baseEndpoint/danmakus/$danmakuId/approve',
      method: 'PUT',
    );
  }

  // 通过视频评论
  static Future<void> approveVideoComment({
    required int vcid,
  }) async {
    await ApiService.request(
      '$baseEndpoint/video-comments/$vcid/approve',
      method: 'PUT',
    );
  }

  // 通过动态评论
  static Future<void> approveBlogComment({
    required int bcid,
  }) async {
    await ApiService.request(
      '$baseEndpoint/blog-comments/$bcid/approve',
      method: 'PUT',
    );
  }

  // 驳回视频
  static Future<void> rejectVideo({
    required int vid,
    required String reason,
  }) async {
    await ApiService.request(
      '$baseEndpoint/videos/$vid/reject',
      method: 'PUT',
      body: {
        'reason': reason,
      },
    );
  }

  // 驳回动态
  static Future<void> rejectBlog({
    required int bid,
    required String reason,
  }) async {
    await ApiService.request(
      '$baseEndpoint/blogs/$bid/reject',
      method: 'PUT',
      body: {
        'reason': reason,
      },
    );
  }

  // 驳回头像
  static Future<void> rejectAvatar({
    required int uid,
    required String reason,
  }) async {
    await ApiService.request(
      '$baseEndpoint/avatars/$uid/reject',
      method: 'PUT',
      body: {
        'reason': reason,
      },
    );
  }

  // 驳回封面
  static Future<void> rejectCover({
    required int uid,
    required String reason,
  }) async {
    await ApiService.request(
      '$baseEndpoint/covers/$uid/reject',
      method: 'PUT',
      body: {
        'reason': reason,
      },
    );
  }

  // 驳回弹幕
  static Future<void> rejectDanmaku({
    required int danmakuId,
    required String reason,
  }) async {
    await ApiService.request(
      '$baseEndpoint/danmakus/$danmakuId/reject',
      method: 'PUT',
      body: {
        'reason': reason,
      },
    );
  }

  // 驳回视频评论
  static Future<void> rejectVideoComment({
    required int vcid,
    required String reason,
  }) async {
    await ApiService.request(
      '$baseEndpoint/video-comments/$vcid/reject',
      method: 'PUT',
      body: {
        'reason': reason,
      },
    );
  }

  // 驳回动态评论
  static Future<void> rejectBlogComment({
    required int bcid,
    required String reason,
  }) async {
    await ApiService.request(
      '$baseEndpoint/blog-comments/$bcid/reject',
      method: 'PUT',
      body: {
        'reason': reason,
      },
    );
  }

  // 举报视频
  static Future<void> reportVideo({
    required int vid,
    required String reason,
  }) async {
    await ApiService.request(
      '$baseEndpoint/videos/$vid/report',
      method: 'POST',
      body: {
        'reason': reason,
      },
    );
  }

  // 举报动态
  static Future<void> reportBlog({
    required int bid,
    required String reason,
  }) async {
    await ApiService.request(
      '$baseEndpoint/blogs/$bid/report',
      method: 'POST',
      body: {
        'reason': reason,
      },
    );
  }

  // 举报头像
  static Future<void> reportAvatar({
    required int uid,
    required String reason,
  }) async {
    await ApiService.request(
      '$baseEndpoint/avatars/$uid/report',
      method: 'POST',
      body: {
        'reason': reason,
      },
    );
  }

  // 举报封面
  static Future<void> reportCover({
    required int uid,
    required String reason,
  }) async {
    await ApiService.request(
      '$baseEndpoint/covers/$uid/report',
      method: 'POST',
      body: {
        'reason': reason,
      },
    );
  }

  // 举报弹幕
  static Future<void> reportDanmaku({
    required int danmakuId,
    required String reason,
  }) async {
    await ApiService.request(
      '$baseEndpoint/danmakus/$danmakuId/report',
      method: 'POST',
      body: {
        'reason': reason,
      },
    );
  }

  // 举报视频评论
  static Future<void> reportVideoComment({
    required int vcid,
    required String reason,
  }) async {
    await ApiService.request(
      '$baseEndpoint/video-comments/$vcid/report',
      method: 'POST',
      body: {
        'reason': reason,
      },
    );
  }

  // 举报动态评论
  static Future<void> reportBlogComment({
    required int bcid,
    required String reason,
  }) async {
    await ApiService.request(
      '$baseEndpoint/blog-comments/$bcid/report',
      method: 'POST',
      body: {
        'reason': reason,
      },
    );
  }

  // 申诉视频
  static Future<void> appealVideo({
    required int vid,
    required String reason,
  }) async {
    await ApiService.request(
      '$baseEndpoint/videos/$vid/appeal',
      method: 'POST',
      body: {
        'reason': reason,
      },
    );
  }

  // 申诉动态
  static Future<void> appealBlog({
    required int bid,
    required String reason,
  }) async {
    await ApiService.request(
      '$baseEndpoint/blogs/$bid/appeal',
      method: 'POST',
      body: {
        'reason': reason,
      },
    );
  }

  // 申诉头像
  static Future<void> appealAvatar({
    required int uid,
    required String reason,
  }) async {
    await ApiService.request(
      '$baseEndpoint/avatars/$uid/appeal',
      method: 'POST',
      body: {
        'reason': reason,
      },
    );
  }

  // 申诉封面
  static Future<void> appealCover({
    required int uid,
    required String reason,
  }) async {
    await ApiService.request(
      '$baseEndpoint/covers/$uid/appeal',
      method: 'POST',
      body: {
        'reason': reason,
      },
    );
  }

  // 申诉弹幕
  static Future<void> appealDanmaku({
    required int danmakuId,
    required String reason,
  }) async {
    await ApiService.request(
      '$baseEndpoint/danmakus/$danmakuId/appeal',
      method: 'POST',
      body: {
        'reason': reason,
      },
    );
  }

  // 申诉视频评论
  static Future<void> appealVideoComment({
    required int vcid,
    required String reason,
  }) async {
    await ApiService.request(
      '$baseEndpoint/video-comments/$vcid/appeal',
      method: 'POST',
      body: {
        'reason': reason,
      },
    );
  }

  // 申诉动态评论
  static Future<void> appealBlogComment({
    required int bcid,
    required String reason,
  }) async {
    await ApiService.request(
      '$baseEndpoint/blog-comments/$bcid/appeal',
      method: 'POST',
      body: {
        'reason': reason,
      },
    );
  }
}
