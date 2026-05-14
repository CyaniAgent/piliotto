---
date: 2026-05-14 22:45:48
title: main
permalink: /pages/main
categories:
  - guide
  - pages
---
# 主框架与推荐模块（Main & Rcmd）

本章涵盖两个模块：**主框架模块（MainPage）** — 应用的根级布局容器，负责底部导航栏、宽窄屏适配和全局返回拦截——以及 **推荐模块（RcmdPage）** — 首页"推荐" Tab 的内容提供者。

## 目录结构

```
lib/pages/
├── main/
│   ├── controller.dart    # MainController - 导航栏配置与全局状态
│   ├── view.dart          # MainApp - 主框架视图（窄屏/宽屏自适应）
│   └── index.dart         # 统一导出
└── rcmd/
    ├── controller.dart    # RcmdController - 视频推荐数据管理
    ├── view.dart          # RcmdPage - 推荐视频网格视图
    └── index.dart         # 统一导出
```

---

## 第一部分：MainPage（主框架）

### 1. 模块概述

`MainApp` 是 PiliOtto 的 **根级框架 Widget**，负责管理底部导航栏（BottomNavigationBar / NavigationBar / NavigationRail）以及多个子页面的切换。

核心缓存数据模型定义在 `nav_bar_config.dart`：

```dart
List defaultNavigationBars = [
  { 'id': 0, 'label': "首页", 'page': HomePage(), ... },
  { 'id': 1, 'label': "动态", 'page': DynamicsPage(), ... },
  { 'id': 3, 'label': "我的", 'page': MinePage(), ... },
];
```

每个 Tab 包含 `id`、`icon`、`selectIcon`、`label`、`count`（角标数）和 `page`（对应的 Widget）。

### 2. MainController 详解

`MainController` 管理底部导航栏配置、页面列表和全局 UI 状态。

#### 2.1 属性一览

| 属性 | 类型 | 说明 |
|------|------|------|
| `pages` | `List<Widget>` | 当前生效的页面列表，顺序与导航栏一致 |
| `pagesIds` | `List<int>` | 当前页面的 ID 列表 |
| `navigationBars` | `RxList` | 响应式导航栏配置列表，驱动导航栏渲染 |
| `selectedIndex` | `int` | 当前选中的 Tab 索引 |
| `pageController` | `PageController` | 控制 `PageView` 的页面切换 |
| `bottomBarStream` | `StreamController<bool>` | 广播流，用于隐藏/显示底部导航栏动画 |
| `hideTabBar` | `bool` | 是否启用 Tab 栏隐藏功能 |
| `userLogin` | `RxBool` | 用户登录状态 |
| `dynamicBadgeType` | `Rx<DynamicBadgeMode>` | 角标显示模式：数字/仅红点/隐藏 |
| `enableGradientBg` | `bool` | 是否启用渐变背景 |
| `useDrawerForUser` | `bool` | 窄屏时用侧边抽屉代替"我的"Tab |
| `scaffoldKey` | `GlobalKey<ScaffoldState>` | 用于打开侧边抽屉 |

#### 2.2 onInit 初始化

```dart
void onInit() {
  super.onInit();
  if (setting.get(SettingBoxKey.autoUpdate, defaultValue: false)) {
    Utils.checkUpdata();
  }
  hideTabBar = setting.get(SettingBoxKey.hideTabBar, defaultValue: false);
  useDrawerForUser = setting.get(SettingBoxKey.useDrawerForUser, defaultValue: true);
  userLogin.value = userInfoCache.get('userInfoCache') != null;
  dynamicBadgeType.value = DynamicBadgeMode.values[
    setting.get(SettingBoxKey.dynamicBadgeMode, defaultValue: DynamicBadgeMode.number.code)
  ];
  setNavBarConfig();
  enableGradientBg = setting.get(SettingBoxKey.enableGradientBg, defaultValue: true);
}
```

按顺序：读取自动更新 → 导航栏显隐 → 抽屉模式 → 登录状态 → 角标模式 → **构建导航栏配置** → 渐变背景。

#### 2.3 setNavBarConfig() — 导航栏配置构建

这是 MainController **最核心的方法**：

```dart
void setNavBarConfig() async {
  defaultNavTabs = [...defaultNavigationBars];
  navBarSort = setting.get(SettingBoxKey.navBarSort, defaultValue: [0, 1, 3]);

  // 1. 自动添加新页面（防止新增 Tab 后旧设置不包含）
  for (var item in defaultNavigationBars) {
    if (!navBarSort.contains(item['id'])) navBarSort.add(item['id']);
  }

  // 2. 移除已废弃的页面 ID
  navBarSort.removeWhere((id) => !defaultNavigationBars.any((item) => item['id'] == id));

  // 3. 窄屏 + 启用侧边栏 → 从底栏移除"我的"（id: 3）
  if (isNarrowScreen && useDrawerForUser) navBarSort.remove(3);

  // 4. 过滤 + 排序
  defaultNavTabs.retainWhere((item) => navBarSort.contains(item['id']));
  defaultNavTabs.sort((a, b) =>
      navBarSort.indexOf(a['id']).compareTo(navBarSort.indexOf(b['id'])));

  // 5. 转换为 pages / pagesIds
  pages = navigationBars.map<Widget>((e) => e['page']).toList();
  pagesIds = navigationBars.map<int>((e) => e['id']).toList();

  // 6. 计算默认选中
  int defaultHomePage = setting.get(SettingBoxKey.defaultHomePage, defaultValue: 0);
  selectedIndex = navigationBars.indexWhere((item) => item['id'] == defaultHomePage) ?? 0;
}
```

**自适应逻辑**：通过物理像素 / 设备像素比判断是否为窄屏（< 600px），窄屏 + 侧边栏模式时从底部导航移除"我的"Tab。

#### 2.4 返回键拦截

```dart
void onBackPressed(BuildContext context) {
  if (_lastPressedAt == null ||
      DateTime.now().difference(_lastPressedAt!) > Duration(seconds: 2)) {
    _lastPressedAt = DateTime.now();
    if (selectedIndex != 0) pageController.jumpTo(0);  // 不在首页则跳回首页
    SmartDialog.showToast("再按一次退出PiliOtto");
    return;
  }
  SystemNavigator.pop();  // 2秒内双击退出
}
```

- 首次按返回：跳转到首页（已在家则提示）
- 2 秒内再次按：退出应用

### 3. MainApp View 详解

`MainApp` 实现宽窄屏双布局。

#### 3.1 布局切换

```dart
Widget build(BuildContext context) {
  bool isWideScreen = ResponsiveUtil.isLg || ResponsiveUtil.isXl;
  return PopScope(
    canPop: false,
    onPopInvokedWithResult: (...) => _mainController.onBackPressed(context),
    child: isWideScreen ? _buildWideScreenLayout(context) : _buildNarrowScreenLayout(context),
  );
}
```

- 使用 `ResponsiveUtil` 判断屏幕尺寸
- `PopScope(canPop: false)` 拦截系统返回键

#### 3.2 窄屏布局（`_buildNarrowScreenLayout`）

```
Scaffold
├── drawer: UserDrawer (useDrawerForUser 为 true 时)
├── body: Stack → PageView (NeverScrollableScrollPhysics)
└── bottomNavigationBar: navigationBars.length > 1 ?
    ├── enableMYBar ? NavigationBar (Material 3) : BottomNavigationBar (Material 2)
    └── AnimatedSlide (offset: hideTabBar ? 0 : 1 ← 动画隐藏)
```

**底部导航栏**支持两种样式：
- `enableMYBar = true`：使用 Material 3 `NavigationBar`
- `enableMYBar = false`：使用传统 `BottomNavigationBar`

**隐藏动画**：
- `hideTabBar = true` 时监听 `bottomBarStream`，通过 `AnimatedSlide` 实现滑入滑出（500ms）
- `hideTabBar = false` 时传入空流，导航栏始终显示

#### 3.3 宽屏布局（`_buildWideScreenLayout`）

```
Scaffold
└── Row
    ├── NavigationRail (左侧导航栏)
    └── Expanded → Stack → PageView
```

宽屏下使用 `NavigationRail` 替代底部导航栏，导航项在左侧垂直排列。

#### 3.4 Tab 切换逻辑（`setIndex`）

```dart
void setIndex(int value) async {
  feedBack();
  _mainController.pageController.jumpToPage(value);
  var currentPage = _mainController.pages[value];

  if (currentPage is HomePage) {
    if (_homeController.flag) {
      if (now - lastSelectTime < 500) _homeController.onRefresh();  // 双击刷新
      else _homeController.animateToTop();                            // 单击回顶
    }
    _homeController.flag = true;
  }

  if (currentPage is DynamicsPage) { /* 同逻辑 */ }
  if (currentPage is MediaPage) { _mediaController!.queryFavFolder(); }
}
```

核心交互模式：**单击回顶，双击（500ms内）刷新**。通过 `flag` 标记和 `_lastSelectTime` 实现双击检测。

#### 3.5 Controller 延迟初始化

```dart
void controllerInit() {
  _homeController = Get.put(HomeController());
  if (_mainController.pagesIds.contains(1)) {
    _dynamicController = Get.put(DynamicsController());
  }
  if (_mainController.pagesIds.contains(2)) {
    _mediaController = Get.put(MediaController());
  }
}
```

仅注册用户启用的 Tab 对应的 Controller，节省内存。

---

## 第二部分：RcmdPage（推荐页）

### 4. 模块概述

`RcmdPage` 是 HomePage 中"推荐"Tab 的内容页，展示随机推荐的视频列表。

- 使用 `GridView.builder` + 响应式列数（支持 1-4 列）
- 支持下拉刷新和无限滚动加载
- 使用 `FutureBuilder` 包裹，加载中显示骨架屏

### 5. RcmdController 详解

`RcmdController` 管理推荐视频数据。

#### 5.1 Rx 响应式状态

| 变量 | 类型 | 说明 |
|------|------|------|
| `isLoadingMore` | `RxBool` | 加载状态（`true` = 允许加载，`false` = 加载完成/已有数据） |
| `crossAxisCount` | `RxInt` | 当前网格列数（响应屏幕宽度变化） |
| `videoList` | `RxList<Video>` | 视频列表 |

#### 5.2 列数计算

```dart
void updateCrossAxisCount() {
  int customRows = setting.get(SettingBoxKey.customRows, defaultValue: 2);
  int baseCount = ResponsiveUtil.calculateCrossAxisCount(
    baseCount: customRows, minCount: 1, maxCount: 4,
  );
  crossAxisCount.value = baseCount;
}
```

- 用户设置的基础列数（`customRows`，默认 2）
- 通过 `ResponsiveUtil` 根据屏幕宽度动态调整（1-4 列）
- 在 `didChangeDependencies` 和 `didUpdateWidget` 中触发更新

#### 5.3 视频加载

```dart
Future<Map<String, dynamic>> queryRcmdFeed(String type) async {
  if (isLoadingMore.value == false) return {'status': false, 'msg': '正在加载中'};

  final response = await _videoRepo.getRandomVideos(num: 20);

  if (type == 'init')       videoList.clear() + videoList.addAll(videos);
  else if (type == 'onRefresh')  enableSaveLastData ? insertAll(0) : clear() + addAll();
  else if (type == 'onLoad')     videoList.addAll(videos);

  isLoadingMore.value = false;
}
```

| type | 行为 | 说明 |
|------|------|------|
| `init` | 清空 + 添加 | 首次加载 |
| `onRefresh` | 默认清空 + 添加；或 `enableSaveLastData` 时前插 | 下拉刷新 |
| `onLoad` | 追加 | 加载更多 |

#### 5.4 滚动到顶部

```dart
void animateToTop() async {
  if (scrollController.offset >= MediaQuery.of(Get.context!).size.height * 5) {
    scrollController.jumpTo(0);  // 距离太远直接跳转
  } else {
    scrollController.animateTo(0, duration: 500ms, curve: easeInOut);  // 平滑滚动
  }
}
```

超过 5 倍屏幕高度时直接 `jumpTo`，避免长时间动画。

#### 5.5 拉黑用户

```dart
void blockUserCb(int uid) {
  videoList.removeWhere((e) => e.uid == uid);
  videoList.refresh();
  SmartDialog.showToast('已移除相关视频');
}
```

从列表中移除该用户的所有视频。

### 6. RcmdPage View 详解

`RcmdPage` 实现视频网格视图。

#### 6.1 组件树

```
RcmdPage (StatefulWidget + AutomaticKeepAliveClientMixin)
└── Container (圆角裁剪 + 安全间距)
    └── FutureBuilder
        ├── done + 成功 → Obx → RefreshIndicator → GridView.builder
        │     ├── itemBuilder: VideoCardV(videoItem) / VideoCardVSkeleton
        │     └── padding: safeSpace
        ├── done + 失败 → HttpError(errMsg, 重试按钮)
        ├── done + null → NoData
        └── loading → Obx → 骨架屏 (10 个 VideoCardVSkeleton)
```

#### 6.2 无限滚动

```dart
scrollController.addListener(() {
  if (scrollController.position.pixels >=
      scrollController.position.maxScrollExtent - 200) {
    EasyThrottle.throttle('my-throttler', Duration(milliseconds: 200), () {
      _rcmdController.onLoad();
    });
  }
});
```

- 距离底部 200px 时触发加载更多
- 使用 `EasyThrottle` 200ms 节流防抖

#### 6.3 GridView 配置

```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    mainAxisSpacing: safeSpace,
    crossAxisSpacing: safeSpace,
    crossAxisCount: crossAxisCount,        // 响应式列数
    mainAxisExtent: calculateMainAxisExtent(...)  // 动态计算 Item 高度
  ),
  itemCount: videoList.isNotEmpty ? videoList.length : 10,  // 骨架屏占 10 个
)
```

---

## 7. 数据流

### MainApp 初始化流

```
main.dart 启动
  → Get.put(MainController())
    → MainController.onInit()
      ├── Hive 读取: autoUpdate → Utils.checkUpdata()
      ├── Hive 读取: hideTabBar, useDrawerForUser
      ├── Hive 读取: userInfoCache → userLogin
      ├── Hive 读取: dynamicBadgeMode → dynamicBadgeType
      ├── setNavBarConfig()
      │     ├── 读取 navBarSort → 过滤排序 defaultNavigationBars
      │     ├── 窄屏 + useDrawerForUser → 移除"我的"
      │     └── 生成 pages / pagesIds / selectedIndex
      └── Hive 读取: enableGradientBg

MainApp.initState()
  → pageController = PageController(initialPage: selectedIndex)
  → controllerInit()
    ├── Get.put(HomeController())
    ├── pagesIds.contains(1) → Get.put(DynamicsController())
    └── pagesIds.contains(2) → Get.put(MediaController())
```

### RcmdPage 数据流

```
RcmdPage.initState()
  → _futureBuilderFuture = queryRcmdFeed('init')
    → _videoRepo.getRandomVideos(num: 20)
      ├── 成功 → videoList 赋值 → GridView 渲染
      └── 失败 → HttpError 组件展示

用户下拉刷新
  → RefreshIndicator → onRefresh()
    └── queryRcmdFeed('onRefresh')
        ├── enableSaveLastData ? insertAll(0) : clear() + addAll()

用户滚动到底部
  → scrollController listener → onLoad()
    └── queryRcmdFeed('onLoad') → videoList.addAll()
```

---

## 8. 开发指南

### 8.1 新增底部导航 Tab

1. 在 `nav_bar_config.dart` 的 `defaultNavigationBars` 中添加配置
2. 创建对应的 Page 和 Controller
3. 在 `MainApp.controllerInit()` 中注册 Controller
4. 在设置页的导航栏排序配置中追加相应 ID

### 8.2 获取 MainController

```dart
final mainController = Get.find<MainController>();

// 切换到首页
mainController.pageController.jumpToPage(0);

// 隐藏底部导航栏
mainController.bottomBarStream.add(false);

// 显示底部导航栏
mainController.bottomBarStream.add(true);
```

---

## 9. 二改指南

### 9.1 关闭宽屏布局

将 `isWideScreen` 强制设为 `false`：

```dart
bool isWideScreen = false;  // 始终使用窄屏布局
```

### 9.2 修改双击退出行为

调整 `onBackPressed` 中的双击间隔：

```dart
DateTime.now().difference(_lastPressedAt!) > Duration(seconds: 3)  // 改为 3 秒
```

### 9.3 调整推荐页每页加载数量

修改 `queryRcmdFeed` 中的 `num` 参数：

```dart
final response = await _videoRepo.getRandomVideos(num: 30);  // 改为 30
```

### 9.4 改变底部导航栏样式

将 `enableMYBar` 设为 `false` 以使用 Material 2 的 `BottomNavigationBar`：

```dart
Box setting = GStrorage.setting;
bool enableMYBar = false;  // 强制使用 BottomNavigationBar
```

### 9.5 注意事项

1. **PageView 物理**：`NeverScrollableScrollPhysics()` 禁止手势滑动，页面切换完全由导航栏控制
2. **Controller 注册时机**：子页面的 Controller 必须在 `MainApp.controllerInit()` 前或同时注册，否则 `Get.find` 会抛出异常
3. **宽窄屏判断**：`ResponsiveUtil.isLg` / `isXl` 依赖 `MediaQuery` context，确保在 `build` 方法中调用
4. **推荐页 KeepAlive**：`AutomaticKeepAliveClientMixin` 防止 Tab 切换时状态丢失
5. **`isLoadingMore` 语义**：`true` 表示"允许加载"，`false` 表示"已完成/不可再加载"，与常见命名惯例相反