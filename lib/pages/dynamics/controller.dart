import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/repositories/i_dynamics_repository.dart';
import 'package:piliotto/models/common/dynamics_type.dart';
import 'package:piliotto/ottohub/models/dynamics/result.dart';
import 'package:piliotto/utils/feed_back.dart';

import 'package:piliotto/utils/storage.dart';

class DynamicsController extends GetxController {
  final IDynamicsRepository _dynamicsRepo = Get.find<IDynamicsRepository>();
  int page = 1;
  String? offset = '';
  RxList<DynamicItemModel> dynamicsList = <DynamicItemModel>[].obs;
  Rx<DynamicsType> dynamicsType = DynamicsType.values[0].obs;
  RxString dynamicsTypeLabel = '全部'.obs;
  List filterTypeList = [
    {
      'label': DynamicsType.all.labels,
      'value': DynamicsType.all,
      'enabled': true
    },
    {
      'label': DynamicsType.video.labels,
      'value': DynamicsType.video,
      'enabled': true
    },
    {
      'label': DynamicsType.pgc.labels,
      'value': DynamicsType.pgc,
      'enabled': true
    },
    {
      'label': DynamicsType.article.labels,
      'value': DynamicsType.article,
      'enabled': true
    },
  ];
  bool flag = false;
  RxInt initialValue = 0.obs;
  Box userInfoCache = GStrorage.userInfo;
  RxBool userLogin = false.obs;
  dynamic userInfo;
  final Map<String, RxBool> tabLoadingStates = {
    'latest': false.obs,
    'popular': false.obs,
  };
  Box setting = GStrorage.setting;

  RxString currentTab = 'latest'.obs;
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
  final Map<String, ScrollController> tabScrollControllers = {
    'latest': ScrollController(),
    'popular': ScrollController(),
  };
  RxBool hasMore = true.obs;
  RxString wideScreenLayout = 'center'.obs;
  RxInt waterfallCrossAxisCount = 3.obs;
  RxBool waterfallLimitWidth = false.obs;
  RxDouble waterfallCustomItemWidth = 300.0.obs;
  RxBool waterfallUseCustomItemWidth = false.obs;

  // 缓存的瀑布流计算结果
  int _cachedAutoCrossAxisCount = 3;
  double _cachedItemWidth = 300.0;
  int _cachedEffectiveCrossAxisCount = 3;
  double _lastScreenWidth = 0;

  Timer? _pollTimer;
  static const Duration _pollInterval = Duration(seconds: 30);
  RxInt newDynamicsCount = 0.obs;
  String? _latestDynamicId;

  @override
  void onInit() {
    userInfo = userInfoCache.get('userInfoCache');
    userLogin.value = userInfo != null;
    super.onInit();
    initialValue.value =
        setting.get(SettingBoxKey.defaultDynamicType, defaultValue: 0);
    dynamicsType = DynamicsType.values[initialValue.value].obs;
    wideScreenLayout.value = setting.get(
      SettingBoxKey.dynamicWideScreenLayout,
      defaultValue: 'center',
    );
    waterfallCrossAxisCount.value = setting.get(
      SettingBoxKey.waterfallCrossAxisCount,
      defaultValue: 3,
    );
    waterfallLimitWidth.value = setting.get(
      SettingBoxKey.waterfallLimitWidth,
      defaultValue: false,
    );
    waterfallCustomItemWidth.value = setting.get(
      SettingBoxKey.waterfallCustomItemWidth,
      defaultValue: 300.0,
    );
    waterfallUseCustomItemWidth.value = setting.get(
      SettingBoxKey.waterfallUseCustomItemWidth,
      defaultValue: false,
    );
    _startPolling();
  }

  @override
  void onClose() {
    _stopPolling();
    for (final controller in tabScrollControllers.values) {
      controller.dispose();
    }
    super.onClose();
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
    if (currentTab.value != 'latest') return;
    if (tabLoadingStates['latest']!.value) return;

    try {
      final items = await _dynamicsRepo.getNewBlogs(offset: 0, num: 10);
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
          newDynamicsCount.value = count;
        }
      }
    } catch (e) {
      debugPrint('Poll error: $e');
    }
  }

  Future<void> loadNewDynamics() async {
    if (newDynamicsCount.value == 0) return;

    feedBack();
    newDynamicsCount.value = 0;

    await queryFollowDynamic(type: 'init');

    scrollToTop();
  }

  void scrollToTop([String? tab]) {
    final targetTab = tab ?? currentTab.value;
    final controller = tabScrollControllers[targetTab];

    if (controller != null && controller.hasClients) {
      if (controller.offset >= 1000) {
        controller.jumpTo(0);
      } else {
        controller.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void toggleWideScreenLayout() {
    if (wideScreenLayout.value == 'center') {
      wideScreenLayout.value = 'waterfall';
    } else {
      wideScreenLayout.value = 'center';
    }
    setting.put(SettingBoxKey.dynamicWideScreenLayout, wideScreenLayout.value);
  }

  void setWaterfallCrossAxisCount(int count) {
    waterfallCrossAxisCount.value = count.clamp(2, 6);
    setting.put(
        SettingBoxKey.waterfallCrossAxisCount, waterfallCrossAxisCount.value);
  }

  void toggleWaterfallLimitWidth([bool? value]) {
    waterfallLimitWidth.value = value ?? !waterfallLimitWidth.value;
    setting.put(SettingBoxKey.waterfallLimitWidth, waterfallLimitWidth.value);
    _invalidateCache();
  }

  void toggleWaterfallUseCustomItemWidth([bool? value]) {
    waterfallUseCustomItemWidth.value =
        value ?? !waterfallUseCustomItemWidth.value;
    setting.put(SettingBoxKey.waterfallUseCustomItemWidth,
        waterfallUseCustomItemWidth.value);
    _invalidateCache();
  }

  void setWaterfallCustomItemWidth(double width) {
    waterfallCustomItemWidth.value = width.clamp(200.0, 600.0);
    setting.put(
        SettingBoxKey.waterfallCustomItemWidth, waterfallCustomItemWidth.value);
  }

  void _invalidateCache() {
    _lastScreenWidth = 0;
  }

  double getEffectiveItemWidth(
      double screenWidth, int autoCrossAxisCount, double crossAxisSpacing) {
    if (waterfallUseCustomItemWidth.value) {
      return waterfallCustomItemWidth.value;
    }
    return calculateItemWidth(
        screenWidth, autoCrossAxisCount, crossAxisSpacing);
  }

  void updateWaterfallCache(double screenWidth,
      {double minItemWidth = 300.0, double crossAxisSpacing = 12.0}) {
    if ((_lastScreenWidth - screenWidth).abs() < 1.0) {
      return;
    }
    _lastScreenWidth = screenWidth;
    _cachedAutoCrossAxisCount =
        calculateAutoCrossAxisCount(screenWidth, minItemWidth);
    _cachedItemWidth = waterfallUseCustomItemWidth.value
        ? waterfallCustomItemWidth.value
        : calculateItemWidth(
            screenWidth, _cachedAutoCrossAxisCount, crossAxisSpacing);
    _cachedEffectiveCrossAxisCount = waterfallLimitWidth.value
        ? waterfallCrossAxisCount.value.clamp(2, _cachedAutoCrossAxisCount)
        : _cachedAutoCrossAxisCount;
  }

  int get cachedAutoCrossAxisCount => _cachedAutoCrossAxisCount;
  double get cachedItemWidth => _cachedItemWidth;
  int get cachedEffectiveCrossAxisCount => _cachedEffectiveCrossAxisCount;

  double getAutoItemWidth(double screenWidth, double crossAxisSpacing) {
    return calculateItemWidth(
        screenWidth, _cachedAutoCrossAxisCount, crossAxisSpacing);
  }

  int calculateAutoCrossAxisCount(double screenWidth, double minItemWidth) {
    final count = (screenWidth / minItemWidth).floor();
    return count.clamp(2, 6);
  }

  double calculateItemWidth(
      double screenWidth, int autoCrossAxisCount, double crossAxisSpacing) {
    return (screenWidth - (autoCrossAxisCount - 1) * crossAxisSpacing) /
        autoCrossAxisCount;
  }

  int getEffectiveCrossAxisCount(double screenWidth, double minItemWidth) {
    final autoCount = calculateAutoCrossAxisCount(screenWidth, minItemWidth);
    if (!waterfallLimitWidth.value) {
      return autoCount;
    }
    return waterfallCrossAxisCount.value.clamp(2, autoCount);
  }

  Future<void> queryFollowDynamic({String type = 'init'}) async {
    final tab = currentTab.value;

    if (type == 'init') {
      _tabOffsetCache[tab] = 0;
    }

    tabLoadingStates[tab]!.value = true;

    try {
      List<DynamicItemModel> items;

      if (tab == 'latest') {
        items = await _queryLatestBlogs(type: type);
      } else {
        items = await _queryPopularBlogs(type: type);
      }

      tabLoadingStates[tab]!.value = false;

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
      hasMore.value = items.length >= 10;
      dynamicsList.value = List.from(_tabDataCache[tab]!);

      if (items.length < 10) {
        hasMore.value = false;
        if (type != 'init') {
          SmartDialog.showToast('没有更多了');
        }
      }
    } catch (e) {
      tabLoadingStates[tab]!.value = false;
      if (e is SocketException) {
        SmartDialog.showToast('网络连接失败，请检查网络设置');
      } else {
        SmartDialog.showToast('请求失败: $e');
      }
    }
  }

  Future<List<DynamicItemModel>> _queryLatestBlogs(
      {String type = 'init'}) async {
    return _dynamicsRepo.getNewBlogs(
      offset: _tabOffsetCache['latest']!,
      num: 10,
    );
  }

  Future<List<DynamicItemModel>> _queryPopularBlogs(
      {String type = 'init'}) async {
    return _dynamicsRepo.getPopularBlogs(
      offset: _tabOffsetCache['popular']!,
      num: 10,
    );
  }

  void onTabChanged(String tab) {
    if (currentTab.value == tab) return;
    currentTab.value = tab;
    newDynamicsCount.value = 0;
    if (_tabHasLoadedCache[tab] == true && _tabDataCache[tab]!.isNotEmpty) {
      dynamicsList.value = List.from(_tabDataCache[tab]!);
      hasMore.value = _tabDataCache[tab]!.length % 10 == 0;
    } else {
      hasMore.value = true;
      queryFollowDynamic(type: 'init');
    }
  }

  List<DynamicItemModel> getTabData(String tab) {
    return _tabDataCache[tab] ?? [];
  }

  bool hasTabLoaded(String tab) {
    return _tabHasLoadedCache[tab] ?? false;
  }

  Future<bool> pushDetail(DynamicItemModel item, int floor,
      {String action = 'all'}) async {
    feedBack();
    if (action == 'comment') {
      Get.toNamed('/dynamicDetail',
          arguments: {'item': item, 'floor': floor, 'action': action});
      return false;
    }
    switch (item.type) {
      case 'DYNAMIC_TYPE_DRAW':
        Get.toNamed('/dynamicDetail',
            arguments: {'item': item, 'floor': floor});
        break;
      case 'DYNAMIC_TYPE_WORD':
        Get.toNamed('/dynamicDetail',
            arguments: {'item': item, 'floor': floor});
        break;
      default:
        SmartDialog.showToast('暂不支持的动态类型');
    }
    return false;
  }

  Future<void> onRefresh() async {
    page = 1;
    newDynamicsCount.value = 0;
    await queryFollowDynamic();
  }

  void resetSearch() {
    dynamicsType.value = DynamicsType.values[0];
    initialValue.value = 0;
    SmartDialog.showToast('还原默认加载');
    dynamicsList.value = <DynamicItemModel>[];
    queryFollowDynamic();
  }
}
