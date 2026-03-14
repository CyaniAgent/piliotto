import '../models/video/reply/data.dart';
import '../models/video/reply/emote.dart';
import 'api.dart';
import 'init.dart';

class ReplyHttp {
  static Future replyList({
    required int oid,
    required int pageNum,
    required int type,
    int? ps,
    int sort = 1,
  }) async {
    var res = await Request().get(Api.replyList, data: {
      'oid': oid,
      'pn': pageNum,
      'type': type,
      'sort': sort,
      'ps': ps ?? 20
    });
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': ReplyData.fromJson(res.data['data']),
        'code': 200,
      };
    } else {
      return {
        'status': false,
        'date': [],
        'code': res.data['code'],
        'msg': res.data['message'],
      };
    }
  }

  // 楼中楼评论列表（Ottohub 不支持）
  static Future replyReplyList({
    required int oid,
    required String root,
    required int pageNum,
    required int type,
    int sort = 1,
  }) async {
    return {
      'status': false,
      'msg': 'Ottohub API 不支持楼中楼评论功能',
    };
  }

  // 评论点赞（Ottohub 不支持）
  static Future likeReply({
    required int type,
    required int oid,
    required int rpid,
    required int action,
  }) async {
    return {
      'status': false,
      'msg': 'Ottohub API 不支持评论点赞功能',
    };
  }

  static Future getEmoteList({String? business}) async {
    var res = await Request().get(Api.emojiList, data: {
      'business': business ?? 'reply',
      'web_location': '333.1245',
    });
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': EmoteModelData.fromJson(res.data['data']),
      };
    } else {
      return {
        'status': false,
        'date': [],
        'msg': res.data['message'],
      };
    }
  }

  // 删除评论（Ottohub 不支持）
  static Future replyDel({
    required type, //replyType
    required int oid,
    required int rpid,
  }) async {
    return {
      'status': false,
      'msg': 'Ottohub API 不支持删除评论功能',
    };
  }
}
