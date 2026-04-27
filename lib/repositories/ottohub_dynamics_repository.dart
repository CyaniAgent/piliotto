import '../api/services/legacy_api_service.dart';
import '../models/dynamics/result.dart';
import 'base_repository.dart';
import 'i_dynamics_repository.dart';

class OttohubDynamicsRepository extends BaseRepository implements IDynamicsRepository {
  @override
  Future<List<DynamicItemModel>> getNewBlogs(
      {int offset = 0, int num = 10}) async {
    final res = await LegacyApiService.getNewBlogList(offset: offset, num: num);
    if (res['status'] == 'success') {
      final List<dynamic> blogList = res['blog_list'] as List;
      return blogList.map((blog) => DynamicItemModel.fromJson(blog)).toList();
    }
    throw Exception(res['message'] ?? '获取最新动态失败');
  }

  @override
  Future<List<DynamicItemModel>> getPopularBlogs(
      {int timeLimit = 7, int offset = 0, int num = 10}) async {
    final res = await LegacyApiService.getPopularBlogList(
        timeLimit: timeLimit, offset: offset, num: num);
    if (res['status'] == 'success') {
      final List<dynamic> blogList = res['blog_list'] as List;
      return blogList.map((blog) => DynamicItemModel.fromJson(blog)).toList();
    }
    throw Exception(res['message'] ?? '获取热门动态失败');
  }

  @override
  Future<Map<String, dynamic>> getBlogDetail(
      {required int bid, CacheConfig? cacheConfig}) {
    return withCache(
      'getBlogDetail_$bid',
      () => LegacyApiService.getBlogDetail(bid: bid),
      cacheConfig:
          cacheConfig ?? const CacheConfig(duration: Duration(minutes: 2)),
    );
  }

  @override
  Future<List<DynamicItemModel>> getRelatedBlogs(
      {required int bid, int offset = 0, int num = 10}) async {
    final res = await LegacyApiService.getRelatedBlogList(
        bid: bid, offset: offset, num: num);
    if (res['status'] == 'success') {
      final List<dynamic> blogList = res['blog_list'] as List? ?? [];
      return blogList.map((blog) => DynamicItemModel.fromJson(blog)).toList();
    }
    throw Exception(res['message'] ?? '获取相关动态失败');
  }

  @override
  Future<List<DynamicItemModel>> getUserBlogs(
      {required int uid, int offset = 0, int num = 10}) async {
    final res = await LegacyApiService.getUserBlogList(
        uid: uid, offset: offset, num: num);
    if (res['status'] == 'success') {
      final List<dynamic> blogList = res['blog_list'] as List? ?? [];
      return blogList.map((blog) => DynamicItemModel.fromJson(blog)).toList();
    }
    throw Exception(res['message'] ?? '获取用户动态失败');
  }

  @override
  Future<Map<String, dynamic>> likeBlog({required int bid}) {
    invalidateCache('getBlogDetail_$bid');
    return LegacyApiService.likeBlog(bid: bid);
  }

  @override
  Future<Map<String, dynamic>> favoriteBlog({required int bid}) {
    invalidateCache('getBlogDetail_$bid');
    return LegacyApiService.favoriteBlog(bid: bid);
  }
}
