---
date: 2026-05-14 22:17:55
title: services
permalink: /pages/1ee281
categories:
  - guide
  - core
---
# 服务层 (Services)

## 1. 模块概述

服务层 (`lib/services/`) 是 PiliOtto 应用的服务基础设施，负责管理应用生命周期的各类后台服务，包括依赖注入、音频播放服务、电池优化管理等。

该模块采用**服务定位器模式（Service Locator Pattern）**，通过 `service_locator.dart` 集中初始化并暴露全局服务实例，确保各模块可以方便地获取服务依赖。

### 目录结构

```
lib/services/
├── service_locator.dart      # 依赖注入/服务定位器
├── audio_handler.dart        # 音频播放服务处理器
├── audio_session.dart        # 音频会话管理
├── disable_battery_opt.dart  # 电池优化禁用
├── search_history_service.dart # 搜索历史服务
└── shutdown_timer_service.dart # 定时关闭服务
```

> **注意**: `logger.dart` 文件在源码中不存在，项目中日志功能通过第三方依赖（如 `flutter_smart_dialog` 的 toast）和 Hive 持久化实现。

---

## 2. 服务清单

| 服务 | 文件 | 类型 | 职责 |
|------|------|------|------|
| Service Locator | `service_locator.dart` | 启动函数 | 集中初始化所有服务实例 |
| Audio Handler | `audio_handler.dart` | 类 + BaseAudioHandler | Android/iOS 后台音频播放 |
| Audio Session | `audio_session.dart` | 类 | 管理音频会话状态（激活/停用） |
| Battery Opt | `disable_battery_opt.dart` | 函数 | 禁用 Android 电池优化 |
| Search History | `search_history_service.dart` | 类 | 搜索关键词历史（最多 20 条） |
| Shutdown Timer | `shutdown_timer_service.dart` | 单例类 | 定时关闭应用/播放器 |

---

## 3. service_locator 详解

`service_locator.dart` 是整个服务层的入口，定义了顶层全局变量并通过 `setupServiceLocator()` 函数初始化。

### 源代码 (完整)

```dart
import 'audio_handler.dart';
import 'audio_session.dart';

late VideoPlayerServiceHandler videoPlayerServiceHandler;
late AudioSessionHandler audioSessionHandler;

Future<void> setupServiceLocator() async {
  final audio = await initAudioService();
  videoPlayerServiceHandler = audio;
  audioSessionHandler = AudioSessionHandler();
}
```

### 核心机制

- **全局变量**: `videoPlayerServiceHandler` 和 `audioSessionHandler` 为顶层 `late` 变量，使用 `late` 关键字确保在首次访问前已完成初始化。
- **初始化流程**: `setupServiceLocator()` 首先调用 `initAudioService()` 获取音频服务实例，然后直接创建 `AudioSessionHandler`。
- **调用时机**: 通常在应用启动阶段（`main.dart` 或 app 初始化流程中）调用。

### 二改要点

如果要添加新的全局服务，只需：

1. 在 `service_locator.dart` 中声明 `late` 变量
2. 在 `setupServiceLocator()` 中初始化

```dart
// 示例：添加下载管理服务
late DownloadManagerService downloadManagerService;

Future<void> setupServiceLocator() async {
  final audio = await initAudioService();
  videoPlayerServiceHandler = audio;
  audioSessionHandler = AudioSessionHandler();
  downloadManagerService = DownloadManagerService(); // 新增
}
```

---

## 4. 音频服务详解

### 4.1 Audio Handler (`audio_handler.dart`)

音频处理器继承自 `BaseAudioHandler`（来自 `audio_service` 包），提供系统级音频服务集成。

```dart
class VideoPlayerServiceHandler extends BaseAudioHandler with SeekHandler {
  static final List<MediaItem> _item = [];
  Box setting = GStrorage.setting;
  bool enableBackgroundPlay = false;
}
```

#### 关键方法

| 方法 | 说明 |
|------|------|
| `revalidateSetting()` | 从 Hive 存储读取 `enableBackgroundPlay` 设置 |
| `setMediaItem(MediaItem)` | 设置当前播放媒体信息（仅在后台播放启用时有效） |
| `clear()` | 清除播放状态，发送 idle 状态到通知栏 |
| `onPositionChange(Duration)` | 更新播放进度到通知栏 |

#### AudioService 配置

```dart
config: const AudioServiceConfig(
  androidNotificationChannelId: 'com.cyaniagent.piliotto.audio',
  androidNotificationChannelName: 'Audio Service PiliOtto',
  androidNotificationOngoing: true,
  androidStopForegroundOnPause: true,
  fastForwardInterval: Duration(seconds: 10),
  rewindInterval: Duration(seconds: 10),
  androidNotificationChannelDescription: 'Media notification channel',
  androidNotificationIcon: 'drawable/ic_notification_icon',
),
```

**关键配置说明**:
- `androidNotificationOngoing: true` - 通知持久显示（不可滑动清除）
- `androidStopForegroundOnPause: true` - 暂停时退出前台服务
- `fastForwardInterval` / `rewindInterval` - 快进/快退步长均为 10 秒

#### 后台播放控制

`enableBackgroundPlay` 字段控制所有实际操作是否生效。当用户关闭后台播放设置时，`setMediaItem`、`clear`、`onPositionChange` 三个核心方法均会直接 return。

### 4.2 Audio Session (`audio_session.dart`)

音频会话管理器封装了 `audio_session` 包，用于请求和管理系统音频焦点。

```dart
class AudioSessionHandler {
  late AudioSession session;

  AudioSessionHandler() { initSession(); }

  Future<void> initSession() async {
    session = await AudioSession.instance;
    session.configure(const AudioSessionConfiguration.music());
  }

  void setActive(bool active) {
    session.setActive(active);
  }
}
```

- 使用 `AudioSessionConfiguration.music()` 配置，标识应用为音乐播放类型
- `setActive(true/false)` 用于获取/释放音频焦点

---

## 5. 日志服务

项目中**没有独立的 logger.dart 文件**。日志/通知功能通过以下方式实现：

- **Toast 通知**: 使用 `flutter_smart_dialog` 的 `SmartDialog.showToast()`
- **持久化日志**: 通过 Hive Box 存储搜索历史、本地缓存等
- **调试日志**: 依赖 Dart 内置 `print()` 或框架级日志

---

## 6. 搜索历史服务

`SearchHistoryService` 管理用户的搜索关键词历史，基于 Hive Box 持久化。

```dart
class SearchHistoryService {
  static const String _historyKey = 'searchHistory';
  static const int _maxHistoryCount = 20;
  final Box _historyBox = GStrorage.historyword;
}
```

### 功能清单

| 方法 | 说明 |
|------|------|
| `loadSearchHistory()` | 加载持久化的历史记录到内存 |
| `saveSearchHistory(String keyword)` | 保存关键词（去重，插入到列表头部，最多 20 条） |
| `clearSearchHistory()` | 清空全部历史 |
| `removeSearchHistory(String keyword)` | 删除指定关键词 |
| `filterSearchHistory(String query)` | 根据输入过滤匹配的历史记录（不区分大小写） |
| `currentHistory` (getter) | 返回不可修改的历史列表 |

### 数据结构

- 存储键: `searchHistory`
- 存储位置: `GStrorage.historyword` (Hive Box: `historyWord`)
- 最大容量: 20 条
- 排序: 最近搜索在最前

---

## 7. 定时关闭服务

`ShutdownTimerService` 是一个**单例**服务，实现定时关闭应用或播放器的功能。

```dart
class ShutdownTimerService {
  static final ShutdownTimerService _instance = ShutdownTimerService._internal();
  factory ShutdownTimerService() => _instance;
}

final shutdownTimerService = ShutdownTimerService();
```

### 状态字段

| 字段 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `scheduledExitInMinutes` | int | -1 | 定时分钟数，-1 表示取消 |
| `exitApp` | bool | false | 时间到后是否退出应用 |
| `waitForPlayingCompleted` | bool | false | 是否等待当前视频播放完毕 |
| `isWaiting` | bool | false | 是否正在等待播放完成 |

### 工作流程

```
startShutdownTimer()
    │
    ├── scheduledExitInMinutes == -1 → 取消定时，Toast 提示
    │
    └── 设置 Timer → _shutdownDecider()
            │
            ├── exitApp && !waitForPlayingCompleted → 10 秒倒计时弹窗 → _executeShutdown()
            ├── !exitApp && !waitForPlayingCompleted → 仅提示弹窗
            └── waitForPlayingCompleted → 等待 handleWaitingFinished() 回调
```

---

## 8. 电池优化禁用

`disable_battery_opt.dart` 仅在 **Android** 平台生效，通过 `disable_battery_optimization` 插件引导用户禁用系统电池优化，确保后台播放不受限制。

```dart
void disableBatteryOpt() async {
  if (!Platform.isAndroid) return;

  // 1. 检查并引导禁用系统电池优化
  bool isDisableBatteryOptLocal =
      GStrorage.localCache.get('isDisableBatteryOptLocal', defaultValue: false);
  if (!isDisableBatteryOptLocal) {
    // 调用系统设置页面
    final hasDisabled = await DisableBatteryOptimization
        .showDisableBatteryOptimizationSettings();
    GStrorage.localCache.put('isDisableBatteryOptLocal', hasDisabled == true);
  }

  // 2. 检查并引导禁用厂商电池优化
  bool isManufacturerBatteryOptimizationDisabled = GStrorage.localCache
      .get('isManufacturerBatteryOptimizationDisabled', defaultValue: false);
  if (!isManufacturerBatteryOptimizationDisabled) {
    final hasDisabled = await DisableBatteryOptimization
        .showDisableManufacturerBatteryOptimizationSettings(
      "当前设备可能有额外的电池优化",
      "按照步骤操作以禁用电池优化，以保证应用在后台正常运行",
    );
    GStrorage.localCache.put(
        'isManufacturerBatteryOptimizationDisabled', hasDisabled == true);
  }
}
```

**两层优化**:
1. **系统级电池优化** - Android 原生电池优化
2. **厂商级电池优化** - 小米、华为、OPPO 等厂商的额外优化

每层只在首次未禁用时弹出引导，结果缓存到 `localCache` Hive Box 中，避免重复提示。

---

## 9. 使用示例

### 9.1 服务定位器初始化

```dart
import 'package:piliotto/services/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await GStrorage.init();
  await setupServiceLocator();
  
  runApp(const MyApp());
}
```

### 9.2 音频服务使用

```dart
import 'package:piliotto/services/service_locator.dart';

class AudioPlayerPage extends StatefulWidget {
  @override
  State<AudioPlayerPage> createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  @override
  void initState() {
    super.initState();
    videoPlayerServiceHandler.revalidateSetting();
  }
  
  void playInBackground(MediaItem item) {
    if (videoPlayerServiceHandler.enableBackgroundPlay) {
      videoPlayerServiceHandler.setMediaItem(item);
    }
  }
  
  void updateProgress(Duration position) {
    videoPlayerServiceHandler.onPositionChange(position);
  }
  
  void stopPlayback() {
    videoPlayerServiceHandler.clear();
  }
}
```

### 9.3 搜索历史服务

```dart
import 'package:piliotto/services/search_history_service.dart';

class SearchPage extends StatelessWidget {
  final SearchHistoryService _historyService = SearchHistoryService();
  
  void onSearch(String keyword) {
    _historyService.saveSearchHistory(keyword);
  }
  
  List<String> getHistorySuggestions(String query) {
    return _historyService.filterSearchHistory(query);
  }
  
  void clearAllHistory() {
    _historyService.clearSearchHistory();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListView.builder(
          itemCount: _historyService.currentHistory.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(_historyService.currentHistory[index]),
              onTap: () => onSearch(_historyService.currentHistory[index]),
            );
          },
        ),
      ],
    );
  }
}
```

### 9.4 定时关闭服务

```dart
import 'package:piliotto/services/shutdown_timer_service.dart';

final shutdownTimerService = ShutdownTimerService();

void setupShutdownTimer(int minutes, bool exitApp, bool waitPlaying) {
  shutdownTimerService.scheduledExitInMinutes = minutes;
  shutdownTimerService.exitApp = exitApp;
  shutdownTimerService.waitForPlayingCompleted = waitPlaying;
  
  shutdownTimerService.startShutdownTimer();
}

void cancelShutdownTimer() {
  shutdownTimerService.scheduledExitInMinutes = -1;
  shutdownTimerService.startShutdownTimer();
}
```

---

## 10. 开发指南

### 添加新服务

1. 在 `lib/services/` 下创建新的服务文件
2. 实现服务类或函数
3. 在 `service_locator.dart` 中注册：
   - 添加 `late` 顶层变量
   - 在 `setupServiceLocator()` 中初始化
4. 如果服务需要持久化，使用 `GStrorage` 的 Hive Box
5. 在应用初始化流程中确保 `setupServiceLocator()` 先于其他模块调用

### 服务设计原则

- **单一职责**: 每个服务文件只负责一个明确的功能领域
- **全局访问**: 通过 `service_locator.dart` 暴露为顶层变量，避免层层传递
- **延迟初始化**: 使用 `late` 关键字，在 `setupServiceLocator()` 中完成初始化
- **平台检查**: 涉及平台特性的服务（如音频、电池优化）始终检查 `Platform.isAndroid` / `Platform.isIOS`

---

## 11. 二改指南

### 常见二改场景

#### 场景 1: 修改音频通知配置

编辑 `audio_handler.dart` 中的 `AudioServiceConfig`:

```dart
// 例如修改快进快退步长
fastForwardInterval: Duration(seconds: 15),  // 从 10 改为 15
rewindInterval: Duration(seconds: 15),
// 或修改暂停时是否退出前台服务
androidStopForegroundOnPause: false,
```

#### 场景 2: 修改搜索历史最大条数

编辑 `search_history_service.dart`：

```dart
static const int _maxHistoryCount = 50; // 从 20 改为 50
```

#### 场景 3: 修改定时关闭倒计时

编辑 `shutdown_timer_service.dart`：

```dart
// 将 10 秒倒计时改为其他时长
_autoCloseDialogTimer = Timer(const Duration(seconds: 30), () { ... });
```

#### 场景 4: 添加新的全局服务

在 `service_locator.dart` 中添加：

```dart
late YourNewService yourNewService;

Future<void> setupServiceLocator() async {
  final audio = await initAudioService();
  videoPlayerServiceHandler = audio;
  audioSessionHandler = AudioSessionHandler();
  yourNewService = YourNewService(); // 新增
}
```

### 注意事项

- 修改 `audio_handler.dart` 时需同步考虑 Android 和 iOS 双平台兼容性
- `shutdown_timer_service.dart` 使用 `dart:io` 的 `exit(0)` 直接退出进程，仅适用于移动端
- 搜索历史服务依赖 `GStrorage.historyword` Box 已正确初始化
- 所有 Hive 读写操作必须在 `GStrorage.init()` 之后进行