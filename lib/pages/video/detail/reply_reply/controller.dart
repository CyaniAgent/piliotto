import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piliotto/repositories/i_comment_repository.dart';
import 'package:piliotto/models/common/reply_type.dart';
import 'package:piliotto/ottohub/models/video/reply/item.dart';
import 'package:piliotto/services/loggeer.dart';

class VideoReplyReplyController extends GetxController {
  VideoReplyReplyController(this.vid, this.parentVcid, this.replyType);
  final ScrollController scrollController = ScrollController();
  int vid;
  int parentVcid;
  ReplyType replyType = ReplyType.video;
  RxList<ReplyItemModel> replyList = <ReplyItemModel>[].obs;
  int currentPage = 0;
  bool isLoadingMore = false;
  RxString noMore = ''.obs;
  ReplyItemModel? currentReplyItem;
  int ps = 12;
  final ICommentRepository _commentRepo = Get.find<ICommentRepository>();

  @override
  void onInit() {
    super.onInit();
    currentPage = 0;
  }

  Future<void> queryReplyList({String type = 'init', dynamic currentReply}) async {
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

      final result = await _commentRepo.getVideoComments(
        vid: vid,
        parentVcid: parentVcid,
        offset: currentPage * ps,
        num: ps,
      );
      logger.d('获取二级评论列表成功，数量: ${result.replies.length}');

      final List<ReplyItemModel> replies = result.replies;

      if (replies.isNotEmpty) {
        noMore.value = '加载中...';
        if (!result.hasMore) {
          noMore.value = '没有更多了';
        }
        currentPage++;
      } else {
        noMore.value = currentPage == 0 ? '还没有评论' : '没有更多了';
      }
      if (type == 'init') {
        replyList.value = replies;
      } else {
        if (replies.length == 1 && replies.last.rpid == replyList.last.rpid) {
          return;
        }
        replyList.addAll(replies);
      }
    } catch (e) {
      final logger = getLogger();
      logger.e('获取二级评论异常: ${e.toString()}');
      noMore.value = '获取评论失败';
    }
    if (replyList.isNotEmpty && currentReply != null) {
      int indexToRemove =
          replyList.indexWhere((item) => currentReply.rpid == item.rpid);
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
