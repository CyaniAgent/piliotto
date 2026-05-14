---
date: 2026-05-14 22:27:03
title: router
permalink: /pages/a482e5
categories:
  - guide
  - core
---
# 路由系统 (Router)

## 1. 模块概述

路由系统 (`lib/router/`) 是 PiliOtto 的页面导航核心，基于 **GetX** 框架的 `GetPage` 实现声明式路由管理。通过自定义的 `CustomGetPage` 封装统一了过渡动画、曲线等配置，保证所有页面导航体验一致。

路由模块位于 `app_pages.dart`，共定义 **36 条路由**，覆盖项目所有页面模块。路由注册在 `GetMaterialApp` 的 `getPages` 属性中，支持命名路由（`Get.toNamed`）和参数传递。

### 目录结构

```
lib/router/
└── app_pages.dart              # 路由定义文件（Routes + CustomGetPage）
```

### 依赖关系

```
app_pages.dart
  ├── package:get/get.dart      # GetX 路由框架
  ├── pages/home/index.dart     # 首页
  ├── pages/hot/index.dart      # 热门页
  ├── pages/search/index.dart   # 搜索页
  ├── pages/video/detail/index.dart           # 视频详情
  ├── pages/video/detail/reply_reply/index.dart # 评论回复面板
  ├── pages/webview/index.dart  # WebView 页
  ├── pages/setting/index.dart  # 设置主页（及 11 个子设置页）
  ├── pages/media/index.dart    # 番剧/影视
  ├── pages/fav/index.dart      # 收藏夹
  ├── pages/fav_detail/index.dart # 收藏夹详情
  ├── pages/history/index.dart  # 历史记录
  ├── pages/dynamics/index.dart # 动态
  ├── pages/dynamics/detail/index.dart # 动态详情
  ├── pages/follow/index.dart   # 关注列表
  ├── pages/fan/index.dart      # 粉丝列表
  ├── pages/member/index.dart   # 用户主页
  ├── pages/mine/index.dart     # 我的
  ├── pages/member_dynamics/index.dart  # 用户动态
  ├── pages/member_archive/index.dart   # 用户投稿
  ├── pages/login/index.dart    # 登录
  ├── pages/message/index.dart  # 消息
  ├── pages/whisper_detail/index.dart   # 私信详情
  ├── pages/about/index.dart    # 关于
  └── utils/storage.dart        # Hive 存储（读取设置）
```

---

## 2. 路由架构

### 2.1 CustomGetPage 设计

`CustomGetPage` 继承自 GetX 的 `GetPage`，封装了项目中所有路由共用的配置：

```dart
class CustomGetPage extends GetPage<dynamic> {
  CustomGetPage({
    required super.name,
    required super.page,
    this.fullscreen,
    super.transitionDuration,
  }) : super(
          curve: Curves.linear,
          transition: Transition.native,
          showCupertinoParallax: false,
          popGesture: false,
          fullscreenDialog: fullscreen != null && fullscreen,
        );
  bool? fullscreen = false;
}
```

**统一配置项**:

| 配置项 | 值 | 说明 |
|--------|-----|------|
| `curve` | `Curves.linear` | 线性过渡曲线，无缓动 |
| `transition` | `Transition.native` | 使用原生平台过渡动画（Android 左右滑动，iOS 自右向左） |
| `showCupertinoParallax` | `false` | 禁用 iOS 视差效果，统一体验 |
| `popGesture` | `false` | 禁用手势返回，统一通过返回按钮控制 |
| `fullscreenDialog` | 由 `fullscreen` 参数控制 | 全屏弹窗模式（显示关闭按钮替代返回箭头） |

**设计意图**:
- **Transition.native**: 使用原生过渡动画，在各平台上获得平台一致的用户体验，同时支持自定义 `pageTransitionsTheme` 覆盖（如 Android 使用 `ZoomPageTransitionsBuilder`）
- **Curves.linear**: 线性曲线保证过渡动画简洁高效，避免缓动带来的感知延迟
- **showCupertinoParallax: false**: 禁用 iOS 特有的视差效果，确保 Android/iOS 双端导航感一致
- **popGesture: false**: 禁用滑动返回手势，避免与页面内横向滑动交互（如 Tab 切换、卡片滑动）冲突

### 2.2 可配置参数

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `name` | `String` | 必填 | 路由路径，如 `'/video'` |
| `page` | `GetPageBuilder` | 必填 | 页面构建函数 |
| `fullscreen` | `bool?` | `false` | 是否作为全屏弹窗展示（AppBar 显示关闭按钮） |
| `transitionDuration` | `Duration?` | 系统默认 | 过渡动画时长 |

---

## 3. 完整路由表

路由定义在 `Routes.getPages` 静态列表中。

### 3.1 主页面

| 序号 | 路由路径 | 页面组件 | 所属模块 | 说明 |
|------|----------|----------|----------|------|
| 1 | `/` | `HomePage` | 首页 | 应用首页，底部导航栏默认页 |
| 2 | `/hot` | `HotPage` | 热门 | 热门视频列表 |
| 3 | `/search` | `SearchPage` | 搜索 | 搜索页面 |

### 3.2 视频与媒体

| 序号 | 路由路径 | 页面组件 | 所属模块 | 说明 |
|------|----------|----------|----------|------|
| 4 | `/video` | `VideoDetailPage` | 视频详情 | 视频播放与详情 |
| 5 | `/media` | `MediaPage` | 番剧/影视 | 番剧、电影、纪录片 |
| 6 | `/replyReply` | `VideoReplyReplyPanel` | 评论 | 评论回复子面板 |

### 3.3 用户与社交

| 序号 | 路由路径 | 页面组件 | 所属模块 | 说明 |
|------|----------|----------|----------|------|
| 7 | `/member` | `MemberPage` | 用户主页 | 查看其他用户主页 |
| 8 | `/mine` | `MinePage(showBackButton: true)` | 我的 | 个人主页（显示返回按钮） |
| 9 | `/follow` | `FollowPage` | 关注 | 关注列表 |
| 10 | `/fan` | `FansPage` | 粉丝 | 粉丝列表 |
| 11 | `/memberDynamics` | `MemberDynamicsPage` | 用户动态 | 某用户发布的动态 |
| 12 | `/memberArchive` | `MemberArchivePage` | 用户投稿 | 某用户视频投稿 |
| 13 | `/message` | `MessagePage` | 消息 | 消息列表页 |
| 14 | `/whisperDetail` | `WhisperDetailPage` | 私信 | 私信对话详情 |

### 3.4 动态

| 序号 | 路由路径 | 页面组件 | 所属模块 | 说明 |
|------|----------|----------|----------|------|
| 15 | `/dynamics` | `DynamicsPage` | 动态 | 动态列表页 |
| 16 | `/dynamicDetail` | `DynamicDetailPage` | 动态详情 | 单条动态详情 |

### 3.5 收藏与历史

| 序号 | 路由路径 | 页面组件 | 所属模块 | 说明 |
|------|----------|----------|----------|------|
| 17 | `/fav` | `FavPage` | 收藏夹 | 收藏夹列表 |
| 18 | `/favDetail` | `FavDetailPage` | 收藏夹详情 | 收藏夹内容详情 |
| 19 | `/history` | `HistoryPage` | 历史记录 | 播放历史 |

### 3.6 设置（共 11 个子页面）

| 序号 | 路由路径 | 页面组件 | 所属模块 | 说明 |
|------|----------|----------|----------|------|
| 20 | `/setting` | `SettingPage` | 设置主页 | 设置入口页 |
| 21 | `/playSetting` | `PlaySetting` | 播放设置 | 视频播放相关配置 |
| 22 | `/styleSetting` | `StyleSetting` | 外观设置 | 主题、字号、布局 |
| 23 | `/extraSetting` | `ExtraSetting` | 其他设置 | 扩展功能设置 |
| 24 | `/colorSetting` | `ColorSelectPage` | 主题色 | 自定义主题色选择 |
| 25 | `/tabbarSetting` | `TabbarSetPage` | 首页 Tab | 首页顶部 Tab 排序 |
| 26 | `/fontSizeSetting` | `FontSizeSelectPage` | 字体大小 | 全局字体缩放 |
| 27 | `/displayModeSetting` | `SetDiaplayMode` | 屏幕帧率 | Android 显示模式 |
| 28 | `/playSpeedSet` | `PlaySpeedPage` | 倍速设置 | 播放倍速列表管理 |
| 29 | `/bottomControlSet` | `BottomControlSetPage` | 底部按钮 | 播放器底部按钮配置 |
| 30 | `/playerGestureSet` | `PlayGesturePage` | 手势设置 | 全屏手势模式配置 |
| 31 | `/navbarSetting` | `NavigationBarSetPage` | 导航栏 | 底部导航栏排序 |
| 32 | `/actionMenuSet` | `ActionMenuSetPage` | 操作菜单 | 操作按钮排序 |

### 3.7 通用与工具

| 序号 | 路由路径 | 页面组件 | 所属模块 | 说明 |
|------|----------|----------|----------|------|
| 33 | `/webview` | `WebviewPage` | WebView | 内嵌网页浏览器 |
| 34 | `/loginPage` | `LoginPage` | 登录 | 用户登录页 |
| 35 | `/about` | `AboutPage` | 关于 | 关于页面 |
| 36 | `/logs` | `LogsPage` | 日志 | 运行日志查看 |

> **注意**: 当前所有 36 条路由均未显式设置 `fullscreen: true`，但 `CustomGetPage` 已预留该参数，可在需要时启用全屏弹窗模式。

---

## 4. GetMaterialApp 配置

路由系统在 `main.dart` 的 `GetMaterialApp` 中完成注册：

```dart
return GetMaterialApp(
  title: 'PiliOtto',
  themeMode: appThemeMode,
  theme: ThemeData(
    colorScheme: lightColorScheme,
    snackBarTheme: lightSnackBarTheme,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: ZoomPageTransitionsBuilder(
          allowEnterRouteSnapshotting: false,
        ),
      },
    ),
  ),
  darkTheme: ThemeData(
    colorScheme: darkColorScheme,
    snackBarTheme: darkSnackBarTheme,
  ),
  localizationsDelegates: const [
    GlobalCupertinoLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ],
  locale: const Locale("zh", "CN"),
  supportedLocales: const [Locale("zh", "CN"), Locale("en", "US")],
  fallbackLocale: const Locale("zh", "CN"),
  getPages: Routes.getPages,       // ← 路由注册
  home: const MainApp(),           // ← 首页入口
  builder: (context, child) { ... },
  navigatorObservers: [
    VideoDetailPage.routeObserver, // ← 路由观察者（用于 PiP 检测）
  ],
  onReady: () async { ... },
);
```

**关键配置说明**:

| 配置项 | 值 | 说明 |
|--------|-----|------|
| `getPages` | `Routes.getPages` | 注册 36 条命名路由 |
| `home` | `MainApp()` | 应用主框架（含底部导航栏），非单独的首页 |
| `pageTransitionsTheme` | `ZoomPageTransitionsBuilder` | Android 平台使用缩放过渡（禁用进入路由快照） |
| `navigatorObservers` | `VideoDetailPage.routeObserver` | 用于视频 PiP（画中画）模式的路由状态监听 |
| `locale` | `zh_CN` | 默认中文，支持英文回退 |

**过渡动画层次**:
```
GetMaterialApp.pageTransitionsTheme (ZoomPageTransitionsBuilder)
  └── CustomGetPage.transition = Transition.native
       └── 最终 Android: 缩放过渡 / iOS: 右滑过渡
```

---

## 5. 页面跳转方式

### 5.1 基础跳转：Get.toNamed

项目中所有页面跳转统一使用 `Get.toNamed()`，支持两种参数传递方式：

```dart
// 方式一：URL 查询参数 (parameters)
Get.toNamed('/video?vid=$vid');

// 方式二：arguments 参数
Get.toNamed('/member?mid=$mid', arguments: {
  'face': avatarUrl,
  'heroTag': heroTag,
});
```

**parameters vs arguments 的区别**:

| 特性 | `parameters` (查询参数) | `arguments` |
|------|------------------------|-------------|
| 获取方式 | `Get.parameters['key']` | `Get.arguments` |
| 数据格式 | 仅 `String` | 任意类型 (`Map`, `List` 等) |
| 可见性 | URL 中可见 | 不可见 |
| 适用场景 | 简单 ID、标识符 | 复杂对象、Hero 标签等 |

### 5.2 常用跳转方法

| 方法 | 说明 | 使用场景 |
|------|------|----------|
| `Get.toNamed('/path')` | 普通导航 | 大多数页面跳转 |
| `Get.toNamed('/path', preventDuplicates: false)` | 允许重复入栈 | 登录页多次进入 |
| `Get.offAndToNamed('/path?vid=$vid')` | 替换当前路由 | WebView 内打开视频（替换 WebView 页） |
| `Get.back()` | 返回上一页 | AppBar 返回按钮 |

### 5.3 参数获取示例

**目标页面接收参数**:

```dart
// 在页面的 build() 或 initState() 中获取
class VideoDetailPage extends StatefulWidget {
  @override
  State<VideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  @override
  void initState() {
    super.initState();
    // 获取 query parameters
    final String? vid = Get.parameters['vid'];
    // 获取 arguments
    final Map<String, dynamic>? args = Get.arguments;
    final String? pic = args?['pic'];
    final String? heroTag = args?['heroTag'];
  }
}
```

### 5.4 跨模块路由集成

#### Deep Link / Scheme 跳转

`app_scheme.dart` 中通过命名路由实现外部 URL 跳转：

```dart
// ottohub://video/12345 → 跳转视频详情
Get.offAndToNamed('/video?vid=$vid', arguments: {
  'pic': '',
  'heroTag': 'video_$vid',
});

// https://ottohub.cn/u/12345 → 跳转用户主页
Get.toNamed('/member?mid=$uid', arguments: {'face': ''});

// 其他 URL → WebView 兜底
Get.toNamed('/webview', parameters: {
  'url': url,
  'type': 'url',
  'pageTitle': title,
});
```

#### WebView 内部路由

WebView 页面内可以通过 URL scheme 拦截跳转到 App 内页面：

```dart
// ottohub://video/12345 → 替换当前 WebView 为视频页
Get.offAndToNamed('/video?vid=$vid', arguments: {
  'pic': '',
  'heroTag': 'video_$vid',
});
```

---

## 6. 使用示例

### 6.1 基础路由跳转

```dart
import 'package:get/get.dart';

void navigateToVideo(int vid) {
  Get.toNamed('/video?vid=$vid');
}

void navigateToMember(int mid, {String? avatarUrl, String? heroTag}) {
  Get.toNamed('/member?mid=$mid', arguments: {
    'face': avatarUrl,
    'heroTag': heroTag ?? 'member_$mid',
  });
}

void navigateToSearch(String keyword) {
  Get.toNamed('/search?keyword=$keyword');
}
```

### 6.2 带参数的路由跳转

```dart
void navigateWithArguments() {
  Get.toNamed('/video?vid=12345', arguments: {
    'pic': 'https://example.com/cover.jpg',
    'heroTag': 'video_12345',
    'videoType': 'video',
  });
}

void navigateAndReplace() {
  Get.offAndToNamed('/video?vid=12345');
}

void navigateAndClearStack() {
  Get.offAllNamed('/home');
}
```

### 6.3 获取路由参数

```dart
class VideoDetailPage extends StatefulWidget {
  @override
  State<VideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  late int vid;
  String? heroTag;
  String? coverUrl;
  
  @override
  void initState() {
    super.initState();
    vid = int.parse(Get.parameters['vid'] ?? '0');
    
    final args = Get.arguments as Map<String, dynamic>?;
    heroTag = args?['heroTag'] ?? 'default';
    coverUrl = args?['pic'];
  }
}
```

### 6.4 路由返回处理

```dart
void navigateWithResult() async {
  final result = await Get.toNamed('/search');
  if (result != null && result is String) {
    print('选择的搜索词: $result');
  }
}

void returnResult(String selectedKeyword) {
  Get.back(result: selectedKeyword);
}
```

---

## 6. 使用示例

### 6.1 基础路由跳转

```dart
import 'package:get/get.dart';

void navigateToVideo(int vid) {
  Get.toNamed('/video?vid=$vid');
}

void navigateToMember(int mid, {String? avatarUrl, String? heroTag}) {
  Get.toNamed('/member?mid=$mid', arguments: {
    'face': avatarUrl,
    'heroTag': heroTag ?? 'member_$mid',
  });
}

void navigateToSearch(String keyword) {
  Get.toNamed('/search?keyword=$keyword');
}
```

### 6.2 带参数的路由跳转

```dart
void navigateWithArguments() {
  Get.toNamed('/video?vid=12345', arguments: {
    'pic': 'https://example.com/cover.jpg',
    'heroTag': 'video_12345',
    'videoType': 'video',
  });
}

void navigateAndReplace() {
  Get.offAndToNamed('/video?vid=12345');
}

void navigateAndClearStack() {
  Get.offAllNamed('/home');
}
```

### 6.3 获取路由参数

```dart
class VideoDetailPage extends StatefulWidget {
  @override
  State<VideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  late int vid;
  String? heroTag;
  String? coverUrl;
  
  @override
  void initState() {
    super.initState();
    vid = int.parse(Get.parameters['vid'] ?? '0');
    
    final args = Get.arguments as Map<String, dynamic>?;
    heroTag = args?['heroTag'] ?? 'default';
    coverUrl = args?['pic'];
  }
}
```

### 6.4 路由返回处理

```dart
void navigateWithResult() async {
  final result = await Get.toNamed('/search');
  if (result != null && result is String) {
    print('选择的搜索词: $result');
  }
}

void returnResult(String selectedKeyword) {
  Get.back(result: selectedKeyword);
}
```

---

## 7. 开发指南

### 7.1 新增路由

**步骤 1**: 创建新页面

```dart
// lib/pages/new_feature/index.dart
import 'package:flutter/material.dart';

class NewFeaturePage extends StatelessWidget {
  const NewFeaturePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('新功能')),
      body: const Center(child: Text('Hello World')),
    );
  }
}
```

**步骤 2**: 注册路由

在 `app_pages.dart` 中：

```dart
// 1. 添加 import
import '../pages/new_feature/index.dart';

// 2. 在 Routes.getPages 列表中添加路由
class Routes {
  static final List<GetPage<dynamic>> getPages = [
    // ... 已有路由 ...
    CustomGetPage(name: '/newFeature', page: () => const NewFeaturePage()),
  ];
}
```

**步骤 3**: 使用路由跳转

```dart
Get.toNamed('/newFeature');
```

### 7.2 路由命名规范

| 规范 | 示例 | 说明 |
|------|------|------|
| 根路径 `/` | `'/'` | 仅首页使用 |
| 主页面用小写 | `'/video'`, `'/search'` | 单单词路径 |
| 详情页用驼峰 | `'/favDetail'`, `'/dynamicDetail'` | 子页面追加描述 |
| 设置页用完整描述 | `'/playSetting'`, `'/fontSizeSetting'` | 清晰表达功能 |
| 不使用下划线 | ❌ `/video_detail` | 统一使用驼峰 |

### 7.3 全屏弹窗路由

当需要将页面以全屏弹窗形式展示时，使用 `fullscreen: true` 参数：

```dart
CustomGetPage(
  name: '/fullscreenPage',
  page: () => const FullscreenPage(),
  fullscreen: true,  // AppBar 显示关闭按钮，非返回箭头
),
```

`fullscreen: true` 的效果：
- `fullscreenDialog: true` → AppBar 左侧显示关闭(X)按钮，而非返回箭头
- 适用于登录页、表单填写页等独立任务流

### 7.4 路由观察者

项目已注册 `VideoDetailPage.routeObserver` 用于 PiP 模式检测：

```dart
navigatorObservers: [
  VideoDetailPage.routeObserver,
],
```

如需添加新的路由观察者（如埋点统计），在 `main.dart` 的 `navigatorObservers` 数组中追加即可。

### 7.5 注意事项

- **路由路径唯一性**: 每条路由的 `name` 必须在全局保持唯一，重复会导致不可预期的跳转行为
- **页面需 `const` 构造**: 所有页面组件应使用 `const` 构造函数（`const MyPage()`），以优化性能
- **参数获取时机**: `Get.parameters` 和 `Get.arguments` 应在 `initState()` 或首次 `build()` 时获取，不要在 `StatelessWidget` 的构造函数中获取
- **Hero 动画**: 跨页面 Hero 动画需要确保路由注册的时间足够短（`const` 构造保证页面实例化不耗时），否则 Hero 无法匹配
- **避免硬编码路径**: 建议将路由路径定义为常量，或在每个页面模块中导出路径常量，减少拼写错误风险

---

## 8. 二改指南

### 8.1 常见二改场景

#### 场景 1: 修改过渡动画

修改 `app_pages.dart` 中 `CustomGetPage` 的默认动画：

```dart
class CustomGetPage extends GetPage<dynamic> {
  CustomGetPage({
    required super.name,
    required super.page,
    this.fullscreen,
    super.transitionDuration,
  }) : super(
          curve: Curves.easeInOut,          // 改为缓入缓出曲线
          transition: Transition.rightToLeft, // 改为统一右滑动画
          // transition: Transition.fadeIn,   // 或淡入效果
          showCupertinoParallax: false,
          popGesture: false,
          fullscreenDialog: fullscreen != null && fullscreen,
        );
  bool? fullscreen = false;
}
```

**GetX 支持的 Transition 类型**:

| Transition | 效果描述 |
|------------|----------|
| `Transition.native` | 平台原生动画（当前使用） |
| `Transition.fadeIn` | 淡入效果 |
| `Transition.rightToLeft` | 统一右滑动画 |
| `Transition.rightToLeftWithFade` | 右滑 + 淡入 |
| `Transition.leftToRight` | 左滑动画 |
| `Transition.downToUp` | 从下向上弹出 |
| `Transition.zoom` | 缩放效果 |
| `Transition.noTransition` | 无动画 |

#### 场景 2: 为特定路由启用全屏弹窗

```dart
CustomGetPage(name: '/loginPage', page: () => const LoginPage()),
// 改为 ↓
CustomGetPage(
  name: '/loginPage',
  page: () => const LoginPage(),
  fullscreen: true,  // 启用全屏弹窗模式
),
```

#### 场景 3: 更换 Android 过渡动画

修改 `main.dart` 中的 `pageTransitionsTheme`：

```dart
// 当前：Zoom 过渡
TargetPlatform.android: ZoomPageTransitionsBuilder(
  allowEnterRouteSnapshotting: false,
),

// 改为：原生滑动
TargetPlatform.android: CupertinoPageTransitionsBuilder(),

// 或：自定义无过渡
TargetPlatform.android: const NoTransitionBuilder(),
```

#### 场景 4: 添加路由中间件（路由守卫）

在 `main.dart` 的 `GetMaterialApp` 中添加 `routingCallback`：

```dart
GetMaterialApp(
  // ... 现有配置 ...
  routingCallback: (routing) {
    if (routing?.current == '/setting' && !isLoggedIn) {
      // 未登录时重定向到登录页
      Get.offAllNamed('/loginPage');
    }
  },
),
```

#### 场景 5: 提取路由路径常量

创建 `lib/router/route_names.dart` 避免硬编码路径：

```dart
class RouteNames {
  static const String home = '/';
  static const String video = '/video';
  static const String member = '/member';
  static const String setting = '/setting';
  static const String playSetting = '/playSetting';
  // ... 所有路由路径 ...
}
```

然后在项目中统一使用：
```dart
// 替换硬编码
Get.toNamed('/video?vid=$vid');
// 使用常量
Get.toNamed('${RouteNames.video}?vid=$vid');
```

#### 场景 6: 修改默认首页

项目支持通过 `SettingBoxKey.defaultHomePage` 修改启动时的默认首页索引（在 `MainApp` 中通过 `PageController` 的 `initialPage` 控制），不涉及路由系统本身的修改。

### 8.2 注意事项

- **修改 `CustomGetPage` 会影响全部路由**: `CustomGetPage` 是所有路由的基类，修改其默认动画、曲线等参数会影响全局的导航体验
- **路由懒加载**: 所有页面通过 `() => const MyPage()` 箭头函数延迟创建，只有在实际导航到时才会实例化页面组件
- **不要绕过路由系统**: 避免直接使用 `Navigator.of(context).push()`，统一使用 `Get.toNamed()` 以保持路由状态一致性
- **`/` 路由不可删除**: 首页路由是应用的入口，`GetMaterialApp` 的 `home: MainApp()` 与 `'/'` 路由需要配合使用
- **添加新路由后需测试**: Hero 动画、Deep Link、返回手势在新路由上可能表现不同，需要专项测试