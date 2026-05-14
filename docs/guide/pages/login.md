---
date: 2026-05-14 22:54:02
title: login
permalink: /pages/55ea5c
categories:
  - guide
  - pages
---
# 登录模块（Login）

## 1. 模块概述

登录模块负责 PiliOtto 的用户身份认证，支持 **登录** 和 **注册** 两种模式，统一使用邮箱 + 密码的方式与 OttoHub 后端进行交互。注册模式下额外需要邮箱验证码。

模块文件结构：

```
lib/pages/login/
├── controller.dart            # LoginPageController - 表单状态、登录/注册逻辑、验证码倒计时
├── view.dart                  # LoginPage - 响应式登录/注册表单视图（含用户协议弹窗）
└── index.dart                 # 统一导出
```

### 核心功能

| 功能 | 说明 |
|------|------|
| 邮箱登录 | 输入邮箱 + 密码，调用 `AuthService.login` |
| 邮箱注册 | 输入邮箱 + 密码 + 验证码，调用 `AuthService.register` |
| 验证码发送 | 仅支持 QQ 邮箱，60 秒冷却 |
| 协议确认 | 需同时同意 OttoHub 和 PiliOtto 的用户协议与隐私政策 |
| 登录态同步 | 登录/注册成功后刷新 Mine、Home、Dynamics、Media 四个 Controller |

---

## 2. Controller 详解

`LoginPageController` 继承 `GetxController`，是登录页面的核心状态管理器。通过 `Get.put(LoginPageController(), tag: heroTag)` 以唯一 tag 注入，避免多实例冲突。

### 2.1 表单控制器与焦点节点

```dart
final GlobalKey<FormState> formKey = GlobalKey<FormState>();
final TextEditingController emailTextController = TextEditingController();
final TextEditingController passwordTextController = TextEditingController();
final TextEditingController verificationCodeController = TextEditingController();

final FocusNode emailTextFieldNode = FocusNode();
final FocusNode passwordTextFieldNode = FocusNode();
final FocusNode verificationCodeTextFieldNode = FocusNode();
```

三个 `TextEditingController` 分别管理邮箱、密码、验证码输入框，三个 `FocusNode` 用于控制键盘焦点。`formKey` 用于 Flutter `Form` 组件的全局校验。

### 2.2 响应式状态

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `passwordVisible` | `RxBool` | `true` | 密码可见性切换 |
| `isRegisterMode` | `RxBool` | `false` | 登录/注册模式切换 |
| `agreedToOttohub` | `RxBool` | `false` | 是否同意 OttoHub 协议 |
| `agreedToPiliotto` | `RxBool` | `false` | 是否同意 PiliOtto 协议 |
| `isLoading` | `RxBool` | `false` | 提交加载状态 |
| `seconds` | `RxInt` | `60` | 验证码倒计时秒数 |
| `smsCodeSendStatus` | `RxBool` | `false` | 验证码是否已发送（冷却中） |

### 2.3 核心方法

#### `toggleMode()` — 切换登录/注册模式

```dart
void toggleMode() {
  isRegisterMode.value = !isRegisterMode.value;
}
```

简单的布尔取反，视图层通过 `Obx` 响应式切换表单 UI。

#### `sendVerificationCode()` — 发送验证码

`controller.dart:L41-L62`

1. 校验邮箱格式（`GetUtils.isEmail`）
2. 校验邮箱必须为 QQ 邮箱（`endsWith('@qq.com')`）
3. 调用 `AuthService.sendRegisterVerificationCode(email:)`
4. 成功后启动 60 秒倒计时

#### `submit()` — 表单提交入口

`controller.dart:L64-L82`

1. `formKey.currentState!.validate()` 校验表单
2. 检查两项协议是否勾选
3. 根据 `isRegisterMode` 分发到 `_login()` 或 `_register()`

#### `_login()` — 登录逻辑

`controller.dart:L84-L112`

1. 调用 `AuthService.login(email:, password:)` 获取登录响应
2. 构造 `UserInfoData` 对象，存入 Hive 缓存 `GStrorage.userInfo`
3. 调用 `_refreshLoginStatus(true, avatarUrl)` 同步状态到各页面 Controller
4. 成功则 `Get.back()` 关闭登录页

#### `_register()` — 注册逻辑

`controller.dart:L114-L143`

流程与 `_login()` 类似，额外传入 `verificationCode` 参数调用 `AuthService.register`。

#### `_refreshLoginStatus()` — 跨页面状态同步

`controller.dart:L145-L167`

登录成功后，通过 `Get.find` 获取以下 Controller 并更新登录状态：

| Controller | 更新内容 |
|------------|----------|
| `MineController` | `userLogin`、`userInfo` |
| `HomeController` | `updateLoginStatus(status)`、`userFace` |
| `DynamicsController` | `userLogin` |
| `MediaController` | `userLogin` |

#### `startTimer()` — 验证码倒计时

`controller.dart:L169-L179`

使用 `Timer.periodic` 每秒递减 `seconds`，归零后重置为 60 并取消计时器，同时将 `smsCodeSendStatus` 设为 `false` 以启用发送按钮。

#### `dispose()` — 资源释放

`controller.dart:L182-L191`

取消 Timer，释放三个 TextEditingController 和三个 FocusNode。

---

## 3. View 详解

`LoginPage` 是 `StatefulWidget`，通过 `LayoutBuilder` 实现响应式宽窄屏布局。

### 3.1 响应式布局策略

```dart
body: LayoutBuilder(
  builder: (context, constraints) {
    bool isWideScreen = constraints.maxWidth > 800;
    if (isWideScreen) {
      return _buildWideScreenLayout(context, theme);
    } else {
      return _buildNarrowScreenLayout(context, theme);
    }
  },
),
```

以 `800px` 为断点：
- **宽屏**（≥800px）：左右分栏，左侧品牌展示区（3/5）+ 右侧表单区（2/5）
- **窄屏**（<800px）：全屏表单，带安全区域底部间距

### 3.2 表单字段

#### `_buildEmailField()` — 邮箱输入

`view.dart:L175-L199`

- `TextFormField`，`keyboardType: TextInputType.emailAddress`
- validator：非空 + 合法邮箱格式

#### `_buildPasswordField()` — 密码输入

`view.dart:L202-L233`

- `obscureText` 绑定 `passwordVisible`，通过 `suffixIcon` 按钮切换可见性
- validator：仅校验非空

#### `_buildVerificationCodeField()` — 验证码输入

`view.dart:L236-L282`

- 使用 `AnimatedSize` 包裹，仅在注册模式下显示
- 一行布局：`Expanded` 输入框 + 发送按钮
- 发送按钮在冷却期间显示倒计时（`${seconds}s`），禁用状态

### 3.3 协议确认区

`view.dart:L284-L377`

两组 Checkbox + 富文本链接，使用 `TapGestureRecognizer` 处理协议文本点击：

- OttoHub 用户协议 → `_showOttohubUserAgreement`
- OttoHub 隐私政策 → `_showOttohubPrivacyPolicy`
- PiliOtto 用户协议 → `_showPiliottoUserAgreement`
- PiliOtto 隐私政策 → `_showPiliottoPrivacyPolicy`

### 3.4 提交按钮与模式切换

- `_buildSubmitButton`：全宽按钮，loading 时显示 `CircularProgressIndicator`，按钮文字随模式变化（"登录"/"注册"）
- `_buildModeToggleButton`：居中文字按钮，"已有账号？去登录" / "没有账号？去注册"

### 3.5 协议弹窗

`_PolicyDialog` 是一个内部私有 `StatelessWidget`，接收 `title` 和 `content` 参数，以 `AlertDialog` + `SingleChildScrollView` 展示协议全文。

---

## 4. 数据流

```
用户输入
  │
  ▼
LoginPageController
  │
  ├── sendVerificationCode() ──► AuthService.sendRegisterVerificationCode()
  │
  └── submit()
        │
        ├── isRegisterMode? ──► AuthService.register()
        └── else ──► AuthService.login()
              │
              ▼
         构造 UserInfoData ──► Hive GStrorage.userInfo
              │
              ▼
         _refreshLoginStatus()
              │
              ├──► MineController.userLogin / userInfo
              ├──► HomeController.updateLoginStatus()
              ├──► DynamicsController.userLogin
              └──► MediaController.userLogin
              │
              ▼
         Get.back() 关闭登录页
```

---

## 5. 开发指南

### 5.1 添加新表单字段

1. 在 `LoginPageController` 中添加新的 `TextEditingController` 和 `FocusNode`
2. 在 `submit()` 方法中加入对应的校验逻辑
3. 在 `view.dart` 的 `_buildNarrowScreenLayout` 和 `_buildWideScreenLayout` 中插入对应的 `_buildXxxField` widget
4. 在 `dispose()` 中释放新增的资源

### 5.2 修改验证码邮箱限制

当前验证码仅限于 QQ 邮箱（`controller.dart:L47`）。如需支持其他邮箱：

```dart
// 移除或修改此条件
if (!emailTextController.text.trim().endsWith('@qq.com')) {
  SmartDialog.showToast('请使用QQ邮箱注册');
  return;
}
```

### 5.3 添加第三方登录

在 `LoginPageController` 中添加新的登录方法，例如：

```dart
Future _loginWithWeChat() async {
  // 调用第三方 SDK 获取授权码
  // 调用 AuthService 的对应方法
  // 复用 _refreshLoginStatus 同步状态
}
```

在 View 层添加对应的登录按钮。

---

## 6. 二改指南

### 6.1 自定义品牌展示区

宽屏模式下左侧品牌展示区代码位于 `view.dart:L61-L120` 的 `_buildWideScreenLayout` 第一个 `Expanded(flex: 3, ...)` 中。可替换其中的 `"Ottohub"` 文字和 slogan `"阐述你的梦"`。

### 6.2 修改协议内容

四份协议文本硬编码在 `view.dart` 的四个 `showDialog` 方法中（`_showOttohubUserAgreement`、`_showOttohubPrivacyPolicy`、`_showPiliottoUserAgreement`、`_showPiliottoPrivacyPolicy`）。直接修改 `_PolicyDialog` 的 `content` 字符串参数即可。

### 6.3 调整响应式断点

宽窄屏断点当前为 `800`，定义在 `view.dart:L49`：

```dart
bool isWideScreen = constraints.maxWidth > 800;
```

可修改此数值调整断点，或使用 `ResponsiveUtil` 统一管理。

### 6.4 自定义 UI 样式

- 密码可见性图标：修改 `_buildPasswordField` 中 `suffixIcon` 的 Icon
- 提交按钮颜色：修改 `_buildSubmitButton` 中 `TextButton.styleFrom` 的 `backgroundColor`
- 验证码倒计时文本：修改 `_buildVerificationCodeField` 中 Text 的显示逻辑