---
date: 2026-05-14 22:45:48
title: danmaku
permalink: /pages/danmaku
categories:
  - guide
  - pages
---
# 弹幕与私信模块（Danmaku & Whisper）

本章涵盖两个功能模块：**弹幕渲染模块（PlDanmaku）** 和 **私信详情模块（WhisperDetailPage）**。两者因功能独立但同属播放器交互体系而放在一起说明。

## 目录结构

```
lib/pages/
├── danmaku/
│   ├── controller.dart    # PlDanmakuController - 弹幕数据获取与缓存
│   ├── view.dart          # PlDanmaku - canvas_danmaku 弹幕渲染层
│   └── index.dart         # 统一导出
└── whisper_detail/
    ├── controller.dart    # WhisperDetailController - 消息收发管理
    ├── view.dart          # WhisperDetailPage - 私信聊天界面
    └── index.dart         # 统一导出
```

---

## 第一部分：PlDanmaku（弹幕模块）

### 1. 模块概述

`PlDanmaku` 是一个 **非路由页面** 的独立 Widget，它在视频播放器上方叠加一层 `canvas_danmaku` 弹幕渲染层，与 `PlPlayerController` 协同工作，实现视频弹幕的实时展示。

- 采用 **原生 Dart Controller** 模式（`PlDanmakuController` 非 GetxController），避免 GetX 依赖注入开销
- 弹幕数据通过 `SplayTreeMap` 按时间戳索引，实现 O(log N) 时间复杂度的查找
- 内置静态缓存池，同一 vid 的弹幕数据跨组件共享

### 2. PlDanmakuController 详解

`PlDanmakuController` 负责弹幕数据的获取、缓存和按时间点查询。

#### 2.1 属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `vid` | `int` | 目标视频 ID |
| `onLoaded` | `Function(List<Danmaku>)?` | 弹幕加载完成回调 |
| `danmakuMap` | `SplayTreeMap<int, List<Danmaku>>` | 按时间戳分组的弹幕映射 |
| `loaded` | `bool` | 是否已加载（公开只读） |
| `initiated` | `bool` | 同 `loaded` 的别名，供外部判断 |

#### 2.2 静态缓存

```dart
static final Set<int> _loadingVids = {};       // 正在加载中的 vid 集合
static final Map<int, List<Danmaku>> _cachedDanmaku = {};  // 已加载弹幕的缓存池
```

- `_loadingVids`：防止同一 vid 被重复请求
- `_cachedDanmaku`：弹幕数据缓存，不同视频实例共享

#### 2.3 核心方法

**`initiate(videoDuration, progress)`**

```dart
void initiate(int videoDuration, int progress) async {
  if (_loaded || _loading) return;
  if (_loadingVids.contains(vid)) return;
  _loading = true;
  _loadingVids.add(vid);
  await queryDanmaku();
}
```

三层防护确保不会重复加载：
1. 已加载完成 → 跳过
2. 正在加载中 → 跳过
3. 其他实例正在加载同一 vid → 跳过

**`queryDanmaku()`**

```dart
Future<void> queryDanmaku() async {
  if (_cachedDanmaku.containsKey(vid)) {
    _danmakuMap = _mapDanmaku(_cachedDanmaku[vid]!);
    _loaded = true;
    onLoaded?.call(_cachedDanmaku[vid]!);
    return;
  }
  final response = await DanmakuService.getDanmakus(vid);
  _cachedDanmaku[vid] = response;
  _danmakuMap = _mapDanmaku(response);
  _loaded = true;
  onLoaded?.call(response);
}
```

- 优先使用静态缓存，命中缓存直接返回
- 未命中则调用 `DanmakuService.getDanmakus(vid)` 获取
- 获取后写入缓存并触发 `onLoaded` 回调

**`_mapDanmaku(List<Danmaku>)`**

```dart
SplayTreeMap<int, List<Danmaku>> _mapDanmaku(List<Danmaku> danmakuList) {
  final map = SplayTreeMap<int, List<Danmaku>>();
  for (final danmaku in danmakuList) {
    final timeKey = danmaku.time.toInt();
    map.putIfAbsent(timeKey, () => []).add(danmaku);
  }
  return map;
}
```

将弹幕列表按 `time` 字段（取整）分组存入 `SplayTreeMap`。同一秒内的多条弹幕合并为 `List<Danmaku>`。

**`getCurrentDanmaku(int progress)`**

```dart
List<Danmaku>? getCurrentDanmaku(int progress) {
  if (!_loaded) {
    if (!_loading && !_loadingVids.contains(vid)) {
      queryDanmaku();  // 懒加载：未加载且未在加载中则触发
    }
    return null;
  }
  return _danmakuMap[progress];
}
```

播放器每 100ms 调用此方法查询当前时间戳对应的弹幕。首次调用且未加载时自动触发懒加载。

**`clear()` / `clearCache()` / `clearAllCache()`**

| 方法 | 说明 |
|------|------|
| `clear()` | 实例级清理，移除 `_loadingVids` 中的当前 vid |
| `clearCache(int vid)` | 静态方法，清除指定 vid 的缓存 |
| `clearAllCache()` | 静态方法，清除所有缓存 |

### 3. PlDanmaku View 详解

`PlDanmaku` 是弹幕渲染 Widget，作为播放器覆盖层使用。

#### 3.1 构造参数

| 参数 | 类型 | 说明 |
|------|------|------|
| `vid` | `int?` | 视频 ID（视频模式下必传） |
| `cid` | `int?` | 分P ID（备用） |
| `playerController` | `PlPlayerController` | 播放器控制器（双向绑定） |
| `type` | `String` | 类型：`'video'` 或其它 |
| `createdController` | `Function(DanmakuController)?` | 弹幕引擎控制器创建回调 |

#### 3.2 初始化流程

```dart
void initState() {
  super.initState();
  enableShowDanmaku = setting.get(SettingBoxKey.enableShowDanmaku, defaultValue: false);
  _plDanmakuController = PlDanmakuController(vid: _videoId);
  playerController = widget.playerController;

  // 视频模式下：根据开关状态决定是否加载
  if (mounted && widget.type == 'video') {
    if (enableShowDanmaku || playerController.isOpenDanmu.value) {
      _plDanmakuController.initiate(duration, position);
    }
    playerController
      ..addStatusLister(playerListener)      // 播放状态监听
      ..addPositionListener(videoPositionListen);  // 播放位置监听
  }

  // 监听弹幕开关状态变化
  playerController.isOpenDanmu.listen((p0) {
    if (p0 && !_plDanmakuController.initiated) {
      _plDanmakuController.initiate(duration, position);
    }
  });
}
```

关键设计：弹幕加载时机由 **播放器开关状态** 和 **全局设置** 双重控制，用户可在播放器界面随时开启/关闭弹幕。

#### 3.3 弹幕渲染配置

从 `playerController` 读取所有 UI 配置：

| 配置项 | 来源 | 说明 |
|------|------|------|
| `blockTypes` | `playerController.blockTypes` | 屏蔽弹幕类型列表 |
| `showArea` | `playerController.showArea` | 显示区域比例 |
| `opacityVal` | `playerController.opacityVal` | 透明度 |
| `fontSizeVal` | `playerController.fontSizeVal` | 字体大小倍率 |
| `strokeWidth` | `playerController.strokeWidth` | 描边宽度 |
| `danmakuDurationVal` | `playerController.danmakuDurationVal` | 弹幕持续时间 |

#### 3.4 弹幕屏蔽逻辑

```dart
bool _shouldBlockDanmaku(Danmaku danmaku) {
  if (playerController.blockTypes.contains(6) && danmaku.color != '#ffffff') {
    return true;  // 屏蔽"彩色弹幕"
  }
  return false;
}
```

当前仅实现彩色弹幕屏蔽（类型 6），其他屏蔽类型（`blockTypes` 2/4/5）直接传递给 `DanmakuOption` 的 `hideScroll`/`hideBottom`/`hideTop`。

#### 3.5 弹幕类型解析

```dart
DanmakuItemType _parseDanmakuType(String mode) {
  switch (mode.toLowerCase()) {
    case 'top':    return DanmakuItemType.top;
    case 'bottom': return DanmakuItemType.bottom;
    default:       return DanmakuItemType.scroll;
  }
}
```

支持三种弹幕模式：滚动（默认）、顶部、底部。

#### 3.6 组件树

```
PlDanmaku (StatefulWidget)
└── LayoutBuilder
    └── Obx → AnimatedOpacity (opacity: isOpenDanmu ? 1 : 0, 100ms)
        └── DanmakuScreen
            ├── createdController → 将 DanmakuController 绑定到 playerController
            └── option: DanmakuOption (fontSize, area, opacity, hide*, duration, strokeWidth)
```

- `AnimatedOpacity` 实现 100ms 的弹幕开关渐变
- `DanmakuScreen` 是 `canvas_danmaku` 库的核心渲染组件

---

## 第二部分：WhisperDetailPage（私信详情）

### 4. 模块概述

`WhisperDetailPage` 是一个聊天式私信界面，路由为 `/whisperDetail?mid=xxx&name=xxx&face=xxx&heroTag=xxx`，支持消息列表展示、下拉加载更多、发送消息。

模块采用标准 **Controller-View 分离** 架构：

```
lib/pages/whisper_detail/
├── controller.dart    # WhisperDetailController - 消息管理
├── view.dart          # WhisperDetailPage - 聊天 UI
└── index.dart         # 统一导出
```

### 5. WhisperDetailController 详解

`WhisperDetailController` 管理消息的分页加载与发送。

#### 5.1 构造参数

| 参数 | 类型 | 说明 |
|------|------|------|
| `friendUid` | `int` | 好友 UID |
| `friendName` | `String` | 好友昵称 |
| `friendAvatar` | `String?` | 好友头像 URL |
| `heroTag` | `String` | GetX tag，支持同一 Controller 多实例 |

#### 5.2 Rx 响应式状态

| 变量 | 类型 | 说明 |
|------|------|------|
| `messages` | `RxList<Message>` | 消息列表 |
| `isLoading` | `RxBool` | 是否正在加载消息 |
| `isSending` | `RxBool` | 是否正在发送消息 |
| `errorMessage` | `RxString` | 错误信息（驱动错误状态 UI） |
| `snackbarMessage` | `RxString` | SnackBar 提示信息 |

#### 5.3 分页加载

```dart
int _offset = 0;
final int _pageSize = 20;
bool _hasMore = true;

Future loadMessages({bool refresh = false}) async {
  if (isLoading.value) return;
  if (refresh) { _offset = 0; _hasMore = true; messages.clear(); }
  if (!_hasMore) return;

  isLoading.value = true;
  final newMessages = await _messageRepo.getFriendMessage(
    friendUid: friendUid, offset: _offset, num: _pageSize,
  );

  if (newMessages.length < _pageSize) _hasMore = false;
  refresh ? messages.assignAll(newMessages) : messages.addAll(newMessages);
  _offset += newMessages.length;
}
```

- `refresh: true`：下拉刷新，重置分页状态
- `refresh: false`：上拉加载更多，追加数据
- `_hasMore` 为 `false` 时不再触发加载

#### 5.4 发送消息

```dart
Future sendMessage() async {
  final text = messageController.text.trim();
  if (text.isEmpty || isSending.value) return;

  isSending.value = true;
  final success = await _messageRepo.sendMessage(receiver: friendUid, message: text);
  if (success) {
    messageController.clear();
    await loadMessages(refresh: true);  // 发送后刷新列表
  }
}
```

- 发送前校验文本非空和 `isSending` 防重复
- 发送成功后清空输入框并重新加载消息列表

#### 5.5 生命周期清理

```dart
void onClose() {
  scrollController.dispose();
  messageController.dispose();
  focusNode.dispose();
  super.onClose();
}
```

确保所有控制器和焦点节点被正确释放。

### 6. WhisperDetailPage View 详解

`WhisperDetailPage` 实现聊天界面。

#### 6.1 路由参数解析

```dart
friendUid = int.tryParse(parameters['mid'] ?? '0') ?? 0;
friendName = parameters['name'] ?? '';
friendAvatar = parameters['face'];
heroTag = parameters['heroTag'] ?? '';
```

通过 `Get.parameters` 获取路由参数，Controller 使用 `heroTag` 作为 `tag` 注册，支持多实例。

#### 6.2 组件树

```
WhisperDetailPage (StatefulWidget)
└── Scaffold
    ├── AppBar (居中)
    │   └── Row: [CircleAvatar(friendAvatar), Text(friendName)]
    └── Column
        ├── Obx → snackbarMessage 触发 SnackBar
        └── Expanded
            └── Obx → 状态分支:
                ├── isLoading + messages空 → CircularProgressIndicator
                ├── errorMessage 非空 + messages空 → 错误 + 重试按钮
                ├── messages 空 → "暂无消息"
                └── RefreshIndicator → ListView.builder (reverse: true)
        └── _buildInputArea
            └── Row: [TextField (消息输入), Obx → IconButton.filled (发送)]
```

#### 6.3 消息列表

- `ListView.builder(reverse: true)`：消息从底部开始展示，新消息自动滚动到顶部
- `RefreshIndicator`：下拉触发 `loadMessages(refresh: true)`
- 每条消息通过 `_buildMessageItem` 渲染为聊天气泡

#### 6.4 聊天气泡

```dart
Widget _buildMessageItem(Message message, bool isMe, ThemeData theme, String? myAvatar) {
  return Row(
    mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
    children: [
      if (!isMe) [CircleAvatar(friendAvatar), SizedBox(width: 8)],
      Flexible(
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              color: isMe ? primary : surfaceContainerHighest,
              child: Text(message.content),
            ),
            Text(message.time),  // 时间戳
          ],
        ),
      ),
      if (isMe) [SizedBox(width: 8), CircleAvatar(myAvatar)],
    ],
  );
}
```

- 自己发送的消息：右对齐，主色背景，右侧显示自己的头像
- 对方发送的消息：左对齐，灰色背景，左侧显示对方头像
- 最大宽度限制为屏幕宽度的 70%

#### 6.5 输入区域

```dart
Widget _buildInputArea(ThemeData theme) {
  return Container(
    child: Row([
      Expanded(TextField(decoration: InputDecoration(borderRadius: 24))),
      Obx(() => IconButton.filled(
        onPressed: isSending.value ? null : sendMessage,
        icon: isSending.value ? CircularProgressIndicator : Icon(Icons.send_rounded),
      )),
    ]),
  );
}
```

- `TextField` 使用 `TextInputAction.send`，键盘上显示发送按钮
- 发送中时按钮禁用并显示加载动画
- `bottom` padding 适配安全区域

---

## 7. 数据流

### 弹幕数据流

```
视频播放开始
  → PlDanmaku.initState()
    ├── 创建 PlDanmakuController(vid)
    ├── type=='video' && (enableShowDanmaku || isOpenDanmu)
    │     → controller.initiate(duration, position)
    │         └── queryDanmaku()
    │               ├── 命中静态缓存 → 直接使用
    │               └── 未命中 → DanmakuService.getDanmakus(vid)
    │                     ├── _mapDanmaku() → SplayTreeMap
    │                     └── 写入 _cachedDanmaku 缓存
    └── playerController.addPositionListener(videoPositionListen)

播放进度更新（每 100ms 去重）
  → videoPositionListen(position)
    ├── isOpenDanmu == false → 忽略
    ├── position % 100 == latestAddedPosition → 去重跳过
    └── getCurrentDanmaku(position)
        ├── _shouldBlockDanmaku() 过滤
        └── controller.addDanmaku(DanmakuContentItem)
```

### 私信数据流

```
Get.toNamed('/whisperDetail?mid=123&name=xxx')
  → WhisperDetailController.onInit()
    └── loadMessages()
        └── IMessageRepository.getFriendMessage(friendUid, offset: 0, num: 20)
              └── messages 赋值 → UI 渲染

用户下拉刷新
  → RefreshIndicator → loadMessages(refresh: true)
    └── 重置 offset / _hasMore → 重新加载

用户上拉加载更多
  → scrollController listener
    └── loadMessages(refresh: false)
        └── offset 追加 → messages.addAll()

用户发送消息
  → sendMessage()
    └── IMessageRepository.sendMessage(receiver, message)
        ├── 成功 → clear() + loadMessages(refresh: true)
        └── 失败 → snackbarMessage.value = '发送失败'
```

---

## 8. 开发指南

### 8.1 在播放器中集成弹幕

```dart
Stack(
  children: [
    PlPlayer(...),  // 播放器
    Positioned.fill(
      child: PlDanmaku(
        vid: videoId,
        playerController: playerController,
      ),
    ),
  ],
)
```

### 8.2 触发私信页面

```dart
Get.toNamed('/whisperDetail', parameters: {
  'mid': '12345',
  'name': '用户名',
  'face': 'https://.../avatar.jpg',
  'heroTag': 'whisper_12345',
});
```

### 8.3 监听弹幕加载完成

```dart
final controller = PlDanmakuController(
  vid: 12345,
  onLoaded: (danmakuList) {
    print('弹幕加载完成，共 ${danmakuList.length} 条');
  },
);
```

---

## 9. 二改指南

### 9.1 新增弹幕屏蔽类型

在 `_shouldBlockDanmaku` 中添加新规则：

```dart
bool _shouldBlockDanmaku(Danmaku danmaku) {
  if (playerController.blockTypes.contains(7) && danmaku.text.contains('关键词')) {
    return true;
  }
  return false;
}
```

### 9.2 扩大弹幕缓存容量

当前缓存无容量限制。如需添加上限：

```dart
static final LinkedHashMap<int, List<Danmaku>> _cachedDanmaku =
    LinkedHashMap(maximumSize: 50);  // 最多缓存 50 个视频的弹幕
```

### 9.3 私信消息持久化

当前消息仅在内存中，切换页面后丢失。可添加 Hive 持久化：

```dart
Future loadMessages({bool refresh = false}) async {
  // 先读本地缓存
  final localMessages = GStrorage.localCache.get('whisper_$friendUid');
  if (localMessages != null) messages.assignAll(localMessages);
  // 再请求远程
  // ...
  // 写入本地
  GStrorage.localCache.put('whisper_$friendUid', messages.toList());
}
```

### 9.4 注意事项

1. **弹幕懒加载**：`getCurrentDanmaku` 在首次调用时可能触发网络请求，确保调用方有 `await` 或回调处理
2. **静态缓存清理**：视频切换频繁时应调用 `PlDanmakuController.clearAllCache()` 释放内存
3. **消息分页**：`loadMessages` 的 `_hasMore` 判断依赖 `newMessages.length < _pageSize`，若 API 返回数量不稳定应改用其他断点方式
4. **弹幕去重**：`latestAddedPosition` 按 100ms 粒度去重，避免进度条跳跃导致同一批弹幕重复添加