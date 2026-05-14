---
date: 2026-05-14 23:44:38
title: 开发入门
categories:
  - guide
---
# 开发入门

本指南帮助你快速搭建 PiliOtto 开发环境并运行项目。

## 环境要求

| 工具           | 版本要求                 |
| -------------- | ------------------------ |
| Flutter        | ≥ 3.41.6                 |
| Dart           | ≥ 3.11.4                 |
| Android Studio | 最新版（Android 开发）   |
| Xcode          | 最新版（iOS/macOS 开发） |
| Visual Studio  | 2022+（Windows 开发）    |

## 1. 克隆项目

```bash
git clone https://github.com/CyaniAgent/piliotto.git
cd piliotto
```

## 2. 安装依赖

```bash
flutter pub get
```

## 3. 运行项目

### Android / iOS

```bash
flutter run
```

### Windows

```bash
flutter run -d windows
```

### macOS

```bash
flutter run -d macos
```

### Linux

```bash
flutter run -d linux
```

## 4. 构建发布版

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

## 项目结构

```
lib/
├── main.dart           # 应用入口
├── common/             # 通用组件、混入、骨架屏
├── models/             # 数据模型
├── repositories/       # 仓储接口
├── services/           # 服务层
├── utils/              # 工具函数
├── router/             # 路由配置
├── ottohub/            # API 集成层
├── plugin/             # 自定义插件
└── pages/              # 页面模块
```

## 下一步

- [项目概览](/guide/) — 了解项目架构和技术栈
- [核心分层](/guide/core/models) — 深入理解各层设计
- [页面模块](/guide/pages/home) — 学习页面开发模式