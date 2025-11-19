# 财富累积器 (Wealth Comes)

财富累积器 - 一个帮助用户直观看到工资如何随时间累计增长的应用

## 功能特性

- **工资设置**: 按月薪或年薪设置工资
- **自定义配置**: 可设置更新频率、小数点位数、货币符号（¥、$、€、£、₹、元）
- **计算模式**: 
  - 全年全天：365天24小时不间断计算
  - 仅工作日：仅在周一至周五计算
  - 仅工作时段：仅在周一至周五的指定工作时间计算
- **多种视图**: 可切换查看年、月、日周期内累计的工资
- **进度显示**: 显示当日/当周/当月/当年的累计进度百分比
- **桌面小组件**: Android桌面小组件，可在手机桌面直接查看工资累计情况

## 安装与使用

### Flutter应用部分
1. 克隆项目
2. 运行 `flutter pub get`
3. 运行 `flutter run` 启动应用

### Android桌面小组件部分
要在Android设备上使用桌面小组件，请按照以下步骤操作：

1. 编译并安装应用到Android设备：
   ```
   flutter build apk
   adb install build/app/outputs/flutter-apk/app-release.apk
   ```

2. 在Android原生代码中实现小组件：
   - 参见 `android_widget_implementation.md` 中的详细说明
   - 需要在 `android/app/src/main/res/layout/` 目录下创建小组件布局文件
   - 实现 `SalaryWidgetProvider` 服务
   - 配置 `AndroidManifest.xml` 以注册小组件
   - 设置定期更新以保持小组件数据同步

3. 在手机桌面添加小组件：
   - 长按手机桌面空白处
   - 选择 "小组件" 或 "Widgets"
   - 找到 "财富累积器" 小组件
   - 拖拽到桌面即可

## 配置说明

在应用中可配置以下参数：
- 年薪数额
- 更新频率（秒）
- 小数位数
- 货币符号
- 计算模式（全年/工作日/工作时段）
- 工作时段（当选择"仅工作时段"模式时）

## 技术架构

- **框架**: Flutter
- **状态管理**: Provider
- **数据持久化**: Shared Preferences
- **桌面小组件**: 原生Android组件配合Flutter数据通信

## 项目结构

```
lib/
├── models/         # 数据模型
├── services/       # 业务逻辑服务
├── utils/          # 工具类
├── widgets/        # 可复用UI组件
└── screens/        # 页面
```

## 开发

如需贡献代码：
1. Fork 仓库
2. 创建功能分支
3. 提交更改
4. 发起 Pull Request

## 许可证

MIT