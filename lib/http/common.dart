/// 通用相关 API - Ottohub 不支持
class CommonHttp {
  // 未读动态
  static Future unReadDynamic() async {
    return {'status': false, 'data': [], 'msg': 'Ottohub API 不支持未读动态功能'};
  }
}
