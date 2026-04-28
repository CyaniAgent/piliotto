import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/repositories/i_comment_repository.dart';
import 'package:piliotto/ottohub/models/video/reply/item.dart';
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
  final ICommentRepository _commentRepo = Get.find<ICommentRepository>();

  Rxn<ReplyItemModel> replyingTo = Rxn<ReplyItemModel>();
  RxInt parentBcid = 0.obs;

  @override
  void onInit() {
    super.onInit();
    item = Get.arguments['item'];
    floor = Get.arguments['floor'];
    acount.value =
        int.tryParse(item?.modules?.moduleStat?.comment?.count ?? '0') ?? 0;
  }

  Future<Map<String, dynamic>> queryReplyList({String reqType = 'init'}) async {
    if (reqType == 'init') {
      currentOffset = 0;
      replyList.clear();
    }

    isLoadingMore.value = true;

    try {
      final replies = await _commentRepo.getBlogComments(
        bid: oid!,
        offset: currentOffset,
        num: 12,
      );

      if (replies.isNotEmpty) {
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
    } catch (e) {
      SmartDialog.showToast('请求失败: $e');
      noMore.value = '加载失败';
    }

    isLoadingMore.value = false;
    return {'status': true};
  }

  void setReplyingTo(ReplyItemModel? replyItem, {int? parent}) {
    replyingTo.value = replyItem;
    parentBcid.value = parent ?? replyItem?.rpid ?? 0;
  }

  void clearReplyingTo() {
    replyingTo.value = null;
    parentBcid.value = 0;
  }

  void onReplySuccess() {
    clearReplyingTo();
    queryReplyList(reqType: 'init');
    acount.value++;
  }
}
