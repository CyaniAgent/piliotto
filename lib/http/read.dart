/// 专栏/文章相关 API - Ottohub 不支持
/// 所有专栏功能暂不可用
class ReadHttp {
  // 解析专栏 opus格式
  static Future parseArticleOpus({required String id}) async {
    return {'status': false, 'data': null, 'msg': 'Ottohub API 不支持专栏功能'};
  }

  // 解析专栏 cv格式
  static Future parseArticleCv({required String id}) async {
    return {'status': false, 'data': null, 'msg': 'Ottohub API 不支持专栏功能'};
  }

  // 获取视图信息
  static Future getViewInfo({required String id}) async {
    return {'status': false, 'data': null, 'msg': 'Ottohub API 不支持专栏功能'};
  }
}
