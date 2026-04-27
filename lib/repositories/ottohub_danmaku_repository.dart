import '../api/services/danmaku_service.dart';
import '../api/models/danmaku.dart';
import 'base_repository.dart';
import 'i_danmaku_repository.dart';

class OttohubDanmakuRepository extends BaseRepository implements IDanmakuRepository {
  @override
  Future<List<Danmaku>> getDanmakus(int vid, {CacheConfig? cacheConfig}) {
    return withCache(
      'getDanmakus_$vid',
      () => DanmakuService.getDanmakus(vid),
      cacheConfig:
          cacheConfig ?? const CacheConfig(duration: Duration(minutes: 5)),
    );
  }

  @override
  Future<void> sendDanmaku({
    required dynamic vid,
    required String text,
    required dynamic time,
    required String mode,
    required String color,
    required String fontSize,
    required String render,
  }) {
    invalidateCache('getDanmakus_$vid');
    return DanmakuService.sendDanmaku(
      vid: vid,
      text: text,
      time: time,
      mode: mode,
      color: color,
      fontSize: fontSize,
      render: render,
    );
  }

  @override
  Future<void> deleteDanmaku({required int danmakuId}) {
    return DanmakuService.deleteDanmaku(danmakuId: danmakuId);
  }
}
