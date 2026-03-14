/// 收藏夹相关 API - Ottohub 不支持
class FavHttp {
  // 编辑收藏夹
  static Future editFolder({
    required String title,
    required String intro,
    required String mediaId,
    String? cover,
    int? privacy,
  }) async {
    return {'status': false, 'msg': 'Ottohub API 不支持编辑收藏夹功能'};
  }

  // 新建收藏夹
  static Future addFolder({
    required String title,
    required String intro,
    String? cover,
    int? privacy,
  }) async {
    return {'status': false, 'msg': 'Ottohub API 不支持新建收藏夹功能'};
  }
}
