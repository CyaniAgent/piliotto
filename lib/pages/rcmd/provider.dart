import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:piliotto/ottohub/api/models/video.dart';
import 'package:piliotto/providers/repository_provider.dart';
import 'package:piliotto/router/app_router.dart';
import 'package:piliotto/services/loggeer.dart';
import 'package:piliotto/utils/responsive_util.dart';
import 'package:piliotto/utils/storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'provider.g.dart';

class RcmdState {
  final List<Video> videoList;
  final bool isLoadingMore;
  final int crossAxisCount;

  const RcmdState({
    this.videoList = const [],
    this.isLoadingMore = true,
    this.crossAxisCount = 2,
  });

  RcmdState copyWith({
    List<Video>? videoList,
    bool? isLoadingMore,
    int? crossAxisCount,
  }) {
    return RcmdState(
      videoList: videoList ?? this.videoList,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      crossAxisCount: crossAxisCount ?? this.crossAxisCount,
    );
  }
}

@riverpod
class RcmdNotifier extends _$RcmdNotifier {
  final ScrollController scrollController = ScrollController();
  late bool enableSaveLastData;

  @override
  RcmdState build() {
    try {
      enableSaveLastData = GStrorage.setting
          .get(SettingBoxKey.enableSaveLastData, defaultValue: false);
    } catch (_) {
      enableSaveLastData = false;
    }
    final crossAxisCount = _calculateCrossAxisCount();
    ref.onDispose(() {
      scrollController.dispose();
    });
    return RcmdState(crossAxisCount: crossAxisCount);
  }

  int _calculateCrossAxisCount() {
    try {
      int customRows =
          GStrorage.setting.get(SettingBoxKey.customRows, defaultValue: 2);
      return ResponsiveUtil.calculateCrossAxisCount(
        baseCount: customRows,
        minCount: 1,
        maxCount: 4,
      );
    } catch (e) {
      return 2;
    }
  }

  void updateCrossAxisCount() {
    if (!ref.mounted) return;
    final count = _calculateCrossAxisCount();
    state = state.copyWith(crossAxisCount: count);
  }

  Future<Map<String, dynamic>> queryRcmdFeed(String type) async {
    if (!state.isLoadingMore) {
      return {'status': false, 'msg': '正在加载中'};
    }
    try {
      final videoRepo = ref.read(videoRepositoryProvider);
      final response = await videoRepo.getRandomVideos(num: 20);
      final List<Video> videos = response.videoList;

      if (!ref.mounted) {
        return {'status': false, 'msg': 'Provider disposed'};
      }

      List<Video> newList = state.videoList;
      if (type == 'init') {
        newList = videos;
      } else if (type == 'onRefresh') {
        if (enableSaveLastData) {
          newList = [...videos, ...state.videoList];
        } else {
          newList = videos;
        }
      } else if (type == 'onLoad') {
        newList = [...state.videoList, ...videos];
      }
      state = state.copyWith(videoList: newList, isLoadingMore: false);
      return {'status': true, 'data': videos};
    } catch (error) {
      if (!ref.mounted) {
        return {'status': false, 'msg': 'Provider disposed'};
      }
      state = state.copyWith(isLoadingMore: false);
      getLogger().log(Level.error, 'Error fetching videos: $error');
      return {'status': false, 'data': [], 'msg': error.toString()};
    }
  }

  Future onRefresh() async {
    if (!ref.mounted) return;
    state = state.copyWith(isLoadingMore: true);
    await queryRcmdFeed('onRefresh');
  }

  Future onLoad() async {
    if (!ref.mounted) return;
    if (!state.isLoadingMore) {
      state = state.copyWith(isLoadingMore: true);
      await queryRcmdFeed('onLoad');
    }
  }

  void animateToTop() async {
    final BuildContext? context = rootNavigatorKey.currentContext;
    if (context == null) return;
    if (scrollController.offset >= MediaQuery.of(context).size.height * 5) {
      scrollController.jumpTo(0);
    } else {
      await scrollController.animateTo(0,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    }
  }

  void blockUserCb(int uid) {
    if (!ref.mounted) return;
    final newList = state.videoList.where((e) => e.uid != uid).toList();
    state = state.copyWith(videoList: newList);
    SmartDialog.showToast('已移除相关视频');
  }
}
