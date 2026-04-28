import 'package:piliotto/ottohub/models/dynamics/result.dart';
import 'base_repository.dart';

abstract class IDynamicsRepository {
  Future<List<DynamicItemModel>> getNewBlogs({int offset = 0, int num = 10});
  Future<List<DynamicItemModel>> getPopularBlogs({int timeLimit = 7, int offset = 0, int num = 10});
  Future<Map<String, dynamic>> getBlogDetail({required int bid, CacheConfig? cacheConfig});
  Future<List<DynamicItemModel>> getRelatedBlogs({required int bid, int offset = 0, int num = 10});
  Future<List<DynamicItemModel>> getUserBlogs({required int uid, int offset = 0, int num = 10});
  Future<Map<String, dynamic>> likeBlog({required int bid});
  Future<Map<String, dynamic>> favoriteBlog({required int bid});
}
