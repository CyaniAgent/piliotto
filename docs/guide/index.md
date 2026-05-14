---
date: 2026-05-14 21:56:09
title: 项目概览
categories:
  - guide
---

# PiliOtto 项目概览

**PiliOtto** 是一款跨平台 Ottohub 视频客户端，基于 Flutter 构建，支持 Android / iOS / Windows / macOS / Linux 五大平台。

## 核心功能

- 🎬 视频浏览、搜索与播放（弹幕、倍速、画中画）
- 👤 用户登录与个人中心
- 📰 动态流、收藏、历史记录
- 📊 排行榜、消息系统
- 🎨 主题定制（深色/浅色、Material You）

## 技术栈

| 类别 | 技术 |
|------|------|
| 框架 | Flutter 3.0+ |
| 状态管理 | GetX |
| 本地存储 | Hive |
| 网络请求 | Dio |
| 视频播放 | media_kit |
| 弹幕渲染 | canvas_danmaku |

## 架构设计

```
lib/
├── main.dart           # 应用入口
├── common/             # 通用组件、骨架屏
├── models/             # 数据模型
├── repositories/       # 仓储接口
├── services/           # 服务层
├── utils/              # 工具函数
├── router/             # 路由配置
├── ottohub/            # API 集成层
├── plugin/             # 自定义插件
└── pages/              # 页面模块
```

### 分层架构

```
┌─────────────────────────────────────┐
│           Pages（页面层）             │
│      Controller + View 模式          │
├─────────────────────────────────────┤
│          Repositories（仓储层）       │
│         接口抽象 + 实现               │
├─────────────────────────────────────┤
│           OttoHub API 层             │
│         API Models / Services        │
├─────────────────────────────────────┤
│    Models（模型）  Utils（工具）       │
├─────────────────────────────────────┤
│          Common（通用组件）            │
└─────────────────────────────────────┘
```

## 核心设计模式

### Controller-View 模式

每个页面模块遵循 Controller-View 分离：

```
pages/video/detail/
├── controller.dart    # 状态管理与业务逻辑
├── view.dart          # UI 组件
├── index.dart         # 统一导出
└── widgets/           # 页面专属组件
```

### Repository 模式

数据访问通过接口抽象：

- `lib/repositories/` — 接口定义
- `lib/ottohub/repositories/` — 具体实现

### 依赖注入

```dart
// main.dart 中注册
Get.put<IVideoRepository>(OttohubVideoRepository());

// Controller 中获取
final IVideoRepository repo = Get.find<IVideoRepository>();
```

## 模块导航

### 核心分层

- [数据模型层](/guide/core/models) — 数据类与 JSON 序列化
- [仓储层](/guide/core/repositories) — 接口抽象与实现
- [服务层](/guide/core/services) — 依赖注入与后台服务
- [工具层](/guide/core/utils) — 存储、网络、缓存工具
- [通用组件](/guide/core/common) — 可复用 Widget
- [路由系统](/guide/core/router) — 32 条路由定义
- [OttoHub API](/guide/core/ottohub) — API 集成层
- [自定义插件](/guide/core/plugin) — 播放器、图片画廊

### 页面模块

- [首页](/guide/pages/home) — 推荐流与 Tab 管理
- [主框架](/guide/pages/main) — 底部导航与页面容器
- [视频详情](/guide/pages/video-detail) — 播放器与评论系统
- [搜索](/guide/pages/search) — 搜索与历史
- [动态](/guide/pages/dynamics) — 动态流与详情
- [用户主页](/guide/pages/member) — 用户信息与投稿
- [设置](/guide/pages/setting) — 应用配置
- [登录](/guide/pages/login) — 认证流程
- [消息](/guide/pages/message) — 消息列表与聊天
- [收藏](/guide/pages/fav) — 收藏夹管理
- [历史记录](/guide/pages/history) — 观看历史
- [关注/粉丝](/guide/pages/follow) — 用户关系
- [热门](/guide/pages/hot) — 热门内容
- [排行](/guide/pages/rank) — 排行榜
- [媒体](/guide/pages/media) — 媒体内容
- [个人中心](/guide/pages/mine) — 个人信息
- [关于](/guide/pages/about) — 应用信息
- [WebView](/guide/pages/webview) — 内嵌浏览器
- [弹幕](/guide/pages/danmaku) — 弹幕发送