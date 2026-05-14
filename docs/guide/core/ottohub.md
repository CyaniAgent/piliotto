---
date: 2026-05-14 22:28:21
title: ottohub
permalink: /pages/c04e2e
categories:
  - guide
  - core
---
# OttoHub 模块

## 1. 模块概述与架构

OttoHub 模块是 PiliOtto 项目的 API 集成层，负责与 `api.ottohub.cn` 后端服务进行数据交互。该模块采用清晰的分层架构，将 API 请求、数据模型和业务逻辑严格分离。

### 目录结构

```
lib/ottohub/
├── api/
│   ├── models/          # API 响应模型（DTO）
│   │   ├── auth.dart           # 认证相关模型
│   │   ├── base_response.dart  # 通用响应基类
│   │   ├── block.dart          # 拉黑相关模型
│   │   ├── channel.dart        # 频道相关模型
│   │   ├── danmaku.dart        # 弹幕模型
│   │   ├── following.dart      # 关注相关模型
│   │   ├── message.dart        # 消息模型
│   │   ├── moderation.dart     # 审核相关模型
│   │   └── video.dart          # 视频模型
│   └── services/         # API 服务类（静态方法）
│       ├── api_service.dart          # 核心 HTTP 客户端（基于 Dio）
│       ├── auth_service.dart         # 认证服务
│       ├── block_service.dart        # 拉黑服务
│       ├── channel_service.dart      # 频道服务
│       ├── danmaku_service.dart      # 弹幕服务
│       ├── following_service.dart    # 关注服务
│       ├── legacy_api_service.dart   # 旧版 API 兼容层（基于 http 包）
│       ├── message_service.dart      # 消息服务（基于 Legacy 接口）
│       ├── moderation_service.dart   # 审核服务
│       ├── multi_user_service.dart   # 多用户管理（暂未实现）
│       └── video_service.dart        # 视频服务
├── models/              # 领域模型
│   ├── dynamics/
│   │   └── result.dart       # 动态列表模型
│   ├── member/
│   │   ├── archive.dart      # 用户投稿视频模型
│   │   ├── info.dart         # 用户个人信息模型
│   │   └── tags.dart         # 用户标签模型
│   └── video/
│       └── reply/
│           ├── content.dart  # 评论内容模型
│           ├── item.dart     # 评论条目模型
│           └── member.dart   # 评论用户模型
└── repositories/        # Repository 实现（详见 repositories.md）
    ├── ottohub_comment_repository.dart
    ├── ottohub_danmaku_repository.dart
    ├── ottohub_dynamics_repository.dart
    ├── ottohub_message_repository.dart
    ├── ottohub_user_repository.dart
    └── ottohub_video_repository.dart
```

### 架构设计

项目采用三层架构：

1. **API Models 层** - 纯数据传输对象（DTO），定义 API JSON 响应到 Dart 对象的映射
2. **API Services 层** - 静态方法集，封装 HTTP 请求逻辑，调用 `ApiService` / `LegacyApiService` 底层客户端
3. **Repositories 层** - 业务逻辑聚合层，继承 `BaseRepository`，实现对应接口（如 `IVideoRepository`），添加缓存、数据转换等功能

---

## 2. API Services 详解

### 2.1 ApiService（核心 HTTP 客户端）

位于 `api_service.dart`。

- **Base URL**: `https://api.ottohub.cn/api`
- **HTTP 库**: Dio
- **超时**: 连接 30s，接收 60s
- **Token 管理**: 自动在 GET 请求的 query 参数和 POST/PUT/DELETE 请求的 body 中注入 token；支持 `skipToken` 标记跳过
- **错误处理**: 统一的 `ApiException`，提供中文化友好错误提示（连接超时、未授权、服务端错误等）
- **方法**:
  - `request(endpoint, method, body, headers, queryParams, requireToken, skipToken)` - 核心请求方法，返回 `Map<String, dynamic>`
  - `safeRequest(...)` - 安全请求，捕获异常返回 `null` 而不抛出
  - `setToken(token)` / `getToken()` / `clearToken()` - Token 持久化管理（通过 `GStrorage.setting`）

### 2.2 AuthService（认证服务）

位于 `auth_service.dart`。

| 方法 | 端点 | 说明 |
|------|------|------|
| `login(email, password)` | `POST /auth/login` | 邮箱登录，登录成功后自动设置 token |
| `register(email, password, verificationCode)` | `POST /auth/register` | 用户注册 |
| `sendRegisterVerificationCode(email)` | `POST /auth/register/verification-code` | 发送注册验证码 |
| `resetPassword(...)` | `POST /auth/password-reset` | 重置密码 |
| `sendPasswordResetVerificationCode(email)` | `POST /auth/password-reset/verification-code` | 发送密码重置验证码 |
| `signIn()` | `POST /auth/sign-in` | 每日签到 |

### 2.3 VideoService（视频服务）

位于 `video_service.dart`。

| 方法 | 端点 | 说明 |
|------|------|------|
| `getRandomVideos(num)` | `GET /video/random` | 随机视频列表 |
| `getNewVideos(offset, num, type)` | `GET /video/new` | 最新视频列表 |
| `getPopularVideos(timeLimit, offset, num)` | `GET /video/popular` | 热门视频列表 |
| `getCategoryVideos(category, num)` | `GET /video/category/{category}` | 分类视频列表 |
| `searchVideos(...)` | `GET /video/search` | 视频搜索（支持多字段排序） |
| `getVideoDetail(vid)` | `GET /video/{vid}` | 视频详情 |
| `getUserVideos(uid, offset, num)` | `GET /video/user/{uid}` | 用户视频列表 |
| `getRelatedVideos(vid, num, offset)` | `GET /video/related/{vid}` | 相关视频推荐 |
| `getFavoriteVideos(offset, num)` | `GET /video/favorite-list` | 收藏视频列表（需登录） |
| `getManageVideos(offset, num)` | `GET /video/manage-list` | 我的投稿管理 |
| `getHistoryVideos()` | `GET /video/history-list` | 观看历史 |
| `saveWatchHistory(vid, lastWatchSecond)` | `POST /video/watch-history` | 保存观看进度 |
| `toggleFavorite(vid)` | `POST /video/favorite/{vid}` | 收藏/取消收藏 |
| `toggleLike(vid)` | `POST /video/like/{vid}` | 点赞/取消点赞 |
| `deleteVideo(vid)` | `DELETE /video/{vid}` | 删除视频 |
| `submitVideo(...)` | `POST /video/submit` | 投稿视频 |
| `updateVideo(vid, ...)` | `POST /video/update/{vid}` | 更新视频信息 |

### 2.4 ChannelService（频道服务）

位于 `channel_service.dart`。功能最丰富的 Service，涵盖频道的完整 CRUD、成员管理、内容管理、分区管理、公告管理等。

| 类别 | 方法 | 说明 |
|------|------|------|
| 频道 CRUD | `createChannel`、`getChannelDetail`、`updateChannel`、`deleteChannel`、`getChannels`、`searchChannels`、`getMyChannels` | 频道的增删改查与搜索 |
| 成员管理 | `joinChannel`、`getMembers`、`approveMember`、`kickMember`、`leaveChannel`、`setMemberRole`、`getPendingApplications` | 加入、审核、踢出、退出、角色设置 |
| 内容管理 | `getChannelContent`、`addContentToChannel`、`removeContentFromChannel`、`updateContentSection` | 频道内容（视频/动态）的增删查 |
| 关注 | `followChannel`、`unfollowChannel`、`getFollowingChannels` | 频道关注系统 |
| 分区 | `getChannelSections`、`getSectionDetail`、`createSection`、`updateSection`、`deleteSection` | 二级分区管理 |
| 公告 | `createNotice`、`deleteNotice`、`updateNoticeSort`、`getNotices` | 频道公告管理 |
| 黑名单 | `blacklistUser`、`unblacklistUser`、`getBlacklist` | 频道内部拉黑 |
| 时间线 | `getFollowingTimeline`、`getChannelTimeline` | 订阅内容动态聚合 |
| 其他 | `getChannelStats`、`getChannelHistory` | 统计与操作历史 |

### 2.5 FollowingService（关注服务）

位于 `following_service.dart`。

| 方法 | 说明 |
|------|------|
| `followUser(followingUid)` | 关注/取消关注用户 |
| `getFollowStatus(followingUid)` | 查询关注状态 |
| `getFollowingList(uid, offset, num)` | 获取关注列表 |
| `getFansList(uid, offset, num)` | 获取粉丝列表 |
| `getFollowingTimeline(offset, num)` | 获取关注者的动态时间线 |
| `getUserTimeline(uid, offset, num)` | 获取指定用户的时间线 |
| `getActiveFollowers(uid, offset, num)` | 获取活跃关注者 |

### 2.6 BlockService（拉黑服务）

位于 `block_service.dart`。

| 方法 | 说明 |
|------|------|
| `blockUser(blockedId, reason, reasonVisible)` | 拉黑用户 |
| `unblockUser(blockedId)` | 解除拉黑 |
| `getBlockList(page, pageSize)` | 我的拉黑列表 |
| `getBlockedList(page, pageSize)` | 被拉黑列表 |
| `checkBlockStatus(userId)` | 检查双方拉黑状态（含 iBlocked、heBlocked、mutualBlock 等） |

### 2.7 DanmakuService（弹幕服务）

位于 `danmaku_service.dart`。

| 方法 | 说明 |
|------|------|
| `getDanmakus(vid)` | 获取视频弹幕列表（无需登录） |
| `sendDanmaku(vid, text, time, mode, color, fontSize, render)` | 发送弹幕（需登录） |
| `deleteDanmaku(danmakuId)` | 删除弹幕（需登录） |

### 2.8 MessageService（消息服务）

位于 `message_service.dart`。基于 `LegacyApiService`（module: `im`）。

| 方法 | 说明 |
|------|------|
| `getUnreadMessageNum()` | 未读消息数 |
| `getReadMessageList(offset, num)` | 已读消息列表 |
| `getUnreadMessageList(offset, num)` | 未读消息列表 |
| `getSentMessageList(offset, num)` | 已发送消息列表 |
| `sendMessage(receiver, message)` | 发送消息 |
| `readMessage(msgId)` | 读取单条消息 |
| `readAllSystemMessage()` | 系统消息一键已读 |
| `deleteMessage(msgId)` | 删除消息 |
| `getFriendList(offset, num, ifTimeDesc)` | 好友列表 |
| `getFriendMessage(friendUid, offset, num, ifTimeDesc)` | 好友私信记录 |

### 2.9 ModerationService（审核服务）

位于 `moderation_service.dart`。支持 7 种审核类型：视频、动态、头像、封面、弹幕、视频评论、动态评论。

| 操作类别 | 方法模式 |
|----------|----------|
| 获取待审核列表 | `getXxxModerationList(offset, num)` - 7 种 |
| 通过审核 | `approveXxx(id)` - 7 种 |
| 驳回审核 | `rejectXxx(id, reason)` - 7 种 |
| 举报 | `reportXxx(id, reason)` - 7 种 |
| 申诉 | `appealXxx(id, reason)` - 7 种 |
| 日志 | `getModerationLogs(...)`、`getUnreadCount(...)` |

### 2.10 LegacyApiService（旧版 API 兼容层）

位于 `legacy_api_service.dart`。

基于 `package:http` 的 GET 请求实现，使用 `module` + `action` 路由模式（格式：`?module=xxx&action=xxx`）。封装了评论、用户信息、动态、博客、历史记录等旧版接口。

核心方法包括：
- `getVideoComments(vid, parentVcid, offset, num)` - 视频评论列表
- `getBlogCommentList(bid, parentBcid, offset, num)` - 动态评论列表
- `commentVideo(...)` / `deleteVideoComment(...)` - 视频评论操作
- `commentBlog(...)` / `deleteBlogComment(...)` - 动态评论操作
- `getUserDetail(uid)` - 用户详情
- `getNewBlogList(...)` / `getPopularBlogList(...)` - 动态列表
- `likeBlog(...)` / `favoriteBlog(...)` - 动态互动
- `getVideoHistory(...)`、`getFavoriteVideoList(...)` 等个人中心接口

### 2.11 MultiUserService（多用户管理）

位于 `multi_user_service.dart`。**暂未实现**，所有方法抛出 `UnimplementedError`。预留了 `UserAccount` 模型（uid、email、token、avatarUrl 等字段）以及账户列表、添加、切换、刷新 token 等接口。

---

## 3. API Models 详解

### 3.1 BaseResponse 泛型模式

位于 `base_response.dart`。

```dart
class BaseResponse<T> {
  final String status;    // "success" | "error"
  final T? data;          // 泛型数据
  final String? message;  // 错误信息
}

class ListResponse<T> {
  final List<T> list;
  final int? total;
  final int? totalPages;
  final int? page;
  final int? limit;
}
```

所有 API 响应都遵循 `{ status, data, message }` 结构。`ApiService.request()` 会自动检查 `status == 'error'` 并抛出 `ApiException`。

### 3.2 关键模型一览

| 模型文件 | 主要类 | 用途 |
|----------|--------|------|
| `auth.dart` | `LoginResponse`, `SignInResponse` | 登录/签到响应 |
| `video.dart` | `Video`, `VideoListResponse`, `VideoActionResponse`, `VideoSubmitResponse`, `ChannelDetail` | 视频实体与列表 |
| `channel.dart` | `Channel`, `ChannelMember`, `ChannelSection`, `ChannelContent`, `ChannelNotice`, `ContentCount`, `Pagination` | 频道及子实体 |
| `block.dart` | `Block`, `BlockedUser`, `BlockStatus`, `BlockListResponse`, `BlockedListResponse`, `BlockResponse` | 拉黑状态 |
| `following.dart` | `FollowingUser`, `ActiveUser`, `TimelineItem`, `UserListResponse`, `TimelineResponse`, `FollowResponse`, `FollowStatusResponse` | 关注与时间线 |
| `danmaku.dart` | `Danmaku` | 弹幕（danmakuId, text, time, mode, color, fontSize, render） |
| `message.dart` | `Message`, `Friend` | 消息与好友 |
| `moderation.dart` | `VideoModeration`, `BlogModeration`, `AvatarModeration`, `CoverModeration`, `DanmakuModeration`, `VideoCommentModeration`, `BlogCommentModeration`, `ModerationLog`, `LogsResponse`, `UnreadCountResponse` + 各 `XxxList` | 审核与日志 |

### 3.3 Video 模型的特别处理

`Video` 模型使用 `static int toInt(dynamic value)` 辅助方法处理 API 返回中字段类型不一致的问题（int 与 String 混用），覆盖了 vid、uid、likeCount、viewCount 等一系列数值字段。

---

## 4. Domain Models 详解

### 4.1 动态模型（Dynamics）

位于 `dynamics/result.dart`。动态数据结构设计：

- `DynamicsDataModel` - 动态列表顶层容器（hasMore, items, offset）
- `DynamicItemModel` - 单条动态（idStr, modules, type, vid, bid, contentType）
  - 支持从 JSON 或 `fromTimelineItem()` 构造
  - `type` 自动判断：`DYNAMIC_TYPE_DRAW`（有图片）、`DYNAMIC_TYPE_WORD`（纯文字）、`DYNAMIC_TYPE_VIDEO`（视频）
- `ItemModulesModel` - 动态模块集合（moduleAuthor, moduleDynamic, moduleStat）
- `ModuleAuthorModel` - 作者信息（face, mid, name, pubTime）
- `ModuleDynamicModel` - 动态主体（desc: 文字描述, major: 图片/附件）
- `DynamicDescModel` - 文字描述（title, text）
- `DynamicMajorModel` - 主要内容（draw: 图片列表）
- `DynamicDrawItemModel` - 单张图片（src, width, height, size）
- `ModuleStatModel` - 互动数据（comment, forward, like）

### 4.2 成员模型（Member）

#### MemberInfoModel

位于 `member/info.dart`。用户个人主页信息：

- `mid`, `name`, `sex`, `face`, `sign`, `level`
- `isFollowed` - 关注状态
- `topPhoto`, `cover` - 顶部背景图
- `official` - 认证信息
- `vip` - 会员信息（type, status, dueDate, label, nicknameColor）
- `liveRoom` - 直播间信息（roomStatus, liveStatus, url, title, cover, roomId）
- `attention` - 关注数
- `fans` - 粉丝数
- `archiveCount` - 投稿数
- `articleCount` - 动态数

#### Archive Model

位于 `member/archive.dart`。用户投稿视频列表：

- `MemberArchiveDataModel` - 顶层容器
- `ArchiveListModel` - 列表（tlist: 分区统计, vlist: 视频列表）
- `VListItemModel` - 单个视频条目（兼容标准视频字段：aid, bvid, cid 等）
- `Stat` - 播放/弹幕统计
- `Owner` - 上传者信息

#### Tags Model

位于 `member/tags.dart`。`MemberTagItemModel` - 用户标签（count, name, tagid, tip）。

### 4.3 评论模型（Video Reply）

这是评论系统的核心模型，设计参考了标准评论 JSON 结构。

#### ReplyItemModel

位于 `video/reply/item.dart`。

核心字段：`rpid`（评论 ID）、`oid`（目标 ID）、`mid`（评论者）、`root`/`parent`（层级关系）、`like`（点赞数）、`count`（子评论数）、`member`、`content`、`replies`（子评论列表，递归构造）、`isUp`（是否 UP 主）、`isTop`（是否置顶）、`replyControl`（评论控制信息）。

提供两种构造方式：
- `ReplyItemModel.fromJson(json, upperMid)` - 从标准 JSON 构造
- `ReplyItemModel.fromOttohubJson(json)` - 从 OttoHub API 响应构造（bcid 映射到 rpid，uid 映射到 mid 等）

#### ReplyContent

位于 `video/reply/content.dart`。评论内容模型，支持 `@` 提及、表情、图片、投票、富文本和话题。`isText` 字段判断是否为纯文本（决定是否可折叠）。

#### ReplyMember

位于 `video/reply/member.dart`。评论用户信息，包含头像挂件（`Pendant`）、头像框（`UserSailing`）、VIP 信息等。

---

## 5. API 调用流程

### 5.1 新接口调用链

```
Repository（业务聚合 + 缓存）
   │
   ├──> Service（静态方法，参数封装）
   │       │
   │       └──> ApiService.request(endpoint, method, body, ...)
   │               │
   │               ├──> Dio HTTP 请求
   │               ├──> Auto Token 注入（拦截器）
   │               ├──> 检查 status == "error"
   │               └──> 返回 Map<String, dynamic>
   │
   └──> Model.fromJson() 数据转换
```

### 5.2 旧接口调用链（Legacy）

```
Repository
   │
   ├──> Service
   │       │
   │       └──> LegacyApiService.request(module, action, params)
   │               │
   │               ├──> URL: ?module=xxx&action=xxx&...
   │               ├──> http.get()（基于 package:http）
   │               └──> 返回 Map<String, dynamic>
   │
   └──> Model.fromJson() 数据转换
```

### 5.3 Token 管理

- Token 通过 `GStrorage.setting` 持久化存储
- `ApiService` 拦截器自动在 GET 请求 query 和 POST/PUT/DELETE body 中注入 token
- `skipToken: true` 可跳过注入（注册/登录接口）
- `LegacyApiService` 手动从 storage 读取 token 注入

---

## 6. 使用示例

### 6.1 认证服务使用

```dart
import 'package:piliotto/ottohub/api/services/auth_service.dart';

Future<void> login(String email, String password) async {
  try {
    final response = await AuthService.login(
      email: email,
      password: password,
    );
    print('登录成功，用户ID: ${response.uid}');
    print('Token: ${response.token}');
  } catch (e) {
    print('登录失败: $e');
  }
}

Future<void> register(String email, String password, String code) async {
  try {
    await AuthService.register(
      email: email,
      password: password,
      verificationCode: code,
    );
    print('注册成功');
  } catch (e) {
    print('注册失败: $e');
  }
}
```

### 6.2 视频服务使用

```dart
import 'package:piliotto/ottohub/api/services/video_service.dart';

Future<void> loadVideos() async {
  try {
    final randomVideos = await VideoService.getRandomVideos(num: 20);
    print('随机视频: ${randomVideos.videoList.length} 个');
    
    final popularVideos = await VideoService.getPopularVideos(
      timeLimit: 7,
      offset: 0,
      num: 10,
    );
    print('热门视频: ${popularVideos.videoList.length} 个');
    
    final videoDetail = await VideoService.getVideoDetail(12345);
    print('视频标题: ${videoDetail.title}');
  } catch (e) {
    print('请求失败: $e');
  }
}

Future<void> toggleLike(int vid) async {
  try {
    final response = await VideoService.toggleLike(vid: vid);
    print('点赞状态: ${response.status}');
  } catch (e) {
    print('操作失败: $e');
  }
}
```

### 6.3 关注服务使用

```dart
import 'package:piliotto/ottohub/api/services/following_service.dart';

Future<void> followUser(int uid) async {
  try {
    final response = await FollowingService.followUser(followingUid: uid);
    print('关注状态: ${response.status}');
  } catch (e) {
    print('操作失败: $e');
  }
}

Future<void> getFollowingList(int uid) async {
  try {
    final response = await FollowingService.getFollowingList(
      uid: uid,
      offset: 0,
      num: 20,
    );
    print('关注列表: ${response.list.length} 人');
  } catch (e) {
    print('获取失败: $e');
  }
}
```

### 6.4 弹幕服务使用

```dart
import 'package:piliotto/ottohub/api/services/danmaku_service.dart';

Future<void> loadDanmakus(int vid) async {
  try {
    final danmakus = await DanmakuService.getDanmakus(vid);
    print('弹幕数量: ${danmakus.length}');
  } catch (e) {
    print('加载失败: $e');
  }
}

Future<void> sendDanmaku(int vid, String text, double time) async {
  try {
    await DanmakuService.sendDanmaku(
      vid: vid,
      text: text,
      time: time,
      mode: 'scroll',
      color: '16777215',
      fontSize: '25',
      render: '',
    );
    print('弹幕发送成功');
  } catch (e) {
    print('发送失败: $e');
  }
}
```

---

## 7. 开发指南

### 7.1 新接口接入步骤

1. **定义 API Model**：在 `api/models/` 下创建对应的模型类，实现 `fromJson` 工厂方法
2. **创建 Service**：在 `api/services/` 下创建 Service 类，调用 `ApiService.request()` 封装请求，返回数据模型中 `response['data']` 转换
3. **创建 Repository**（可选）：继承 `BaseRepository`，实现对应接口，添加缓存、数据转换逻辑

### 7.2 错误处理

所有 API 调用应使用 try-catch 捕获 `ApiException`：

```dart
try {
  await SomeService.doSomething();
} on ApiException catch (e) {
  // e.message 已经是中文友好提示
  // e.statusCode - HTTP 状态码
  // e.isNetworkError - 是否网络错误
  // e.isTimeout - 是否超时
  showError(e.message);
}
```

不安全抛出的接口可使用 `safeRequest`：

```dart
final result = await ApiService.safeRequest('/some/endpoint');
if (result != null) {
  // 处理成功
} else {
  // 静默失败
}
```

### 7.3 Token 处理

- 需要登录的接口设置 `requireToken: true`
- 登录/注册接口设置 `requireToken: false`
- 需要跳过 Token 注入的设置 `skipToken: true`

### 7.4 数值类型兼容

API 可能返回 int 或 String 类型的数值。参考 `Video.toInt()` 实现兼容转换：

```dart
static int toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) {
    try { return int.parse(value); } catch (e) { return 0; }
  }
  return 0;
}
```

---

## 8. 二改指南

### 8.1 切换后端服务器

修改 `api_service.dart` 中的 `baseUrl` 常量：

```dart
static const String baseUrl = 'https://your-api-server.com';
```

Legacy 接口同样需修改 `legacy_api_service.dart` 中的 URL。

### 8.2 修改 Token 注入逻辑

如需自定义 Token 处理（如改为 JWT Bearer 模式），修改 `ApiService.init()` 中的拦截器：

```dart
_dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) {
    final token = getToken();
    if (token != null && !_shouldSkipToken(options)) {
      // 修改注入方式
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  },
));
```

### 8.3 接入自己的 API 响应格式

如果后端 API 响应结构与 `{ status, data, message }` 不同，需修改两处：

1. `ApiService.request()` 中 `responseData['status'] == 'error'` 的判断逻辑
2. `BaseResponse` 模型的结构

### 8.4 扩展 MultiUserService

`multi_user_service.dart` 目前所有方法抛出 `UnimplementedError`。实现多用户功能需要：

1. 实现账户持久化存储（Hive/SharedPreferences）
2. 实现 `switchAccount(uid)` 切换 token
3. 在多用户场景下管理多个 token 实例

### 8.5 添加新的审核类型

在 `moderation_service.dart` 中参考现有模式：
1. 在 `moderation.dart` 模型中添加对应的 `XxxModeration` 和 `XxxModerationList` 类
2. 在 `ModerationService` 中添加对应的 `getXxxModerationList`、`approveXxx`、`rejectXxx`、`reportXxx`、`appealXxx` 方法

### 8.6 替换 HTTP 库

如要将 Legacy API 从 `package:http` 迁移到 Dio：
1. 修改 `LegacyApiService.request()` 方法，使用 Dio 替代 `http.get()`
2. 注意 Legacy API 的 URL 格式为 `?module=xxx&action=xxx&...`，需在 Dio 的 `queryParameters` 中构造

### 8.7 数据模型字段适配

如果后端返回字段名变更，需要修改各 Model 的 `fromJson` 方法。例如 `ReplyItemModel.fromOttohubJson()` 展示了如何将 OttoHub 的字段（`bcid`、`uid`）映射到评论模型字段（`rpid`、`mid`）。可按此模式添加新的适配方法。