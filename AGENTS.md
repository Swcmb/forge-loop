# ForgeLoop Agent Contract

## 1. Project Identity

Project:

```text
ForgeLoop
```

Purpose:

```text
Goal-Driven MVP Iterative Engineering
```

Target:

```text
Claude Code
```

ForgeLoop 是一套面向 Claude Code 的长周期、目标驱动、迭代式软件工程工作流。

ForgeLoop 的系统设计由：

```text
ForgeLoop.DESIGN.md
```

定义。

本文件定义 Claude Code 在 ForgeLoop 项目自身开发过程中的项目级约束。

---

## 2. Governing Rules

ForgeLoop 必须遵守全局工程治理规则。

涉及：

```text
Version Management
Git
Repository Management
Release Management
Security
```

等事项时，全局规则优先。

基本优先级：

```text
Global Rules
    ↓
ForgeLoop Project Rules
    ↓
Task Instructions
```

ForgeLoop 项目规则不得与全局规则冲突。

如果发现冲突：

```text
Global Rule wins
```

---

## 3. ForgeLoop Is the Current Project

当前仓库就是 ForgeLoop。

因此：

```text
CURRENT_PROJECT = FORGELOOP
OWNER = FORGELOOP
```

ForgeLoop 自身开发直接使用：

```text
doc/
.ai/
src/
tests/
```

以及项目已有的正常目录。

ForgeLoop 自身开发不得因为使用 ForgeLoop Workflow，就产生：

```text
dev-doc/
.dev-ai/
```

作为中间开发层。

---

## 4. Namespace Ownership

命名空间由 Owner 决定。

```text
FORGELOOP
    → normal namespace

CURRENT_PROJECT
    → dev-* / .dev-*
```

ForgeLoop 自身：

```text
doc/
.ai/
```

外部项目：

```text
dev-doc/
.dev-ai/
```

---

## 5. Design Authority

ForgeLoop 系统设计以：

```text
ForgeLoop.DESIGN.md
```

为设计依据。

Design 定义：

```text
Lifecycle
Responsibilities
Integration
State Semantics
Verification Semantics
Completion Rules
Workspace Namespace
```

具体实现不得脱离实际项目上下文自行假定。

Claude Code 必须结合：

```text
ForgeLoop.DESIGN.md
+
AGENTS.md
+
rules/
+
现有代码
+
现有 Harness
```

进行工程决策。

### Design Is The Single Authority

所有设计表述以：

```text
ForgeLoop.DESIGN.md
```

为准。

具体要求：

```text
1. 术语、生命周期顺序、Gate 名称、状态名、ID 格式、Checkpoint 字段
   等设计表述，一律以 DESIGN.md 的原始定义为准。

2. 其他文件（README.md / AGENTS.md / CONTRIBUTING.md / rules/ / doc/ /
   CLAUDE.md）不得重新表述、简化或改写 DESIGN.md 的设计内容。
   这些文件只做索引，引用时必须指向 DESIGN.md 的节号。

3. 任何文件与 DESIGN.md 冲突时，DESIGN.md wins。
   发现冲突应先修正引用方，而不是反向修改 DESIGN.md。

4. 修改 DESIGN.md 本身需要用户明确指示。
   DESIGN.md 的删减、重构或重新编号都会使下游 rules/ 与 CLAUDE.md
   中的引用失效。
```

---

## 6. Version Management

ForgeLoop 项目版本必须遵守全局 Version Management 规则。

ForgeLoop 不建立独立版本管理体系。

全局版本管理负责决定：

```text
Version Source of Truth
Current Version
Version Scheme
Version Increment
Pre-release
Release
Tag
Changelog
Release Metadata
```

Claude Code 必须在执行版本相关工作前读取并遵循全局 Version Management 规则。

不得自行发明另一套：

```text
Version Numbering
Version Bump
Release Tag
Changelog
```

规则。

---

## 7. Design Version vs Project Version

以下版本必须严格区分：

```text
Design Version
Project Version
Package Version
Skill Version
Release Version
```

例如：

```text
ForgeLoop.DESIGN.md
Version: 1.0.0
```

表示：

```text
Design Document Version = 1.0.0
```

不能仅因为该字段存在，就推断：

```text
ForgeLoop Project Version = 1.0.0
```

ForgeLoop 项目版本必须依据全局 Version Management 判定。

---

## 8. Git Governance

ForgeLoop 的所有 Git 操作必须遵循全局 Git Rules。

包括：

```text
branch
commit
merge
rebase
reset
revert
tag
push
pull
worktree
release
```

等。

ForgeLoop 不建立第二套 Git Policy。

ForgeLoop 的生命周期需要：

```text
Checkpoint
```

时，应调用并遵循现有 Git Workflow 建立可靠版本边界。

---

## 9. Existing Harness First

开发 ForgeLoop 前必须优先检查：

```text
AGENTS.md
rules/
agents/
commands/
skills/
```

已有能力优先：

```text
Reuse
```

已有能力不足时：

```text
Extend
```

确有必要时：

```text
Create
```

不得重复实现已经存在的能力。

---

## 10. One Task at a Time

ForgeLoop 自身开发遵循：

```text
ONE TASK
```

默认执行：

```text
Select
 ↓
Explore
 ↓
Implement
 ↓
Test
 ↓
Review
 ↓
Verify
 ↓
Checkpoint
```

一个 Task 完成以后才能进入下一个 Task。

---

## 11. Evidence Required

完成状态必须有实际证据。

证据可以包括：

```text
Test Result
Build Result
Runtime Result
Review Result
Inspection Result
Requirement Verification
```

不能仅根据“代码已经写出来”声明完成。

---

## 12. State Persistence

ForgeLoop 自身长期运行状态存放：

```text
.ai/
```

至少应能够表达：

```text
Goal
Phase
Task
Iteration
Checkpoint
Blocker
Verification
```

长期状态不能只存在于当前 Claude Code 对话。

---

## 13. Recovery

发生：

```text
Restart
Interruption
Context Compaction
Agent Failure
Partial Execution
Unexpected Git State
```

时，必须先检查：

```text
.ai/
Current Files
Git State
Checkpoint
```

完成状态协调后才能继续。

---

## 14. Final Audit

ForgeLoop 自身一个完整 Goal 的最终完成必须经过：

```text
Final Audit
```

Audit 发现问题后：

```text
Finding
 ↓
Task
 ↓
Iteration
 ↓
Verification
 ↓
Audit Again
```

直到满足完成条件。

---

## 15. Completion

ForgeLoop 自身开发完成必须满足项目实际要求以及：

```text
Required Requirements Verified
+
Required Tests Passed
+
Required Reviews Passed
+
Final Audit Passed
+
Version State Valid
+
Git State Valid
```

其中：

```text
Version State Valid
```

必须依据全局 Version Management。

```text
Git State Valid
```

必须依据全局 Git Rules。

---

## 16. Final Principle

```text
ForgeLoop defines the workflow.
Global Rules define governance.
Claude Code performs the engineering.
```

ForgeLoop 的具体实现由实际项目状态和开发过程动态形成。
