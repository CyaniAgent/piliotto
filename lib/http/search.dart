class SearchHttp {
  // bvid 转 cid（Ottohub 使用 vid）
  static Future<int> ab2c({int? aid, String? bvid}) async {
    return -1;
  }
  
  // bvid 转 cid 和 pic（Ottohub 使用 vid）
  static Future<Map<String, dynamic>> ab2cWithPic({String? bvid}) async {
    return {'cid': -1, 'pic': null};
  }
}
