---
date: 2026-05-14 22:45:48
title: about
permalink: /pages/about
categories:
  - guide
  - pages
---
# 关于模块（About）

## 1. 模块概述

关于模块负责展示应用基本信息与版本检查功能，页面简洁，用户可在此查看版本号、检查更新、跳转项目开源地址或反馈渠道。

模块采用 **单一文件架构**，Controller 与 View 合并在 `index.dart` 中，未拆分为独立子文件：

```
lib/pages/about/
└── index.dart    # AboutPage（StatefulWidget）+ AboutController（GetxController）
```

### 核心职责

| 职责 | 说明 |
|------|------|
| **版本展示** | 通过 `PackageInfoPlus` 获取本地版本号 |
| **更新检测** | 调用 GitHub API 获取最新 Release 版本，比较是否需要更新 |
| **导航跳转** | 通过 `url_launcher` 打开外部链接（GitHub 仓库、Release 页、Issues 页） |
| **日志查看** | 跳转到错误日志页面 `/logs` |

### 外部依赖

- [`package_info_plus`](https://pub.dev/packages/package_info_plus)：获取当前应用版本号
- [`url_launcher`](https://pub.dev/packages/url_launcher)：在外部浏览器打开链接
- [`dio`](https://pub.dev/packages/dio)：网络请求 GitHub API
- [`flutter_smart_dialog`](https://pub.dev/packages/flutter_smart_dialog)：Toast 提示

---

## 2. Controller 详解

`AboutController` 负责版本获取和外部跳转。

### 2.1 Rx 响应式状态

| 变量 | 类型 | 说明 |
|------|------|------|
| `currentVersion` | `RxString` | 当前本地版本号，来自 `PackageInfo.version` |
| `remoteVersion` | `RxString` | 远程最新版本号（GitHub Release 的 `tag_name`） |
| `isUpdate` | `RxBool` | 是否有新版本，由 `Utils.needUpdate()` 比较得出 |
| `isLoading` | `RxBool` | 网络请求状态，初始为 `true` |

### 2.2 非 Rx 属性

| 变量 | 类型 | 说明 |
|------|------|------|
| `remoteAppInfo` | `LatestDataModel` | 远程 Release 完整数据模型（含 `tagName`, `htmlUrl`, `assets` 等） |
| `data` | `LatestDataModel` | 同上，`getRemoteApp()` 请求成功后赋值 |

### 2.3 生命周期

**`onInit()`** — 初始化时并行触发两个异步任务：

```dart
void onInit() {
  super.onInit();
  getCurrentApp();  // 获取本地版本
  getRemoteApp();   // 获取远程版本
}
```

两个方法互不依赖，可在 `onInit` 中同时启动。

### 2.4 核心方法

**`getCurrentApp()`** — 获取本地版本

```dart
Future getCurrentApp() async {
  var result = await PackageInfo.fromPlatform();
  currentVersion.value = result.version;
}
```

通过 `PackageInfo.fromPlatform()` 取得 `version` 字段（对应 `pubspec.yaml` 中的 `version`）。

**`getRemoteApp()`** — 获取远程最新 Release

```dart
Future getRemoteApp() async {
  var result = await dio.get(
    'https://api.github.com/repos/CyaniAgent/piliotto/releases/latest');
  isLoading.value = false;
  data = LatestDataModel.fromJson(result.data);
  remoteVersion.value = data.tagName ?? '';
  if (remoteVersion.value.isNotEmpty) {
    isUpdate.value = Utils.needUpdate(currentVersion.value, remoteVersion.value);
  }
}
```

- 请求 GitHub REST API 的 `/repos/{owner}/{repo}/releases/latest` 端点
- 解析为 `LatestDataModel`
- 调用 `Utils.needUpdate()` 比较版本字符串
- 请求结束时 `isLoading` 置为 `false`

**`onUpdate()`** — 触发更新下载

```dart
Future onUpdate() async {
  Utils.matchVersion(data);
}
```

代理到 `Utils.matchVersion()`，根据 Release 的 `assets` 列表匹配适合当前平台的安装包并跳转下载。

**导航方法**

| 方法 | 目标 URL | 说明 |
|------|---------|------|
| `githubUrl()` | `https://github.com/CyaniAgent/piliotto` | 打开项目开源地址 |
| `githubRelease()` | `https://github.com/CyaniAgent/piliotto/releases` | 打开 Release 下载页 |
| `feedback()` | `https://github.com/CyaniAgent/piliotto/issues` | 打开 Issues 反馈页 |
| `logs()` | `/logs` | GetX 路由跳转到错误日志页 |

所有外部链接均使用 `LaunchMode.externalApplication` 在外部浏览器中打开。

---

## 3. View 详解

`AboutPage` 是 `StatefulWidget`，在 `_AboutPageState` 中通过 `Get.put(AboutController())` 注册 Controller。

### 3.1 组件树

```
AboutPage (StatefulWidget)
└── Scaffold
    └── SingleChildScrollView
        └── Column
            ├── Image.asset('assets/images/logo/logo.png')  // 应用 Logo，150px 宽
            ├── Text('PiliOtto')                            // 应用名称
            ├── Obx → Badge + FilledButton.tonal            // 版本号按钮（带更新标记）
            ├── ListTile → TextButton('开源地址')               // GitHub 地址
            ├── ListTile → IconButton('问题反馈')               // Issues 页
            └── ListTile → IconButton('错误日志')               // 日志页
```

### 3.2 版本号按钮

```dart
Badge(
  isLabelVisible: _aboutController.isLoading.value
      ? false
      : _aboutController.isUpdate.value,
  label: const Text('New'),
  child: FilledButton.tonal(
    onPressed: () {
      showModalBottomSheet(...)  // 弹出底部面板
    },
    child: Text('V${_aboutController.currentVersion.value}'),
  ),
)
```

- **加载中**：`isLoading` 为 `true` 时，始终隐藏 Badge 标签
- **有更新**：`isUpdate` 为 `true` 且加载完成后，显示 `New` 标签
- **点击行为**：弹出底部面板（`showModalBottomSheet`），提供 `Github下载` 选项

### 3.3 底部面板

```dart
showModalBottomSheet(
  context: context,
  builder: (context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      ListTile(
        onTap: () => _aboutController.githubRelease(),
        title: const Text('Github下载'),
      ),
      SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
    ],
  ),
);
```

仅含一个选项：「Github下载」，点击打开 Release 页面。

### 3.4 列表项交互

- **开源地址**：点击调用 `githubUrl()`，trailing 显示仓库路径
- **问题反馈**：点击调用 `feedback()`
- **错误日志**：点击调用 `logs()` → 路由到 `/logs`

所有列表项的 trailing 使用 `Icons.arrow_forward_ios`（16px）统一风格。

---

## 4. 数据流

```
页面初始化
  → _AboutPageState.initState()
    → Get.put(AboutController())
      → AboutController.onInit()
        ├── getCurrentApp()
        │     └── PackageInfo.fromPlatform()
        │           └── currentVersion.value = result.version
        └── getRemoteApp()
              └── Dio.get(github_api_releases_latest)
                    ├── 成功 → LatestDataModel.fromJson()
                    │       ├── remoteVersion.value = tagName
                    │       ├── isUpdate.value = needUpdate(local, remote)
                    │       └── isLoading.value = false
                    └── 失败 → SmartDialog.showToast()
                            └── isLoading.value = false

用户点击版本按钮
  → showModalBottomSheet
    → 用户选择「Github下载」
      → githubRelease()
        → launchUrl(releases_page, LaunchMode.externalApplication)
```

---

## 5. 开发指南

### 5.1 获取远程数据的时机

`getRemoteApp()` 在 `onInit` 中直接调用，页面打开即开始请求。如需推迟到用户交互时再请求（减少 API 请求频率），可改为在 `Badge` 组件的 `onPressed` 中调用。

### 5.2 版本号更新失败处理

`getRemoteApp()` 的 `try-catch` 会捕获网络错误，通过 `SmartDialog.showToast` 提示用户。当前不重试，如需自动重试可添加 `RetryPolicy` 或利用 Dio 的拦截器。

---

## 6. 二改指南

### 6.1 更换 Logo

修改 `index.dart` 中的 `Image.asset` 路径：

```dart
Image.asset('assets/images/logo/your_logo.png', width: 150),
```

### 6.2 添加更多下载渠道

在底部面板中追加 `ListTile`：

```dart
ListTile(
  onTap: () => launchUrl(Uri.parse('https://your_cdn.com/download.apk')),
  title: const Text('CDN下载'),
),
```

### 6.3 修改更新源

`getRemoteApp()` 中的 API URL 是硬编码的。如需更换为自建 API：

```dart
var result = await dio.get('https://your-server.com/api/latest-version');
```

### 6.4 添加许可信息展示

在 `Column` 末尾追加 `ListTile`：

```dart
ListTile(
  onTap: () => showLicensePage(context: context),
  title: const Text('开源许可'),
  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: outline),
),
```

### 6.5 注意事项

1. **API 请求频率**：GitHub API 对匿名请求有频率限制（60次/小时），频繁打开关于页可能触发限制
2. **版本比较逻辑**：`Utils.needUpdate()` 的实现决定了版本比较的语义，修改版本号格式时需同步更新该工具方法
3. **外部浏览器**：所有链接使用 `LaunchMode.externalApplication`，确保不会在应用内 WebView 打开