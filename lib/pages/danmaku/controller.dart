import 'package:get/get.dart';
import 'package:piliotto/ottohub/api/models/danmaku.dart';
import 'package:piliotto/repositories/i_danmaku_repository.dart';
import 'package:piliotto/services/loggeer.dart';

class PlDanmakuController {
  PlDanmakuController(this.vid);
  final int vid;
  Map<int, List<Danmaku>> dmSegMap = {};
  bool _loaded = false;
  bool _loading = false;

  bool get initiated => _loaded;

  void initiate(int videoDuration, int progress) async {
    if (!_loaded && !_loading) {
      await queryDanmaku();
    }
  }

  void dispose() {
    dmSegMap.clear();
    _loaded = false;
    _loading = false;
  }

  Future<void> queryDanmaku() async {
    if (_loading) return;
    _loading = true;
    final logger = getLogger();
    try {
      logger.d('开始获取弹幕，vid: $vid');
      final List<Danmaku> danmakus = await Get.find<IDanmakuRepository>().getDanmakus(vid);
      logger.d('获取到弹幕数量: ${danmakus.length}');
      dmSegMap.clear();
      for (var danmaku in danmakus) {
        int pos = (danmaku.time * 10).toInt();
        if (dmSegMap[pos] == null) {
          dmSegMap[pos] = [];
        }
        dmSegMap[pos]!.add(danmaku);
      }
      _loaded = true;
      logger.d('弹幕映射完成，共 ${dmSegMap.length} 个时间点');
    } catch (e) {
      logger.e('获取弹幕失败: $e');
    } finally {
      _loading = false;
    }
  }

  List<Danmaku>? getCurrentDanmaku(int progress) {
    if (!_loaded) {
      if (!_loading) {
        queryDanmaku();
      }
      return null;
    }
    int pos = (progress / 100).toInt();
    return dmSegMap[pos];
  }
}
