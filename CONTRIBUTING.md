# Contributing to ForgeLoop

## 1. Before Development

修改 ForgeLoop 前必须阅读：

```text
AGENTS.md
ForgeLoop.DESIGN.md
rules/
```

同时读取与当前 Task 相关的：

```text
代码
测试
Skills
Agents
Commands
Git Rules
Version Management Rules
```

---

## 2. Development Scope

每个开发任务应具有明确范围。

原则：

```text
Small
Focused
Traceable
Verifiable
Recoverable
```

---

## 3. Existing Harness

已有能力按照：

```text
Reuse
→ Extend
→ Create
```

顺序处理。

---

## 4. Version Changes

任何可能影响项目版本的修改必须先检查全局 Version Management。

包括：

```text
Feature
Bug Fix
Breaking Change
Dependency Change
Release Preparation
```

不能自行决定：

```text
major
minor
patch
pre-release
tag
```

除非全局规则允许并定义了对应语义。

---

## 5. Git Changes

所有 Git 操作遵守全局 Git Rules。

不得在本文件中定义覆盖全局规则的：

```text
Branch Naming
Commit Naming
Merge Policy
Tag Policy
Push Policy
```

等内容。

---

## 6. Verification

代码修改完成后，根据实际变更执行：

```text
Test
Build
Lint
Type Check
Runtime Verification
Review
Requirement Verification
```

---

## 7. Documentation

ForgeLoop 自身文档：

```text
doc/
```

外部项目文档：

```text
dev-doc/
```

---

## 8. Completion

一个 Task 完成前至少应具备：

```text
Implementation
Verification
Evidence
Checkpoint
```

Checkpoint 的 Git 实现方式必须遵循全局 Git Rules。

---

## 9. Release

Release 必须同时满足：

```text
Goal / Release Criteria
+
Version Management Rules
+
Git Rules
+
Required Verification
```

不得因为工作内容“看起来完成”就直接发布版本。
