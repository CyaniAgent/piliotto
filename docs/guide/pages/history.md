---
date: 2026-05-14 23:00:21
title: history
permalink: /pages/e4f51c
categories:
  - guide
  - pages
---
# 历史记录模块（History）

## 1. 模块概述

历史记录模块负责展示用户的视频观看历史。页面以响应式网格布局呈现视频卡片，通过 `FutureBuilder` 管理异步初始加载状态，提供三种明确的 UI 状态处理：加载中骨架屏、错误/未登录提示、正常数据展示。

模块文件结构：

```
lib/pages/history/
├── controller.dart            # HistoryController - 历史列表加载、状态管理
├── view.dart                  # HistoryPage - 网格视图（含 FutureBuilder 状态处理）
├── index.dart                 # 统一导出
└── widgets/
    └── item.dart              # HistoryItem - 历史视频卡片组件
```

### 核心功能

| 功能 | 说明 |
|------|------|
| 历史列表 | 调用 `IVideoRepository.getHistoryVideos()` 一次性加载全部历史记录 |
| 响应式网格 | 通过 `ResponsiveUtil.calculateCrossAxisCount` 动态计算网格列数 |
| 骨架屏 | 加载中显示 10 个 `VideoCardHSkeleton` 骨架占位 |
| 未登录处理 | `userInfo == null` 时返回 `code: -101`，UI 显示"去登录"按钮 |
| 错误处理 | 请求失败时通过 `HttpError` 组件展示错误信息和重试按钮 |
| 功能限制 | 当前 OttoHub API 不支持暂停/清空/删除单条历史记录 |

### API 功能限制

由于 OttoHub API 的限制，以下操作当前不可用（调用时会弹出 Toast 提示）：

- **暂停历史记录** (`onPauseHistory`)：提示 "Ottohub API 不支持暂停历史记录"
- **清空历史记录** (`onClearHistory`)：提示 "Ottohub API 不支持清空历史记录"
- **删除单条记录** (`delHistory`)：提示 "Ottohub API 不支持删除历史记录"
- **删除选中记录** (`onDelCheckedHistory`)：提示 "Ottohub API 不支持删除历史记录"

---

## 2. Controller 详解

`HistoryController` 继承 `GetxController`，管理历史记录列表的加载和状态。

### 2.1 响应式状态

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `historyList` | `RxList<Video>` | `[]` | 历史视频列表 |
| `isLoadingMore` | `RxBool` | `false` | 加载更多状态 |
| `pauseStatus` | `RxBool` | `false` | 历史记录是否已暂停（固定 false） |
| `isLoading` | `RxBool` | `false` | 加载状态 |
| `enableMultiple` | `RxBool` | `false` | 是否开启批量选择模式 |
| `checkedCount` | `RxInt` | `0` | 已选中数量（配合多选使用） |
| `crossAxisCount` | `RxInt` | `1` | 网格列数（响应式） |

### 2.2 本地缓存

```dart
Box localCache = GStrorage.localCache;
Box userInfoCache = GStrorage.userInfo;
UserInfoData? userInfo;
```

- `localCache`：本地缓存 Box（预留）
- `userInfoCache`：从 Hive 读取用户信息
- `userInfo`：当前登录用户，`null` 表示未登录

### 2.3 生命周期

`controller.dart:L26-L31`

```dart
@override
void onInit() {
  super.onInit();
  userInfo = userInfoCache.get('userInfoCache');
  updateCrossAxisCount();
  queryHistoryList();
}
```

在 `onInit` 中同步读取 Hive 缓存获取用户信息，计算网格列数，并立即发起历史记录请求。

### 2.4 响应式列数计算

`controller.dart:L33-L44`

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

与 FavController 策略一致，窄屏 1 列，中等屏幕 2 列，宽屏 3 列。

### 2.5 核心方法

#### `queryHistoryList({String type})` — 加载历史记录

`controller.dart:L46-L62`

```dart
Future<Map<String, dynamic>> queryHistoryList({String type = 'init'}) async {
  if (userInfo == null) {
    return {'status': false, 'msg': '账号未登录', 'code': -101};
  }
  isLoadingMore.value = true;
  try {
    final response = await _videoRepo.getHistoryVideos();
    historyList.value = response.videoList;
  } catch (e) {
    SmartDialog.showToast('请求失败: $e');
  }
  isLoadingMore.value = false;
  return {'status': true};
}
```

关键设计点：

- **返回 `Map<String, dynamic>`**：供 View 层的 `FutureBuilder` 消费，通过 `data['status']` 判断成功/失败
- **未登录检查**：`userInfo == null` 时返回 `code: -101`，View 层据此展示"去登录"按钮
- **一次性加载**：调用 `getHistoryVideos()` 无分页参数，一次性拉取全部历史
- `type` 参数当前未实际使用（预留扩展点，区分 'init' 和 'onRefresh'）

#### `onLoad()` — 加载更多

`controller.dart:L64-L66`

```dart
Future onLoad() async {
  SmartDialog.showToast('没有更多了');
}
```

由于 `getHistoryVideos()` 一次性返回全部数据，不支持分页，所以 `onLoad` 直接提示"没有更多了"。

#### `onRefresh()` — 下拉刷新

`controller.dart:L68-L70`

重新调用 `queryHistoryList(type: 'onRefresh')`，在 View 层配合 `setState` 重新构建 `FutureBuilder`。

#### 功能限制方法

以下方法因 OttoHub API 不支持，内部仅为 Toast 提示：

- `onPauseHistory()`：暂停历史记录
- `historyStatus()`：查询历史记录状态（固定 `pauseStatus.value = false`）
- `onClearHistory()`：清空全部历史
- `delHistory(int kid, String business)`：删除单条
- `onDelHistory()`：删除历史
- `onDelCheckedHistory()`：批量删除选中

---

## 3. View 详解

`HistoryPage` 是 `StatefulWidget`，使用 `CustomScrollView` + `FutureBuilder` + `SliverGrid` 构建视图。

### 3.1 FutureBuilder 三态处理

`view.dart:L95-L165`

```dart
FutureBuilder(
  future: _futureBuilderFuture,
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      // 状态1: 加载完成
      if (snapshot.data == null) {
        return const SliverToBoxAdapter(child: SizedBox());
      }
      Map? data = snapshot.data;
      if (data != null && data['status']) {
        // 状态1a: 加载成功
        return historyList.isNotEmpty ? SliverGrid(...) : NoData();
      } else {
        // 状态1b: 加载失败（含未登录）
        return HttpError(
          errMsg: data?['msg'] ?? '请求异常',
          btnText: data?['code'] == -101 ? '去登录' : null,
          fn: () { /* 去登录或重试 */ },
        );
      }
    } else {
      // 状态2: 加载中 - 骨架屏
      return SliverGrid(/* 10 个 VideoCardHSkeleton */);
    }
  },
)
```

| 状态 | 条件 | 渲染 |
|------|------|------|
| 加载中 | `ConnectionState != done` | 10 个 `VideoCardHSkeleton` 骨架屏 |
| 成功有数据 | `data['status'] == true && historyList.isNotEmpty` | `SliverGrid` 渲染 `HistoryItem` |
| 成功无数据 | `data['status'] == true && historyList.isEmpty` | `NoData` 组件 |
| 未登录 | `data['code'] == -101` | `HttpError`，按钮"去登录" |
| 请求失败 | `data['status'] != true` | `HttpError`，重试按钮 |

### 3.2 网格布局参数

`view.dart:L107-L114`

```dart
SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: _historyController.crossAxisCount.value,
  mainAxisSpacing: 16,
  crossAxisSpacing: 16,
  childAspectRatio: 3 / 1,
)
```

与 FavPage 使用相同的网格参数：3:1 宽高比，16px 间距。

### 3.3 下拉刷新

`view.dart:L86-L89`

```dart
RefreshIndicator(
  onRefresh: () async {
    await _historyController.onRefresh();
    return;
  },
  child: CustomScrollView(...)
)
```

通过 `RefreshIndicator` 包裹 `CustomScrollView`，刷新时调用 `onRefresh()`。

### 3.4 滚动加载更多

`view.dart:L29-L40`

通过 `scrollController.addListener` 监听滚动位置，距底部 300px 时触发 `onLoad()`（当前仅提示"没有更多了"）。

### 3.5 AppBar 操作菜单

`view.dart:L66-L83`

右上角 `PopupMenuButton` 包含"清空观看记录"选项，点击触发 `onClearHistory()`（提示 API 不支持）。

### 3.6 HistoryItem 组件

`HistoryItem` 是历史视频卡片组件。

#### 布局结构

```
┌────────────────────────────────────────────┐
│ ┌──────────┐                               │
│ │   封面    │  [时长 00:45]                   │
│ │  + Hero  │                               │
│ └──────────┘  视频标题（最多2行）              │
│               UP主名称                       │
│               观看时间         ⋮ 功能菜单     │
└────────────────────────────────────────────┘
```

#### 封面区域

- `Hero` 动画标签（`heroTag`）
- `NetworkImgLayer` 封面图片
- 时长 overlay：右下角半透明黑色容器，通过 `Utils.timeFormat` 格式化

#### 点击行为

`item.dart:L22-L27`

```dart
Get.toNamed('/video?vid=${videoItem.vid}', arguments: {
  'heroTag': heroTag,
  'pic': videoItem.coverUrl,
});
```

跳转到视频详情页 `/video`，通过 URL query 传递 `vid`，arguments 传递 `heroTag` 和 `pic`。

#### 功能菜单

`item.dart:L144-L174`

右下角 `PopupMenuButton`（三点图标），包含"删除记录"选项，点击提示"Ottohub API 不支持删除历史记录"。

#### _VideoContent 展示信息

| 信息 | 数据来源 | 格式 |
|------|----------|------|
| 视频标题 | `videoItem.title` | 最多 2 行省略 |
| UP主名称 | `videoItem.username` | 非空时显示 |
| 观看时间 | `videoItem.time` | 原始时间字符串 |

---

## 4. 数据流

```
HistoryPage 初始化
  │
  ▼
_futureBuilderFuture = _historyController.queryHistoryList()
  │
  ▼
HistoryController.queryHistoryList()
  │
  ├── userInfo == null?
  │     └── 返回 {'status': false, 'code': -101}
  │
  └── userInfo != null?
        │
        ▼
  IVideoRepository.getHistoryVideos()
        │
        ├── 成功 ──► historyList.value = response.videoList
        │              └── 返回 {'status': true}
        │
        └── 失败 ──► SmartDialog.showToast('请求失败')
                       └── 返回 {'status': true}（但列表为空）

FutureBuilder 根据返回的 Map 决定渲染：

  {'status': true, historyList 有数据} ──► SliverGrid + HistoryItem
  {'status': true, historyList 为空}   ──► NoData
  {'code': -101}                       ──► HttpError + "去登录"
  其他错误                              ──► HttpError + 重试

用户操作：

  点击卡片 ──► Get.toNamed('/video?vid=...')
  下拉刷新 ──► setState → _futureBuilderFuture = queryHistoryList()
  清空记录 ──► Toast: "API 不支持"
  删除记录 ──► Toast: "API 不支持"
```

---

## 5. 使用示例

### 5.1 历史记录页面跳转

```dart
import 'package:get/get.dart';

void navigateToHistory() {
  Get.toNamed('/history');
}

void navigateToHistoryWithType(String type) {
  Get.toNamed('/history?type=$type');
}
```

### 5.2 HistoryController 使用

```dart
import 'package:get/get.dart';
import 'package:piliotto/pages/history/controller.dart';

class HistoryListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HistoryController>();
    
    return FutureBuilder(
      future: controller.queryHistoryList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        
        if (snapshot.hasError) {
          return Text('加载失败: ${snapshot.error}');
        }
        
        final data = snapshot.data as Map<String, dynamic>;
        final list = data['list'] as List;
        
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(list[index]['title']),
              subtitle: Text(list[index]['author']),
            );
          },
        );
      },
    );
  }
}
```

### 5.3 历史记录操作

```dart
void refreshHistory(HistoryController controller) {
  controller.onRefresh();
}

void loadMoreHistory(HistoryController controller) {
  controller.onLoad();
}

void deleteHistoryItem(HistoryController controller, int kid) {
  controller.deleteHistoryItem(kid);
}
```

### 5.4 历史记录过滤

```dart
void filterByType(HistoryController controller, String type) {
  controller.currentType.value = type;
  controller.queryHistoryList();
}

void searchHistory(HistoryController controller, String keyword) {
  controller.keyword.value = keyword;
  controller.queryHistoryList();
}
```

---

## 6. 开发指南

### 6.1 理解 FutureBuilder 模式

HistoryPage 是项目中少数使用 `FutureBuilder` 的页面。这种模式的优势在于：

1. **自动管理异步状态**：`ConnectionState` 自动区分 loading / done
2. **与 setState 配合刷新**：通过 `setState(() { _futureBuilderFuture = ... })` 重新触发
3. **返回值驱动 UI**：Controller 返回 `Map<String, dynamic>` 携带 status / code / msg，View 层据此渲染不同 UI

如果需要添加新的加载状态（如分页），建议将 `FutureBuilder` 改为与 FavPage 一致的 `Obx` + 响应式状态模式。

### 6.2 添加分页支持

当前 `queryHistoryList` 一次性加载全部数据。要添加分页：

1. 在 Controller 中添加 `_offset`、`_pageSize`、`_hasMore`、`isLoadingMore` 等状态
2. 修改 `queryHistoryList` 支持 `offset` 参数
3. 实现真正的 `onLoad()` 方法
4. 将 View 层的 `FutureBuilder` 改为 `Obx` 监听 `historyList`
5. 添加底部"加载更多"提示

### 6.3 添加历史记录类型的过滤

当前展示全部历史。要按类型过滤（如仅视频、仅文章）：

1. 在 `queryHistoryList` 中添加 `business` 参数
2. 调用 `IVideoRepository` 的对应过滤方法
3. 在 AppBar 或 body 顶部添加 TabBar / DropdownButton 切换

---

## 7. 二改指南

### 7.1 自定义空状态样式

空状态使用 `NoData` 通用组件。要自定义，替换为：

```dart
SliverToBoxAdapter(
  child: Center(
    child: Column(
      children: [
        Icon(Icons.history, size: 64, color: Colors.grey),
        const SizedBox(height: 16),
        Text('暂无观看记录', style: TextStyle(color: Colors.grey)),
      ],
    ),
  ),
)
```

### 7.2 修改骨架屏数量

骨架屏数量硬编码为 10 个（`view.dart:L160`）。可改为动态计算：

```dart
final screenHeight = MediaQuery.of(context).size.height;
final cardHeight = (MediaQuery.of(context).size.width / crossAxisCount) / 3;
final skeletonCount = (screenHeight / cardHeight).ceil().clamp(5, 15);
```

### 7.3 自定义错误页面行为

错误页面使用 `HttpError` 组件（`view.dart:L133-L148`）。`code == -101` 时点击跳转登录页（`RoutePush.loginRedirectPush()`），其他情况重新请求。可修改 `fn` 回调实现自定义行为。

### 7.4 自定义视频卡片

HistoryItem 的样式定义在 `widgets/item.dart`。如需显示更多信息（如播放量、弹幕数），在 `_VideoContent` 中添加对应的 Row/Widget，参考 FavVideoCardH 的实现。

### 7.5 启用多选删除功能

Controller 已预留 `enableMultiple` 和 `checkedCount` 状态。实现步骤：

1. 在 AppBar 添加"编辑"按钮，切换 `enableMultiple`
2. 在 HistoryItem 中根据 `enableMultiple` 显示 Checkbox
3. 实现真正的 `onDelCheckedHistory` 方法（需要 API 支持）