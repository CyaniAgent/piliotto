import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:piliotto/providers/repository_provider.dart';
import 'package:piliotto/models/common/dynamics_type.dart';
import 'package:piliotto/ottohub/models/dynamics/result.dart';
import 'package:piliotto/router/app_router.dart';
import 'package:piliotto/utils/feed_back.dart';
import 'package:piliotto/utils/responsive_util.dart';
import 'package:piliotto/utils/storage.dart';

part 'provider.g.dart';

class DynamicsState {
  final List<DynamicItemModel> dynamicsList;
  final DynamicsType dynamicsType;
  final String dynamicsTypeLabel;
  final int initialValue;
  final bool userLogin;
  final dynamic userInfo;
  final bool isLoadingDynamic;
  final int crossAxisCount;
  final String currentTab;
  final bool hasMore;
  final String wideScreenLayout;
  final int newDynamicsCount;

  const DynamicsState({
    this.dynamicsList = const [],
    this.dynamicsType = DynamicsType.all,
    this.dynamicsTypeLabel = '全部',
    this.initialValue = 0,
    this.userLogin = false,
    this.userInfo,
    this.isLoadingDynamic = true,
    this.crossAxisCount = 1,
    this.currentTab = 'latest',
    this.hasMore = true,
    this.wideScreenLayout = 'center',
    this.newDynamicsCount = 0,
  });

  DynamicsState copyWith({
    List<DynamicItemModel>? dynamicsList,
    DynamicsType? dynamicsType,
    String? dynamicsTypeLabel,
    int? initialValue,
    bool? userLogin,
    dynamic userInfo,
    bool? isLoadingDynamic,
    int? crossAxisCount,
    String? currentTab,
    bool? hasMore,
    String? wideScreenLayout,
    int? newDynamicsCount,
  }) {
    return DynamicsState(
      dynamicsList: dynamicsList ?? this.dynamicsList,
      dynamicsType: dynamicsType ?? this.dynamicsType,
      dynamicsTypeLabel: dynamicsTypeLabel ?? this.dynamicsTypeLabel,
      initialValue: initialValue ?? this.initialValue,
      userLogin: userLogin ?? this.userLogin,
      userInfo: userInfo ?? this.userInfo,
      isLoadingDynamic: isLoadingDynamic ?? this.isLoadingDynamic,
      crossAxisCount: crossAxisCount ?? this.crossAxisCount,
      currentTab: currentTab ?? this.currentTab,
      hasMore: hasMore ?? this.hasMore,
      wideScreenLayout: wideScreenLayout ?? this.wideScreenLayout,
      newDynamicsCount: newDynamicsCount ?? this.newDynamicsCount,
    );
  }
}

@riverpod
class DynamicsNotifier extends _$DynamicsNotifier {
  final ScrollController scrollController = ScrollController();
  Timer? _pollTimer;
  static const Duration _pollInterval = Duration(seconds: 30);
  String? _latestDynamicId;

  final Map<String, List<DynamicItemModel>> _tabDataCache = {
    'latest': [],
    'popular': [],
  };
  final Map<String, int> _tabOffsetCache = {
    'latest': 0,
    'popular': 0,
  };
  final Map<String, bool> _tabHasLoadedCache = {
    'latest': false,
    'popular': false,
  };

  List filterTypeList = [
    {'label': DynamicsType.all.labels, 'value': DynamicsType.all, 'enabled': true},
    {'label': DynamicsType.video.labels, 'value': DynamicsType.video, 'enabled': true},
    {'label': DynamicsType.pgc.labels, 'value': DynamicsType.pgc, 'enabled': true},
    {'label': DynamicsType.article.labels, 'value': DynamicsType.article, 'enabled': true},
  ];

  @override
  DynamicsState build() {
    dynamic userInfo;
    bool userLogin = false;
    try {
      userInfo = GStrorage.userInfo.get('userInfoCache');
      userLogin = userInfo != null;
    } catch (_) {
      userInfo = null;
      userLogin = false;
    }

    int initialValue = 0;
    DynamicsType dynamicsType = DynamicsType.all;
    String wideScreenLayout = 'center';
    try {
      initialValue = GStrorage.setting.get(SettingBoxKey.defaultDynamicType, defaultValue: 0);
      dynamicsType = DynamicsType.values[initialValue];
      wideScreenLayout = GStrorage.setting.get(
        SettingBoxKey.dynamicWideScreenLayout,
        defaultValue: 'center',
      );
    } catch (_) {
      initialValue = 0;
      dynamicsType = DynamicsType.all;
      wideScreenLayout = 'center';
    }

    final crossAxisCount = _calculateCrossAxisCount();
    _startPolling();

    ref.onDispose(() {
      _stopPolling();
      scrollController.dispose();
    });

    return DynamicsState(
      userInfo: userInfo,
      userLogin: userLogin,
      initialValue: initialValue,
      dynamicsType: dynamicsType,
      dynamicsTypeLabel: dynamicsType.labels,
      wideScreenLayout: wideScreenLayout,
      crossAxisCount: crossAxisCount,
      isLoadingDynamic: true,
    );
  }

  int _calculateCrossAxisCount() {
    try {
      return ResponsiveUtil.calculateCrossAxisCount(
        baseCount: 1,
        minCount: 1,
        maxCount: 2,
      );
    } catch (e) {
      return 1;
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) {
      _checkForNewDynamics();
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _checkForNewDynamics() async {
    if (state.currentTab != 'latest') return;
    if (state.isLoadingDynamic) return;

    try {
      final items = await ref.read(dynamicsRepositoryProvider).getNewBlogs(offset: 0, num: 10);
      if (items.isEmpty) return;

      final newLatestId = items.first.idStr;
      if (_latestDynamicId == null) {
        _latestDynamicId = newLatestId;
        return;
      }

      if (newLatestId != _latestDynamicId) {
        int count = 0;
        for (final item in items) {
          if (item.idStr == _latestDynamicId) break;
          count++;
        }
        if (count > 0) {
          state = state.copyWith(newDynamicsCount: count);
        }
      }
    } catch (e) {
      debugPrint('Poll error: $e');
    }
  }

  Future<void> loadNewDynamics() async {
    if (state.newDynamicsCount == 0) return;

    feedBack();
    state = state.copyWith(newDynamicsCount: 0);

    await queryFollowDynamic(type: 'init');

    if (scrollController.hasClients) {
      scrollController.jumpTo(0);
    }
  }

  void toggleWideScreenLayout() {
    final newLayout = state.wideScreenLayout == 'center' ? 'waterfall' : 'center';
    state = state.copyWith(wideScreenLayout: newLayout);
    try {
      GStrorage.setting.put(SettingBoxKey.dynamicWideScreenLayout, newLayout);
    } catch (_) {}
  }

  void updateCrossAxisCount() {
    final count = _calculateCrossAxisCount();
    state = state.copyWith(crossAxisCount: count);
  }

  Future<void> queryFollowDynamic({String type = 'init'}) async {
    final tab = state.currentTab;

    if (type == 'init') {
      _tabOffsetCache[tab] = 0;
    }

    state = state.copyWith(isLoadingDynamic: true);

    try {
      List<DynamicItemModel> items;

      if (tab == 'latest') {
        items = await ref.read(dynamicsRepositoryProvider).getNewBlogs(
          offset: _tabOffsetCache[tab]!,
          num: 10,
        );
      } else {
        items = await ref.read(dynamicsRepositoryProvider).getPopularBlogs(
          offset: _tabOffsetCache[tab]!,
          num: 10,
        );
      }

      if (type == 'init') {
        _tabDataCache[tab] = items;
        _tabOffsetCache[tab] = 10;
        if (tab == 'latest' && items.isNotEmpty) {
          _latestDynamicId = items.first.idStr;
        }
      } else {
        _tabDataCache[tab]!.addAll(items);
        _tabOffsetCache[tab] = _tabOffsetCache[tab]! + 10;
      }

      _tabHasLoadedCache[tab] = true;
      final hasMore = items.length >= 10;
      state = state.copyWith(
        dynamicsList: List.from(_tabDataCache[tab]!),
        hasMore: hasMore,
        isLoadingDynamic: false,
      );

      if (items.length < 10) {
        if (type != 'init') {
          SmartDialog.showToast('没有更多了');
        }
      }
    } catch (e) {
      state = state.copyWith(isLoadingDynamic: false);
      SmartDialog.showToast('请求失败: $e');
    }
  }

  void onTabChanged(String tab) {
    if (state.currentTab == tab) return;
    state = state.copyWith(currentTab: tab, newDynamicsCount: 0);
    if (_tabHasLoadedCache[tab] == true && _tabDataCache[tab]!.isNotEmpty) {
      state = state.copyWith(
        dynamicsList: List.from(_tabDataCache[tab]!),
        hasMore: _tabDataCache[tab]!.length % 10 == 0,
      );
    } else {
      state = state.copyWith(hasMore: true);
      queryFollowDynamic(type: 'init');
    }
  }

  Future<void> onSelectType(dynamic value) async {
    final dynamicsType = filterTypeList[value]['value'] as DynamicsType;
    state = state.copyWith(
      dynamicsType: dynamicsType,
      dynamicsTypeLabel: dynamicsType.labels,
      dynamicsList: [],
      initialValue: value,
    );
    await queryFollowDynamic();
    scrollController.jumpTo(0);
  }

  Future<bool> pushDetail(BuildContext context, DynamicItemModel? item, int floor,
      {String action = 'all'}) async {
    feedBack();
    if (action == 'comment') {
      context.push('/dynamicDetail', extra: {'item': item, 'floor': floor, 'action': action});
      return false;
    }
    switch (item!.type) {
      case 'DYNAMIC_TYPE_DRAW':
        context.push('/dynamicDetail', extra: {'item': item, 'floor': floor});
        break;
      case 'DYNAMIC_TYPE_WORD':
        context.push('/dynamicDetail', extra: {'item': item, 'floor': floor});
        break;
      default:
        SmartDialog.showToast('暂不支持的动态类型');
    }
    return false;
  }

  Future<void> onRefresh() async {
    state = state.copyWith(newDynamicsCount: 0);
    await queryFollowDynamic();
  }

  void animateToTop([BuildContext? ctx]) async {
    final BuildContext? context = ctx ?? rootNavigatorKey.currentContext;
    if (context == null) return;
    if (scrollController.offset >= MediaQuery.of(context).size.height * 5) {
      scrollController.jumpTo(0);
    } else {
      await scrollController.animateTo(0,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    }
  }

  void resetSearch() {
    state = state.copyWith(
      dynamicsType: DynamicsType.all,
      dynamicsTypeLabel: DynamicsType.all.labels,
      initialValue: 0,
      dynamicsList: [],
    );
    SmartDialog.showToast('还原默认加载');
    queryFollowDynamic();
  }
}
