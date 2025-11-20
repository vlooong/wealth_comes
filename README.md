# 财富累积器 (Wealth Comes)

财富累积器 - 一个帮助用户直观看到工资如何随时间累计增长的应用

## ✨ 功能特性

### 核心功能
- **工资设置**: 按月薪或年薪设置工资
- **自定义配置**: 可设置更新频率、小数点位数、货币符号（¥、$、€、£、₹、元）
- **计算模式**: 
  - 全年全天：365天24小时不间断计算
  - 仅工作日：仅在周一至周五计算
  - 仅工作时段：仅在周一至周五的指定工作时间计算
- **多种视图**: 可切换查看年、月、周、日周期内累计的工资
- **进度显示**: 显示当日/当周/当月/当年的累计进度百分比
- **桌面小组件**: Android桌面小组件，可在手机桌面直接查看工资累计情况

### 🎨 UI/UX 增强
- **Material 3 设计**: 现代化界面设计
- **深色模式**: 自动跟随系统主题
- **流畅动画**: 数字滚动、进度条、卡片入场动画
- **图表可视化**: 收入趋势折线图（使用 fl_chart）
- **渐变卡片**: 彩色渐变背景和图标
- **Google Fonts**: 使用 Noto Sans 字体

### 💾 数据功能
- **数据持久化**: 使用 SharedPreferences 保存所有设置
- **即时更新**: 实时计算和显示薪资累积

## 📱 安装与使用

### Flutter应用部分
```bash
# 克隆项目
git clone <repository-url>

# 安装依赖
flutter pub get

# 运行应用
flutter run

# 构建 APK
flutter build apk --release
```

### Android桌面小组件
1. 编译并安装应用到Android设备
2. 在手机桌面长按空白处
3. 选择 "小组件" 或 "Widgets"
4. 找到 "财富累积器" 小组件
5. 拖拽到桌面即可

小组件功能：
- 显示今日累计薪资
- 显示今日进度条
- 显示当前年度总额
- 每分钟自动更新
- 点击打开主应用

## 🎯 配置说明

在应用中可配置以下参数：
- **年薪数额**: 设置您的年度薪资
- **更新频率**: 薪资数字的更新间隔（秒）
- **小数位数**: 显示的小数点位数（0-6）
- **货币符号**: 选择货币单位
- **计算模式**: 选择全年/工作日/工作时段模式
- **工作时段**: 当选择"仅工作时段"模式时，可自定义工作时间

## 🏗️ 技术架构

### 技术栈
- **框架**: Flutter 3.10+
- **状态管理**: Provider
- **数据持久化**: Shared Preferences
- **图表库**: fl_chart
- **字体**: Google Fonts
- **桌面小组件**: 原生 Android Widget + Flutter 数据通信

### 项目结构
```
lib/
├── models/         # 数据模型
│   ├── salary_model.dart
│   └── app_settings.dart
├── services/       # 业务逻辑服务
│   ├── salary_service.dart
│   ├── app_provider.dart
│   └── android_widget_service.dart
├── utils/          # 工具类
│   └── salary_calculator.dart
├── widgets/        # 可复用UI组件
│   ├── salary_stats_widget.dart
│   ├── progress_widget.dart
│   └── salary_chart_widget.dart
└── screens/        # 页面
    ├── home_screen.dart
    └── settings_screen.dart

android/
└── app/src/main/
    ├── java/com/example/wealth_comes/
    │   └── WealthWidgetProvider.java
    └── res/
        ├── layout/wealth_widget.xml
        ├── drawable/  # Widget 图标和背景
        └── xml/wealth_widget_info.xml
```

## 📦 依赖包

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.2               # 状态管理
  shared_preferences: ^2.2.2     # 数据持久化
  flutter_local_notifications: ^17.2.2  # 本地通知
  workmanager: ^0.5.1            # 后台任务
  fl_chart: ^0.68.0              # 图表库
  google_fonts: ^6.1.0           # 字体
  intl: ^0.19.0                  # 国际化
  path_provider: ^2.1.1          # 文件路径
  share_plus: ^7.2.2             # 分享功能
```

## 🎨 界面预览

### 主界面
- 顶部：周期选择按钮（年/月/周/日）
- 中部：当前周期累计薪资卡片（带图标和动画）
- 中下：当前总额卡片
- 底部：进度指示器（带动画进度条）

### 设置界面
- **薪资信息卡片**: 年薪设置
- **显示设置卡片**: 更新频率、小数位数、货币符号
- **计算模式卡片**: 三种模式选择 + 工作时段设置
- 每个卡片都有彩色图标和边框

## 🚀 最新更新

### v0.2.0 (2025-11-20)
- ✅ 实现完整的数据持久化
- ✅ 升级到 Material 3 设计
- ✅ 添加深色模式支持
- ✅ 增强所有 Widget 动画效果
- ✅ 重新设计设置界面
- ✅ 添加收入趋势图表（待集成）
- ✅ 实现原生 Android Widget
- ✅ 使用 Google Fonts

### 已知问题
- `withOpacity` 方法有弃用警告（不影响功能）
- 建议未来升级到 Flutter 3.25+ 后使用 `withValues()`

## 🔮 未来计划

- [ ] 多语言支持（中文/英文）
- [ ] 历史数据记录和查看
- [ ] 月度/年度统计分析
- [ ] 储蓄目标设置和跟踪
- [ ] 每日收入通知提醒
- [ ] 分享功能（截图分享）
- [ ] iOS Widget 支持

## 📖 开发

如需贡献代码：
1. Fork 仓库
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 发起 Pull Request

## 📄 许可证

MIT License

## 🙏 致谢

- [Flutter](https://flutter.dev) - UI 框架
- [fl_chart](https://pub.dev/packages/fl_chart) - 图表库
- [Google Fonts](https://pub.dev/packages/google_fonts) - 字体支持
- [Provider](https://pub.dev/packages/provider) - 状态管理

---

**注意**: 本应用仅用于学习和个人使用。薪资计算仅供参考，不代表实际收入。