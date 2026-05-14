---
date: 2026-05-14 22:24:28
title: common
permalink: /pages/27621a
categories:
  - guide
  - core
---
# 通用组件层 (Common)

## 1. 模块概述

通用组件层 (`lib/common/`) 是 PiliOtto 的 UI 基础组件库，包含所有页面共享的可复用 Widget、骨架屏（Skeleton Screen）系统、Mixin 混入、应用常量定义以及公共弹窗。

该层遵循 **DRY（Don't Repeat Yourself）** 原则，将项目中频繁使用的 UI 模式抽象为独立组件，保证一致的用户体验和开发效率。

### 目录结构

```
lib/common/
├── constants.dart                # 应用常量（API Key、样式常量）
├── pages_bottom_sheet.dart       # 分集/合集底部弹窗
├── mixins/
│   └── scroll_to_top.dart        # 滚动到顶部 Mixin
├── skeleton/                     # 骨架屏加载占位
│   ├── skeleton.dart             # 骨架屏核心引擎（Shimmer 动画）
│   ├── dynamic_card.dart         # 动态卡片骨架屏 + 瀑布流骨架屏
│   ├── media_bangumi.dart        # 番剧卡片骨架屏
│   ├── video_card_h.dart         # 横向视频卡片骨架屏
│   ├── video_card_v.dart         # 纵向视频卡片骨架屏
│   ├── video_intro.dart          # 视频简介骨架屏
│   └── video_reply.dart          # 视频评论骨架屏
└── widgets/                      # 可复用 UI 组件
    ├── stat/
    │   ├── danmu.dart            # 弹幕统计组件
    │   └── view.dart             # 播放量统计组件
    ├── animated_dialog.dart      # 动画弹窗
    ├── app_expansion_panel_list.dart # 可展开面板列表
    ├── appbar.dart               # 自定义 AppBar（带滑入滑出动画）
    ├── badge.dart                # 徽标组件
    ├── content_container.dart    # 内容容器
    ├── custom_toast.dart         # 自定义 Toast
    ├── html_render.dart          # HTML 渲染组件
    ├── http_error.dart           # HTTP 错误提示
    ├── limited_waterfall.dart    # 限制宽度瀑布流布局
    ├── live_card.dart            # 直播卡片
    ├── markdown_text.dart        # Markdown/Html 智能文本渲染
    ├── network_img_layer.dart    # 网络图片组件（缓存+占位）
    ├── no_data.dart              # 空数据提示
    ├── page_widgets.dart         # 页面级组件（ErrorPage, LoadingPage, TabBar）
    ├── responsive_layout.dart    # 响应式布局系统
    ├── sliver_header.dart        # Sliver 头部代理
    ├── user_drawer.dart          # 用户侧边栏抽屉
    ├── user_list_page.dart       # 用户列表通用页面
    ├── video_card_h.dart         # 横向视频卡片
    └── video_card_v.dart         # 纵向视频卡片
```

---

## 2. 完整组件清单

### 2.1 核心展示组件

| 组件 | 文件 | 类型 | 说明 |
|------|------|------|------|
| `VideoCardH` | `widgets/video_card_h.dart` | StatelessWidget | 横向视频卡片（含排名、时长、更多面板） |
| `VideoCardV` | `widgets/video_card_v.dart` | StatelessWidget | 纵向视频卡片（含统计、自适应列数） |
| `LiveCard` | `widgets/live_card.dart` | StatelessWidget | 直播卡片（含在线人数） |
| `NetworkImgLayer` | `widgets/network_img_layer.dart` | StatelessWidget | 网络图片封装（缓存、占位、质量参数） |
| `UserDrawer` | `widgets/user_drawer.dart` | StatelessWidget | 用户侧边栏（头像、数据、菜单） |
| `UserListPage` | `widgets/user_list_page.dart` | StatefulWidget | 通用用户列表页（关注/粉丝） |

### 2.2 交互与反馈组件

| 组件 | 文件 | 类型 | 说明 |
|------|------|------|------|
| `AppBarWidget` | `widgets/appbar.dart` | StatelessWidget | 带滑动隐藏动画的 AppBar |
| `CustomToast` | `widgets/custom_toast.dart` | StatelessWidget | 圆角 Toast（可调透明度） |
| `AnimatedDialog` | `widgets/animated_dialog.dart` | StatefulWidget | 缩放+淡入动画弹窗 |
| `PBadge` | `widgets/badge.dart` | StatelessWidget | 徽标（角标/行内，多风格） |
| `HttpError` | `widgets/http_error.dart` | StatelessWidget | 网络错误重试页 |
| `NoData` | `widgets/no_data.dart` | StatelessWidget | 空数据占位页 |
| `ErrorPage` | `widgets/page_widgets.dart` | StatelessWidget | 错误页面（含重试按钮） |
| `LoadingPage` | `widgets/page_widgets.dart` | StatelessWidget | 加载中页面 |
| `EpisodeBottomSheet` | `pages_bottom_sheet.dart` | 类 | 集数/分P选择底部弹窗 |

### 2.3 文本与内容组件

| 组件 | 文件 | 说明 |
|------|------|------|
| `HtmlRender` | `widgets/html_render.dart` | HTML 内容渲染（含图片点击放大、代码高亮） |
| `MarkdownText` | `widgets/markdown_text.dart` | 智能 Markdown/Html 渲染（自动检测格式） |
| `StatView` | `widgets/stat/view.dart` | 播放量统计（图标+格式化数字） |
| `StatDanMu` | `widgets/stat/danmu.dart` | 弹幕数统计（图标+格式化数字） |

### 2.4 布局组件

| 组件 | 文件 | 说明 |
|------|------|------|
| `ResponsiveLayout` | `widgets/responsive_layout.dart` | 居中式响应式容器 |
| `ResponsiveGridView` | `widgets/responsive_layout.dart` | 响应式网格视图 |
| `ResponsiveGridItem` | `widgets/responsive_layout.dart` | 响应式网格项 |
| `ResponsiveText` | `widgets/responsive_layout.dart` | 响应式文字 |
| `LimitedWaterfall` | `widgets/limited_waterfall.dart` | 限制最大宽度的瀑布流 |
| `LimitedWaterfallGrid` | `widgets/limited_waterfall.dart` | 限制最大宽度的固定列瀑布流 |
| `ContentContainer` | `widgets/content_container.dart` | 可滚动内容容器 |
| `AppExpansionPanelList` | `widgets/app_expansion_panel_list.dart` | 自定义可展开面板列表 |
| `SliverHeaderDelegate` | `widgets/sliver_header.dart` | 自定义 Sliver 头部代理 |
| `SliverTabBarDelegate` | `widgets/page_widgets.dart` | Sliver 中的 TabBar 代理 |

### 2.5 骨架屏组件（Skeleton）

| 组件 | 文件 | 模拟目标 |
|------|------|----------|
| `Skeleton` | `skeleton/skeleton.dart` | 骨架屏基础引擎（Shimmer 动画） |
| `VideoCardHSkeleton` | `skeleton/video_card_h.dart` | 横向视频卡片 |
| `VideoCardVSkeleton` | `skeleton/video_card_v.dart` | 纵向视频卡片 |
| `DynamicCardSkeleton` | `skeleton/dynamic_card.dart` | 动态卡片 |
| `WaterfallSkeleton` | `skeleton/dynamic_card.dart` | 瀑布流布局（8 项） |
| `MediaBangumiSkeleton` | `skeleton/media_bangumi.dart` | 番剧媒体卡片 |
| `VideoIntroSkeleton` | `skeleton/video_intro.dart` | 视频简介（标题、数据、作者信息） |
| `VideoReplySkeleton` | `skeleton/video_reply.dart` | 视频评论区 |

---

## 3. 核心组件详解

### 3.1 VideoCardH – 横向视频卡片

`VideoCardH` 是推荐列表、搜索结果的横向卡片。

```dart
class VideoCardH extends StatelessWidget {
  final dynamic videoItem;   // 支持 Ottohub Video 和旧版通用对象
  final Function()? onPressedFn;
  final String source;       // 'normal' | 'later' 等
  final bool showOwner;      // 是否显示 UP 主名称
  final bool showView;       // 是否显示播放量
  final bool showDanmaku;    // 是否显示弹幕数
  final bool showPubdate;    // 是否显示发布日期
  final bool showCharge;     // 是否显示充电标识
  final int? rankIndex;      // 排名（1-3 金银铜徽标）
}
```

**核心特性**:
- **双向兼容**: 通过 getter 方法同时支持 `Video`（Ottohub 新模型）和旧版 `dynamic` 对象
- **排名徽标**: `rankIndex` 1-3 显示金银铜色徽标，>3 显示灰色
- **时长角标**: 使用 `PBadge` 组件显示 `Utils.timeFormat()` 格式化时长
- **Hero 动画**: 封面图使用 `Hero` + `NetworkImgLayer` 支持页面过渡动画
- **更多面板**: 右下角三点按钮弹出 `MorePanel`，支持拉黑 UP 主和查看封面

**内部类 MorePanel**:
```dart
class MorePanel extends StatelessWidget {
  // 功能区：
  // - 拉黑 UP 主（调用 IUserRepository.blockUser）
  // - 查看/下载视频封面（imageSaveDialog）
}
```

### 3.2 VideoCardV – 纵向视频卡片

`VideoCardV` 用于瀑布流/网格布局的纵向卡片，直接使用 Ottohub `Video` 模型。

```dart
class VideoCardV extends StatelessWidget {
  final Video videoItem;
  final int crossAxisCount;   // 网格列数，影响尺寸和布局
  final Function? blockUserCb; // 拉黑回调
}
```

**自适应布局**:
- `crossAxisCount == 1`（单列）: 使用大号时长角标，统计信息在下方展开
- `crossAxisCount > 1`（多列）: 使用小号角标，统计紧凑排列

**VideoContent 子组件**:
- 标题（最多 2 行，ellipsis 溢出）
- UP 主名称
- `VideoStat`: 播放量 + 相对时间

**VideoStat 子组件**:
```dart
class VideoStat extends StatelessWidget {
  // StatView（播放量图标+数字）
  // 相对时间文本（使用 Utils.formatTimestampToRelativeTime）
}
```

### 3.3 NetworkImgLayer – 网络图片组件

`NetworkImgLayer` 是项目中**所有网络图片的统一入口**，封装了缓存、占位、质量控制。

```dart
class NetworkImgLayer extends StatelessWidget {
  final String? src;           // 图片 URL
  final double width;          // 宽度
  final double height;         // 高度
  final String? type;          // 'avatar' | 'emote' | 'bg' | null
  final Duration? fadeOutDuration;
  final Duration? fadeInDuration;
  final int? quality;          // 图片质量百分比
  final double? origAspectRatio; // 原始宽高比
}
```

**核心逻辑**:

1. **URL 处理**:
   - Ottohub 图片（包含 `ottohub.cn`）: 直接使用，不加后缀
   - 其他图片: 追加 `@{quality}q.webp` 参数
   - `//` 开头的 URL 自动补 `https:`

2. **内存缓存优化**:
   - 横向图片（aspectRatio > 1）: 缓存高度
   - 纵向图片（aspectRatio < 1）: 缓存宽度
   - 正方形: 通过 `origAspectRatio` 判断或同时缓存宽高

3. **类型特殊处理**:
   - `avatar`: 圆形裁剪（BorderRadius 50）
   - `emote`: 无圆角
   - `bg`: 占位时无图标
   - 默认: `StyleString.imgRadius` 圆角

4. **占位图 (placeholder)**:
   - 默认显示进度指示器
   - avatar 类型显示人物图标
   - bg 类型显示空白

### 3.4 AppBarWidget – 自定义 AppBar

`AppBarWidget` 实现 Scroll-Aware AppBar，随滚动隐藏/显示。

```dart
class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final PreferredSizeWidget child;
  final AnimationController controller;
  final bool visible;
}
```

- `visible == true` → `controller.reverse()`，AppBar 滑入
- `visible == false` → `controller.forward()`，AppBar 滑出
- 动画使用 `Curves.easeInOutBack` 弹性曲线

### 3.5 CustomToast – 自定义 Toast

`CustomToast` 是一个圆角 Toast 组件，支持从设置读取不透明度。

```dart
class CustomToast extends StatelessWidget {
  final String msg;
  // 透明度从 SettingBoxKey.defaultToastOp 读取（默认 1.0）
}
```

**样式**:
- 圆角 20px
- 背景色 `primaryContainer`，前景色 `primary`
- 字号 13px
- 底部 margin = 安全区底部 + 30

---

## 4. Skeleton 骨架屏系统

### 4.1 核心引擎 (`skeleton.dart`)

`Skeleton` 是整个骨架屏系统的核心，包含三个关键类：

| 类 | 说明 |
|------|------|
| `Skeleton` | 骨架屏入口 StatelessWidget，包裹子组件并应用 Shimmer 效果 |
| `Shimmer` | StatefulWidget，管理 1 秒循环的渐变动画 |
| `ShimmerLoading` | StatefulWidget，将渐变作为 ShaderMask 应用到子组件 |

**动画原理**:
```
AnimationController.unbounded
  .repeat(min: -0.5, max: 1.5, period: 1000ms)
  → _SlidingGradientTransform (Matrix4 平移)
  → LinearGradient 滑动
  → ShaderMask (blendMode: srcATop)
  → 子组件仅在有颜色的部分可见
```

**渐变色配置**:
```dart
LinearGradient(
  colors: [transparent, surface(10%), surface(10%), transparent],
  stops: [0.1, 0.3, 0.5, 0.7],
  begin: Alignment(-1.0, -0.3),
  end: Alignment(1.0, 0.9),
)
```

**使用方式**:
```dart
Skeleton(
  child: YourPlaceholderWidget(), // 用纯色 Container 模拟真实布局
)
```

### 4.2 各骨架屏组件

| 组件 | 模拟内容 |
|------|----------|
| `VideoCardHSkeleton` | 横向封面图（aspectRatio 16:10）+ 标题条 + UP 名条 + 统计条 |
| `VideoCardVSkeleton` | 纵向封面图 + 双行标题条 |
| `DynamicCardSkeleton` | 圆形头像 + 用户名 + 内容条 + 3 个操作按钮 |
| `WaterfallSkeleton` (8项) | 8 个不同高度的瀑布流卡片（180-260px） |
| `MediaBangumiSkeleton` | 111×148 封面图 + 标题 + 描述 + 按钮 |
| `VideoIntroSkeleton` | 双行标题 + 4 项数据 + 3 行简介 + 4 个按钮 + 作者信息 |
| `VideoReplySkeleton` | 圆形头像 + 用户名 + 2 行评论 + 点赞/回复 |

所有骨架屏均使用 `Theme.of(context).colorScheme.onInverseSurface` 或 `surfaceContainerHighest` 作为占位色块颜色，保证与主题一致。

---

## 5. Mixin 混入

### ScrollToTopMixin

`ScrollToTopMixin` 为 StatefulWidget 提供"滚动到顶部"功能。

```dart
mixin ScrollToTopMixin<T extends StatefulWidget> on State<T> {
  void scrollToTop(ScrollController scrollController) {
    if (!scrollController.hasClients) return;

    if (scrollController.offset >= MediaQuery.of(context).size.height * 3) {
      scrollController.jumpTo(0);      // 超过 3 屏：直接跳转
    } else {
      scrollController.animateTo(0,    // 3 屏内：动画滚动
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }
}
```

**设计思路**: 当前位置 > 3 倍屏幕高度时使用 `jumpTo(0)` 瞬间跳转（避免长距离动画卡顿），否则使用 500ms 的 `animateTo` 平滑过渡。

**使用方式**:
```dart
class MyPage extends StatefulWidget { ... }

class _MyPageState extends State<MyPage> with ScrollToTopMixin {
  final ScrollController _controller = ScrollController();

  void onTabTap() {
    scrollToTop(_controller);
  }
}
```

---

## 6. Constants 常量

### StyleString – 样式常量

`StyleString` 定义全应用统一的视觉常量：

```dart
class StyleString {
  static const double cardSpace = 8;         // 卡片间距
  static const double safeSpace = 12;        // 安全边距
  static BorderRadius mdRadius = BorderRadius.circular(10); // 中等圆角
  static const Radius imgRadius = Radius.circular(10);       // 图片圆角
  static const double aspectRatio = 16 / 10; // 视频封面宽高比
}
```

### Constants – API 常量

```dart
class Constants {
  static const String appKey = '4409e2ce8ffd12b8';   // AppKey
  static const String appSec = '59b43e04ad6965f34319062b478f83dd'; // AppSecret
  static const String thirdSign = '04224646d1fea004e79606d3b038c84a';
  static const String thirdApi = 'https://www.mcbbs.net/...';
}
```

---

## 7. 其他重要组件

### MarkdownText – 智能文本渲染

`MarkdownText` 自动检测文本格式并选择渲染引擎：

```
文本输入
  │
  ├── 包含 HTML 标签 → flutter_html (Html widget)
  ├── 包含 Markdown 语法 → flutter_markdown_plus (MarkdownBody)
  └── 纯文本 → 原生 Text widget
```

**特色功能**:
- 时间戳链接跳转（如 `00:30` → 回调 `onTimeJump`）
- 链接点击处理（支持自定义 `onLinkTap`，默认跳转 WebView）
- 完整 Markdown 样式支持（标题、列表、引用、代码块、删除线、粗斜体）

### HtmlRender – HTML 渲染

`HtmlRender` 专门用于渲染富文本 HTML 内容（视频简介等）。

**扩展功能**:
- **代码块**: 使用 `TagExtension` 自定义 `<pre>` 标签，通过 `highlight.dart` 实现语法高亮
- **图片点击放大**: 自定义 `<img>` 标签，点击后全屏预览（InteractiveviewerGallery）
- **行高**: 140%，大号字体

### LimitedWaterfall – 限制宽度瀑布流

`LimitedWaterfall` 解决宽屏下瀑布流过度拉伸的问题。

```
屏幕宽度 > 项目最大宽度 × 列数 + 间距
  → 居中显示，按计算出的 gridWidth 限制
屏幕宽度 ≤ 计算出的 gridWidth
  → 填满屏幕
```

支持自定义 `maxCrossAxisCount`（默认 3）、`maxItemWidth`（默认 400）、`centerContent`（默认 true）。

### EpisodeBottomSheet – 分集选择器

`EpisodeBottomSheet` 提供视频分集/分P/番剧集数选择的底部弹窗。

**支持数据类型**:
- `VideoEpidoesType.videoEpisode` — 视频分集
- `VideoEpidoesType.videoPart` — 视频分P
- `VideoEpidoesType.bangumiEpisode` — 番剧集数

**特性**:
- `ScrollablePositionedList` 自动滚动到当前播放位置
- 全屏模式下隐藏关闭按钮
- 带封面的集数以卡片形式展示，无封面的为纯文字列表

---

## 8. 使用示例

### 8.1 视频卡片组件

```dart
import 'package:piliotto/common/widgets/video_card_h.dart';
import 'package:piliotto/common/widgets/video_card_v.dart';

class VideoListPage extends StatelessWidget {
  final List<Video> videos;
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: videos.length,
      itemBuilder: (context, index) {
        return VideoCardH(
          videoItem: videos[index],
          showOwner: true,
          showView: true,
          showDanmaku: true,
          rankIndex: index < 3 ? index + 1 : null,
          onPressedFn: () {
            Get.toNamed('/video?vid=${videos[index].vid}');
          },
        );
      },
    );
  }
}

class VideoGridPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        return VideoCardV(
          videoItem: videos[index],
          crossAxisCount: 2,
        );
      },
    );
  }
}
```

### 8.2 网络图片组件

```dart
import 'package:piliotto/common/widgets/network_img_layer.dart';

class AvatarWidget extends StatelessWidget {
  final String avatarUrl;
  
  @override
  Widget build(BuildContext context) {
    return NetworkImgLayer(
      src: avatarUrl,
      width: 48,
      height: 48,
      type: 'avatar',
      quality: 80,
    );
  }
}

class CoverWidget extends StatelessWidget {
  final String coverUrl;
  
  @override
  Widget build(BuildContext context) {
    return NetworkImgLayer(
      src: coverUrl,
      width: double.infinity,
      height: 200,
      quality: 60,
    );
  }
}
```

### 8.3 骨架屏使用

```dart
import 'package:piliotto/common/skeleton/video_card_h.dart';
import 'package:piliotto/common/skeleton/skeleton.dart';

class LoadingListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return const Skeleton(
          child: VideoCardHSkeleton(),
        );
      },
    );
  }
}
```

### 8.4 错误与空状态组件

```dart
import 'package:piliotto/common/widgets/http_error.dart';
import 'package:piliotto/common/widgets/no_data.dart';

class ContentPage extends StatelessWidget {
  final bool hasError;
  final bool hasData;
  final VoidCallback onRetry;
  
  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return HttpError(
        errMsg: '网络请求失败',
        fn: onRetry,
      );
    }
    
    if (!hasData) {
      return const NoData();
    }
    
    return const VideoList();
  }
}
```

---

## 8. 使用示例

### 8.1 视频卡片组件

```dart
import 'package:piliotto/common/widgets/video_card_h.dart';
import 'package:piliotto/common/widgets/video_card_v.dart';

class VideoListPage extends StatelessWidget {
  final List<Video> videos;
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: videos.length,
      itemBuilder: (context, index) {
        return VideoCardH(
          videoItem: videos[index],
          showOwner: true,
          showView: true,
          showDanmaku: true,
          rankIndex: index < 3 ? index + 1 : null,
          onPressedFn: () {
            Get.toNamed('/video?vid=${videos[index].vid}');
          },
        );
      },
    );
  }
}

class VideoGridPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        return VideoCardV(
          videoItem: videos[index],
          crossAxisCount: 2,
        );
      },
    );
  }
}
```

### 8.2 网络图片组件

```dart
import 'package:piliotto/common/widgets/network_img_layer.dart';

class AvatarWidget extends StatelessWidget {
  final String avatarUrl;
  
  @override
  Widget build(BuildContext context) {
    return NetworkImgLayer(
      src: avatarUrl,
      width: 48,
      height: 48,
      type: 'avatar',
      quality: 80,
    );
  }
}

class CoverWidget extends StatelessWidget {
  final String coverUrl;
  
  @override
  Widget build(BuildContext context) {
    return NetworkImgLayer(
      src: coverUrl,
      width: double.infinity,
      height: 200,
      quality: 60,
    );
  }
}
```

### 8.3 骨架屏使用

```dart
import 'package:piliotto/common/skeleton/video_card_h.dart';
import 'package:piliotto/common/skeleton/skeleton.dart';

class LoadingListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return const Skeleton(
          child: VideoCardHSkeleton(),
        );
      },
    );
  }
}
```

### 8.4 错误与空状态组件

```dart
import 'package:piliotto/common/widgets/http_error.dart';
import 'package:piliotto/common/widgets/no_data.dart';

class ContentPage extends StatelessWidget {
  final bool hasError;
  final bool hasData;
  final VoidCallback onRetry;
  
  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return HttpError(
        errMsg: '网络请求失败',
        fn: onRetry,
      );
    }
    
    if (!hasData) {
      return const NoData();
    }
    
    return const VideoList();
  }
}
```

---

## 9. 开发指南

### 添加新的通用组件

1. 在 `lib/common/widgets/` 创建新文件
2. 组件必须是无状态的（StatelessWidget），除非确实需要管理内部状态
3. 使用 `const` 构造函数以优化性能
4. 所有视觉常量从 `StyleString`（`constants.dart`）获取
5. 图片统一使用 `NetworkImgLayer`，不直接使用 `CachedNetworkImage`
6. 颜色从 `Theme.of(context).colorScheme` 获取，支持暗黑模式

### 组件命名规范

- 卡片组件: `XxxCard`（VideoCardH, VideoCardV, LiveCard）
- 骨架屏: `XxxSkeleton`（VideoCardHSkeleton, DynamicCardSkeleton）
- 弹窗/面板: `XxxBottomSheet`, `XxxDialog`, `MorePanel`
- 布局组件: 描述性名称（ResponsiveLayout, LimitedWaterfall）

### 添加新的骨架屏

1. 在 `lib/common/skeleton/` 创建文件
2. 分析目标页面的布局结构，用纯色 Container 搭建镜像布局
3. 最外层用 `Skeleton(child: ...)` 包裹
4. 颜色统一使用 `Theme.of(context).colorScheme.onInverseSurface` 或 `surfaceContainerHighest`

### 设计原则

- **主题感知**: 所有组件通过 `Theme.of(context)` 获取颜色，自动适配亮/暗模式
- **平台无关**: 避免 `Platform.isXxx` 判断，保持纯 Flutter 实现
- **适量抽象**: 组件提供合理的参数化（如 `showOwner`, `showView`），但不做过度泛化

---

## 10. 二改指南

### 常见二改场景

#### 场景 1: 修改视频封面宽高比

编辑 `constants.dart`：

```dart
// 从 16:10 改为 16:9
static const double aspectRatio = 16 / 9;
```

此修改会同时影响 VideoCardH、VideoCardV、Skeleton 等所有使用 `StyleString.aspectRatio` 的组件。

#### 场景 2: 修改 VideoCardH 显示字段

编辑 `video_card_h.dart`，构造函数默认值即可控制：

```dart
// 例如默认不显示弹幕
VideoCardH(
  videoItem: video,
  showDanmaku: false, // 改为默认 false
)
```

#### 场景 3: 添加新的卡片样式

1. 在 `lib/common/widgets/` 创建新卡片文件
2. 参考 `VideoCardV` 的结构: 封面（NetworkImgLayer + 角标） + 内容区
3. 在 `lib/common/skeleton/` 创建对应的骨架屏

#### 场景 4: 修改 Skeleton Shimmer 动画速度

编辑 `skeleton.dart`：

```dart
_shimmerController = AnimationController.unbounded(vsync: this)
  ..repeat(min: -0.5, max: 1.5,
    period: const Duration(milliseconds: 1500), // 从 1000 改为 1500
  );
```

#### 场景 5: 修改 MorePanel 菜单项

编辑 `video_card_v.dart` 中 `MorePanel.build()`:

```dart
// 添加新的 ListTile
ListTile(
  onTap: () { /* 新功能 */ },
  minLeadingWidth: 0,
  leading: const Icon(Icons.your_icon, size: 19),
  title: Text('你的功能', style: Theme.of(context).textTheme.titleSmall),
),
```

#### 场景 6: 修改自定义 Toast 样式

编辑 `custom_toast.dart`：

```dart
// 修改圆角、内边距、字号等
decoration: BoxDecoration(
  color: ...,
  borderRadius: BorderRadius.circular(12), // 从 20 改为 12
),
child: Text(
  msg,
  style: TextStyle(
    fontSize: 15, // 从 13 改为 15
    ...
  ),
),
```

### 注意事项

- `NetworkImgLayer` 是项目中**唯一的图片加载入口**，不要绕过它直接使用 `CachedNetworkImage`
- 修改 `StyleString` 常量会影响全局样式，需全面测试
- 骨架屏的颜色必须与主题系统保持一致，不要硬编码颜色值
- `VideoCardH` 使用 `dynamic` 类型兼容新旧数据模型，修改 getter 时需保持双向兼容
- `pages_bottom_sheet.dart` 中的 `ItemScrollController.jumpTo` 需在 `addPostFrameCallback` 中调用，否则布局未完成时跳转会失效
- `MarkdownText` 内置了 HTML 实体解码，如果上游已解码需注意双重解码问题