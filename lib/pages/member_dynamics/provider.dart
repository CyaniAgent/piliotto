import 'package:flutter/material.dart';
import 'package:piliotto/ottohub/models/dynamics/result.dart';
import 'package:piliotto/providers/repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'provider.g.dart';

class MemberDynamicsState {
  final List<DynamicItemModel> dynamicsList;
  final bool hasMore;
  final int offset;

  const MemberDynamicsState({
    this.dynamicsList = const [],
    this.hasMore = true,
    this.offset = 0,
  });

  MemberDynamicsState copyWith({
    List<DynamicItemModel>? dynamicsList,
    bool? hasMore,
    int? offset,
  }) {
    return MemberDynamicsState(
      dynamicsList: dynamicsList ?? this.dynamicsList,
      hasMore: hasMore ?? this.hasMore,
      offset: offset ?? this.offset,
    );
  }
}

@riverpod
class MemberDynamicsNotifier extends _$MemberDynamicsNotifier {
  late int _mid;
  final ScrollController scrollController = ScrollController();

  @override
  MemberDynamicsState build(int mid) {
    _mid = mid;
    return const MemberDynamicsState();
  }

  Future<void> getMemberDynamic(String type) async {
    if (type == 'onRefresh') {
      state = const MemberDynamicsState();
    }
    if (!state.hasMore) {
      return;
    }
    try {
      final dynamicsRepo = ref.read(dynamicsRepositoryProvider);
      final blogList = await dynamicsRepo.getUserBlogs(
        uid: _mid,
        offset: state.offset,
        num: 10,
      );
      if (!ref.mounted) return;
      if (blogList.isNotEmpty) {
        state = state.copyWith(
          dynamicsList: [...state.dynamicsList, ...blogList],
          offset: state.offset + blogList.length,
          hasMore: blogList.length == 10,
        );
      } else {
        state = state.copyWith(hasMore: false);
      }
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(hasMore: false);
    }
  }

  Future<void> onLoad() async {
    await getMemberDynamic('onLoad');
  }
}
