import 'dart:collection';
import 'package:piliotto/ottohub/api/models/danmaku.dart';
import 'package:piliotto/ottohub/api/services/danmaku_service.dart';
import 'package:piliotto/services/loggeer.dart';

class PlDanmakuController {
  final int vid;
  final Function(List<Danmaku>)? onLoaded;

  PlDanmakuController({
    required this.vid,
    this.onLoaded,
  });

  static final Set<int> _loadingVids = {};
  static final Map<int, List<Danmaku>> _cachedDanmaku = {};

  SplayTreeMap<int, List<Danmaku>> _danmakuMap = SplayTreeMap();
  bool _loaded = false;
  bool _loading = false;

  SplayTreeMap<int, List<Danmaku>> get danmakuMap => _danmakuMap;
  bool get loaded => _loaded;
  bool get initiated => _loaded;

  void initiate(int videoDuration, int progress) async {
    if (_loaded || _loading) return;
    if (_loadingVids.contains(vid)) return;

    _loading = true;
    _loadingVids.add(vid);
    await queryDanmaku();
  }

  Future<void> queryDanmaku() async {
    if (_cachedDanmaku.containsKey(vid)) {
      _danmakuMap = _mapDanmaku(_cachedDanmaku[vid]!);
      _loaded = true;
      _loading = false;
      _loadingVids.remove(vid);
      onLoaded?.call(_cachedDanmaku[vid]!);
      return;
    }

    getLogger().d('开始获取弹幕，vid: $vid');
    try {
      final response = await DanmakuService.getDanmakus(vid);
      getLogger().d('获取到弹幕数量: ${response.length}');
      _cachedDanmaku[vid] = response;
      _danmakuMap = _mapDanmaku(response);
      getLogger().d('弹幕映射完成，共 ${_danmakuMap.length} 个时间点');
      _loaded = true;
      onLoaded?.call(response);
    } catch (e) {
      getLogger().e('获取弹幕失败: $e');
    } finally {
      _loading = false;
      _loadingVids.remove(vid);
    }
  }

  SplayTreeMap<int, List<Danmaku>> _mapDanmaku(List<Danmaku> danmakuList) {
    final map = SplayTreeMap<int, List<Danmaku>>();
    for (final danmaku in danmakuList) {
      final timeKey = danmaku.time.toInt();
      map.putIfAbsent(timeKey, () => []).add(danmaku);
    }
    return map;
  }

  List<Danmaku>? getCurrentDanmaku(int progress) {
    if (!_loaded) {
      if (!_loading && !_loadingVids.contains(vid)) {
        queryDanmaku();
      }
      return null;
    }
    return _danmakuMap[progress];
  }

  void clear() {
    _danmakuMap.clear();
    _loaded = false;
    _loading = false;
    _loadingVids.remove(vid);
  }

  static void clearCache(int vid) {
    _cachedDanmaku.remove(vid);
    _loadingVids.remove(vid);
  }

  static void clearAllCache() {
    _cachedDanmaku.clear();
    _loadingVids.clear();
  }
}
