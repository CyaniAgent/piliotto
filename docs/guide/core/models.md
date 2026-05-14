---
date: 2026-05-14 22:02:13
title: models
permalink: /pages/32b639
categories:
  - guide
  - core
---
# 数据模型层

## 1. 模块概述

PiliOtto 的数据模型层（Models Layer）位于 `lib/models/`，负责定义项目中所有数据结构、枚举和 JSON 序列化逻辑。模型层是数据流的**基础构件**，贯穿 Controller → Repository → API Service 的整个数据链路。

模型层由三个子层级组成：

```
lib/models/              # 通用业务模型
├── common/              # 通用枚举和配置模型
├── fans/                # 粉丝相关模型
├── follow/              # 关注相关模型
├── github/              # GitHub 发布检查模型
├── user/                # 用户相关模型
└── video/               # 视频相关模型（播放、画质、URL）

lib/ottohub/models/      # OttoHub 领域模型（自建社区接口）
├── dynamics/            # 动态/广场内容模型
├── member/              # 成员/用户模型
└── video/reply/         # 评论与回复模型

lib/ottohub/api/models/  # OttoHub API 响应模型（RESTful 接口封装）
├── auth.dart            # 认证相关模型
├── base_response.dart   # 通用响应基类
├── block.dart           # 屏蔽/黑名单模型
├── channel.dart         # 频道/分区模型
├── danmaku.dart         # 弹幕模型
├── following.dart       # 关注/时间线模型
├── message.dart         # 私信/消息模型
├── moderation.dart      # 审核/举报模型
└── video.dart           # 视频模型（上传、操作反馈）
```

### 架构定位

```
┌──────────────────────────────────────────────────┐
│  Pages (View + Controller)                       │
│    ↓ 引用                                        │
│  Repositories (接口)  →  Repositories (实现)     │
│    ↓ 引用              →    ↓ 调用               │
│  Models (数据模型)         API Services (网络)    │
│    ↑ 反序列化                   ↓ JSON           │
│  API JSON / Hive 本地存储                         │
└──────────────────────────────────────────────────┘
```

### JSON 序列化策略

本项目**不使用** `json_serializable` 等代码生成方案，所有模型类均采用**手动 JSON 序列化**：

- 每个模型类提供 `类名.fromJson(Map<String, dynamic> json)` 工厂构造函数用于反序列化
- 部分模型类提供 `Map<String, dynamic> toJson()` 实例方法用于序列化
- 枚举类通过 `extension` 扩展提供 `code`、`description` 等衍生属性
- 部分模型（如 `UserInfoData`）同时实现了 `Hive TypeAdapter` 以支持本地存储

---

## 2. 完整模型清单

### 2.1 `lib/models/common/` — 通用枚举与配置模型

| 文件 | 核心类型 | 类型 | 说明 |
|------|---------|------|------|
| `action_type.dart` | `ActionType` | `enum` | 视频操作类型枚举：`like`（点赞）、`coin`（投币）、`collect`（收藏）、`watchLater`（稍后再看）、`share`（分享）、`dislike`（不喜欢）、`downloadCover`（下载封面）、`copyLink`（复制链接），附带 `actionMenuConfig` 菜单配置列表 |
| `business_type.dart` | `BusinessType` | `enum` | 业务类型：`archive`（普通视频）、`pgc`（番剧/影视）、`live`（直播）、`article`（文章），附带 `type` 标签和 `hiddenDurationType`/`showBadge` 属性 |
| `color_type.dart` | `colorThemeTypes` | `List<Map>` | 主题色配置列表，含 19 种预定义色值（从默认绿到灰色），每项包含 `color`（`Color` 对象）和 `label`（中文标签） |
| `theme_type.dart` | `ThemeType` | `enum` | 主题模式：`light`（浅色）、`dark`（深色）、`system`（跟随系统），附带 `description` 和 `code` |
| `tab_type.dart` | `TabType` | `enum` | 首页 Tab 类型：`rcmd`（推荐）、`hot`（热门），附带 `tabsConfig` 配置列表 |
| `rank_type.dart` | `RandType` | `enum` | 排行榜分区类型：15 个分区（全站、动画、音乐、舞蹈、游戏、知识、科技、运动、汽车、美食、动物圈、鬼畜、时尚、娱乐、影视），附带 `description`、`id` 和 `tabsConfig` 配置 |
| `rcmd_type.dart` | `RcmdType` | `enum` | 首页推荐来源类型：`web`（web端）、`app`（app端）、`notLogin`（游客模式） |
| `dynamics_type.dart` | `DynamicsType` | `enum` | 动态分类筛选：`all`（全部）、`video`（投稿）、`pgc`（番剧）、`article`（专栏） |
| `dynamic_badge_mode.dart` | `DynamicBadgeMode` | `enum` | 动态角标模式：`hidden`（隐藏）、`point`（红点）、`number`（数字），附带 `description` 和 `code` |
| `gesture_mode.dart` | `FullScreenGestureMode` | `enum` | 全屏手势方向：`fromToptoBottom`（从上往下滑）、`fromBottomtoTop`（从下往上滑） |
| `reply_type.dart` | `ReplyType` | `enum` | 评论来源类型：24 个枚举值，涵盖 `video`（视频）、`topic`（话题）、`activity`（活动）、`dynamics`（动态）、`course`（课程）等场景 |
| `reply_sort_type.dart` | `ReplySortType` | `enum` | 评论排序方式：`time`（最新评论）、`like`（最热评论） |
| `nav_bar_config.dart` | `defaultNavigationBars` | `List` | 底部导航栏配置：首页、动态、我的三个 Tab 的图标与页面定义 |
| `video_episode_type.dart` | `VideoEpidoesType` | `enum` | 视频分集类型：`videoEpisode`（视频合辑）、`videoPart`（视频分P）、`bangumiEpisode`（番剧剧集） |
| `index.dart` | — | `library` | 统一导出 `BusinessType` 和 `FullScreenGestureMode` |

### 2.2 `lib/models/user/` — 用户相关模型

| 文件 | 核心类 | 说明 |
|------|-------|------|
| `info.dart` | `UserInfoData`、`LevelInfo` | 登录用户完整信息，含 VIP、钱包、等级等字段，同时实现 `Hive TypeAdapter`（typeId=4/5）用于本地持久化 |
| `stat.dart` | `UserStat` | 用户统计信息：`following`（关注数）、`follower`（粉丝数）、`dynamicCount`（动态数） |
| `fav_folder.dart` | `FavFolderData`、`FavFolderItemData`、`Upper` | 收藏夹列表与详情，含封面上传者信息 |
| `history.dart` | `HistoryData`、`Cursor`、`HisTabItem`、`HisListItem`、`History` | 观看历史记录，含分页游标、Tab 分类、视频条目详情 |

### 2.3 `lib/models/fans/` 与 `lib/models/follow/` — 粉丝与关注模型

| 文件 | 核心类 | 说明 |
|------|-------|------|
| `fans/result.dart` | `FansDataModel`、`FansItemModel` | 粉丝列表：`total`（总数）+ `list`（列表，含 `mid`、`uname`、`face`、`sign`、认证信息） |
| `follow/result.dart` | `FollowDataModel`、`FollowItemModel` | 关注列表：结构与粉丝列表高度一致 |

### 2.4 `lib/models/video/` — 视频相关模型

| 文件 | 核心类 | 说明 |
|------|-------|------|
| `video/play/quality.dart` | `VideoQuality`、`AudioQuality`、`VideoDecodeFormats` | 视频画质（12 级：240P ~ 8K）、音频质量（5 级：64K ~ Hi-Res）、解码格式（DVH1/AV1/HEVC/AVC），附带 code ↔ description 双向映射 |
| `video/play/url.dart` | `PlayUrlModel`、`Dash`、`VideoItem`、`AudioItem`、`FormatItem`、`Dolby`、`Flac`、`Durl` | 视频播放地址（DASH/HLS/FLV），含视频/音频流列表、杜比全景声、无损音频 |

### 2.5 `lib/models/github/` — GitHub 更新检查模型

| 文件 | 核心类 | 说明 |
|------|-------|------|
| `github/latest.dart` | `LatestDataModel`、`AssetItem` | GitHub Release 最新版本信息，含 `tagName`、`body`（更新日志）、`assets`（下载资源） |

### 2.6 `lib/models/` 根目录 — 视频详情响应

| 文件 | 核心类 | 说明 |
|------|-------|------|
| `video_detail_res.dart` | `VideoDetailResponse`、`VideoDetailData`、`Stat`、`Owner`、`Part`、`Dimension`、`Subtitle`、`UgcSeason`、`EpisodeItem`、`Staff`、`Vip` 等 | 视频详情完整响应模型，是整个 model 层最核心也最复杂的模型文件 |

---

## 3. 核心模型详解

### 3.1 VideoDetailResponse — 视频详情响应包装

位于 `lib/models/video_detail_res.dart`。

标准响应格式的封装，采用三层嵌套：`code + message + data`。

```dart
class VideoDetailResponse {
  int? code;           // 状态码，0 表示成功
  String? message;     // 状态消息
  int? ttl;            // 响应 TTL
  VideoDetailData? data;  // 视频详情数据体

  VideoDetailResponse.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

### 3.2 VideoDetailData — 视频详情数据体

位于 `lib/models/video_detail_res.dart`。

是整个项目**字段最多**的模型类，涵盖视频元数据的方方面面。

**核心字段一览：**

| 字段 | 类型 | JSON key | 说明 |
|------|------|----------|------|
| `bvid` | `String?` | `bvid` | BV 号（如 `BV1xx411c7mD`） |
| `aid` | `int?` | `aid` | AV 号 |
| `title` | `String?` | `title` | 视频标题 |
| `pic` | `String?` | `pic` | 视频封面 URL |
| `desc` | `String?` | `desc` | 视频简介文本 |
| `descV2` | `List<DescV2>?` | `desc_v2` | 结构化简介（富文本格式） |
| `duration` | `int?` | `duration` | 视频时长（秒） |
| `pubdate` | `int?` | `pubdate` | 发布时间戳 |
| `ctime` | `int?` | `ctime` | 创建时间戳 |
| `owner` | `Owner?` | `owner` | UP 主信息（mid、name、face） |
| `stat` | `Stat?` | `stat` | 视频统计（播放、弹幕、评论、收藏、投币、分享、点赞等） |
| `pages` | `List<Part>?` | `pages` | 视频分P列表 |
| `subtitle` | `Subtitle?` | `subtitle` | 字幕信息 |
| `dimension` | `Dimension?` | `dimension` | 视频分辨率（宽/高/旋转） |
| `ugcSeason` | `UgcSeason?` | `ugc_season` | UGC 合集信息（含 Sections → Episodes 嵌套） |
| `staff` | `List<Staff>?` | `staff` | 联合投稿成员列表 |
| `rights` | `Map<String, int>?` | `rights` | 版权/权限标记 |
| `honorReply` | `HonorReply?` | `honor_reply` | 每周必看等荣誉标记 |

**子模型关系图：**

```
VideoDetailResponse
  └── VideoDetailData
        ├── Owner               (mid, name, face)
        ├── Stat                (view, danmaku, reply, favorite, coin, share, like, dislike...)
        ├── Dimension           (width, height, rotate)
        ├── List<Part>          (cid, page, part, duration, dimension)
        ├── Subtitle            (allowSubmit, list)
        ├── HonorReply          → List<Honor>
        ├── DescV2              (rawText, type, bizId)
        ├── UgcSeason
        │     └── List<SectionItem>
        │           └── List<EpisodeItem>  (aid, cid, bvid, page)
        ├── UserGarb            (urlImageAniCut)
        └── List<Staff>         (mid, title, name, face)
              └── Vip           (type, status)
```

### 3.3 Stat — 视频统计数据

位于 `lib/models/video_detail_res.dart`。

| 字段 | 类型 | JSON key | 说明 |
|------|------|----------|------|
| `view` | `int?` | `view` | 播放量 |
| `danmaku` | `int?` | `danmaku` | 弹幕数 |
| `reply` | `int?` | `reply` | 评论数 |
| `favorite` | `int?` | `favorite` | 收藏数 |
| `coin` | `int?` | `coin` | 投币数 |
| `share` | `int?` | `share` | 分享数 |
| `like` | `int?` | `like` | 点赞数 |
| `dislike` | `int?` | `dislike` | 点踩数 |
| `nowRank` | `int?` | `now_rank` | 当前排名 |
| `hisRank` | `int?` | `his_rank` | 历史最高排名 |
| `evaluation` | `String?` | `evaluation` | 视频评分 |

### 3.4 UserInfoData — 用户信息

位于 `lib/models/user/info.dart`。

**核心字段：**

| 字段 | 类型 | 说明 |
|------|------|------|
| `isLogin` | `bool?` | 是否已登录 |
| `mid` | `int?` | 用户 MID |
| `uname` | `String?` | 用户名 |
| `face` | `String?` | 头像 URL |
| `cover` | `String?` | 个人主页封面 |
| `levelInfo` | `LevelInfo?` | 等级信息（当前等级、经验值） |
| `money` | `double?` | 硬币数（自动处理 int→double 转换） |
| `moral` | `int?` | 节操值 |
| `scores` | `int?` | 积分 |
| `vipStatus` / `vipType` | `int?` | VIP 状态/类型 |
| `vipLabel` | `Map?` | VIP 标签信息（如"年度大会员"） |
| `vipNicknameColor` | `String?` | VIP 昵称颜色（如 `#FB7299`） |
| `wallet` | `Map?` | 钱包信息 |
| `hasShop` / `shopUrl` | `bool?` / `String?` | 商品橱窗 |
| `official` / `officialVerify` | `Map?` | 官方认证信息 |
| `pendant` | `Map?` | 头像挂件 |

**Hive 持久化：**

`UserInfoData` 通过 `UserInfoDataAdapter`（typeId=4）和 `LevelInfoAdapter`（typeId=5）支持 Hive 二进制存储，是项目中**唯一同时支持 JSON 序列化和 Hive 持久化**的模型类。

### 3.5 PlayUrlModel — 播放地址

位于 `lib/models/video/play/url.dart`。

**核心字段：**

| 字段 | 类型 | 说明 |
|------|------|------|
| `quality` | `int?` | 当前画质代码 |
| `format` | `String?` | 视频格式描述 |
| `acceptQuality` | `List<int>?` | 支持的画质代码列表 |
| `dash` | `Dash?` | DASH 流数据（H.264/H.265/AV1 分段流） |
| `durl` | `List<Durl>?` | FLV 分段地址（备选播放方式） |
| `supportFormats` | `List<FormatItem>?` | 支持的格式列表（含 codecs 信息） |

**Dash 流结构：**

```
Dash
├── duration: int?           # 总时长
├── video: List<VideoItem>   # 视频流列表（含 codecid、bandWidth、quality、解码格式）
├── audio: List<AudioItem>   # 音频流列表（含 64K/132K/192K/杜比/Hi-Res）
├── dolby: Dolby?            # 杜比全景声（含 type 标识和独立 audio 流）
└── flac: Flac?              # 无损音频
```

### 3.6 VideoQuality / AudioQuality — 画质与音频枚举

位于 `lib/models/video/play/quality.dart`。

**VideoQuality 映射表：**

| 枚举值 | Code | 描述 |
|--------|------|------|
| `speed240` | 6 | 240P 极速 |
| `flunt360` | 16 | 360P 流畅 |
| `clear480` | 32 | 480P 清晰 |
| `high720` | 64 | 720P 高清 |
| `high72060` | 74 | 720P60 高帧率 |
| `high1080` | 80 | 1080P 高清 |
| `high1080plus` | 112 | 1080P+ 高码率 |
| `high108060` | 116 | 1080P60 高帧率 |
| `super4K` | 120 | 4K 超清 |
| `hdr` | 125 | HDR 真彩色 |
| `dolbyVision` | 126 | 杜比视界 |
| `super8k` | 127 | 8K 超高清 |

**AudioQuality 映射表：**

| 枚举值 | Code | 描述 |
|--------|------|------|
| `k64` | 30216 | 64K |
| `k132` | 30232 | 132K |
| `k192` | 30280 | 192K |
| `dolby` | 30250 | 杜比全景声 |
| `hiRes` | 30251 | Hi-Res无损 |

两个枚举均提供 `fromCode` / `toCode` 双向转换方法。

### 3.7 FavFolderData / HistoryData — 收藏与历史

**FavFolderData**（`fav_folder.dart`）：

- 顶层：`FavFolderData` — `count`（总数）、`list`（子项列表）、`hasMore`（是否有更多）
- 子项：`FavFolderItemData` — 含 `id`、`title`、`cover`、`mediaCount`、`Upper`（UP 主信息）等 20+ 字段

**HistoryData**（`history.dart`）：

- 顶层：`HistoryData` — `cursor`（分页游标）、`tab`（Tab 列表）、`list`（历史条目）
- 子项：`HisListItem` — 含 `title`、`cover`、`authorName`、`progress`（播放进度）、`duration`、`isFinish` 等 20+ 字段
- 内嵌：`History` — `oid`（稿件 ID）、`bvid`、`cid`（视频分P ID）、`business`（业务类型）

---

## 4. OttoHub 领域模型

### 4.1 `lib/ottohub/models/dynamics/result.dart` — 动态/广场

位于 `lib/ottohub/models/dynamics/result.dart`。

从 OttoHub API（自建社区后端）获取的动态/广场内容模型，。

**核心模型类：**

| 类名 | 说明 |
|------|------|
| `DynamicsDataModel` | 动态列表顶层容器：`hasMore`、`items`、`offset` |
| `DynamicItemModel` | 单条动态：`idStr`、`type`（`DYNAMIC_TYPE_DRAW` / `DYNAMIC_TYPE_WORD` / `DYNAMIC_TYPE_VIDEO`）、`modules` |
| `ItemModulesModel` | 动态模块集合：`moduleAuthor`（作者信息）、`moduleDynamic`（正文与媒体）、`moduleStat`（统计） |
| `ModuleAuthorModel` | 作者模块：`face`（头像）、`mid`、`name`、`pubTime` |
| `ModuleDynamicModel` | 内容模块：`desc`（文字描述）、`major`（主要媒体，图文动态） |
| `DynamicDescModel` | 文本描述：`title`、`text` |
| `DynamicMajorModel` | 主要媒体：`draw`（图文集）、`type`（`MAJOR_TYPE_DRAW`） |
| `DynamicDrawModel` / `DynamicDrawItemModel` | 图文集：含 `items` 列表（`src`、`width`、`height`、`size`） |
| `ModuleStatModel` | 互动统计：`comment`（评论）、`forward`（转发）、`like`（点赞） |

**亮点设计：双数据源兼容**

`DynamicItemModel` 提供两个构造工厂：

```dart
// 从 API JSON 解析
DynamicItemModel.fromJson(Map<String, dynamic> json)

// 从 OttoHub TimelineItem 转换
factory DynamicItemModel.fromTimelineItem(TimelineItem item)
```

这使得同一个 UI 组件可以无缝展示来自两个不同数据源的动态内容。

### 4.2 `lib/ottohub/models/member/` — 成员/用户模型

| 文件 | 核心类 | JSON 兼容 | 说明 |
|------|-------|-----------|------|
| `info.dart` | `MemberInfoModel`、`Vip`、`LiveRoom` | **双键兼容** | 用户信息（`name`、`sex`、`face`、`sign`、`level`），含 VIP 和直播间子模型 |
| `archive.dart` | `MemberArchiveDataModel`、`ArchiveListModel`、`TListItemModel`、`VListItemModel`、`Stat`、`Owner` | **多源兼容** | 用户投稿视频列表，同时兼容 B 站原生字段（`pic`/`play`）和 OttoHub API 字段（`cover_url`/`view_count`） |
| `tags.dart` | `MemberTagItemModel` | — | 用户标签和 TAG（OAD） |

**`VListItemModel` 的多源兼容设计：**

```dart
// API 字段名
pic = json['cover_url'] ?? json['pic'];
play = json['view_count'] ?? json['play'];
comment = json['comment_count'] ?? json['comment'];
review = json['like_count'] ?? json['review'];
author = json['username'] ?? json['author'];
mid = json['uid'] ?? json['mid'];
```

每个字段都使用 `??` 提供了两套 JSON key 的回退，确保同一模型类可以解析两种不同命名风格的返回数据。

### 4.3 `lib/ottohub/models/video/reply/` — 评论模型

| 文件 | 核心类 | 说明 |
|------|-------|------|
| `item.dart` | `ReplyItemModel`、`UpAction`、`ReplyControl` | 评论条目：含 `rpid`、`mid`、`count`（子回复数）、`like`、`member`（用户信息）、`content`（内容）、`replies`（递归子回复）、`isUp`（是否UP主）、`isTop`（是否置顶） |
| `content.dart` | `ReplyContent`、`MemberItemModel` | 评论内容：`message`（文本）、`atNameToMid`（@用户映射）、`members`（被@的用户列表）、`emote`（表情包）、`pictures`（图片列表）、`isText`（纯文本/富文本判断） |
| `member.dart` | `ReplyMember`、`Pendant`、`UserSailing` | 评论用户：`mid`、`uname`、`avatar`、`level`、`vip`、`pendant`（头像挂件）、`officialVerify`、`userSailing`（大航海信息） |

**双数据源兼容：**

`ReplyItemModel` 同样支持两个工厂构造函数：

```dart
// 从 API JSON 解析
ReplyItemModel.fromJson(Map<String, dynamic> json, upperMid, {isTopStatus})

// 从 OttoHub API JSON 解析
ReplyItemModel.fromOttohubJson(Map<String, dynamic> json)
```

OttoHub 返回的字段名不同（`bcid` → `rpid`、`uid` → `mid`、`username` → `uname`），`fromOttohubJson` 完成了字段名映射。

---

## 5. API 响应模型

位于 `lib/ottohub/api/models/`，专为 OttoHub RESTful API 设计的轻量级数据类。这些类仅用于 API Service 层的数据传输，与 UI 领域模型分离。

### 5.1 base_response.dart — 通用响应基类

位于 `lib/ottohub/api/models/base_response.dart`。

```dart
class BaseResponse<T> {
  final String status;    // API 状态
  final T? data;          // 泛型数据体
  final String? message;  // 提示消息
}

class ListResponse<T> {
  final List<T> list;     // 列表数据
  final int? total;       // 总数
  final int? totalPages;  // 总页数
  final int? page;        // 当前页
  final int? limit;       // 每页条数
}
```

### 5.2 各领域模型清单

| 文件 | 模型类 | 用途 |
|------|-------|------|
| `auth.dart` | `LoginResponse`、`SignInResponse` | 登录返回：uid、token、avatar/cover URL、isAdmin、isAudit；签到状态 |
| `video.dart` | `Video`、`ChannelDetail`、`VideoListResponse`、`VideoActionResponse`、`VideoSubmitResponse` | 视频上传/列表/互动（点赞、收藏）、投稿反馈（vid + 经验加成） |
| `channel.dart` | `Channel`、`ChannelMember`、`ChannelSection`、`ContentCount`、`ChannelContent`、`ChannelNotice`、`Pagination` | 频道管理全套模型：频道信息、成员、分区（Section）、内容（视频/图文）、公告、通用分页 |
| `following.dart` | `FollowingUser`、`ActiveUser`、`TimelineItem`、`UserListResponse`、`TimelineResponse`、`ActiveUserListResponse`、`FollowResponse`、`FollowStatusResponse` | 关注/时间线/活跃用户全套模型 |
| `danmaku.dart` | `Danmaku` | 弹幕数据：danmakuId、text、time（秒）、mode、color、fontSize、render |
| `message.dart` | `Message`、`Friend` | 私信消息与好友列表 |
| `block.dart` | `Block`、`BlockedUser`、`BlockStatus`、`BlockResponse`、`BlockListResponse`、`BlockedListResponse` | 黑名单全套模型：block/被block/双向状态/列表翻页 |
| `moderation.dart` | `VideoModeration`、`BlogModeration`、`AvatarModeration`、`DanmakuModeration`、`VideoCommentModeration`、`BlogCommentModeration`、`ModerationLog`、各类 Response/List | 审核系统全套模型：视频审核、图文审核、头像审核、弹幕审核、评论审核、审核日志、未读计数 |

---

## 6. JSON 序列化模式

### 6.1 核心模式：手写 `fromJson` 构造函数

项目中所有模型类的 JSON 反序列化均采用**手写 `factory` 或命名构造函数**：

```dart
class Stat {
  int? view;
  int? danmaku;

  Stat({this.view, this.danmaku});

  // 手写 fromJson，逐一映射字段
  Stat.fromJson(Map<String, dynamic> json) {
    view = json["view"];
    danmaku = json["danmaku"];
  }

  // 可选的 toJson（并非所有模型都需要）
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["view"] = view;
    data["danmaku"] = danmaku;
    return data;
  }
}
```

### 6.2 常见模式总结

**模式一：可选字段 + 空安全**

```dart
Stat.fromJson(Map<String, dynamic> json) {
  view = json["view"];    // 直接用 ?. 或默认 null
  danmaku = json["danmaku"];
}
```

**模式二：提供默认值**

```dart
FollowDataModel.fromJson(Map<String, dynamic> json) {
  total = json['total'] ?? 0;           // 默认 0
  sign = json['sign'] == '' ? '还没有签名' : json['sign'];  // 空字符串替换
}
```

**模式三：嵌套对象懒初始化**

```dart
VideoDetailData.fromJson(Map<String, dynamic> json) {
  owner = json["owner"] == null ? null : Owner.fromJson(json["owner"]);
  stat = json["stat"] == null ? null : Stat.fromJson(json["stat"]);
}
```

**模式四：列表映射**

```dart
pages = json["pages"] == null
    ? []
    : List<Part>.from(json["pages"]!.map((e) => Part.fromJson(e)));
```

**模式五：类型安全转换**

```dart
// 处理 int/double 歧义
money = json['money'] is int ? json['money'].toDouble() : json['money'];
```

**模式六：双数据源多键回退**

OttoHub 模型特有模式，同时兼容 B 站原生和 OttoHub API 的字段名差异：

```dart
// 从两个不同 JSON key 取值，优先取 OttoHub 的 key
pic = json['cover_url'] ?? json['pic'];
author = json['username'] ?? json['author'];
mid = _parseInt(json['uid'] ?? json['mid']);

// _parseInt 辅助函数：安全转换 String/int → int
int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  return null;
}
```

### 6.3 Hive TypeAdapter 模式

仅 `UserInfoData` 和 `LevelInfo` 实现了 `TypeAdapter`：

```dart
class UserInfoDataAdapter extends TypeAdapter<UserInfoData> {
  @override
  final int typeId = 4;

  @override
  UserInfoData read(BinaryReader reader) {
    // 按 fieldId 读取各字段
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserInfoData(isLogin: fields[0] as bool?, ...);
  }

  @override
  void write(BinaryWriter writer, UserInfoData obj) {
    // 按 fieldId 写入各字段
    writer
      ..writeByte(25)      // 字段总数
      ..writeByte(0)       // fieldId
      ..write(obj.isLogin) // field value
      ..writeByte(1)
      ..write(obj.emailVerified);
    // ...
  }
}
```

### 6.4 枚举扩展模式

所有枚举类通过 Dart `extension` 提供额外属性和方法：

```dart
enum ThemeType { light, dark, system }

extension ThemeTypeDesc on ThemeType {
  String get description => ['浅色', '深色', '跟随系统'][index];
}

extension ThemeTypeCode on ThemeType {
  int get code => [0, 1, 2][index];
}
```

对于带 Code 映射的枚举，同时提供双向转换：

```dart
extension VideoQualityCode on VideoQuality {
  int get code => _codeList[index];
  static VideoQuality? fromCode(int code) { ... }
  static int? toCode(VideoQuality quality) { ... }
}
```

---

## 7. 使用示例

### 7.1 视频详情模型解析

```dart
import 'package:piliotto/models/video_detail_res.dart';

Future<void> parseVideoDetail(Map<String, dynamic> jsonData) async {
  final response = VideoDetailResponse.fromJson(jsonData);
  
  if (response.code == 0 && response.data != null) {
    final video = response.data!;
    
    print('视频标题: ${video.title}');
    print('BV号: ${video.bvid}');
    print('播放量: ${video.stat?.view}');
    print('点赞数: ${video.stat?.like}');
    print('UP主: ${video.owner?.name}');
    
    if (video.pages != null && video.pages!.isNotEmpty) {
      print('分P数量: ${video.pages!.length}');
      for (var page in video.pages!) {
        print('  P${page.page}: ${page.part} (${page.duration}秒)');
      }
    }
  }
}
```

### 7.2 用户信息模型使用

```dart
import 'package:piliotto/models/user/info.dart';
import 'package:piliotto/utils/storage.dart';

Future<void> handleUserLogin(Map<String, dynamic> userData) async {
  final userInfo = UserInfoData.fromJson(userData);
  
  if (userInfo.isLogin == true) {
    print('用户: ${userInfo.uname}');
    print('等级: Lv.${userInfo.levelInfo?.currentLevel}');
    print('硬币: ${userInfo.money}');
    
    if (userInfo.vipStatus == 1) {
      print('VIP状态: ${userInfo.vipLabel?['text'] ?? '大会员'}');
    }
    
    await GStrorage.userInfo.put('userInfoCache', userInfo);
  }
}
```

### 7.3 弹幕模型转换

```dart
import 'package:piliotto/models/video/play/quality.dart';
import 'package:piliotto/utils/danmaku.dart';

void processDanmaku(List<dynamic> danmakuList) {
  for (var dm in danmakuList) {
    final color = DmUtils.decimalToColor(dm['color'] ?? 16777215);
    final type = DmUtils.getPosition(dm['mode'] ?? 1);
    
    print('弹幕: ${dm['content']}');
    print('颜色: ${color.value}');
    print('类型: ${type.name}');
  }
}

void selectVideoQuality(int code) {
  final quality = VideoQualityCode.fromCode(code);
  if (quality != null) {
    print('当前画质: ${quality.description}');
    print('画质代码: ${quality.code}');
  }
}
```

### 7.4 OttoHub 动态模型解析

```dart
import 'package:piliotto/ottohub/models/dynamics/result.dart';

void parseDynamics(List<dynamic> jsonList) {
  for (var json in jsonList) {
    final item = DynamicItemModel.fromJson(json);
    
    print('动态ID: ${item.idStr}');
    print('类型: ${item.type}');
    
    final author = item.modules?.moduleAuthor;
    if (author != null) {
      print('作者: ${author.name}');
      print('发布时间: ${author.pubTime}');
    }
    
    final content = item.modules?.moduleDynamic?.desc?.text;
    if (content != null) {
      print('内容: $content');
    }
    
    final stats = item.modules?.moduleStat;
    if (stats != null) {
      print('点赞: ${stats.like?.count ?? 0}');
      print('评论: ${stats.comment?.count ?? 0}');
    }
  }
}
```

---

## 8. 开发指南：如何新增模型

### 8.1 新增业务模型

适用场景：接入 B 站 API 新接口，需要在 `lib/models/` 下新建模型。

**步骤：**

1. **确定归属目录**：视频相关放 `video/`，用户相关放 `user/`，通用枚举放 `common/`
2. **创建 Dart 文件**：以业务含义命名（如 `video_related.dart`）
3. **编写模型类**：遵循以下模板

```dart
/// 响应包装类
class MyNewResponse {
  int? code;
  String? message;
  MyNewData? data;

  MyNewResponse({this.code, this.message, this.data});

  MyNewResponse.fromJson(Map<String, dynamic> json) {
    code = json["code"];
    message = json["message"];
    data = json["data"] == null ? null : MyNewData.fromJson(json["data"]);
  }

  Map<String, dynamic> toJson() => {
    "code": code,
    "message": message,
    "data": data?.toJson(),
  };
}

/// 数据体类
class MyNewData {
  int? id;
  String? title;
  List<MySubItem>? items;

  MyNewData({this.id, this.title, this.items});

  MyNewData.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    title = json["title"];
    items = json["items"] == null
        ? []
        : List<MySubItem>.from(json["items"]!.map((e) => MySubItem.fromJson(e)));
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "items": items == null ? [] : List<dynamic>.from(items!.map((e) => e.toJson())),
  };
}

/// 子项类
class MySubItem {
  int? itemId;
  String? itemName;

  MySubItem({this.itemId, this.itemName});

  MySubItem.fromJson(Map<String, dynamic> json) {
    itemId = json["item_id"];
    itemName = json["item_name"];
  }

  Map<String, dynamic> toJson() => {
    "item_id": itemId,
    "item_name": itemName,
  };
}
```

4. **关键约定**：
   - JSON key 使用**下划线命名**（`snake_case`），如 `item_id`、`cover_url`
   - Dart 字段使用**驼峰命名**（`camelCase`），如 `itemId`、`coverUrl`
   - 所有字段使用**可空类型**（`?`），避免 JSON 缺失字段导致崩溃
   - 列表字段提供**空列表默认值**（`?? []`）
   - 如果模型需要 Hive 持久化，额外实现 `TypeAdapter`

### 8.2 新增 OttoHub API 响应模型

适用场景：需要接入新的 OttoHub RESTful 端点。

**步骤：**

1. 在 `lib/ottohub/api/models/` 下新建或编辑对应领域的模型文件
2. 遵循 `factory` 模式：

```dart
class MyNewApiModel {
  final int id;
  final String title;
  final String createdAt;

  MyNewApiModel({
    required this.id,
    required this.title,
    required this.createdAt,
  });

  factory MyNewApiModel.fromJson(Map<String, dynamic> json) {
    return MyNewApiModel(
      id: toInt(json['id']),
      title: json['title'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  static int toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
```

3. **关键约定**：
   - 使用 `final` 不可变字段（OttoHub API 模型的统一风格）
   - 使用 `factory` 构造函数而非普通构造函数进行反序列化
   - 提供 `toInt` / `toDouble` 辅助方法处理类型安全转换

### 8.3 新增 OttoHub 领域模型

适用场景：UI 需要展示来自 OttoHub 的数据，但与 API 模型字段不完全匹配（需要兼容 B 站字段名）。

**步骤：**

1. 在 `lib/ottohub/models/` 下按业务领域新建文件
2. **如果数据来自不同数据源，需要提供 JSON key 兼容：

```dart
MyItemModel.fromJson(Map<String, dynamic> json) {
  // 数据源 key
  title = json['title'] ?? json['name'];
  cover = json['pic'] ?? json['cover_url'] ?? '';
  playCount = _parseInt(json['play'] ?? json['view_count']);
}
```

3. 如果数据源完全不同（如 `DynamicItemModel`），可以提供额外的工厂构造函数进行转换：

```dart
factory DynamicItemModel.fromTimelineItem(TimelineItem item) {
  // 将 OttoHub API 的 TimelineItem 转换为 UI 友好的模型
}
```

---

## 9. 二改指南

### 9.1 修改现有模型字段

**场景**：B 站 API 新增/变更字段，需要修改现有模型。

**操作步骤：**

1. 在对应模型类的构造函数中新增字段
2. 在 `fromJson` 中添加对应 JSON key 的解析逻辑
3. 如果字段需要用于 UI，在 Controller 中解包使用
4. 如果字段需要持久化（`UserInfoData`），同时更新 `TypeAdapter` 的 `read`/`write` 方法

**示例**：给 `Stat` 新增 `vt` 字段：

```dart
// 1. 修改 Stat 类
class Stat {
  // ... 原有字段
  int? vt;  // 新增

  Stat.fromJson(Map<String, dynamic> json) {
    // ... 原有解析
    vt = json["vt"];  // 新增
  }
}
```

### 9.2 切换数据源

如果需要将某个页面的数据从 B 站 API 切换到 OttoHub API：

1. **创建新的 OttoHub 领域模型**（`lib/ottohub/models/` 下），兼容新旧字段名
2. **修改 Repository 实现**（`lib/ottohub/repositories/`），将 API 返回的 JSON 解析为新模型
3. **Controller 无需改动**（接口不变），确保新模型的字段名与旧模型一致

### 9.3 替换视频播放器

播放器相关模型主要在两个位置：

- `lib/models/video/play/url.dart` — DASH/FLV 流 URL 模型
- `lib/models/video/play/quality.dart` — 画质/音频/解码格式枚举

替换播放器时：

1. 保留 `PlayUrlModel` 的结构作为数据契约
2. 根据新播放器的流格式要求，调整 `Dash` 的解析逻辑
3. 更新 `VideoItem`/`AudioItem` 中 `baseUrl`/`backupUrl` 的处理方式
4. 保持 `VideoQuality` 枚举的 code 映射不变（与 B 站 API 对齐）

### 9.4 添加新枚举配置

需要新增 UI 配置枚举时的模板：

```dart
enum MyNewEnum { optionA, optionB }

extension MyNewEnumDesc on MyNewEnum {
  String get description => ['选项A', '选项B'][index];
}

extension MyNewEnumCode on MyNewEnum {
  int get code => [0, 1][index];

  static MyNewEnum? fromCode(int code) {
    final index = [0, 1].indexOf(code);
    return index != -1 ? MyNewEnum.values[index] : null;
  }
}
```

### 9.5 注意事项

1. **不要使用代码生成**：项目不使用 `json_serializable` / `build_runner`，不要引入相关依赖，保持纯手写序列化
2. **保持字段可空**：B 站 API 字段可能随时返回 null，所有模型字段应使用 `?`
3. **列表字段默认 `[]`**：`fromJson` 中列表字段始终提供空列表默认值，避免 `null` 导致 `ListView` 报错
4. **命名一致性**：
   - JSON key（`fromJson` 参数）：`snake_case`（如 `cover_url`、`like_count`）
   - Dart 字段名：`camelCase`（如 `coverUrl`、`likeCount`）
   - 模型类名：`PascalCase`，以业务含义命名（如 `VideoDetailData`、`FansItemModel`）
5. **Hive TypeAdapter 维护**：如果修改了 `UserInfoData` 或 `LevelInfo` 的字段结构，必须在对应的 `TypeAdapter` 中同步更新 `read`/`write` 逻辑，否则本地缓存数据会损坏
6. **枚举 `index` 顺序不可变**：所有枚举 extension 依赖 `.values[index]` 的顺序，新增枚举项应追加到末尾，不可插入中间