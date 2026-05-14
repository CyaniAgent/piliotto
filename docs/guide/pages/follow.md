---
date: 2026-05-14 22:54:20
title: follow
permalink: /pages/
categories:
  - guide
  - pages
---
# 关注 / 粉丝页（Follow & Fan）

## 1. 模块概述

关注页和粉丝页采用**完全相同的架构模式**，共同复用 `UserListPage` 通用组件展示用户列表。两者路由独立、Controller 独立，但代码结构高度对称。

| 页面 | 路由 | 数据源 | 用途 |
|------|------|--------|------|
| `FollowPage` | `/follow?mid={mid}&name={name}` | `IUserRepository.getFollowingList()` | 展示某用户的关注列表 |
| `FansPage` | `/fan?mid={mid}&name={name}` | `IUserRepository.getFansList()` | 展示某用户的粉丝列表 |

### 文件结构

```
lib/pages/follow/
├── controller.dart      # FollowController - 关注列表控制器
├── view.dart            # FollowPage - 关注页 UI
└── index.dart           # 模块导出

lib/pages/fan/
├── controller.dart      # FanController - 粉丝列表控制器
├── view.dart            # FansPage - 粉丝页 UI
└── index.dart           # 模块导出

lib/common/widgets/
└── user_list_page.dart  # UserListPage - 通用用户列表组件（被两者复用）
```

### 依赖关系

```
FollowPage / FansPage
  ├── Get.put → FollowController / FanController (tag: mid)
  └── UserListPage
        ├── RefreshIndicator → onRefresh (下拉刷新)
        ├── ListView.builder → userList (用户卡片列表)
        ├── ScrollController._onScroll → onLoad (滚动加载更多)
        └── 每个 ListTile → 点击跳转 /member?mid={uid}
```

两个 Controller 均依赖 `IUserRepository`，仅调用的接口方法不同：
- `FollowController` → `_userRepo.getFollowingList(uid, offset, num)`
- `FanController` → `_userRepo.getFansList(uid, offset, num)`

---

## 2. Controller 详解

### 2.1 FollowController

**源文件：** `controller.dart`

`FollowController` 继承自 `GetxController`，管理关注列表的分页加载逻辑。

#### 核心属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `mid` | `int` | 目标用户 ID，优先从路由参数 `Get.parameters['mid']` 获取，其次从缓存 `userInfo` |
| `name` | `String` | 目标用户昵称，经过 `_safeDecodeUri` 解码 |
| `offset` | `int` | 分页偏移量，每次加载后累加 |
| `num` | `int` | 每页数量，固定 `12`（API 限制） |
| `followList` | `RxList<FollowingUser>` | 关注用户列表（响应式） |
| `isLoading` | `RxBool` | 加载状态（防止重复请求） |
| `hasMore` | `RxBool` | 是否还有更多数据 |
| `loadingText` | `RxString` | 底部加载状态提示文本 |
| `userInfo` | `dynamic` | 从 Hive 缓存读取的当前登录用户信息 |

#### 核心方法

**`onInit()`**
从路由参数 `mid` / `name` 解析目标用户信息，若未提供则从本地缓存 `GStrorage.userInfo` 获取当前登录用户的 mid 和 uname。

**`queryFollowings({bool isLoadMore = false})`**
核心数据加载方法。通过 `_userRepo.getFollowingList(uid: mid, offset: offset, num: num)` 获取关注列表：
- 防重复加载：`isLoading` 为 `true` 时直接返回
- 首次加载（`isLoadMore == false`）：重置 `offset = 0`，覆盖 `followList`
- 追加加载（`isLoadMore == true`）：检查 `hasMore`，追加到 `followList`
- 判断是否到底：返回数据量 `< num` 则设置 `hasMore = false`
- 异常处理：Toast 提示"获取关注列表失败"

**`onLoad()`**
上拉加载更多，实际调用 `queryFollowings(isLoadMore: true)`。

**`onRefresh()`**
下拉刷新，实际调用 `queryFollowings()`（默认 `isLoadMore = false`）。

### 2.2 FanController

**源文件：** `controller.dart`

`FanController` 与 `FollowController` 结构几乎完全一致，差异仅在于：

| 对比项 | FollowController | FanController |
|--------|------------------|---------------|
| 列表属性 | `followList` | `fanList` |
| 数据方法 | `queryFollowings()` | `queryFans()` |
| 仓储调用 | `getFollowingList()` | `getFansList()` |
| 错误日志 | "获取关注列表失败" | "获取粉丝列表失败" |

---

## 3. View 详解（UserListPage）

### 3.1 FollowPage / FansPage

**源文件：** `view.dart` | `view.dart`

两个页面的 View 层非常精简，仅为 `UserListPage` 的参数绑定容器：

```dart
// FollowPage 示例
UserListPage(
  title: '${controller.name}的关注',   // 标题
  onRefresh: controller.onRefresh,     // 下拉刷新回调
  onLoad: controller.onLoad,           // 加载更多回调
  onInit: controller.onRefresh,       // 初始化加载
  userList: controller.followList,     // 用户列表数据
  isLoading: controller.isLoading,     // 加载状态
  hasMore: controller.hasMore,         // 是否有更多
  loadingText: controller.loadingText, // 底部状态文本
);
```

`FansPage` 同理，仅将 `followList` 替换为 `fanList`，标题替换为 `'${controller.name}的粉丝'`。

Controller 的注册使用 `tag: mid` 确保不同用户之间 Controller 实例隔离。

### 3.2 UserListPage 通用组件

**源文件：** `user_list_page.dart`

`UserListPage` 是一个 `StatefulWidget`，接收以下必需参数：

| 参数 | 类型 | 说明 |
|------|------|------|
| `title` | `String` | AppBar 标题 |
| `onRefresh` | `Future<void> Function()` | 下拉刷新回调 |
| `onLoad` | `Future<void> Function()` | 滚动加载更多回调 |
| `onInit` | `Future<void> Function()` | 初始化加载回调 |
| `userList` | `RxList<FollowingUser>` | 用户列表数据源 |
| `isLoading` | `RxBool` | 加载状态 |
| `hasMore` | `RxBool` | 是否还有更多 |
| `loadingText` | `RxString` | 底部加载文本 |

#### 组件结构

```
Scaffold
├── AppBar (title + back button)
└── body: RefreshIndicator
    └── Obx → 三种状态
        ├── [isLoading && userList.isEmpty] → CircularProgressIndicator
        ├── [userList.isEmpty] → NoData（空数据提示）
        └── [有数据] → ListView.builder
            ├── item[0..n-1]: ListTile
            │   ├── leading: Hero + NetworkImgLayer (40px 圆形头像)
            │   ├── title: 用户名（单行省略）
            │   └── onTap → Get.toNamed('/member?mid={uid}')
            └── item[n]: 底部加载状态文字（padding 60px）
```

#### 滚动监听

`_scrollController` 距底部 200px 时通过 `EasyThrottle` 防抖（1 秒）触发 `widget.onLoad()`。

#### 列表项交互

点击用户卡片 → `feedBack()` 触觉反馈 → `Get.toNamed('/member?mid=${user.uid}')` 跳转用户主页，携带 `face` 和 `heroTag` 实现 Hero 动画。

---

## 4. 数据流

```
┌─────────────────────────────┐
│  路由 /follow?mid=&name=    │
│  路由 /fan?mid=&name=       │
└─────────────┬───────────────┘
              │
    ┌─────────▼─────────┐
    │ Controller.onInit  │
    │ 解析 mid / name    │
    └─────────┬─────────┘
              │
    ┌─────────▼──────────────┐
    │ IUserRepository        │
    │ getFollowingList()     │  ← FollowController
    │ getFansList()          │  ← FanController
    │ (uid, offset, num:12)  │
    └─────────┬──────────────┘
              │
    ┌─────────▼─────────┐
    │ UserListPage      │
    │ ListView.builder  │
    │ 渲染 FollowingUser│
    └───────────────────┘
```

### 状态管理

| 状态 | 来源 | 使用方式 |
|------|------|----------|
| `followList` / `fanList` | Controller (RxList) | `Obx` 包裹列表区域 |
| `isLoading` | Controller (RxBool) | 控制首次加载的 loading 指示器 |
| `hasMore` | Controller (RxBool) | 控制是否允许加载更多 |
| `loadingText` | Controller (RxString) | 底部"加载中..."/"没有更多了"文本 |

### 分页逻辑

每次请求 `num = 12` 条。返回数据量 `< 12` 判定为到底，`hasMore = false`。每次加载成功后 `offset += users.length`，下一次以新 `offset` 请求。

---

## 5. 开发指南

### 5.1 新增用户列表类型（如"黑名单"）

1. 新建 `lib/pages/block/` 目录，复制 `fan/` 的 controller.dart 和 view.dart
2. 将 `getFansList` 替换为对应的 `IUserRepository` 黑名单接口
3. 在路由配置中添加 `/block` 路由
4. `UserListPage` 无需修改，直接复用

### 5.2 修改每页加载数量

在 Controller 中修改 `num` 常量。注意 API 限制最多 12 条，超过可能无效。

### 5.3 自定义列表项样式

修改 `UserListPage` 中 `ListView.builder` 的 `itemBuilder`。可添加关注按钮、等级徽章等额外 UI 元素。所有数据来自 `FollowingUser` 模型（`lib/ottohub/api/models/following.dart`）。

### 5.4 响应式适配

`UserListPage` 使用常规 `ListView`，已支持窄屏/宽屏自适应。如需添加横向网格布局，参考 `HotPage` 的 `SliverGrid` + `crossAxisCount` 模式。

---

## 6. 二改指南

### 6.1 常见需求

#### 在列表中显示"已关注"状态
`FollowingUser` 模型需包含 `isFollowed` 字段。在 `UserListPage` 的 `title` 右侧或 `ListTile` 末尾添加状态指示器。

#### 添加搜索筛选
在 `FollowPage` / `FansPage` 中包裹一层 `Column`，顶部添加 `TextField` 搜索框，下方放 `UserListPage`。Controller 的 `queryFollowings()` 需添加关键字参数。

#### 修改 Hero 动画 tag
在 `UserListPage` 中 `Utils.makeHeroTag(user.uid)` 的生成逻辑位于 `lib/utils/utils.dart`。

#### 调整滚动触发阈值
修改 `UserListPage._onScroll()` 中的 `maxScrollExtent - 200` 数值。

#### 修改底部加载提示
`loadingText` 的默认值为 "加载中..."，到底后设为 "没有更多了"。可直接修改 Controller 中的字符串或扩展为多语言。

### 6.2 注意事项

- 两个 Controller 使用 `tag: mid` 注册，确保同一用户在不同页面间实例隔离
- `UserListPage` 在 `initState` 时调用 `onInit()`，无需额外手动触发首次加载
- 路由参数 `name` 通过 `Uri.encodeComponent` 编码传入，Controller 使用 `_safeDecodeUri` 解码
- 未登录用户访问时，`mid` 默认为 `0`，`name` 为空字符串
- 下拉刷新通过 `RefreshIndicator` 实现，需确保 `onRefresh` 返回 `Future<void>`