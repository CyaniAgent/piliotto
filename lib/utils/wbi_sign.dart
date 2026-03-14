/// WBI 签名 - Ottohub 不需要
class WbiSign {
  // Ottohub 不需要 WBI 签名
  static Future<Map<String, dynamic>> getWbiKeys() async {
    return {'imgKey': '', 'subKey': ''};
  }

  Future<Map<String, dynamic>> makSign(Map<String, dynamic> params) async {
    return params;
  }
}
