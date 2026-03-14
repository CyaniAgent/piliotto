/// HTML 相关 API - Ottohub 不支持
class HtmlHttp {
  // 动态HTML
  static Future reqHtml(id, dynamicType) async {
    return {'status': false, 'msg': 'Ottohub API 不支持动态功能'};
  }

  // 专栏HTML
  static Future reqReadHtml(id, dynamicType) async {
    return {'status': false, 'msg': 'Ottohub API 不支持专栏功能'};
  }
}
