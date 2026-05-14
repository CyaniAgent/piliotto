---
date: 2026-05-14 22:54:20
title: mine
permalink: /pages/
categories:
  - guide
  - pages
---
# 个人中心页（Mine）

## 1. 模块概述

`MinePage` 是用户个人中心页面，展示用户头像、昵称、关注/粉丝统计，并提供主题切换、设置、收藏、历史记录等功能的入口。

| 页面 | 路由 | 数据源 | 用途 |
|------|------|--------|------|
| `MinePage` | `/mine` (Tab 内嵌页面，也可独立进入) | `IUserRepository.getUserProfileInfo()` | 个人中心门户 |

### 文件结构

```
lib/pages/mine/
├── controller.dart      # MineController - 个人中心控制器
├── view.dart            # MinePage - 个人中心 UI
└── index.dart           # 模块导出
```

### 依赖关系

```
MinePage (StatefulWidget)
  ├── Get.put → MineController
  ├── IUserRepository → getUserProfileInfo(uid)
  ├── GStrorage.userInfo → 用户信息缓存 (Hive)
  ├── GStrorage.setting → 主题设置缓存 (Hive)
  ├── SliverAppBar (expanded + pinned + snap)
  │   ├── actions: 主题切换 + 设置
  │   └── flexibleSpace: 用户信息 Header
  │       ├── CachedNetworkImage (封面背景)
  │       ├── 头像 (80px 圆形)
  │       ├── 用户名 + UID
  │       ├── 关注/粉丝统计 (可点击跳转)
  │       └── 登录按钮 (未登录时)
  └── SliverToBoxAdapter → _buildContent
      └── 功能菜单列表
          ├── 我的收藏 → FavPage
          └── 历史记录 → HistoryPage
```

---

## 2. Controller 详解

**源文件：** `controller.dart`

`MineController` 继承自 `GetxController`，管理用户信息、登录态、主题切换、导航跳转等核心逻辑。

### 2.1 核心属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `userInfo` | `Rx<UserInfoData>` | 用户信息（响应式），含 `mid`、`uname`、`face`、`cover` 等字段 |
| `userStat` | `Rx<UserStat>` | 用户统计（响应式），含 `following`（关注数）、`follower`（粉丝数） |
| `userLogin` | `RxBool` | 登录状态 |
| `userInfoCache` | `Box` | Hive 用户信息缓存 Box |
| `setting` | `Box` | Hive 设置缓存 Box |
| `themeType` | `Rx<ThemeType>` | 当前主题类型：`light` / `dark` / `system` |

### 2.2 核心方法

**`onInit()`**
初始化逻辑：
1. 从 `userInfoCache` 读取缓存的 `userInfoCache` key，若存在则赋值 `userInfo` 并设置 `userLogin = true`
2. 从 `setting` 读取 `themeMode`，解析为 `ThemeType` 枚举
3. 若已登录，调用 `_refreshUserInfo()` 获取最新的封面图 URL

**`_refreshUserInfo()`**
静默刷新用户信息：
- 通过 `_userRepo.getUserProfileInfo(uid: uid)` 获取用户资料
- 更新 `cover` 封面图、`following` 关注数、`follower` 粉丝数
- 调用 `userInfo.refresh()` 和 `userStat.refresh()` 手动触发 UI 更新
- 写回缓存 `userInfoCache.put('userInfoCache', userInfo.value)`

**`onLogin()`**
头像/登录区域的点击处理：
- 未登录 → 跳转 `/loginPage`
- 已登录 → 跳转 `/member?mid={mid}?`，携带 `face` 参数

**`queryUserInfo()`**
返回当前用户信息（适配 `FutureBuilder` 模式，返回 `{'status': true, 'data': userInfo.value}`）。

**`resetUserInfo()`**
重置用户信息（登出时调用）：
- 清空 `userInfo`、`userStat`
- 删除缓存 `userInfoCache.delete('userInfoCache')`
- 设置 `userLogin = false`

**`onChangeTheme()`**
循环切换主题：`light → dark → system → light`。写入 `setting.put(SettingBoxKey.themeMode, nextTheme.code)`，调用 `Get.forceAppUpdate()` 强制全局刷新。

**`pushFollow()`**
跳转关注页 `/follow?mid={mid}&name={name}`。需登录，未登录弹出 Toast 提示。

**`pushFans()`**
跳转粉丝页 `/fan?mid={mid}&name={name}`。需登录，未登录弹出 Toast 提示。

**`pushDynamic()`**
跳转用户动态页 `/memberDynamics?mid={mid}`。需登录，未登录弹出 Toast 提示。

---

## 3. View 详解（功能入口列表）

**源文件：** `view.dart`

`MinePage` 是一个 `StatefulWidget`，支持可选的 `showBackButton` 参数（用于独立页面进入时显示返回按钮）。

### 3.1 生命周期事件

| 事件 | 操作 |
|------|------|
| `initState` | 注册 `userLogin.listen` → `setState` 刷新 UI，确保登录/登出时页面自动更新 |
| `dispose` | 释放 `_scrollController` |

### 3.2 页面结构

```
Scaffold
└── body: CustomScrollView
    ├── SliverAppBar
    │   ├── leading: 条件返回按钮 (showBackButton)
    │   ├── actions:
    │   │   ├── 主题切换按钮 (light/dark/auto 图标)
    │   │   └── 设置按钮 → /setting
    │   ├── expandedHeight: 280
    │   ├── pinned + snap + floating (Material You 风格)
    │   └── flexibleSpace: _buildHeaderWithUserInfo
    │       └── Stack
    │           ├── CachedNetworkImage (封面背景, 280px)
    │           ├── 半透明遮罩 (黑色 100 alpha)
    │           └── SafeArea + Align(左下)
    │               └── Row
    │                   ├── _buildAvatar (80px 圆形, 白色/primary 边框)
    │                   └── Expanded → _buildUserDetails
    │                       ├── 用户名 / "点击头像登录"
    │                       ├── UID (登录后显示)
    │                       ├── 关注统计 + 粉丝统计 (可点击)
    │                       └── "立即登录" FilledButton (未登录时)
    └── SliverToBoxAdapter → _buildContent
        └── Container(padding: 20)
            └── _buildMenuItems
                ├── ListTile: 我的收藏 → FavPage()
                └── ListTile: 历史记录 → HistoryPage()
```

### 3.3 AppBar 图标颜色逻辑

`_getIconColor(ThemeData theme)` 根据是否有封面背景动态决定图标颜色：
- 有封面 → 白色（`Colors.white`）
- 无封面 → 主题色 `onSurface`

### 3.4 用户头像处理

- 已登录 + 有 `face` URL → `ClipOval` + `NetworkImgLayer`（网络头像）
- 已登录 + 无 `face` URL → `CircleAvatar` + `Icons.person` 图标
- 未登录 → `CircleAvatar` + `Icons.person` 图标

### 3.5 关注/粉丝统计

登录后显示关注和粉丝数，数据来自 `userStat`：
```dart
_buildStatItem('关注', userStat.value.following, pushFollow, textColor, subTextColor)
_buildStatItem('粉丝', userStat.value.follower, pushFans, textColor, subTextColor)
```

每个统计项为 `GestureDetector`，点击跳转对应列表页。

### 3.6 功能菜单列表

当前菜单项：
| 图标 | 标题 | 跳转 |
|------|------|------|
| `Icons.favorite_border_outlined` | 我的收藏 | `FavPage()` |
| `Icons.history_outlined` | 历史记录 | `HistoryPage()` |

菜单项使用 `ListTile`，`leading` 为 primary 色图标，`trailing` 为右箭头指示符。

---

## 4. 数据流

```
┌─────────────────────────────────┐
│  MineController.onInit          │
│  读取缓存 userInfoCache         │
└───────────────┬─────────────────┘
                │
    ┌───────────▼───────────┐
    │ userLogin == true?    │
    └──────┬──────────┬─────┘
     未登录 │          │ 已登录
           │          ▼
           │  _refreshUserInfo()
           │  IUserRepository
           │  getUserProfileInfo(uid)
           │          │
           │          ▼
           │  userStat + userInfo
           │  + 写回缓存
           │          │
           └────┬─────┘
                ▼
    ┌─────────────────────┐
    │ MinePage (Obx)      │
    │ ├── SliverAppBar    │
    │ │   ├── 头像       │
    │ │   ├── 用户名+UID  │
    │ │   ├── 关注/粉丝   │
    │ │   └── 登录按钮    │
    │ └── 功能菜单       │
    └─────────────────────┘
```

### 状态管理

| 状态 | 来源 | 说明 |
|------|------|------|
| `userInfo` | `Rx<UserInfoData>` | 驱动头像、用户名、UID 显示 |
| `userStat` | `Rx<UserStat>` | 驱动关注/粉丝数显示 |
| `userLogin` | `RxBool` | 控制登录/未登录 UI 切换 |
| `themeType` | `Rx<ThemeType>` | 控制主题切换按钮图标 |
| Hive 缓存 | `GStrorage.userInfo` | 持久化用户信息，支持离线读取 |

### 登录态联动

在 `MinePage.initState` 中监听 `userLogin`：
```dart
mineController.userLogin.listen((status) {
  if (mounted) setState(() {});
});
```

登录/登出时 `setState` 触发全页面重建，确保 UI 同步更新。

---

## 5. 开发指南

### 5.1 添加新的功能菜单入口

在 `_buildMenuItems()` 方法中添加新的 `_buildMenuItem` 调用：

```dart
_buildMenuItem(
  context, theme,
  Icons.download_outlined,
  '离线缓存',
  () => Get.toNamed('/offline'),
),
```

如需添加分组（如"创作中心"、"数据统计"），可在 `Column` 中插入 `Divider` + 分组标题。

### 5.2 添加新的用户统计指标

1. 在 `UserStat` 模型中添加对应字段（如 `likes` 获赞数）
2. 在 `_refreshUserInfo()` 中从 API 响应赋值
3. 在 `_buildUserDetails()` 中添加 `_buildStatItem` 调用

### 5.3 修改封面背景样式

- **高度**：修改 `expandedHeight: 280`
- **遮罩透明度**：修改 `Colors.black.withAlpha(100)`
- **头像大小**：修改 `CircleAvatar` 的 `radius: 40` 和 `NetworkImgLayer` 的 `width/height: 80`

### 5.4 添加"退出登录"功能

1. 在 Controller 中调用 `resetUserInfo()` 清除状态和缓存
2. 在 View 中添加退出按钮（如放在设置页或菜单底部）
3. 可选：清除 Hive 中的 token 等认证信息

---

## 6. 二改指南

### 6.1 常见需求

#### 修改主题切换顺序
在 `onChangeTheme()` 的 `switch` 逻辑中调整 `nextTheme` 的赋值顺序。当前顺序：`light → dark → system → light`。

#### 添加背景图片缓存策略
`CachedNetworkImage` 的 `placeholder` 和 `errorWidget` 均为 `SizedBox.shrink()`，可替换为默认背景色或模糊的低分辨率占位图。

#### 替换 StatelessWidget 为 ConsumerWidget
如需使用 Riverpod 等状态管理替代 GetX，将 `Obx` 替换为 `ref.watch`，Controller 改为 Provider。

#### 自定义空状态样式
未登录时头像显示 `Icons.person`（灰色人形图标）。如需替换为自定义占位图，修改 `_buildAvatar` 中的 `CircleAvatar` 的 `child` 参数。

#### 添加 VIP 标识
在 `_buildUserDetails` 的用户名旁添加 VIP 徽章。需要 `UserInfoData` 包含 VIP 等级字段，在 `userInfo` 中读取。

#### 支持编辑个人资料
当前仅跳转 `/member?mid={mid}` 到用户主页。如需编辑资料，添加编辑资料按钮跳转到资料编辑页。

### 6.2 注意事项

- `MineController.onInit()` 中的 `try-catch` 仅用于捕获初始化异常，不包含 `_refreshUserInfo` 的异常
- `_refreshUserInfo` 异常被静默处理（仅日志记录），不影响页面正常渲染
- 主题切换通过 `Get.forceAppUpdate()` 全局刷新，性能开销较大但确保所有页面同步
- `userInfo` 和 `userStat` 的 `refresh()` 调用是手动的——因为 `UserInfoData` 字段修改不会自动触发 `Rx` 的 `refresh`，需要手动通知
- `showBackButton` 参数仅在独立页面入口（非 Tab）时设为 `true`，Tab 内嵌时不显示返回按钮
- 关注/粉丝页面路由中 `name` 使用 `Uri.encodeComponent` 编码，与 `FollowController` / `FanController` 的解码逻辑配对