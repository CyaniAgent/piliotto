import 'package:get/get.dart';

import 'package:piliotto/repositories/i_comment_repository.dart';
import 'package:piliotto/services/loggeer.dart';
import 'package:piliotto/ottohub/models/video/reply/item.dart';

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

  final ICommentRepository _commentRepo = Get.find<ICommentRepository>();

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

      final result = await _commentRepo.getVideoComments(
        vid: vid,
        offset: currentPage * ps,
        num: ps,
      );
      logger.d('获取评论列表成功，数量: ${result.replies.length}');

      final List<ReplyItemModel> replyItems = result.replies;

      if (type == 'init') {
        count = replyItems.length;
        replyList = replyItems;
      } else {
        replyList.addAll(replyItems);
      }

      if (!result.hasMore) {
        noMore = '没有更多了';
      } else {
        currentPage++;
        noMore = '';
      }

      hasLoaded = true;
      update();
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
      logger.d('开始获取二级评论，vid: $vid, parentVcid: $parentVcid, offset: 0, num: $ps');

      final result = await _commentRepo.getVideoComments(
        vid: vid,
        parentVcid: parentVcid,
        offset: 0,
        num: ps,
      );
      logger.d('获取到二级评论数量: ${result.replies.length}');

      return result.replies;
    } catch (e) {
      final logger = getLogger();
      logger.e('获取二级评论异常: ${e.toString()}');
      return [];
    }
  }
}
