---
date: 2026-05-14 22:45:48
title: webview
permalink: /pages/webview
categories:
  - guide
  - pages
---
# WebView 模块（Webview）

## 1. 模块概述

WebView 模块提供一个内嵌浏览器页面，用于展示任意 Web 内容。它同时承担 **登录** 功能——当 `type` 参数为 `login` 时，会清除所有缓存和 Cookie，并在用户完成登录后通过 `LoginUtils.confirmLogin` 提取登录凭证。

模块采用 **Controller-View 分离** + **GetX 响应式状态管理** 的架构：

```
lib/pages/webview/
├── controller.dart    # WebviewController - WebView 初始化与导航控制
├── view.dart          # WebviewPage - 页面视图（含 AppBar + 进度条 + WebView）
└── index.dart         # 统一导出
```

### 核心职责

| 职责 | 说明 |
|------|------|
| **Web 内容展示** | 使用 `webview_flutter` 加载指定 URL |
| **导航控制** | AppBar 提供刷新、外部浏览器打开按钮 |
| **登录流程** | 清除缓存、监听 URL 变化、提取登录凭证 |
| **进度指示** | 线性进度条展示页面加载进度 |
| **深度链接处理** | 拦截 `ottohub://` 协议，跳转到视频详情页 |

---

## 2. Controller 详解

`WebviewController` 管理 WebView 的生命周期与交互。

### 2.1 路由参数

在 `onInit()` 中从 GetX 路由参数提取三个必填参数：

| 参数 | 类型 | 说明 |
|------|------|------|
| `url` | `String` | 目标加载地址，自动补全 `https://` 前缀 |
| `type` | `RxString` | 页面类型：`'login'` 标识登录页，影响缓存清除和 UI 行为 |
| `pageTitle` | `String` | AppBar 标题文字 |

### 2.2 Rx 响应式状态

| 变量 | 类型 | 说明 |
|------|------|------|
| `type` | `RxString` | 页面类型（obs），View 层通过 `Obx` 监听 |
| `loadProgress` | `RxInt` | 页面加载进度（0-100），驱动进度条 |
| `loadShow` | `RxBool` | 是否显示进度条，URL 变化后隐藏 |

### 2.3 非 Rx 属性

| 变量 | 类型 | 说明 |
|------|------|------|
| `controller` | `WebViewController` | `webview_flutter` 原生控制器 |
| `eventBus` | `EventBus` | 事件总线实例（当前未使用，预留扩展） |

### 2.4 onInit 逻辑

```dart
void onInit() {
  super.onInit();
  url = Get.parameters['url']!;
  type.value = Get.parameters['type']!;
  pageTitle = Get.parameters['pageTitle']!;

  if (type.value == 'login') {
    controller.clearCache();           // 清除 WebView 缓存
    controller.clearLocalStorage();    // 清除 localStorage
    WebViewCookieManager().clearCookies();  // 清除所有 Cookie
  }

  webviewInit();
}
```

登录模式下会在 `webviewInit()` **之前** 执行三重清除，确保用户以干净状态重新登录。

### 2.5 webviewInit() — 核心初始化

```dart
void webviewInit() {
  controller
    ..setUserAgent(
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) ... Chrome/120.0.0.0 Safari/537.36')
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setNavigationDelegate(NavigationDelegate(...))
    ..loadRequest(Uri.parse(url.startsWith('http') ? url : 'https://$url'));
}
```

| 配置项 | 值 | 说明 |
|------|-----|------|
| UserAgent | Chrome 120 / Windows 10 | 伪装桌面端，避免移动端页面限制 |
| JavaScript | `unrestricted` | 允许执行 JS，登录需要 |
| URL 兜底 | `https://` 前缀 | 若传入的 url 不以 `http` 开头，自动补全 |

### 2.6 NavigationDelegate 回调

| 回调 | 行为 |
|------|------|
| `onProgress` | 更新 `loadProgress.value`，驱动进度条 |
| `onPageStarted` | 无操作（空实现） |
| `onUrlChange` | `loadShow.value = false`，隐藏进度条 |
| `onWebResourceError` | 无操作（空实现，可在此添加错误提示） |
| `onNavigationRequest` | 拦截 `ottohub://` 协议，否则放行 |

### 2.7 深度链接拦截

```dart
onNavigationRequest: (NavigationRequest request) {
  if (request.url.startsWith('ottohub://')) {
    if (request.url.startsWith('ottohub://video/')) {
      final uri = Uri.parse(request.url);
      if (uri.pathSegments.isNotEmpty) {
        final vid = int.tryParse(uri.pathSegments[0]);
        if (vid != null) {
          Get.offAndToNamed('/video?vid=$vid', arguments: {
            'pic': '',
            'heroTag': 'video_$vid',
          });
        }
      }
    }
    return NavigationDecision.prevent;  // 阻止 WebView 导航
  }
  return NavigationDecision.navigate;   // 放行正常 HTTP 请求
}
```

- 拦截 `ottohub://` 自定义协议
- 解析 `ottohub://video/{vid}` 格式，跳转到视频详情页
- `Get.offAndToNamed` 会替换当前路由栈（登录后不再返回 WebView 页）

---

## 3. View 详解

`WebviewPage` 是页面主视图。

### 3.1 组件树

```
WebviewPage (StatefulWidget)
└── Scaffold
    ├── AppBar
    │   ├── Text(pageTitle)                       // 居中标题
    │   ├── Row: IconButton [刷新]                   // controller.reload()
    │   ├── Row: IconButton [外部浏览器]               // launchUrl(url)
    │   └── Row: Obx → type=='login' ? TextButton [刷新登录状态] : SizedBox
    └── Column
        ├── Obx → AnimatedContainer (进度条)         // loadShow ? 4px : 0px
        ├── type=='login' ? 提示横幅 : null           // 「登录成功未自动跳转?」
        └── Expanded → WebViewWidget(controller)    // 核心 WebView
```

### 3.2 AppBar 操作按钮

| 按钮 | 图标 | 行为 |
|------|------|------|
| 刷新 | `Icons.refresh_outlined` | `controller.reload()` |
| 外部浏览器 | `Icons.open_in_browser_outlined` | `launchUrl(url)` 在外部浏览器打开 |
| 刷新登录状态（仅登录模式） | 文字按钮 | `LoginUtils.confirmLogin(null, controller)` |

### 3.3 进度条

```dart
Obx(
  () => AnimatedContainer(
    curve: Curves.easeInOut,
    duration: const Duration(milliseconds: 350),
    height: _webviewController.loadShow.value ? 4 : 0,
    child: LinearProgressIndicator(
      key: ValueKey(_webviewController.loadProgress),
      value: _webviewController.loadProgress / 100,
    ),
  ),
)
```

- 使用 `AnimatedContainer` 实现平滑的高度过渡（4px ↔ 0px）
- `ValueKey` 保证 progress 变化时 indicator 正确重建动画
- URL 变化时 `loadShow` 变为 `false`，进度条收起

### 3.4 登录提示横幅

仅在 `type == 'login'` 时显示：

```dart
Container(
  color: Theme.of(context).colorScheme.onInverseSurface,
  child: const Text('登录成功未自动跳转?  请点击右上角「刷新登录状态」'),
)
```

---

## 4. 数据流

```
Get.toNamed('/webview?url=xxx&type=login&pageTitle=登录')
  → WebviewController.onInit()
    ├── 提取路由参数 (url, type, pageTitle)
    ├── type=='login' → 三重清除 (Cache + localStorage + Cookie)
    └── webviewInit()
        ├── setUserAgent(Chrome 120 Desktop)
        ├── setJavaScriptMode(unrestricted)
        ├── setNavigationDelegate
        └── loadRequest(url)

页面加载过程:
  → onProgress(int) → loadProgress.value 更新 → 进度条动画
  → onUrlChange → loadShow.value = false → 进度条隐藏

用户完成登录:
  → 点击「刷新登录状态」→ LoginUtils.confirmLogin()
    → 从 WebView 中提取 Cookie/Token
    → 写入 Hive 缓存
    → 路由返回

深度链接拦截:
  → ottohub://video/12345
    → onNavigationRequest 拦截
    → Get.offAndToNamed('/video?vid=12345')
    → 替换路由栈
```

---

## 5. 开发指南

### 5.1 新增 WebView 页面类型

在调用 `Get.toNamed` 时传入新的 `type` 值，并在 `view.dart` 中通过 `Obx` 监听 `type` 来切换 UI：

```dart
Obx(
  () => _webviewController.type.value == 'custom_type'
      ? CustomBanner()
      : const SizedBox(),
),
```

### 5.2 处理更多深度链接

在 `onNavigationRequest` 中扩展拦截规则：

```dart
if (request.url.startsWith('ottohub://user/')) {
  final uri = Uri.parse(request.url);
  final uid = int.tryParse(uri.pathSegments[0]);
  if (uid != null) {
    Get.toNamed('/member?mid=$uid');
  }
  return NavigationDecision.prevent;
}
```

---

## 6. 二改指南

### 6.1 替换 UserAgent

修改 `controller.dart` 中的 UA 字符串：

```dart
controller.setUserAgent('Mozilla/5.0 ... Your_New_UA');
```

### 6.2 添加错误页面

在 `onWebResourceError` 回调中设置错误状态：

```dart
onWebResourceError: (WebResourceError error) {
  errorOccurred.value = true;
  errorMessage.value = error.description;
},
```

### 6.3 添加 JavaScript 通道

如需与 Web 页面双向通信，添加 `JavaScriptChannel`：

```dart
controller.addJavaScriptChannel(
  'PiliOtto',
  onMessageReceived: (JavaScriptMessage message) {
    // 处理来自 Web 页面的消息
  },
);
```

### 6.4 注意事项

1. **Cookie 清除时机**：登录模式下的 Cookie 清除在 `onInit` 中执行，确保在任何 WebView 操作之前完成
2. **路由替换**：深度链接使用 `Get.offAndToNamed` 替换路由栈，避免用户返回到已完成登录的 WebView 页
3. **UserAgent 伪装**：桌面端 UA 可能导致部分移动页面显示异常，如需加载移动页面请更换为移动端 UA
4. **HTTPS 补全**：`loadRequest` 中自动补全 `https://` 前缀，确保 localhost 场景不受影响