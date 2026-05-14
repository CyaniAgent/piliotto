---
date: 2026-05-14 22:57:19
title: message
permalink: /pages/34b693
categories:
  - guide
  - pages
---
# 消息模块（Message）

## 1. 模块概述

消息模块是 PiliOtto 的私信/聊天功能页面，负责展示好友列表和聊天对话。模块采用 **宽屏分栏 + 窄屏独立页面** 的响应式布局策略：宽屏下好友列表与聊天详情左右并排，窄屏下点击好友跳转至独立的 `/whisperDetail` 页面进行对话。

模块文件结构：

```
lib/pages/message/
├── controller.dart            # MessageController - 好友列表管理、多用户切换
├── view.dart                  # MessagePage - 响应式双栏布局 + 聊天面板（含轮询）
└── index.dart                 # 统一导出

lib/pages/message_list/
└── controller.dart            # MessageListController - 简单好友列表（无聊天详情）
```

### 核心功能

| 功能 | 说明 |
|------|------|
| 好友列表 | 分页加载好友列表，支持下拉刷新 |
| 一对一聊天 | 选中好友后进入聊天界面，发送/接收消息 |
| 消息轮询 | 每 10 秒自动轮询新消息 |
| 多用户切换 | 宽屏模式支持在已聊过天的用户之间切换当前身份 |
| 未读提示 | 显示未读消息数红点和最后消息时间 |
| 响应式布局 | ≥800px 双栏，<800px 路由跳转 |

---

## 2. Controller 详解

### 2.1 MessageController

`MessageController` 继承 `GetxController`，负责好友列表的加载、选择与多用户切换。

#### 响应式状态

| 属性 | 类型 | 说明 |
|------|------|------|
| `friendList` | `RxList<Friend>` | 当前用户的好友列表 |
| `isLoading` | `RxBool` | 加载状态 |
| `errorMessage` | `RxString` | 错误消息 |
| `selectedFriend` | `Rxn<Friend>` | 当前选中的好友（可空） |
| `currentUser` | `Rxn<Friend>` | 当前登录用户信息 |
| `userList` | `RxList<Friend>` | 所有曾对话过的用户列表（用于切换） |

#### 内部状态

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `_offset` | `int` | `0` | 分页偏移量 |
| `_pageSize` | `int` | `20` | 每页条数 |
| `_hasMore` | `bool` | `true` | 是否有更多数据 |

#### 生命周期

```dart
@override
void onInit() {
  super.onInit();
  _initCurrentUser();      // 从 Hive 缓存读取当前用户信息
  _checkInitialFriend();   // 检查路由参数是否有目标好友
  loadFriendList();        // 加载好友列表
}
```

#### `loadFriendList({bool refresh})` — 加载好友列表

`controller.dart:L54-L89`

1. `refresh=true` 时重置 `_offset=0`、`_hasMore=true`、清空列表
2. 调用 `IMessageRepository.getMergedFriendList(uid:, offset:, pageSize:)` 获取合并好友列表
3. 数据少于 `_pageSize` 时标记 `_hasMore=false`
4. 将新数据追加到 `friendList`，并通过 `_updateUserList` 去重追加到 `userList`

`getMergedFriendList` 与 `MessageListController` 使用的 `getFriendList` 不同，它会合并多个来源的好友数据。

#### `selectFriend(Friend)` / `clearSelection()` — 好友选择

- `selectFriend`：设置 `selectedFriend`，触发聊天面板切换
- `clearSelection`：将 `selectedFriend` 置 null，聊天面板显示空状态

#### `switchUser(Friend)` — 切换用户身份

`controller.dart:L107-L115`

设置新的 `currentUser`，清空 `selectedFriend`、`friendList`、`userList`，重置分页状态后重新加载。

### 2.2 MessageListController

`MessageListController` 是 message 模块的一个简化变体，仅管理好友列表的加载和刷新，不含选择和聊天功能。使用 `IMessageRepository.getFriendList` 获取数据。

---

## 3. View 详解

`MessagePage` 是 `StatefulWidget`，在 `initState` 中完成 Controller 注入和窄屏路由跳转判断。

### 3.1 窄屏自动跳转逻辑

`view.dart:L30-L47`

当屏幕宽度 < 800px 且路由参数包含 `mid` 和 `name` 时，在首帧渲染完成后自动跳转到 `/whisperDetail`：

```dart
if (mid != null && name != null && !_hasNavigated) {
  _hasNavigated = true;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Get.toNamed('/whisperDetail', parameters: {
      'mid': mid, 'name': name,
      'face': face ?? '', 'heroTag': mid,
    });
  });
}
```

`_hasNavigated` 防止重复跳转。

### 3.2 宽屏布局（双栏）

`view.dart:L126-L171`

```
┌────────────────────────────────────────────────┐
│  AppBar（消息 / 切换用户按钮）                      │
├──────────────┬─────────────────────────────────┤
│              │                                 │
│  好友列表      │         聊天详情面板              │
│  (320px)     │         (Expanded)              │
│              │                                 │
│              │  - 无选中时：空状态提示              │
│              │  - 有选中时：_ChatDetailPanel     │
│              │                                 │
└──────────────┴─────────────────────────────────┘
```

- 好友列表宽度固定 320px
- 中间 1px 分隔线
- 选中好友高亮（`primaryContainer.withAlpha(100)`）

### 3.3 窄屏布局（单栏）

仅渲染 `_buildFriendListPanel`，点击好友跳转到 `/whisperDetail`。

### 3.4 好友列表面板

`view.dart:L177-L215`

三种状态处理：
- **加载中 + 列表为空**：居中 `CircularProgressIndicator`
- **有错误 + 列表为空**：错误文本 + 重试按钮
- **列表为空**："暂无消息" 提示
- **有数据**：`RefreshIndicator` + `ListView.builder`

### 3.5 好友列表项

`view.dart:L217-L303`

每项显示：
- **头像**：48px `CircleAvatar`，优先网络图片，回退为图标
- **用户名**：加粗显示
- **最后消息**：单行省略
- **时间**：智能格式化（今天显示 HH:mm，昨天显示"昨天"，7天内显示"N天前"，超过显示 M/d）
- **未读数**：红色圆形 badge，超过 99 显示 "99+"

点击行为：
- 宽屏：调用 `controller.selectFriend(friend)` 切换右侧面板
- 窄屏：`Get.toNamed('/whisperDetail')` 跳转

### 3.6 聊天详情面板（_ChatDetailPanel）

`_ChatDetailPanel` 是内嵌在 `view.dart` 中的私有 `StatefulWidget`，管理单个聊天会话。

#### 核心状态

| 属性 | 类型 | 说明 |
|------|------|------|
| `messages` | `RxList<Message>` | 消息列表 |
| `isLoading` | `RxBool` | 加载状态 |
| `isSending` | `RxBool` | 发送中状态 |
| `errorMessage` | `RxString` | 错误消息 |
| `_pollTimer` | `Timer?` | 轮询定时器 |

#### 消息轮询

`view.dart:L373-L417`

每 10 秒通过 `Timer.periodic` 调用 `_pollNewMessages()`，比较最新消息 ID（`msgId > latestMsgId`）判断是否有新消息，有则刷新列表并滚动到顶部。

#### 消息加载

`view.dart:L419-L469`

采用分页加载，`reverse: true` 实现从底部开始的消息列表布局。刷新时 `assignAll`，加载更多时 `addAll`。

#### 发送消息

`view.dart:L471-L492`

调用 `IMessageRepository.sendMessage(receiver:, message:)`，成功后清空输入框并刷新消息列表。

#### 消息气泡

`view.dart:L580-L663`

- **自己发送**：右对齐，蓝色（`theme.colorScheme.primary`）气泡，右侧显示自己头像
- **对方发送**：左对齐，灰色（`surfaceContainerHighest`）气泡，左侧显示对方头像
- 最大宽度限制为屏幕宽度的 50%
- 每条消息下方显示时间戳

#### 输入区域

`view.dart:L666-L720`

固定在底部的输入栏，包含：
- 圆角输入框（`BorderRadius.circular(24)`）
- 发送按钮（蓝色填充 `IconButton.filled`），发送中显示 `CircularProgressIndicator`
- 支持回车发送（`textInputAction: TextInputAction.send`）

### 3.7 用户切换弹窗

`view.dart:L73-L124`

仅在宽屏模式下可用（AppBar 右侧图标按钮），弹窗内以 `ListView` 展示 `userList` 中的所有用户，当前用户标记勾选图标，点击切换后关闭弹窗。

---

## 4. 数据流

```
应用启动
  │
  ▼
MessageController.onInit()
  │
  ├── _initCurrentUser() ──► Hive GStrorage.userInfo ──► currentUser
  ├── _checkInitialFriend() ──► Get.parameters ──► selectedFriend（如有）
  └── loadFriendList()
        │
        ▼
  IMessageRepository.getMergedFriendList() ──► friendList
        │
        ▼
  用户点击好友
        │
        ├── 宽屏 ──► selectFriend() ──► _ChatDetailPanel 渲染
        └── 窄屏 ──► Get.toNamed('/whisperDetail')

_ChatDetailPanel
  │
  ├── initState ──► loadMessages() + _startPolling()
  │
  ├── 每10秒 ──► _pollNewMessages() ──► IMessageRepository.getFriendMessage()
  │     │
  │     └── 有新消息? ──► messages.assignAll(newMessages)
  │
  └── 用户发送 ──► sendMessage()
        │
        ▼
  IMessageRepository.sendMessage() ──► 成功后 refresh
```

---

## 5. 开发指南

### 5.1 理解消息模型

消息模块使用两个核心模型：

- `Friend`：好友信息，包含 `uid`、`username`、`avatarUrl`、`lastMessage`、`lastTime`、`newMessageNum`
- `Message`：聊天消息，包含 `msgId`、`sender`、`content`、`time`

这两个模型定义在 `lib/ottohub/api/models/message.dart`。

### 5.2 调整轮询间隔

轮询间隔硬编码在 `view.dart:L375`：

```dart
_pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
  _pollNewMessages();
});
```

修改 `Duration(seconds: 10)` 即可调整。

### 5.3 添加新的消息类型

当前仅支持文本消息。要扩展消息类型（如图片、语音），需要：

1. 扩展 `Message` 模型，添加 `messageType` 字段
2. 在 `_buildMessageItem` 中根据类型渲染不同的 widget
3. 在数据层 `IMessageRepository` 中实现对应的发送/接收方法

---

## 6. 二改指南

### 6.1 自定义消息气泡样式

消息气泡样式定义在 `view.dart:L609-L629`。修改 `BoxDecoration` 的 `color` 和 `borderRadius` 即可改变气泡外观：

```dart
decoration: BoxDecoration(
  color: isMe
      ? theme.colorScheme.primary          // 我方气泡颜色
      : theme.colorScheme.surfaceContainerHighest,  // 对方气泡颜色
  borderRadius: BorderRadius.circular(20),  // 圆角
),
```

### 6.2 调整好友列表宽度

宽屏好友列表固定 320px（`view.dart:L131`），可改为百分比宽度或响应式值。

### 6.3 修改时间格式化逻辑

时间格式化函数 `_formatTime` 在 `view.dart:L305-L323`。可根据需求添加更多格式化规则：

```dart
String _formatTime(String time) {
  // 自定义格式化逻辑
}
```

### 6.4 禁用轮询

若不需要自动刷新，注释掉 `_startPolling()` 调用，或设置轮询间隔为更长的时间。