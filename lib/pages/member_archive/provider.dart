import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:piliotto/ottohub/models/member/archive.dart';
import 'package:piliotto/providers/repository_provider.dart';
import 'package:piliotto/utils/route_arguments.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'provider.g.dart';

class MemberArchiveState {
  final int mid;
  final int offset;
  final int count;
  final Map<String, String> currentOrder;
  final List<Map<String, String>> orderList;
  final List<VListItemModel> archivesList;
  final bool isLoading;

  const MemberArchiveState({
    this.mid = 0,
    this.offset = 0,
    this.count = 0,
    this.currentOrder = const {'type': 'pubdate', 'label': '最新发布'},
    this.orderList = const [
      {'type': 'pubdate', 'label': '最新发布'},
      {'type': 'click', 'label': '最多播放'},
      {'type': 'stow', 'label': '最多收藏'},
    ],
    this.archivesList = const [],
    this.isLoading = false,
  });

  MemberArchiveState copyWith({
    int? mid,
    int? offset,
    int? count,
    Map<String, String>? currentOrder,
    List<Map<String, String>>? orderList,
    List<VListItemModel>? archivesList,
    bool? isLoading,
  }) {
    return MemberArchiveState(
      mid: mid ?? this.mid,
      offset: offset ?? this.offset,
      count: count ?? this.count,
      currentOrder: currentOrder ?? this.currentOrder,
      orderList: orderList ?? this.orderList,
      archivesList: archivesList ?? this.archivesList,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

@riverpod
class MemberArchiveNotifier extends _$MemberArchiveNotifier {
  final ScrollController scrollController = ScrollController();

  @override
  MemberArchiveState build() {
    final midStr = routeArguments.queryParameters['mid'];
    final mid = midStr != null ? int.parse(midStr) : 0;
    return MemberArchiveState(mid: mid);
  }

  Future<void> getMemberArchive(String type) async {
    if (state.isLoading) {
      return;
    }
    state = state.copyWith(isLoading: true);
    int newOffset = state.offset;
    List<VListItemModel> newList = state.archivesList;
    
    if (type == 'init') {
      newOffset = 0;
      newList = [];
    }
    
    try {
      final videoRepo = ref.read(videoRepositoryProvider);
      final items = await videoRepo.getUserVideoList(
        uid: state.mid,
        offset: newOffset,
        num: 20,
      );
      
      if (type == 'init') {
        newList = items;
      } else {
        newList = [...newList, ...items];
      }
      newOffset += items.length;
      
      state = state.copyWith(
        archivesList: newList,
        offset: newOffset,
        count: items.length,
        isLoading: false,
      );
    } catch (e) {
      SmartDialog.showToast('请求失败: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> toggleSort() async {
    List<String> typeList = state.orderList.map((e) => e['type']!).toList();
    int index = typeList.indexOf(state.currentOrder['type']!);
    Map<String, String> newOrder;
    if (index == state.orderList.length - 1) {
      newOrder = state.orderList.first;
    } else {
      newOrder = state.orderList[index + 1];
    }
    state = state.copyWith(currentOrder: newOrder);
    await getMemberArchive('init');
  }

  Future<void> setCurrentOrder(Map<String, String> order) async {
    state = state.copyWith(currentOrder: order);
    await getMemberArchive('init');
  }

  Future<void> onLoad() async {
    await getMemberArchive('onLoad');
  }
}
