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
