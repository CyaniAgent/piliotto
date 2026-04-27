import '../api/models/danmaku.dart';
import 'base_repository.dart';

abstract class IDanmakuRepository {
  Future<List<Danmaku>> getDanmakus(int vid, {CacheConfig? cacheConfig});
  Future<void> sendDanmaku({required dynamic vid, required String text, required dynamic time, required String mode, required String color, required String fontSize, required String render});
  Future<void> deleteDanmaku({required int danmakuId});
}
