import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/api/services/old_api_service.dart';
// TODO: 迁移到 Ottohub API
// import 'package:piliotto/http/dynamics.dart';
import 'package:piliotto/models/common/dynamics_type.dart';
import 'package:piliotto/models/dynamics/result.dart';
import 'package:piliotto/models/dynamics/up.dart';
import 'package:piliotto/utils/feed_back.dart';
import 'package:piliotto/utils/responsive_util.dart';

import 'package:piliotto/utils/storage.dart';

class DynamicsController extends GetxController {
  int page = 1;
  String? offset = '';
  RxList<DynamicItemModel> dynamicsList = <DynamicItemModel>[].obs;
  Rx<DynamicsType> dynamicsType = DynamicsType.values[0].obs;
  RxString dynamicsTypeLabel = '全部'.obs;
  final ScrollController scrollController = ScrollController();
  Rx<FollowUpModel> upData = FollowUpModel().obs;
  RxInt mid = (-1).obs;
  Rx<UpItem> upInfo = UpItem().obs;
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
  RxBool isLoadingDynamic = false.obs;
  Box setting = GStrorage.setting;
  RxInt crossAxisCount = 1.obs;

  // Ottohub 模式相关
  RxBool isOttohubMode = true.obs;
  RxString currentTab = 'latest'.obs; // 'latest' or 'popular'

  // 每个 tab 独立的数据缓存
  Map<String, List<DynamicItemModel>> _tabDataCache = {
    'latest': [],
    'popular': [],
  };
  Map<String, int> _tabOffsetCache = {
    'latest': 0,
    'popular': 0,
  };
  Map<String, bool> _tabHasLoadedCache = {
    'latest': false,
    'popular': false,
  };

  RxBool hasMore = true.obs;

  // 宽屏布局模式: 'center' 居中, 'waterfall' 瀑布流
  RxString wideScreenLayout = 'center'.obs;

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
    updateCrossAxisCount();
  }

  // 切换宽屏布局模式
  void toggleWideScreenLayout() {
    if (wideScreenLayout.value == 'center') {
      wideScreenLayout.value = 'waterfall';
    } else {
      wideScreenLayout.value = 'center';
    }
    setting.put(SettingBoxKey.dynamicWideScreenLayout, wideScreenLayout.value);
  }

  // 根据屏幕宽度更新列数
  void updateCrossAxisCount() {
    try {
      int baseCount = ResponsiveUtil.calculateCrossAxisCount(
        baseCount: 1,
        minCount: 1,
        maxCount: 2,
      );

      crossAxisCount.value = baseCount;
    } catch (e) {
      crossAxisCount.value = 1;
    }
  }

  Future queryFollowDynamic({type = 'init'}) async {
    // Ottohub 模式使用旧版 API
    if (isOttohubMode.value) {
      return await _queryOttohubDynamic(type: type);
    }

    // TODO: 迁移到 Ottohub API
    // 原始 B站 API 已禁用
    // if (!userLogin.value) {
    //   return {'status': false, 'msg': '账号未登录', 'code': -101};
    // }
    // if (type == 'init') {
    //   dynamicsList.clear();
    // }
    // // 下拉刷新数据渲染时会触发onLoad
    // if (type == 'onLoad' && page == 1) {
    //   return;
    // }
    // isLoadingDynamic.value = true;
    // var res = await DynamicsHttp.followDynamic(
    //   page: type == 'init' ? 1 : page,
    //   type: dynamicsType.value.values,
    //   offset: offset,
    //   mid: mid.value,
    // );
    // isLoadingDynamic.value = false;
    // if (res['status']) {
    //   if (type == 'onLoad' && res['data'].items.isEmpty) {
    //     SmartDialog.showToast('没有更多了');
    //     return;
    //   }
    //   if (type == 'init') {
    //     dynamicsList.value = res['data'].items;
    //   } else {
    //     dynamicsList.addAll(res['data'].items);
    //   }
    //   offset = res['data'].offset;
    //   page++;
    // }
    // return res;
    return {'status': false, 'msg': 'TODO: 迁移到 Ottohub API'};
  }

  // Ottohub 动态查询
  Future _queryOttohubDynamic({type = 'init'}) async {
    final tab = currentTab.value;

    // 刷新时不清空数据，等请求完成后再替换
    if (type == 'init') {
      _tabOffsetCache[tab] = 0;
    }

    isLoadingDynamic.value = true;

    try {
      Map<String, dynamic> res;
      if (tab == 'latest') {
        res = await OldApiService.getNewBlogList(
          offset: _tabOffsetCache[tab]!,
          num: 10,
        );
      } else {
        res = await OldApiService.getPopularBlogList(
          offset: _tabOffsetCache[tab]!,
          num: 10,
        );
      }

      isLoadingDynamic.value = false;

      if (res['status'] == 'success') {
        final List<dynamic> blogList = res['blog_list'] as List;
        final items = blogList.map((blog) {
          return DynamicItemModel.fromJson(blog);
        }).toList();

        if (type == 'init') {
          // 刷新时替换数据
          _tabDataCache[tab] = items;
          _tabOffsetCache[tab] = 10;
        } else {
          // 加载更多时追加数据
          _tabDataCache[tab]!.addAll(items);
          _tabOffsetCache[tab] = _tabOffsetCache[tab]! + 10;
        }

        _tabHasLoadedCache[tab] = true;
        hasMore.value = items.length >= 10;

        // 更新当前显示的列表
        dynamicsList.value = List.from(_tabDataCache[tab]!);

        if (items.length < 10) {
          hasMore.value = false;
          if (type != 'init') {
            SmartDialog.showToast('没有更多了');
          }
        }
      } else {
        SmartDialog.showToast(res['message'] ?? '获取动态失败');
      }
    } catch (e) {
      isLoadingDynamic.value = false;
      SmartDialog.showToast('请求失败: $e');
    }
  }

  // 切换标签
  void onTabChanged(String tab) {
    if (currentTab.value == tab) return;

    currentTab.value = tab;

    // 如果该 tab 已经加载过数据，直接显示缓存
    if (_tabHasLoadedCache[tab] == true && _tabDataCache[tab]!.isNotEmpty) {
      dynamicsList.value = List.from(_tabDataCache[tab]!);
      hasMore.value = _tabDataCache[tab]!.length % 10 == 0;
    } else {
      // 否则请求数据
      hasMore.value = true;
      queryFollowDynamic(type: 'init');
    }
  }

  // 获取当前 tab 的数据列表（供 view 使用）
  List<DynamicItemModel> getTabData(String tab) {
    return _tabDataCache[tab] ?? [];
  }

  // 检查 tab 是否已加载
  bool hasTabLoaded(String tab) {
    return _tabHasLoadedCache[tab] ?? false;
  }

  // 切换模式
  void toggleMode() {
    isOttohubMode.value = !isOttohubMode.value;
    _tabDataCache = {
      'latest': [],
      'popular': [],
    };
    _tabOffsetCache = {
      'latest': 0,
      'popular': 0,
    };
    _tabHasLoadedCache = {
      'latest': false,
      'popular': false,
    };
    page = 1;
    hasMore.value = true;
    queryFollowDynamic(type: 'init');
  }

  onSelectType(value) async {
    dynamicsType.value = filterTypeList[value]['value'];
    dynamicsList.value = <DynamicItemModel>[];
    page = 1;
    initialValue.value = value;
    await queryFollowDynamic();
    scrollController.jumpTo(0);
  }

  pushDetail(item, floor, {action = 'all'}) async {
    feedBack();

    /// 点击评论action 直接查看评论
    if (action == 'comment') {
      Get.toNamed('/dynamicDetail',
          arguments: {'item': item, 'floor': floor, 'action': action});
      return false;
    }
    switch (item!.type) {
      /// 图文动态查看
      case 'DYNAMIC_TYPE_DRAW':
        Get.toNamed('/dynamicDetail',
            arguments: {'item': item, 'floor': floor});
        break;

      /// 纯文字动态查看
      case 'DYNAMIC_TYPE_WORD':
        Get.toNamed('/dynamicDetail',
            arguments: {'item': item, 'floor': floor});
        break;

      default:
        SmartDialog.showToast('暂不支持的动态类型');
    }
  }

  Future queryFollowUp({type = 'init'}) async {
    // TODO: 迁移到 Ottohub FollowingService API
    // if (!userLogin.value) {
    //   return {'status': false, 'msg': '账号未登录', 'code': -101};
    // }
    // if (type == 'init') {
    //   upData.value.upList = <UpItem>[];
    //   upData.value.liveList = <LiveUserItem>[];
    // }
    // var res = await DynamicsHttp.followUp();
    // if (res['status']) {
    //   upData.value = res['data'];
    //   if (upData.value.upList!.isEmpty) {
    //     mid.value = -1;
    //   }
    //   upData.value.upList!.insertAll(0, [
    //     UpItem(face: '', uname: '全部动态', mid: -1),
    //     UpItem(face: userInfo.face, uname: '我', mid: userInfo.mid),
    //   ]);
    // }
    // return res;
    return {'status': false, 'msg': 'TODO: 迁移到 Ottohub FollowingService API'};
  }

  onSelectUp(mid) async {
    dynamicsType.value = DynamicsType.values[0];
    dynamicsList.value = <DynamicItemModel>[];
    page = 1;
    queryFollowDynamic();
  }

  onRefresh() async {
    page = 1;
    await queryFollowUp();
    await queryFollowDynamic();
  }

  // 返回顶部并刷新
  void animateToTop() async {
    if (scrollController.offset >=
        MediaQuery.of(Get.context!).size.height * 5) {
      scrollController.jumpTo(0);
    } else {
      await scrollController.animateTo(0,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    }
  }

  // 重置搜索
  void resetSearch() {
    mid.value = -1;
    dynamicsType.value = DynamicsType.values[0];
    initialValue.value = 0;
    SmartDialog.showToast('还原默认加载');
    dynamicsList.value = <DynamicItemModel>[];
    queryFollowDynamic();
  }

  // 点击up主
  void onTapUp(data) {
    mid.value = data.mid;
    upInfo.value = data;
    onSelectUp(data.mid);
  }
}
