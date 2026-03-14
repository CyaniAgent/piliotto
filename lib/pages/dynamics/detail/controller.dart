import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/api/services/old_api_service.dart';
import 'package:piliotto/models/video/reply/item.dart';
import 'package:piliotto/utils/storage.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class DynamicDetailController extends GetxController {
  DynamicDetailController(this.oid);
  int? oid;
  dynamic item;
  int? floor;
  int currentOffset = 0;
  RxBool isLoadingMore = false.obs;
  RxString noMore = ''.obs;
  RxList<ReplyItemModel> replyList = <ReplyItemModel>[].obs;
  RxInt acount = 0.obs;
  final ScrollController scrollController = ScrollController();

  Box setting = GStrorage.setting;

  @override
  void onInit() {
    super.onInit();
    item = Get.arguments['item'];
    floor = Get.arguments['floor'];
    acount.value =
        int.tryParse(item?.modules?.moduleStat?.comment?.count ?? '0') ?? 0;
  }

  Future queryReplyList({reqType = 'init'}) async {
    if (reqType == 'init') {
      currentOffset = 0;
      replyList.clear();
    }

    isLoadingMore.value = true;

    try {
      final res = await OldApiService.getBlogCommentList(
        bid: oid!,
        offset: currentOffset,
        num: 12,
      );

      if (res['status'] == 'success') {
        final List<dynamic> comments = res['comment_list'] ?? [];

        if (comments.isNotEmpty) {
          final replies = comments.map((comment) {
            return ReplyItemModel.fromOttohubJson(comment);
          }).toList();

          if (reqType == 'init') {
            replyList.value = replies;
          } else {
            replyList.addAll(replies);
          }

          currentOffset += 12;
          noMore.value = replies.length < 12 ? '没有更多了' : '加载中...';
        } else {
          noMore.value = currentOffset == 0 ? '还没有评论' : '没有更多了';
        }
      } else {
        SmartDialog.showToast(res['message'] ?? '获取评论失败');
        noMore.value = '加载失败';
      }
    } catch (e) {
      SmartDialog.showToast('请求失败: $e');
      noMore.value = '加载失败';
    }

    isLoadingMore.value = false;
    return {'status': true};
  }
}
