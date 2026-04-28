import '../services/api_service.dart';
import '../models/video.dart';

class VideoService {
  static const String baseEndpoint = '/video';

  // 随机视频列表
  static Future<VideoListResponse> getRandomVideos({int num = 20}) async {
    final response = await ApiService.request(
      '$baseEndpoint/random',
      queryParams: {'num': num},
      requireToken: false,
    );
    return VideoListResponse.fromJson(response['data']);
  }

  // 最新视频列表
  static Future<VideoListResponse> getNewVideos({
    int offset = 0,
    int num = 20,
    String type = 'all',
  }) async {
    final response = await ApiService.request(
      '$baseEndpoint/new',
      queryParams: {
        'offset': offset,
        'num': num,
        'type': type,
      },
      requireToken: false,
    );
    return VideoListResponse.fromJson(response['data']);
  }

  // 热门视频列表
  static Future<VideoListResponse> getPopularVideos({
    int timeLimit = 7,
    int offset = 0,
    int num = 20,
  }) async {
    final response = await ApiService.request(
      '$baseEndpoint/popular',
      queryParams: {
        'time_limit': timeLimit,
        'offset': offset,
        'num': num,
      },
      requireToken: false,
    );
    return VideoListResponse.fromJson(response['data']);
  }

  // 分类视频列表
  static Future<VideoListResponse> getCategoryVideos(String category,
      {int num = 20}) async {
    final response = await ApiService.request(
      '$baseEndpoint/category/$category',
      queryParams: {'num': num},
      requireToken: false,
    );
    return VideoListResponse.fromJson(response['data']);
  }

  // 搜索视频列表
  static Future<VideoListResponse> searchVideos({
    String? searchTerm,
    int offset = 0,
    int num = 20,
    int vidDesc = 0,
    int viewCountDesc = 0,
    int likeCountDesc = 0,
    int favoriteCountDesc = 0,
    int? uid,
    String? type,
  }) async {
    final queryParams = {
      'search_term': searchTerm,
      'offset': offset,
      'num': num,
      'vid_desc': vidDesc,
      'view_count_desc': viewCountDesc,
      'like_count_desc': likeCountDesc,
      'favorite_count_desc': favoriteCountDesc,
      'uid': uid,
      'type': type,
    }..removeWhere((key, value) => value == null);

    final response = await ApiService.request(
      '$baseEndpoint/search',
      queryParams: queryParams,
      requireToken: false,
    );
    return VideoListResponse.fromJson(response['data']);
  }

  // 获取视频详情
  static Future<Video> getVideoDetail(int vid) async {
    final response = await ApiService.request(
      '$baseEndpoint/$vid',
    );
    return Video.fromJson(response['data']);
  }

  // 用户视频列表
  static Future<VideoListResponse> getUserVideos(
    int uid, {
    int offset = 0,
    int num = 20,
  }) async {
    final response = await ApiService.request(
      '$baseEndpoint/user/$uid',
      queryParams: {
        'offset': offset,
        'num': num,
      },
      requireToken: false,
    );
    return VideoListResponse.fromJson(response['data']);
  }

  // 相关视频列表
  static Future<VideoListResponse> getRelatedVideos(
    int vid, {
    int num = 20,
    int offset = 0,
  }) async {
    final response = await ApiService.request(
      '$baseEndpoint/related/$vid',
      queryParams: {
        'num': num,
        'offset': offset,
      },
      requireToken: false,
    );
    return VideoListResponse.fromJson(response['data']);
  }

  // 收藏视频列表
  static Future<VideoListResponse> getFavoriteVideos({
    int offset = 0,
    int num = 20,
  }) async {
    final response = await ApiService.request(
      '$baseEndpoint/favorite-list',
      queryParams: {
        'offset': offset,
        'num': num,
      },
      requireToken: true,
    );
    return VideoListResponse.fromJson(response['data']);
  }

  // 管理视频列表
  static Future<VideoListResponse> getManageVideos({
    int offset = 0,
    int num = 20,
  }) async {
    final response = await ApiService.request(
      '$baseEndpoint/manage-list',
      queryParams: {
        'offset': offset,
        'num': num,
      },
    );
    return VideoListResponse.fromJson(response['data']);
  }

  // 历史视频列表
  static Future<VideoListResponse> getHistoryVideos() async {
    final response = await ApiService.request(
      '$baseEndpoint/history-list',
    );
    return VideoListResponse.fromJson(response['data']);
  }

  // 保存视频观看历史
  static Future<void> saveWatchHistory({
    required int vid,
    required int lastWatchSecond,
  }) async {
    await ApiService.request(
      '$baseEndpoint/watch-history',
      method: 'POST',
      body: {
        'vid': vid,
        'last_watch_second': lastWatchSecond,
      },
    );
  }

  // 收藏/取消收藏视频
  static Future<VideoActionResponse> toggleFavorite({
    required int vid,
  }) async {
    final response = await ApiService.request(
      '$baseEndpoint/favorite/$vid',
      method: 'POST',
    );
    return VideoActionResponse.fromJson(response['data']);
  }

  // 点赞/取消点赞视频
  static Future<VideoActionResponse> toggleLike({
    required int vid,
  }) async {
    final response = await ApiService.request(
      '$baseEndpoint/like/$vid',
      method: 'POST',
    );
    return VideoActionResponse.fromJson(response['data']);
  }

  // 删除视频
  static Future<void> deleteVideo({
    required int vid,
  }) async {
    await ApiService.request(
      '$baseEndpoint/$vid',
      method: 'DELETE',
    );
  }

  // 投稿视频
  static Future<VideoSubmitResponse> submitVideo({
    required String title,
    required String intro,
    required int type,
    required int category,
    required String tag,
    required String fileMp4,
    required String fileJpg,
    int? channelId,
    int? channelSectionId,
  }) async {
    // 注意：这里需要处理文件上传，实际实现会更复杂
    final response = await ApiService.request(
      '$baseEndpoint/submit',
      method: 'POST',
      body: {
        'title': title,
        'intro': intro,
        'type': type,
        'category': category,
        'tag': tag,
        'file_mp4': fileMp4,
        'file_jpg': fileJpg,
        'channel_id': channelId,
        'channel_section_id': channelSectionId,
      }..removeWhere((key, value) => value == null),
    );
    return VideoSubmitResponse.fromJson(response['data']);
  }

  // 更新视频
  static Future<void> updateVideo({
    required int vid,
    String? title,
    String? intro,
    String? tag,
    int? category,
    String? fileJpg,
    String? fileMp4,
  }) async {
    // 注意：这里需要处理文件上传，实际实现会更复杂
    final body = {
      'title': title,
      'intro': intro,
      'tag': tag,
      'category': category,
      'file_jpg': fileJpg,
      'file_mp4': fileMp4,
    }..removeWhere((key, value) => value == null);

    await ApiService.request(
      '$baseEndpoint/update/$vid',
      method: 'POST',
      body: body,
    );
  }
}
