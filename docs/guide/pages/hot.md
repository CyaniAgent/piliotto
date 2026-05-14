---
date: 2026-05-14 22:54:20
title: hot
permalink: /pages/
categories:
  - guide
  - pages
---
# 热门页（Hot）

## 1. 模块概述

`HotPage` 是热门/流行视频的聚合展示页面，支持按时间范围（热门/周榜/月榜）筛选视频，并提供响应式网格布局和瀑布流滚动加载。

| 页面 | 路由 | 数据源 | 用途 |
|------|------|--------|------|
| `HotPage` | `/hot` (Tab 内嵌页面) | `IVideoRepository.getPopularVideos()` | 展示热门视频列表 |

### 文件结构

```
lib/pages/hot/
├── controller.dart      # HotController - 热门视频控制器
├── view.dart            # HotPage - 热门页 UI
└── index.dart           # 模块导出
```

### 依赖关系

```
HotPage (StatefulWidget + AutomaticKeepAliveClientMixin)
  ├── Get.put → HotController
  ├── IVideoRepository → getPopularVideos(timeLimit, offset, num)
  ├── RefreshIndicator → onRefresh (下拉刷新)
  ├── CustomScrollView + ScrollController → onLoad (滚动加载更多)
  ├── ResponsiveUtil → 动态计算网格列数
  ├── VideoCardH → 视频卡片
  └── VideoCardHSkeleton → 加载骨架屏
```

---

## 2. Controller 详解

**源文件：** `controller.dart`

`HotController` 继承自 `GetxController`，管理热门视频的分页加载和 Tab 切换逻辑。

### 2.1 核心属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `scrollController` | `ScrollController` | 滚动控制器，用于监听滚动位置和程序化滚动 |
| `pageSize` | `int` | 每页加载数量，固定 `20` |
| `videoList` | `RxList<Video>` | 视频列表（响应式） |
| `currentPage` | `int` | 当前页码（从 0 开始），每次加载成功后自增 |
| `isLoadingMore` | `bool` | 是否正在加载更多（防重复请求） |
| `noMore` | `String` | 底部状态："加载失败" / "没有更多了" / "" |
| `tabs` | `List<Map>` | Tab 配置：[热门(1) / 周榜(7) / 月榜(30)] |
| `currentTabIndex` | `RxInt` | 当前选中的 Tab 索引 |
| `crossAxisCount` | `RxInt` | 响应式网格列数 |

### 2.2 核心方法

**`onInit()`**
初始化时调用 `updateCrossAxisCount()` 计算网格列数。

**`updateCrossAxisCount()`**
通过 `ResponsiveUtil.calculateCrossAxisCount()` 动态计算列数（1~3 列）。异常时兜底为 1。

**`onTabChanged(int index)`**
Tab 切换逻辑：
- 与当前 Tab 相同则忽略
- 更新 `currentTabIndex`，清空 `videoList`，重置 `currentPage = 0` 和 `noMore`
- 调用 `queryHotFeed(type: 'init')` 重新加载

**`currentTimeLimit`** (getter)
根据 `currentTabIndex` 从 `tabs` 中获取对应的时间范围值（1/7/30 天）。

**`queryHotFeed({String type = 'init'})`**
核心数据加载方法：
- 防重复加载：`isLoadingMore` 为 `true` 直接返回
- `type == 'init'`：重置 `currentPage = 0`，清空 `noMore`
- 检查 `noMore == '没有更多了'`：终止加载
- 调用 `_videoRepo.getPopularVideos(timeLimit, offset, num)`
  - `offset` = `currentPage * pageSize`，`num` = `pageSize`（20）
- `type == 'init'`：记录 `count`，清空并重新填充 `videoList`
- `type == 'onLoad'`：追加到 `videoList`
- 返回数据量 `< pageSize` 时设置 `noMore = '没有更多了'`，否则 `currentPage++`
- 异常时设置 `noMore = '加载失败'`
- 最终 `isLoadingMore = false`

**`onRefresh()`**
下拉刷新：重置 `currentPage` 和 `noMore`，调用 `queryHotFeed(type: 'init')`。

**`onLoad()`**
上拉加载更多：调用 `queryHotFeed(type: 'onLoad')`。

**`animateToTop()`**
程序化滚动到顶部：超过 5 屏高度时直接 `jumpTo(0)`，否则平滑 `animateTo`。

---

## 3. View 详解

**源文件：** `view.dart`

`HotPage` 是一个 `StatefulWidget`，混合 `AutomaticKeepAliveClientMixin` 保持页面状态（Tab 切换时不重建）。

### 3.1 生命周期

| 阶段 | 操作 |
|------|------|
| `initState` | 调用 `queryHotFeed(type: 'init')`，注册滚动监听 |
| `didChangeDependencies` | 更新列数 `updateCrossAxisCount()` |
| `didUpdateWidget` | 通过 `EasyThrottle` 防抖更新列数 |
| `dispose` | 移除滚动监听 |

### 3.2 页面结构

```
RefreshIndicator
└── CustomScrollView
    ├── SliverToBoxAdapter
    │   └── _buildTabBar: FilterChip 组（热门 / 周榜 / 月榜）
    ├── SliverPadding
    │   └── FutureBuilder
    │       ├── [loading] → SliverGrid + VideoCardHSkeleton (10个骨架屏)
    │       ├── [done + 空列表] → HttpError (暂无数据 / 加载失败)
    │       └── [done + 有数据] → Obx
    │           └── SliverGrid (SliverGridDelegateWithFixedCrossAxisCount)
    │               ├── crossAxisCount: 响应式 1~3 列
    │               ├── childAspectRatio: 3/1
    │               └── delegate: VideoCardH (showPubdate: true)
    └── SliverToBoxAdapter (底部安全区间距)
```

### 3.3 Tab 栏

`_buildTabBar()` 使用 `FilterChip` 渲染三个筛选按钮，通过 `Obx` 响应 `currentTabIndex` 变化。`onSelected` 触发 `onTabChanged(index)`。

### 3.4 滚动加载

`_scrollListener()` 监听滚动位置，距底部 200px 时且无正在加载、无"没有更多了"状态时调用 `onLoad()`。同时调用 `handleScrollEvent()` 处理全局滚动事件（如隐藏/显示底部导航栏）。

### 3.5 宽屏适配

- 通过 `ResponsiveUtil.isMd` 判断是否为中等及以上屏幕
- 宽屏时网格区域两侧添加水平 padding 使内容居中，最大宽度 800px

---

## 4. 数据流

```
┌────────────────────────────┐
│  HotPage.initState         │
│  queryHotFeed(type:'init') │
└────────────┬───────────────┘
             │
  ┌──────────▼───────────────┐
  │ IVideoRepository         │
  │ getPopularVideos(        │
  │   timeLimit: 1/7/30,     │
  │   offset: page*20,       │
  │   num: 20                │
  │ )                        │
  └──────────┬───────────────┘
             │
  ┌──────────▼──────────┐
  │ HotController       │
  │ videoList (RxList)  │
  │ currentPage (int)   │
  │ noMore (String)     │
  └──────────┬──────────┘
             │
  ┌──────────▼──────────┐
  │ HotPage (Obx)       │
  │ SliverGrid          │
  │ VideoCardH × N      │
  └─────────────────────┘
```

### 分页机制

与 `FollowController` 的 offset 增量方式不同，`HotController` 使用**页码制**：
- `offset = currentPage * pageSize`，每页固定 20 条
- 加载成功且数据量 >= `pageSize` 时 `currentPage++`
- 不足 20 条判定为到底

### 状态流转

| 状态 | 条件 | UI 表现 |
|------|------|---------|
| 加载中 | `ConnectionState != done` | `VideoCardHSkeleton` 骨架屏 × 10 |
| 空数据 | `videoList.isEmpty && noMore != '加载失败'` | "暂无数据" + 重试按钮 |
| 加载失败 | `noMore == '加载失败'` | "加载失败，请重试" + 重试按钮 |
| 正常 | `videoList.isNotEmpty` | `VideoCardH` 网格 |
| 加载更多中 | `isLoadingMore == true` | 底部无额外指示器 |
| 没有更多 | `noMore == '没有更多了'` | 优势：滚动监听直接忽略，不触发无效请求 |

---

## 5. 开发指南

### 5.1 添加新的时间范围 Tab

在 `tabs` 列表中添加新的 `{'label': '标签名', 'timeLimit': N}` 条目。`timeLimit` 值会直接传给 `getPopularVideos` 的 `timeLimit` 参数。

### 5.2 修改默认 Tab

在 `currentTabIndex` 的初始值中修改，从 `0`（热门）改为对应索引。

### 5.3 调整网格布局

- **列数**：修改 `ResponsiveUtil.calculateCrossAxisCount()` 的入参 `minCount` / `maxCount`
- **宽高比**：修改 `childAspectRatio: 3 / 1`
- **最大内容宽度**：修改 `maxContentWidth` 变量值（当前 800px）
- **间距**：修改 `mainAxisSpacing` 和 `crossAxisSpacing`

### 5.4 修改每页加载数量

修改 `pageSize` 常量（当前 20）。同时建议调整滚动触发阈值中的 `-200` 以适配不同的数据量。

---

## 6. 二改指南

### 6.1 常见需求

#### 替换 FilterChip 为其他 Tab 样式
修改 `_buildTabBar()` 方法，可替换为 `TabBar` + `TabBarView`（参考 RankPage 实现）。

#### 添加视频排序选项
在 Controller 中添加排序参数，传递给 `getPopularVideos()` 或在本地对 `videoList` 排序。需确认 API 是否支持排序。

#### 添加"回到顶部"浮动按钮
可参考 `RankPage` 的 `animateToTop()` 方法，在 `HotPage` 中添加一个 `FloatingActionButton`，点击调用 `_hotController.animateToTop()`。

#### 修改加载失败重试逻辑
`_buildTabBar` 中的 `fn` 回调通过 `setState` 重置 `FutureBuilder` 的 future。可扩展为重试前清空数据。

#### 宽屏模式下改为双列或更多列
调整 `ResponsiveUtil.calculateCrossAxisCount()` 的 `maxCount` 参数（当前 3）。注意 `childAspectRatio` 可能需要随之调整。

### 6.2 注意事项

- `HotPage` 使用 `AutomaticKeepAliveClientMixin`，Tab 切换时保持数据和滚动位置
- 分页使用页码制，`currentPage` 在 `init` 时重置为 0，切勿在页面刷新时忘记重置
- `isLoadingMore` 是普通 `bool`（非 Rx），仅用于防止重复请求，不需要 UI 绑定
- `noMore` 是普通 `String`，视图中直接读取，但通过 `Obx` 包裹确保空数据状态刷新
- `handleScrollEvent()` 来自 `lib/utils/main_stream.dart`，用于全局导航栏显隐逻辑，与热门页业务无关但必须调用