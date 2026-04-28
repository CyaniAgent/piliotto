import '../api/services/legacy_api_service.dart';
import '../api/services/video_service.dart';
import '../api/models/video.dart';
import '../models/member/archive.dart';
import 'package:piliotto/repositories/base_repository.dart';
import 'package:piliotto/repositories/i_video_repository.dart';

class OttohubVideoRepository extends BaseRepository implements IVideoRepository {
  @override
  Future<VideoListResponse> getRandomVideos({int num = 20}) {
    return withCache(
      'getRandomVideos',
      () => VideoService.getRandomVideos(num: num),
    );
  }

  @override
  Future<VideoListResponse> getPopularVideos({
    int timeLimit = 7,
    int offset = 0,
    int num = 20,
  }) {
    return withCache(
      'getPopularVideos_${timeLimit}_$offset',
      () => VideoService.getPopularVideos(
        timeLimit: timeLimit,
        offset: offset,
        num: num,
      ),
    );
  }

  @override
  Future<VideoListResponse> searchVideos({
    String? searchTerm,
    int offset = 0,
    int num = 20,
    int vidDesc = 0,
    int viewCountDesc = 0,
    int likeCountDesc = 0,
    int favoriteCountDesc = 0,
    int? uid,
    String? type,
  }) {
    return VideoService.searchVideos(
      searchTerm: searchTerm,
      offset: offset,
      num: num,
      vidDesc: vidDesc,
      viewCountDesc: viewCountDesc,
      likeCountDesc: likeCountDesc,
      favoriteCountDesc: favoriteCountDesc,
      uid: uid,
      type: type,
    );
  }

  @override
  Future<Video> getVideoDetail(int vid, {CacheConfig? cacheConfig}) {
    return withCache(
      'getVideoDetail_$vid',
      () => VideoService.getVideoDetail(vid),
      cacheConfig:
          cacheConfig ?? const CacheConfig(duration: Duration(minutes: 2)),
    );
  }

  @override
  Future<VideoListResponse> getRelatedVideos(int vid,
      {int num = 20, int offset = 0}) {
    return withCache(
      'getRelatedVideos_${vid}_$offset',
      () => VideoService.getRelatedVideos(vid, num: num, offset: offset),
    );
  }

  @override
  Future<VideoListResponse> getFavoriteVideos({int offset = 0, int num = 20}) {
    return VideoService.getFavoriteVideos(offset: offset, num: num);
  }

  @override
  Future<VideoListResponse> getManageVideos({int offset = 0, int num = 20}) {
    return VideoService.getManageVideos(offset: offset, num: num);
  }

  @override
  Future<VideoListResponse> getHistoryVideos() {
    return VideoService.getHistoryVideos();
  }

  @override
  Future<VideoListResponse> getUserVideos(int uid,
      {int offset = 0, int num = 20}) {
    return VideoService.getUserVideos(uid, offset: offset, num: num);
  }

  @override
  Future<VideoActionResponse> toggleLike({required int vid}) {
    invalidateCache('getVideoDetail_$vid');
    return VideoService.toggleLike(vid: vid);
  }

  @override
  Future<VideoActionResponse> toggleFavorite({required int vid}) {
    invalidateCache('getVideoDetail_$vid');
    return VideoService.toggleFavorite(vid: vid);
  }

  @override
  Future<void> saveWatchHistory(
      {required int vid, required int lastWatchSecond}) {
    return VideoService.saveWatchHistory(
        vid: vid, lastWatchSecond: lastWatchSecond);
  }

  @override
  Future<void> deleteVideo({required int vid}) {
    invalidateCache('getVideoDetail_$vid');
    return VideoService.deleteVideo(vid: vid);
  }

  @override
  Future<List<VListItemModel>> getUserVideoList(
      {required int uid, int offset = 0, int num = 20}) async {
    final res = await LegacyApiService.getUserVideoList(
        uid: uid, offset: offset, num: num);
    if (res['status'] == 'success') {
      final List<dynamic> videoList = res['video_list'] as List;
      return videoList.map((v) => VListItemModel.fromJson(v)).toList();
    }
    throw Exception(res['message'] ?? '获取用户视频失败');
  }
}
