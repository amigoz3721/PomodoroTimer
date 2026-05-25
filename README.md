# PomodoroTimer

一个简洁的 macOS 菜单栏番茄钟应用，使用 Swift 和 SwiftUI 开发。项目目标是提供轻量、安静、常驻菜单栏的专注计时体验。

## 功能特性

- 菜单栏常驻计时显示
- 专注、短休息、长休息三种模式
- 可自定义专注和休息时长
- 完成后系统通知、提示音和应用内提醒
- 今日和本周专注统计
- 中英文界面切换
- 主题色和明暗模式设置

## 技术栈

- Swift
- SwiftUI
- AppKit
- UserNotifications
- Xcode

## 项目结构

```text
PomodoroTimer/
├── Models/        # 番茄钟模式、状态和记录模型
├── Services/      # 通知、统计、主题、语言和窗口服务
├── ViewModels/    # 计时状态和业务逻辑
├── Views/         # SwiftUI 界面
└── Resources/     # 图标和本地化资源
```

## 运行方式

1. 使用 Xcode 打开 `PomodoroTimer.xcodeproj`
2. 选择 `PomodoroTimer` scheme
3. 点击 Run 构建并运行

也可以在终端中检查项目：

```bash
xcodebuild -list -project PomodoroTimer.xcodeproj
```

## 后续计划

- 增加电脑睡眠后的时间校准
- 支持应用重启后恢复计时状态
- 增加更完整的统计图表
- 补充应用截图和 DMG 发布说明

## 开发说明

这是一个 AI 辅助开发练习项目，重点用于学习 macOS 应用结构、SwiftUI 状态管理、菜单栏应用交互和小工具发布流程。
