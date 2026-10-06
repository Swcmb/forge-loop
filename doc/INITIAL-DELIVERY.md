重要边界：

```text
ForgeLoop.DESIGN.md
    = ForgeLoop 系统设计，使用你提供的 1.0.0 版本

ForgeLoop Project Version
    = 由全局 Version Management 规则决定

ForgeLoop Git Behavior
    = 由全局 Git Rules 决定
```

下面是完整文档集。**不包含 `ForgeLoop.DESIGN.md`**，你提供的版本直接作为设计基线。

---

# AGENTS.md

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


---

# README.md

# ForgeLoop

## Goal-Driven MVP Iterative Engineering

ForgeLoop 是一套面向 Claude Code 的长周期、目标驱动、迭代式软件工程工作流。

核心生命周期：

```text
Goal
 ↓
MVP
 ↓
Requirement
 ↓
SPEC
 ↓
PLAN
 ↓
Task
 ↓
Iteration
 ↓
Implementation
 ↓
Test
 ↓
Review
 ↓
Requirement Verification
 ↓
Git Checkpoint
 ↓
Next Task
 ↓
Final Audit
 ↓
Release
 ↓
Goal Complete
```

## Design

ForgeLoop 的系统设计：

```text
ForgeLoop.DESIGN.md
```

Design Version：

```text
1.0.0
```

这里的 `1.0.0` 是 Design Document Version。

ForgeLoop 项目自身版本由全局 Version Management 决定。

## Governance

ForgeLoop 遵守：

```text
Global Version Management
Global Git Rules
Global Security Rules
Global Repository Rules
```

ForgeLoop 项目规则不得与全局规则冲突。

## Project Workspace

ForgeLoop 自身：

```text
doc/
.ai/
src/
tests/
```

外部项目：

```text
dev-doc/
.dev-ai/
dev-*/
.dev-*/
```

核心规则：

```text
FORGELOOP
    → normal namespace

CURRENT_PROJECT
    → dev-* / .dev-*
```

## Core Responsibility

ForgeLoop 负责：

```text
Workflow Orchestration
Lifecycle Control
Task Progression
State Persistence
Verification Gates
Checkpoint Control
Recovery
Final Audit
```

专业执行能力来自：

```text
Agents
Commands
Skills
Rules
Git Workflow
```

## Development

ForgeLoop 自身开发遵循：

```text
Goal
 ↓
MVP
 ↓
Requirement
 ↓
SPEC
 ↓
PLAN
 ↓
Task
 ↓
Iteration
 ↓
Verification
 ↓
Checkpoint
 ↓
Final Audit
```

具体工程设计由 Claude Code 根据实际项目动态完成。


---

# CONTRIBUTING.md

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

---

# rules/forge-loop-development.md

# ForgeLoop Development Rules

## 1. Scope

本 Rule 适用于 ForgeLoop 自身开发。

```text
OWNER = FORGELOOP
CURRENT_PROJECT = FORGELOOP
```

---

## 2. Governing Rules

本 Rule 必须服从：

```text
Global Rules
```

尤其是：

```text
Global Version Management
Global Git Rules
Global Security Rules
Global Repository Rules
```

---

## 3. Design

开发前读取：

```text
ForgeLoop.DESIGN.md
```

Design 是系统设计依据。

---

## 4. No Premature Detailed Design

不得在没有实际工程依据的情况下预先假定：

```text
Architecture
Module
API
Database
Task Breakdown
Implementation Structure
```

具体设计由 Claude Code 结合实际需求和代码形成。

---

## 5. Existing Harness First

开发前检查：

```text
agents/
commands/
skills/
rules/
```

遵循：

```text
Reuse
→ Extend
→ Create
```

---

## 6. Task Boundary

默认：

```text
ONE TASK
```

执行一个 Task 时：

```text
Explore
→ Implement
→ Test
→ Review
→ Verify
```

---

## 7. Evidence

任何完成状态必须能够回答：

```text
What was changed?
How was it tested?
How was it reviewed?
How was the requirement verified?
```

---

## 8. Requirement Integrity

Requirement、SPEC、PLAN、Task、Implementation、Verification 之间必须保持可追踪。

Requirement 或 SPEC 发生语义变化时：

```text
Existing Implementation
Existing Verification
```

必须重新评估。

---

## 9. State

ForgeLoop 自身状态存放：

```text
.ai/
```

---

## 10. Checkpoint

完成 Task 后需要形成 Checkpoint。

Checkpoint 的具体 Git 实现：

```text
遵循 Global Git Rules
```

ForgeLoop 不自行定义 commit / tag / branch 策略。

---

## 11. Version

任何版本相关工作：

```text
Read Global Version Management
→ Determine Current Version
→ Determine Required Version Change
→ Apply Global Rules
→ Verify Version State
```

不得直接猜测版本号。

---

## 12. Final Audit

全部 Required Task 完成后执行：

```text
Final Audit
```

Audit 发现问题时重新进入 Task Loop。

---

## 13. Completion

完成条件：

```text
Requirements Verified
+
Tests Passed
+
Reviews Passed
+
Final Audit Passed
+
Version Valid
+
Git Valid
```


---

# rules/workspace-namespace.md

# Workspace Namespace Rules

## 1. Ownership

ForgeLoop 只有两个逻辑 Owner：

```text
FORGELOOP
CURRENT_PROJECT
```

---

## 2. Core Mapping

```text
FORGELOOP
    → normal namespace

CURRENT_PROJECT
    → dev-* / .dev-*
```

---

## 3. ForgeLoop Self Development

当开发 ForgeLoop 自身：

```text
Owner = FORGELOOP
```

使用：

```text
doc/
.ai/
```

以及正常源码目录。

不得使用：

```text
dev-doc/
.dev-ai/
```

作为 ForgeLoop 自身开发空间。

---

## 4. External Project

ForgeLoop 开发其他项目：

```text
Owner = CURRENT_PROJECT
```

使用：

```text
dev-doc/
.dev-ai/
```

以及：

```text
dev-*
.dev-*
```

---

## 5. Mapping

```text
Current Project       ForgeLoop

dev-doc/              doc/
dev-config/           config/
dev-scripts/          scripts/
dev-tools/            tools/
dev-agents/           agents/
dev-commands/         commands/
dev-skills/           skills/
dev-rules/            rules/
dev-hooks/            hooks/
dev-prompts/          prompts/
dev-templates/        templates/
dev-reports/          reports/
```

隐藏目录：

```text
.dev-ai/              .ai/
.dev-cache/           .cache/
.dev-work/            .work/
```

---

## 6. Ownership Is Not Maturity

以下状态不会改变 Namespace：

```text
Draft
Review
Approved
Stable
Released
```

Owner 决定 Namespace。

---

## 7. No Promotion

禁止默认：

```text
dev-doc → doc
.dev-ai → .ai
```

不存在“成熟后迁移到 ForgeLoop 目录”的标准流程。

---

## 8. Source Code

源码目录不强制使用 `dev-`。

例如：

```text
src/
tests/
server/
client/
packages/
```

仍由项目自身结构决定。


---

# rules/state-and-recovery.md

# State and Recovery Rules

## 1. Runtime Location

ForgeLoop：

```text
.ai/
```

External Project：

```text
.dev-ai/
```

---

## 2. Minimum State

必须能够恢复：

```text
Goal
Phase
Task
Iteration
Checkpoint
Blocker
Verification
```

---

## 3. Persistent State

以下信息不能只保存在对话：

```text
Current Goal
Current Phase
Current Task
Current Iteration
Verification
Checkpoint
Blocker
Resume Position
```

---

## 4. Recovery

恢复流程：

```text
Load State
↓
Inspect Current Task
↓
Inspect Workspace
↓
Inspect Git
↓
Inspect Checkpoint
↓
Reconcile
↓
Resume
```

---

## 5. Git/State Conflict

如果：

```text
Runtime State
```

和：

```text
Git State
```

不一致：

```text
STOP AUTO-PROGRESSION
```

先进行 Reconciliation。

例如：

```text
Runtime = Task Complete
Git = Uncommitted Changes
```

或：

```text
Runtime = Iteration 5
Git = Iteration 4 Checkpoint
```

必须先确认真实工程状态。

---

## 6. Partial Execution

发生中断时：

```text
Inspect Existing Changes
↓
Determine Completed Work
↓
Determine Remaining Work
↓
Determine Verification State
↓
Continue / Repair
```

不得无条件重复执行。

---

## 7. Failed Verification

任何验证失败：

```text
Task ≠ Complete
```

然后：

```text
Repair
↓
Test
↓
Review
↓
Verify
```

---

## 8. Blocked

无法安全继续时：

```text
Blocked
```

Blocker 至少记录：

```text
Cause
Impact
Required Action
Context
```

---

## 9. State Integrity

不得：

```text
伪造完成
跳过验证
静默删除状态
静默覆盖历史
```

状态必须能够解释当前工程为什么处于当前阶段。


---

# rules/version-management.md

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


---

# rules/git-integration.md

# ForgeLoop Git Integration Rules

## 1. Authority

ForgeLoop 的 Git 权威规则：

```text
Global Git Rules
```

本 Rule 是集成规则，不是替代规则。

---

## 2. No Second Git Policy

ForgeLoop 不定义独立：

```text
Branch Policy
Commit Convention
Merge Policy
Rebase Policy
Tag Policy
Push Policy
Remote Policy
```

这些由全局 Git Rules 决定。

---

## 3. Checkpoint

ForgeLoop Lifecycle 中的：

```text
Checkpoint
```

必须通过合法 Git Workflow 形成可靠版本边界。

---

## 4. Task Completion

标准关系：

```text
Task
↓
Implementation
↓
Verification
↓
Git Workflow
↓
Checkpoint
```

Checkpoint 的实际形式由全局 Git Rules 决定。

---

## 5. Before Git Mutation

任何可能改变 Git 状态的操作：

```text
commit
reset
rebase
merge
revert
checkout
branch
push
```

必须遵守全局 Git Rules。

---

## 6. Unexpected Git State

如果发现：

```text
Uncommitted Changes
Detached HEAD
Unexpected Branch
Conflicting Changes
Missing Checkpoint
```

必须先按照全局 Git Rules 处理。

ForgeLoop 不得擅自恢复 Git 状态。

---

## 7. Release

Release 所涉及：

```text
Commit
Tag
Push
Branch
```

均由全局 Git Rules 和 Version Management 管理。

ForgeLoop 只负责工作流编排。



---

# doc/DEVELOPMENT.md

# ForgeLoop Development

## 1. Project Ownership

当前仓库：

```text
ForgeLoop
```

Owner：

```text
FORGELOOP
```

因此 ForgeLoop 自身开发资料直接存放在：

```text
doc/
```

运行状态直接存放在：

```text
.ai/
```

---

## 2. Design Authority

ForgeLoop 系统设计：

```text
ForgeLoop.DESIGN.md
```

当前 Design Version：

```text
1.0.0
```

该版本只表示设计文档版本。

Project Version 遵循：

```text
Global Version Management
```

---

## 3. Development Model

ForgeLoop 自身开发采用：

```text
Goal
→ MVP
→ Requirement
→ SPEC
→ PLAN
→ Task
→ Iteration
→ Implementation
→ Test
→ Review
→ Requirement Verification
→ Checkpoint
→ Final Audit
```

---

## 4. Design vs Implementation

Design 规定：

```text
What ForgeLoop is
What ForgeLoop does
Lifecycle
Responsibility
Integration
Verification
State
Completion
```

具体：

```text
Architecture Implementation
Module
API
Data Model
Task Breakdown
Test Details
```

根据实际工程动态形成。

---

## 5. Global Version Management

ForgeLoop 版本管理：

```text
遵循全局 Version Management
```

任何版本变化都必须通过全局规则判断。

设计版本与项目版本分离：

```text
Design Version ≠ Project Version
```

---

## 6. Global Git Rules

所有 Git 行为：

```text
遵循全局 Git Rules
```

ForgeLoop 需要：

```text
Checkpoint
```

时，通过全局 Git Workflow 实现。

---

## 7. Existing Harness

优先使用：

```text
Agents
Commands
Skills
Rules
Git Workflow
```

ForgeLoop 的角色是：

```text
Orchestration
```

---

## 8. Verification

Task 完成必须有：

```text
Implementation
Test
Review
Requirement Verification
Evidence
Checkpoint
```

实际验证方式根据 Task 决定。


---

# doc/WORKSPACE-NAMESPACE.md

# ForgeLoop Workspace Namespace

## 1. Core Rule

```text
FORGELOOP
    → normal namespace

CURRENT_PROJECT
    → dev-* / .dev-*
```

---

## 2. ForgeLoop

开发 ForgeLoop 自身：

```text
doc/
.ai/
```

例如：

```text
doc/
    ForgeLoop Documentation

.ai/
    ForgeLoop Runtime
```

---

## 3. External Project

ForgeLoop 被用于开发其他项目：

```text
dev-doc/
.dev-ai/
```

以及：

```text
dev-*
.dev-*
```

---

## 4. Mapping

```text
dev-doc/       ↔ doc/
dev-config/    ↔ config/
dev-scripts/   ↔ scripts/
dev-tools/     ↔ tools/
dev-agents/    ↔ agents/
dev-commands/  ↔ commands/
dev-skills/    ↔ skills/
dev-rules/     ↔ rules/
dev-hooks/     ↔ hooks/
dev-prompts/   ↔ prompts/
dev-templates/ ↔ templates/
dev-reports/   ↔ reports/
```

隐藏目录：

```text
.dev-ai/       ↔ .ai/
.dev-cache/    ↔ .cache/
.dev-work/     ↔ .work/
```

---

## 5. Important Meaning

```text
doc/
```

含义：

```text
ForgeLoop Documentation
```

```text
dev-doc/
```

含义：

```text
Current Project Development Documentation
```

因此 ForgeLoop 自身开发时直接使用：

```text
doc/
```

---

## 6. No Migration

不存在：

```text
dev-doc
    ↓
成熟
    ↓
doc
```

或者：

```text
.dev-ai
    ↓
成熟
    ↓
.ai
```

Namespace 是 Owner 信息，而不是成熟度信息。

---

## 7. Source Code

源码不需要使用：

```text
dev-src/
```

正常：

```text
src/
tests/
app/
server/
client/
packages/
```

即可。


---

# doc/PROJECT-CONSTRAINTS.md

# ForgeLoop Project Constraints

## 1. Project

```text
Project = ForgeLoop
Owner = FORGELOOP
Target = Claude Code
```

---

## 2. Design

Design Authority：

```text
ForgeLoop.DESIGN.md
```

Design Version：

```text
1.0.0
```

---

## 3. Version Constraint

ForgeLoop Project Version 必须遵循：

```text
Global Version Management
```

项目不得自行定义与全局规则冲突的版本系统。

必须明确区分：

```text
Design Version
Project Version
Release Version
```

---

## 4. Git Constraint

ForgeLoop 所有 Git 行为必须遵循：

```text
Global Git Rules
```

项目不得建立第二套 Git Policy。

---

## 5. Workspace Constraint

ForgeLoop 自身：

```text
doc/
.ai/
```

External Project：

```text
dev-doc/
.dev-ai/
```

---

## 6. Development Constraint

开发遵循：

```text
Small Task
+
Actual Implementation
+
Actual Verification
+
Evidence
+
Checkpoint
```

---

## 7. Requirement Constraint

Required Requirement 必须：

```text
Have Identity
Be Traceable
Be Implemented
Be Verified
```

---

## 8. State Constraint

长期状态必须持久化。

ForgeLoop：

```text
.ai/
```

---

## 9. Recovery Constraint

恢复必须检查：

```text
State
Workspace
Git
Checkpoint
```

状态不一致时不得静默继续。

---

## 10. Final Audit Constraint

Goal Complete 前必须：

```text
Final Audit
```

Audit 可以产生新的 Task。

---

## 11. Completion Constraint

最终完成必须满足：

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

由全局 Version Management 判断。

```text
Git State Valid
```

由全局 Git Rules 判断。

---

## 12. Absolute Rules

ForgeLoop 开发时必须始终遵循：

```text
Global Governance
        ↓
ForgeLoop Rules
        ↓
Current Task
```

版本：

```text
Global Version Management
```

Git：

```text
Global Git Rules
```

工作空间：

```text
ForgeLoop Namespace Rules
```

生命周期：

```text
ForgeLoop.DESIGN.md
```

具体实现：

```text
Claude Code 根据实际工程动态决定
```



最终建议把仓库组织成：

```text
ForgeLoop/
├── AGENTS.md
├── README.md
├── CONTRIBUTING.md
├── ForgeLoop.DESIGN.md       ← 你提供的 1.0.0
│
├── rules/
│   ├── forge-loop-development.md
│   ├── workspace-namespace.md
│   ├── state-and-recovery.md
│   ├── version-management.md
│   └── git-integration.md
│
├── doc/
│   ├── DEVELOPMENT.md
│   ├── WORKSPACE-NAMESPACE.md
│   └── PROJECT-CONSTRAINTS.md
│
├── .ai/
├── src/
└── tests/
```

其中最关键的治理链现在已经固定为：

```text
Global Version Management
            ↓
ForgeLoop Version Integration
            ↓
ForgeLoop Development
```

以及：

```text
Global Git Rules
        ↓
ForgeLoop Git Integration
        ↓
ForgeLoop Checkpoint / Release
```

这样 Claude Code 在开发 ForgeLoop 时，就不会自己发明版本号规则，也不会自己发明 Git 工作流；**ForgeLoop 负责工程生命周期，全局规则负责版本与 Git 治理。**