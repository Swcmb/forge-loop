# ForgeLoop Artifact Persistence Rules

## 1. Purpose

ForgeLoop 是长周期工程系统。

Claude Code 的对话上下文属于临时工作上下文，不得作为工程文档、设计成果、任务记录或验证证据的唯一存储位置。

凡是进入 ForgeLoop 工程流程的正式产物，必须落盘。

---

## 2. Mandatory Persistence

以下类型的内容一旦形成正式结果，必须写入项目文件：

```text
Goal Definition
MVP / Scope Decision
Requirement
Acceptance Criteria
Brainstorming Result
Decision Record
SPEC
Detailed Design
Architecture
Plan
Task Definition
Implementation Notes
Test Plan
Test Result
Code Review
Requirement Verification
Audit Report
Audit Finding
Release Notes
Version Decision
Checkpoint Record
Recovery Record
Blocker Record
```

对话中出现的内容只有在写入对应文件后，才视为正式工程资产。

---

## 3. No Chat-Only Artifacts

禁止将以下内容仅保留在 Claude Code 对话中：

```text
Requirement
SPEC
Design
Plan
Review
Verification
Audit
Decision
Test Evidence
Release Information
```

例如：

```text
Claude Code 在对话中生成了 SPEC
```

不等于：

```text
SPEC 已完成
```

必须：

```text
Generate
↓
Write to File
↓
Verify File Exists
↓
Continue Workflow
```

---

## 4. ForgeLoop Self-Development

当前 ForgeLoop 自身开发时：

```text
OWNER = FORGELOOP
```

因此正式工程文档统一写入：

```text
doc/
```

例如：

```text
doc/
├── requirements/
├── brainstorming/
├── decisions/
├── design/
├── specs/
├── plans/
├── reviews/
├── verification/
├── audits/
└── releases/
```

实际目录结构不要求固定，上述结构仅为示例。

Claude Code 应根据实际工程需要创建目录。

---

## 5. External Project

当 ForgeLoop 用于开发其他项目时：

```text
OWNER = CURRENT_PROJECT
```

正式工程文档进入：

```text
dev-doc/
```

对应关系：

```text
FORGELOOP
    → doc/

CURRENT_PROJECT
    → dev-doc/
```

---

## 6. Runtime State

运行状态不属于普通文档。

ForgeLoop 自身运行状态：

```text
.ai/
```

外部项目运行状态：

```text
.dev-ai/
```

例如：

```text
.ai/
    current-goal
    current-phase
    current-work
    verification-state
    recovery-state
```

具体状态结构由实现决定。

---

## 7. Brainstorming Persistence

Brainstorming 产生的正式结果必须落盘。

至少保存：

```text
Questions
Clarifications
Decisions
Constraints
Open Issues
Resolved Issues
```

Brainstorming 的聊天过程可以是临时上下文，但经过整理形成的工程结论必须写入：

```text
doc/
```

或外部项目对应的：

```text
dev-doc/
```

---

## 8. SPAC Persistence

`/SPAC-plus-auto` 产生的正式设计结果必须落盘。

包括但不限于：

```text
Architecture
Detailed Design
Interfaces
Data Model
Components
Workflow
State Model
Error Handling
Verification Strategy
Implementation Constraints
```

不得仅在对话中输出设计后直接开始编码。

必须：

```text
/SPAC-plus-auto
↓
Generate Design
↓
Write Design to Disk
↓
Verify Design
↓
Proceed to Implementation
```

---

## 9. Phase Gate

进入下一个工程阶段前，当前阶段需要落盘的正式产物必须已经写入文件。

例如：

```text
Brainstorming
    ↓
Clarified Requirements written to disk
    ↓
SPAC
```

以及：

```text
SPAC
    ↓
Detailed Design written to disk
    ↓
Implementation
```

以及：

```text
Implementation
    ↓
Test / Review / Verification records written to disk
    ↓
Checkpoint
```

---

## 10. File Verification

写入文档后必须确认：

```text
File Exists
+
Content Is Complete
+
Correct Path
+
Correct Owner
```

不能仅调用写文件动作后就假定持久化成功。

---

## 11. Traceability

所有重要文档必须能够建立关系：

```text
Goal
↓
MVP / Scope
↓
Requirement
↓
Brainstorming Decision
↓
Detailed Design
↓
Implementation
↓
Test
↓
Review
↓
Verification
↓
Checkpoint
↓
Audit
```

文档之间应尽可能通过稳定 ID、引用或明确路径建立关联。

---

## 12. Update Existing Documents

当现有 Requirement、SPEC、Design、Plan 或 Audit 发生实质变化时：

```text
Read Existing Document
↓
Modify
↓
Write Back
↓
Verify
```

不得只在当前对话中说明：

```text
“我们把设计改成了……”
```

却不更新原文件。

---

## 13. Completion Condition

任何阶段不得仅因为对话中已经产生结果，就认为该阶段完成。

必须满足：

```text
Artifact Generated
+
Artifact Persisted
+
Artifact Verified
```

才算完成。

---

## 14. Recovery Principle

任何重要工程结论都应该能够在 Claude Code 重启、Session 中断或 Context Compaction 后，从：

```text
Project Files
+
.ai/
+
Git
```

恢复。

恢复工程状态不得依赖“记得之前聊天说过什么”。

---

## 15. Final Rule

ForgeLoop 遵循：

```text
Conversation = Temporary Working Context

Filesystem = Durable Project Knowledge

.ai/ = Durable Workflow State

Git = Durable Version History
```

因此：

> **凡是需要在后续开发中继续使用、验证、审计、恢复或追踪的内容，都必须落盘。**
