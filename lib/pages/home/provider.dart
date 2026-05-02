import 'dart:async';

import 'package:piliotto/models/common/tab_type.dart';
import 'package:piliotto/providers/repository_provider.dart';
import 'package:piliotto/utils/storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'provider.g.dart';

class HomeState {
  final List<Map<String, dynamic>> tabs;
  final int initialIndex;
  final bool userLogin;
  final String userFace;
  final bool hideSearchBar;
  final String defaultSearch;
  final bool enableGradientBg;

  const HomeState({
    this.tabs = const [],
    this.initialIndex = 0,
    this.userLogin = false,
    this.userFace = '',
    this.hideSearchBar = false,
    this.defaultSearch = '搜索视频',
    this.enableGradientBg = true,
  });

  HomeState copyWith({
    List<Map<String, dynamic>>? tabs,
    int? initialIndex,
    bool? userLogin,
    String? userFace,
    bool? hideSearchBar,
    String? defaultSearch,
    bool? enableGradientBg,
  }) {
    return HomeState(
      tabs: tabs ?? this.tabs,
      initialIndex: initialIndex ?? this.initialIndex,
      userLogin: userLogin ?? this.userLogin,
      userFace: userFace ?? this.userFace,
      hideSearchBar: hideSearchBar ?? this.hideSearchBar,
      defaultSearch: defaultSearch ?? this.defaultSearch,
      enableGradientBg: enableGradientBg ?? this.enableGradientBg,
    );
  }
}

@riverpod
class HomeNotifier extends _$HomeNotifier {
  final StreamController<bool> searchBarStream = StreamController<bool>.broadcast();

  @override
  HomeState build() {
    bool userLogin = false;
    String userFace = '';
    bool hideSearchBar = false;
    bool enableGradientBg = true;

    try {
      final userInfo = GStrorage.userInfo.get('userInfoCache');
      userLogin = userInfo != null;
      userFace = userInfo != null ? userInfo.face : '';
      hideSearchBar = GStrorage.setting.get(SettingBoxKey.hideSearchBar, defaultValue: false);
      enableGradientBg = GStrorage.setting.get(SettingBoxKey.enableGradientBg, defaultValue: true);
    } catch (_) {}

    final (tabs, initialIndex) = _getTabConfig();

    if (GStrorage.setting.get(SettingBoxKey.enableSearchWord, defaultValue: true)) {
      _searchDefault();
    }

    return HomeState(
      userLogin: userLogin,
      userFace: userFace,
      hideSearchBar: hideSearchBar,
      enableGradientBg: enableGradientBg,
      tabs: tabs,
      initialIndex: initialIndex,
    );
  }

  (List<Map<String, dynamic>>, int) _getTabConfig() {
    List<Map<String, dynamic>> defaultTabs = [...tabsConfig];
    List<String> tabbarSort;
    try {
      tabbarSort = GStrorage.setting.get(SettingBoxKey.tabbarSort, defaultValue: ['rcmd', 'hot']);
    } catch (_) {
      tabbarSort = ['rcmd', 'hot'];
    }

    defaultTabs.retainWhere((item) => tabbarSort.contains((item['type'] as TabType).id));
    defaultTabs.sort((a, b) => tabbarSort
        .indexOf((a['type'] as TabType).id)
        .compareTo(tabbarSort.indexOf((b['type'] as TabType).id)));

    int initialIndex = 0;
    if (tabbarSort.contains(TabType.rcmd.id)) {
      initialIndex = tabbarSort.indexOf(TabType.rcmd.id);
    }

    return (defaultTabs, initialIndex);
  }

  Future<void> _searchDefault() async {
    try {
      final videoRepo = ref.read(videoRepositoryProvider);
      final response = await videoRepo.getPopularVideos(
        timeLimit: 7,
        offset: 0,
        num: 10,
      );
      if (response.videoList.isNotEmpty) {
        final random = DateTime.now().millisecondsSinceEpoch % response.videoList.length;
        state = state.copyWith(defaultSearch: response.videoList[random].title);
      }
    } catch (e) {
      state = state.copyWith(defaultSearch: '搜索视频');
    }
  }

  void updateLoginStatus(bool val) {
    dynamic userInfo;
    try {
      userInfo = GStrorage.userInfo.get('userInfoCache');
    } catch (_) {
      userInfo = null;
    }
    state = state.copyWith(
      userLogin: val,
      userFace: val && userInfo != null ? userInfo.face : '',
    );
  }

  void setInitialIndex(int index) {
    state = state.copyWith(initialIndex: index);
  }
}
