---
date: 2026-05-14 22:09:21
title: repositories
permalink: /pages/3531af
categories:
  - guide
  - core
---
# 仓储层

## 1. 模块概述

PiliOtto 的仓储层（Repository Layer）遵循**接口-实现分离**架构，是 Controller 与 API Service 之间的**桥梁层**。它封装了数据获取逻辑、缓存策略和缓存失效机制，使上层 Controller 无需关心数据来源与缓存细节。

模块由两个子层级组成：

```
lib/repositories/                     # 抽象接口层（6 个接口 + 1 个基类）
├── base_repository.dart              # BaseRepository 抽象基类（缓存引擎）
├── i_video_repository.dart           # IVideoRepository 接口
├── i_user_repository.dart            # IUserRepository 接口
├── i_dynamics_repository.dart        # IDynamicsRepository 接口
├── i_comment_repository.dart         # ICommentRepository 接口
├── i_message_repository.dart         # IMessageRepository 接口
└── i_danmaku_repository.dart         # IDanmakuRepository 接口

lib/ottohub/repositories/             # OttoHub 具体实现层（6 个实现）
├── ottohub_video_repository.dart     # OttohubVideoRepository
├── ottohub_user_repository.dart      # OttohubUserRepository
├── ottohub_dynamics_repository.dart  # OttohubDynamicsRepository
├── ottohub_comment_repository.dart   # OttohubCommentRepository
├── ottohub_message_repository.dart   # OttohubMessageRepository
└── ottohub_danmaku_repository.dart   # OttohubDanmakuRepository
```

### 架构定位

```
┌──────────────────────────────────────────────────────────────┐
│  Pages (View + Controller)                                   │
│    │  Get.find<IVideoRepository>()  ← 注入接口               │
│    ▼                                                         │
│  lib/repositories/  (接口定义)                                │
│    │  implements                                              │
│    ▼                                                         │
│  lib/ottohub/repositories/  (OttoHub 实现)                   │
│    │  extends BaseRepository  (继承缓存能力)                  │
│    │  calls                                                   │
│    ▼                                                         │
│  lib/ottohub/api/services/  (API Service 网络层)              │
└──────────────────────────────────────────────────────────────┘
```

### 核心设计模式

| 模式 | 说明 |
|------|------|
| **接口-实现分离** | `lib/repositories/` 定义抽象接口，`lib/ottohub/repositories/` 提供 OttoHub 具体实现 |
| **依赖注入** | 通过 GetX 的 `Get.put()` / `Get.find()` 注入和获取实例 |
| **模板方法** | `BaseRepository.withCache()` 提供统一的缓存读写模板 |
| **缓存失效** | 写操作（点赞/收藏/删除）自动调用 `invalidateCache()` 清除对应缓存 |

---

## 2. 仓储接口一览

### 2.1 IVideoRepository — 视频仓储

**源文件：** `i_video_repository.dart`

```dart
abstract class IVideoRepository {
  Future<VideoListResponse> getRandomVideos({int num = 20});
  Future<VideoListResponse> getPopularVideos({int timeLimit = 7, int offset = 0, int num = 20});
  Future<VideoListResponse> searchVideos({String? searchTerm, int offset = 0, int num = 20, int vidDesc = 0, int viewCountDesc = 0, int likeCountDesc = 0, int favoriteCountDesc = 0, int? uid, String? type});
  Future<Video> getVideoDetail(int vid, {CacheConfig? cacheConfig});
  Future<VideoListResponse> getRelatedVideos(int vid, {int num = 20, int offset = 0});
  Future<VideoListResponse> getFavoriteVideos({int offset = 0, int num = 20});
  Future<VideoListResponse> getManageVideos({int offset = 0, int num = 20});
  Future<VideoListResponse> getHistoryVideos();
  Future<VideoListResponse> getUserVideos(int uid, {int offset = 0, int num = 20});
  Future<List<VListItemModel>> getUserVideoList({required int uid, int offset = 0, int num = 20});
  Future<VideoActionResponse> toggleLike({required int vid});
  Future<VideoActionResponse> toggleFavorite({required int vid});
  Future<void> saveWatchHistory({required int vid, required int lastWatchSecond});
  Future<void> deleteVideo({required int vid});
}
```

| 方法 | 功能 | 是否缓存 | 写操作失效 |
|------|------|----------|------------|
| `getRandomVideos` | 随机推荐视频列表 | ✅ | — |
| `getPopularVideos` | 热门视频列表（支持时间范围） | ✅ | — |
| `searchVideos` | 视频搜索（多排序维度） | ❌ | — |
| `getVideoDetail` | 视频详情 | ✅ 2分钟 | — |
| `getRelatedVideos` | 相关视频推荐 | ✅ | — |
| `getFavoriteVideos` | 收藏视频列表 | ❌ | — |
| `getManageVideos` | 我的视频管理列表 | ❌ | — |
| `getHistoryVideos` | 观看历史 | ❌ | — |
| `getUserVideos` | 用户投稿列表 | ❌ | — |
| `getUserVideoList` | 用户视频列表（Legacy API） | ❌ | — |
| `toggleLike` | 切换点赞状态 | — | ✅ `getVideoDetail_{vid}` |
| `toggleFavorite` | 切换收藏状态 | — | ✅ `getVideoDetail_{vid}` |
| `saveWatchHistory` | 保存观看历史 | — | — |
| `deleteVideo` | 删除视频 | — | ✅ `getVideoDetail_{vid}` |

### 2.2 IUserRepository — 用户仓储

**源文件：** `i_user_repository.dart`

```dart
class UserProfileInfo {
  final String? coverUrl;
  final int followingCount;
  final int fansCount;
}

abstract class IUserRepository {
  Future<MemberInfoModel> getUserDetail({required int uid, CacheConfig? cacheConfig});
  Future<UserProfileInfo> getUserProfileInfo({required int uid});
  Future<FollowStatusResponse> getFollowStatus({required int followingUid});
  Future<FollowResponse> followUser({required int followingUid});
  Future<UserListResponse> getFollowingList({required int uid, int offset = 0, int num = 20});
  Future<UserListResponse> getFansList({required int uid, int offset = 0, int num = 20});
  Future<BlockResponse> blockUser({required int blockedId, String? reason, int? reasonVisible});
  Future<void> unblockUser({required int blockedId});
}
```

| 方法 | 功能 | 是否缓存 | 写操作失效 |
|------|------|----------|------------|
| `getUserDetail` | 用户详细信息 | ✅ 5分钟 | — |
| `getUserProfileInfo` | 用户资料摘要（封面/关注数/粉丝数） | ❌ | — |
| `getFollowStatus` | 查询是否已关注某用户 | ❌ | — |
| `followUser` | 关注用户 | — | ✅ `getUserDetail_{followingUid}` |
| `getFollowingList` | 我的关注列表 | ❌ | — |
| `getFansList` | 我的粉丝列表 | ❌ | — |
| `blockUser` | 屏蔽用户 | ❌ | — |
| `unblockUser` | 解除屏蔽 | ❌ | — |

### 2.3 IDynamicsRepository — 动态仓储

**源文件：** `i_dynamics_repository.dart`

```dart
abstract class IDynamicsRepository {
  Future<List<DynamicItemModel>> getNewBlogs({int offset = 0, int num = 10});
  Future<List<DynamicItemModel>> getPopularBlogs({int timeLimit = 7, int offset = 0, int num = 10});
  Future<Map<String, dynamic>> getBlogDetail({required int bid, CacheConfig? cacheConfig});
  Future<List<DynamicItemModel>> getRelatedBlogs({required int bid, int offset = 0, int num = 10});
  Future<List<DynamicItemModel>> getUserBlogs({required int uid, int offset = 0, int num = 10});
  Future<Map<String, dynamic>> likeBlog({required int bid});
  Future<Map<String, dynamic>> favoriteBlog({required int bid});
}
```

| 方法 | 功能 | 是否缓存 | 写操作失效 |
|------|------|----------|------------|
| `getNewBlogs` | 最新广场动态 | ❌ | — |
| `getPopularBlogs` | 热门广场动态 | ❌ | — |
| `getBlogDetail` | 动态详情 | ✅ 2分钟 | — |
| `getRelatedBlogs` | 相关动态推荐 | ❌ | — |
| `getUserBlogs` | 用户发布的动态 | ❌ | — |
| `likeBlog` | 点赞动态 | — | ✅ `getBlogDetail_{bid}` |
| `favoriteBlog` | 收藏动态 | — | ✅ `getBlogDetail_{bid}` |

### 2.4 ICommentRepository — 评论仓储

**源文件：** `i_comment_repository.dart`

```dart
class CommentListResult {
  final List<ReplyItemModel> replies;
  final bool hasMore;
}

abstract class ICommentRepository {
  Future<CommentListResult> getVideoComments({required int vid, int parentVcid = 0, int offset = 0, int num = 12});
  Future<List<ReplyItemModel>> getBlogComments({required int bid, int parentBcid = 0, int offset = 0, int num = 12});
  Future<Map<String, dynamic>> commentVideo({required int vid, int parentVcid = 0, required String content});
  Future<Map<String, dynamic>> deleteVideoComment({required int vcid});
  Future<Map<String, dynamic>> commentBlog({required int bid, int parentBcid = 0, required String content});
  Future<Map<String, dynamic>> deleteBlogComment({required int bcid});
}
```

| 方法 | 功能 | 是否缓存 |
|------|------|----------|
| `getVideoComments` | 视频评论列表（支持楼中楼分页） | ❌ |
| `getBlogComments` | 动态评论列表（支持楼中楼分页） | ❌ |
| `commentVideo` | 发表视频评论 | ❌ |
| `deleteVideoComment` | 删除视频评论 | ❌ |
| `commentBlog` | 发表动态评论 | ❌ |
| `deleteBlogComment` | 删除动态评论 | ❌ |

> **注意：** 评论接口均不使用缓存，保证评论数据的实时性。

### 2.5 IMessageRepository — 消息仓储

**源文件：** `i_message_repository.dart`

```dart
abstract class IMessageRepository {
  Future<List<Friend>> getFriendList({int offset = 0, int num = 20, CacheConfig? cacheConfig});
  Future<List<Message>> getFriendMessage({required int friendUid, int offset = 0, int num = 20});
  Future<bool> sendMessage({required int receiver, required String message});
  Future<int> getUnreadMessageNum();
  Future<List<Friend>> getMergedFriendList({required int uid, int offset = 0, int pageSize = 20});
}
```

| 方法 | 功能 | 是否缓存 | 写操作失效 |
|------|------|----------|------------|
| `getFriendList` | 私信好友列表 | ✅ 1分钟 | — |
| `getFriendMessage` | 与好友的聊天记录 | ❌ | — |
| `sendMessage` | 发送私信 | — | ✅ `getFriendList` |
| `getUnreadMessageNum` | 未读消息数 | ❌ | — |
| `getMergedFriendList` | 合并私信好友与关注好友列表 | ❌ | — |

### 2.6 IDanmakuRepository — 弹幕仓储

**源文件：** `i_danmaku_repository.dart`

```dart
abstract class IDanmakuRepository {
  Future<List<Danmaku>> getDanmakus(int vid, {CacheConfig? cacheConfig});
  Future<void> sendDanmaku({required dynamic vid, required String text, required dynamic time, required String mode, required String color, required String fontSize, required String render});
  Future<void> deleteDanmaku({required int danmakuId});
}
```

| 方法 | 功能 | 是否缓存 | 写操作失效 |
|------|------|----------|------------|
| `getDanmakus` | 获取视频弹幕列表 | ✅ 5分钟 | — |
| `sendDanmaku` | 发送弹幕 | — | ✅ `getDanmakus_{vid}` |
| `deleteDanmaku` | 删除弹幕 | ❌ | — |

---

## 3. BaseRepository 详解

**源文件：** `base_repository.dart`

`BaseRepository` 是所有仓储实现的抽象基类，提供**内存缓存引擎**和**缓存配置**能力。所有 OttoHub 仓储实现都通过 `extends BaseRepository` 继承缓存机制。

### 3.1 CacheConfig — 缓存配置

```dart
class CacheConfig {
  final bool enabled;        // 是否启用缓存，默认 true
  final Duration duration;   // 缓存有效期，默认 5 分钟
  const CacheConfig({
    this.enabled = true,
    this.duration = const Duration(minutes: 5),
  });
}
```

**使用场景：**

```dart
// 场景1：使用默认缓存策略（enabled=true, 5分钟）
getVideoDetail(123);

// 场景2：自定义缓存时长（2分钟）
getVideoDetail(123, cacheConfig: const CacheConfig(duration: Duration(minutes: 2)));

// 场景3：强制刷新（禁用缓存）
getVideoDetail(123, cacheConfig: const CacheConfig(enabled: false));

// 场景4：延长缓存（10分钟）
getUserDetail(uid: 456, cacheConfig: const CacheConfig(duration: Duration(minutes: 10)));
```

### 3.2 withCache — 缓存模板方法

```dart
Future<T> withCache<T>(
  String key,
  Future<T> Function() fetch, {
  CacheConfig? cacheConfig,
}) async
```

**执行流程：**

```
                    ┌──────────────┐
                    │  withCache()  │
                    └──────┬───────┘
                           │
                    ┌──────▼───────┐
                    │ cacheConfig  │
                    │  != null     │──No──▶ 直接 fetch() 并返回
                    │  && enabled  │
                    └──────┬───────┘
                       Yes │
                    ┌──────▼───────┐
                    │ _cache[key]  │
                    │ 存在且未过期  │──Yes──▶ 返回缓存数据
                    └──────┬───────┘
                       No  │
                    ┌──────▼───────┐
                    │  await       │
                    │  fetch()     │
                    └──────┬───────┘
                           │
                    ┌──────▼───────┐
                    │ 写入 _cache  │
                    │ 设置过期时间  │
                    └──────┬───────┘
                           │
                    ┌──────▼───────┐
                    │ 返回结果     │
                    └──────────────┘
```

### 3.3 缓存失效方法

```dart
void invalidateCache(String key);    // 清除单个 key 的缓存
void invalidateAllCache();           // 清除所有缓存
```

**典型用法——写操作后自动失效读缓存：**

```dart
// 点赞后失效视频详情缓存，下次 getVideoDetail 会重新请求
@override
Future<VideoActionResponse> toggleLike({required int vid}) {
  invalidateCache('getVideoDetail_$vid');  // 先失效，再请求
  return VideoService.toggleLike(vid: vid);
}
```

### 3.4 缓存 Key 命名约定

| key 格式 | 示例 | 说明 |
|----------|------|------|
| `get{Method}_{id}` | `getVideoDetail_123` | 按 ID 区分 |
| `get{Method}_{id}_{offset}` | `getRelatedVideos_123_0` | 按 ID + 分页区分 |
| `get{Method}_{param}_{offset}` | `getPopularVideos_7_0` | 按参数 + 分页区分 |
| `get{Method}_{offset}` | `getFriendList_0` | 仅按分页区分 |
| `get{Method}` | `getRandomVideos` | 无参数方法 |

---

## 4. OttoHub 实现详解

### 4.1 OttohubVideoRepository

**源文件：** `ottohub_video_repository.dart`

```dart
class OttohubVideoRepository extends BaseRepository implements IVideoRepository
```

**依赖的 API Service：**
- `VideoService` — 视频 CRUD、搜索、点赞、收藏、观看历史
- `LegacyApiService` — 用户视频列表（`getUserVideoList`）

**缓存策略：**
| 方法 | 缓存 Key | 默认 TTL | 可外部覆盖 |
|------|----------|----------|------------|
| `getRandomVideos` | `getRandomVideos` | 5分钟（默认） | ✅ |
| `getPopularVideos` | `getPopularVideos_{timeLimit}_{offset}` | 5分钟（默认） | ❌ |
| `getVideoDetail` | `getVideoDetail_{vid}` | **2分钟** | ✅ `cacheConfig` |
| `getRelatedVideos` | `getRelatedVideos_{vid}_{offset}` | 5分钟（默认） | ❌ |

**未被缓存的方法：** `searchVideos`、`getFavoriteVideos`、`getManageVideos`、`getHistoryVideos`、`getUserVideos`、`getUserVideoList`

**写操作失效策略：**
- `toggleLike(vid)` → 失效 `getVideoDetail_{vid}`
- `toggleFavorite(vid)` → 失效 `getVideoDetail_{vid}`
- `deleteVideo(vid)` → 失效 `getVideoDetail_{vid}`

**特殊实现 — getUserVideoList：**

该方法未使用 `VideoService`，而是通过 `LegacyApiService` 调用旧版 API，并手动进行 JSON → Model 转换：

```dart
Future<List<VListItemModel>> getUserVideoList({required int uid, int offset = 0, int num = 20}) async {
  final res = await LegacyApiService.getUserVideoList(uid: uid, offset: offset, num: num);
  if (res['status'] == 'success') {
    final List<dynamic> videoList = res['video_list'] as List;
    return videoList.map((v) => VListItemModel.fromJson(v)).toList();
  }
  throw Exception(res['message'] ?? '获取用户视频失败');
}
```

### 4.2 OttohubUserRepository

**源文件：** `ottohub_user_repository.dart`

```dart
class OttohubUserRepository extends BaseRepository implements IUserRepository
```

**依赖的 API Service：**
- `LegacyApiService` — 用户详情（`getUserDetail`）
- `FollowingService` — 关注状态、关注/取关操作、关注/粉丝列表
- `BlockService` — 屏蔽/解屏蔽操作

**缓存策略：**
| 方法 | 缓存 Key | 默认 TTL |
|------|----------|----------|
| `getUserDetail` | `getUserDetail_{uid}` | **5分钟** |

**特殊实现 — getUserDetail：**

该方法从 `LegacyApiService` 获取原始 JSON，手动构建 `MemberInfoModel`：

```dart
Future<MemberInfoModel> getUserDetail({required int uid, CacheConfig? cacheConfig}) async {
  return withCache('getUserDetail_$uid', () async {
    final res = await LegacyApiService.getUserDetail(uid: uid);
    if (res['status'] == 'success') {
      return MemberInfoModel(
        mid: int.tryParse(res['uid'].toString()) ?? 0,
        name: res['username']?.toString() ?? '',
        sign: res['intro']?.toString() ?? '',
        face: res['avatar_url']?.toString() ?? '',
        cover: res['cover_url']?.toString() ?? '',
        sex: res['sex']?.toString() ?? '',
        fans: int.tryParse(res['fans_count'].toString()) ?? 0,
        attention: int.tryParse(res['followings_count'].toString()) ?? 0,
        archiveCount: int.tryParse(res['video_num'].toString()) ?? 0,
        articleCount: int.tryParse(res['blog_num'].toString()) ?? 0,
      );
    }
    throw Exception(res['message'] ?? '获取用户信息失败');
  }, cacheConfig: cacheConfig ?? const CacheConfig(duration: Duration(minutes: 5)));
}
```

**写操作失效策略：**
- `followUser(followingUid)` → 失效 `getUserDetail_{followingUid}`，确保关注后用户详情刷新

### 4.3 OttohubDynamicsRepository

**源文件：** `ottohub_dynamics_repository.dart`

```dart
class OttohubDynamicsRepository extends BaseRepository implements IDynamicsRepository
```

**依赖的 API Service：** 全部通过 `LegacyApiService`

**缓存策略：**
| 方法 | 缓存 Key | 默认 TTL |
|------|----------|----------|
| `getBlogDetail` | `getBlogDetail_{bid}` | **2分钟** |

**未被缓存的方法：** `getNewBlogs`、`getPopularBlogs`、`getRelatedBlogs`、`getUserBlogs`

**写操作失效策略：**
- `likeBlog(bid)` → 失效 `getBlogDetail_{bid}`
- `favoriteBlog(bid)` → 失效 `getBlogDetail_{bid}`

**统一的数据处理模式：**

所有列表类方法遵循相同的处理模式：

```dart
final res = await LegacyApiService.getXxxList(...);
if (res['status'] == 'success') {
  final List<dynamic> list = res['xxx_list'] as List;
  return list.map((item) => DynamicItemModel.fromJson(item)).toList();
}
throw Exception(res['message'] ?? '获取失败');
```

### 4.4 OttohubCommentRepository

**源文件：** `ottohub_comment_repository.dart`

```dart
class OttohubCommentRepository extends BaseRepository implements ICommentRepository
```

**依赖的 API Service：** 全部通过 `LegacyApiService`

**不使用缓存** — 评论数据要求实时性，所有方法直接调用 API。

**核心方法 — getVideoComments：**

返回 `CommentListResult`，包含评论列表与 `hasMore` 分页标识：

```dart
Future<CommentListResult> getVideoComments({required int vid, int parentVcid = 0, ...}) async {
  final response = await LegacyApiService.getVideoComments(vid: vid, ...);
  if (response['status'] == 'success') {
    final replies = comments.map((comment) =>
      _convertCommentToReplyItemModel(comment, oid: vid, includeChildPreview: parentVcid == 0)
    ).toList();
    return CommentListResult(replies: replies, hasMore: replies.length >= num);
  }
  throw Exception(response['message'] ?? '获取评论失败');
}
```

**内部转换器 — `_convertCommentToReplyItemModel`：**

该私有方法将 OttoHub 原始评论 JSON 转换为统一的 `ReplyItemModel`：
- 构建 `ReplyMember`（用户信息、头像、等级、VIP状态）
- 构建 `ReplyContent`（评论文本、@提及、表情、图片）
- 递归构建子回复预览（最多 3 条）
- 构建 `ReplyControl`（回复入口文本、时间、位置）

**视频评论 vs 动态评论：**

| | 视频评论 | 动态评论 |
|---|---|---|
| 方法 | `getVideoComments` | `getBlogComments` |
| 返回类型 | `CommentListResult`（含 `hasMore`） | `List<ReplyItemModel>` |
| 内部转换 | `_convertCommentToReplyItemModel` | `ReplyItemModel.fromOttohubJson` |

### 4.5 OttohubMessageRepository

**源文件：** `ottohub_message_repository.dart`

```dart
class OttohubMessageRepository extends BaseRepository implements IMessageRepository
```

**依赖的 API Service：**
- `MessageService` — 好友列表、聊天记录、发送消息、未读计数
- `LegacyApiService` — 关注列表（用于 `getMergedFriendList` 合并）

**缓存策略：**
| 方法 | 缓存 Key | 默认 TTL |
|------|----------|----------|
| `getFriendList` | `getFriendList_{offset}` | **1分钟** |

**写操作失效策略：**
- `sendMessage` → 失效 `getFriendList`（发送消息后好友列表可能变化）

**核心方法 — getMergedFriendList：**

该方法是 `OttohubMessageRepository` 最复杂的实现，通过 `Future.wait` 并行合并两个数据源：

```
getMergedFriendList(uid)
  │
  ├─▶ _getFollowingFriends(uid, offset)     // LegacyApiService 获取关注列表
  │     └─ 转换为 Friend 列表（无 lastTime）
  │
  └─▶ MessageService.getFriendList(offset)  // 私信好友列表（有 lastTime）
        └─ 包含最近聊天时间
  │
  └─▶ Future.wait 并行等待两个结果

合并逻辑：
  1. 以 messageFriends 为主（私信列表已包含 lastTime）
  2. 将 followingFriends 中不在私信列表的好友追加到结果
  3. 按 lastTime 降序排序（有聊天记录的排前面）
```

### 4.6 OttohubDanmakuRepository

**源文件：** `ottohub_danmaku_repository.dart`

```dart
class OttohubDanmakuRepository extends BaseRepository implements IDanmakuRepository
```

**依赖的 API Service：** 全部通过 `DanmakuService`

**缓存策略：**
| 方法 | 缓存 Key | 默认 TTL |
|------|----------|----------|
| `getDanmakus` | `getDanmakus_{vid}` | **5分钟** |

**写操作失效策略：**
- `sendDanmaku(vid)` → 失效 `getDanmakus_{vid}`，确保发送弹幕后弹幕列表实时刷新

---

## 5. 依赖注入机制

### 5.1 注册（main.dart 启动时）

**源文件：** `main.dart:L72-L77`

```dart
Get.put<IVideoRepository>(OttohubVideoRepository());
Get.put<IUserRepository>(OttohubUserRepository());
Get.put<IDynamicsRepository>(OttohubDynamicsRepository());
Get.put<ICommentRepository>(OttohubCommentRepository());
Get.put<IMessageRepository>(OttohubMessageRepository());
Get.put<IDanmakuRepository>(OttohubDanmakuRepository());
```

- 使用 **接口类型** 注册（`Get.put<IVideoRepository>()`），而非具体实现类型
- 注册的是 **具体实现实例**（`OttohubVideoRepository()`）
- 在 `main()` 中 `runApp()` 之前完成注册

### 5.2 消费（Controller / Widget 中使用）

**模式一：Controller 成员变量注入（推荐）**

```dart
// lib/pages/video/detail/controller.dart
final IVideoRepository _videoRepo = Get.find<IVideoRepository>();
final IDanmakuRepository _danmakuRepo = Get.find<IDanmakuRepository>();
```

**模式二：Widget 中直接使用（临时调用）**

```dart
// lib/pages/video/detail/widgets/header_control.dart
await Get.find<IDanmakuRepository>().sendDanmaku(...);
```

### 5.3 使用分布

| 接口 | 使用页面（Controller/Widget） |
|------|------------------------------|
| `IVideoRepository` | `home`、`rcmd`、`hot`、`rank`、`search`、`history`、`fav`、`fav_detail`、`media`、`member`、`member_archive`、`video/detail`、`video/detail/introduction`、`video/detail/related` |
| `IUserRepository` | `mine`、`member`、`follow`、`fan`、`video/detail/introduction`、`video_card_v`、`video_card_h` |
| `IDynamicsRepository` | `dynamics`、`member_dynamics`、`dynamics/widgets/action_panel` |
| `ICommentRepository` | `video/detail/reply`、`video/detail/reply_reply`、`video/detail/reply_new`、`dynamics/detail`、`dynamics/widgets/flat_reply_item`、`dynamics/widgets/blog_comment_input` |
| `IMessageRepository` | `message`、`message_list`、`whisper_detail` |
| `IDanmakuRepository` | `video/detail`、`video/detail/widgets/header_control` |

---

## 6. 数据流图

### 6.1 完整请求链路

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Controller                                  │
│  _videoRepo.getVideoDetail(123)                                     │
│  _videoRepo = Get.find<IVideoRepository>()                          │
└────────────────────────────────┬────────────────────────────────────┘
                                 │ 调用接口方法
                                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    OttohubVideoRepository                           │
│  extends BaseRepository implements IVideoRepository                 │
│                                                                     │
│  Future<Video> getVideoDetail(int vid, {CacheConfig? cc}) {         │
│    return withCache(                                                │
│      'getVideoDetail_$vid',          ◀─ ① 生成缓存 Key              │
│      () => VideoService.getVideoDetail(vid), ◀─ ② 定义数据获取函数   │
│      cacheConfig: cc ?? CacheConfig(duration: Duration(minutes: 2)),│
│    );                                                               │
│  }                                                                  │
└────────────────────────────────┬────────────────────────────────────┘
                                 │ withCache 内部逻辑
                                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        BaseRepository                               │
│                                                                     │
│  ① 检查 cacheConfig 是否为 null/enabled=true                        │
│  ② 查找 _cache['getVideoDetail_123']                                │
│  ③ 如果命中且未过期 → 直接返回缓存数据                               │
│  ④ 如果未命中 → await fetch() → VideoService.getVideoDetail(123)    │
│  ⑤ 写入 _cache['getVideoDetail_123'] = _CacheEntry(data, expiresAt) │
│  ⑥ 返回数据给调用方                                                  │
└────────────────────────────────┬────────────────────────────────────┘
                                 │ await fetch()
                                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│                       VideoService                                  │
│  HTTP Request → OttoHub API Server → JSON Response                  │
└─────────────────────────────────────────────────────────────────────┘
```

### 6.2 写操作 + 缓存失效流程

```
┌──────────────────────────────┐
│  用户点击❤️点赞按钮           │
└─────────────┬────────────────┘
              ▼
┌──────────────────────────────┐
│  Controller                  │
│  await _videoRepo.toggleLike(vid: 123)  │
└─────────────┬────────────────┘
              ▼
┌──────────────────────────────────────────────────────────┐
│  OttohubVideoRepository.toggleLike(vid)                  │
│                                                          │
│  ① invalidateCache('getVideoDetail_123')  ◀─ 失效缓存   │
│  ② await VideoService.toggleLike(vid: 123) ◀─ 发送请求   │
└──────────────────────────────────────────────────────────┘
              │
              ▼ 下次访问
┌──────────────────────────────────────────────────────────┐
│  getVideoDetail(123)                                     │
│  → _cache['getVideoDetail_123'] 不存在                   │
│  → 重新 fetch() → 获取最新数据（含更新后的点赞状态）      │
└──────────────────────────────────────────────────────────┘
```

---

## 7. 使用示例

### 7.1 视频仓储基本使用

```dart
import 'package:get/get.dart';
import 'package:piliotto/repositories/i_video_repository.dart';

class VideoListController extends GetxController {
  final IVideoRepository _videoRepo = Get.find<IVideoRepository>();
  
  final RxList videos = [].obs;
  final RxBool isLoading = false.obs;
  
  Future<void> loadRandomVideos() async {
    isLoading.value = true;
    try {
      final response = await _videoRepo.getRandomVideos(num: 20);
      videos.value = response.videoList;
    } catch (e) {
      print('加载失败: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> loadVideoDetail(int vid) async {
    try {
      final video = await _videoRepo.getVideoDetail(
        vid,
        cacheConfig: const CacheConfig(duration: Duration(minutes: 2)),
      );
      print('视频标题: ${video.title}');
    } catch (e) {
      print('获取详情失败: $e');
    }
  }
}
```

### 7.2 用户仓储操作

```dart
import 'package:get/get.dart';
import 'package:piliotto/repositories/i_user_repository.dart';

class UserController extends GetxController {
  final IUserRepository _userRepo = Get.find<IUserRepository>();
  
  Future<void> followUser(int uid) async {
    try {
      final response = await _userRepo.followUser(followingUid: uid);
      if (response.status == 'followed') {
        print('关注成功');
      } else {
        print('已取消关注');
      }
    } catch (e) {
      print('操作失败: $e');
    }
  }
  
  Future<void> getUserInfo(int uid) async {
    try {
      final user = await _userRepo.getUserDetail(
        uid: uid,
        cacheConfig: const CacheConfig(duration: Duration(minutes: 5)),
      );
      print('用户名: ${user.name}');
      print('粉丝数: ${user.fans}');
      print('投稿数: ${user.archiveCount}');
    } catch (e) {
      print('获取用户信息失败: $e');
    }
  }
}
```

### 7.3 评论仓储使用

```dart
import 'package:get/get.dart';
import 'package:piliotto/repositories/i_comment_repository.dart';

class CommentController extends GetxController {
  final ICommentRepository _commentRepo = Get.find<ICommentRepository>();
  
  Future<void> loadComments(int vid) async {
    try {
      final result = await _commentRepo.getVideoComments(
        vid: vid,
        offset: 0,
        num: 12,
      );
      print('评论数: ${result.replies.length}');
      print('还有更多: ${result.hasMore}');
    } catch (e) {
      print('加载评论失败: $e');
    }
  }
  
  Future<void> sendComment(int vid, String content) async {
    try {
      await _commentRepo.commentVideo(
        vid: vid,
        content: content,
      );
      print('评论发送成功');
    } catch (e) {
      print('评论发送失败: $e');
    }
  }
}
```

### 7.4 弹幕仓储使用

```dart
import 'package:get/get.dart';
import 'package:piliotto/repositories/i_danmaku_repository.dart';

class DanmakuController extends GetxController {
  final IDanmakuRepository _danmakuRepo = Get.find<IDanmakuRepository>();
  
  Future<void> loadDanmakus(int vid) async {
    try {
      final danmakus = await _danmakuRepo.getDanmakus(
        vid,
        cacheConfig: const CacheConfig(duration: Duration(minutes: 5)),
      );
      print('弹幕数量: ${danmakus.length}');
    } catch (e) {
      print('加载弹幕失败: $e');
    }
  }
  
  Future<void> sendDanmaku(int vid, String text, double time) async {
    try {
      await _danmakuRepo.sendDanmaku(
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
      print('弹幕发送失败: $e');
    }
  }
}
```

---

## 8. 开发指南 — 如何新增仓储

### 步骤 1：定义接口

在 `lib/repositories/` 下创建 `i_xxx_repository.dart`：

```dart
// lib/repositories/i_search_repository.dart
import 'base_repository.dart';

abstract class ISearchRepository {
  Future<List<SearchResult>> searchAll(String keyword, {int offset = 0, int num = 20});
  Future<List<SearchSuggestion>> getSuggestions(String keyword);
}
```

### 步骤 2：实现具体类

在 `lib/ottohub/repositories/` 下创建 `ottohub_search_repository.dart`：

```dart
// lib/ottohub/repositories/ottohub_search_repository.dart
import '../api/services/legacy_api_service.dart';
import 'package:piliotto/repositories/base_repository.dart';
import 'package:piliotto/repositories/i_search_repository.dart';

class OttohubSearchRepository extends BaseRepository implements ISearchRepository {
  @override
  Future<List<SearchResult>> searchAll(String keyword, {int offset = 0, int num = 20}) {
    // 搜索不需要缓存
    return LegacyApiService.searchAll(keyword, offset: offset, num: num);
  }

  @override
  Future<List<SearchSuggestion>> getSuggestions(String keyword) {
    // 搜索建议可缓存 10 分钟
    return withCache(
      'getSuggestions_$keyword',
      () => LegacyApiService.getSuggestions(keyword),
      cacheConfig: const CacheConfig(duration: Duration(minutes: 10)),
    );
  }
}
```

### 步骤 3：注册依赖注入

在 `lib/main.dart` 中添加：

```dart
Get.put<ISearchRepository>(OttohubSearchRepository());
```

### 步骤 4：Controller 中使用

```dart
class SearchController extends GetxController {
  final ISearchRepository _searchRepo = Get.find<ISearchRepository>();
  // ...
}
```

### 缓存使用决策指南

| 场景 | 建议 |
|------|------|
| 数据变化不频繁（用户信息、视频详情） | 使用 `withCache`，设置合适 TTL |
| 数据实时性要求高（评论、消息内容） | 不使用缓存，直接调用 API |
| 搜索结果 | 不使用缓存（每次搜索条件不同） |
| 热门/推荐列表 | 短期缓存（1-2分钟），减少重复请求 |
| 写操作（点赞、发送） | 调用 API + 失效相关读缓存 |

---

## 9. 二改指南 — 如何替换数据源

PiliOtto 当前数据源为 **OttoHub**（自建社区后端）。如果要替换为其他数据源（其他自建服务器等），只需：

### 9.1 创建新的实现类

以替换 `IVideoRepository` 为例，在 `lib/new_source/repositories/` 下创建：

```dart
// lib/new_source/repositories/new_source_video_repository.dart
import 'package:piliotto/repositories/base_repository.dart';
import 'package:piliotto/repositories/i_video_repository.dart';

class NewSourceVideoRepository extends BaseRepository implements IVideoRepository {
  @override
  Future<VideoListResponse> getRandomVideos({int num = 20}) {
    return withCache('getRandomVideos', () => NewSourceApi.getRandomVideos(num: num));
  }

  @override
  Future<Video> getVideoDetail(int vid, {CacheConfig? cacheConfig}) {
    return withCache(
      'getVideoDetail_$vid',
      () => NewSourceApi.getVideoDetail(vid),
      cacheConfig: cacheConfig ?? const CacheConfig(duration: Duration(minutes: 2)),
    );
  }

  // ... 实现其余方法
}
```

### 9.2 切换注册

只需修改 `lib/main.dart` 中的 `Get.put` 一行：

```dart
// 替换前
Get.put<IVideoRepository>(OttohubVideoRepository());

// 替换后
Get.put<IVideoRepository>(NewSourceVideoRepository());
```

### 9.3 零改动原则

由于所有 Controller 通过接口类型 `Get.find<IVideoRepository>()` 获取实例，切换数据源后 **Controller 代码无需任何修改**。整个切换过程仅需：

1. 新建实现类实现对应接口
2. 修改 `main.dart` 中的 `Get.put` 注册
3. 确保新 API Service 返回的 Model 类型与接口签名一致

这种架构设计保证了**数据源的可插拔性**，是 Repository 模式的核心价值。