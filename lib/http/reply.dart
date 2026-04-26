import '../api/services/old_api_service.dart';

class ReplyHttp {
  // 视频评论列表
  static Future replyList({
    required int oid,
    required int pageNum,
    required int type,
    int? ps,
    int sort = 1,
  }) async {
    try {
      final response = await OldApiService.getVideoComments(
        vid: oid,
        parentVcid: 0,
        offset: (pageNum - 1) * (ps ?? 20),
        num: ps ?? 20,
      );
      return {
        'status': true,
        'data': response,
        'code': 200,
      };
    } catch (err) {
      return {
        'status': false,
        'data': null,
        'code': -1,
        'msg': err.toString(),
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

  // 表情列表（Ottohub 不支持）
  static Future getEmoteList({String? business}) async {
    return {
      'status': false,
      'data': null,
      'msg': 'Ottohub API 不支持表情功能',
    };
  }

  // 删除评论（Ottohub 不支持）
  static Future<Map<String, dynamic>> replyDel({
    required String type,
    required int oid,
    required int rpid,
  }) async {
    return {
      'status': false,
      'msg': 'Ottohub API 不支持删除评论功能',
    };
  }
}
