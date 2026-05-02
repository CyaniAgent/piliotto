import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:piliotto/ottohub/api/models/video.dart';
import 'package:piliotto/repositories/i_video_repository.dart';
import 'package:piliotto/providers/repository_provider.dart';
import 'package:piliotto/providers/user_provider.dart';
import 'package:piliotto/utils/responsive_util.dart';

part 'provider.g.dart';

class HistoryState {
  final List<Video> historyList;
  final bool isLoadingMore;
  final bool pauseStatus;
  final bool isLoading;
  final bool enableMultiple;
  final int checkedCount;
  final int crossAxisCount;

  const HistoryState({
    this.historyList = const [],
    this.isLoadingMore = true,
    this.pauseStatus = false,
    this.isLoading = true,
    this.enableMultiple = false,
    this.checkedCount = 0,
    this.crossAxisCount = 1,
  });

  HistoryState copyWith({
    List<Video>? historyList,
    bool? isLoadingMore,
    bool? pauseStatus,
    bool? isLoading,
    bool? enableMultiple,
    int? checkedCount,
    int? crossAxisCount,
  }) {
    return HistoryState(
      historyList: historyList ?? this.historyList,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      pauseStatus: pauseStatus ?? this.pauseStatus,
      isLoading: isLoading ?? this.isLoading,
      enableMultiple: enableMultiple ?? this.enableMultiple,
      checkedCount: checkedCount ?? this.checkedCount,
      crossAxisCount: crossAxisCount ?? this.crossAxisCount,
    );
  }
}

@riverpod
class HistoryNotifier extends _$HistoryNotifier {
  IVideoRepository get _videoRepo => ref.watch(videoRepositoryProvider);

  final ScrollController scrollController = ScrollController();

  @override
  HistoryState build() {
    final crossAxisCount = _calculateCrossAxisCount();
    ref.onDispose(() {
      scrollController.dispose();
    });
    queryHistoryList();
    return HistoryState(crossAxisCount: crossAxisCount);
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

  Future<Map<String, dynamic>> queryHistoryList({String type = 'init'}) async {
    final userInfo = ref.read(userProvider);
    if (userInfo == null) {
      return {'status': false, 'msg': '账号未登录', 'code': -101};
    }

    state = state.copyWith(isLoadingMore: true);

    try {
      final response = await _videoRepo.getHistoryVideos();
      state = state.copyWith(
        historyList: response.videoList,
        isLoadingMore: false,
      );
    } catch (e) {
      SmartDialog.showToast('请求失败: $e');
      state = state.copyWith(isLoadingMore: false);
    }

    return {'status': true};
  }

  Future onLoad() async {
    SmartDialog.showToast('没有更多了');
  }

  Future onRefresh() async {
    await queryHistoryList(type: 'onRefresh');
  }

  Future onPauseHistory() async {
    SmartDialog.showToast('Ottohub API 不支持暂停历史记录');
  }

  Future historyStatus() async {
    state = state.copyWith(pauseStatus: false);
  }

  Future onClearHistory() async {
    SmartDialog.showToast('Ottohub API 不支持清空历史记录');
  }

  Future<void> delHistory(int kid, String business) async {
    SmartDialog.showToast('Ottohub API 不支持删除历史记录');
  }

  Future onDelHistory() async {
    SmartDialog.showToast('Ottohub API 不支持删除历史记录');
  }

  Future onDelCheckedHistory() async {
    SmartDialog.showToast('Ottohub API 不支持删除历史记录');
  }
}

@riverpod
bool isUserLoggedInForHistory(Ref ref) {
  return ref.watch(userProvider) != null;
}
