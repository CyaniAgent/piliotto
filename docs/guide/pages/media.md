---
date: 2026-05-14 22:54:20
title: media
permalink: /pages/
categories:
  - guide
  - pages
---
# 媒体库页（Media）

## 1. 模块概述

`MediaPage` 是用户媒体库入口页面，提供观看记录和收藏夹两大功能的快捷访问。登录后展示收藏夹的横向预览列表，支持直接预览收藏夹封面和跳转详情。

| 页面 | 路由 | 数据源 | 用途 |
|------|------|--------|------|
| `MediaPage` | `/media` (Tab 内嵌页面) | `IVideoRepository.getFavoriteVideos()` | 媒体库入口 + 收藏夹预览 |

### 文件结构

```
lib/pages/media/
├── controller.dart      # MediaController - 媒体库控制器
├── view.dart            # MediaPage - 媒体库页 UI + FavFolderItem 组件
└── index.dart           # 模块导出
```

### 依赖关系

```
MediaPage (StatefulWidget + AutomaticKeepAliveClientMixin)
  ├── Get.put → MediaController
  ├── IVideoRepository → getFavoriteVideos(offset: 0, num: 5)
  ├── GStrorage.userInfo → 判断登录态
  ├── ListTile → 观看记录 (/history)
  ├── ListTile → 我的收藏 (/fav)
  ├── FutureBuilder → favFolder 收藏夹预览
  │   └── ListView.builder (水平滚动)
  │       └── FavFolderItem (StatelessWidget)
  │           ├── Hero + NetworkImgLayer (封面图)
  │           ├── 收藏夹名称
  │           └── 视频数量
  └── 登录态监听 → userLogin.listen
```

---

## 2. Controller 详解

**源文件：** `controller.dart`

`MediaController` 继承自 `GetxController`，管理媒体库的登录态判断和收藏夹数据获取。

### 2.1 核心属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `favFolderData` | `Rx<FavFolderData>` | 收藏夹数据（响应式），含 `count` + `list` |
| `userInfoCache` | `Box` | Hive 缓存 Box，用于读取用户信息 |
| `userLogin` | `RxBool` | 登录状态（响应式），未登录时隐藏收藏夹区域 |
| `mid` | `int?` | 当前登录用户 ID |
| `userInfo` | `dynamic` | 缓存的用户信息对象 |
| `scrollController` | `ScrollController` | 页面滚动控制器 |
| `list` | `List<Map>` | 媒体库功能入口列表 |

### 2.2 功能入口列表

```dart
// controller.dart 中的 list 定义
[
  {'icon': Icons.history,   'title': '观看记录', 'onTap': () => Get.toNamed('/history')},
  {'icon': Icons.star_border,'title': '我的收藏', 'onTap': () => Get.toNamed('/fav')},
]
```

该列表驱动页面上半部分的快捷入口。添加新入口只需新增 Map 元素。

### 2.3 核心方法

**`onInit()`**
从 `GStrorage.userInfo` 读取缓存的用户信息，判断登录态：`userLogin.value = userInfo != null`。

**`queryFavFolder()`**
获取收藏夹数据（适配 `FutureBuilder`）：
- 未登录返回 `{'status': false, 'msg': '未登录'}`
- 已登录调用 `_videoRepo.getFavoriteVideos(offset: 0, num: 5)` 获取最近 5 个收藏夹
- 成功返回 `{'status': true, 'data': response}`，失败返回 `{'status': false, 'msg': ...}`
- 返回 `Map` 而非直接设置 `favFolderData`，适配 View 层的 `FutureBuilder` 模式

---

## 3. View 详解

**源文件：** `view.dart`

`MediaPage` 是一个 `StatefulWidget`，混合 `AutomaticKeepAliveClientMixin`。

### 3.1 页面结构

```
Scaffold
├── AppBar (toolbarHeight: 30)
└── body: SingleChildScrollView
    └── Column
        ├── ListTile (标题 "媒体库"，加粗大字号)
        ├── forEach → mediaController.list
        │   └── ListTile
        │       ├── leading: Icon (带 primary 颜色)
        │       ├── title: 入口名称
        │       └── onTap: 路由跳转
        ├── Obx → [userLogin] favFolder()
        │   └── Column
        │       ├── Divider (35px 高度)
        │       ├── ListTile (标题 "收藏夹 N" + 刷新按钮)
        │       └── FutureBuilder → 120px / 200px 高度的水平预览区
        │           ├── [loading] → SizedBox (无骨架屏)
        │           ├── [error] → 居中错误文本
        │           └── [success] → Obx
        │               └── ListView.builder (Axis.horizontal)
        │                   ├── FavFolderItem (收藏夹卡片)
        │                   └── "查看更多" 箭头按钮 (当 count > list.length 时)
        └── SizedBox (底部安全区 + 导航栏高度)
```

### 3.2 初始化流程

```dart
// initState
mediaController = Get.put(MediaController());
_futureBuilderFuture = mediaController.queryFavFolder();

// 监听登录态变化，重新加载收藏夹
mediaController.userLogin.listen((status) {
  setState(() {
    _futureBuilderFuture = mediaController.queryFavFolder();
  });
});
```

登录态变化（如登录/登出）时，自动重新触发收藏夹数据加载。

### 3.3 收藏夹预览区

**标题行**
- 左侧："收藏夹" + 收藏夹总数（蓝色 primary 色）
- 右侧：刷新按钮（`Icons.refresh`），点击重新加载 `queryFavFolder()`

**横向预览列表**
- 高度：`MediaQuery.textScalerOf(context).scale(200)`（响应系统字体缩放）
- 水平滚动 `ListView.builder`
- 每项为 `FavFolderItem` 卡片

**"查看更多"按钮**
当 `favFolderCount > favFolderList.length` 时（即收藏夹总数超过预览数量 5 个），在列表末位显示一个圆形箭头按钮，点击跳转 `/fav` 完整收藏夹页。

### 3.4 FavFolderItem 组件

收藏夹卡片组件，结构：

```
Container (margin: left 20 / right 14)
└── GestureDetector → Get.toNamed('/favDetail')
    └── Column
        ├── SizedBox(12)
        ├── Container (180×110, 圆角 12 + 阴影)
        │   └── Hero (tag: heroTag)
        │       └── NetworkImgLayer (封面图)
        ├── Text (收藏夹名称, 单行省略)
        └── Text ("共N条视频", labelSmall + outline 色)
```

点击卡片跳转 `/favDetail`，携带 `mediaId`、`heroTag`、`isOwner: '1'` 参数。

---

## 4. 数据流

```
┌──────────────────────────────────┐
│  MediaPage.initState             │
│  mediaController.queryFavFolder()│
└───────────────┬──────────────────┘
                │
    ┌───────────▼───────────┐
    │ 是否已登录？           │
    └──────┬──────────┬─────┘
     未登录 │          │ 已登录
           ▼          ▼
  {status:false,   IVideoRepository
   msg:'未登录'}    getFavoriteVideos
           │       (offset:0, num:5)
           │          │
           └────┬─────┘
                ▼
    ┌─────────────────────┐
    │ favFolderData       │
    │ Rx<FavFolderData>   │
    │  .count (总数)       │
    │  .list (预览列表)    │
    └──────────┬──────────┘
               │
    ┌──────────▼──────────┐
    │ FutureBuilder       │
    │  ├── error → 文本   │
    │  └── success →      │
    │      ListView       │
    │      FavFolderItem  │
    └─────────────────────┘
```

### 状态管理

| 状态 | 来源 | 说明 |
|------|------|------|
| `userLogin` | `RxBool` | 控制收藏夹区域的显示/隐藏 |
| `favFolderData` | `Rx<FavFolderData>` | 收藏夹数据，`count` 和 `list` 分别用于总数显示和列表渲染 |
| `_futureBuilderFuture` | `Future` | 驱动 `FutureBuilder` 的状态切换 |

### 登录态联动

登录态变化 → `userLogin.listen` → `setState` 重置 `_futureBuilderFuture` → `FutureBuilder` 重新构建 → 显示/隐藏收藏夹区域。

---

## 5. 开发指南

### 5.1 添加新的媒体库入口

在 `MediaController.list` 中添加新的 Map 元素：

```dart
{
  'icon': Icons.download,
  'title': '离线缓存',
  'onTap': () => Get.toNamed('/offline'),
},
```

View 层通过 `for (var i in mediaController.list)` 自动渲染，无需修改 UI 代码。

### 5.2 修改收藏夹预览数量

修改 `queryFavFolder()` 中 `getFavoriteVideos(offset: 0, num: 5)` 的 `num` 参数。注意调整 `FavFolderItem` 卡片的宽度和预览区高度以适应更多卡片。

### 5.3 接入收藏夹真实 API

当前 `queryFavFolder()` 调用 `getFavoriteVideos()` 获取数据，但未将响应数据赋值给 `favFolderData`。需要根据 API 返回的实际数据结构更新：

```dart
final response = await _videoRepo.getFavoriteVideos(offset: 0, num: 5);
favFolderData.value = response; // 或从 response 中提取 FavFolderData
```

### 5.4 添加加载骨架屏

当前 `FutureBuilder` 的 loading 状态返回 `const SizedBox()`。可替换为水平排列的骨架卡片：

```dart
if (snapshot.connectionState != ConnectionState.done) {
  return SizedBox(
    height: 200,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 5,
      itemBuilder: (_, __) => FavFolderSkeleton(),
    ),
  );
}
```

---

## 6. 二改指南

### 6.1 常见需求

#### 替换收藏夹为"稍后再看"列表
在 `list` 中将"我的收藏"入口替换为"稍后再看"，修改 `onTap` 路由。收藏夹预览区域也可替换为对应的预览列表。

#### 添加"下载管理"入口
在 `list` 中添加下载入口，并在 `SingleChildScrollView` 下方添加下载中的任务预览区。

#### 修改收藏夹卡片样式
在 `FavFolderItem.build()` 中调整 `Container` 的宽高、圆角、阴影等样式。注意 `NetworkImgLayer` 依赖 `LayoutBuilder` 的 `BoxConstraints`。

#### 添加登录引导
当前未登录时收藏夹区域隐藏（`const SizedBox()`）。可在未登录时展示登录引导卡片，提示用户登录后查看收藏。

#### 支持下拉刷新
为 `SingleChildScrollView` 包裹 `RefreshIndicator`，刷新时重新调用 `queryFavFolder()`。

### 6.2 注意事项

- `MediaPage` 使用 `AutomaticKeepAliveClientMixin`，Tab 切换时保持状态
- `queryFavFolder()` 返回 `Map` 而非直接操作 `favFolderData`，是为了适配 `FutureBuilder` 的状态管理
- `userLogin.listen` 中的 `setState` 会触发整个 `MediaPage` 重建，若非必须避免在此处执行昂贵操作
- `FavFolderItem` 中的 `Hero` tag 通过 `Utils.makeHeroTag(item.fid)` 生成，确保与 `/favDetail` 页面的 Hero tag 匹配
- 水平 `ListView.builder` 的 `itemCount` 计算：`list.length + (flag ? 1 : 0)`，flag 为是否显示"查看更多"按钮