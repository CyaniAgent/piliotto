---
date: 2026-05-14 22:58:58
title: fav
permalink: /pages/bd5374
categories:
  - guide
  - pages
---
# 收藏模块（Fav）

## 1. 模块概述

收藏模块是 PiliOtto 的收藏夹功能，采用 **两级页面结构** 组织收藏内容：

- **FavPage**：收藏文件夹列表页，以网格形式展示用户的所有收藏文件夹
- **FavDetailPage**：收藏夹详情页，展示某个文件夹内的视频列表，支持滑动删除取消收藏

两个页面共享相同的分页加载和响应式网格列数策略。

模块文件结构：

```
lib/pages/fav/
├── controller.dart            # FavController - 收藏文件夹分页加载、取消收藏
├── view.dart                  # FavPage - 收藏文件夹网格视图
├── index.dart                 # 统一导出
└── widgets/
    └── item.dart              # FavItem - 收藏文件夹卡片组件

lib/pages/fav_detail/
├── controller.dart            # FavDetailController - 文件夹内视频分页加载
├── view.dart                  # FavDetailPage - 视频列表视图（含滑动删除）
├── index.dart                 # 统一导出
└── widget/
    └── fav_video_card.dart    # FavVideoCardH - 视频卡片（含时长、UP主、播放量、取消收藏按钮）
```

### 核心功能

| 功能 | 说明 |
|------|------|
| 收藏文件夹展示 | 网格布局展示文件夹封面、标题、内容数量、公开/私密状态 |
| 分页加载 | `offset/num` 模式分页，每页 20 条 |
| 下拉刷新 | `RefreshIndicator` 包裹，支持下拉刷新 |
| 滚动加载更多 | 距底部 300px（fav）或 200px（fav_detail）触发加载 |
| 响应式列数 | 通过 `ResponsiveUtil.calculateCrossAxisCount` 动态计算网格列数 |
| 滑动删除 | FavDetailPage 支持 `Dismissible` 左滑取消收藏 |
| 骨架屏 | 加载中展示 `VideoCardHSkeleton` 占位 |

---

## 2. FavController 详解

`FavController` 继承 `GetxController`，管理收藏文件夹列表。

### 2.1 响应式状态

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `favoriteList` | `RxList<Video>` | `[]` | 收藏文件夹列表 |
| `isLoading` | `RxBool` | `false` | 首次加载状态 |
| `isLoadingMore` | `RxBool` | `false` | 加载更多状态 |
| `hasMore` | `RxBool` | `true` | 是否有更多数据 |
| `crossAxisCount` | `RxInt` | `1` | 网格列数（响应式） |

### 2.2 内部状态

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `_currentPage` | `int` | `0` | 当前页码（offset 模式） |
| `_pageSize` | `int` | `20` | 每页条数 |

### 2.3 响应式列数计算

`controller.dart:L29-L40`

```dart
void updateCrossAxisCount() {
  int baseCount = ResponsiveUtil.calculateCrossAxisCount(
    baseCount: 1,
    minCount: 1,
    maxCount: 3,
  );
  crossAxisCount.value = baseCount;
}
```

通过 `ResponsiveUtil` 根据屏幕宽度动态计算：窄屏 1 列，中等屏幕 2 列，宽屏 3 列。在 `onInit` 和 `didChangeDependencies` 中调用。

### 2.4 核心方法

#### `queryFavorites({bool isLoadMore})` — 加载收藏列表

`controller.dart:L42-L75`

- 防重入保护：`isLoading` 或 `isLoadingMore` 为 `true` 时直接返回
- 非加载更多时：重置 `_currentPage=0`，设置 `isLoading=true`
- 加载更多时：检查 `hasMore`，设置 `isLoadingMore=true`
- 调用 `IVideoRepository.getFavoriteVideos(offset:, num:)`
- 加载更多时 `addAll`，刷新时直接赋值 `value = videos`
- 数据量少于 `_pageSize` 时 `hasMore=false`

#### `onLoad()` / `onRefresh()` — 加载更多 / 刷新

```dart
Future<void> onLoad() async => await queryFavorites(isLoadMore: true);
Future<void> onRefresh() async => await queryFavorites();
```

#### `removeFavorite(int vid)` — 取消收藏

`controller.dart:L85-L92`

调用 `IVideoRepository.toggleFavorite(vid:)`，成功后从 `favoriteList` 中移除对应项。

#### `animateToTop()` — 滚动到顶部

`controller.dart:L94-L103`

如果滚动超过 5 个屏幕高度则直接 `jumpTo(0)`，否则平滑动画滚动到顶部。

---

## 3. FavView 详解

`FavPage` 是 `StatefulWidget`，使用 `CustomScrollView` + `SliverGrid` 实现收藏文件夹网格。

### 3.1 滚动加载更多

`view.dart:L23-L31`

通过 `scrollController.addListener` 监听滚动位置，距底部 300px 时通过 `EasyThrottle.throttle('fav', 1s, ...)` 节流触发 `onLoad()`。

### 3.2 三种视图状态

`view.dart:L62-L153`

| 状态 | 渲染内容 |
|------|----------|
| 加载中 + 列表为空 | `SliverGrid` 填充 10 个 `VideoCardHSkeleton` 骨架屏 |
| 加载完成 + 列表为空 | `SliverFillRemaining` 居中显示空心爱心图标 + "暂无收藏" |
| 有数据 | `SliverGrid` 渲染 `VideoCardH` 卡片 + 底部加载状态提示 |

### 3.3 网格布局参数

```dart
SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: _favController.crossAxisCount.value,
  mainAxisSpacing: 16,
  crossAxisSpacing: 16,
  childAspectRatio: 3 / 1,
)
```

- 宽高比 3:1，适合横版卡片展示
- 间距 16px

### 3.4 FavItem 组件

`FavItem` 是收藏文件夹的卡片组件。

布局结构：

```
┌─────────────────────────────────────────┐
│ ┌──────────┐                            │
│ │          │  文件夹标题                  │
│ │   封面    │  N个内容                    │
│ │          │                            │
│ │          │  公开 / 私密                │
│ └──────────┘                            │
└─────────────────────────────────────────┘
```

点击通过 `Get.toNamed('/favDetail')` 跳转到收藏夹详情页，传递参数包括 `heroTag`、`mediaId`、`isOwner`。

`VideoContent` 是 FavItem 的子组件，展示文件夹的文本信息：
- `title`：文件夹标题，加粗
- `mediaCount`：内容数量
- `attr`：通过判断 `[23, 1].contains(favFolderItem.attr)` 显示"私密"或"公开"

---

## 4. FavDetail 详解

### 4.1 FavDetailController

`FavDetailController` 继承 `GetxController`，与 FavController 结构类似，区别在于：

| 对比项 | FavController | FavDetailController |
|--------|--------------|---------------------|
| 列表属性 | `favoriteList` | `favList` |
| 标题 | 无 | `title`（从路由参数读取） |
| 底部文本 | 无 | `loadingText`（默认"加载中..."，结束时"没有更多了"） |
| 取消收藏 | `removeFavorite(vid)` | `removeFavorite(vid)`（同名） |

`title` 在 `onInit` 中从 `Get.parameters['title']` 获取，默认值为 `'我的收藏'`。

### 4.2 FavDetailPage

`FavDetailPage` 是 `StatefulWidget`，使用 `ListView.builder` 渲染视频列表。

#### 与 FavPage 的差异

| 对比项 | FavPage | FavDetailPage |
|--------|---------|---------------|
| 滚动容器 | `CustomScrollView` + `SliverGrid` | `ListView.builder` |
| 加载更多触发距离 | 300px | 200px |
| 滑动删除 | 不支持 | `Dismissible` 左滑删除 |
| 骨架屏 | `SliverGrid` 10 个骨架 | `ListView` 10 个骨架 |
| 底部提示 | `SliverToBoxAdapter` | `itemCount + 1` 尾部元素 |

#### 滑动删除

`view.dart:L110-L121`

```dart
Dismissible(
  key: Key('fav_detail_${video.vid}'),
  direction: DismissDirection.endToStart,
  background: Container(
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.only(right: 20),
    color: Colors.red,
    child: const Icon(Icons.delete, color: Colors.white),
  ),
  onDismissed: (direction) {
    _favDetailController.removeFavorite(video.vid);
  },
)
```

仅支持从右向左滑动（`endToStart`），红色背景 + 白色删除图标，滑动完成后直接调用 `removeFavorite`。

### 4.3 FavVideoCardH 组件

`FavVideoCardH` 是收藏夹详情页的视频卡片，相比 FavItem 包含更丰富的视频信息。

#### 封面区域

- `Hero` 动画封套（`heroTag`）
- `NetworkImgLayer` 网络图片
- 时长 badge：右下角灰色圆角标签，通过 `Utils.timeFormat` 格式化
- OGV 类型标签：如有 `ogv` 字段，右上角显示类型名称

#### 点击与长按

- **点击**：`Get.toNamed('/video')` 跳转到视频详情页
- **长按**：`imageSaveDialog` 弹出图片保存对话框

#### VideoContent（子组件）

`VideoContent` 展示视频元数据：

| 信息项 | 数据来源 | 说明 |
|--------|----------|------|
| 标题 | `videoItem.title` | 最多 2 行，省略号溢出 |
| 简介 | `videoItem.intro` | 仅 OGV 内容显示 |
| 收藏时间 | `videoItem.favTime` | 通过 `Utils.dateFormat` 格式化 |
| UP主 | `videoItem.owner.name` | 非空时显示 |
| 播放量 | `videoItem.cntInfo['play']` | `StatView` 组件 |
| 弹幕数 | `videoItem.cntInfo['danmaku']` | `StatDanMu` 组件 |
| 取消收藏 | 右上角 X 按钮 | 仅 `isOwner == '1'` 且 `searchType != 1` 时显示 |

取消收藏按钮点击后弹出确认对话框，确认后调用 `callFn`（由 FavDetailPage 传入的 `removeFavorite`）。

---

## 5. 数据流

```
应用进入 /fav 路由
  │
  ▼
FavController.onInit()
  │
  ├── updateCrossAxisCount() ──► ResponsiveUtil ──► crossAxisCount
  └── queryFavorites()
        │
        ▼
  IVideoRepository.getFavoriteVideos(offset:, num:)
        │
        ▼
  favoriteList (RxList<Video>)
        │
        ▼
  FavPage 渲染 FavItem 网格
        │
        ▼
  用户点击文件夹 ──► Get.toNamed('/favDetail')
        │
        ▼
FavDetailController.onInit()
  │
  └── queryFavorites()
        │
        ▼
  IVideoRepository.getFavoriteVideos(offset:, num:)
        │
        ▼
  favList (RxList<Video>)
        │
        ▼
  FavDetailPage 渲染 FavVideoCardH 列表

用户滑动删除 / 点击取消收藏按钮
  │
  ▼
FavDetailController.removeFavorite(vid)
  │
  ▼
IVideoRepository.toggleFavorite(vid:)
  │
  ▼
favList.removeWhere((v) => v.vid == vid)
```

---

## 6. 开发指南

### 6.1 理解分页加载的双状态设计

FavController 使用 `isLoading` 和 `isLoadingMore` 两个独立的加载状态：

- `isLoading`：首次加载或刷新时使用，控制全屏 loading 和骨架屏的显示
- `isLoadingMore`：滚动加载更多时使用，防止 `onLoad` 被重复触发

这种双状态设计避免了首次加载时"加载更多"被触发的问题。

### 6.2 节流控制

两个页面都使用 `EasyThrottle.throttle` 防止滚动事件过于频繁触发加载：

```dart
// FavPage - 1秒节流
EasyThrottle.throttle('fav', const Duration(seconds: 1), () {
  _favController.onLoad();
});

// FavDetailPage - 1秒节流
EasyThrottle.throttle('favDetail', const Duration(seconds: 1), () {
  _favDetailController.onLoad();
});
```

节流 key 分别为 `'fav'` 和 `'favDetail'`，互不影响。

### 6.3 适配新的收藏夹 API

当前 `IVideoRepository.getFavoriteVideos` 同时用于 FavController 和 FavDetailController。如果 API 区分文件夹列表和文件夹内视频列表，需要在 Repository 层添加新接口，并分别注入到两个 Controller。

---

## 7. 二改指南

### 7.1 自定义网格列数规则

网格列数由 `ResponsiveUtil.calculateCrossAxisCount` 决定。如需自定义断点，修改此调用参数或直接替换为自定义逻辑：

```dart
void updateCrossAxisCount() {
  final width = MediaQuery.of(Get.context!).size.width;
  if (width > 1200) {
    crossAxisCount.value = 4;
  } else if (width > 800) {
    crossAxisCount.value = 2;
  } else {
    crossAxisCount.value = 1;
  }
}
```

### 7.2 调整卡片的宽高比

卡片宽高比定义在两个位置：

- FavPage 网格：`view.dart:L75` `childAspectRatio: 3 / 1`
- FavItem 内容区：`item.dart:L36-L37` `width / StyleString.aspectRatio`

修改 `childAspectRatio` 和 `StyleString.aspectRatio` 即可调整。

### 7.3 自定义滑动删除样式

FavDetailPage 的滑动删除背景在 `view.dart:L113-L118`，可修改 `color`、图标或添加确认回调。

### 7.4 添加批量取消收藏

1. 在 `FavDetailController` 中添加 `RxList<int> checkedVids` 和 `removeCheckedFavorites()` 方法
2. 在 `FavVideoCardH` 中添加多选模式，渲染 Checkbox
3. 在 `FavDetailPage` AppBar 中添加批量操作按钮

### 7.5 替换视频卡片组件

FavDetailPage 使用 `FavVideoCardH` 渲染视频，如要使用通用的 `VideoCardH` 替代，修改 `view.dart:L122`：

```dart
// 替换前
child: VideoCardH(videoItem: video),
// 替换后
child: FavVideoCardH(videoItem: video, isOwner: isOwner),
```

注意 `FavVideoCardH` 比 `VideoCardH` 多出收藏时间、取消收藏按钮等功能。