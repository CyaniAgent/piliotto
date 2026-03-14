import '../api/services/following_service.dart';

class FanHttp {
  // 粉丝列表
  static Future fans({int? vmid, int? pn, int? ps, String? orderType}) async {
    try {
      final response = await FollowingService.getFansList(
        uid: vmid!,
        offset: (pn! - 1) * (ps ?? 20),
        num: ps ?? 20,
      );
      return {'status': true, 'data': response};
    } catch (err) {
      return {'status': false, 'data': [], 'msg': err.toString()};
    }
  }
}
