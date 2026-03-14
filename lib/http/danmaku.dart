/// 弹幕相关 API - Ottohub 不支持
class DanmakaHttp {
  // 获取视频弹幕
  static Future queryDanmaku({
    required int cid,
    required int segmentIndex,
  }) async {
    throw UnimplementedError('Ottohub API 不支持弹幕功能');
  }

  // 发送弹幕
  static Future shootDanmaku({
    int type = 1,
    required int oid,
    required String msg,
    int mode = 1,
    required String bvid,
    int? progress,
    int? color,
    int? fontsize,
    int? pool,
    int? colorful,
    int? checkboxType,
  }) async {
    return {'status': false, 'msg': 'Ottohub API 不支持弹幕功能'};
  }
}
