---
date: 2026-05-14 22:30:52
title: plugin
permalink: /pages/9c1ce8
categories:
  - guide
  - core
---
# Plugin 插件层

## 1. 模块概述

Plugin 层是 PiliOtto 项目中独立可复用的 UI 插件集合，提供视频播放、图片浏览和弹窗弹出等核心交互能力。三个插件各自独立，无相互依赖。

### 目录结构

```
lib/plugin/
├── pl_player/           # 视频播放器插件
│   ├── controller.dart         # 播放器控制器（核心状态管理）
│   ├── view.dart               # 播放器 UI 视图
│   ├── utils.dart              # 时间格式化工具
│   ├── index.dart              # 库导出入口
│   ├── models/
│   │   ├── bottom_control_type.dart      # 底部控制栏按钮类型
│   │   ├── bottom_progress_behavior.dart # 底部进度条显示行为
│   │   ├── data_source.dart             # 数据源配置（网络/本地/Asset）
│   │   ├── data_status.dart             # 数据加载状态
│   │   ├── duration.dart                # Duration 扩展方法
│   │   ├── fullscreen_mode.dart         # 全屏模式枚举
│   │   ├── play_repeat.dart             # 播放循环模式
│   │   ├── play_speed.dart              # 播放速度列表
│   │   └── play_status.dart             # 播放状态枚举
│   ├── utils/
│   │   └── fullscreen.dart       # 全屏/横竖屏切换工具
│   └── widgets/
│       ├── app_bar_ani.dart      # 控制栏滑入/滑出动画
│       ├── backward_seek.dart    # 快退 10 秒指示器
│       ├── bottom_control.dart   # 底部控制栏（进度条 + 按钮行）
│       ├── common_btn.dart       # 通用按钮组件
│       ├── control_bar.dart      # 音量/亮度状态指示条
│       ├── forward_seek.dart     # 快进 10 秒指示器
│       └── play_pause_btn.dart   # 播放/暂停按钮（带动画）
├── pl_gallery/          # 图片浏览器插件
│   ├── index.dart                      # 库导出入口
│   ├── interactiveviewer_gallery.dart  # 主画廊组件
│   ├── interactive_viewer_boundary.dart # 缩放边界检测
│   ├── custom_dismissible.dart        # 自定义下拉关闭组件
│   ├── hero_dialog_route.dart          # Hero 动画弹窗路由
│   └── image_color_extractor.dart     # 图片主色调提取
└── pl_popup/            # 弹窗插件
    └── index.dart                     # PlPopupRoute 自定义 PopupRoute
```

---

## 2. pl_player 详解

pl_player 是基于 [media_kit](https://github.com/media-kit/media-kit-flutter) 构建的全功能视频播放器插件，支持弹幕（`canvas_danmaku`）、手势控制、多平台全屏。

### 2.1 入口组件：PLVideoPlayer

位于 `view.dart`。

```dart
class PLVideoPlayer extends StatefulWidget {
  final PlPlayerController controller;       // 播放器控制器（必需）
  final PreferredSizeWidget? headerControl;  // 自定义顶部控制栏
  final PreferredSizeWidget? bottomControl;  // 自定义底部控制栏
  final Widget? danmuWidget;                 // 弹幕组件
  final List<BottomControlType>? bottomList; // 底部按钮定制
  final Widget? customWidget;                // 单个自定义按钮
  final List<Widget>? customWidgets;         // 多个自定义按钮
  final Function? showEposideCb;             // 选集回调
  final Function? fullScreenCb;              // 全屏切换回调
  final Alignment? alignment;                // 视频对齐方式
}
```

### 2.2 播放器控制器：PlPlayerController

位于 `controller.dart`。播放器的核心状态管理类，持有所有可观察状态。

#### 核心状态

| 类别 | 字段 | 类型 | 说明 |
|------|------|------|------|
| 播放状态 | `playerStatus` | `PlPlayerStatus` | completed / playing / paused |
| 数据状态 | `dataStatus` | `PlPlayerDataStatus` | none / loading / loaded / error |
| 进度 | `_position` / `positionSeconds` | `Rx<Duration>` / `RxInt` | 当前播放位置（秒级节流） |
| 进度 | `_sliderPosition` / `sliderPositionSeconds` | `Rx<Duration>` / `RxInt` | 进度条显示位置 |
| 进度 | `_sliderTempPosition` | `Rx<Duration>` | 拖拽中的临时位置 |
| 进度 | `_duration` / `durationSeconds` | `Rx<Duration>` / `RxInt` | 视频总时长（秒级节流） |
| 缓冲 | `_buffered` / `bufferedSeconds` | `Rx<Duration>` / `RxInt` | 缓冲位置 |
| 平滑进度 | `_smoothPosition` | `Rx<Duration>` | 高精度插值进度（~60fps） |
| 播放速度 | `_playbackSpeed` | `Rx<double>` | 当前播放速度 |
| 音量 | `_currentVolume` / `_mute` | `Rx<double>` / `Rx<bool>` | 音量值 / 静音 |
| 亮度 | `_currentBrightness` | `Rx<double>` | 屏幕亮度 |
| 控制 | `_showControls` / `_controlsLock` | `Rx<bool>` / `Rx<bool>` | 控制栏显隐 / 锁定 |
| 全屏 | `_isFullScreen` / `_direction` | `Rx<bool>` / `Rx<String>` | 全屏状态 / 方向 |
| 其他 | `_isSliderMoving` / `_isMouseHovering` / `isBuffering` | `Rx<bool>` | 拖拽中 / 鼠标悬停 / 缓冲中 |
| 倍速 | `_doubleSpeedStatus` / `_longPressSpeed` | `Rx<bool>` / `Rx<double>` | 长按倍速 / 倍速值 |
| 画面 | `_videoFit` / `videoFitChanged` | `Rx<BoxFit>` / `Rx<bool>` | 视频缩放模式 |
| 弹幕 | `isOpenDanmu` / `danmakuController` | `Rx<bool>` / `DanmakuController?` | 弹幕开关 / 控制器 |
| 循环 | `playRepeat` | `PlayRepeat` | 播放顺序模式 |

#### 核心方法

| 方法 | 说明 |
|------|------|
| `setDataSource(dataSource, ...)` | 初始化媒体源，设置播放参数，打开视频 |
| `play()` / `pause()` | 播放/暂停，同时控制高精度进度定时器 |
| `togglePlay()` | 切换播放/暂停（带触觉反馈） |
| `seekTo(position)` | 跳转到指定位置，更新进度插值基准 |
| `setPlaybackSpeed(speed)` | 设置播放速度，同步调整弹幕滚动速度 |
| `setVolume(volume)` / `getCurrentVolume()` | 调节/获取系统音量 |
| `setBrightness(brightness)` / `getCurrentBrightness()` | 调节/获取屏幕亮度 |
| `triggerFullScreen(status)` | 进入/退出全屏（含横竖屏切换） |
| `onLockControl(val)` | 锁定/解锁控制栏 |
| `setDoubleSpeedStatus(val)` | 长按倍速状态切换 |
| `toggleVideoFit()` | 弹出画面比例选择对话框 |
| `addPositionListener(fn)` / `addStatusLister(fn)` | 注册外部进度/状态监听器 |
| `screenshot()` | 截取当前视频帧（返回 `Uint8List`） |
| `makeHeartBeat(progress)` | 间隔 5 秒上报播放进度给后端 |
| `setPlayRepeat(type)` | 设置播放模式（顺序/单曲循环/列表循环） |
| `dispose()` | 释放播放器资源，缓存弹幕选项 |

#### 进度平滑插值机制

播放器使用 `_smoothPosition` 在 stream position 事件之间进行基于时间的线性插值，以 ~60fps 频率更新，确保底部迷你进度条平滑移动。`_lastStreamPosition` 和 `_lastStreamPositionTime` 记录了最近一次 stream 事件的位置和时间，`_startSmoothPositionTimer` / `_stopSmoothPositionTimer` 控制定时器启停。

#### 秒级节流优化

为避免频繁触发 UI 重绘，播放器将 `Duration` 精度降为秒级：

```dart
void updatePositionSecond() {
  int newSecond = _position.value.inSeconds;
  if (positionSeconds.value != newSecond) {
    positionSeconds.value = newSecond;
  }
}
```

四个关键进度（position、duration、sliderPosition、buffered）均有对应的 `XxxSeconds` 字段。

### 2.3 播放器 UI 视图

位于 `view.dart`。`PLVideoPlayer` 使用 `Stack` 布局组织多层 UI：

**层级结构（从底到顶）**：

1. **Video 层** - `media_kit_video` 的 `Video` widget，配置 `subtitleViewConfiguration` 和后台播放行为
2. **倍速 Toast** - 长按倍速时显示的半透明提示条
3. **进度 Toast** - 拖拽进度条时显示的当前/总时长浮层
4. **音量指示条** - 调节音量时显示的百分比条
5. **亮度指示条** - 调节亮度时显示的百分比条
6. **弹幕层** - `widget.danmuWidget`，位于视频上方
7. **手势层** - `GestureDetector` 覆盖视频区域：
   - **单击** - 切换控制栏显隐
   - **双击** - 左侧快退 / 中间暂停 / 右侧快进
   - **长按** - 开启倍速播放
   - **水平拖拽** - Seek 进度条
   - **垂直拖拽** - 左侧调亮度 / 右侧调音量 / 中间上下滑全屏切换
8. **顶部/底部控制栏** - 带动画的滑入滑出（`AppBarAni`），包含进度条和按钮行
9. **底部迷你进度条** - 控制栏隐藏时显示，行为可配置
10. **锁定按钮** - 全屏时左侧的锁图标
11. **加载指示器** - 加载/缓冲时显示线性进度条
12. **快进/快退指示器** - 双击左右区域时显示的半透明面板

#### 手势详解

- **全屏手势切换**: 中间区域上下滑触发全屏。设置了 `lastFullScreenToggleTime` 防止 500ms 内重复触发
- **双击快进/快退**: 每次点击累加 10 秒，200ms 定时器防抖
- **垂直拖拽音量**: 使用 `EasyThrottle` 节流（20ms），调用 `FlutterVolumeController`

### 2.4 控制栏系统

#### 底部控制栏按钮类型

位于 `bottom_control_type.dart`。

`BottomControlType` 枚举定义了 10 种按钮：

| 类型 | 描述 | 是否已实现 | 是否需要回调 |
|------|------|-----------|-------------|
| `pre` | 上一集 | ❌ 未实现 | - |
| `playOrPause` | 播放/暂停 | ✅ | - |
| `next` | 下一集 | ❌ 未实现 | - |
| `time` | 时间进度 | ✅ | - |
| `space` | 空白占位 | ✅ | - |
| `episode` | 选集 | ✅ | ✅ `showEposideCb` |
| `fit` | 画面比例 | ✅ | - |
| `speed` | 播放速度 | ✅ | - |
| `fullscreen` | 全屏切换 | ✅ | - |
| `custom` | 自定义 | ✅ | ✅ `customWidget` |

支持通过 `fromCodeList` / `toCodeList` 进行序列化，方便持久化用户自定义按钮布局。

#### 底部进度条显示行为

位于 `bottom_progress_behavior.dart`。

```dart
enum BtmProgresBehavior {
  alwaysShow,        // 始终展示
  alwaysHide,        // 始终隐藏
  onlyShowFullScreen, // 仅全屏时展示
  onlyHideFullScreen, // 仅全屏时隐藏
}
```

#### 控制栏动画（AppBarAni）

位于 `app_bar_ani.dart`。使用 `SlideTransition` 实现上下滑入效果，顶部控制栏从上方滑入，底部从下方滑入。背景使用 `LinearGradient` 半透明渐变。

#### 播放/暂停按钮动画

位于 `play_pause_btn.dart`。使用 Flutter 内置 `AnimatedIcons.play_pause` 实现播放/暂停图标平滑过渡动画，通过监听 `player.stream.playing` 驱动 `AnimationController`。

#### 快进/快退指示器

- `forward_seek.dart` - 右侧渐变背景面板，显示快进秒数，重复点击累加 10 秒
- `backward_seek.dart` - 左侧渐变背景面板，显示快退秒数，重复点击累加 10 秒

### 2.5 全屏系统

#### 全屏模式

位于 `fullscreen_mode.dart`。

```dart
enum FullScreenMode {
  auto,      // 根据视频宽高比自适应
  vertical,  // 始终竖屏
  horizontal // 始终横屏
}
```

#### 全屏工具函数

位于 `utils/fullscreen.dart`。跨平台全屏支持：

| 函数 | 平台 | 实现 |
|------|------|------|
| `landScape()` | Android/iOS | `AutoOrientation.landscapeAutoMode` |
| `landScape()` | Web | `document.documentElement?.requestFullscreen()` |
| `verticalScreen()` | Android/iOS | `SystemChrome.setPreferredOrientations` |
| `enterFullScreen()` | Desktop | `windowManager.setFullScreen(true)` |
| `enterFullScreen()` | Android/iOS | `SystemUiMode.immersiveSticky` |
| `exitFullScreen()` | Desktop | `windowManager.setFullScreen(false)` |
| `exitFullScreen()` | Android/iOS | 恢复 `SystemUiMode.edgeToEdge` 和系统 UI |

### 2.6 数据源模型

位于 `data_source.dart`。

```dart
enum DataSourceType { asset, network, file, contentUri }

class DataSource {
  File? file;
  String? videoSource;
  String? audioSource;
  String? subFiles;
  DataSourceType type;
  Map<String, String>? httpHeaders;
}
```

支持四种数据源类型：Asset 内建资源、网络 URL、本地文件、Android Content URI。

### 2.7 播放速度

位于 `play_speed.dart`。预生成 0.25x - 2.0x 共 8 档播放速度列表。

### 2.8 播放循环

位于 `play_repeat.dart`。

```dart
enum PlayRepeat { pause, listOrder, singleCycle, listCycle }
```

### 2.9 自定义播放器外观

`PLVideoPlayer` 支持完全自定义外观：

- **`headerControl`** - 替换顶部控制栏
- **`bottomControl`** - 完全替换底部控制栏（包含进度条 + 按钮行）
- **`bottomList`** - 仅自定义底部按钮的排列和可见性
- **`customWidget`** / **`customWidgets`** - 追加自定义按钮

---

## 3. pl_gallery 详解

pl_gallery 是一个交互式图片浏览器，支持缩放、平移、双击放大、旋转、批量选择和下载等功能。

### 3.1 主组件：InteractiveviewerGallery

位于 `interactiveviewer_gallery.dart`。

```dart
class InteractiveviewerGallery<T> extends StatefulWidget {
  final List<T> sources;                       // 图片 URL 列表
  final int initIndex;                         // 初始展示的图片索引
  final IndexedFocusedWidgetBuilder? itemBuilder; // 自定义图片构建器
  final double maxScale;                       // 最大缩放（默认 4.5）
  final double minScale;                       // 最小缩放（默认 1.0）
  final ValueChanged<int>? onPageChanged;       // 翻页回调
  final ValueChanged<int>? onDismissed;         // 关闭回调
  final IndexedTagStringBuilder? heroTagBuilder; // Hero 动画标签
  final bool showPageNavigationButtons;         // 是否显示翻页按钮
}
```

#### 核心功能

| 功能 | 实现 |
|------|------|
| **缩放/平移** | `InteractiveViewerBoundary` 封装 `InteractiveViewer`，最大缩放 4.5 倍 |
| **翻页** | `PageView.builder`，缩放时禁用翻页防止冲突 |
| **边界检测** | 缩放到边界时恢复 PageView 滑动，未到边界时禁用 |
| **双击放大** | 双击以点击位置为中心缩放至最大倍率的 70% |
| **长按菜单** | 弹出底部菜单（分享/复制/保存） |
| **下拉关闭** | `CustomDismissible` 实现上下滑动关闭（带缩放+透明度动画） |
| **Hero 动画** | `HeroDialogRoute` 实现从缩略图到全屏的平滑过渡 |
| **旋转** | 90° 旋转图片，`AnimatedRotation` 动画 |
| **图片信息** | 获取并展示图片尺寸、文件大小、格式 |
| **批量模式** | 多选图片，支持批量下载和分享 |
| **PC 交互** | 键盘左右箭头翻页、ESC 关闭；鼠标滚轮缩放 |
| **工具栏** | 底部工具栏 3 秒自动隐藏，鼠标悬停重新显示 |
| **滑动退出** | 可在设置中开启/关闭 |

#### 工具栏按钮

- 关闭 (×)
- 旋转 (↻)
- 批量选择 (☑)
- 更多 (⋯) — 图片信息、分享、复制、保存、滑动退出开关、翻页按钮开关

### 3.2 InteractiveViewerBoundary

位于 `interactive_viewer_boundary.dart`。

在 `InteractiveViewer` 基础上增加边界检测回调，当图片缩放后水平滑动到左右边界时，向父组件报告，从而恢复 `PageView` 的翻页手势。同时支持鼠标滚轮缩放（`PointerScrollEvent`），以视图中心为缩放原点。

缩放与翻页的协作逻辑：
- 缩放倍数 ≤ 1.01 → 自动恢复翻页
- 缩放 > 1.01 → 禁用翻页
- 滑到图片边缘 → 恢复翻页
- 翻页时自动重置 Transform 到 `Matrix4.identity()`

### 3.3 CustomDismissible

位于 `custom_dismissible.dart`。

实现图片浏览器的上下滑动关闭交互：

- 垂直拖拽时图片跟随移动并缩小（`ScaleTransition`）
- 背景透明度随拖拽距离渐变（`Opacity` 从 1.0 → 0.0）
- 拖拽超过阈值（默认 20%）时触发 `onDismissed` 关闭
- 未超过阈值时动画回弹
- 可通过 `enabled` 参数禁用（缩放时）

### 3.4 HeroDialogRoute

位于 `hero_dialog_route.dart`。

自定义 `PageRoute`，实现：

- 毛玻璃模糊背景（`BackdropFilter` + `ImageFilter.blur`）
- 半透明黑色遮罩叠加
- 渐入动画（`FadeTransition`）
- 点击背景可关闭（`barrierDismissible: true`）

### 3.5 ImageColorExtractor

位于 `image_color_extractor.dart`。

从图片 URL 提取主色调，用于生成图片查看器的背景遮罩颜色：

1. 通过 `NetworkAssetBundle` 加载图片
2. 缩放到 50×50 以减少计算量
3. 量化颜色（步长 32）并统计出现频率
4. 跳过过暗（<30）和过亮（>225）的颜色
5. 返回出现次数最多的颜色
6. 处理后降低饱和度（15%-35%）和亮度（15%-30%）以确保对比度

---

## 4. pl_popup 详解

位于 `popup/index.dart`。

### PlPopupRoute

```dart
class PlPopupRoute extends PopupRoute<void> {
  final Color? backgroudColor;   // 背景色
  final Alignment alignment;     // 子组件对齐方式（默认居中）
  final Widget child;            // 弹窗内容
  final Function? onClick;       // 背景点击回调
}
```

简单封装的 `PopupRoute`，特性：
- 半透明黑色遮罩背景（`barrierColor: Colors.black54`）
- 300ms 过渡动画
- 禁止点击遮罩关闭（`barrierDismissible: false`）
- 子组件对齐方式可配

---

## 5. 使用示例

### 5.1 视频播放器基本使用

```dart
import 'package:piliotto/plugin/pl_player/controller.dart';
import 'package:piliotto/plugin/pl_player/view.dart';

class VideoPlayerPage extends StatefulWidget {
  final String videoUrl;
  
  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late PlPlayerController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = PlPlayerController();
    _controller.setDataSource(
      DataSource(videoSource: widget.videoUrl, type: DataSourceType.network),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PLVideoPlayer(controller: _controller),
    );
  }
}
```

### 5.2 播放器控制操作

```dart
void controlPlayer(PlPlayerController controller) {
  controller.play();
  controller.pause();
  controller.seekTo(Duration(seconds: 30));
  controller.setPlaybackSpeed(1.5);
  controller.setVolume(0.8);
  controller.triggerFullScreen(true);
}

void listenToPlayerState(PlPlayerController controller) {
  controller.position.listen((position) {
    print('当前播放位置: ${position.inSeconds}秒');
  });
  
  controller.playerStatus.listen((status) {
    print('播放状态: ${status.name}');
  });
}
```

### 5.3 图片浏览器使用

```dart
import 'package:piliotto/plugin/pl_gallery/interactiveviewer_gallery.dart';

void showImageGallery(BuildContext context, List<String> images, int initialIndex) {
  Navigator.of(context).push(
    HeroDialogRoute(
      builder: (context) {
        return InteractiveviewerGallery<String>(
          sources: images,
          initIndex: initialIndex,
          heroTagBuilder: (index) => 'image_$index',
          onPageChanged: (index) {
            print('当前图片: $index');
          },
        );
      },
    ),
  );
}
```

### 5.4 弹窗组件使用

```dart
import 'package:piliotto/plugin/pl_popup/index.dart';

void showCustomPopup(BuildContext context, Widget content) {
  Navigator.of(context).push(
    PlPopupRoute(
      child: content,
      alignment: Alignment.center,
      onClick: () {
        print('点击背景');
      },
    ),
  );
}
```

---

## 6. 开发指南

### 6.1 播放器开发要点

#### 依赖库

- `media_kit` + `media_kit_video` - 视频解码与渲染
- `canvas_danmaku` - 弹幕渲染
- `flutter_volume_controller` - 移动端音量控制
- `screen_brightness` - 移动端亮度控制
- `auto_orientation_v2` - 移动端屏幕方向
- `window_manager` - 桌面端全屏
- `status_bar_control_plus` - 状态栏控制

#### 添加新的底部按钮

1. 在 `BottomControlType` 枚举中添加新类型
2. 在 `buildBottomControl()` 的 `videoProgressWidgets` map 中添加对应的按钮 Widget
3. 在 `_defaultBottomList` 中按需添加

#### 播放器销毁注意事项

务必在页面 `dispose` 时调用 `controller.dispose()`。控制器内部会：
- 取消所有 Timer（进度定时器、隐藏控制栏定时器等）
- 缓存弹幕选项到本地
- 移除事件监听
- 释放 media_kit Player 和 VideoController
- 恢复屏幕亮度

### 6.2 图片浏览器开发要点

#### 自定义图片渲染

通过 `itemBuilder` 参数完全自定义图片渲染：

```dart
InteractiveviewerGallery<String>(
  sources: sources,
  initIndex: 0,
  itemBuilder: (context, index, isFocus, enablePageView) {
    return Image.network(
      sources[index],
      fit: BoxFit.contain,
    );
  },
)
```

#### Hero 动画集成

在来源页面给缩略图设置相同的 `heroTagBuilder`：

```dart
// 列表页
Hero(
  tag: 'image_$index',
  child: Image.network(imageUrls[index]),
)

// 查看器
InteractiveviewerGallery(
  heroTagBuilder: (index) => 'image_$index',
)
```

### 6.3 弹窗开发要点

`PlPopupRoute` 是最简封装，如需更丰富的弹窗交互（如动画入/出方向、手势关闭等），可基于 `PopupRoute` 扩展。

---

## 7. 二改指南

### 7.1 替换视频播放内核

当前使用 `media_kit`，如需替换为其他播放器（如 `video_player`、`better_player`）：

1. 修改 `controller.dart` 中的 `Player` 和 `VideoController` 实例
2. 修改 `_openMedia()` 方法适配新播放器的媒体源配置
3. 修改 `startListeners()` 适配新播放器的事件流
4. 修改 `view.dart` 中的 `Video` widget

### 7.2 修改弹幕渲染引擎

当前使用 `canvas_danmaku`，替换需修改：

1. `PlPlayerController.danmakuController` 的类型和初始化
2. `setPlaybackSpeed()` 中弹幕速度同步逻辑
3. `view.dart` 中 `danmuWidget` 的构建方式

### 7.3 添加新的全屏模式

1. 在 `FullScreenMode` 枚举中添加新值
2. 在 `triggerFullScreen()` 方法中添加对应的进入/退出逻辑
3. 如需新的方向控制，在 `fullscreen.dart` 中添加工具函数

### 7.4 修改播放器手势逻辑

播放器手势逻辑集中在 `view.dart` 的 `GestureDetector` 中。可修改：

- **双击行为**: `onDoubleTapDown` 和 `doubleTapFuc()` 方法
- **长按行为**: `onLongPressStart` / `onLongPressEnd`
- **拖拽行为**: `onHorizontalDragUpdate`（Seek）和 `onVerticalDragUpdate`（音量/亮度/全屏）
- **手势分区**: `sectionWidth` 三分区逻辑

### 7.5 扩展图片浏览器功能

- **视频预览**: 在 `itemBuilder` 中根据 content type 切换 Image / Video widget
- **图片标记/标注**: 在 `InteractiveViewerBoundary` 外包一层标记层
- **更多导出格式**: 在底部工具栏添加新按钮，调用对应分享库

### 7.6 弹窗扩展

`PlPopupRoute` 可作为基类扩展：

```dart
class AnimatedPopupRoute extends PlPopupRoute {
  // 添加自定义过渡动画
  @override
  Widget buildTransitions(...) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0, 1),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }
}
```

### 7.7 更换播放器依赖库版本

播放器依赖在 `pubspec.yaml` 中管理。升级 `media_kit` 时需注意：
- `Player` 和 `VideoController` 的 API 变更
- `PlayerConfiguration` 和 `VideoControllerConfiguration` 的参数变更
- 事件流（`stream.playing`、`stream.position` 等）的行为变更