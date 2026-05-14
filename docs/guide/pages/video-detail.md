---
date: 2026-05-14 22:50:29
title: video-detail
permalink: /pages/efc2f5
categories:
  - guide
  - pages
---
# 视频详情模块（Video Detail）

## 1. 模块概述

视频详情模块是 PiliOtto 项目中**最复杂**的页面模块，路由为 `/video`，负责视频播放、信息展示、评论互动和弹幕交互的全部功能。

模块采用 **Controller-View 分离** + **子模块分层** 的架构，由一个主 Controller 统领，五个子模块各司其职。

### 1.1 目录结构

```
lib/pages/video/detail/
├── controller.dart                 # VideoDetailController - 主控制器（播放、弹幕、Tab 管理）
├── view.dart                       # VideoDetailPage - 主视图（窄屏/宽屏双布局）
├── index.dart                      # 统一导出
├── introduction/                   # 子模块：视频简介
│   ├── controller.dart             #   VideoIntroController - 视频信息、互动操作
│   ├── view.dart                   #   VideoIntroPanel / VideoInfo
│   └── index.dart
├── related/                        # 子模块：相关视频推荐
│   ├── controller.dart             #   RelatedController - 相关视频列表
│   ├── view.dart                   #   RelatedVideoPanel
│   └── index.dart
├── reply/                          # 子模块：评论列表
│   ├── controller.dart             #   VideoReplyController - 评论加载与分页
│   ├── view.dart                   #   VideoReplyPanel
│   └── widgets/
│       ├── reply_item.dart         #   评论条目组件
│       └── comment_input.dart      #   评论输入框组件
├── reply_new/                      # 子模块：新评论对话框
│   ├── view.dart                   #   VideoReplyNewDialog
│   ├── toolbar_icon_button.dart    #   工具栏图标按钮
│   └── index.dart
├── reply_reply/                    # 子模块：评论回复面板（楼中楼）
│   ├── controller.dart             #   VideoReplyReplyController - 二级评论加载
│   ├── view.dart                   #   VideoReplyReplyPanel
│   └── index.dart
└── widgets/                        # 页面专属组件
    ├── app_bar.dart                #   ScrollAppBar - 滚动跟随的顶部栏
    ├── danmaku_send_sheet.dart     #   DanmakuSendSheet - 弹幕发送面板
    ├── expandable_section.dart     #   ExpandedSection - 展开/收起动画容器
    ├── header_control.dart         #   HeaderControl - 播放器顶部控制栏（设置、倍速等）
    └── right_drawer.dart           #   RightDrawer - 右侧抽屉（预留）
```

### 1.2 子模块结构图

```
VideoDetailPage (view.dart)
├── VideoDetailController (主 Controller)
├── HeaderControl (widgets/header_control.dart)
│   ├── 播放设置弹窗（定时关闭 / 播放顺序 / 弹幕设置 / 底部按钮设置）
│   ├── 倍速选择
│   └── 画中画（PiP）控制
├── PLVideoPlayer (pl_player 插件)
│   ├── PlDanmaku (canvas_danmaku 弹幕层)
│   └── 底部控制栏（bottomList）
├── TabBar [简介, 评论]
│   └── TabBarView
│       ├── VideoIntroPanel (introduction/)
│       │   └── VideoIntroController
│       │       ├── 视频标题、统计、简介
│       │       ├── 操作按钮（点赞/收藏/分享）
│       │       └── UP主信息（关注/取关）
│       └── VideoReplyPanel (reply/)
│           ├── VideoReplyController
│           ├── ReplyItem (单条评论)
│           ├── CommentInput (底部评论输入)
│           └── → 点击回复 → showReplyReplyPanel()
│               └── VideoReplyReplyPanel (reply_reply/)
│                   └── VideoReplyReplyController
├── ScrollAppBar (widgets/app_bar.dart)
│   └── 滚动跟随的继续播放/重新播放按钮
├── DanmakuSendSheet (widgets/danmaku_send_sheet.dart)
│   └── 弹幕类型、颜色、字体大小选择
└── VideoReplyNewDialog (reply_new/)
    └── 新评论输入对话框（表情、转发到动态等）
```

### 1.3 路由与传参

路由名称为 `/video`，通过 GetX 路由传参：

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `vid` | `int` | 是 | 视频 ID |
| `heroTag` | `String` | 否 | Hero 动画标签，默认为 `'default'` |
| `videoType` | `String` | 否 | 视频类型，默认为 `'video'`。可选 `'video'` / `'pgc'`（番剧/影视）等 |
| `videoItem` | `dynamic` | 否 | 预加载的视频数据对象（含 `pic` 封面），用于加速首屏渲染 |
| `pic` | `String` | 否 | 视频封面 URL，用于在视频详情加载前显示封面 |

---

## 2. 主 Controller 详解

`VideoDetailController` 是视频详情页的核心控制器，管理播放器生命周期、弹幕、Tab 切换等所有全局状态。

### 2.1 类定义

```dart
class VideoDetailController extends GetxController
    with GetSingleTickerProviderStateMixin
```

- `GetSingleTickerProviderStateMixin`：为单个 `TabController` 提供 `vsync`

### 2.2 Rx 响应式状态

| 变量 | 类型 | 初始值 | 说明 |
|------|------|-------|------|
| `tabs` | `RxList<String>` | `['简介', '评论']` | Tab 标签文字列表 |
| `isLoading` | `RxBool` | `false` | 视频详情加载状态 |
| `autoPlay` | `RxBool` | `true` | 是否自动播放（从设置读取） |
| `isEffective` | `RxBool` | `true` | 视频 URL 是否有效 |
| `isShowCover` | `RxBool` | `true` | 是否显示封面图（播放后隐藏） |
| `bgCover` | `RxString` | `''` | 背景封面图 URL |
| `cover` | `RxString` | `''` | 视频封面图 URL（用于未播放时替代展示） |
| `bottomList` | `RxList<BottomControlType>` | `[]` | 当前播放器底部控制按钮列表 |
| `sheetHeight` | `RxDouble` | `0.0` | 底部面板高度（从本地缓存恢复） |

### 2.3 关键非 Rx 属性

| 变量 | 类型 | 说明 |
|------|------|------|
| `vid` | `int` | 视频 ID，从路由参数中解析 |
| `heroTag` | `String` | Hero 动画标签，用于 GetX 依赖注入的 tag |
| `videoItem` | `Video` | 视频详情对象 |
| `videoType` | `String` | 视频类型（`'video'` / `'pgc'`） |
| `videoUrl` | `String` | 视频播放 URL |
| `plPlayerController` | `PlPlayerController` | 播放器控制器实例 |
| `tabCtr` | `TabController` | Tab 切换控制器 |
| `headerControl` | `HeaderControl` | 播放器顶部控制栏组件 |
| `floating` | `Floating?` | Android 画中画管理器 |
| `scaffoldKey` | `GlobalKey<ScaffoldState>` | 主 Scaffold 的 key（窄屏 / 控制底部面板） |
| `rightContentScaffoldKey` | `GlobalKey<ScaffoldState>` | 右侧内容区 Scaffold key（宽屏） |
| `replyScrollController` | `ScrollController?` | 评论列表的滚动控制器 |
| `halfScreenBottomList` | `RxList<BottomControlType>` | 半屏模式底部按钮配置 |
| `fullScreenBottomList` | `RxList<BottomControlType>` | 全屏模式底部按钮配置 |

### 2.4 生命周期方法

**`onInit()`**

```dart
void onInit() {
  super.onInit();
  plPlayerController = PlPlayerController();           // 1. 创建独立播放器实例
  userInfo = userInfoCache.get('userInfoCache');        // 2. 读取用户信息
  updateCover(argMap['pic']);                           // 3. 设置封面图

  tabCtr = TabController(length: 2, vsync: this);       // 4. 创建 TabController
  autoPlay.value = setting.get(SettingBoxKey.autoPlayEnable, ...);   // 5. 读取自动播放设置
  enableRelatedVideo = setting.get(SettingBoxKey.enableRelatedVideo, ...);

  if (userInfo == null || localCache.get(LocalCacheKey.historyPause) == true) {
    enableHeart = false;                                // 6. 未登录/暂停历史则关闭心跳上报
  }

  if (Platform.isAndroid) {
    floating = Floating();                              // 7. Android 平台初始化画中画
  }

  _initBottomLists();                                   // 8. 初始化底部控制按钮列表
  getVideoDetail();                                     // 9. 发起视频详情请求
  headerControl = HeaderControl(...);                   // 10. 构建顶部控制栏
}
```

**`onClose()`**

```dart
void onClose() {
  plPlayerController.dispose();   // 释放播放器资源
  super.onClose();
}
```

### 2.5 核心方法

#### 2.5.1 视频详情获取 — `getVideoDetail()`

```dart
Future getVideoDetail() async {
  isLoading.value = true;
  videoItem = await _videoRepo.getVideoDetail(vid);  // 调用 Repository
  updateCover(videoItem.coverUrl);
  videoUrl = videoItem.videoUrl ?? '';

  if (videoUrl.isEmpty) {
    isEffective.value = false;       // 无效 → 显示错误面板
    return;
  }

  if (autoPlay.value) {
    await playerInit();              // 自动播放 → 初始化播放器
    isShowCover.value = false;
  }
  isLoading.value = false;
}
```

#### 2.5.2 播放器初始化 — `playerInit()`

```dart
Future<void> playerInit({String? video, Duration? seekToTime, ...}) async {
  // 1. 恢复/设置屏幕亮度
  ScreenBrightness().setApplicationScreenBrightness(brightness!);

  // 2. 设置数据源
  await plPlayerController.setDataSource(
    DataSource(videoSource: video ?? videoUrl, type: DataSourceType.network),
    seekTo: seekToTime ?? defaultST,
    duration: Duration(seconds: (videoItem.duration ?? 0)),
    vid: videoItem.vid,
    enableHeart: enableHeart,     // 是否上报播放心跳
    isFirstTime: isFirstTime,
    autoplay: autoplay ?? autoPlay.value,
  );

  // 3. 传入 headerControl（全屏时需要）
  plPlayerController.headerControl = headerControl;
}
```

#### 2.5.3 弹幕获取 — `getDanmaku()`

```dart
Future getDanmaku() async {
  final danmakus = await _danmakuRepo.getDanmakus(vid);
  _danmakuCount.value = danmakus.length;          // 记录弹幕数量

  if (plPlayerController.danmakuController != null) {
    plPlayerController.danmakuController!.clear(); // 清空旧弹幕
    for (var danmaku in danmakus) {
      // 解析弹幕类型（scroll / top / bottom）和颜色
      DanmakuContentItem item = DanmakuContentItem(
        danmaku.text,
        color: _parseDanmakuColor(danmaku.color),
        type: type,
      );
      plPlayerController.danmakuController!.addDanmaku(item);  // 添加到渲染层
    }
  }
}
```

#### 2.5.4 发送弹幕 — `showShootDanmakuSheet()`

```dart
void showShootDanmakuSheet() {
  DanmakuSendSheet.show(
    vid: vid,
    currentTime: plPlayerController.position.value.inSeconds,
    onSend: ({required vid, required text, required time, required mode, required color, required fontSize}) {
      return _danmakuRepo.sendDanmaku(vid: vid, text: text, time: time, mode: mode, color: color, fontSize: fontSize, render: '');
    },
  );
}
```

打开底部弹幕发送面板，选择弹幕类型（滚动/顶部/底部）、颜色和字体大小后发送。

#### 2.5.5 评论回复面板 — `showReplyReplyPanel()`

```dart
void showReplyReplyPanel(int oid, int fRpid, dynamic firstFloor, dynamic currentReply, bool loadMore) {
  final bool isWideScreen = Get.size.width > 768;
  final scaffold = isWideScreen ? rightContentScaffoldKey : scaffoldKey;

  replyReplyBottomSheetCtr = scaffold.currentState?.showBottomSheet((context) {
    return VideoReplyReplyPanel(
      vid: oid, parentVcid: fRpid,
      firstFloor: firstFloor,      // 被回复的顶层评论
      currentReply: currentReply,  // 用户刚发送的回复（用于乐观插入）
      loadMore: loadMore,
      replyType: ReplyType.video,
      sheetHeight: isWideScreen ? null : sheetHeight.value,
    );
  });
}
```

宽屏模式下将二级回复面板显示在右侧内容区域，窄屏模式显示在底部弹出面板中。

#### 2.5.6 底部按钮管理

```dart
// 切换到底部按钮列表
void switchToHalfScreen() { bottomList.value = List<BottomControlType>.from(halfScreenBottomList); }
void switchToFullScreen() { bottomList.value = List<BottomControlType>.from(fullScreenBottomList); }

// 保存自定义按钮布局到 Hive
void saveBottomLists() {
  videoStorage.put(VideoBoxKey.halfScreenBottomList, BottomControlTypeExtension.toCodeList(halfScreenBottomList));
  videoStorage.put(VideoBoxKey.fullScreenBottomList, BottomControlTypeExtension.toCodeList(fullScreenBottomList));
}
```

### 2.6 RouteObserver — 页面可见性追踪

`VideoDetailPage` 使用静态 `RouteObserver` 追踪页面可见性：

```dart
static final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
```

在 `didChangeDependencies` 中订阅：
```dart
void didChangeDependencies() {
  super.didChangeDependencies();
  VideoDetailPage.routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
}
```

配合 `RouteAware` mixin，实现以下生命周期行为：

| 事件 | 行为 |
|------|------|
| `didPushNext` | 离开当前页 → 暂停播放器、保存播放进度、隐藏 UI |
| `didPopNext` | 返回当前页 → 恢复播放状态、seek 到上次位置、继续播放 |

---

## 3. Introduction 子模块 — 视频简介

`VideoIntroController` 管理视频元数据和用户互动操作。

### 3.1 Controller 核心状态

| 变量 | 类型 | 说明 |
|------|------|------|
| `videoDetail` | `Rx<Video>` | 视频详情数据（标题、简介、UP 主、统计等） |
| `follower` | `RxInt` | UP 主粉丝数 |
| `hasLike` | `RxBool` | 当前用户是否已点赞 |
| `hasFav` | `RxBool` | 当前用户是否已收藏 |
| `followStatus` | `RxBool` | 当前用户是否已关注 UP 主 |

### 3.2 核心方法

| 方法 | 说明 |
|------|------|
| `queryVideoIntro()` | 请求视频详情，同时查询 UP 主粉丝数、点赞/收藏/关注状态 |
| `actionLikeVideo()` | 点赞/取消点赞，操作后刷新视频详情 |
| `actionFavVideo()` | 收藏/取消收藏，操作后刷新视频详情 |
| `actionOneThree()` | 一键三连（点赞+收藏），已操作过则提示 |
| `actionShareVideo()` | 分享视频链接（`share_plus` 插件） |
| `actionRelationMod()` | 关注/取关 UP 主（弹窗确认） |
| `switchVideo(vid, cover)` | 切换到新视频（用于相关视频推荐） |

### 3.3 View 组件

`VideoInfo` 渲染视频简介的 Sliver 区域：

```
VideoInfo (SliverPadding → SliverToBoxAdapter)
├── 视频标题 (SelectableText, 最多两行)
├── 统计信息行
│   ├── StatView (播放量)
│   ├── StatDanMu (弹幕数)
│   ├── 发布时间
│   └── 视频编号 (OV{vid})
├── 视频简介 (MarkdownText, 支持富文本)
├── 操作按钮行 (actionGrid)
│   ├── 点赞 (ActionItem, 长按触发一键三连)
│   ├── 收藏 (ActionItem)
│   └── 分享 (ActionItem)
└── UP主信息卡片
    ├── 头像 (NetworkImgLayer)
    ├── 用户名 + 粉丝数
    └── 关注按钮 (FilledButton.tonal, Obx 响应式)
```

所有互动操作均有**未登录保护**：检测 `userInfo == null` 时提示"账号未登录"。

---

## 4. Related 子模块 — 相关视频

`RelatedController` 管理相关视频推荐列表。

### 4.1 Controller

```dart
class RelatedController extends GetxController {
  RxList relatedVideoList = <Video>[].obs;

  Future<dynamic> queryRelatedVideo() async {
    final response = await _videoRepo.getRelatedVideos(vid);
    relatedVideoList.value = response.videoList;
  }
}
```

### 4.2 View

`RelatedVideoPanel` 使用 `SliverList` 渲染横向视频卡片列表：

- 加载中：`VideoCardHSkeleton` 骨架屏（5 条）
- 加载成功：`VideoCardH` 组件 + `showPubdate: true` 显示发布时间
- 加载失败：`HttpError` 错误组件
- 列表末尾预留底部安全区域高度

---

## 5. Reply 子模块 — 评论系统

`VideoReplyController` 管理一级评论的分页加载和数据缓存。

### 5.1 Controller 核心状态

| 变量 | 类型 | 说明 |
|------|------|------|
| `vid` | `int` | 当前视频 ID（支持动态更新） |
| `replyList` | `List<ReplyItemModel>` | 评论数据列表 |
| `currentPage` | `int` | 当前页码（从 0 开始） |
| `isLoadingMore` | `bool` | 是否正在加载更多 |
| `noMore` | `String` | 加载状态提示（`'没有更多了'` / `'获取评论失败'`） |

### 5.2 分页加载逻辑

```dart
Future queryReplyList({String type = 'init'}) async {
  if (type == 'init') { currentPage = 0; noMore = ''; }  // 刷新时重置
  if (noMore == '没有更多了') return;                     // 已无更多数据

  final result = await _commentRepo.getVideoComments(
    vid: vid, offset: currentPage * ps, num: ps,          // ps = 12 条/页
  );

  if (type == 'init') replyList = result.replies;         // 刷新：替换
  else replyList.addAll(result.replies);                  // 加载更多：追加

  if (!result.hasMore) noMore = '没有更多了';             // 标记到底
  else currentPage++;
}
```

### 5.3 二级评论预加载

```dart
Future<List<ReplyItemModel>> queryChildComments(int parentVcid) async {
  final result = await _commentRepo.getVideoComments(
    vid: vid, parentVcid: parentVcid, offset: 0, num: ps,
  );
  return result.replies;
}
```

获取指定父评论下的子评论列表，用于 `ReplyItem` 组件展示楼中楼前几条回复。

### 5.4 View 组件

`VideoReplyPanel` 是整个评论系统的视图容器：

```
VideoReplyPanel
├── Expanded
│   └── RefreshIndicator
│       └── GetBuilder<VideoReplyController>
│           └── ListView.builder
│               ├── 空状态：骨架屏 / "暂无评论，快来抢沙发喵~"
│               ├── ReplyItem (每条评论)
│               │   └── replyReply 回调 → VideoDetailController.showReplyReplyPanel()
│               └── 底部：加载中 / "没有更多了"
└── CommentInput (底部固定评论输入框)
    └── onCommentSuccess → refresh() 重新加载评论列表
```

**滚动加载**：通过 `ScrollController` 监听，距离底部 300px 时触发 `onLoad()`。

---

## 6. Reply_reply 子模块 — 评论回复

`VideoReplyReplyController` 管理楼中楼（二级评论）的分页加载。

### 6.1 Controller

```dart
class VideoReplyReplyController extends GetxController {
  VideoReplyReplyController(this.vid, this.parentVcid, this.replyType);
  int vid;
  int parentVcid;                               // 被回复的评论 rpid
  ReplyType replyType;
  RxList<ReplyItemModel> replyList = <ReplyItemModel>[].obs;
  int currentPage = 0;
  RxString noMore = ''.obs;
}
```

### 6.2 乐观插入机制

`queryReplyList` 方法中有一个巧妙的乐观更新设计——当用户刚发送完回复后，新回复会被插入到列表第一行：

```dart
if (replyList.isNotEmpty && currentReply != null) {
  // 避免重复：如果列表中已有同 ID 回复，先移除
  int indexToRemove = replyList.indexWhere((item) => currentReply.rpid == item.rpid);
  if (indexToRemove != -1) replyList.removeAt(indexToRemove);
  // 首轮加载时将用户刚发送的回复插入首位
  if (currentPage == 1 && type == 'init') {
    replyList.insert(0, currentReply);
  }
}
```

### 6.3 View 组件

`VideoReplyReplyPanel` 渲染二级回复面板：

```
VideoReplyReplyPanel
├── AppBar (标题 "评论详情" + 关闭按钮)
├── Expanded
│   └── RefreshIndicator
│       └── CustomScrollView
│           ├── firstFloor (被回复的顶层评论)
│           ├── Divider (分隔线)
│           └── SliverList (二级评论列表)
│               ├── 加载中：骨架屏
│               ├── 空状态：暂无回复
│               └── ReplyItem (replyLevel='2', showReplyRow=false)
└── CommentInput (底部评论输入框)
    └── parentVcid 绑定到被回复评论的 rpid
```

- 宽屏模式（`sheetHeight == null`）时面板填充右侧内容区域
- 窄屏模式指定 `sheetHeight` 作为底部弹出面板高度

---

## 7. Reply_new 子模块 — 新评论对话框

`VideoReplyNewDialog` 是一个独立的评论输入对话框。

### 7.1 功能特性

- 通过 `WidgetsBindingObserver` 监听键盘高度变化，动画适配
- 支持工具栏（键盘切换、转发到动态开关）
- 防抖处理（`Debouncer` 200ms）避免频繁触发
- 提交成功后通过 `Get.back(result: true)` 返回到上级页面

### 7.2 UI 结构

```
Container (圆角顶部)
├── TextField (多行输入，minLines=3, 无边框)
├── Divider
└── 底部工具栏 Row
    ├── ToolbarIconButton (键盘切换)
    ├── TextButton.icon (转发到动态，视频页面专用)
    ├── Spacer
    └── FilledButton (发送按钮，Obx 绑定 message.isNotEmpty)
```

---

## 8. Widgets 组件

### 8.1 ScrollAppBar — 滚动跟随顶部栏

`ScrollAppBar` 位于播放器区域上方，当用户向下滚动内容区域时逐渐显示：

```dart
class ScrollAppBar extends StatelessWidget {
  final double scrollVal;        // 当前滚动偏移量
  final Function callback;       // 点击回调（继续播放/重新播放）
  final PlayerStatus playerStatus; // 播放器状态
}
```

- **动画逻辑**：`scrollVal / (videoHeight - kToolbarHeight)` 计算透明度
- **限制距离**：`scrollVal > videoHeight - kToolbarHeight` 时截断，避免完全透明
- 根据 `playerStatus` 显示不同按钮文字：`'继续播放'` / `'重新播放'` / `'播放中'`

### 8.2 DanmakuSendSheet — 弹幕发送面板

`DanmakuSendSheet` 提供完整的弹幕编辑与发送 UI：

```
Container
├── 标题行 ("发送弹幕" + 关闭按钮)
├── 输入行
│   ├── TextField (多行输入, 最大 100 字符)
│   └── IconButton.filled (发送, 发送中显示 CircularProgressIndicator)
├── 弹幕类型选择
│   ├── ChoiceChip: 滚动 (scroll) / 顶部 (top) / 底部 (bottom)
├── 弹幕颜色选择
│   └── Wrap: 8 种预设颜色圆点 (白/红/橙/黄/绿/青/蓝/紫)
└── 字体大小选择
    ├── ChoiceChip: 小 (18px) / 中 (25px) / 大 (36px)
```

- 使用 `MediaQuery.of(context).viewInsets.bottom` 适配键盘高度
- 发送前校验：内容不能为空、不超过 100 字符
- `onSend` 回调中调用 `IDanmakuRepository.sendDanmaku`

### 8.3 HeaderControl — 播放器顶部控制栏

`HeaderControl` 是播放器区域的顶层控制入口。

**核心功能入口：**

| 按钮 | 功能 |
|------|------|
| 返回箭头 | 退出全屏/返回上一页 |
| 首页图标 | 回到首页（dispose 播放器后 pop 到首页） |
| 画中画（Android） | 触发 `Floating.enable()` 进入 PiP 模式 |
| 倍速按钮 | 弹出倍速选择对话框 |
| 更多按钮 | 打开播放设置底部面板 |

**播放设置面板（Navigator 路由）：**

```
/ (主页面)
├── 定时关闭 → /scheduleExit
├── 播放顺序 → /repeat
├── 弹幕设置 → /danmaku
└── 底部按钮设置 → /bottomControl
```

**弹幕设置子页面**包含：

- 按类型屏蔽（顶部/滚动/底部/彩色）
- 显示区域（1/4 屏 / 半屏 / 3/4 屏 / 满屏）
- 不透明度（0%~100%，Slider）
- 描边粗细（0~3，Slider）
- 字体大小（50%~250%，Slider）
- 弹幕时长（2~16 秒，Slider）

**底部按钮设置子页面**：

- 双 Tab（半屏 + 全屏），各自可独立配置
- `ReorderableListView` 支持拖拽排序
- 可用按钮：播放/暂停、时间、占位、分集、比例、倍速、全屏
- 保存到 Hive `videoStorage` 持久化

### 8.4 ExpandedSection — 可展开动画容器

`ExpandedSection` 是一个通用的展开/收起动画组件：

- 使用 `AnimationController` + `SizeTransition` 实现高度动画
- 支持自定义 `begin` / `end` 比例（Tween）
- `didUpdateWidget` 中检测 `expand` 变化自动触发动画

---

## 9. 播放器集成 — PLVideoPlayer

### 9.1 播放器创建与使用

在 `VideoDetailController.onInit()` 中创建独立播放器实例：

```dart
plPlayerController = PlPlayerController();
```

在 View 中通过 `PLVideoPlayer` 组件渲染：

```dart
PLVideoPlayer(
  controller: plPlayerController!,
  headerControl: vdCtr.headerControl,       // 顶部控制栏
  danmuWidget: PlDanmaku(                   // 弹幕层
    key: Key(vdCtr.vid.toString()),
    vid: vdCtr.vid,
    playerController: plPlayerController!,
  ),
  bottomList: vdCtr.bottomList.toList(),     // 底部控制栏按钮
);
```

### 9.2 播放状态监听

```dart
void playerListener(PlayerStatus status) async {
  playerStatus.value = status;

  // 播放完成处理
  if (status == PlayerStatus.completed) {
    shutdownTimerService.handleWaitingFinished();     // 定时关闭：播放完成回调

    if (playRepeat == PlayRepeat.listOrder || ...) {  // 顺序/列表循环
      videoIntroController.nextPlay();                // 自动播放下一个
    }
    if (playRepeat == PlayRepeat.singleCycle) {       // 单曲循环
      plPlayerController!.seekTo(Duration.zero);
      plPlayerController!.play();
    }
    plPlayerController!.onLockControl(false);         // 解锁控制器
  }
}
```

### 9.3 全屏切换与按钮布局

```dart
plPlayerController?.isFullScreen.listen((bool isFullScreen) {
  if (isFullScreen) {
    vdCtr.hiddenReplyReplyPanel();     // 全屏时关闭底部回复面板
    vdCtr.switchToFullScreen();        // 切换为全屏底部按钮列表
  } else {
    vdCtr.switchToHalfScreen();        // 切换为半屏底部按钮列表
  }
});
```

### 9.4 键盘快捷键（桌面端）

在 `_handleKeyEvent` 中处理桌面端键盘操作：

| 按键 | 功能 |
|------|------|
| 空格 | 播放/暂停 |
| ← | 后退 5 秒 |
| → | 前进 5 秒 |
| ↑ | 音量 +0.1 |
| ↓ | 音量 -0.1 |
| F | 切换全屏 |
| Esc | 退出全屏 |

### 9.5 画中画（PiP）

仅 Android 平台支持，通过 `floating` 包实现：

- **自动进入**：播放中且 `autoPiP == true` 时启用
- **自动退出**：暂停/播放完毕时取消
- **宽高比**：从 `videoItem.videoWidth` / `videoItem.videoHeight` 计算

---

## 10. 数据流

### 10.1 页面初始化数据流

```
路由跳转 → /video?vid=xxx
  → VideoDetailController.onInit()
    ├── PlPlayerController() 实例化
    ├── Hive 读取: userInfo, autoPlay, enableRelatedVideo
    ├── 路由参数解析: vid, heroTag, videoType, pic
    ├── _initBottomLists() → Hive 读取自定义按钮布局
    ├── getVideoDetail()
    │   ├── IVideoRepository.getVideoDetail(vid)
    │   │   → videoItem (标题/封面/时长/URL)
    │   ├── autoPlay == true
    │   │   → playerInit()
    │   │       → plPlayerController.setDataSource()
    │   │       → 播放器就绪，isShowCover = false
    │   └── isLoading.value = false
    └── headerControl = HeaderControl(...)
```

### 10.2 视频播放数据流

```
plPlayerController (pl_player 插件)
  ├── position (Rx<Duration>) → 当前播放位置
  ├── duration (Rx<Duration>) → 视频总时长
  ├── isFullScreen (Rx<bool>) → 全屏状态
  │   └── listen → switchToFullScreen() / switchToHalfScreen()
  ├── playbackSpeed (Rx<double>) → 当前倍速
  ├── isOpenDanmu (Rx<bool>) → 弹幕开关
  │   └── 切换 → _saveDanmakuStatus() → Hive
  ├── danmakuController (DanmakuController) → 弹幕渲染引擎
  │   ├── clear() + addDanmaku() → getDanmaku() 数据注入
  │   └── updateOption() → 弹幕样式实时更新
  └── playerStatus (PlayerStatus)
      └── playerListener → 播放完成/暂停/PiP 等状态处理
```

### 10.3 评论数据流

```
VideoReplyController
  → ICommentRepository.getVideoComments(vid, offset, num)
    → replyList (List<ReplyItemModel>)
      → ReplyItem 组件渲染

用户点击"回复"
  → VideoDetailController.showReplyReplyPanel(oid, fRpid, ...)
    → showBottomSheet
      → VideoReplyReplyController(oid, fRpid)
        → ICommentRepository.getVideoComments(vid, parentVcid, ...)
          → replyList (二级评论)
```

### 10.4 视频切换数据流（相关视频 → 新视频）

```
RelatedVideoPanel → 用户点击 VideoCardH
  → VideoIntroController.switchVideo(newVid, newCover)
    ├── VideoDetailController.vid = newVid
    ├── VideoDetailController.cover = newCover
    ├── VideoDetailController.getVideoDetail()   → 重新获取视频
    ├── VideoReplyController.updateVid(newVid)   → 清空旧评论 + 重新加载
    └── VideoIntroController.queryVideoIntro()   → 重新获取简介
```

### 10.5 滚动联动数据流

```
用户向下滚动内容区域
  → _extendNestCtr (ScrollController)
    └── listener: offset = _extendNestCtr.position.pixels
        ├── appbarStream.add(offset)
        │   → StreamBuilder 重建 AppBar (状态栏颜色切换)
        │   → ScrollAppBar 透明度更新 (scrollVal / videoHeight)
        └── vdCtr.sheetHeight.value = Get.size.height - videoHeight - statusBarHeight + offset
            → 底部面板高度动态更新
```

---

## 11. 使用示例

### 11.1 视频详情页跳转

```dart
import 'package:get/get.dart';

void navigateToVideo(int vid, {String? cover, String? heroTag}) {
  Get.toNamed('/video?vid=$vid', arguments: {
    'pic': cover,
    'heroTag': heroTag ?? 'video_$vid',
    'videoType': 'video',
  });
}

void navigateToBangumi(int epid) {
  Get.toNamed('/video?epid=$epid', arguments: {
    'videoType': 'bangumi',
  });
}
```

### 11.2 VideoDetailController 使用

```dart
import 'package:get/get.dart';
import 'package:piliotto/pages/video_detail/controller.dart';

class VideoActionWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VideoDetailController>();
    
    return Obx(() => Row(
      children: [
        IconButton(
          icon: Icon(controller.isLiked.value 
            ? Icons.thumb_up 
            : Icons.thumb_up_outlined),
          onPressed: () => controller.toggleLike(),
        ),
        IconButton(
          icon: Icon(controller.isCoined.value 
            ? Icons.monetization_on 
            : Icons.monetization_on_outlined),
          onPressed: () => controller.showCoinDialog(),
        ),
        IconButton(
          icon: Icon(controller.isFavoured.value 
            ? Icons.star 
            : Icons.star_border),
          onPressed: () => controller.showFavDialog(),
        ),
      ],
    ));
  }
}
```

### 11.3 弹幕控制

```dart
import 'package:piliotto/pages/video_detail/controller.dart';

void toggleDanmaku(VideoDetailController controller) {
  controller.showDanmaku.value = !controller.showDanmaku.value;
}

void setDanmakuOpacity(VideoDetailController controller, double opacity) {
  controller.danmakuOpacity.value = opacity;
  controller.danmakuController?.setOpacity(opacity);
}

void setDanmakuFontSize(VideoDetailController controller, double scale) {
  controller.danmakuScale.value = scale;
  controller.danmakuController?.setFontScale(scale);
}
```

### 11.4 播放控制

```dart
import 'package:piliotto/pages/video_detail/controller.dart';

void controlPlayback(VideoDetailController controller) {
  controller.plPlayerController.play();
  controller.plPlayerController.pause();
  controller.plPlayerController.seekTo(Duration(minutes: 5));
  controller.plPlayerController.setPlaybackSpeed(1.5);
}

void toggleFullscreen(VideoDetailController controller) {
  controller.plPlayerController.triggerFullScreen(
    !controller.isFullScreen.value
  );
}
```

---

## 12. 开发指南

### 12.1 新增视频类型支持

如需支持新视频类型（如互动视频），在以下位置添加处理：

1. `VideoDetailController.onInit()` 中根据 `videoType` 添加条件逻辑
2. `VideoIntroPanel` 中 `CustomScrollView` 的 `slivers` 添加新类型的专属 Section
3. `HeaderControl.build()` 中 `isLandscape && widget.videoType == 'video'` 的判断也需扩展

### 12.2 添加新操作按钮

在 `VideoInfo.actionGrid()` 中：

1. 向 `menuListWidgets` Map 添加新的按钮项
2. 在 `actionTypeSort` 配置中添加对应的 key
3. 在 `VideoIntroController` 中实现对应的业务逻辑方法

### 12.3 自定义弹幕渲染

弹幕渲染由 `canvas_danmaku` 包提供。修改弹幕渲染行为：

- **弹幕过滤**：在 `VideoDetailController.getDanmaku()` 中过滤 `danmakus` 列表
- **弹幕样式**：在 `HeaderControl._buildDanmakuPage()` 中调整 Slider 范围
- **弹幕缓存**：`_updateDanmakuOption()` 方法将 `plPlayerController` 上的状态映射到 `danmakuController.option`

---

## 13. 二改指南

### 13.1 替换播放器引擎

当前播放器封装在 `lib/plugin/pl_player/` 中。如需替换播放器：

1. **保持接口兼容**：确保新播放器的 Controller 提供相同的核心接口：
   - `setDataSource(DataSource, ...)` — 数据源设置
   - `position` / `duration` — 响应式播放进度
   - `isFullScreen` — 全屏状态流
   - `danmakuController` — 弹幕控制器
   - `headerControl` — 顶部控制栏
   - `bottomList` — 底部按钮列表

2. **更新 View 绑定**：修改 `view.dart` 中 `PLVideoPlayer` 的调用

3. **重写 `onClose`**：确保新播放器资源的正确释放

### 13.2 移除弹幕功能

1. 从 `PLVideoPlayer` 中移除 `danmuWidget` 参数
2. 从 `VideoDetailController` 中移除 `getDanmaku()` 和 `showShootDanmakuSheet()`
3. 从 `HeaderControl` 中移除弹幕设置页面和弹幕开关按钮
4. 从 `tabbarBuild()` 中移除弹幕开关图标按钮
5. 从 `introduction/view.dart` 中移除 `StatDanMu` 组件

### 13.3 禁用桌面端键盘快捷键

修改 `_handleKeyEvent` 方法为空即可：

```dart
void _handleKeyEvent(LogicalKeyboardKey key) {
  // 不处理任何键盘事件
}
```

### 13.4 移除 PiP（画中画）支持

1. 从 `VideoDetailController.onInit()` 中移除 `floating = Floating()`
2. 从 `view.dart` 中移除 `floating` 所有相关逻辑（`autoEnterPip`, `playerListener` 中的 PiP 代码）
3. 从 `HeaderControl.build()` 中移除画中画按钮

### 13.5 禁用宽屏布局

在 `view.dart` 的 `build` 方法中：

```dart
// 将
child: isWideScreen ? buildWideScreenLayout() : buildNarrowScreenLayout(),

// 改为
child: buildNarrowScreenLayout(),
```

### 13.6 注意事项

1. **Controller 的 tag 管理**：`VideoDetailController` 和 `VideoIntroController` 使用 `heroTag` 作为 GetX 的 tag 进行依赖注入。如果同一页面上需要显示多个视频详情（如宽屏分屏），必须使用不同的 `heroTag`。

2. **播放器生命周期**：`PlPlayerController` 在 `VideoDetailController.onInit()` 中创建，在 `onClose()` 中 dispose。View 中的 `didPushNext` / `didPopNext` 只是暂停/恢复播放，不销毁播放器实例。

3. **路由 Observer**：`VideoDetailPage.routeObserver` 是静态成员，全局共享。订阅在 `didChangeDependencies`，取消订阅依赖 `RouteAware` 的自动管理。

4. **宽屏适配阈值**：当前宽屏判断阈值为 `Get.size.width > 768`，在 `view.dart` 的多处（`buildWideScreenLayout`、`showReplyReplyPanel`、`HeaderControl.showSettingSheet`）使用此判断。

5. **底部面板的双 Scaffold Key**：
   - `scaffoldKey`：主视图 Scaffold（窄屏 + 宽屏左侧播放器区域）
   - `rightContentScaffoldKey`：宽屏右侧内容区域 Scaffold
   - 调用 `showBottomSheet` 时需要根据当前是否为宽屏选择正确的 Scaffold

6. **Hive 数据依赖**：
   - `setting` Box：自动播放、自动 PiP、自动退出全屏、弹幕开关等
   - `videoStorage` Box：底部按钮布局（半屏+全屏）
   - `localCache` Box：`sheetHeight`（底部面板高度记忆）、`historyPause`（暂停历史记录）