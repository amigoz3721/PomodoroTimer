# PomodoroTimer - AI 协作说明

## 项目简介

PomodoroTimer 是一款 macOS 菜单栏番茄钟应用，使用 Swift、SwiftUI 和 AppKit 开发。

## 协作原则

- 优先使用中文沟通。
- 修改前先阅读当前目录结构和相关 Swift 文件。
- 不随意引入第三方依赖。
- 不删除用户文件、不重置 Git 历史，除非用户明确要求。
- 功能代码修改后，优先使用 Xcode 或 `xcodebuild` 验证。

## 常用路径

- App 入口：`PomodoroTimer/PomodoroTimerApp.swift`
- ViewModel：`PomodoroTimer/ViewModels/PomodoroViewModel.swift`
- 通知服务：`PomodoroTimer/Services/NotificationManager.swift`
- 统计服务：`PomodoroTimer/Services/StatisticsStore.swift`
- 设置界面：`PomodoroTimer/Views/SettingsView.swift`
- 本地化资源：`PomodoroTimer/Resources/`

## 验证命令

```bash
xcodebuild -list -project PomodoroTimer.xcodeproj
xcodebuild -project PomodoroTimer.xcodeproj -scheme PomodoroTimer build
```

如果命令行构建因本机权限或 Xcode 模拟器服务失败，说明具体错误，并建议用户在 Xcode 中手动运行。
