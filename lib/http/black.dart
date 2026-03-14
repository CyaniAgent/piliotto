/// 黑名单相关 API - Ottohub 不支持
class BlackHttp {
  // 黑名单列表
  static Future blackList({required int pn, int? ps}) async {
    return {'status': false, 'data': [], 'msg': 'Ottohub API 不支持黑名单功能'};
  }

  // 移除黑名单
  static Future removeBlack({required int fid}) async {
    return {'status': false, 'msg': 'Ottohub API 不支持黑名单功能'};
  }
}
