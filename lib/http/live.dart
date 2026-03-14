class LiveHttp {
  static Future liveList(
      {int? vmid, int? pn, int? ps, String? orderType}) async {
    return {'status': false, 'data': [], 'msg': '直播功能暂未开放'};
  }

  static Future liveRoomInfo({roomId, qn}) async {
    return {'status': false, 'data': [], 'msg': '直播功能暂未开放'};
  }

  static Future liveRoomInfoH5({roomId, qn}) async {
    return {'status': false, 'data': [], 'msg': '直播功能暂未开放'};
  }

  static Future liveDanmakuInfo({roomId}) async {
    return {'status': false, 'data': [], 'msg': '直播功能暂未开放'};
  }

  static Future sendDanmaku({roomId, msg}) async {
    return {'status': false, 'data': [], 'msg': '直播功能暂未开放'};
  }

  static Future liveFollowing({int? pn, int? ps}) async {
    return {'status': false, 'data': [], 'msg': '直播功能暂未开放'};
  }

  static Future liveRoomEntry({required int roomId}) async {
    return {'status': false, 'data': [], 'msg': '直播功能暂未开放'};
  }
}
