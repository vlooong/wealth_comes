# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

财富累积器是一个 Flutter 应用，帮助用户直观地看到工资如何随时间累计增长。该应用使用 Material 3 设计，支持深色模式，并包含 Android 桌面小组件功能。

## 常用命令

### 开发环境
```bash
# 安装依赖
flutter pub get

# 运行应用（开发模式）
flutter run

# 运行应用（发布模式）
flutter run --release

# 构建 APK
flutter build apk --release

# 构建 App Bundle（推荐用于 Google Play）
flutter build appbundle --release

# 运行测试
flutter test

# 代码格式化
flutter format .

# 代码分析
flutter analyze
```

### 特定平台构建
```bash
# iOS 构建（仅限 macOS）
flutter build ios --release

# Windows 桌面应用
flutter build windows --release

# Linux 桌面应用
flutter build linux --release

# macOS 桌面应用
flutter build macos --release
```

## 项目架构

### 技术栈
- **框架**: Flutter 3.10+
- **状态管理**: Provider (ChangeNotifier)
- **数据持久化**: SharedPreferences
- **图表库**: fl_chart
- **字体**: Google Fonts (Noto Sans)
- **本地通知**: flutter_local_notifications
- **后台任务**: workmanager

### 核心架构模式

该应用采用 MVVM 架构模式：

1. **Model 层** (`lib/models/`)
   - `salary_model.dart`: 薪资数据模型和计算模式枚举
   - `app_settings.dart`: 应用设置模型

2. **Service 层** (`lib/services/`)
   - `salary_service.dart`: 核心业务逻辑，管理薪资计算和状态
   - `app_provider.dart`: Provider 包装器，提供依赖注入
   - `android_widget_service.dart`: Android 桌面小组件通信服务

3. **Utils 层** (`lib/utils/`)
   - `salary_calculator.dart`: 薪资计算的核心算法

4. **View 层**
   - `lib/screens/`: 页面组件
   - `lib/widgets/`: 可复用 UI 组件

### 核心数据流

1. **SalaryService**: 核心状态管理器，负责：
   - 薪资计算的定时器管理
   - SharedPreferences 数据持久化
   - Android 桌面小组件数据更新
   - 实时薪资累计计算

2. **计算模式**: 支持三种薪资计算模式
   - `fullYear`: 全年 365 天不间断计算
   - `workDaysOnly`: 仅工作日计算（周一至周五）
   - `workHoursOnly`: 仅工作时段计算（可自定义时间）

3. **数据持久化策略**: 使用 SharedPreferences 将整个 SalaryModel 序列化为 JSON 存储

## 关键特性

### 实时计算
- 使用 Timer.periodic 实现薪资的实时累计更新
- 可配置更新频率（秒级）
- 支持 0-6 位小数点显示

### Android 桌面小组件
- 原生 Android Widget 实现
- 通过 SharedPreferences 与 Flutter 应用通信
- 显示今日累计薪资和进度
- 每分钟自动更新

### Material 3 设计
- 完整的浅色/深色主题支持
- 使用 ColorScheme.fromSeed 生成配色
- 统一的卡片样式和圆角设计
- Google Fonts (Noto Sans) 字体

## 开发注意事项

### 代码风格
- 使用 flutter_lints 规范代码风格
- 遵循 Material 3 设计指南
- 所有代码注释使用简体中文

### 状态管理
- 所有状态变更必须通过 SalaryService
- 使用 notifyListeners() 通知 UI 更新
- 避免在 Widget 中直接修改状态

### 错误处理
- SharedPreferences 操作包含 try-catch 块
- 使用 print() 输出错误信息（调试阶段）

### 平台特定代码
- Android 小组件代码位于 `android/app/src/main/`
- 主要文件：WealthWidgetProvider.java 和相关布局文件

## 数据模型说明

### SalaryModel
```dart
class SalaryModel {
  final double annualSalary;           // 年薪
  final double updateFrequency;        // 更新频率（秒）
  final int decimalPlaces;            // 小数位数
  final String currencySymbol;        // 货币符号
  final SalaryCalculationMode calculationMode;  // 计算模式
  final TimeRange workHours;          // 工作时间范围
}
```

### 计算逻辑
- 基于年薪和时间比例计算累计薪资
- 支持不同计算模式的工作时间换算
- 提供周期内薪资计算和进度百分比

## 调试技巧

### 查看实时数据
- 使用 `flutter run --debug` 启动应用
- 在 SalaryService 中添加 print 语句查看计算过程

### SharedPreferences 调试
- 数据保存在 `salaryModel` 键下
- Android 数据路径：`/data/data/com.example.wealth_comes/shared_prefs`

### Widget 调试
- Widget 数据通过多个键值对存储（today_salary, week_salary 等）
- 可通过 Android Studio 的 Device File Explorer 查看