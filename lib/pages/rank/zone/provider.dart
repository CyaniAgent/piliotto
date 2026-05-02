import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:piliotto/router/app_router.dart';
import 'package:piliotto/utils/responsive_util.dart';

part 'provider.g.dart';

class ZoneState {
  final List<Map<String, dynamic>> videoList;
  final bool isLoading;
  final bool isLoadingMore;
  final int crossAxisCount;

  const ZoneState({
    this.videoList = const [],
    this.isLoading = true,
    this.isLoadingMore = false,
    this.crossAxisCount = 1,
  });

  ZoneState copyWith({
    List<Map<String, dynamic>>? videoList,
    bool? isLoading,
    bool? isLoadingMore,
    int? crossAxisCount,
  }) {
    return ZoneState(
      videoList: videoList ?? this.videoList,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      crossAxisCount: crossAxisCount ?? this.crossAxisCount,
    );
  }
}

@riverpod
class ZoneNotifier extends _$ZoneNotifier {
  final ScrollController scrollController = ScrollController();

  @override
  ZoneState build() {
    final crossAxisCount = _calculateCrossAxisCount();
    ref.onDispose(() {
      scrollController.dispose();
    });
    return ZoneState(crossAxisCount: crossAxisCount);
  }

  int _calculateCrossAxisCount() {
    try {
      return ResponsiveUtil.calculateCrossAxisCount(
        baseCount: 1,
        minCount: 1,
        maxCount: 3,
      );
    } catch (e) {
      return 1;
    }
  }

  void updateCrossAxisCount() {
    final count = _calculateCrossAxisCount();
    state = state.copyWith(crossAxisCount: count);
  }

  Future<Map<String, dynamic>> queryRankFeed(String type, int rid) async {
    var res = {'status': true, 'data': <Map<String, dynamic>>[]};
    if (res['status'] == true) {
      if (type == 'init') {
        state = state.copyWith(
          videoList: res['data'] as List<Map<String, dynamic>>,
          isLoading: false,
        );
      } else if (type == 'onRefresh') {
        state = state.copyWith(
          videoList: res['data'] as List<Map<String, dynamic>>,
          isLoading: false,
          isLoadingMore: false,
        );
      } else if (type == 'onLoad') {
        state = state.copyWith(
          videoList: res['data'] as List<Map<String, dynamic>>,
          isLoadingMore: false,
        );
      }
    }
    return res;
  }

  Future<void> onRefresh(int rid) async {
    state = state.copyWith(isLoading: true);
    await queryRankFeed('onRefresh', rid);
  }

  Future<void> onLoad(int rid) async {
    state = state.copyWith(isLoadingMore: true);
    await queryRankFeed('onLoad', rid);
  }

  void animateToTop() {
    final BuildContext? context = rootNavigatorKey.currentContext;
    if (context == null) return;
    if (scrollController.hasClients) {
      if (scrollController.offset >= MediaQuery.of(context).size.height * 5) {
        scrollController.jumpTo(0);
      } else {
        scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    }
  }
}
