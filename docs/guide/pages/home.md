---
date: 2026-05-14 22:45:48
title: home
permalink: /pages/3c19c4
categories:
  - guide
  - pages
---
# 首页模块（Home）

## 1. 模块概述

首页模块是 PiliOtto 的应用入口页面，路由为 `/`。它提供一个多 Tab 的内容聚合界面，通过 **推荐** 和 **热门** 两个 Tab 展示视频内容。

模块采用 **Controller-View 分离** + **GetX 响应式状态管理** 的架构模式，由以下核心文件组成：

```
lib/pages/home/
├── controller.dart            # HomeController - 页面状态与 Tab 配置管理
├── view.dart                  # HomePage - 页面视图（含 CustomAppBar、UserInfoWidget、HomeSearchBar）
├── index.dart                 # 统一导出
└── widgets/
    └── app_bar.dart           # HomeAppBar - SliverAppBar 式顶部栏（备用）
```

### 子模块依赖

首页 Tab 的内容区域由两个独立的子页面模块提供：

| Tab | 对应模块 | 路径 |
|-----|---------|------|
| 推荐 (`rcmd`) | `RcmdPage` | `lib/pages/rcmd/` |
| 热门 (`hot`) | `HotPage` | `lib/pages/hot/` |

这两个子模块通过 `TabType` 枚举进行配置映射，定义在 `lib/models/common/tab_type.dart` 中：

```dart
enum TabType { rcmd, hot }

List tabsConfig = [
  {
    'label': '推荐',
    'type': TabType.rcmd,
    'ctr': Get.find<RcmdController>,
    'page': const RcmdPage(),
  },
  {
    'label': '热门',
    'type': TabType.hot,
    'ctr': Get.find<HotController>,
    'page': const HotPage(),
  },
];
```

---

## 2. Controller 详解

`HomeController` 负责管理首页的 Tab 配置、搜索默认词、用户状态等全局性状态。

### 2.1 类定义与 Mixin

```dart
class HomeController extends GetxController with GetTickerProviderStateMixin
```

- 继承 `GetxController`：获得 GetX 生命周期管理（`onInit` / `onClose`）
- 混入 `GetTickerProviderStateMixin`：作为 `TabController` 的 `vsync` 提供者

### 2.2 Rx 响应式状态

| 变量 | 类型 | 说明 |
|------|------|------|
| `tabs` | `RxList` | 当前生效的 Tab 配置列表，由 `setTabConfig()` 动态生成 |
| `initialIndex` | `RxInt` | 当前选中 Tab 的索引，初始为推荐（rcmd）Tab 的位置 |
| `userLogin` | `RxBool` | 用户登录状态，从 Hive 缓存读取 |
| `userFace` | `RxString` | 当前用户头像 URL，用于顶部栏头像展示 |
| `defaultSearch` | `RxString` | 搜索栏占位提示文字，从热门视频中随机选取标题 |

### 2.3 非 Rx 关键属性

| 变量 | 类型 | 说明 |
|------|------|------|
| `tabController` | `TabController` | Flutter 原生 Tab 控制器，绑定 `TabBar` + `TabBarView` |
| `tabsCtrList` | `List` | 各 Tab 对应的子 Controller 获取函数列表（如 `Get.find<RcmdController>`） |
| `tabsPageList` | `List<Widget>` | 各 Tab 对应的页面组件列表 |
| `searchBarStream` | `StreamController<bool>` | 广播流，用于控制搜索栏的显示/隐藏动画 |
| `hideSearchBar` | `bool` | 是否隐藏搜索栏，从设置中读取 |
| `enableGradientBg` | `bool` | 是否启用渐变背景，影响 Tab 切换动画监听 |

### 2.4 生命周期方法

**`onInit()`**

```dart
void onInit() {
  super.onInit();
  userInfo = userInfoCache.get('userInfoCache');    // 从 Hive 读取用户缓存
  userLogin.value = userInfo != null;
  userFace.value = userInfo != null ? userInfo.face : '';
  hideSearchBar = setting.get(SettingBoxKey.hideSearchBar, defaultValue: false);
  if (setting.get(SettingBoxKey.enableSearchWord, defaultValue: true)) {
    searchDefault();  // 获取搜索默认词
  }
  enableGradientBg = setting.get(SettingBoxKey.enableGradientBg, defaultValue: true);
  setTabConfig();     // 构建 Tab 配置
}
```

初始化顺序：
1. 读取用户登录状态和头像
2. 读取搜索栏显示/隐藏设置
3. 获取搜索栏占位提示词（从热门视频中随机选）
4. 读取渐变背景开关
5. **最后构建 Tab 配置**（依赖 tabsConfig 和用户自定义排序）

**`onClose()`**

```dart
void onClose() {
  searchBarStream.close();
  super.onClose();
}
```

仅关闭 StreamController，释放流资源。

### 2.5 核心方法

**`setTabConfig()`** — Tab 配置构建

这是首页**最核心的方法**，负责根据用户设置生成最终的 Tab 列表：

```dart
void setTabConfig() async {
  defaultTabs = [...tabsConfig];                               // 1. 克隆全局配置
  tabbarSort = settingStorage.get(SettingBoxKey.tabbarSort,     // 2. 读取用户自定义排序
      defaultValue: ['rcmd', 'hot']);
  defaultTabs.retainWhere(                                     // 3. 过滤：仅保留用户启用的 Tab
      (item) => tabbarSort.contains((item['type'] as TabType).id));
  defaultTabs.sort((a, b) => ...);                             // 4. 按用户自定义顺序排序

  tabs.value = defaultTabs;                                    // 5. 更新响应式列表

  // 6. 计算初始索引（优先定位到 "推荐" Tab）
  if (tabbarSort.contains(TabType.rcmd.id)) {
    initialIndex.value = tabbarSort.indexOf(TabType.rcmd.id);
  } else {
    initialIndex.value = 0;
  }

  // 7. 提取子 Controller 和 Page
  tabsCtrList = tabs.map((e) => e['ctr']).toList();
  tabsPageList = tabs.map<Widget>((e) => e['page']).toList();

  // 8. 创建 TabController（注意 length = 过滤后的 tabs 数量）
  tabController = TabController(
    initialIndex: initialIndex.value,
    length: tabs.length,
    vsync: this,
  );

  // 9. 如果启用渐变背景，监听 tabController 切换动画
  if (enableGradientBg) {
    tabController.animation!.addListener(() { ... });
  }
}
```

**`searchDefault()`** — 搜索默认词获取

```dart
void searchDefault() async {
  final response = await _videoRepo.getPopularVideos(timeLimit: 7, offset: 0, num: 10);
  if (response.videoList.isNotEmpty) {
    final random = DateTime.now().millisecondsSinceEpoch % response.videoList.length;
    defaultSearch.value = response.videoList[random].title;
  }
}
```

- 调用 `IVideoRepository.getPopularVideos` 获取最近 7 天热门视频（10 条）
- 从中随机选取一条视频标题作为搜索栏占位提示词
- 失败时回退为 `'搜索视频'`

**`onRefresh()`** — 下拉刷新代理

```dart
void onRefresh() {
  int index = tabController.index;
  var ctr = tabsCtrList[index];
  ctr().onRefresh();
}
```

代理到当前激活 Tab 的子 Controller 的 `onRefresh()` 方法。

**`animateToTop()`** — 滚动到顶部代理

```dart
void animateToTop() {
  int index = tabController.index;
  var ctr = tabsCtrList[index];
  ctr().animateToTop();
}
```

代理到当前激活 Tab 的子 Controller 的 `animateToTop()` 方法。

**`updateLoginStatus(bool?)`** — 登录状态更新

```dart
void updateLoginStatus(bool? val) async {
  userInfo = await userInfoCache.get('userInfoCache');
  userLogin.value = val ?? false;
  if (val ?? false) return;
  userFace.value = userInfo != null ? userInfo.face : '';
}
```

从 Hive 重新读取用户信息，更新 UI 中的头像和登录状态。

---

## 3. View 详解

`HomePage` 是首页的主视图组件。

### 3.1 组件树

```
HomePage (StatefulWidget + AutomaticKeepAliveClientMixin)
└── Scaffold (透明背景，extendBodyBehindAppBar)
    └── Column
        ├── CustomAppBar
        │   └── StreamBuilder<bool>
        │       └── AnimatedOpacity
        │           └── UserInfoWidget
        │               ├── Obx → 用户头像 / DefaultUser
        │               └── HomeSearchBar (SearchAnchor + 搜索历史)
        ├── TabBar (仅当 tabs.length > 1 时渲染)
        └── Expanded
            └── TabBarView
                ├── RcmdPage
                └── HotPage
```

### 3.2 状态管理与 KeepAlive

```dart
class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;
```

- `AutomaticKeepAliveClientMixin`：确保首页切换 Tab 时不销毁重建
- `TickerProviderStateMixin`：用于可能的动画需求

### 3.3 Scaffold 配置

```dart
Scaffold(
  extendBody: true,
  extendBodyBehindAppBar: true,
  backgroundColor: Colors.transparent,
  appBar: AppBar(toolbarHeight: 0, ...),  // 零高度 AppBar，仅用于状态栏样式
)
```

- `extendBodyBehindAppBar: true` + `backgroundColor: Colors.transparent`：实现沉浸式 UI
- AppBar 的 `toolbarHeight` 为 0，实际顶部栏由 `CustomAppBar` 组件实现

### 3.4 TabBar 交互

```dart
TabBar(
  controller: _homeController.tabController,
  tabs: [for (var i in _homeController.tabs) Tab(text: i['label'])],
  isScrollable: true,
  onTap: (value) {
    feedBack();
    if (_homeController.initialIndex.value == value) {
      _homeController.tabsCtrList[value]().animateToTop();  // 双击回到顶部
    }
    _homeController.initialIndex.value = value;
  },
)
```

- 点击已选中的 Tab 时触发 `animateToTop()`（双击回到顶部）
- 通过 `feedBack()` 提供触觉反馈

### 3.5 搜索栏组件

`HomeSearchBar` 使用 Flutter 原生的 `SearchAnchor` 组件：

- **搜索历史**：由 `SearchHistoryService` 管理，存储在 Hive 中
- **实时过滤**：`suggestionsBuilder` 中根据输入过滤历史记录
- **宽屏适配**：宽屏（>600px）时搜索栏最大宽度 500px，窄屏为全宽
- **搜索结果**：点击历史项或提交搜索后，跳转到 `/search?keyword=xxx`

### 3.6 用户信息区域

`UserInfoWidget` 处理以下场景：

| 场景 | 窄屏 (<600px) | 宽屏 (>=600px) |
|------|-------------|---------------|
| **未登录** | 显示默认用户图标 → 点击弹出 `MinePage` 底部面板（或跳转 `/mine`） | 显示默认用户图标并显示消息图标 → 点击跳转 `/mine` |
| **已登录** | 显示用户头像 → 点击打开侧边抽屉（或跳转 `/mine`） | 显示用户头像 + 消息图标 → 点击头像跳转 `/mine` |

其中窄屏模式通过 `MainController.useDrawerForUser` 判断是否使用抽屉还是直接跳转。

---

## 4. AppBar 组件

### 4.1 CustomAppBar（主视图内嵌）

`CustomAppBar` 是嵌入在 `Column` 中的顶部栏组件，支持**搜索栏显示/隐藏动画**：

- 通过 `StreamBuilder<bool>` 监听 `searchBarStream`
- 使用 `AnimatedOpacity`（300ms）+ `AnimatedContainer`（500ms）实现平滑过渡
- 搜索栏可见时高度为 `top + 52`，隐藏时收缩为 `top`

### 4.2 HomeAppBar（独立 Sliver）

`HomeAppBar` 是备用方案，使用 `SliverAppBar` 实现：

- `pinned: true` + `floating: true`：滑动时固定并自动展开
- 左侧显示用户头像，点击打开抽屉（窄屏）或跳转个人页
- 搜索栏使用 `Hero(tag: 'searchBar')` 实现与搜索页的共享元素转场动画
- 搜索栏占位文字通过 `Obx` 绑定 `defaultSearch` 响应式更新

---

## 5. 数据流

### 5.1 初始化数据流

```
main.dart 启动
  → HomeController.onInit()
    ├── Hive 读取: userInfoCache.get('userInfoCache')
    │   → userLogin.value, userFace.value
    ├── Hive 读取: setting.get(SettingBoxKey.hideSearchBar)
    │   → hideSearchBar
    ├── IVideoRepository.getPopularVideos()
    │   → defaultSearch.value (随机视频标题)
    └── setTabConfig()
        ├── Hive 读取: settingStorage.get(SettingBoxKey.tabbarSort)
        ├── tabsConfig (TabType 枚举 + RcmdPage/HotPage)
        ├── 过滤 + 排序 → tabs.value
        └── 创建 TabController → TabBar + TabBarView 绑定
```

### 5.2 用户登录状态流

```
登录成功 → Hive 写入 userInfoCache
  → HomeController.updateLoginStatus(true)
    → userLogin.value = true
    → userFace.value = userInfo.face
    → UI 重建 (Obx): 默认图标 → 用户头像
```

### 5.3 Tab 切换流

```
用户点击 Tab / 滑动切换
  → TabController.animation 变化
    → enableGradientBg 时触发渐变背景更新
    → TabBarView 切换页面
    → 子 Controller (RcmdController / HotController) 各自管理内容状态
```

### 5.4 双击 Tab 回到顶部

```
用户点击已选中 Tab
  → onTap: initialIndex.value == value → true
  → tabsCtrList[value]().animateToTop()
  → 子页面的 ScrollController 动画滚动到顶部
```

---

## 6. 使用示例

### 6.1 HomeController 基本使用

```dart
import 'package:get/get.dart';
import 'package:piliotto/pages/home/controller.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.find<HomeController>();
    
    return Obx(() {
      return Column(
        children: [
          Text('当前Tab: ${homeController.tabs[homeController.initialIndex.value]['label']}'),
          Text('用户登录状态: ${homeController.userLogin.value}'),
          Text('搜索默认词: ${homeController.defaultSearch.value}'),
        ],
      );
    });
  }
}
```

### 6.2 Tab 切换与刷新

```dart
void switchTabAndRefresh(HomeController controller, int index) {
  controller.tabController.animateTo(index);
  controller.initialIndex.value = index;
  
  if (controller.tabsCtrList.isNotEmpty) {
    controller.tabsCtrList[index]().onRefresh();
  }
}

void scrollToCurrentTabTop(HomeController controller) {
  final currentIndex = controller.tabController.index;
  controller.tabsCtrList[currentIndex]().animateToTop();
}
```

### 6.3 搜索栏集成

```dart
class SearchBarWidget extends StatelessWidget {
  final HomeController controller;
  
  @override
  Widget build(BuildContext context) {
    return Obx(() => SearchAnchor(
      headerHintStyle: TextStyle(color: Theme.of(context).colorScheme.outline),
      suggestionsBuilder: (context, controller) {
        return [
          for (final item in SearchHistoryService().currentHistory)
            ListTile(
              title: Text(item),
              onTap: () {
                Get.toNamed('/search?keyword=$item');
              },
            ),
        ];
      },
    ));
  }
}
```

### 6.4 用户状态更新

```dart
void onLoginSuccess() {
  final HomeController homeController = Get.find<HomeController>();
  homeController.updateLoginStatus(true);
}

void onLogout() {
  final HomeController homeController = Get.find<HomeController>();
  homeController.updateLoginStatus(false);
}
```

---

## 7. 开发指南

### 7.1 新增首页 Tab

假设要新增一个"直播" Tab：

**步骤 1**：在 `lib/models/common/tab_type.dart` 的 `TabType` 枚举中追加：

```dart
enum TabType { rcmd, hot, live }  // ← 追加到最后

extension TabTypeDesc on TabType {
  String get description => ['推荐', '热门', '直播'][index];
  String get id => ['rcmd', 'hot', 'live'][index];
}
```

**步骤 2**：在 `tabsConfig` 列表中追加配置项：

```dart
List tabsConfig = [
  // ... 原有项
  {
    'icon': const Icon(Icons.live_tv_outlined, size: 15),
    'label': '直播',
    'type': TabType.live,
    'ctr': Get.find<LiveController>,
    'page': const LivePage(),
  },
];
```

**步骤 3**：创建 `lib/pages/live/` 模块，实现 `LiveController` 和 `LivePage`。

**步骤 4**：在 `main.dart` 中注册 `LiveController`：

```dart
Get.put(LiveController());
```

**步骤 5**：在设置页的 Tab 排序配置中追加 `'live'`。

### 7.2 自定义 Tab 排序

用户可在设置页（`/tabbarSetting`）自定义 Tab 的显示和排序，数据存储在 `GStrorage.setting` 的 `SettingBoxKey.tabbarSort` 键中，格式为 `List<String>`。

`HomeController.setTabConfig()` 读取此配置并执行：
- `retainWhere`：过滤掉用户未启用的 Tab
- `sort`：按配置顺序排列

---

## 8. 二改指南

### 8.1 修改搜索默认词来源

当前搜索默认词从 `getPopularVideos` 的返回结果中随机选取。如需修改来源（例如改为固定文字），修改 `searchDefault()` 方法：

```dart
void searchDefault() async {
  // 改为固定文字
  defaultSearch.value = '请输入搜索关键词';
}
```

### 8.2 调整顶部栏布局

`UserInfoWidget` 的 `build` 方法中使用 `Row` 排列各组件。调整顺序或添加新元素时在对应位置插入即可：

- 窄屏（`isNarrowScreen = true`）：`[用户头像, 搜索栏]`
- 宽屏（`isNarrowScreen = false`）：`[搜索栏, 消息图标, 用户头像]`

### 8.3 关闭搜索栏动画

如果不需要搜索栏显示/隐藏动画，可在 `view.dart` 中将 `CustomAppBar` 的 `stream` 传入一个永不变化的流：

```dart
CustomAppBar(
  stream: StreamController<bool>.broadcast().stream,  // 永不触发变化的流
  ...
)
```

### 8.4 修改 onTap Tab 行为

当前点击已选中 Tab 时触发 `animateToTop()`。如需改为刷新：

```dart
onTap: (value) {
  feedBack();
  if (_homeController.initialIndex.value == value) {
    _homeController.tabsCtrList[value]().onRefresh();  // 改为刷新
  }
  _homeController.initialIndex.value = value;
},
```

### 8.5 注意事项

1. **TabController 生命周期**：`TabController` 在 `setTabConfig()` 中创建，与 `HomeController` 同生命周期。如果需要在运行时动态增减 Tab，需先 `dispose` 旧 `TabController` 再创建新的。
2. **Stream 管理**：`searchBarStream` 是广播流（`broadcast`），允许多个监听者。在 `onClose` 中确保关闭。
3. **Hive 缓存**：`userLogin` 和 `userFace` 的值来自 Hive 缓存，登录状态变更后需要调用 `updateLoginStatus()` 刷新。
4. **子 Controller 依赖**：`tabsConfig` 中使用 `Get.find<RcmdController>` 获取子 Controller，这意味着这些 Controller 必须在 `HomeController` 初始化之前已通过 `Get.put()` 注册。