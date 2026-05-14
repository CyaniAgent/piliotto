---
date: 2026-05-14 22:45:48
title: pages
permalink: /pages/
categories:
  - guide
  - pages
---
# 页面模块总览

PiliOtto 采用 **模块化页面架构**，每个页面模块独立在 `lib/pages/` 下组织，遵循统一的 Controller-View 分离模式与 GetX 响应式状态管理。

## 目录结构

```
lib/pages/
├── about/                 # 关于页
├── danmaku/               # 弹幕渲染层（非独立路由页面）
├── dynamics/              # 动态 Feed 页
├── fav/                   # 收藏夹页
├── follow/                # 关注/粉丝页
├── history/               # 观看历史页
├── home/                  # 首页（Tab 容器）
├── login/                 # 登录页
├── main/                  # 主框架（BottomNavigationBar + PageView）
├── media/                 # 媒体库页
├── member/                # 用户详情页
├── message/               # 消息列表页
├── mine/                  # 个人中心页
├── rcmd/                  # 推荐视频页（首页"推荐"Tab 内容）
├── search/                # 搜索结果页
├── setting/               # 设置页（含子页面）
├── video_detail/          # 视频详情页（含播放器）
├── webview/               # 内嵌浏览器页
└── whisper_detail/        # 私信详情页
```

## 架构约定

### Controller-View 分离

每个页面模块通常包含三个文件：

```
lib/pages/{module}/
├── controller.dart        # GetxController 子类，管理状态与逻辑
├── view.dart              # Widget 子类，响应式 UI
└── index.dart             # 统一导出（export controller.dart; export view.dart;）
```

部分简单模块（如 `about`）将 Controller 与 View 合并在单个文件中。

### 状态管理模式

| 模式 | 示例 | 适用场景 |
|------|------|---------|
| **GetxController + Obx** | HomeController, RcmdController | 需要响应式 UI 更新的页面级状态 |
| **原生 Dart Controller + 回调** | PlDanmakuController | 性能敏感场景，避免 GetX 依赖注入开销 |
| **StatefulWidget + setState** | AboutPage | 简单状态，不需要跨组件共享 |

### 路由注册

页面路由在 `lib/router.dart` 中通过 GetX 的 `GetPage` 集中注册：

```dart
GetPage(name: '/video', page: () => const VideoDetailPage()),
GetPage(name: '/webview', page: () => const WebviewPage()),
GetPage(name: '/member', page: () => const MemberPage()),
// ...
```

路由参数通过 `Get.parameters` 传递（如 `?mid=123&name=xxx`），额外数据通过 `Get.arguments` 传递。

## 页面分类

### 框架级页面

| 页面 | 路由 | 说明 |
|------|------|------|
| MainPage | `/` | 根框架，底部导航栏 + PageView |
| HomePage | `/` (Tab) | 首页 Tab 容器，内嵌 RcmdPage 和 HotPage |
| RcmdPage | — | 推荐视频网格（HomePage 子内容） |

### 功能页面

| 页面 | 路由 | 核心功能 |
|------|------|---------|
| VideoDetailPage | `/video?vid=xxx` | 视频播放、弹幕、评论 |
| WebviewPage | `/webview?url=xxx` | 内嵌浏览器、登录 |
| SearchPage | `/search?keyword=xxx` | 搜索结果、搜索历史 |
| MemberPage | `/member?mid=xxx` | 用户详情、视频列表 |
| WhisperDetailPage | `/whisperDetail?mid=xxx` | 私信聊天 |
| LoginPage | `/login` | 登录方式选择 |
| AboutPage | `/about` | 版本信息与更新 |
| SettingPage | `/setting` | 设置（含多个子页面） |

### 个人中心相关

| 页面 | 路由 | 核心功能 |
|------|------|---------|
| MinePage | — | 个人中心（Tab 内嵌） |
| FavPage | — | 收藏夹列表 |
| FollowPage | — | 关注/粉丝列表 |
| HistoryPage | — | 观看历史 |
| MessagePage | — | 消息列表 |

### 内部模块（非独立路由）

| 模块 | 说明 |
|------|------|
| PlDanmaku | 弹幕渲染层，叠加在视频播放器上 |
| MediaPage | 媒体库模块 |
| DynamicsPage | 动态 Feed 模块 |

## 开发约定

### 新增页面步骤

1. 在 `lib/pages/{module}/` 下创建 `controller.dart`、`view.dart`、`index.dart`
2. 在 `lib/router.dart` 中注册路由
3. Controller 通过 `Get.put()` 或 `Bindings` 注册依赖
4. 在本文档中补充页面条目

### 命名规范

- Controller 类名：`{Feature}Controller`
- View 类名：`{Feature}Page` 或 `{Feature}App`（根级）
- 路由名称：小写下划线，如 `video_detail`、`whisper_detail`
- 文件命名：`controller.dart`、`view.dart`、`index.dart`

### 通用依赖

绝大多数页面模块共享以下依赖：

| 库 | 用途 |
|---|------|
| `get` | 状态管理、路由、依赖注入 |
| `hive` / `hive_flutter` | 本地持久化存储（用户设置、缓存） |
| `flutter_smart_dialog` | Toast / Dialog 快捷调用 |
| `GStrorage` | 统一的 Hive Box 访问封装 |
| `EventBus` | 跨组件事件通信 |

## 相关文档

详细文档请参考各模块的独立页面：

- `home.md` — 首页模块
- `main.md` — 主框架与推荐模块
- `danmaku.md` — 弹幕与私信模块
- `webview.md` — WebView 模块
- `about.md` — 关于模块
- `video-detail.md` — 视频详情模块
- `search.md` — 搜索模块
- `member.md` — 用户详情模块
- `setting.md` — 设置模块
- `message.md` — 消息模块
- `login.md` — 登录模块
- `history.md` — 观看历史模块
- `fav.md` — 收藏夹模块
- `follow.md` — 关注/粉丝模块
- `dynamics.md` — 动态模块