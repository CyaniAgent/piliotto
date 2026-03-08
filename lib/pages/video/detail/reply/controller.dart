import 'package:get/get.dart';
import 'package:hive/hive.dart';

import 'package:piliotto/utils/storage.dart';

class VideoReplyController extends GetxController {
  VideoReplyController(this.vid);
  // 视频vid
  int vid;
  RxList replyList = [].obs;
  // 当前页
  int currentPage = 0;
  bool isLoadingMore = false;
  RxString noMore = ''.obs;
  int ps = 20;
  RxInt count = 0.obs;

  Box setting = GStrorage.setting;



  Future queryReplyList({type = 'init'}) async {
    if (isLoadingMore) {
      return;
    }
    isLoadingMore = true;
    if (type == 'init') {
      currentPage = 0;
      noMore.value = '';
    }
    if (noMore.value == '没有更多了') {
      isLoadingMore = false;
      return;
    }
    try {
      // Ottohub API 暂不支持获取评论列表
      final List replies = [];
      noMore.value = '还没有评论';
      if (type == 'init') {
        count.value = 0;
        replyList.value = replies;
      } else {
        replyList.addAll(replies);
      }
    } catch (e) {
      noMore.value = '获取评论失败';
    }
    isLoadingMore = false;
  }

  // 上拉加载
  Future onLoad() async {
    queryReplyList(type: 'onLoad');
  }

  // 排序搜索评论
  queryBySort() {
    // Ottohub API 暂不支持评论排序
  }
}
