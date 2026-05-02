import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:piliotto/providers/repository_provider.dart';
import 'package:piliotto/models/common/reply_type.dart';
import 'package:piliotto/ottohub/models/video/reply/item.dart';
import 'package:piliotto/services/loggeer.dart';

part 'provider.g.dart';

class VideoReplyReplyState {
  final int vid;
  final int parentVcid;
  final ReplyType replyType;
  final List<ReplyItemModel> replyList;
  final int currentPage;
  final bool isLoadingMore;
  final String noMore;
  final ReplyItemModel? currentReplyItem;

  const VideoReplyReplyState({
    this.vid = 0,
    this.parentVcid = 0,
    this.replyType = ReplyType.video,
    this.replyList = const [],
    this.currentPage = 0,
    this.isLoadingMore = false,
    this.noMore = '',
    this.currentReplyItem,
  });

  VideoReplyReplyState copyWith({
    int? vid,
    int? parentVcid,
    ReplyType? replyType,
    List<ReplyItemModel>? replyList,
    int? currentPage,
    bool? isLoadingMore,
    String? noMore,
    ReplyItemModel? currentReplyItem,
  }) {
    return VideoReplyReplyState(
      vid: vid ?? this.vid,
      parentVcid: parentVcid ?? this.parentVcid,
      replyType: replyType ?? this.replyType,
      replyList: replyList ?? this.replyList,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      noMore: noMore ?? this.noMore,
      currentReplyItem: currentReplyItem ?? this.currentReplyItem,
    );
  }
}

@riverpod
class VideoReplyReplyNotifier extends _$VideoReplyReplyNotifier {
  final ScrollController scrollController = ScrollController();
  static const int ps = 12;

  @override
  VideoReplyReplyState build(int vid, int parentVcid, ReplyType replyType) {
    return VideoReplyReplyState(
      vid: vid,
      parentVcid: parentVcid,
      replyType: replyType,
    );
  }

  Future<void> queryReplyList({String type = 'init', dynamic currentReply}) async {
    int currentPage = state.currentPage;
    if (type == 'init') {
      currentPage = 0;
    }
    if (state.isLoadingMore) {
      return;
    }

    state = state.copyWith(isLoadingMore: true);

    try {
      final logger = getLogger();
      logger.d('开始获取二级评论列表，vid: ${state.vid}, parentVcid: ${state.parentVcid}, offset: ${currentPage * ps}, num: $ps');

      final result = await ref.read(commentRepositoryProvider).getVideoComments(
        vid: state.vid,
        parentVcid: state.parentVcid,
        offset: currentPage * ps,
        num: ps,
      );
      logger.d('获取二级评论列表成功，数量: ${result.replies.length}');

      final List<ReplyItemModel> replies = result.replies;
      String noMore;

      if (replies.isNotEmpty) {
        noMore = '加载中...';
        if (!result.hasMore) {
          noMore = '没有更多了';
        }
        currentPage++;
      } else {
        noMore = currentPage == 0 ? '还没有评论' : '没有更多了';
      }

      List<ReplyItemModel> newReplyList;
      if (type == 'init') {
        newReplyList = replies;
      } else {
        if (replies.length == 1 && replies.last.rpid == state.replyList.last.rpid) {
          state = state.copyWith(isLoadingMore: false);
          return;
        }
        newReplyList = [...state.replyList, ...replies];
      }

      state = state.copyWith(
        replyList: newReplyList,
        currentPage: currentPage,
        noMore: noMore,
        isLoadingMore: false,
      );

      if (state.replyList.isNotEmpty && currentReply != null) {
        int indexToRemove =
            state.replyList.indexWhere((item) => currentReply.rpid == item.rpid);
        if (indexToRemove != -1) {
          final updatedList = List<ReplyItemModel>.from(state.replyList);
          updatedList.removeAt(indexToRemove);
          if (currentPage == 1 && type == 'init') {
            updatedList.insert(0, currentReply);
          }
          state = state.copyWith(replyList: updatedList);
        }
      }
    } catch (e) {
      final logger = getLogger();
      logger.e('获取二级评论异常: ${e.toString()}');
      state = state.copyWith(
        noMore: '获取评论失败',
        isLoadingMore: false,
      );
    }
  }

  void dispose() {
    scrollController.dispose();
  }
}
