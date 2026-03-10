import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/api/services/old_api_service.dart';
import 'package:piliotto/models/common/reply_type.dart';
import 'package:piliotto/models/video/reply/item.dart';
import 'package:piliotto/models/video/reply/member.dart';
import 'package:piliotto/models/video/reply/content.dart';
import 'package:piliotto/services/loggeer.dart';

class VideoReplyReplyController extends GetxController {
  VideoReplyReplyController(this.vid, this.parentVcid, this.replyType);
  final ScrollController scrollController = ScrollController();
  // 视频vid
  int vid;
  // 父评论ID
  int parentVcid;
  ReplyType replyType = ReplyType.video;
  RxList<ReplyItemModel> replyList = <ReplyItemModel>[].obs;
  // 当前页
  int currentPage = 0;
  bool isLoadingMore = false;
  RxString noMore = ''.obs;
  // 当前回复的回复
  ReplyItemModel? currentReplyItem;
  int ps = 12;

  @override
  void onInit() {
    super.onInit();
    currentPage = 0;
  }

  // 将旧API返回的评论数据转换为ReplyItemModel
  ReplyItemModel _convertToReplyItemModel(Map<String, dynamic> comment) {
    // 构建member对象
    final member = ReplyMember(
      mid: (comment['uid'] ?? '0').toString(),
      uname: comment['username'] ?? '',
      sign: '',
      avatar: comment['avatar_url'] ?? '',
      level: 1, // 旧API没有提供等级信息，默认设为1
      pendant: Pendant(pid: 0, name: '', image: ''),
      officialVerify: {},
      vip: {'vipStatus': 0, 'vipType': 0}, // 旧API没有提供VIP信息
      fansDetail: {},
    );

    // 构建content对象
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

    // 构建upAction对象
    final upAction = UpAction(
      like: false,
      reply: false,
    );

    // 构建replyControl对象
    final childCommentNum = comment['child_comment_num'] ?? 0;
    final replyControl = ReplyControl(
      upReply: false,
      isUpTop: false,
      upLike: false,
      isShow: childCommentNum > 0,
      entryText: childCommentNum > 0
          ? '共$childCommentNum条回复'
          : '',
      titleText: '',
      time: comment['time'] ?? '',
      location: '',
    );

    // 构建ReplyItemModel
    return ReplyItemModel(
      rpid: int.tryParse(comment['vcid'] ?? '0') ?? 0,
      oid: vid,
      type: 1, // 视频评论类型
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
      like: 0, // 旧API没有提供点赞数
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

  Future queryReplyList({type = 'init', currentReply}) async {
    if (type == 'init') {
      currentPage = 0;
    }
    if (isLoadingMore) {
      return;
    }
    isLoadingMore = true;
    try {
      final logger = getLogger();
      logger.d('开始获取二级评论列表，vid: $vid, parentVcid: $parentVcid, offset: ${currentPage * ps}, num: $ps');
      // 使用旧版API获取二级评论列表
      final response = await OldApiService.getVideoComments(
        vid: vid,
        parentVcid: parentVcid,
        offset: currentPage * ps,
        num: ps,
      );
      logger.d('获取二级评论列表响应: $response');

      if (response['status'] == 'success') {
        final List comments = response['comment_list'] ?? [];
        logger.d('获取到二级评论数量: ${comments.length}');

        // 将原始评论数据转换为ReplyItemModel
        final List<ReplyItemModel> replies = comments
            .map((comment) => _convertToReplyItemModel(comment))
            .toList();

        if (replies.isNotEmpty) {
          noMore.value = '加载中...';
          if (replies.length < ps) {
            noMore.value = '没有更多了';
          }
          currentPage++;
        } else {
          // 未登录状态replies可能返回null
          noMore.value = currentPage == 0 ? '还没有评论' : '没有更多了';
        }
        if (type == 'init') {
          replyList.value = replies;
        } else {
          // 每次回复之后，翻页请求有且只有相同的一条回复数据
          if (replies.length == 1 && replies.last.rpid == replyList.last.rpid) {
            return;
          }
          replyList.addAll(replies);
        }
      } else {
        final logger = getLogger();
        logger.e('获取二级评论失败: ${response['message']}');
        noMore.value = '获取评论失败';
      }
    } catch (e) {
      final logger = getLogger();
      logger.e('获取二级评论异常: ${e.toString()}');
      noMore.value = '获取评论失败';
    }
    if (replyList.isNotEmpty && currentReply != null) {
      int indexToRemove =
          replyList.indexWhere((item) => currentReply.rpid == item.rpid);
      // 如果找到了指定ID的项，则移除
      if (indexToRemove != -1) {
        replyList.removeAt(indexToRemove);
      }
      if (currentPage == 1 && type == 'init') {
        replyList.insert(0, currentReply);
      }
    }
    isLoadingMore = false;
  }

  @override
  void onClose() {
    currentPage = 0;
    super.onClose();
  }
}
