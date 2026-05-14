---
date: 2026-05-14 22:45:42
title: search
permalink: /pages/3f35e2
categories:
  - guide
  - pages
---
# 搜索页（Search）

## 1. 模块概述

搜索模块位于 `lib/pages/search/`，提供视频搜索功能。用户可在搜索页中输入关键词查找视频，支持搜索历史记录、搜索结果分页加载、下拉刷新和加载更多。搜索结果以自适应网格布局展示，并支持 OV 编号快速跳转到视频详情页。

### 模块文件结构

```
lib/pages/search/
├── controller.dart       # VideoSearchController - 搜索状态管理与分页逻辑
├── view.dart             # SearchPage - 搜索界面（搜索框 + 结果列表）
└── index.dart            # 模块统一导出
```

### 依赖关系

```
SearchPage (view.dart)
  ├── 依赖 Get.put → VideoSearchController (controller.dart)
  ├── 依赖 SearchHistoryService → 搜索历史管理
  ├── 依赖 IVideoRepository.searchVideos() → 接口级数据获取
  └── 依赖 VideoCardH / VideoCardHSkeleton → 搜索结果展示
```

### 路由入口

- 路由名称：`/search`
- 支持 URL 参数：`hintText`（搜索提示文字）、`keyword`（初始搜索关键词）
- 跳转示例：
  ```dart
  Get.toNamed('/search', parameters: {'keyword': 'Flutter'});
  Get.toNamed('/search', parameters: {'hintText': '搜索你想看的视频'});
  ```

---

## 2. Controller 详解

**源文件：** `controller.dart`

`VideoSearchController` 继承自 `GetxController`，通过 `Get.put()` 在页面 initState 时注册到 GetX 依赖注入容器。

### 2.1 依赖

| 依赖 | 来源 | 说明 |
|------|------|------|
| `IVideoRepository` | `Get.find<IVideoRepository>()` | 视频仓储接口，调用 `searchVideos` 获取搜索结果 |
| `ScrollController` | 内置实例 | 控制搜索结果列表的滚动 |
| `TextEditingController` | 内置实例 | 控制搜索输入框文本（未在 view 中直接使用） |
| `FocusNode` | 内置实例 | 控制搜索输入框焦点（未在 view 中直接使用） |

### 2.2 Rx 响应式状态

| 状态变量 | 类型 | 初始值 | 说明 |
|----------|------|--------|------|
| `videoList` | `RxList<Video>` | `[]` | 搜索结果视频列表 |
| `isLoading` | `RxBool` | `false` | 首次搜索加载中 |
| `isLoadingMore` | `RxBool` | `false` | 加载更多中 |
| `hasMore` | `RxBool` | `true` | 是否还有更多数据 |
| `currentKeyword` | `RxString` | `''` | 当前搜索关键词 |
| `crossAxisCount` | `RxInt` | `1` | 网格列数（自适应） |
| `errorMessage` | `RxString` | `''` | 错误信息文本 |
| `hasError` | `RxBool` | `false` | 是否处于错误状态 |

### 2.3 核心方法

#### `searchVideos(String keyword, {bool isLoadMore = false})`

执行搜索的核心方法，包含完整的加载/刷新/分页逻辑：

1. **空关键词检查**：如果 `keyword` 为空则直接返回
2. **OV 编号识别**：检查输入是否为 `OV` 开头 + 数字格式（如 `OV12345`）
   - 如果匹配，解析出 `vid` 并通过 `Get.toNamed('/video?vid=$vid')` 直接跳转到视频详情页，不执行搜索
3. **非加载更多模式**：
   - 设置 `isLoading = true`
   - 重置页码 `_currentPage = 1`
   - 保存当前关键词到 `currentKeyword`
   - 清除错误状态
4. **加载更多模式**：设置 `isLoadingMore = true`
5. **请求数据**：调用 `_videoRepo.searchVideos(searchTerm, offset, num: 20)`
6. **结果处理**：
   - 首次搜索：`videoList.value = videos`
   - 加载更多：`videoList.addAll(videos)`
   - 根据返回数量判断 `hasMore`（返回 < 20 条则无更多）
7. **错误处理**：
   - `ApiException`：显示 API 错误信息
   - 其他异常：显示通用错误提示

**分页参数计算：**

```dart
int offset = (_currentPage - 1) * _count;  // _count = 20
```

| 页码 | offset |
|------|--------|
| 1 | 0 |
| 2 | 20 |
| 3 | 40 |
| ... | ... |

#### `onLoad()`

上拉加载更多的触发方法：
- 若 `isLoadingMore` 为 true 或 `hasMore` 为 false 则跳过
- 调用 `searchVideos(currentKeyword.value, isLoadMore: true)`

#### `onRefresh()`

下拉刷新的触发方法：
- 若当前有搜索关键词，重新执行 `searchVideos`

#### `clearSearchResult()`

清空搜索结果：
- 清空 `videoList`
- 重置 `currentKeyword`
- 清空搜索输入框

#### `retrySearch()`

搜索失败后的重试方法：
- 使用当前保存的关键词重新搜索

#### `updateCrossAxisCount()`

根据屏幕尺寸动态计算网格列数：
- 使用 `ResponsiveUtil.calculateCrossAxisCount(baseCount: 1, minCount: 1, maxCount: 3)`
- 范围：1 ~ 3 列

#### `animateToTop()`

带动画滚动到列表顶部：
- 如果已滚动超过 5 屏高度，直接 `jumpTo(0)` 避免长距离动画卡顿
- 否则执行 500ms 的 `animateTo(0)` 平滑动画

### 2.4 私有辅助方法

| 方法 | 说明 |
|------|------|
| `_isOVNumber(String)` | 检查输入是否为 `OV` 编号格式（不区分大小写） |
| `_extractVidFromOV(String)` | 从 OV 编号中提取数字 vid |
| `_clearError()` | 清除错误状态 |
| `_setError(String)` | 设置错误状态与信息 |

---

## 3. View 详解

**源文件：** `view.dart`

`SearchPage` 是一个 `StatefulWidget`，管理搜索输入和结果展示两部分 UI。

### 3.1 状态管理

| 状态 | 类型 | 说明 |
|------|------|------|
| `_videoSearchController` | `VideoSearchController` | 通过 `Get.put` 注册，管理搜索业务逻辑 |
| `_searchController` | `SearchController`（Material） | Flutter Material 搜索控制器，驱动 `SearchAnchor` |
| `_historyService` | `SearchHistoryService` | 搜索历史持久化服务 |
| `hintText` | `String?` | 从路由参数获取的搜索提示文本 |
| `initialKeyword` | `String?` | 从路由参数获取的初始搜索词 |
| `_hasSearched` | `bool` | 防止重复自动搜索的标志 |

### 3.2 生命周期

```
initState()
  ├── Get.put(VideoSearchController)     // 注册 Controller
  ├── 读取路由参数 (hintText / keyword)     // 获取初始搜索词
  ├── _historyService.loadSearchHistory() // 加载搜索历史
  └── 如果有关键词参数，设置搜索框文本

didChangeDependencies()
  └── 如果有初始关键词且未搜索过
      └── addPostFrameCallback → searchVideos(keyword)  // 延迟执行自动搜索

dispose()
  ├── _searchController.dispose()
  ├── _videoSearchController.scrollController.dispose()
  └── Get.delete<VideoSearchController>()
```

### 3.3 搜索输入 (_buildSearchInput)

使用 Material 3 的 `SearchAnchor` + `SearchBar` 组合实现搜索框，功能完备：

**SearchBar（搜索栏栏位）：**
- 左侧搜索图标
- hintText 提示文字（可自定义）
- 右侧清除按钮（输入非空时显示）
- 点击/输入时自动打开建议面板（`controller.openView()`）
- 提交时执行搜索

**suggestionsBuilder（搜索建议面板）：**
- 根据输入实时过滤搜索历史
- 搜索历史为空时显示"暂无搜索历史"
- 每条历史项带删除按钮（`_historyService.removeSearchHistory`）
- 标题行显示"搜索历史"标签 + "清空"按钮
- 点击历史项执行搜索并关闭面板

**搜索流程：**
```
用户输入 → _onSearch(keyword)
  ├── 非空校验
  ├── _historyService.saveSearchHistory(keyword)  // 保存到历史
  ├── _searchController.closeView(null)             // 关闭建议面板
  └── _videoSearchController.searchVideos(keyword)  // 执行搜索
```

### 3.4 搜索结果展示 (_buildSearchResult)

根据搜索状态展示不同的 UI：

| 状态 | 展示内容 |
|------|----------|
| `isLoading = true` | 10 个 `VideoCardHSkeleton` 骨架屏 |
| `hasError = true` | 错误图标 + 错误信息 + "重试"按钮 |
| `videoList.isEmpty` | 视频图标 + 提示文字（"输入关键词搜索视频" / "未找到相关视频"） |
| `videoList.isNotEmpty` | 搜索结果网格 + 加载更多指示器 |

**搜索结果列表特性：**
- 使用 `SliverGrid` 配合 `SliverGridDelegateWithFixedCrossAxisCount` 网格布局
- 列数由 `crossAxisCount`（1~3）动态决定
- `childAspectRatio: 3/1`（宽高比 3:1，适配横向视频卡片）
- 每项使用 `VideoCardH` 组件，传入 `source: 'search'`
- 宽屏自适应居中：`isWideScreen` 时限制最大宽度 800px
- 下拉刷新：`RefreshIndicator` + `onRefresh`
- 上拉加载更多：监听 `ScrollEndNotification`，距离底部 100px 时触发 `onLoad`
- 底部加载指示器：`isLoadingMore=true` 时显示 `CircularProgressIndicator`，无更多数据时显示"没有更多了"

---

## 4. 数据流

### 4.1 完整请求链路

```
┌──────────────────────────┐
│  用户输入关键词并提交       │
└────────────┬─────────────┘
             ▼
┌──────────────────────────┐
│  _onSearch(keyword)      │
│  ├── 保存搜索历史          │
│  └── 调用 Controller      │
└────────────┬─────────────┘
             ▼
┌──────────────────────────────────────┐
│  VideoSearchController               │
│  searchVideos(keyword)               │
│  ├── 检查是否为 OV 编号（直接跳转）    │
│  ├── 设置 isLoading / 清空错误        │
│  └── 调用 _videoRepo.searchVideos()  │
└────────────┬─────────────────────────┘
             ▼
┌──────────────────────────┐
│  OttohubVideoRepository  │
│  searchVideos()          │
│  → VideoService.search   │
└────────────┬─────────────┘
             ▼
┌──────────────────────────┐
│  OttoHub API Server      │
│  返回 JSON 响应           │
└────────────┬─────────────┘
             ▼
┌──────────────────────────┐
│  解析为 Video 列表        │
│  更新 videoList.obs      │
└────────────┬─────────────┘
             ▼
┌──────────────────────────┐
│  Obx 自动触发 UI 重建     │
│  SliverGrid 渲染视频卡片  │
└──────────────────────────┘
```

### 4.2 分页数据流

```
首次搜索:
  keyword → _currentPage=1 → offset=0 → 获取 20 条 → videoList=[v1..v20]

加载更多 (触发 onLoad):
  keyword → _currentPage=2 → offset=20 → 获取 20 条 → videoList=[v1..v40]

加载更多 (再次触发):
  keyword → _currentPage=3 → offset=40 → 获取 <20 条 → hasMore=false → 显示"没有更多了"
```

### 4.3 搜索历史数据流

```
┌─────────────────────────┐
│  SearchHistoryService   │
│  (Hive 持久化)           │
└────────────┬────────────┘
             │
    ┌────────┴────────┐
    ▼                 ▼
保存历史             过滤历史
(onSearch)     (suggestionsBuilder)
    │                 │
    ▼                 ▼
写入 Hive Box      返回 List<String>
                    渲染建议列表
```

---

## 5. 开发指南

### 5.1 如何添加新的搜索过滤条件

当前搜索仅支持关键词搜索。如需添加排序、类型过滤等：

**步骤 1：扩展 Controller**

```dart
// controller.dart 中添加新的状态
RxString sortOrder = 'default'.obs;  // 排序方式
RxString videoType = ''.obs;         // 视频类型过滤

// 修改 searchVideos 方法
final response = await _videoRepo.searchVideos(
  searchTerm: keyword,
  offset: offset,
  num: _count,
  vidDesc: sortOrder.value == 'vid_desc' ? 1 : 0,
  viewCountDesc: sortOrder.value == 'view_desc' ? 1 : 0,
  type: videoType.value.isEmpty ? null : videoType.value,
);
```

**步骤 2：在 View 中添加过滤 UI**

在 `AppBar` 或搜索结果上方添加 `DropdownButton` 或 `ChoiceChip` 控件。

### 5.2 如何修改每页数量

修改 Controller 中的 `_count` 常量：

```dart
final int _count = 20;  // 改为 30、40 等
```

注意同步调整 `hasMore` 的判断逻辑（当前为 `videos.length >= _count`）。

### 5.3 如何自定义搜索结果卡片

当前使用 `VideoCardH`（横向卡片），`childAspectRatio` 为 `3/1`。如需切换为竖向卡片：

```dart
// view.dart _buildSearchResult 中
VideoCardV(         // 替换 VideoCardH
  videoItem: ...,
  source: 'search',
)

// 同时调整 childAspectRatio
childAspectRatio: 2 / 3,  // 竖向比例
```

### 5.4 如何添加搜索建议 API

当前建议列表仅来自本地搜索历史。如需接入远程搜索建议：

1. 在 `IVideoRepository` 中添加 `getSearchSuggestions` 方法
2. 在 Controller 中添加建议列表状态和获取方法
3. 在 `suggestionsBuilder` 中合并远程建议和本地历史

---

## 6. 二改指南

### 6.1 替换数据源

如果要将搜索切换到新的数据源（其他数据源），只需修改 Controller 中的 `searchVideos` 调用：

```dart
// 原代码
final response = await _videoRepo.searchVideos(
  searchTerm: keyword,
  offset: offset,
  num: _count,
);

// 替换为新的 API 调用
final response = await _newSourceRepo.searchVideos(
  keyword: keyword,
  page: _currentPage,
  pageSize: _count,
);
```

### 6.2 修改 OV 编号识别逻辑

如果不需要 OV 编号跳转功能，直接删除 `searchVideos` 方法中的相关逻辑（第 46~58 行和第 75~83 行）。

如果需要扩展编号格式，修改 `_isOVNumber` 和 `_extractVidFromOV` 的正则表达式：

```dart
// 支持更多格式，如 AV、BV 等
bool _isSpecialNumber(String input) {
  final RegExp pattern = RegExp(r'^(OV|AV|BV)(\d+)$', caseSensitive: false);
  return pattern.hasMatch(input.trim());
}
```

### 6.3 修改搜索历史持久化方式

当前使用 `SearchHistoryService`（Hive 持久化）。如需切换到其他存储方案（如 SharedPreferences、SQLite）：

1. 修改 `SearchHistoryService` 的实现
2. 或直接替换 View 中的 `_historyService` 为新服务
3. `suggestionsBuilder` 中的过滤和删除逻辑对应调整

### 6.4 修改布局列数

当前列数通过 `ResponsiveUtil.calculateCrossAxisCount` 动态计算。如需固定列数或调整范围：

```dart
// controller.dart
void updateCrossAxisCount() {
  crossAxisCount.value = 2;  // 固定为 2 列
}
```

### 6.5 修改宽屏最大宽度

当前宽屏布局最大宽度为 800px：

```dart
// view.dart 中
double maxContentWidth = 800;  // 修改为 600、1000 等
```

### 6.6 完整替换搜索 UI

如果希望完全自定义搜索界面（如使用自定义搜索框替代 Material `SearchAnchor`），可以在 `_buildSearchInput` 中替换为自定义 Widget，保持与 `_onSearch` 的对接即可：

```dart
Widget _buildSearchInput() {
  return MyCustomSearchBar(
    onSearch: (keyword) => _onSearch(keyword),
    suggestions: _historyService.filterSearchHistory(query),
    onDeleteHistory: (item) => _historyService.removeSearchHistory(item),
    onClearHistory: () => _historyService.clearSearchHistory(),
  );
}
```