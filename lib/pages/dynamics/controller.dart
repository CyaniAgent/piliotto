import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:piliotto/api/services/following_service.dart';
import 'package:piliotto/api/services/old_api_service.dart';
import 'package:piliotto/api/services/api_service.dart';
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

  RxString currentTab = 'following'.obs;
  final Map<String, List<DynamicItemModel>> _tabDataCache = {
    'following': [],
    'latest': [],
    'popular': [],
  };
  final Map<String, int> _tabOffsetCache = {
    'following': 0,
    'latest': 0,
    'popular': 0,
  };
  final Map<String, bool> _tabHasLoadedCache = {
    'following': false,
    'latest': false,
    'popular': false,
  };
  RxBool hasMore = true.obs;
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

  void toggleWideScreenLayout() {
    if (wideScreenLayout.value == 'center') {
      wideScreenLayout.value = 'waterfall';
    } else {
      wideScreenLayout.value = 'center';
    }
    setting.put(SettingBoxKey.dynamicWideScreenLayout, wideScreenLayout.value);
  }

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
    final tab = currentTab.value;

    if (type == 'init') {
      _tabOffsetCache[tab] = 0;
    }

    isLoadingDynamic.value = true;

    try {
      List<DynamicItemModel> items;

      if (tab == 'following') {
        items = await _queryFollowingTimeline(type: type);
      } else if (tab == 'latest') {
        items = await _queryLatestBlogs(type: type);
      } else {
        items = await _queryPopularBlogs(type: type);
      }

      isLoadingDynamic.value = false;

      if (type == 'init') {
        _tabDataCache[tab] = items;
        _tabOffsetCache[tab] = 10;
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
    } on ApiException catch (e) {
      isLoadingDynamic.value = false;
      if (e.message == 'Token required') {
        SmartDialog.showToast('请先登录查看关注动态');
      } else {
        SmartDialog.showToast('请求失败: ${e.message}');
      }
    } catch (e) {
      isLoadingDynamic.value = false;
      SmartDialog.showToast('请求失败: $e');
    }
  }

  Future<List<DynamicItemModel>> _queryFollowingTimeline(
      {type = 'init'}) async {
    final response = await FollowingService.getFollowingTimeline(
      offset: _tabOffsetCache['following']!,
      num: 10,
    );
    return response.timelineList.map((timelineItem) {
      return DynamicItemModel.fromTimelineItem(timelineItem);
    }).toList();
  }

  Future<List<DynamicItemModel>> _queryLatestBlogs({type = 'init'}) async {
    final res = await OldApiService.getNewBlogList(
      offset: _tabOffsetCache['latest']!,
      num: 10,
    );

    if (res['status'] == 'success') {
      final List<dynamic> blogList = res['blog_list'] as List;
      return blogList.map((blog) {
        return DynamicItemModel.fromJson(blog);
      }).toList();
    } else {
      throw Exception(res['message'] ?? '获取最新动态失败');
    }
  }

  Future<List<DynamicItemModel>> _queryPopularBlogs({type = 'init'}) async {
    final res = await OldApiService.getPopularBlogList(
      offset: _tabOffsetCache['popular']!,
      num: 10,
    );

    if (res['status'] == 'success') {
      final List<dynamic> blogList = res['blog_list'] as List;
      return blogList.map((blog) {
        return DynamicItemModel.fromJson(blog);
      }).toList();
    } else {
      throw Exception(res['message'] ?? '获取热门动态失败');
    }
  }

  void onTabChanged(String tab) {
    if (currentTab.value == tab) return;
    currentTab.value = tab;
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
    if (action == 'comment') {
      Get.toNamed('/dynamicDetail',
          arguments: {'item': item, 'floor': floor, 'action': action});
      return false;
    }
    switch (item!.type) {
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
  }

  Future queryFollowUp({type = 'init'}) async {
    if (!userLogin.value || userInfo == null) {
      return {'status': false, 'msg': '账号未登录'};
    }
    if (type == 'init') {
      upData.value.upList = <UpItem>[];
    }
    try {
      final uid = userInfo.mid as int;
      final response = await FollowingService.getFollowingList(
        uid: uid,
        offset: 0,
        num: 12,
      );
      final upList = response.userList.map((user) {
        return UpItem(
          face: user.avatarUrl,
          uname: user.username,
          mid: user.uid,
        );
      }).toList();
      upData.value.upList = upList;
      if (upList.isEmpty) {
        mid.value = -1;
      }
      upData.value.upList!.insertAll(0, [
        UpItem(face: '', uname: '全部动态', mid: -1),
        UpItem(face: userInfo.face, uname: '我', mid: userInfo.mid),
      ]);
      return {'status': true};
    } on ApiException catch (e) {
      return {'status': false, 'msg': e.message};
    } catch (e) {
      return {'status': false, 'msg': e.toString()};
    }
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

  void animateToTop() async {
    if (scrollController.offset >=
        MediaQuery.of(Get.context!).size.height * 5) {
      scrollController.jumpTo(0);
    } else {
      await scrollController.animateTo(0,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    }
  }

  void resetSearch() {
    mid.value = -1;
    dynamicsType.value = DynamicsType.values[0];
    initialValue.value = 0;
    SmartDialog.showToast('还原默认加载');
    dynamicsList.value = <DynamicItemModel>[];
    queryFollowDynamic();
  }

  void onTapUp(data) {
    mid.value = data.mid;
    upInfo.value = data;
    onSelectUp(data.mid);
  }
}
