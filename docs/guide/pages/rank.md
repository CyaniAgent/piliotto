---
date: 2026-05-14 22:54:20
title: rank
permalink: /pages/
categories:
  - guide
  - pages
---
# 排行榜页（Rank & ZoneRank）

## 1. 模块概述

排行榜模块由两个页面组成：`RankPage` 展示全站视频排行榜（支持时间切换），`ZoneRankPage` 展示特定分区/分类下的排行榜。

| 页面 | 路由 | 数据源 | 用途 |
|------|------|--------|------|
| `RankPage` | `/rank` | `IVideoRepository.getPopularVideos()` | 全站热门视频排行（热门/周榜/月榜） |
| `ZoneRankPage` | `/zoneRank?rid={rid}` | Controller 内部 `queryRankFeed()` | 分区排行（预留接口，当前数据为 stub） |

### 文件结构

```
lib/pages/rank/
├── controller.dart      # RankController - 全站排行控制器
├── view.dart            # RankPage - 全站排行 UI
├── index.dart           # 模块导出
└── zone/
    ├── controller.dart  # ZoneController - 分区排行控制器
    ├── view.dart        # ZonePage - 分区排行 UI
    └── index.dart       # 子模块导出
```

### 依赖关系

```
RankPage (StatefulWidget + AutomaticKeepAliveClientMixin)
  ├── Get.put → RankController
  ├── IVideoRepository → getPopularVideos(timeLimit, offset: 0, num: 50)
  ├── TabBar + TabController (GetTickerProviderStateMixin)
  ├── RefreshIndicator + CustomScrollView + ScrollController
  ├── ResponsiveUtil → crossAxisCount
  ├── VideoCardH (source: 'rank', rankIndex: index + 1)
  └── VideoCardHSkeleton (加载骨架屏)

ZonePage (StatefulWidget + AutomaticKeepAliveClientMixin)
  ├── Get.put → ZoneController (tag: rid)
  ├── RefreshIndicator + CustomScrollView + ScrollController
  ├── FutureBuilder → 加载/成功/失败三态
  ├── ResponsiveUtil → crossAxisCount
  ├── VideoCardH + VideoCardHSkeleton
  └── HttpError (加载失败组件)
```

---

## 2. RankController 详解

**源文件：** `controller.dart`

`RankController` 继承自 `GetxController` 并混合 `GetTickerProviderStateMixin`（提供 TabController 的 vsync）。

### 2.1 核心属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `tabController` | `TabController` | Tab 控制器（3 个 Tab），通过 vsync 绑定 |
| `scrollController` | `ScrollController` | 滚动控制器 |
| `videoList` | `RxList<Video>` | 视频排行榜列表 |
| `isLoading` | `RxBool` | 加载状态 |
| `crossAxisCount` | `RxInt` | 响应式网格列数（1~3） |
| `tabs` | `List<Map>` | Tab 配置：[热门(1) / 周榜(7) / 月榜(30)] |
| `currentTabIndex` | `RxInt` | 当前选中的 Tab 索引 |

### 2.2 核心方法

**`onInit()`**
初始化 `TabController`（`length: 3` + `vsync: this`），注册 `_onTabChanged` 监听，计算列数，调用 `loadVideos()`。

**`_onTabChanged()`**
TabController 的 index 监听。index 变化时更新 `currentTabIndex` 并重新调用 `loadVideos()`。注意与 `HotController.onTabChanged()` 的区别：RankController 使用 TabController 驱动，HotController 使用 `onSelected` 回调驱动。

**`updateCrossAxisCount()`**
通过 `ResponsiveUtil.calculateCrossAxisCount(baseCount: 1, minCount: 1, maxCount: 3)` 动态计算列数。

**`loadVideos()`**
核心数据加载方法：
- 设置 `isLoading = true`
- 调用 `_videoRepo.getPopularVideos(timeLimit, offset: 0, num: 50)`，一次性加载 50 条
- 更新 `videoList.value`
- 异常时仅记录日志
- finally 中设置 `isLoading = false`

**`onRefresh()`**
下拉刷新：调用 `loadVideos()` 重新加载。

**`animateToTop()`**
程序化滚动到顶部：超过 5 屏高度 `jumpTo(0)`，否则平滑 `animateTo`。用于点击当前 Tab 时回到顶部的快捷操作。

**`onClose()`**
移除 TabController 监听、释放 TabController 和 ScrollController。

### 2.3 与 HotController 的对比

| 对比项 | RankController | HotController |
|--------|----------------|---------------|
| 数据量 | 一次性加载 50 条（无分页） | 分页加载，每页 20 条 |
| Tab 切换 | `TabController` + `TabBar` | `FilterChip` + `currentTabIndex` |
| 加载状态 | `RxBool isLoading` | `isLoadingMore` (非 Rx) |
| 滚动加载 | 不支持（单次加载） | 支持滚动触底加载更多 |
| 空数据提示 | 内联 Icon + Text | `HttpError` 组件 |
| 加载骨架屏 | `ListView.builder` 布局 | `SliverGrid` 布局 |
| 排名序号 | `rankIndex: index + 1` | 不显示排名 |

---

## 3. RankView 详解

**源文件：** `view.dart`

`RankPage` 是一个 `StatefulWidget`，混合 `AutomaticKeepAliveClientMixin`。

### 3.1 页面结构

```
Scaffold
├── AppBar (title: "排行榜")
└── body: Column
    ├── _buildTabBar (高度 42px, TabBar)
    └── Expanded
        └── Obx → _buildVideoList
            ├── [isLoading] → ListView + VideoCardHSkeleton × 10
            ├── [空列表] → Center: Icon + "暂无数据"
            └── [有数据] → RefreshIndicator
                └── CustomScrollView + ScrollController
                    └── SliverPadding
                        └── SliverGrid (crossAxisCount: 1~3)
                            └── VideoCardH (source: 'rank', rankIndex: index+1)
```

### 3.2 Tab 栏

`_buildTabBar()` 使用 Material 原生 `TabBar`，通过 `tabController` 控制。`TabAlignment.center` 使 Tab 居中分布，`dividerColor: Colors.transparent` 隐藏分割线。点击当前 Tab 时除 `feedBack()` 外还调用 `animateToTop()` 回到顶部。

### 3.3 VideoCardH 排名展示

排行榜页面的 `VideoCardH` 传入两个特殊参数：
- `source: 'rank'` → 标识来源为排行榜，组件内部可能展示排名序号
- `rankIndex: index + 1` → 排名序号（从 1 开始）

---

## 4. ZoneRankPage 详解

**源文件：** `controller.dart` | `view.dart`

`ZoneRankPage` 展示特定分区（`rid`）下的排行视频。当前 **数据源为 stub 实现**，`queryRankFeed` 方法中的 `res` 为硬编码空数据，实际接入 API 时需要替换。

### 4.1 ZoneController

| 属性 | 类型 | 说明 |
|------|------|------|
| `scrollController` | `ScrollController` | 滚动控制器 |
| `videoList` | `RxList<Map<String, dynamic>>` | 视频列表（响应式） |
| `isLoadingMore` | `bool` | 加载更多防重复标志 |
| `zoneID` | `int` | 当前分区 ID |
| `crossAxisCount` | `RxInt` | 响应式网格列数（1~3） |

**`queryRankFeed(String type, int rid)`**
数据查询方法（当前为 stub）：
- `type == 'init'`：覆盖 `videoList`
- `type == 'onRefresh'`：清空后重新赋值
- `type == 'onLoad'`：清空后重新赋值（与 onRefresh 行为相同，需接入实际分页 API）

**`onRefresh()` / `onLoad()`**
直接调用 `queryRankFeed('onRefresh'/'onLoad', zoneID)`。

**`animateToTop()`**
与 `RankController.animateToTop()` 逻辑相同。

### 4.2 ZonePage

`ZonePage` 接收 `rid` 参数，Controller 以 `tag: rid.toString()` 注册，确保不同分区实例隔离。

页面结构与 `HotPage` 类似：
```
RefreshIndicator
└── CustomScrollView
    ├── SliverPadding
    │   └── FutureBuilder
    │       ├── [loading] → VideoCardHSkeleton × 10
    │       ├── [error] → HttpError (显示 data['msg'])
    │       └── [success] → Obx
    │           └── SliverGrid + VideoCardH (showPubdate: true)
    └── SliverToBoxAdapter (底部安全区)
```

滚动监听：距底部 200px 触发 `onLoad()`。

### 4.3 已知问题

- `queryRankFeed` 中的 `res` 始终返回空状态（`status: true, data: []`），实际数据需待 API 接入
- `onLoad` 和 `onRefresh` 行为相同，均为全量刷新，无真正分页逻辑
- 在 `dispose` 中 `scrollController.removeListener(() {})` 存在潜在问题（传入空闭包而非原始监听器引用，可能无法正确移除）

---

## 5. 数据流

```
┌──────────────────────────────────┐
│  RankPage / ZonePage initState   │
└───────────────┬──────────────────┘
                │
   ┌────────────┼────────────┐
   ▼            ▼            ▼
RankController  │   ZoneController
loadVideos()    │   queryRankFeed()
   │            │            │
   ▼            │            ▼
IVideoRepository│   (stub data)
getPopularVideos│   videoList
(timeLimit,     │   (RxList<Map>)
 offset:0,      │
 num:50)        │
   │            │
   ▼            ▼
videoList     videoList
(RxList<Video>)(RxList<Map>)
   │            │
   └─────┬──────┘
         ▼
   ┌───────────┐
   │ SliverGrid │
   │ VideoCardH │
   └───────────┘
```

### 数据模型差异

| 页面 | 列表类型 | 模型 |
|------|----------|------|
| RankPage | `RxList<Video>` | `Video` (来自 ottohub API) |
| ZonePage | `RxList<Map<String, dynamic>>` | 动态 Map（类型不安全，建议改用 Video 模型） |

---

## 6. 开发指南

### 6.1 接入 ZoneRank 真实 API

1. 在 `IVideoRepository` 中添加 `getZoneRankVideos(rid, offset, num)` 方法
2. 在 `ZoneController.queryRankFeed()` 中替换 stub 代码，调用仓储接口
3. 实现真正的分页逻辑（当前 `onLoad` 和 `onRefresh` 行为相同）
4. 统一使用 `Video` 模型替换 `Map<String, dynamic>`

### 6.2 添加新的排名维度

在 `tabs` 列表中添加新的 `{'label': '标签', 'timeLimit': N}`。注意 `RankController` 是一次性加载 50 条，如需更多数据需改为分页模式。

### 6.3 修改排名样式

在 `VideoCardH` 的 `rankIndex` 渲染逻辑中修改。该参数在 `view.dart` 的 `SliverChildBuilderDelegate` 中传入。

### 6.4 修复 ZonePage dispose 问题

将监听器的匿名函数提取为命名方法，在 `dispose` 中正确移除：

```dart
void _scrollListener() {
  // ... 原有逻辑
}

// initState 中
scrollController.addListener(_scrollListener);

// dispose 中
scrollController.removeListener(_scrollListener);
```

---

## 7. 二改指南

### 7.1 常见需求

#### RankPage 支持滚动加载更多
参考 `HotController` 的分页模式：添加 `currentPage`、`hasMore`、`onLoad()` 方法，将 `loadVideos()` 改为支持 `isLoadMore` 参数。

#### 添加分区导航（ZoneRankPage）
在 `RankPage` 中添加分区类别入口（如动画/游戏/音乐），点击跳转 `/zoneRank?rid={rid}`。需在路由中配置对应映射。

#### 修改 Tab 切换动画
`TabBar` 的动画由 Material 库控制。如需自定义切换动画，替换为 `TabBarView` + `AnimatedSwitcher`。

#### 自定义骨架屏
当前 `VideoCardHSkeleton` 在 `ListView.builder` 中渲染 10 个。可修改骨架屏样式或数量。

### 7.2 注意事项

- `RankController` 使用 `TabController` 驱动切换，务必在 `onClose` 中正确释放资源
- `RankController.loadVideos()` 一次性加载 50 条，数据量大但简单，适合排行榜场景（排名数据通常需一次性获取）
- `ZonePage` 目前为半成品，`queryRankFeed` 的数据为硬编码空数组，接入真实 API 前无法正常使用
- `ZonePage` 的 `dispose` 中 `scrollController.removeListener(() {})` 传入空闭包而非原监听器，需要修复
- 两个页面均使用 `AutomaticKeepAliveClientMixin` 保持 Tab 切换时的状态