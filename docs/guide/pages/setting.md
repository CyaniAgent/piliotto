---
date: 2026-05-14 22:57:57
title: setting
permalink: /pages/67719c
categories:
  - guide
  - pages
---
# 设置页（Setting）

## 1. 模块概述（含设置层级结构图）

设置模块位于 `lib/pages/setting/`，是 PiliOtto 应用全局设置的核心入口，提供四个一级设置分类和十个子设置页面，覆盖外观主题、播放器行为、导航布局和隐私管理等配置。

### 文件结构

```
lib/pages/setting/
├── controller.dart             # SettingController - 全局设置控制器
├── view.dart                   # SettingPage - 设置主入口（列表导航）
├── index.dart                  # 模块统一导出
├── style_setting.dart          # StyleSetting - 外观设置子页面
├── play_setting.dart           # PlaySetting - 播放设置子页面
├── extra_setting.dart          # ExtraSetting - 其他设置子页面
├── privacy_setting.dart        # PrivacySetting - 隐私设置子页面
├── widgets/                    # 可复用的设置 UI 组件
│   ├── select_dialog.dart      # SelectDialog<T> - 通用单选对话框
│   ├── select_item.dart        # SetSelectItem - 下拉选择项（视频/音频质量等）
│   ├── slide_dialog.dart       # SlideDialog<T> - 滑块调节对话框
│   └── switch_item.dart        # SetSwitchItem - 开关设置项（自动读写 Hive）
└── pages/                      # 子设置页面（独立的详情配置页）
    ├── action_menu_set.dart    # ActionMenuSetPage - 视频操作菜单排序
    ├── bottom_control_set.dart # BottomControlSetPage - 播放器底部按钮配置
    ├── color_select.dart       # ColorSelectPage - 应用主题色选择
    ├── display_mode.dart       # SetDiaplayMode - 屏幕帧率设置
    ├── font_size_select.dart   # FontSizeSelectPage - 字体大小设置
    ├── home_tabbar_set.dart    # TabbarSetPage - 首页 Tab 排序
    ├── logs.dart               # LogsPage - 日志查看器
    ├── navigation_bar_set.dart # NavigationBarSetPage - 底部导航栏编辑
    ├── play_gesture_set.dart   # PlayGesturePage - 播放器手势设置
    └── play_speed_set.dart     # PlaySpeedPage - 倍速配置
```

### 设置层级结构图

```
SettingPage (主入口 ── ListView 导航)
├── 播放设置 ──────────► PlaySetting
│   ├── 倍速设置 ───────► PlaySpeedPage
│   ├── 手势设置 ───────► PlayGesturePage
│   ├── 底部按钮设置 ───► BottomControlSetPage
│   ├── 自动播放          (Switch)
│   ├── 后台播放          (Switch)
│   ├── 自动PiP播放       (Switch, Android)
│   ├── 自动全屏          (Switch)
│   ├── 自动退出          (Switch)
│   ├── 开启硬解          (Switch)
│   ├── 亮度记忆          (Switch)
│   ├── 弹幕开关          (Switch)
│   ├── 控制栏动画        (Switch)
│   ├── 默认全屏方式      (SelectDialog)
│   └── 底部进度条展示    (SelectDialog)
│
├── 外观设置 ──────────► StyleSetting
│   ├── 震动反馈          (Switch)
│   ├── MD3样式底栏       (Switch, SetSwitchItem)
│   ├── 首页顶栏收起      (Switch, 重启生效)
│   ├── 首页底栏收起      (Switch, 重启生效)
│   ├── 窄屏使用侧边栏    (Switch, 重启生效)
│   ├── 首页顶部背景渐变  (Switch, 重启生效)
│   ├── 自定义列数        (SelectDialog)
│   ├── 图片质量          (Slider)
│   ├── Toast不透明度     (SlideDialog)
│   ├── 主题模式          (SelectDialog: 浅色/深色/跟随系统)
│   ├── 动态未读标记      (SelectDialog: 数字/红点)
│   ├── 应用主题 ────────► ColorSelectPage      (动态取色 / 指定颜色)
│   ├── 默认启动页        (SelectDialog)
│   ├── 字体大小 ────────► FontSizeSelectPage   (Slider: 0.9 ~ 1.3)
│   ├── 首页tabbar ─────► TabbarSetPage         (CheckboxListTile + ReorderableListView)
│   ├── 底部导航栏设置 ──► NavigationBarSetPage  (CheckboxListTile + ReorderableListView)
│   ├── 操作菜单设置 ────► ActionMenuSetPage     (CheckboxListTile + ReorderableListView, 已注释)
│   └── 屏幕帧率 ────────► SetDiaplayMode        (RadioListTile, Android)
│
├── 其他设置 ──────────► ExtraSetting
│   ├── 相关视频推荐      (Switch)
│   ├── 评论展示          (SelectDialog: 热门/最新)
│   └── 检查更新          (Switch)
│
├── 隐私设置 ──────────► PrivacySetting
│   └── 黑名单管理 ──────► /blackListPage
│
├── 退出登录 (仅已登录可见)
└── 关于 ──────────────► /about
```

### 依赖关系

```
SettingPage (view.dart)
  ├── Get.put → SettingController (controller.dart)
  └── 导航到各子页面路由

SettingController (controller.dart)
  ├── GStrorage.userInfo (Hive Box) ── 用户登录状态
  ├── GStrorage.setting (Hive Box)   ── 全局设置持久化
  ├── GStrorage.localCache (Hive Box)── 本地缓存
  └── LoginUtils.refreshLoginStatus() ── 登录状态刷新

各子页面
  ├── GStrorage.setting (Hive Box)   ── SettingBoxKey 常量
  ├── GStrorage.video (Hive Box)     ── VideoBoxKey 常量（播放器相关）
  └── GlobalDataCache()              ── 运行时全局配置缓存
```

### 路由入口

| 路由 | 页面 | 说明 |
|------|------|------|
| `/setting` | `SettingPage` | 设置主入口（不需要登录） |
| `/playSetting` | `PlaySetting` | 播放设置 |
| `/styleSetting` | `StyleSetting` | 外观设置 |
| `/extraSetting` | `ExtraSetting` | 其他设置 |
| `/privacySetting` | `PrivacySetting` | 隐私设置 |
| `/playSpeedSet` | `PlaySpeedPage` | 倍速设置 |
| `/playerGestureSet` | `PlayGesturePage` | 手势设置 |
| `/bottomControlSet` | `BottomControlSetPage` | 底部按钮设置 |
| `/colorSetting` | `ColorSelectPage` | 应用主题色 |
| `/displayModeSetting` | `SetDiaplayMode` | 屏幕帧率（仅 Android） |
| `/fontSizeSetting` | `FontSizeSelectPage` | 字体大小 |
| `/tabbarSetting` | `TabbarSetPage` | 首页 Tab 编辑 |
| `/navbarSetting` | `NavigationBarSetPage` | 底部导航栏编辑 |
| `/actionMenuSet` | `ActionMenuSetPage` | 操作菜单排序 |
| `/logs` | `LogsPage` | 日志查看 |

---

## 2. SettingController 详解

**源文件：** `controller.dart`

`SettingController` 继承自 `GetxController`，管理全局设置的读取、写入和业务操作，是设置模块的核心控制器。

### 2.1 依赖

| 依赖 | 来源 | 说明 |
|------|------|------|
| `GStrorage.userInfo` | Hive Box | 读取当前登录用户信息 |
| `GStrorage.setting` | Hive Box | 读写 `SettingBoxKey.*` 持久化设置 |
| `GStrorage.localCache` | Hive Box | 读写 `LocalCacheKey.*` 本地缓存 |
| `LoginUtils.refreshLoginStatus()` | utils/login.dart | 退出登录时刷新全局登录态 |

### 2.2 核心属性

| 属性 | 类型 | 说明 | 默认值 |
|------|------|------|--------|
| `userLogin` | `RxBool` | 当前是否已登录 | `false` |
| `feedBackEnable` | `RxBool` | 震动反馈开关 | `false` |
| `toastOpacity` | `RxDouble` | Toast 不透明度 (0.0 ~ 1.0) | `1.0` |
| `picQuality` | `RxInt` | 图片质量百分比 (10 ~ 100) | `10` |
| `themeType` | `Rx<ThemeType>` | 主题模式：浅色 / 深色 / 跟随系统 | `ThemeType.system` |
| `dynamicBadgeType` | `Rx<DynamicBadgeMode>` | 动态未读标记模式：数字 / 红点 | `DynamicBadgeMode.number` |
| `defaultHomePage` | `RxInt` | 默认启动页 ID | `0` |

### 2.3 核心方法

#### `onInit()`
从 Hive Box 读取所有持久化设置，初始化响应式属性。

#### `loginOut()`
弹出确认对话框，确认后清除 `userInfoCache` 和 `accessKey`，调用 `LoginUtils.refreshLoginStatus(false)` 并返回上一页。

#### `onOpenFeedBack()`
切换震动反馈开关，调用 `feedBack()` 立即播放一次震动反馈效果，并持久化到 Hive。

#### `setDynamicBadgeMode(BuildContext context)`
弹出 `SelectDialog<DynamicBadgeMode>` 选择动态未读标记模式（数字 / 红点），设置成功后同步更新 `MainController.dynamicBadgeType`。

#### `seteDefaultHomePage(BuildContext context)`
弹出 `SelectDialog<int>` 选择默认启动的首页 Tab，使用 `defaultNavigationBars` 配置作为选项数据源。设置成功后提示"重启生效"。

---

## 3. SettingView 详解

**源文件：** `view.dart`

`SettingPage` 是一个 `StatelessWidget`，使用 `ListView` 构建设置项导航列表。

### 3.1 页面结构

```
Scaffold
├── AppBar (title: "设置", titleMedium)
└── body: ListView
    ├── ListTile [播放设置]       → /playSetting
    ├── ListTile [外观设置]       → /styleSetting
    ├── ListTile [其他设置]       → /extraSetting
    ├── Visibility
    │   └── ListTile [退出登录]   → loginOut()  (仅登录时可见)
    └── ListTile [关于]           → /about
```

### 3.2 设置项组件

每个设置项使用内部 `buildSettingItem()` 函数构建，参数：

```dart
Widget buildSettingItem(
  IconData icon,    // 左侧图标
  String title,     // 主标题
  String subtitle,  // 副标题
  VoidCallback onTap, // 点击回调
)
```

每个 `ListTile` 使用 `colorScheme.primary` 作为图标色，`onSurface` 为主标题色，`outline` 为副标题色。

### 3.3 退出登录

退出登录仅对已登录用户可见，点击调用 `settingController.loginOut()`。该方法会：
1. 弹出确认对话框
2. 确认后清空 `userInfoCache` 和 `accessKey`
3. 刷新全局登录态
4. 返回上一页

---

## 4. StyleSetting 详解（外观设置）

**源文件：** `style_setting.dart`

`StyleSetting` 是一个 `StatefulWidget`，管理主题模式、颜色、字体、显示等所有外观相关配置。

### 4.1 设置项详细列表

| 设置项 | 实现方式 | 存储 Key | 说明 |
|--------|----------|----------|------|
| 震动反馈 | Switch + `onOpenFeedBack()` | `feedBackEnable` | 切换时播放一次震动 |
| MD3样式底栏 | `SetSwitchItem` | `enableMYBar` | 默认 `true` |
| 首页顶栏收起 | `SetSwitchItem` | `hideSearchBar` | 默认 `true`，重启生效 |
| 首页底栏收起 | `SetSwitchItem` | `hideTabBar` | 默认 `true`，重启生效 |
| 窄屏使用侧边栏 | `SetSwitchItem` | `useDrawerForUser` | 默认 `true`，重启生效 |
| 首页顶部背景渐变 | `SetSwitchItem` | `enableGradientBg` | 默认 `true`，重启生效 |
| 自定义列数 | `SelectDialog<int>` | `customRows` | 选项：1 / 2 / 3 / 4 / 5 列，默认 `2` |
| 图片质量 | `Slider` (AlertDialog) | `defaultPicQa` | 范围 10% ~ 100%，步长 10%；同步更新 `GlobalDataCache().imgQuality` |
| Toast不透明度 | `SlideDialog<double>` | `defaultToastOp` | 范围 0.0 ~ 1.0，10 等分 |
| 主题模式 | `SelectDialog<ThemeType>` | `themeMode` | 浅色 / 深色 / 跟随系统；切换后 `Get.forceAppUpdate()` |
| 动态未读标记 | `SelectDialog<DynamicBadgeMode>` | `dynamicBadgeMode` | 数字 / 红点；同步 MainController |
| 应用主题 | 跳转 `/colorSetting` | `dynamicColor` + `customColor` | 动态取色 / 指定颜色 |
| 默认启动页 | `SelectDialog<int>` | `defaultHomePage` | 选完提示"重启生效" |
| 字体大小 | 跳转 `/fontSizeSetting` | `defaultTextScale` | 范围 0.9 ~ 1.3 |
| 首页tabbar | 跳转 `/tabbarSetting` | `tabbarSort` | 排序 + 显示 / 隐藏 |
| 底部导航栏设置 | 跳转 `/navbarSetting` | `navBarSort` | 排序 + 显示 / 隐藏 |
| 操作菜单设置 | 跳转 `/actionMenuSet`（已注释） | `actionTypeSort` | 视频操作菜单排序 |
| 屏幕帧率 | 跳转 `/displayModeSetting`（仅 Android） | `displayMode` | 高刷设置 |

### 4.2 主题颜色选择（ColorSelectPage）

`color_select.dart`

提供两种模式：
- **动态取色**（`type = 0`）：使用 Material You 动态配色
- **指定颜色**（`type = 1`）：从预设色板中选择，色板由 `colorThemeTypes` 配置提供

`ColorSelectController` 管理当前选择，切换颜色时调用 `Get.forceAppUpdate()` 立即生效。

### 4.3 字体大小（FontSizeSelectPage）

`font_size_select.dart`

使用 `Slider` 选择字体缩放比例（0.9 ~ 1.3，9 档），实时预览当前字体效果。确定后调用 `Get.forceAppUpdate()` 立即生效。

### 4.4 屏幕帧率（SetDiaplayMode）

`display_mode.dart`

仅 Android 平台可用，使用 `flutter_displaymode` 插件读取系统支持的显示模式，通过 `RadioListTile` 切换并立即应用。

### 4.5 首页 Tab 编辑（TabbarSetPage）

`home_tabbar_set.dart`

使用 `CheckboxListTile` + `ReorderableListView` 实现 Tab 的显示 / 隐藏和排序。数据源为 `tabsConfig`，修改后持久化到 `tabbarSort`（`List<String>`），提示"下次启动时生效"。

### 4.6 底部导航栏编辑（NavigationBarSetPage）

`navigation_bar_set.dart`

与 Tab 编辑逻辑类似，数据源为 `defaultNavigationBars`，管理底部导航栏的显示 / 隐藏和排序。自动处理新增页面和移除不存在的页面 ID。

---

## 5. PlaySetting 详解（播放器设置）

**源文件：** `play_setting.dart`

`PlaySetting` 管理视频播放器的所有行为配置。

### 5.1 设置项详细列表

| 设置项 | 实现方式 | 存储 Key | 默认值 | 说明 |
|--------|----------|----------|--------|------|
| 倍速设置 | 跳转 `/playSpeedSet` | 多个 `VideoBoxKey.*` | - | 系统预设倍速 + 自定义倍速 |
| 手势设置 | 跳转 `/playerGestureSet` | `fullScreenGestureMode` | - | 全屏手势 + 双击快进退 |
| 底部按钮设置 | 跳转 `/bottomControlSet` | `halfScreenBottomList` + `fullScreenBottomList` | - | 半屏 / 全屏底部按钮 |
| 自动播放 | `SetSwitchItem` | `autoPlayEnable` | `true` | 进入详情页自动播放 |
| 后台播放 | `SetSwitchItem` | `enableBackgroundPlay` | `false` | 进入后台继续播放 |
| 自动PiP播放 | `SetSwitchItem` | `autoPiP` | `false` | Android 画中画 |
| 自动全屏 | `SetSwitchItem` | `enableAutoEnter` | `false` | 播放时自动进入全屏 |
| 自动退出 | `SetSwitchItem` | `enableAutoExit` | `false` | 播放结束退出全屏 |
| 开启硬解 | `SetSwitchItem` | `enableHA` | `false` | 低功耗硬解码 |
| 亮度记忆 | `SetSwitchItem` | `enableAutoBrightness` | `false` | 返回时恢复视频亮度 |
| 弹幕开关 | `SetSwitchItem` | `enableShowDanmaku` | `false` | 展示弹幕 |
| 控制栏动画 | `SetSwitchItem` | `enablePlayerControlAnimation` | `true` | 播放器控制栏动画效果；回调同步 `GlobalDataCache` |
| 默认全屏方式 | `SelectDialog<int>` | `fullScreenMode` | 第一个值 | `FullScreenMode` 枚举 |
| 底部进度条展示 | `SelectDialog<int>` | `btmProgressBehavior` | 第一个值 | `BtmProgresBehavior` 枚举 |

### 5.2 倍速设置（PlaySpeedPage）

`play_speed_set.dart`

功能丰富的倍速管理页面：

- **系统预设倍速**：从 `VideoBoxKey.playSpeedSystem` 读取，以 `FilledButton.tonal` 展示
- **自定义倍速**：通过 TextField 输入任意倍速值，添加到 `VideoBoxKey.customSpeedsList`
- **默认倍速**：点击预设倍速按钮 → 底部弹出菜单 → 选择"设置为默认倍速" / "设置为默认长按倍速" / "删除该项"
- **动态长按倍速**：开启后自动将长按倍速设为默认倍速的 2 倍，隐藏手动设置长按倍速的选项
- 所有数据存储在 `GStrorage.video` (Hive Box) 中

底部菜单操作（`showBottomSheet`）：

| 菜单 ID | 标题 | 说明 |
|---------|------|------|
| 1 | 设置为默认倍速 | 将选中倍速写入 `playSpeedDefault` |
| 2 | 设置为默认长按倍速 | 将选中倍速写入 `longPressSpeedDefault`（动态模式时隐藏） |
| -1 | 删除该项 | 从列表中移除（默认倍速不可删除） |

### 5.3 手势设置（PlayGesturePage）

`play_gesture_set.dart`

- **全屏手势**：通过 `SelectDialog<String>` 从 `FullScreenGestureMode` 枚举中选择
- **双击快退/快进**：`SetSwitchItem` 开关，键 `enableQuickDouble`，默认 `true`

### 5.4 底部按钮设置（BottomControlSetPage）

`bottom_control_set.dart`

使用 `TabBar` 分离半屏和全屏两种模式：

- **半屏默认**：playOrPause, time, space, fit, fullscreen
- **全屏默认**：playOrPause, time, space, episode, fit, speed, fullscreen
- 支持：添加按钮（`ActionChip` 底部弹窗）、删除按钮、拖拽排序、重置默认
- 可选按钮类型：`BottomControlType` 枚举（playOrPause, time, space, episode, fit, speed, fullscreen）
- 数据存储在 `GStrorage.video` 中

---

## 6. ExtraSetting 详解（其他设置）

**源文件：** `extra_setting.dart`

`ExtraSetting` 管理不属于播放和外观的杂项配置。

### 6.1 设置项详细列表

| 设置项 | 实现方式 | 存储 Key | 默认值 | 说明 |
|--------|----------|----------|--------|------|
| 相关视频推荐 | `SetSwitchItem` | `enableRelatedVideo` | `true` | 视频详情页展示相关视频推荐 |
| 评论展示 | `SelectDialog<int>` | `replySortType` | `0` | 热门优先 / 最新优先；旧值 `2` 自动修正为 `0` |
| 检查更新 | `SetSwitchItem` | `autoUpdate` | `false` | 启动时检查更新，开启时触发 `Utils.checkUpdata()` |

---

## 7. 子设置页面汇总

### 7.1 ActionMenuSetPage（操作菜单设置）

`action_menu_set.dart`

- 管理视频操作菜单（点赞、投币、收藏、稍后再看、分享）的排序和显示 / 隐藏
- `CheckboxListTile` + `ReorderableListView`，数据源 `actionMenuConfig`
- 保存到 `actionTypeSort`，同步 `GlobalDataCache().actionTypeSort`
- 当前在 StyleSetting 中已注释

### 7.2 BottomControlSetPage（底部按钮设置）

详见 5.4 节。

### 7.3 ColorSelectPage（应用主题色选择）

详见 4.2 节。

### 7.4 SetDiaplayMode（屏幕帧率设置）

详见 4.4 节。

### 7.5 FontSizeSelectPage（字体大小设置）

详见 4.3 节。

### 7.6 TabbarSetPage（首页 Tab 编辑）

详见 4.5 节。

### 7.7 LogsPage（日志查看器）

`logs.dart`

- 读取本地日志文件并解析展示
- 解析规则：以 `====...====` 为分隔符，将原始 crash 日志解析为时间 + 正文结构
- 支持：复制全部日志、单独复制一条日志、清空日志、跳转到 GitHub Issues 反馈
- 使用 `services/loggeer.dart` 的 `getLogsPath()` 和 `clearLogs()` 方法

### 7.8 NavigationBarSetPage（底部导航栏编辑）

详见 4.6 节。

### 7.9 PlayGesturePage（播放器手势设置）

详见 5.3 节。

### 7.10 PlaySpeedPage（倍速设置）

详见 5.2 节。

---

## 8. 数据流

```
                       ┌─────────────────────┐
                       │   SettingPage        │
                       │   Get.put(ctr)       │
                       └──────────┬──────────┘
                                  │
                    ┌─────────────┼─────────────┐
                    ▼             ▼             ▼
           ┌───────────┐  ┌───────────┐  ┌───────────┐
           │PlaySetting│  │StyleSetting│  │ExtraSetting│
           └─────┬─────┘  └─────┬─────┘  └─────┬─────┘
                 │              │              │
    ┌────────────┼──────┐  ┌────┼──────┐      │
    ▼            ▼      ▼  ▼    ▼      ▼      ▼
┌────────┐ ┌────────┐ ┌──────────────────────────────┐
│PlaySpeed│ │Gesture │ │ SetSwitchItem / SelectDialog │
│  Page   │ │  Page  │ │ Slider / SlideDialog         │
└────┬────┘ └────┬───┘ └──────────────┬───────────────┘
     │           │                    │
     ▼           ▼                    ▼
┌────────────────────────────────────────────────────┐
│              Hive 持久化存储                         │
│  ┌─────────────────┐  ┌──────────────────────────┐ │
│  │ GStrorage.setting│  │  GStrorage.video         │ │
│  │ (SettingBoxKey.*)│  │  (VideoBoxKey.*)         │ │
│  └─────────────────┘  └──────────────────────────┘ │
└────────────────────────────────────────────────────┘
                              │
                              ▼
                   ┌─────────────────────┐
                   │  GlobalDataCache()  │  (运行时缓存)
                   │  - imgQuality       │
                   │  - actionTypeSort   │
                   │  - enablePlayer...  │
                   │  - fullScreenGesture│
                   └─────────────────────┘
```

### 数据存储分类

| 存储 Box | 常量前缀 | 存储内容 | 示例 |
|----------|----------|----------|------|
| `GStrorage.setting` | `SettingBoxKey.*` | 全局 UI / 行为设置 | 主题模式、字体大小、开关状态 |
| `GStrorage.video` | `VideoBoxKey.*` | 播放器相关设置 | 倍速、底部按钮、手势 |
| `GlobalDataCache()` | 内存单例 | 需要即时生效的缓存 | 图片质量、操作菜单排序 |

### 设置生效方式

| 生效方式 | 使用场景 | 实现 |
|----------|----------|------|
| 即时生效 | 主题模式、字体大小、图片质量、颜色选择 | `Get.forceAppUpdate()` 或直接更新 `GlobalDataCache` |
| 重启生效 | 导航栏、TabBar、顶栏底栏收起 | `SetSwitchItem` 的 `needReboot: true`，弹 Toast "重启生效" |
| 下次启动 | 首页 Tab 排序、底部导航栏排序 | 手动 Toast "下次启动时生效" |

---

## 9. 使用示例

### 9.1 设置页面跳转

```dart
import 'package:get/get.dart';

void navigateToSetting() {
  Get.toNamed('/setting');
}

void navigateToStyleSetting() {
  Get.toNamed('/styleSetting');
}

void navigateToPlaySetting() {
  Get.toNamed('/playSetting');
}

void navigateToDanmakuSetting() {
  Get.toNamed('/danmakuSetting');
}
```

### 9.2 读取和修改设置项

```dart
import 'package:piliotto/utils/storage.dart';

void readSettings() {
  final themeMode = GStrorage.setting.get(
    SettingBoxKey.themeMode, 
    defaultValue: 'system',
  );
  final autoPlay = GStrorage.setting.get(
    SettingBoxKey.autoPlayEnable, 
    defaultValue: true,
  );
  final defaultSpeed = GStrorage.video.get(
    VideoBoxKey.videoSpeed, 
    defaultValue: 1.0,
  );
  
  print('主题模式: $themeMode');
  print('自动播放: $autoPlay');
  print('默认倍速: $defaultSpeed');
}

void updateSettings() async {
  await GStrorage.setting.put(SettingBoxKey.themeMode, 'dark');
  await GStrorage.setting.put(SettingBoxKey.autoPlayEnable, false);
  await GStrorage.video.put(VideoBoxKey.videoSpeed, 1.5);
  
  Get.forceAppUpdate();
}
```

### 9.3 设置组件使用

```dart
import 'package:piliotto/common/widgets/set_switch_item.dart';

class MySettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SetSwitchItem(
          title: '自动播放',
          subtitle: '进入视频详情页自动开始播放',
          setKey: SettingBoxKey.autoPlayEnable,
          defaultVal: true,
          onChanged: (value) {
            print('自动播放: $value');
          },
        ),
        SetSwitchItem(
          title: '后台播放',
          subtitle: '应用切换到后台时继续播放音频',
          setKey: SettingBoxKey.backgroundPlayEnable,
          defaultVal: false,
          needReboot: true,
        ),
      ],
    );
  }
}
```

### 9.4 主题切换

```dart
import 'package:piliotto/utils/storage.dart';

void changeTheme(String themeMode) async {
  await GStrorage.setting.put(SettingBoxKey.themeMode, themeMode);
  Get.changeThemeMode(
    themeMode == 'dark' 
      ? ThemeMode.dark 
      : themeMode == 'light' 
        ? ThemeMode.light 
        : ThemeMode.system,
  );
  Get.forceAppUpdate();
}

void changeThemeColor(Color color) async {
  await GStrorage.setting.put(SettingBoxKey.themeColor, color.value);
  Get.changeTheme(Get.theme.copyWith(primaryColor: color));
  Get.forceAppUpdate();
}
```

---

## 10. 开发指南

### 10.1 添加新的子设置页面

1. 在 `lib/pages/setting/pages/` 下创建新的页面文件和路由
2. 在对应的一级设置页面（StyleSetting / PlaySetting / ExtraSetting）中添加 `ListTile` 跳转入口
3. 确保页面正确使用 `GStrorage.setting` 或 `GStrorage.video` 读写数据

### 10.2 Widgets 组件使用指南

四个可复用的设置组件：

| 组件 | 用途 | 泛型 |
|------|------|------|
| `SelectDialog<T>` | 单选列表弹窗（RadioListTile） | 任意类型 |
| `SetSelectItem` | 带 PopupMenuButton 的下拉选择（视频质量等） | 无泛型，按 `setKey` 判断类型 |
| `SlideDialog<T extends num>` | 滑块调节弹窗 | 数值类型 |
| `SetSwitchItem` | 自动读写 Hive 的开关组件 | 无泛型 |

`SetSwitchItem` 的关键参数：

```dart
SetSwitchItem(
  title: '设置名称',
  subTitle: '描述',         // 可选
  setKey: SettingBoxKey.xx, // 必填：Hive 存储 key
  defaultVal: false,        // 必填：默认值
  callFn: (bool val) {},    // 可选：状态变化回调
  needReboot: false,        // 可选：是否需要重启生效
)
```

### 10.3 SettingBoxKey 常量

所有 Hive setting box 的 key 常量定义在 `lib/utils/storage.dart` 的 `SettingBoxKey` 类中。添加新设置项时需要同时在此处定义常量：

```dart
class SettingBoxKey {
  static const String feedBackEnable = 'feedBackEnable';
  static const String themeMode = 'themeMode';
  static const String customColor = 'customColor';
  static const String defaultPicQa = 'defaultPicQa';
  // ...more keys
}
```

### 10.4 隐私设置

`PrivacySetting` 是一个独立页面类，当前仅包含黑名单管理入口。需要登录态才能查看，点击时验证 `userLogin` 状态。

---

## 11. 二改指南

### 11.1 常见需求

#### 调整设置项顺序
在各一级设置页面的 `ListView` 中调整 `children` 的顺序即可。例如在 `StyleSetting` 中将主题模式放在第一位。

#### 修改默认值
修改对应 `SetSwitchItem` 的 `defaultVal` 参数或 `SelectDialog` 调用时的默认值。同时需修改 `SettingController.onInit()` 中对应的 `setting.get(..., defaultValue: xx)` 以保持一致。

#### 启用被注释的操作菜单设置
在 `style_setting.dart` 中取消注释 `ActionMenuSetPage` 的入口 `ListTile`，并确保 `/actionMenuSet` 路由已注册。

#### 添加"重启后生效"的 Switch
使用 `SetSwitchItem` 时传 `needReboot: true`，组件会自动弹出 "重启生效" Toast。

#### 自定义 Switch 样式
修改 `switch_item.dart` 中的 `Switch` 组件配置，包括 `thumbIcon`、`scale` 等属性。

#### 修改图片质量的步长
在 `style_setting.dart` 中修改 `Slider` 的 `min`、`max` 和 `divisions` 参数。当前为 10% ~ 100%，9 等分（步长 10%）。

#### 修改倍速删除的行为
在 `play_speed_set.dart` 中调整 `menuAction` 的 `id == -1` 分支，当前默认倍速不可删除。

#### 自定义宽屏布局下的设置页
各设置页面目前使用标准的 `ListView`，无需特殊处理宽屏。如需居中显示，参考 `MemberDynamicsPage` 的宽屏适配模式。

### 11.2 注意事项

- **Hive key 命名**：所有 key 均通过 `SettingBoxKey` / `VideoBoxKey` 常量引用，不要硬编码字符串
- **即时生效 vs 重启生效**：涉及导航结构（Tab、NavBar）的修改需要重启，UI 样式（主题、颜色、字体）通过 `Get.forceAppUpdate()` 即时生效
- **GlobalDataCache**：部分设置如 `imgQuality`、`actionTypeSort`、`enablePlayerControlAnimation` 在设置变更时同步到 `GlobalDataCache()` 单例，确保运行时的全局读取是最新值
- **登录态检查**：退出登录前会清除 `userInfoCache` 和本地 `accessKey`，确保不影响后续的未登录状态
- **Android 特定功能**：屏幕帧率设置（`flutter_displaymode`）和自动 PiP 仅在 Android 平台可用，通过 `Platform.isAndroid` 条件渲染
- **倍速系统预设**：`playSpeedSystem` 默认值来自 `lib/plugin/pl_player/index.dart` 中的 `playSpeed` 常量，修改此处可全局影响倍速选项