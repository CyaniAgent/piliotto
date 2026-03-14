/// 消息相关 API - Ottohub 不支持
/// 所有消息功能暂不可用
class MsgHttp {
  // 会话列表
  static Future sessionList({int? endTs}) async {
    return {'status': false, 'data': [], 'msg': 'Ottohub API 不支持消息功能'};
  }

  // 账号列表
  static Future accountList(uids) async {
    return {'status': false, 'data': [], 'msg': 'Ottohub API 不支持消息功能'};
  }

  // 会话消息
  static Future sessionMsg({int? talkerId}) async {
    return {'status': false, 'data': [], 'msg': 'Ottohub API 不支持消息功能'};
  }

  // 消息标记已读
  static Future ackSessionMsg({int? talkerId, int? ackSeqno}) async {
    return {'status': false, 'msg': 'Ottohub API 不支持消息功能'};
  }

  // 发送私信
  static Future sendMsg({
    required int senderUid,
    required int receiverId,
    int? receiverType,
    int? msgType,
    dynamic content,
  }) async {
    return {'status': false, 'msg': 'Ottohub API 不支持消息功能'};
  }

  // 移除会话
  static Future removeSession({int? talkerId}) async {
    return {'status': false, 'msg': 'Ottohub API 不支持消息功能'};
  }

  // 未读消息
  static Future unread() async {
    return {'status': false, 'data': {}, 'msg': 'Ottohub API 不支持消息功能'};
  }

  // 回复我的
  static Future messageReply({int? id, int? replyTime}) async {
    return {'status': false, 'data': [], 'msg': 'Ottohub API 不支持消息功能'};
  }

  // 收到的赞
  static Future messageLike({int? id, int? likeTime}) async {
    return {'status': false, 'data': [], 'msg': 'Ottohub API 不支持消息功能'};
  }

  // 系统消息
  static Future messageSystem() async {
    return {'status': false, 'data': [], 'msg': 'Ottohub API 不支持消息功能'};
  }

  // 系统消息标记已读
  static Future systemMarkRead(int cursor) async {
    return {'status': false, 'msg': 'Ottohub API 不支持消息功能'};
  }

  // 用户系统消息
  static Future messageSystemAccount() async {
    return {'status': false, 'data': [], 'msg': 'Ottohub API 不支持消息功能'};
  }
}
