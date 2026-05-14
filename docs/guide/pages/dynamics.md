---
date: 2026-05-14 22:50:22
title: dynamics
permalink: /pages/51b714
categories:
  - guide
  - pages
---
# 动态页（Dynamics）

## 1. 模块概述（含子模块结构图）

动态模块位于 `lib/pages/dynamics/`，是 PiliOtto 的核心社交模块，负责展示动态广场信息流和动态详情。支持最新/热门双 Tab 切换、瀑布流与居中两种宽屏布局、动态类型过滤、点赞评论等社交交互功能。

### 子模块结构图

```
lib/pages/dynamics/
├── controller.dart            # DynamicsController - 动态广场控制器
├── view.dart                  # DynamicsPage - 动态广场主页面
├── index.dart                 # 模块统一导出
├── widgets/                   # 动态卡片组件库
│   ├── dynamic_panel.dart     # DynamicPanel - 动态卡片容器
│   ├── author_panel.dart      # AuthorPanel - 作者信息面板
│   ├── content_panel.dart     # Content - 动态内容面板（文本+图片）
│   ├── action_panel.dart      # ActionPanel - 互动操作面板（评论/点赞/分享）
│   ├── pic_panel.dart         # picWidget - 图片网格展示（旧版）
│   ├── rich_node_panel.dart   # richNode - 富文本节点渲染
│   ├── blog_comment_input.dart # BlogCommentInput - 动态评论输入框
│   └── flat_reply_item.dart   # FlatReplyItem - 扁平回复列表项
└── detail/                    # 动态详情子模块
    ├── controller.dart        # DynamicDetailController - 详情控制器
    ├── view.dart              # DynamicDetailPage - 详情页面
    ├── header.dart            # DynamicDetailHeader - 详情头部
    └── index.dart             # 子模块统一导出
```

### 依赖关系

```
DynamicsPage (view.dart)
  ├── Get.put → DynamicsController (controller.dart)
  ├── IDynamicsRepository (getNewBlogs / getPopularBlogs / likeBlog)
  └── DynamicPanel (widgets/dynamic_panel.dart)
        ├── AuthorPanel → 作者头像 + 名称 + 发布时间
        ├── Content → MarkdownText + 图片网格
        └── ActionPanel → 评论 / 点赞 / 分享
              └── IDynamicsRepository.likeBlog()

DynamicDetailPage (detail/view.dart)
  ├── Get.put → DynamicDetailController (detail/controller.dart)
  ├── DynamicDetailHeader → 作者信息 + 内容 + 图片
  ├── BlogCommentInput → 评论输入
  ├── FlatReplyItem → 评论列表项
  └── ICommentRepository (getBlogComments / commentBlog / deleteBlogComment)
```

### 路由入口

| 路由 | 页面 | 说明 |
|------|------|------|
| `/dynamics` | `DynamicsPage` | 动态广场（最新/热门 Tab） |
| `/dynamicDetail` | `DynamicDetailPage` | 动态详情（评论列表 + 回复） |

跳转示例：
```dart
Get.toNamed('/dynamics');
Get.toNamed('/dynamicDetail', arguments: {
  'item': dynamicItemModel,
  'floor': 1,
  'action': 'comment',  // 可选，'comment' 时自动聚焦评论
});
```

---

## 2. DynamicsController 详解

**源文件：** `controller.dart`

`DynamicsController` 继承自 `GetxController`，管理动态广场的所有业务逻辑，包括最新/热门双 Tab 数据源、分页加载、动态类型过滤、瀑布流布局配置和轮询新动态通知。

### 2.1 依赖

| 依赖 | 来源 | 说明 |
|------|------|------|
| `IDynamicsRepository` | `Get.find<IDynamicsRepository>()` | 动态仓储接口，获取动态列表和点赞 |
| `GStrorage.userInfo` | Hive Box | 用户信息缓存，判断登录状态 |
| `GStrorage.setting` | Hive Box | 设置持久化，读写布局偏好 |

### 2.2 Rx 响应式状态

| 状态变量 | 类型 | 初始值 | 说明 |
|----------|------|--------|------|
| `dynamicsList` | `RxList<DynamicItemModel>` | `[]` | 当前 Tab 的动态列表 |
| `dynamicsType` | `Rx<DynamicsType>` | `DynamicsType.values[0]` | 动态类型过滤（全部/视频/专栏/文章） |
| `dynamicsTypeLabel` | `RxString` | `'全部'` | 类型过滤标签文本 |
| `currentTab` | `RxString` | `'latest'` | 当前 Tab（'latest' 最新 / 'popular' 热门） |
| `hasMore` | `RxBool` | `true` | 是否还有更多数据 |
| `userLogin` | `RxBool` | `false` | 用户是否已登录 |
| `newDynamicsCount` | `RxInt` | `0` | 新动态数量（轮询检测） |
| `wideScreenLayout` | `RxString` | `'center'` | 宽屏布局模式（'center' 居中 / 'waterfall' 瀑布流） |
| `waterfallCrossAxisCount` | `RxInt` | `3` | 瀑布流列数（2~6） |
| `waterfallLimitWidth` | `RxBool` | `false` | 是否限制瀑布流宽度 |
| `waterfallCustomItemWidth` | `RxDouble` | `300.0` | 自定义卡片宽度（200~600） |
| `waterfallUseCustomItemWidth` | `RxBool` | `false` | 是否启用自定义卡片宽度 |

### 2.3 双 Tab 数据缓存

Controller 为"最新"和"热门"两个 Tab 维护独立的缓存体系：

| 缓存 Map | Key | Value | 说明 |
|----------|-----|-------|------|
| `_tabDataCache` | `'latest'` / `'popular'` | `List<DynamicItemModel>` | 每个 Tab 的数据缓存 |
| `_tabOffsetCache` | `'latest'` / `'popular'` | `int` | 每个 Tab 的分页 offset |
| `_tabHasLoadedCache` | `'latest'` / `'popular'` | `bool` | 每个 Tab 是否已加载过 |
| `tabLoadingStates` | `'latest'` / `'popular'` | `RxBool` | 每个 Tab 的加载状态 |
| `tabScrollControllers` | `'latest'` / `'popular'` | `ScrollController` | 每个 Tab 的滚动控制器 |

**Tab 切换逻辑 (`onTabChanged`)：**

```
切换到新 Tab
  ├── 如果已加载且有缓存数据
  │     ├── dynamicsList = 缓存数据
  │     └── hasMore = 缓存长度 % 10 == 0
  └── 如果未加载
        ├── hasMore = true
        └── queryFollowDynamic(type: 'init')  // 发起新请求
```

### 2.4 分页机制

```dart
Future<void> queryFollowDynamic({String type = 'init'})

// type='init'  → 重置 offset=0，替换数据
// type='onLoad' → 追加数据，offset += 10
```

每次请求 10 条数据，offset 递增步长为 10：

| 请求 | offset | 数据量 | 处理方式 |
|------|--------|--------|----------|
| init | 0 | 10 | 替换 `_tabDataCache[tab]` |
| onLoad 1 | 10 | 10 | 追加到 `_tabDataCache[tab]` |
| onLoad 2 | 20 | 10 | 追加 |
| ... | ... | ... | ... |

### 2.5 轮询新动态机制

Controller 在 `onInit` 时启动 30 秒间隔的轮询定时器：

```
_startPolling()
  └── Timer.periodic(30s) → _checkForNewDynamics()
        ├── 仅在 currentTab == 'latest' 时执行
        ├── 请求最新 10 条动态
        ├── 记录第一条的 idStr 为 _latestDynamicId
        ├── 下次轮询时比较 idStr
        └── 如果有变化 → 计算新动态数量 → 更新 newDynamicsCount.obs
```

**用户点击"新动态"横幅时：**
```
loadNewDynamics()
  ├── feedBack()  // 触觉反馈
  ├── newDynamicsCount = 0
  ├── queryFollowDynamic(type: 'init')  // 刷新数据
  └── scrollToTop()  // 滚动到顶部
```

### 2.6 瀑布流布局计算

Controller 提供完整的瀑布流布局参数计算系统：

```
核心计算流程:
  updateWaterfallCache(screenWidth)
    ├── calculateAutoCrossAxisCount(screenWidth, minItemWidth=300)
    │     └── (screenWidth / minItemWidth).floor().clamp(2, 6)
    │
    ├── 计算 itemWidth
    │     ├── 自定义宽度 → waterfallCustomItemWidth
    │     └── 自动计算 → (screenWidth - spacing) / autoCrossAxisCount
    │
    └── 计算 effectiveCrossAxisCount
          ├── 限制宽度 → waterfallCrossAxisCount.clamp(2, autoCount)
          └── 不限制 → autoCrossAxisCount
```

**缓存优化：** 当屏幕宽度变化小于 1px 时复用缓存结果，避免重复计算。

| 方法 | 返回 | 说明 |
|------|------|------|
| `calculateAutoCrossAxisCount` | `int` | 根据屏幕宽度自动计算最优列数 |
| `calculateItemWidth` | `double` | 根据列数计算每项宽度 |
| `getEffectiveItemWidth` | `double` | 获取实际使用的项宽度 |
| `updateWaterfallCache` | `void` | 更新瀑布流缓存（去抖） |

### 2.7 动态类型过滤

`filterTypeList` 定义可过滤的动态类型：

| 类型枚举 | 标签 | 说明 |
|----------|------|------|
| `DynamicsType.all` | 全部 | 所有类型 |
| `DynamicsType.video` | 视频 | 视频动态 |
| `DynamicsType.pgc` | PGC | 专业生产内容 |
| `DynamicsType.article` | 文章 | 图文动态 |

### 2.8 动态详情跳转

```dart
Future<bool> pushDetail(DynamicItemModel item, int floor, {String action = 'all'})
```

| 动态类型 | 跳转行为 |
|----------|----------|
| `DYNAMIC_TYPE_DRAW` | 跳转 `/dynamicDetail` |
| `DYNAMIC_TYPE_WORD` | 跳转 `/dynamicDetail` |
| 其他类型 | 显示 Toast "暂不支持的动态类型" |

若 `action == 'comment'`，跳转后详情页会自动聚焦评论输入。

---

## 3. DynamicsView 详解

**源文件：** `view.dart`

`DynamicsPage` 是一个 `StatefulWidget`，使用 `AutomaticKeepAliveClientMixin` 保持 Tab 页面状态，使用 `TabBar` + `TabBarView` 实现最新/热门双 Tab。

### 3.1 页面结构

```
Scaffold
└── Column
      ├── _buildHeader          // 标题"动态" + 宽屏布局切换按钮 + 编辑按钮
      ├── TabBar                // "最新" | "热门"（isScrollable: true）
      └── Expanded
            └── TabBarView
                  ├── _TabPage(tab: 'latest')
                  └── _TabPage(tab: 'popular')
```

### 3.2 _buildHeader

| 元素 | 说明 |
|------|------|
| 标题文字 | "动态"，使用 `titleLarge` + `bold` |
| 宽屏布局按钮 | 仅在宽屏显示，`toggleWideScreenLayout()`，长按弹出瀑布流配置对话框 |
| 编辑按钮 | 占位按钮，当前无实际功能 |

### 3.3 Tab 交互

```
_onTapTab(index)
  ├── 如果点击当前 Tab → scrollToTop()  // 双击回到顶部
  ├── _tabController.animateTo(index)     // 切换动画
  └── dynamicsController.onTabChanged(tab) // 切换数据源
```

### 3.4 _TabPage 内部状态组件

`_TabPage` 是 `StatefulWidget`，使用 `AutomaticKeepAliveClientMixin` 保持状态，根据布局模式渲染不同列表：

**居中布局 (`_buildCenteredList`)：**
- 使用 `ListView.builder`
- 最大内容宽度 600px，宽屏下水平居中
- 第 0 项：新动态通知横幅（`_buildNewDynamicsBanner`）
- `index - 1` 项：DynamicPanel 卡片
- 末尾项：加载指示器
- 通过 `ScrollUpdateNotification` 监听底部 200px 触发加载更多（带 `EasyThrottle` 节流）

**瀑布流布局 (`_buildWaterfallList`)：**
- 使用 `SliverMasonryGrid.count`，列数由 `cachedEffectiveCrossAxisCount` 决定
- 最大内容宽度 1600px，超出部分加侧边 padding
- 限制宽度模式下根据列数和项宽计算居中 offset
- 同样包含新动态横幅和加载指示器

**骨架屏 (`_buildSkeletonList`)：**
- 居中布局：5 个 `DynamicCardSkeleton`
- 瀑布流布局：`WaterfallSkeleton(widget)` 对应列数

### 3.5 新动态横幅 (`_buildNewDynamicsBanner`)

仅在 `tab == 'latest'` 且 `newDynamicsCount > 0` 时显示：
- 使用 `primaryContainer` 背景色
- 显示向上箭头图标 + "N 条新动态"文字
- 点击触发 `loadNewDynamics()`，刷新数据并滚动到顶部

### 3.6 瀑布流配置对话框 (`_showWaterfallConfigDialog`)

长按宽屏布局按钮弹出，提供以下配置项：

| 配置项 | 控件 | 说明 |
|--------|------|------|
| 限制宽度 | `SwitchListTile` | 启用后可自定义列数 |
| 自定义卡片宽度 | `SwitchListTile` | 是否启用自定义宽度 |
| 卡片宽度滑块 | `Slider` (200~600) | 仅在启用自定义宽度时显示 |
| 列数选择 | `DropdownButton` (2~autoCount) | 仅在限制宽度时显示 |

---

## 4. Widgets 组件详解

### 4.1 DynamicPanel（动态卡片容器）

**源文件：** `widgets/dynamic_panel.dart`

`DynamicPanel` 是动态卡片的顶层容器组件，将 AuthorPanel、Content 和 ActionPanel 组合为一张 Material Card。

```dart
class DynamicPanel extends StatelessWidget {
  final DynamicItemModel item;    // 动态数据模型
  final String? source;          // 来源（'detail' 时不显示 ActionPanel）
  final VoidCallback? onTap;     // 点击卡片回调
  final VoidCallback? onCommentTap; // 点击评论按钮回调
}
```

**布局结构：**

```
Card (圆角 16，outlineVariant 边框)
└── InkWell (onTap)
      └── Padding(12)
            └── Column
                  ├── AuthorPanel(item)
                  ├── if 有内容: SizedBox(10) + Content(item, source)
                  ├── SizedBox(4)
                  └── if source != 'detail': ActionPanel(item, onCommentTap)
```

### 4.2 AuthorPanel（作者信息面板）

**源文件：** `widgets/author_panel.dart`

展示动态发布者的头像、标题和发布时间。

```
Row
├── GestureDetector (onTap → /member?mid=xxx)
│     └── Container (圆形边框, primaryContainer 2px)
│           └── ClipOval → NetworkImgLayer (width:44, height:44, type:'avatar')
└── SizedBox(12)
      └── Expanded
            └── Column
                  ├── Text (title, titleSmall + bold, maxLines:2)
                  └── Text (pubTime, bodySmall + outline)
```

### 4.3 ContentPanel（内容面板）

**源文件：** `widgets/content_panel.dart`

展示动态的文字内容和图片。

**文本渲染：**
- 使用 `MarkdownText` 组件渲染
- 非详情模式下限制 `maxLines: 4`
- 详情模式下 `maxLines: null`（不限行数）
- 包裹在 `Hero(tag: 'content_$dynamicId')` 中实现共享元素动画

**图片渲染（`_buildPicsGrid`）：**

| 图片数量 | 布局方式 | 说明 |
|----------|----------|------|
| 1 张 | 单图模式 | 宽度 = maxWidth，高度 = 60% 宽度 |
| 2 张 | Wrap，2 列 | 方形裁剪 |
| 3+ 张 | Wrap，3 列 | 最多展示 9 张，方形裁剪 |

所有图片支持点击预览，通过 `InteractiveviewerGallery` 实现全屏图片浏览。

### 4.4 ActionPanel（互动操作面板）

**源文件：** `widgets/action_panel.dart`

显示评论、点赞、分享三个操作按钮及其计数。

```
Row
├── _ActionButton (评论, FontAwesomeIcons.comment, commentCount)
├── _ActionButton (点赞, thumbsUp/solidThumbsUp, likeCount, isActive)
└── _ActionButton (分享, shareFromSquare, forwardCount)
```

**点赞逻辑 (`onLikeDynamic`)：**
```
点击点赞按钮
  ├── 防重复点击 (isProcessing)
  ├── 调用 _dynamicsRepo.likeBlog(bid)
  ├── 成功后更新本地状态:
  │     ├── isLiked = !isLiked
  │     └── likeCount = isLiked ? count+1 : count-1
  └── 显示 Toast ("点赞成功" / "取消点赞")
```

**`_ActionButton` 私有组件：**
- `Expanded` 包裹，等宽分布
- 图标尺寸 16px（支持 `FaIconData` 和 `IconData` 两种类型）
- 激活态使用 `primary` 颜色

### 4.5 PicPanel（图片网格 - 旧版）

**源文件：** `widgets/pic_panel.dart`

旧版图片展示组件，提供 `picWidget` 和 `onPreviewImg` 两个顶层函数。

**`picWidget(item, context)` - 图片网格 Widget：**
- 支持 `MAJOR_TYPE_DRAW` 类型的图片
- `MAJOR_TYPE_OPUS` 类型返回空 SizedBox（与 rich_node_panel 避免重复）
- 单图模式：根据原始宽高比计算高度，长图（高度 > 屏幕 90%）显示"长图"角标
- 多图模式：使用 `GridView.count`，3 列方形布局

**`onPreviewImg(url, picList, index, context, heroTagBuilder)` - 图片预览：**
- 使用 `HeroDialogRoute` + `InteractiveviewerGallery` 实现全屏预览

### 4.6 RichNodePanel（富文本节点）

**源文件：** `widgets/rich_node_panel.dart`

`richNode(item, context)` 函数将动态的标题和正文组合为 `InlineSpan`：

```dart
InlineSpan richNode(dynamic item, BuildContext context) {
  // 提取 desc.title 和 desc.text
  // 组合为 TextSpan:
  //   [title] (titleMedium, bold, height:1.4)
  //   \n\n
  //   [text]  (height:1.65)
  // 异常时返回 _VerticalSpaceSpan(0) 空白占位
}
```

### 4.7 BlogCommentInput（评论输入框）

**源文件：** `widgets/blog_comment_input.dart`

动态评论区底部的固定输入框组件。

**参数：**
| 参数 | 类型 | 说明 |
|------|------|------|
| `bid` | `int` | 动态 ID |
| `parentBcid` | `int`（默认 0） | 父评论 ID（回复评论时使用） |
| `placeholder` | `String?` | 输入框占位文字 |
| `onCommentSuccess` | `Function()?` | 评论成功后的回调 |

**提交逻辑：**
```
_submitComment()
  ├── 空内容校验 → Toast "请输入评论内容"
  ├── 登录校验 (_token 检查) → Toast "请先登录"
  ├── 调用 _commentRepo.commentBlog(bid, parentBcid, content)
  ├── 成功 → Toast "评论成功喵~" → 清空输入 → 收起键盘 → onCommentSuccess
  └── 失败 → Toast 显示错误信息
```

**UI 特性：**
- 圆角输入框（`surfaceContainerHighest` 背景）
- 发送按钮：有内容时 `primary` 颜色，无内容时 `surfaceContainerHigh` 灰色
- 键盘弹起时自动上移（`AnimatedPadding` 跟随 `viewInsets.bottom`）

### 4.8 FlatReplyItem（扁平回复项）

**源文件：** `widgets/flat_reply_item.dart`

评论列表中的单条评论展示组件。

**结构：**

```
Container
└── Column
      ├── _buildHeader       // 头像 + 用户名 + VIP 标识 + 荣誉标签 + UP 角标 + 时间
      ├── _buildContent      // 评论文本 (MarkdownText, maxLines:6 / 不限行)
      ├── _buildExpandButton // 长文本展开/收起按钮
      ├── _buildBottomAction // UP点赞标识 / 热评标识 / 回复按钮
      └── _buildReplyRow     // 子回复预览（最多 3 条） + "查看更多回复"
```

**交互功能：**

| 操作 | 行为 |
|------|------|
| 点击头像/用户名 | 跳转 `/member?mid=xxx` |
| 点击"展开/收起" | 切换内容行数限制（带箭头旋转动画） |
| 点击"回复" | 触发 `onReply` 回调 |
| 点击"更多"菜单 | 弹出 PopupMenu（复制 / 删除（仅自己的评论）） |
| 点击子回复 | 触发 `onReply` 回调（带子回复参数） |
| 点击"查看更多回复" | 触发 `onReply` 回调（loadMore 模式） |

**删除确认流程：**
```
点击"删除"
  └── AlertDialog 确认
        └── 确认 → _commentRepo.deleteBlogComment(bcid) / deleteVideoComment(vcid)
              ├── 成功 → Toast "删除成功" → onRefresh
              └── 失败 → Toast 显示错误
```

---

## 5. DynamicsDetail 详解

### 5.1 DynamicDetailController

**源文件：** `detail/controller.dart`

`DynamicDetailController` 管理动态详情页的评论列表数据。

**构造函数参数：**
- `oid`（`int?`）：动态 ID

**Rx 状态：**

| 状态变量 | 类型 | 初始值 | 说明 |
|----------|------|--------|------|
| `replyList` | `RxList<ReplyItemModel>` | `[]` | 评论列表 |
| `isLoadingMore` | `RxBool` | `false` | 加载更多中 |
| `noMore` | `RxString` | `''` | 加载状态文本 |
| `acount` | `RxInt` | `0` | 评论总数 |
| `replyingTo` | `Rxn<ReplyItemModel>` | `null` | 当前正在回复的评论 |
| `parentBcid` | `RxInt` | `0` | 父评论 ID |

**核心方法：**

`queryReplyList({String reqType = 'init'})`：
- `init` → 重置 offset，清空列表，请求 12 条评论
- `onLoad` → 追加 12 条评论，offset += 12
- 返回 < 12 条时 `noMore = '没有更多了'`
- offset == 0 且无评论时 `noMore = '还没有评论'`

`setReplyingTo(replyItem, {parent})` / `clearReplyingTo()`：
- 设置/清除当前回复目标，影响评论输入框的 `parentBcid` 和占位文字

### 5.2 DynamicDetailPage

**源文件：** `detail/view.dart`

详情页使用 `Scaffold` + `AppBar` + 底部评论输入的布局。

**AppBar 特性：**
- 使用 `StreamController<bool>` 控制标题显示
- 滚动超过 55px 时，AppBar 显示 `AuthorPanel`（渐显动画）
- `scrolledUnderElevation: 1`

**主内容区域：**

```
ListView.builder (padding 自适应居中，maxWidth=600)
├── index 0: DynamicDetailHeader (非 comment action 时显示)
├── index 1: _buildCommentHeader (评论数 + 取消回复按钮)
├── index 2~n: FlatReplyItem (评论项)
└── 末尾: _buildLoadingIndicator (加载中 / 没有更多了 / 还没有评论)
```

**滚动交互：**
- `ScrollUpdateNotification` 监听，距离底部 300px 时加载更多（EasyThrottle 2s 节流）
- 滚动方向检测：向下滚动隐藏 FAB，向上滚动显示 FAB（`fabAnimationCtr` 动画控制）

**底部评论输入：**
- `BlogCommentInput` 固定底部
- `parentBcid` 和 `placeholder` 由 `replyingTo` 状态决定
- 评论成功后调用 `onReplySuccess()`：清除回复状态、重新加载评论、评论数 +1

### 5.3 DynamicDetailHeader

**源文件：** `detail/header.dart`

详情页头部组件，展示作者信息和完整动态内容。

**结构：**

```
Padding(16)
└── Column
      ├── _buildAuthorSection (头像 + 标题 + 时间)
      ├── if 有文本: Hero(tag:'content_$id') → MarkdownText (selectable:true)
      └── if 有图片: _buildPicsGrid (单图 / 多图网格 + 预览)
```

与列表页 `Content` 组件的区别：
- 文本 `selectable: true`（可选择复制）
- 文本 `maxLines: null`（不限行数）
- 不包含 `ActionPanel`

---

## 6. 数据流

### 6.1 动态广场数据流

```
┌─────────────────────────────────────┐
│  DynamicsPage.onInit()              │
│  queryFollowDynamic()               │
└───────────────┬─────────────────────┘
                ▼
┌─────────────────────────────────────┐
│  DynamicsController                 │
│  ├── queryFollowDynamic('init')     │
│  │     ├── currentTab='latest'      │
│  │     │     └── _queryLatestBlogs  │
│  │     │           → _dynamicsRepo  │
│  │     │               .getNewBlogs │
│  │     └── currentTab='popular'     │
│  │           └── _queryPopularBlogs │
│  │               → _dynamicsRepo   │
│  │                   .getPopular    │
│  │                     Blogs        │
│  └── 写入 _tabDataCache +          │
│       更新 dynamicsList.obs         │
└───────────────┬─────────────────────┘
                ▼
┌─────────────────────────────────────┐
│  Obx 触发 _TabPage 重建             │
│  ├── 居中布局 → ListView.builder    │
│  │     └── DynamicPanel(item)       │
│  └── 瀑布流 → SliverMasonryGrid     │
│        └── DynamicPanel(item)       │
└─────────────────────────────────────┘
```

### 6.2 详情页数据流

```
┌─────────────────────────────────┐
│  DynamicDetailPage.init()       │
│  ├── 解析路由参数                │
│  ├── DynamicDetailController    │
│  └── queryReplyList('init')     │
└───────────────┬─────────────────┘
                ▼
┌─────────────────────────────────┐
│  DynamicDetailController        │
│  _commentRepo.getBlogComments   │
│  (bid, offset=0, num=12)        │
└───────────────┬─────────────────┘
                ▼
┌─────────────────────────────────┐
│  OttohubCommentRepository       │
│  → LegacyApiService             │
└───────────────┬─────────────────┘
                ▼
┌─────────────────────────────────┐
│  replyList.obs 更新              │
│  Obx → ListView 渲染            │
│    FlatReplyItem(replyItem)     │
└─────────────────────────────────┘
```

### 6.3 点赞数据流

```
用户点击点赞
  → ActionPanel.onLikeDynamic()
      → _dynamicsRepo.likeBlog(bid)
          → 成功后本地更新:
              isLiked = !isLiked
              likeCount = count±1
```

### 6.4 评论数据流

```
用户输入评论 → BlogCommentInput._submitComment()
  → _commentRepo.commentBlog(bid, parentBcid, content)
      → 成功 → onCommentSuccess()
          → DynamicDetailController.onReplySuccess()
              → clearReplyingTo()
              → queryReplyList('init')  // 重新加载评论
              → acount++

用户删除评论 → FlatReplyItem._handleMenuAction('delete')
  → 确认对话框
      → _commentRepo.deleteBlogComment(bcid)
          → 成功 → onRefresh
              → queryReplyList('init')
```

---

## 7. 使用示例

### 7.1 DynamicsController 基本使用

```dart
import 'package:get/get.dart';
import 'package:piliotto/pages/dynamics/controller.dart';

class DynamicsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DynamicsController>();
    
    return Obx(() => Column(
      children: [
        Text('动态类型: ${controller.dynamicsType.value}'),
        Text('加载状态: ${controller.isLoading.value}'),
        Text('动态数量: ${controller.dynamicsList.length}'),
      ],
    ));
  }
}
```

### 7.2 动态列表加载

```dart
void loadDynamics(DynamicsController controller) {
  controller.queryDynamics('init');
}

void loadMoreDynamics(DynamicsController controller) {
  controller.queryDynamics('loadMore');
}

void refreshDynamics(DynamicsController controller) {
  controller.onRefresh();
}
```

### 7.3 动态类型切换

```dart
void switchDynamicsType(DynamicsController controller, String type) {
  controller.dynamicsType.value = type;
  controller.queryDynamics('init');
}

void filterByAuthor(DynamicsController controller, int mid) {
  controller.mid = mid;
  controller.queryDynamics('init');
}
```

### 7.4 动态交互操作

```dart
void toggleLike(DynamicsController controller, String dynamicId) {
  controller.dynamicLike(
    dynamicId: dynamicId,
    isLike: true,
  );
}

void navigateToDetail(DynamicsController controller, String dynamicId) {
  Get.toNamed('/dynamicDetail?id=$dynamicId');
}
```

---

## 8. 开发指南

### 8.1 如何添加新的动态类型支持

当前仅支持 `DYNAMIC_TYPE_DRAW` 和 `DYNAMIC_TYPE_WORD` 两种类型。要添加新类型（如 `DYNAMIC_TYPE_AV`、`DYNAMIC_TYPE_ARTICLE`）：

**步骤 1：在 Controller 中注册类型**

```dart
// controller.dart pushDetail 方法
switch (item.type) {
  case 'DYNAMIC_TYPE_DRAW':
  case 'DYNAMIC_TYPE_WORD':
  case 'DYNAMIC_TYPE_AV':        // 新增
    Get.toNamed('/dynamicDetail',
        arguments: {'item': item, 'floor': floor});
    break;
  // ...
}
```

**步骤 2：在 DynamicDetailHeader 中处理新类型的内容渲染**

根据新类型的 `major` 结构，在 `header.dart` 中添加对应的渲染逻辑。

### 8.2 如何添加新的过滤类型

```dart
// controller.dart filterTypeList
{
  'label': DynamicsType.live.labels,     // 新增直播类型
  'value': DynamicsType.live,
  'enabled': true
},
```

同时在 `DynamicsType` 枚举中添加对应值。

### 8.3 如何修改每页加载数量

修改 Controller 中的硬编码值：

```dart
// controller.dart queryFollowDynamic 方法中
_tabOffsetCache[tab] = 10;   // offset 步长改为 20
// ...
hasMore.value = items.length >= 10;  // 判断阈值同步修改
```

同步修改 `_queryLatestBlogs` 和 `_queryPopularBlogs` 中的 `num:` 参数。

### 8.4 如何修改轮询间隔

```dart
// controller.dart
static const Duration _pollInterval = Duration(seconds: 30);
// 改为 60 秒、120 秒等
static const Duration _pollInterval = Duration(seconds: 60);
```

禁用轮询：在 `onInit` 中注释掉 `_startPolling()`。

### 8.5 如何添加分享功能

当前 ActionPanel 中的分享按钮无实际功能（`onTap: () {}`）。实现分享功能：

**步骤 1：在 ActionPanel 中添加分享逻辑**

```dart
Future<void> onShareDynamic() async {
  final dynamicId = widget.item.idStr ?? '';
  final title = widget.item.modules?.moduleDynamic?.desc?.title ?? '';
  // 使用 share_plus 或其他分享库
  await Share.share('$title\nhttps://...');
}
```

**步骤 2：绑定到分享按钮**
修改 ActionPanel 中分享 `_ActionButton` 的 `onTap`。

### 8.6 如何自定义瀑布流默认配置

修改 Controller 的 `onInit` 中的默认值：

```dart
// controller.dart onInit()
waterfallCrossAxisCount.value = setting.get(
  SettingBoxKey.waterfallCrossAxisCount,
  defaultValue: 4,  // 默认 4 列
);
waterfallCustomItemWidth.value = setting.get(
  SettingBoxKey.waterfallCustomItemWidth,
  defaultValue: 350.0,  // 默认 350px
);
```

---

## 9. 二改指南

### 9.1 替换动态数据源

与 Repository 模式一致，只需替换 `IDynamicsRepository` 的实现：

```dart
// controller.dart
final IDynamicsRepository _dynamicsRepo = Get.find<IDynamicsRepository>();
```

在 `main.dart` 中替换注册：

```dart
Get.put<IDynamicsRepository>(NewSourceDynamicsRepository());
```

### 9.2 替换评论数据源

评论功能通过 `ICommentRepository` 解耦：

```dart
// detail/controller.dart
final ICommentRepository _commentRepo = Get.find<ICommentRepository>();

// widgets/blog_comment_input.dart
final ICommentRepository _commentRepo = Get.find<ICommentRepository>();

// widgets/flat_reply_item.dart
final ICommentRepository _commentRepo = Get.find<ICommentRepository>();
```

只需替换 `main.dart` 中的注册即可。

### 9.3 完全替换 Tab 架构

如果要移除双 Tab 架构，改为单数据源：

1. 移除 `_tabController` 和 TabBar/TabBarView
2. 移除 `_tabDataCache`、`_tabOffsetCache` 等缓存 Map
3. 简化为单一 `dynamicsList` + `queryFollowDynamic`
4. 移除 `onTabChanged` 方法

### 9.4 修改动态卡片样式

`DynamicPanel` 使用 `Card` + `RoundedRectangleBorder`。要修改卡片样式：

```dart
// widgets/dynamic_panel.dart
return Card(
  elevation: 2,                              // 添加阴影
  margin: const EdgeInsets.symmetric(...),   // 添加外边距
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),  // 修改圆角
  ),
  // ...
);
```

### 9.5 移除瀑布流布局功能

1. 在 Controller 中删除瀑布流相关的 Rx 状态和计算方法
2. 在 View 中移除瀑布流开关按钮和配置对话框
3. 在 `_TabPage._buildContentList` 中移除瀑布流分支，始终使用居中布局

### 9.6 替换图片预览组件

当前使用 `InteractiveviewerGallery`（来自 `pl_gallery` 插件）。如需替换：

**在 `content_panel.dart` 和 `detail/header.dart` 中：**

```dart
void onPreviewImg(int initIndex) {
  // 替换为新的图片查看器
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => NewImageViewer(
        images: picList,
        initialIndex: initIndex,
      ),
    ),
  );
}
```

### 9.7 替换评论列表 UI

当前评论列表使用 `FlatReplyItem`。如需替换为自定义评论组件：

1. 创建新的评论组件（可参考 `FlatReplyItem` 的接口）
2. 在 `DynamicDetailPage` 的 `ListView.builder` 中替换

```dart
CustomCommentItem(     // 替换 FlatReplyItem
  replyItem: replyList[replyIndex],
  onReply: (replyItem) { ... },
  onDelete: () { ... },
);
```