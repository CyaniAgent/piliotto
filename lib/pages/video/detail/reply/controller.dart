import 'package:get/get.dart';
import 'package:hive/hive.dart';

import 'package:piliotto/utils/storage.dart';
import 'package:piliotto/api/services/old_api_service.dart';
import 'package:piliotto/services/loggeer.dart';
import 'package:piliotto/models/video/reply/item.dart';
import 'package:piliotto/models/video/reply/member.dart';
import 'package:piliotto/models/video/reply/content.dart';

class VideoReplyController extends GetxController {
  VideoReplyController(this.vid);

  int vid;

  List<ReplyItemModel> replyList = <ReplyItemModel>[];
  int currentPage = 0;
  bool isLoadingMore = false;
  bool hasLoaded = false;
  String noMore = '';
  int ps = 12;
  int count = 0;

  Box setting = GStrorage.setting;

  void updateVid(int newVid) {
    if (vid != newVid) {
      vid = newVid;
      replyList.clear();
      currentPage = 0;
      hasLoaded = false;
      noMore = '';
      count = 0;
    }
  }

  ReplyItemModel _convertToReplyItemModel(Map<String, dynamic> comment) {
    final member = ReplyMember(
      mid: (comment['uid'] ?? '0').toString(),
      uname: comment['username'] ?? '',
      sign: '',
      avatar: comment['avatar_url'] ?? '',
      level: 1,
      pendant: Pendant(pid: 0, name: '', image: ''),
      officialVerify: {},
      vip: {'vipStatus': 0, 'vipType': 0},
      fansDetail: {},
    );

    final content = ReplyContent(
      message: comment['content'] ?? '',
      atNameToMid: {},
      members: [],
      emote: {},
      jumpUrl: {},
      pictures: [],
      vote: {},
      richText: {},
      isText: true,
      topicsMeta: {},
    );

    final upAction = UpAction(
      like: false,
      reply: false,
    );

    final childCommentNum = comment['child_comment_num'] ?? 0;
    
    // 处理二级评论预览
    List<ReplyItemModel> childReplies = [];
    if (comment['child_comments'] != null && comment['child_comments'] is List) {
      final List childCommentsList = comment['child_comments'];
      // 最多显示3条热门二级评论预览
      final previewCount = childCommentsList.length > 3 ? 3 : childCommentsList.length;
      for (int i = 0; i < previewCount; i++) {
        childReplies.add(_convertChildReplyItemModel(childCommentsList[i]));
      }
    }
    
    final replyControl = ReplyControl(
      upReply: false,
      isUpTop: false,
      upLike: false,
      isShow: childCommentNum > 0,
      entryText: childCommentNum > 0
          ? (childCommentNum > 3 ? '共$childCommentNum条回复' : '共$childCommentNum条回复')
          : '',
      titleText: '',
      time: comment['time'] ?? '',
      location: '',
    );

    return ReplyItemModel(
      rpid: int.tryParse(comment['vcid'] ?? '0') ?? 0,
      oid: vid,
      type: 1,
      mid: int.tryParse(comment['uid'] ?? '0') ?? 0,
      root: 0,
      parent: int.tryParse(comment['parent_vcid'] ?? '0') ?? 0,
      dialog: 0,
      count: childCommentNum,
      ctime: comment['time'] != null
          ? DateTime.parse(comment['time'].replaceAll(' ', 'T'))
                  .millisecondsSinceEpoch ~/
              1000
          : 0,
      like: 0,
      member: member,
      content: content,
      replies: childReplies,
      upAction: upAction,
      invisible: false,
      replyControl: replyControl,
      isUp: false,
      isTop: false,
      cardLabel: [],
    );
  }

  ReplyItemModel _convertChildReplyItemModel(Map<String, dynamic> comment) {
    final member = ReplyMember(
      mid: (comment['uid'] ?? '0').toString(),
      uname: comment['username'] ?? '',
      sign: '',
      avatar: comment['avatar_url'] ?? '',
      level: 1,
      pendant: Pendant(pid: 0, name: '', image: ''),
      officialVerify: {},
      vip: {'vipStatus': 0, 'vipType': 0},
      fansDetail: {},
    );

    final content = ReplyContent(
      message: comment['content'] ?? '',
      atNameToMid: {},
      members: [],
      emote: {},
      jumpUrl: {},
      pictures: [],
      vote: {},
      richText: {},
      isText: true,
      topicsMeta: {},
    );

    final upAction = UpAction(
      like: false,
      reply: false,
    );

    final childCommentNum = comment['child_comment_num'] ?? 0;
    final replyControl = ReplyControl(
      upReply: false,
      isUpTop: false,
      upLike: false,
      isShow: childCommentNum > 0,
      entryText: childCommentNum > 0 ? '共$childCommentNum条回复' : '',
      titleText: '',
      time: comment['time'] ?? '',
      location: '',
    );

    return ReplyItemModel(
      rpid: int.tryParse(comment['vcid'] ?? '0') ?? 0,
      oid: vid,
      type: 1,
      mid: int.tryParse(comment['uid'] ?? '0') ?? 0,
      root: 0,
      parent: int.tryParse(comment['parent_vcid'] ?? '0') ?? 0,
      dialog: 0,
      count: childCommentNum,
      ctime: comment['time'] != null
          ? DateTime.parse(comment['time'].replaceAll(' ', 'T'))
                  .millisecondsSinceEpoch ~/
              1000
          : 0,
      like: 0,
      member: member,
      content: content,
      replies: [],
      upAction: upAction,
      invisible: false,
      replyControl: replyControl,
      isUp: false,
      isTop: false,
      cardLabel: [],
    );
  }

  Future queryReplyList({String type = 'init'}) async {
    if (isLoadingMore) {
      return;
    }

    isLoadingMore = true;

    if (type == 'init') {
      currentPage = 0;
      noMore = '';
    }

    if (noMore == '没有更多了') {
      isLoadingMore = false;
      return;
    }

    try {
      final logger = getLogger();
      logger.d('开始获取评论列表，vid: $vid, offset: ${currentPage * ps}, num: $ps');

      final response = await OldApiService.getVideoComments(
        vid: vid,
        offset: currentPage * ps,
        num: ps,
      );
      logger.d('获取评论列表响应: $response');

      if (response['status'] == 'success') {
        final List comments = response['comment_list'] ?? [];
        logger.d('获取到评论数量: ${comments.length}');

        final List<ReplyItemModel> replyItems = comments
            .map((comment) => _convertToReplyItemModel(comment))
            .toList();

        if (type == 'init') {
          count = replyItems.length;
          replyList = replyItems;
        } else {
          replyList.addAll(replyItems);
        }

        if (replyItems.length < ps) {
          noMore = '没有更多了';
        } else {
          currentPage++;
          noMore = '';
        }

        hasLoaded = true;
        update();
      } else {
        logger.e('获取评论失败: ${response['message']}');
        noMore = '获取评论失败';
        update();
      }
    } catch (e) {
      final logger = getLogger();
      logger.e('获取评论异常: ${e.toString()}');
      noMore = '获取评论失败';
      update();
    }

    isLoadingMore = false;
  }

  Future onLoad() async {
    await queryReplyList(type: 'onLoad');
  }

  Future<List<ReplyItemModel>> queryChildComments(int parentVcid) async {
    try {
      final logger = getLogger();
      logger.d(
          '开始获取二级评论，vid: $vid, parentVcid: $parentVcid, offset: 0, num: $ps');

      final response = await OldApiService.getVideoComments(
        vid: vid,
        parentVcid: parentVcid,
        offset: 0,
        num: ps,
      );
      logger.d('获取二级评论列表响应: $response');

      if (response['status'] == 'success') {
        final List comments = response['comment_list'] ?? [];
        logger.d('获取到二级评论数量: ${comments.length}');

        final List<ReplyItemModel> replyItems = comments
            .map((comment) => _convertToReplyItemModel(comment))
            .toList();

        return replyItems;
      } else {
        logger.e('获取二级评论失败: ${response['message']}');
        return [];
      }
    } catch (e) {
      final logger = getLogger();
      logger.e('获取二级评论异常: ${e.toString()}');
      return [];
    }
  }
}
