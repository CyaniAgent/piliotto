---
date: 2026-05-14 22:22:01
title: utils
permalink: /pages/7d458d
categories:
  - guide
  - core
---
# 工具层 (Utils)

## 1. 模块概述

工具层 (`lib/utils/`) 是 PiliOtto 的核心基础设施层，包含持久化存储、通用工具函数、数据管理、以及各类业务辅助功能。该层是项目中复用度最高的代码，被 services、common、pages 等各层广泛依赖。

### 目录结构

```
lib/utils/
├── storage.dart              # Hive 持久化存储核心
├── utils.dart                # 通用工具函数集
├── data.dart                 # 数据初始化
├── global_data_cache.dart    # 全局数据缓存（单例）
├── id_utils.dart             # 视频ID转换（bvid/avid）
├── url_utils.dart            # URL 重定向与路由跳转
├── video_utils.dart          # 视频CDN URL处理
├── danmaku.dart              # 弹幕工具
├── event_bus.dart            # 事件总线（单例）
├── app_scheme.dart           # Deep Link / Scheme 处理
├── cache_manage.dart         # 缓存管理（大小计算/清除）
├── cookie.dart               # Cookie 管理（已废弃）
├── download.dart             # 下载工具（图片保存）
├── drawer.dart               # 右侧抽屉工具
├── em.dart                   # HTML 实体 & Emoji 解析
├── extension.dart            # Dart 扩展方法
├── feed_back.dart            # 触觉反馈
├── highlight.dart            # 代码高亮
├── image_save.dart           # 图片保存对话窗
├── login.dart                # 登录状态管理
├── main_stream.dart          # 滚动事件流处理
├── proxy.dart                # HTTP 代理配置
├── recommend_filter.dart     # 推荐内容过滤器
├── responsive_util.dart      # 响应式布局工具
├── route_push.dart           # 路由跳转工具
└── subtitle.dart             # 字幕格式转换（WebVTT）
```

---

## 2. 完整工具清单

| 文件 | 类/函数 | 功能描述 |
|------|---------|----------|
| `storage.dart` | `GStrorage` + `SettingBoxKey` + `LocalCacheKey` + `VideoBoxKey` | Hive 持久化存储：5 个 Box + 三大键枚举 |
| `utils.dart` | `Utils` (静态类) | 数字格式化、时间格式化、版本比对、MD5签名等 |
| `data.dart` | `Data` | 应用启动时的数据初始化（历史记录等） |
| `global_data_cache.dart` | `GlobalDataCache` (单例) | 全局设置缓存：弹幕、播放器、用户信息 |
| `id_utils.dart` | `IdUtils` (静态类) | bvid ↔ avid 互转、eid 生成 |
| `url_utils.dart` | `UrlUtils` (静态类) | URL 重定向解析、scheme 路由跳转 |
| `video_utils.dart` | `VideoUtils` (静态类) | 视频 CDN URL 智能替换 |
| `danmaku.dart` | `DmUtils` (静态类) | 弹幕颜色十进制转换、弹幕位置类型映射 |
| `event_bus.dart` | `EventBus` (单例) + `EventName` | 发布/订阅事件总线 |
| `app_scheme.dart` | `PiliSchame` (静态类) | Deep Link 初始化、路由分发 |
| `cache_manage.dart` | `CacheManage` (单例) | 缓存目录大小计算、格式化、清除 |
| `cookie.dart` | `SetCookie` (静态类) | Cookie 管理（Ottohub 已用 token 替代） |
| `download.dart` | `DownloadUtils` (静态类) | 图片下载保存、权限请求 |
| `drawer.dart` | `DrawerUtils` (静态类) | 右侧滑出式抽屉弹窗 |
| `em.dart` | `Em` (静态类) | HTML 标签解析、实体解码 |
| `extension.dart` | `ImageExtension` | num 扩展：计算缓存尺寸 |
| `feed_back.dart` | `feedBack()` | 触觉反馈（设置可控） |
| `highlight.dart` | `highlightExistingText()` | 代码语法高亮 |
| `image_save.dart` | `imageSaveDialog()` | 视频封面查看与保存弹窗 |
| `login.dart` | `LoginUtils` (静态类) | 登录状态刷新、WebView 登录确认 |
| `main_stream.dart` | `handleScrollEvent()` | 滚动方向检测，控制底栏/搜索栏显隐 |
| `proxy.dart` | `CustomProxy` + `ProxiedHttpOverrides` | 系统代理读取与 HTTP 代理设置 |
| `recommend_filter.dart` | `RecommendFilter` (静态类) | 推荐视频过滤（时长、点赞比、关注豁免） |
| `responsive_util.dart` | `ResponsiveUtil` (静态类) | 屏幕断点检测、列数计算、间距/字号适配 |
| `route_push.dart` | `RoutePush` (静态类) | 登录页路由快捷跳转 |
| `subtitle.dart` | `SubTitleUtils` (静态类) | JSON 字幕 → WebVTT 格式转换（Isolate） |

---

## 3. Storage 详解

### 3.1 GStrorage 类

`storage.dart` 是项目的存储核心，管理 5 个 Hive Box：

```dart
class GStrorage {
  static late final Box<dynamic> userInfo;    // 用户信息
  static late final Box<dynamic> historyword; // 搜索历史
  static late final Box<dynamic> localCache;  // 本地缓存
  static late final Box<dynamic> setting;     // 应用设置
  static late final Box<dynamic> video;       // 视频播放设置

  static Future<void> init() async { ... }
  static void regAdapter() { ... }
  static Future<void> close() async { ... }
}
```

**Hive Box 清单**:

| Box 名称 | Hive 文件名 | 用途 | 压缩策略 (compactionStrategy) |
|----------|------------|------|------------------------------|
| `userInfo` | `userInfo` | 登录用户信息 (UserInfoData) | deletedEntries > 2 |
| `historyword` | `historyWord` | 搜索关键词历史 | deletedEntries > 10 |
| `localCache` | `localCache` | 弹幕设置、代理、AccessKey 等 | deletedEntries > 4 |
| `setting` | `setting` | 应用设置：播放器、隐私、外观等 | 无（默认策略） |
| `video` | `video` | 视频播放：比例、亮度、倍速等 | 无（默认策略） |

**初始化和清理流程**:

```dart
// 初始化 - 注册适配器后打开 5 个 Box
static Future<void> init() async {
  final Directory dir = await getApplicationSupportDirectory();
  await Hive.initFlutter('$path/hive');
  regAdapter();
  userInfo = await Hive.openBox('userInfo', ...);
  localCache = await Hive.openBox('localCache', ...);
  setting = await Hive.openBox('setting');
  historyword = await Hive.openBox('historyWord', ...);
  video = await Hive.openBox('video');
}

// 关闭 - 压缩后关闭所有 Box
static Future<void> close() async {
  userInfo.compact(); userInfo.close();
  historyword.compact(); historyword.close();
  localCache.compact(); localCache.close();
  setting.compact(); setting.close();
  video.compact(); video.close();
}
```

### 3.2 SettingBoxKey 枚举

`SettingBoxKey` 定义所有应用设置键名，分为四大类：

#### 播放器设置

| 键名 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `btmProgressBehavior` | — | — | 底部进度条行为 |
| `defaultVideoSpeed` | — | — | 默认视频倍速 |
| `defaultVideoQa` | — | — | 默认视频画质 |
| `defaultLiveQa` | — | — | 默认直播画质 |
| `defaultAudioQa` | — | — | 默认音频质量 |
| `autoPlayEnable` | — | — | 自动播放 |
| `fullScreenMode` | — | — | 全屏模式 |
| `defaultDecode` | — | — | 默认解码方式 |
| `danmakuEnable` | bool | — | 弹幕开关 |
| `enableHA` | bool | — | 硬件加速 |
| `enableOnlineTotal` | bool | — | 显示在线总人数 |
| `enableAutoBrightness` | bool | — | 自动亮度 |
| `enableAutoEnter` | bool | — | 自动进入全屏 |
| `enableAutoExit` | bool | — | 自动退出全屏 |
| `p1080` | bool | — | 1080p 高码率 |
| `enableCDN` | bool | — | CDN 加速 |
| `autoPiP` | bool | — | 自动画中画 |
| `enableAutoLongPressSpeed` | bool | false | 自动长按倍速 |
| `enablePlayerControlAnimation` | bool | true | 播放器控制动画 |
| `defaultAoOutput` | — | — | 默认音频输出 |
| `enableGATMode` | bool | — | 港澳台模式 |
| `enableQuickDouble` | bool | — | YouTube 式双击快进 |
| `enableShowDanmaku` | bool | true | 显示弹幕 |
| `enableBackgroundPlay` | bool | false | 后台播放 |
| `fullScreenGestureMode` | — | — | 全屏手势模式 |

#### 推荐设置

| 键名 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enableRcmdDynamic` | bool | — | 推荐动态 |
| `defaultRcmdType` | — | — | 默认推荐类型 |
| `enableSaveLastData` | bool | — | 保存上次数据 |
| `minDurationForRcmd` | int | 0 | 推荐最小时长 |
| `minLikeRatioForRecommend` | int | 0 | 推荐最小点赞比 |
| `exemptFilterForFollowed` | bool | true | 关注 UP 豁免过滤 |
| `applyFilterToRelatedVideos` | bool | true | 相关视频应用过滤 |

#### 外观设置

| 键名 | 类型 | 说明 |
|------|------|------|
| `themeMode` | — | 主题模式 |
| `defaultTextScale` | — | 文字缩放比例 |
| `dynamicColor` | bool | Material You 动态取色 |
| `customColor` | — | 自定义主题色 |
| `enableSingleRow` | bool | 首页单列模式 |
| `displayMode` | — | 显示模式 |
| `customRows` | — | 自定义列数 |
| `enableMYBar` | bool | 我的页面顶栏 |
| `hideSearchBar` | bool | 收起搜索栏 |
| `hideTabBar` | bool | 收起底栏 |
| `tabbarSort` | — | 首页 tabbar 排序 |
| `dynamicBadgeMode` | — | 动态角标模式 |
| `enableGradientBg` | bool | 渐变背景 |
| `navBarSort` | — | 导航栏排序 |
| `actionTypeSort` | List | 操作按钮排序 (like/coin/collect/watchLater/share) |
| `dynamicWideScreenLayout` | — | 动态宽屏布局 (center/waterfall) |
| `waterfallCrossAxisCount` | — | 瀑布流列数 |
| `waterfallLimitWidth` | bool | 瀑布流宽度限制 |
| `waterfallCustomItemWidth` | — | 瀑布流自定义卡片宽度 |
| `waterfallUseCustomItemWidth` | bool | 启用自定义卡片宽度 |
| `useDrawerForUser` | bool | 窄屏使用侧边栏 |

#### 隐私/其他

| 键名 | 类型 | 说明 |
|------|------|------|
| `blackMidsList` | — | 黑名单用户列表 |
| `autoUpdate` | bool | 自动更新 |
| `replySortType` | — | 评论排序 |
| `defaultDynamicType` | — | 默认动态类型 |
| `enableHotKey` | bool | 快捷键 |
| `enableQuickFav` | bool | 快速收藏 |
| `enableWordRe` | bool | 文字替换 |
| `enableSearchWord` | bool | 搜索词推荐 |
| `enableSystemProxy` | bool | 系统代理 |
| `enableAi` | bool | AI 功能 |
| `defaultHomePage` | — | 默认首页 |
| `enableRelatedVideo` | bool | 相关视频 |
| `feedBackEnable` | bool | false | 触觉反馈 |

### 3.3 LocalCacheKey 枚举

| 键名 | 说明 |
|------|------|
| `historyPause` | 历史记录暂停状态（默认 false） |
| `accessKey` | API 访问密钥 |
| `wbiKeys` | WBI 签名密钥 |
| `timeStamp` | 时间戳 |
| `danmakuBlockType` | 弹幕屏蔽类型 |
| `danmakuShowArea` | 弹幕显示区域（默认 0.5=50%） |
| `danmakuOpacity` | 弹幕透明度（默认 1.0） |
| `danmakuFontScale` | 弹幕字体缩放（默认 1.0） |
| `danmakuDuration` | 弹幕持续时间（默认 4 秒） |
| `strokeWidth` | 弹幕描边宽度（默认 1.5） |
| `systemProxyHost` / `systemProxyPort` | 代理地址/端口 |
| `isDisableBatteryOptLocal` | 电池优化禁用状态 |
| `isManufacturerBatteryOptimizationDisabled` | 厂商电池优化状态 |

### 3.4 VideoBoxKey 枚举

| 键名 | 说明 |
|------|------|
| `videoFit` | 视频画面比例 |
| `videoBrightness` | 亮度 |
| `videoSpeed` | 倍速 |
| `playRepeat` | 播放循环模式 |
| `playSpeedSystem` | 系统预设倍速 |
| `playSpeedDefault` | 默认倍速（默认 1.0） |
| `longPressSpeedDefault` | 长按倍速（默认 2.0） |
| `customSpeedsList` | 自定义倍速列表 |
| `cacheVideoFit` | 缓存画面填充 |
| `halfScreenBottomList` | 半屏底部按钮列表 |
| `fullScreenBottomList` | 全屏底部按钮列表 |

---

## 4. 核心工具详解

### 4.1 ID 转换 (`id_utils.dart`)

`IdUtils` 实现 B 站视频 ID 的 av 号与 bv 号互转，以及 Aurora eid 生成。

```dart
class IdUtils {
  static final XOR_CODE = BigInt.parse('23442827791579');
  static final MASK_CODE = BigInt.parse('2251799813685247');
  static final MAX_AID = BigInt.one << (BigInt.from(51)).toInt();
  static final BASE = BigInt.from(58);
  static const data = 'FcwAPNKTMug3GV5Lj7EJnHpWsx4tb8haYeviqBz6rkCy12mUSDQX9RdoZf';
}
```

**核心方法**:

| 方法 | 说明 | 示例 |
|------|------|------|
| `av2bv(int aid)` | av 号 → bv 号 | `av2bv(170001)` → `"BV17x411w7KC"` |
| `bv2av(String bvid)` | bv 号 → av 号 | `bv2av("BV17x411w7KC")` → `170001` |
| `matchAvorBv({String? input})` | 从字符串中提取 av/bv | 返回 `{BV: "...", AV: 123}` |
| `genAuroraEid(int uid)` | 生成 Aurora eid | XOR 加密 + base64url |

**算法原理**:
- av → bv: `(MAX_AID | aid) XOR XOR_CODE`，然后按 BASE(58) 进制转换，再交换固定位置字符
- bv → av: 逆操作，先交换位置，再进制还原，最后 `(tmp & MASK_CODE) XOR XOR_CODE`

### 4.2 URL 工具 (`url_utils.dart`)

`UrlUtils` 提供 URL 重定向解析和 scheme 路由跳转。

```dart
class UrlUtils {
  static Future<String> parseRedirectUrl(String url) async { ... }
  static Future<void> matchUrlPush(String pathSegment, String title, String redirectUrl) async { ... }
}
```

- `parseRedirectUrl`: 发起 HTTP GET（不跟随重定向），解析 301/302 头中的 Location
- `matchUrlPush`: 如果 pathSegment 是纯数字 → 跳转视频播放页；否则 → 跳转 WebView

### 4.3 视频工具 (`video_utils.dart`)

`VideoUtils` 处理视频 CDN URL 的智能替换。

```dart
class VideoUtils {
  static String getCdnUrl(dynamic item) { ... }
}
```

**CDN 替换规则**:
1. 如果 URL 包含 `.mcdn.bilivideo` → 使用代理：`https://proxy-tf-all-ws.bilivideo.com/?url=...`
2. 如果 URL 包含 `/upgcxcode/` → 替换域名为阿里 CDN：`upos-sz-mirrorali.bilivideo.com`
3. 优先使用 `backupUrl`（如果以 http 开头），否则使用 `baseUrl`
4. 支持 `VideoItem` 和 `AudioItem` 两种类型

### 4.4 弹幕工具 (`danmaku.dart`)

`DmUtils` 提供弹幕颜色和类型的转换。

| 方法 | 说明 |
|------|------|
| `decimalToColor(int decimalColor)` | 十进制颜色值 → Flutter Color（16777215=白色） |
| `getPosition(int mode)` | 弹幕 mode 值 → `DanmakuItemType` (scroll/bottom/top) |

弹幕 mode 映射：1-3 → scroll（滚动），4 → bottom（底部），5 → top（顶部）

### 4.5 事件总线 (`event_bus.dart`)

`EventBus` 是应用内轻量级发布/订阅事件系统，单例模式。

```dart
class EventBus {
  factory EventBus() => _singleton;  // 单例
  
  void on(dynamic eventName, EventCallback f);      // 订阅
  void off(dynamic eventName, [EventCallback? f]);  // 取消订阅
  void emit(dynamic eventName, [dynamic arg]);      // 发布事件
  int getSubscriberCount(dynamic eventName);         // 订阅者数量
}

class EventName {
  static const String loginEvent = 'loginEvent';  // 登录事件
}
```

**当前已定义事件**: `loginEvent` – 登录状态变更时触发，各页面控制器订阅此事件更新 UI。

---

## 5. GlobalDataCache 详解

`GlobalDataCache` 是单例模式的全局数据缓存，在应用启动时从 Hive 加载所有设置到内存。

### 缓存字段分类

**图片与外观**:
- `imgQuality` — 图片质量等级（默认 10）
- `fullScreenGestureMode` — 全屏手势模式
- `enablePlayerControlAnimation` — 播放器控制动画（默认 true）
- `actionTypeSort` — 操作按钮排序（默认：like, coin, collect, watchLater, share）

**弹幕相关**:
- `isOpenDanmu` — 弹幕开关（默认 true）
- `blockTypes` — 屏蔽类型列表（默认 []）
- `showArea` — 显示区域（默认 0.5=50%）
- `opacityVal` — 透明度（默认 1.0）
- `fontSizeVal` — 字体缩放（默认 1.0）
- `danmakuDurationVal` — 显示时长秒数（默认 4.0）
- `strokeWidth` — 描边宽度（默认 1.5）

**播放器**:
- `playRepeat` — 循环模式（默认 PlayRepeat.pause）
- `playbackSpeed` — 播放倍速（默认 1.0）
- `enableAutoLongPressSpeed` — 自动长按倍速（默认 false）
- `longPressSpeed` — 长按倍速（默认 2.0）
- `speedsList` — 可用倍速列表（系统预设 + 自定义）

**用户**:
- `userInfo` — 当前登录用户信息

---

## 6. 其他重要工具

### App Scheme (`app_scheme.dart`)

`PiliSchame` 处理 Deep Link，注册 Scheme 监听器，支持以下路由：

| Host | 路由 |
|------|------|
| `root` | 返回首页根 |
| `u` / `user` | `/member?mid=` |
| `v` / `video` | `/video?vid=` |
| `b` / `blog` | 暂不支持 |
| `search` | `/search` |
| `https://ottohub.cn/*` | 域名匹配跳转，否则 WebView |

### 推荐过滤器 (`recommend_filter.dart`)

`RecommendFilter` 静态类，根据用户设置过滤推荐视频：

- `minDurationForRcmd` — 最小时长过滤（默认 0=不过滤）
- `minLikeRatioForRecommend` — 最小点赞比过滤（默认 0=不过滤）
- `exemptFilterForFollowed` — 已关注 UP 豁免（默认 true）
- `applyFilterToRelatedVideos` — 相关视频也应用过滤（默认 true）

### 字幕转换 (`subtitle.dart`)

`SubTitleUtils` 使用 Dart Isolate 在后台线程将 JSON 字幕数据转换为 WebVTT 格式，避免阻塞 UI。

### 缓存管理 (`cache_manage.dart`)

`CacheManage` 单例类，计算和清除应用缓存：

- `loadApplicationCache()` — 计算临时目录 + DioCache.db 大小
- `clearCacheAll()` — 弹窗确认后清除
- `formatSize(double)` — 字节转可读格式 (B/K/M/G)

---

## 7. 使用示例

### 7.1 存储工具使用

```dart
import 'package:piliotto/utils/storage.dart';

Future<void> initApp() async {
  await GStrorage.init();
  
  final isLogin = GStrorage.userInfo.get('isLogin', defaultValue: false);
  final themeMode = GStrorage.setting.get(SettingBoxKey.themeMode, defaultValue: 'system');
  
  await GStrorage.setting.put(SettingBoxKey.feedBackEnable, true);
  await GStrorage.localCache.put(LocalCacheKey.danmakuOpacity, 0.8);
}

Future<void> saveUserSettings() async {
  await GStrorage.setting.put(SettingBoxKey.autoPlayEnable, true);
  await GStrorage.setting.put(SettingBoxKey.defaultVideoSpeed, 1.5);
  await GStrorage.video.put(VideoBoxKey.videoSpeed, 1.0);
}
```

### 7.2 ID 转换工具

```dart
import 'package:piliotto/utils/id_utils.dart';

void convertVideoId() {
  final bvid = IdUtils.av2bv(170001);
  print('BV号: $bvid');
  
  final aid = IdUtils.bv2av('BV17x411w7KC');
  print('AV号: $aid');
  
  final result = IdUtils.matchAvorBv(input: 'https://example.com/video/BV17x411w7KC');
  print('BV: ${result['BV']}, AV: ${result['AV']}');
}
```

### 7.3 事件总线使用

```dart
import 'package:piliotto/utils/event_bus.dart';

class LoginManager {
  void onLoginSuccess() {
    EventBus().emit(EventName.loginEvent, true);
  }
}

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    EventBus().on(EventName.loginEvent, (arg) {
      print('登录状态变更: $arg');
      setState(() {});
    });
  }
  
  @override
  void dispose() {
    EventBus().off(EventName.loginEvent);
    super.dispose();
  }
}
```

### 7.4 缓存管理

```dart
import 'package:piliotto/utils/cache_manage.dart';

class StoragePage extends StatelessWidget {
  final CacheManage _cacheManage = CacheManage();
  
  Future<void> checkCache() async {
    final size = await _cacheManage.loadApplicationCache();
    print('缓存大小: ${_cacheManage.formatSize(size)}');
  }
  
  Future<void> clearCache() async {
    await _cacheManage.clearCacheAll();
    print('缓存已清除');
  }
}
```

---

## 8. 开发指南

### 新增工具文件

1. 在 `lib/utils/` 创建新文件
2. 如果是纯工具函数，使用静态类
3. 如果需要状态管理，使用单例模式（参考 `CacheManage`）
4. 如果涉及 Hive 读写，使用 `GStrorage` 的 Box
5. 如果涉及平台特性，添加 `Platform.isAndroid` / `Platform.isIOS` 检查

### 工具命名规范

- 静态工具类使用 `Utils` 后缀：`IdUtils`, `UrlUtils`, `DmUtils`
- 存储类使用描述性名称：`GStrorage`, `GlobalDataCache`
- 函数使用 `camelCase`：`feedBack()`, `handleScrollEvent()`

### 依赖关系

```
storage.dart ←─ 几乎所有模块
global_data_cache.dart ←─ storage.dart + models
event_bus.dart ←─ 跨模块通信
utils.dart ←─ 通用工具，被 UI 层广泛使用
```

---

## 9. 二改指南

### 常见二改场景

#### 场景 1: 添加新的设置项

```dart
// 在 storage.dart 的 SettingBoxKey 中添加
class SettingBoxKey {
  // ... 现有键 ...
  static const String yourNewSetting = 'yourNewSetting';
}
```

然后在需要的地方读写：
```dart
GStrorage.setting.put(SettingBoxKey.yourNewSetting, value);
final val = GStrorage.setting.get(SettingBoxKey.yourNewSetting, defaultValue: defaultValue);
```

如果需要在 GlobalDataCache 中缓存，在 `global_data_cache.dart` 的 `initialize()` 中添加：

```dart
yourNewField = await setting.get(SettingBoxKey.yourNewSetting, defaultValue: defaultValue);
```

#### 场景 2: 添加新的事件类型

在 `event_bus.dart` 的 `EventName` 类中添加：

```dart
class EventName {
  static const String loginEvent = 'loginEvent';
  static const String yourNewEvent = 'yourNewEvent'; // 新增
}
```

#### 场景 3: 修改推荐过滤逻辑

编辑 `recommend_filter.dart` 的 `filter()` 方法：

```dart
static bool filter(dynamic videoItem, {bool relatedVideos = false}) {
  // 在此添加新的过滤条件
  if (videoItem.duration > 0 && videoItem.duration < minDurationForRcmd) {
    return true; // 过滤掉
  }
  // ... 现有逻辑 ...
}
```

#### 场景 4: 修改 Deep Link 路由

编辑 `app_scheme.dart` 的 `_routePush()` 方法：

```dart
switch (host) {
  // ... 现有 case ...
  case 'your_new_host':
    Get.toNamed('/yourNewPage');
    break;
}
```

### 注意事项

- 修改 `storage.dart` 的键枚举时，需要确保已有数据的兼容性
- `global_data_cache.dart` 是单例，在整个应用生命周期内只初始化一次
- `event_bus.dart` 在页面 dispose 时需取消订阅，避免内存泄漏
- `subtitle.dart` 使用 Isolate，注意大文件时内存使用
- `recommend_filter.dart` 是静态类，`update()` 方法需在设置变更时手动调用