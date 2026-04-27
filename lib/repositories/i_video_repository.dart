import '../api/models/video.dart';
import '../models/member/archive.dart';
import 'base_repository.dart';

abstract class IVideoRepository {
  Future<VideoListResponse> getRandomVideos({int num = 20});
  Future<VideoListResponse> getPopularVideos({int timeLimit = 7, int offset = 0, int num = 20});
  Future<VideoListResponse> searchVideos({String? searchTerm, int offset = 0, int num = 20, int vidDesc = 0, int viewCountDesc = 0, int likeCountDesc = 0, int favoriteCountDesc = 0, int? uid, String? type});
  Future<Video> getVideoDetail(int vid, {CacheConfig? cacheConfig});
  Future<VideoListResponse> getRelatedVideos(int vid, {int num = 20, int offset = 0});
  Future<VideoListResponse> getFavoriteVideos({int offset = 0, int num = 20});
  Future<VideoListResponse> getManageVideos({int offset = 0, int num = 20});
  Future<VideoListResponse> getHistoryVideos();
  Future<VideoListResponse> getUserVideos(int uid, {int offset = 0, int num = 20});
  Future<List<VListItemModel>> getUserVideoList({required int uid, int offset = 0, int num = 20});
  Future<VideoActionResponse> toggleLike({required int vid});
  Future<VideoActionResponse> toggleFavorite({required int vid});
  Future<void> saveWatchHistory({required int vid, required int lastWatchSecond});
  Future<void> deleteVideo({required int vid});
}
