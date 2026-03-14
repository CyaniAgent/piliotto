class DynamicsHttp {
  // 关注动态
  static Future followDynamic({
    String? type,
    int? page,
    String? offset,
    int? mid,
  }) async {
    return {'status': false, 'data': [], 'msg': 'Ottohub API 不支持动态功能'};
  }

  // 关注UP
  static Future followUp() async {
    return {'status': false, 'data': [], 'msg': 'Ottohub API 不支持动态功能'};
  }

  // 动态点赞
  static Future likeDynamic({
    required String? dynamicId,
    required int? up,
  }) async {
    return {'status': false, 'msg': 'Ottohub API 不支持动态点赞功能'};
  }

  // 动态详情
  static Future dynamicDetail({String? id}) async {
    return {'status': false, 'data': [], 'msg': 'Ottohub API 不支持动态详情功能'};
  }

  // 动态转发
  static Future dynamicForward() async {
    return {'status': false, 'msg': 'Ottohub API 不支持动态转发功能'};
  }

  // 创建动态
  static Future dynamicCreate({
    required int mid,
    required int scene,
    int? oid,
    String? dynIdStr,
    String? rawText,
  }) async {
    return {'status': false, 'msg': 'Ottohub API 不支持创建动态功能'};
  }
}
