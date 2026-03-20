import 'package:piliotto/api/models/danmaku.dart';
import 'package:piliotto/api/services/danmaku_service.dart';

class PlDanmakuController {
  PlDanmakuController(this.vid);
  final int vid;
  Map<int, List<Danmaku>> dmSegMap = {};
  bool _loaded = false;

  bool get initiated => _loaded;

  void initiate(int videoDuration, int progress) async {
    if (!_loaded) {
      await queryDanmaku();
    }
  }

  void dispose() {
    dmSegMap.clear();
    _loaded = false;
  }

  Future<void> queryDanmaku() async {
    try {
      final List<Danmaku> danmakus = await DanmakuService.getDanmakus(vid);
      for (var danmaku in danmakus) {
        int pos = (danmaku.time * 10).toInt();
        if (dmSegMap[pos] == null) {
          dmSegMap[pos] = [];
        }
        dmSegMap[pos]!.add(danmaku);
      }
      _loaded = true;
    } catch (e) {
      // 错误处理
    }
  }

  List<Danmaku>? getCurrentDanmaku(int progress) {
    if (!_loaded) {
      queryDanmaku();
      return null;
    }
    int pos = (progress / 100).toInt();
    return dmSegMap[pos];
  }
}
