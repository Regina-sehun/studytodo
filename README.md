# StudyTodo

iPhone 主页小组件待办清单（个人学习进度管理）。

## 现状

**P0：整条生产链冒烟测试** —— App + 小组件安装、数据互通（App Group）、实时倒计时、通知权限、AlarmKit 可用性。

## 生产方式（无需 Mac）

- 源码在 GitHub，push 后 GitHub Actions 用云端 macOS 自动编译
- 产物：Actions 页面下载 `StudyTodo-ipa` → 解压得 `StudyTodo.ipa`
- 安装：AltStore（Windows 版 AltServer）用免费 Apple ID 签名侧载，详见 [docs/P0-安装指南.md](docs/P0-安装指南.md)

## 本地开发

本机为 Windows，不本地编译；Xcode 工程由 XcodeGen 从 `project.yml` 生成（`StudyTodo.xcodeproj` 不入库）。

## 目录

```
StudyTodo/          App 源码（SwiftUI）
Widget/             小组件扩展源码（WidgetKit）
Shared/             App 与小组件共享代码（App Group 存储）
project.yml         XcodeGen 工程描述
.github/workflows/  云构建流水线
docs/               安装与使用文档
```
