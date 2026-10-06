# ForgeLoop Version Management Integration

## 1. Purpose

本 Rule 定义 ForgeLoop 如何接入全局 Version Management。

本 Rule 不替代全局 Version Management。

---

## 2. Authority

版本管理的最终权威：

```text
Global Version Management
```

ForgeLoop 服从全局版本规则。

---

## 3. Version Layers

ForgeLoop 至少存在以下可能的版本层：

```text
Design Version
Project Version
Package Version
Skill Version
Release Version
```

不同层级的版本互不自动继承。

---

## 4. Design Version

设计文档：

```text
ForgeLoop.DESIGN.md
```

当前版本：

```text
1.0.0
```

这是：

```text
Design Version
```

不得自动作为 Project Version。

---

## 5. Project Version

ForgeLoop Project Version：

```text
由 Global Version Management 决定
```

Claude Code 必须从全局规则和项目实际版本源确定：

```text
Current Project Version
```

不得仅根据 Design Version 推导。

---

## 6. Version Source of Truth

项目中真正作为版本源的数据必须依据全局规则确定。

可能存在：

```text
package manifest
project metadata
runtime metadata
release metadata
```

具体位置不能在 ForgeLoop Rule 中提前假定。

---

## 7. Version Change

产生版本变化时：

```text
Read Global Rules
↓
Classify Change
↓
Determine Required Version
↓
Apply Version Change
↓
Verify All Version Sources
```

---

## 8. Consistency

如果 ForgeLoop 存在多个版本声明：

```text
必须按照全局规则保持一致
```

不能自行选择其中一个作为权威。

---

## 9. Release

Release 前必须确认：

```text
Project Version Valid
+
Required Metadata Valid
+
Required Changelog Valid
+
Required Git State Valid
```

具体 Release 流程遵循全局规则。

---

## 10. Tagging

Tag 的：

```text
Name
Format
Timing
Creation
Push
```

全部服从全局 Git / Version Management。

本 Rule 不自行定义 Tag Policy。

---

## 11. Changelog

Changelog 是否必须存在、采用什么格式、由什么事件触发，遵循全局 Version Management。

ForgeLoop 不创建独立 Changelog Policy。
