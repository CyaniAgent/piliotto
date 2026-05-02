import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:piliotto/providers/repository_provider.dart';
import 'package:piliotto/ottohub/models/video/reply/item.dart';
import 'package:piliotto/utils/route_arguments.dart';

part 'provider.g.dart';

class DynamicDetailState {
  final int oid;
  final dynamic item;
  final int? floor;
  final List<ReplyItemModel> replyList;
  final int currentOffset;
  final bool isLoadingMore;
  final String noMore;
  final int acount;
  final ReplyItemModel? replyingTo;
  final int parentBcid;

  const DynamicDetailState({
    this.oid = 0,
    this.item,
    this.floor,
    this.replyList = const [],
    this.currentOffset = 0,
    this.isLoadingMore = false,
    this.noMore = '',
    this.acount = 0,
    this.replyingTo,
    this.parentBcid = 0,
  });

  DynamicDetailState copyWith({
    int? oid,
    dynamic item,
    int? floor,
    List<ReplyItemModel>? replyList,
    int? currentOffset,
    bool? isLoadingMore,
    String? noMore,
    int? acount,
    ReplyItemModel? replyingTo,
    int? parentBcid,
  }) {
    return DynamicDetailState(
      oid: oid ?? this.oid,
      item: item ?? this.item,
      floor: floor ?? this.floor,
      replyList: replyList ?? this.replyList,
      currentOffset: currentOffset ?? this.currentOffset,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      noMore: noMore ?? this.noMore,
      acount: acount ?? this.acount,
      replyingTo: replyingTo ?? this.replyingTo,
      parentBcid: parentBcid ?? this.parentBcid,
    );
  }
}

@riverpod
class DynamicDetailNotifier extends _$DynamicDetailNotifier {
  final ScrollController scrollController = ScrollController();

  @override
  DynamicDetailState build(int oid) {
    final item = routeArguments['item'];
    final floor = routeArguments['floor'];
    final acount = int.tryParse(item?.modules?.moduleStat?.comment?.count ?? '0') ?? 0;

    return DynamicDetailState(
      oid: oid,
      item: item,
      floor: floor,
      acount: acount,
    );
  }

  Future<Map<String, dynamic>> queryReplyList({String reqType = 'init'}) async {
    if (reqType == 'init') {
      state = state.copyWith(currentOffset: 0, replyList: []);
    }

    state = state.copyWith(isLoadingMore: true);

    try {
      final replies = await ref.read(commentRepositoryProvider).getBlogComments(
        bid: state.oid,
        offset: state.currentOffset,
        num: 12,
      );

      if (replies.isNotEmpty) {
        final newReplyList = reqType == 'init'
            ? replies
            : [...state.replyList, ...replies];

        final newOffset = state.currentOffset + 12;
        final noMore = replies.length < 12 ? '没有更多了' : '加载中...';

        state = state.copyWith(
          replyList: newReplyList,
          currentOffset: newOffset,
          noMore: noMore,
          isLoadingMore: false,
        );
      } else {
        final noMore = state.currentOffset == 0 ? '还没有评论' : '没有更多了';
        state = state.copyWith(noMore: noMore, isLoadingMore: false);
      }
    } catch (e) {
      SmartDialog.showToast('请求失败: $e');
      state = state.copyWith(noMore: '加载失败', isLoadingMore: false);
    }

    return {'status': true};
  }

  void setReplyingTo(ReplyItemModel? replyItem, {int? parent}) {
    state = state.copyWith(
      replyingTo: replyItem,
      parentBcid: parent ?? replyItem?.rpid ?? 0,
    );
  }

  void clearReplyingTo() {
    state = state.copyWith(replyingTo: null, parentBcid: 0);
  }

  void onReplySuccess() {
    clearReplyingTo();
    queryReplyList(reqType: 'init');
    state = state.copyWith(acount: state.acount + 1);
  }
}
