import '../api/services/following_service.dart';

class FollowHttp {
  // 关注列表
  static Future followings({int? vmid, int? pn, int? ps, String? orderType}) async {
    try {
      final response = await FollowingService.getFollowingList(
        uid: vmid!,
        offset: (pn! - 1) * (ps ?? 12),
        num: ps ?? 12,
      );
      return {'status': true, 'data': response};
    } catch (err) {
      return {'status': false, 'data': [], 'msg': err.toString()};
    }
  }
}
