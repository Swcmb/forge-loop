# ForgeLoop
## Goal-Driven MVP Iterative Engineering

**Version:** 1.0.0  
**Status:** Design  
**Target:** Claude Code  
**Core:** `/goal` + `slavingia/mvp` + `aspiers/iterative-development`  
**Integration:** Existing Agents / Commands / Rules / Git Workflow

---

# 1. Purpose

ForgeLoop 是一套面向 Claude Code 的长周期软件工程工作流。

它解决一个核心问题：

> 给 Claude 一组项目文档、需求和现有代码后，如何让 Claude 从 MVP 开始，经过 Spec、Plan、单任务迭代、测试、Review、需求验收、版本控制，持续工作到文档规定的全部功能真正完成。

完整生命周期：

```text
Source Documents
        ↓
MVP Definition
        ↓
Requirement Extraction
        ↓
Requirement Review
        ↓
SPEC
        ↓
SPEC Review
        ↓
Implementation Plan
        ↓
Task Breakdown
        ↓
Iterative Development
        ↓
Test
        ↓
Code Review
        ↓
Requirement Verification
        ↓
Git Commit
        ↓
Version Checkpoint
        ↓
Next Task
        ↓
...
        ↓
Final Document Audit
        ↓
Release
        ↓
Goal Complete
```

---

# 2. Design Philosophy

ForgeLoop 使用四个层次定义开发行为：

```text
Goal
    决定什么时候停止

MVP
    决定第一版做什么

SPEC + PLAN
    决定必须做到什么、拆成什么

Iterative Development
    决定这一轮具体完成什么
```

进一步加上：

```text
Git Workflow
    决定如何形成可靠版本

Requirement Verification
    决定一个需求是否真正完成

Final Audit
    决定整个文档是否兑现
```

因此：

```text
/goal
  ↓
slavingia/mvp
  ↓
SPEC
  ↓
PLAN
  ↓
aspiers/iterative-development
  ↓
Test / Review / Verify
  ↓
Git / Version
  ↓
Next Iteration
  ↓
Final Audit
```

---

# 3. Source Skills

## 3.1 `slavingia/mvp`

ForgeLoop 使用 `slavingia/mvp` 作为 MVP 定义层。

该 Skill 当前的核心方法是：

```text
Manual
   ↓
Processized
   ↓
Productized
```

并要求围绕：

```text
最小实现
快速交付
用户价值
快速反馈
```

进行范围控制。其官方 Skill 还提供了“能否周末交付”“客户是否得到实际改善”“能否快速获得反馈”等 Build Questions。

ForgeLoop 对它的职责定义为：

```text
MVP Scope
Feature Prioritization
Minimality Check
Manual-first 判断
Feedback Loop
```

它不承担：

```text
Task Execution
Git
Testing
Final Audit
Goal Completion
```

---

## 3.2 `aspiers/iterative-development`

ForgeLoop 使用 `aspiers/iterative-development` 作为**单任务迭代执行模型**。

核心原则：

```text
One Task
    ↓
Implement
    ↓
Verify
    ↓
Record
    ↓
Next Task
```

ForgeLoop 不把 Iterative Development 改造成“大批量自动编码”。

核心边界保持：

```text
一次一个可验证任务
```

ForgeLoop 在此基础上增加 Goal Mode，使任务完成后的推进由：

```text
人工审核 → 下一任务
```

变成：

```text
完成验证
→ checkpoint
→ Goal 下一轮
→ 下一任务
```

这样能够同时保留：

```text
Manual Mode
```

与：

```text
Goal Mode
```

---

# 4. Claude Code `/goal`

`/goal` 是 ForgeLoop 的最高层生命周期控制器。

Claude Code 的 Goal 机制用于定义一个完成条件，然后让 Claude 在多个轮次中持续工作；Goal evaluator 会在轮次结束后判断条件是否满足。([code.claude.com](https://code.claude.com/docs/en/goal))

ForgeLoop 因此采用：

```text
/goal
    ↓
ForgeLoop
```

的关系。

`/goal` 负责：

```text
WHEN TO STOP
```

ForgeLoop 负责：

```text
HOW TO WORK
```

---

# 5. Goal Boundary

模型通过普通文本写：

```text
使用 /goal
```

属于开发指导。

它不能替代用户实际启动 Claude Code 的 `/goal`。

因此标准入口：

```text
/goal
<completion condition>
```

ForgeLoop 在 Goal 已经 active 的情况下开始工作。

---

# 6. Goal Completion Contract

推荐最终 Goal：

```text
/goal

完成当前项目 MVP Scope 中规定的全部 Required 功能。

完成条件：

1. 已读取并分析相关项目文档。
2. 已建立 Requirement Matrix。
3. 已定义 MVP Scope。
4. 已完成 Requirement Review。
5. 已创建并审核 SPEC。
6. 已创建 Implementation Plan。
7. 所有 Required Requirement 均已实现。
8. 所有 Required Requirement 均已验证。
9. 所有 Acceptance Criteria 均通过。
10. 必要测试均执行并通过。
11. 必要 Code Review 均通过。
12. 构建成功。
13. 运行时验证成功。
14. 最终 Document Audit 通过。
15. Git 与 Version State 一致。
16. 已生成最终完成证据。

持续工作直到以上条件全部满足。
```

关键终态：

```text
ALL_REQUIRED_VERIFIED
+
ALL_ACCEPTANCE_PASS
+
ALL_TESTS_PASS
+
FINAL_AUDIT_PASS
+
VERSION_CONSISTENT
```

---

# 7. ForgeLoop Architecture

```text
                         USER
                          │
                          ▼
                 Claude Code /goal
                          │
                          ▼
              ┌─────────────────────┐
              │      ForgeLoop      │
              │   Orchestration     │
              └─────────┬───────────┘
                        │
        ┌───────────────┼────────────────┐
        │               │                │
        ▼               ▼                ▼
  slavingia/mvp      Document         Existing
                     Analysis         Project
        │               │                │
        └───────────────┼────────────────┘
                        ▼
                   Requirement
                        │
                        ▼
                   Requirement
                      Review
                        │
                        ▼
                      SPEC
                        │
                        ▼
                   SPEC Review
                        │
                        ▼
                      PLAN
                        │
                        ▼
                Task Breakdown
                        │
                        ▼
       ┌────────────────────────────────┐
       │    aspiers Iterative Model     │
       │                                │
       │       One Task Only            │
       └───────────────┬────────────────┘
                       │
                       ▼
                  Implement
                       │
                       ▼
                     Test
                       │
                       ▼
                    Review
                       │
                       ▼
                Requirement Verify
                       │
                       ▼
                     Commit
                       │
                       ▼
                  Checkpoint
                       │
                       ▼
                 Next Iteration
                       │
                       ▼
                Final Document Audit
                       │
                       ▼
                    Release
                       │
                       ▼
                  Goal Complete
```

---

# 8. Existing Harness Integration

现有 Harness 已经形成：

```text
AGENTS.md
    ↓
rules/README.md
    ↓
rules/*.md
    ↓
agents/
commands/
skills/
```

你当前的 `AGENTS.md` 已明确要求：

```text
Read before write
Smallest change
Done means executed and verified
Git work → read Git rules
Testing → follow testing rules
```

并要求先读取规则索引，再只读取当前任务适用规则。

ForgeLoop 完全复用这一体系。

---

# 9. Responsibility Model

```text
AGENTS.md
    ↓
全局行为契约

rules/
    ↓
具体治理规则

agents/
    ↓
专业执行者

commands/
    ↓
用户显式工作流入口

skills/
    ↓
可复用领域能力

ForgeLoop
    ↓
项目级开发编排

Claude Code /goal
    ↓
长周期完成控制
```

ForgeLoop 不复制已有规则。

---

# 10. Agent Integration

现有：

```text
code-explorer
code-architect
code-reviewer
```

作为下层专业 Agent。

职责：

### code-explorer

```text
项目结构
调用关系
依赖
已有实现
测试
影响面
```

### code-architect

```text
技术方案
架构边界
模块关系
风险
实现策略
```

### code-reviewer

```text
Diff
Correctness
Regression
Security
Maintainability
Architecture
```

ForgeLoop 负责决定：

```text
何时调用
为什么调用
调用结果进入哪个 Gate
```

---

# 11. Existing Commands / Skills Integration

继续复用现有：

```text
feature-dev
breakdown-feature-prd
breakdown-feature-implementation
breakdown-plan
breakdown-test
create-specification
create-implementation-plan
```

现有技能库已经包含这些类型的组件。

ForgeLoop 采用：

```text
已有能力 = worker
ForgeLoop = orchestrator
```

---

# 12. Rules Integration

Git：

```text
rules/git.md
rules/github-kb.md
```

Testing：

```text
rules/testing.md
```

Filesystem：

```text
rules/filesystem.md
```

Security：

```text
rules/security.md
```

具体规则继续由现有 Rule System 管理。

ForgeLoop 只规定：

```text
需要 Git → 读取 Git Rule
需要测试 → 读取 Testing Rule
需要修改文件 → 读取 Filesystem Rule
```

---

# 13. Git Workflow Integration

当前 Git Workflow 设计采用：

```text
Markdown decides policy
Python provides facts
Agent performs resolution
Verification proves result
```

并将：

```text
skills/git-workflow/references/policy.md
```

作为 Policy Truth Source。

ForgeLoop 不创建第二套 Git Policy。

Git 操作统一走：

```text
ForgeLoop
    ↓
Git Workflow
    ↓
Policy Resolution
    ↓
Execution
    ↓
Verification
```

---

# 14. MVP Phase

MVP 阶段执行：

```text
Project
 ↓
Core User Value
 ↓
Minimum Deliverable
 ↓
MVP Scope
 ↓
Excluded Scope
```

---

# 15. MVP Scope Model

```yaml
mvp:
  version: 0.1.0

required:
  - REQ-001
  - REQ-002
  - REQ-003

optional:
  - REQ-010
  - REQ-011

deferred:
  - REQ-020
  - REQ-021
```

其中：

```text
required
```

是当前 Goal 必须兑现的需求集合。

---

# 16. MVP Minimality Gate

进入 SPEC 前进行：

```text
MVP Minimality Review
```

检查：

```text
这个功能是不是核心价值的一部分？
这个功能是否可以延期？
这个功能是否已经有更简单实现？
这个流程能否先人工/简单实现？
```

目标：

```text
最小范围
+
最大可验证性
```

---

# 17. Document Discovery

读取：

```text
README
docs/
设计文档
API 文档
Issue
源代码
测试
配置
```

产生：

```text
docs/requirements/source-index.md
```

记录：

```yaml
sources:
  - id: SRC-001
    path: docs/product.md

  - id: SRC-002
    path: docs/api.md
```

---

# 18. Requirement Extraction

生成：

```text
docs/requirements/requirement-matrix.yaml
```

每个 Requirement：

```yaml
REQ-001:
  title: Document Upload
  source:
    - SRC-001

  priority: required

  acceptance:
    - AC-001
    - AC-002

  status: pending
```

---

# 19. Requirement ID

Requirement ID 永久稳定：

```text
REQ-001
REQ-002
REQ-003
```

一旦进入正式 SPEC：

```text
REQ-001
```

不因为文字修改而重新编号。

这样 Git、Task、Test、Audit 都可以稳定引用。

---

# 20. Acceptance Criteria

每个 Requirement 至少拥有一个 Acceptance Criterion。

例如：

```yaml
REQ-001:
  acceptance:

    AC-001:
      description: Correct file uploads successfully

    AC-002:
      description: Invalid file type is rejected

    AC-003:
      description: Upload produces document_id
```

Acceptance Criterion 是：

```text
Requirement
    ↓
Verification
```

之间的桥梁。

---

# 21. Document Review

Reviewer 对：

```text
Source
+
Requirement Matrix
```

进行审核。

检查：

```text
Coverage
Accuracy
Consistency
Testability
Ambiguity
```

输出：

```text
REQUIREMENT_REVIEW_PASS
```

或者：

```text
REQUIREMENT_REVIEW_FAIL
```

失败：

```text
Requirement Repair
    ↓
Review Again
```

---

# 22. SPEC Phase

使用现有：

```text
create-specification
```

或已有：

```text
/spec
```

创建：

```text
docs/spec/SPEC.md
```

---

# 23. SPEC Content

```text
1. Goal
2. Scope
3. Requirements
4. Functional Behavior
5. Non-functional Requirements
6. Architecture Constraints
7. APIs
8. Data
9. Errors
10. Security
11. Runtime
12. Acceptance Criteria
```

---

# 24. SPEC Version

SPEC 使用：

```text
MAJOR.MINOR.PATCH
```

例如：

```text
0.1.0
0.2.0
0.2.1
1.0.0
```

规则：

```text
Patch
    文本修正 / 非语义修改

Minor
    增加兼容的新 Requirement / Capability

Major
    改变已有 Requirement 语义
```

涉及 Requirement 语义变化时必须进行：

```text
SPEC Impact Analysis
```

---

# 25. SPEC Gate

进入 PLAN 必须满足：

```text
Requirement Review = PASS
SPEC = COMPLETE
SPEC Review = PASS
```

形成：

```text
SPEC_APPROVED
```

---

# 26. PLAN Phase

使用：

```text
breakdown-plan
create-implementation-plan
```

将：

```text
Requirement
```

转换为：

```text
Task
```

---

# 27. Requirement → Task Mapping

```text
REQ-001
 ├── TASK-001
 ├── TASK-002
 └── TASK-003

REQ-002
 ├── TASK-004
 └── TASK-005
```

禁止存在：

```text
没有 Requirement 的 Required Task
```

允许：

```text
纯技术任务
```

但需要与某个实现目标或质量目标关联。

---

# 28. Task Structure

为了兼容 `aspiers/iterative-development` 的任务驱动方式，采用：

```text
.ai/
└── <feature>/
    ├── tasks.md
    └── ...
```

示例：

```markdown
# Document Upload

- [ ] 1. Implement Upload API

  Requirement: REQ-001

  Acceptance:
  - AC-001
  - AC-002

  Tests:
  - TEST-001

- [ ] 2. Add Upload Validation

  Requirement: REQ-001

  Acceptance:
  - AC-003

  Tests:
  - TEST-002
```

---

# 29. Task State

```text
pending
ready
implementing
implemented
testing
reviewing
verified
blocked
complete
```

---

# 30. Iterative Development

核心：

```text
ONE TASK
```

生命周期：

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
Commit
 ↓
Checkpoint
```

---

# 31. Task Selection Policy

优先：

```text
1. Blocker
2. Required Requirement
3. Dependency prerequisite
4. High-risk Task
5. Small verifiable Task
```

原则：

```text
Small
Atomic
Verifiable
Traceable
```

---

# 32. One-Task Rule

每个 Goal Turn 的主目标：

```text
ONE PRIMARY TASK
```

允许：

```text
Implementation
+
Tests
+
必要文档更新
+
必要状态更新
```

属于同一 Task。

不在同一轮塞入无关功能。

---

# 33. Code Exploration

Task 开始后：

```text
code-explorer
```

检查：

```text
相关模块
调用关系
依赖
已有测试
已有实现
影响面
```

---

# 34. Architecture Check

需要架构判断时：

```text
code-architect
```

输出：

```text
implementation approach
affected components
risk
test strategy
```

---

# 35. Implementation

开发遵循现有：

```text
Read before write
Smallest valid change
Preserve project conventions
Task-scoped modification
```

这与现有 Global Agent Contract 完全一致。

---

# 36. Test Gate

每个 Task 必须有适当的验证。

选择：

```text
Lint
Unit
Integration
E2E
Build
Runtime
```

根据任务类型选择实际需要的级别。

现有全局契约已经规定：

```text
Done means executed and verified.
```

并要求报告实际验证命令及结果。

---

# 37. Code Review Gate

调用：

```text
code-reviewer
```

审核：

```text
Correctness
Architecture
Security
Regression
Maintainability
Scope
```

结果：

```text
PASS
```

或：

```text
FINDINGS
```

存在 Finding：

```text
Fix
 ↓
Test
 ↓
Review Again
```

---

# 38. Requirement Verification Gate

这一层单独存在。

Code Review 回答：

```text
代码质量是否正确？
```

Requirement Verification 回答：

```text
需求是否真的完成？
```

例如：

```text
TASK-042
    ↓
REQ-017
    ↓
AC-017-1
AC-017-2
AC-017-3
```

三个 AC 全部：

```text
PASS
```

以后：

```text
REQ-017 → VERIFIED
```

---

# 39. Evidence

每个 Requirement 保存：

```yaml
REQ-017:

  source:
    - SRC-004

  spec:
    section: 4.3
    version: 0.6.0

  task:
    - TASK-042

  implementation:
    commit: a82c91f

  tests:
    - TEST-108

  review:
    status: passed

  runtime:
    status: passed

  acceptance:
    AC-017-1: passed
    AC-017-2: passed
    AC-017-3: passed

  status: verified
```

---

# 40. Git Versioning

ForgeLoop 将 Git 作为工作流一级状态。

每个 Task：

```text
Task
 ↓
Implementation
 ↓
Test
 ↓
Review
 ↓
Verify
 ↓
Commit
```

这样每个 Commit 对应一个可验证增量。

---

# 41. Commit Traceability

完整链：

```text
Source
 ↓
REQ
 ↓
SPEC
 ↓
TASK
 ↓
ITERATION
 ↓
COMMIT
 ↓
TEST
 ↓
EVIDENCE
```

例如：

```text
SRC-004
  ↓
REQ-017
  ↓
SPEC §4.3
  ↓
TASK-042
  ↓
ITER-017
  ↓
a82c91f
  ↓
TEST-108
  ↓
REQ-017 VERIFIED
```

---

# 42. Branch Strategy

Branch 遵循现有 Git Workflow。

候选结构：

```text
goal/GOAL-001
```

或者：

```text
feature/document-upload
```

实际选择：

```text
Repository Policy
+
rules/git.md
+
Git Workflow
```

决定。

ForgeLoop 不创建第二套 Branch Policy。

---

# 43. Worktree

独立并行任务可使用：

```text
git worktree
```

例如：

```text
Goal
 ├── Worktree A → TASK-041
 ├── Worktree B → TASK-042
 └── Worktree C → investigation
```

主流程保持：

```text
Requirement
 ↓
Task
 ↓
Verification
```

统一。

现有 Git Workflow 已经把 worktree 作为并行开发的一等隔离机制。

---

# 44. Version Layers

ForgeLoop 同时追踪：

```text
Goal Version
MVP Version
SPEC Version
Plan Revision
Iteration
Task
Git Commit
Product Version
```

不要把这些概念合并。

---

# 45. Goal ID

每个长周期工作实例：

```text
GOAL-001
GOAL-002
```

例如：

```yaml
goal:
  id: GOAL-001
  type: mvp-completion
```

---

# 46. MVP Version

例如：

```text
MVP-0.1
MVP-0.2
MVP-1.0
```

它描述：

```text
产品范围
```

---

# 47. SPEC Version

例如：

```text
SPEC 0.3.0
```

描述：

```text
需求合同
```

---

# 48. Plan Revision

Plan 不一定采用 SemVer。

推荐：

```text
PLAN-r1
PLAN-r2
PLAN-r3
```

因为 Plan 的主要价值是：

```text
execution planning revision
```

---

# 49. Iteration ID

```text
ITER-001
ITER-002
ITER-003
```

一个 Iteration：

```text
One Task
One verification cycle
One checkpoint
```

---

# 50. Task ID

```text
TASK-001
TASK-002
```

Task 是最小工作单位。

---

# 51. Product Version

最终产品继续使用：

```text
MAJOR.MINOR.PATCH
```

例如：

```text
0.1.0
0.2.0
0.9.0
1.0.0
```

---

# 52. Version Relationship

```text
GOAL-001
│
├── MVP 0.1
│
├── SPEC 0.1.0
│
├── PLAN-r1
│
├── ITER-001
│   └── TASK-001
│       └── COMMIT A
│
├── ITER-002
│   └── TASK-002
│       └── COMMIT B
│
├── ITER-003
│   └── TASK-003
│       └── COMMIT C
│
└── FINAL
    └── Product v0.1.0
```

---

# 53. Checkpoint

每轮完成：

```text
ITERATION COMPLETE
```

生成：

```text
Checkpoint
```

内容：

```yaml
checkpoint:
  id: CP-003

  goal:
    id: GOAL-001

  iteration:
    id: ITER-003

  task:
    id: TASK-003

  git:
    commit: a82c91f

  spec:
    version: 0.4.0

  progress:
    requirements:
      total: 42
      verified: 17
```

---

# 54. Checkpoint Purpose

Checkpoint 用于：

```text
Resume
Audit
Rollback
Progress Tracking
Version Comparison
```

Context compact 后可以根据：

```text
Git
+
.ai/tasks.md
+
docs/status/
```

恢复。

---

# 55. Version State

项目建立：

```text
docs/status/version-state.yaml
```

示例：

```yaml
project:
  version: 0.4.0

goal:
  id: GOAL-001

mvp:
  version: 0.1

spec:
  version: 0.6.0

plan:
  revision: 4

iteration:
  current: ITER-017

git:
  branch: goal/GOAL-001
  head: a82c91f
  clean: true
```

---

# 56. Development State

```text
docs/status/development-status.yaml
```

```yaml
phase: iterative-development

requirements:
  total: 42
  verified: 17
  pending: 23
  blocked: 2

tasks:
  total: 96
  completed: 38
  pending: 58

current:
  iteration: ITER-018
  requirement: REQ-018
  task: TASK-043
```

---

# 57. Audit State

```text
docs/status/audit-state.yaml
```

```yaml
requirement_review:
  status: passed

spec_review:
  status: passed

code_review:
  status: passed

final_document_audit:
  status: pending

runtime:
  status: passed
```

---

# 58. Requirement State Machine

```text
PENDING
   ↓
PLANNED
   ↓
IMPLEMENTING
   ↓
IMPLEMENTED
   ↓
TESTING
   ↓
REVIEWING
   ↓
VERIFIED
```

失败：

```text
BLOCKED
```

变化：

```text
VERIFIED
   ↓
STALE
   ↓
RE-VERIFY
```

用于 Requirement 或 SPEC 发生语义变化的场景。

---

# 59. Evidence Invalidation

例如：

```text
REQ-017
```

从：

```text
“支持 PDF”
```

改变为：

```text
“支持 PDF + 加密 PDF”
```

原验证结果：

```text
PDF PASS
```

进入：

```text
STALE
```

重新：

```text
Plan Impact
 ↓
Task
 ↓
Test
 ↓
Review
 ↓
Verify
```

---

# 60. Scope Change

Goal 运行期间出现新需求：

```text
New Requirement
       ↓
MVP Review
       ↓
Scope Decision
```

结果：

```text
Required
```

或：

```text
Deferred
```

或：

```text
Future Version
```

---

# 61. Scope Expansion Rule

MVP 阶段持续控制范围。

新增 Required Requirement 会触发：

```text
MVP Scope Update
+
Requirement Matrix Update
+
SPEC Impact
+
Plan Impact
+
Task Expansion
```

不能只在代码里偷偷增加功能。

---

# 62. SPEC Change

SPEC 改动：

```text
SPEC Change
 ↓
Impact Analysis
 ↓
Affected Requirement
 ↓
Affected Task
 ↓
Affected Test
 ↓
Version Update
```

---

# 63. Plan Change

任务结构变化：

```text
Plan Revision
```

例如：

```text
PLAN-r4
 ↓
PLAN-r5
```

同时保留：

```text
Git history
```

和：

```text
Requirement Mapping
```

---

# 64. Iteration Loop

完整的一轮：

```text
ITER-018
    │
    ▼
Read State
    │
    ▼
Select Task
    │
    ▼
Read Applicable Rules
    │
    ▼
Explore Code
    │
    ▼
Implement
    │
    ▼
Test
    │
    ▼
Review
    │
    ▼
Requirement Verify
    │
    ├── FAIL → Fix
    │             ↓
    │          Re-test
    │             ↓
    │          Re-review
    │
    ▼
Commit
    │
    ▼
Update State
    │
    ▼
Checkpoint
    │
    ▼
Expose Evidence
```

---

# 65. Goal Continuation

一轮结束以后：

```text
Requirement Complete?
```

如果还有 Required Requirement：

```text
YES
 ↓
Goal continues
 ↓
Next Task
```

如果全部完成：

```text
NO
 ↓
Final Audit
```

---

# 66. Final Audit

Final Audit 是整个系统的终极验收。

重新读取：

```text
Source Documents
```

对照：

```text
Requirement Matrix
SPEC
Plan
Implementation
Tests
Git History
```

---

# 67. Final Audit Matrix

```text
| Req | Source | SPEC | Task | Code | Test | Review | Runtime | Status |
|-----|--------|------|------|------|------|--------|---------|--------|
| R01 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | VERIFIED |
| R02 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | VERIFIED |
| R03 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | VERIFIED |
```

最终：

```text
Required Requirements = Verified
```

---

# 68. Final Document Audit

检查：

```text
Source
  ↕
Requirement
  ↕
SPEC
  ↕
Implementation
```

确认：

```text
Coverage
Consistency
Completeness
Behavior
```

---

# 69. Audit Failure

例如：

```text
REQ-031
Missing:
Encrypted PDF
```

创建：

```text
TASK-099
```

进入：

```text
Iteration
```

然后：

```text
Implement
 ↓
Test
 ↓
Review
 ↓
Verify
 ↓
Commit
 ↓
Final Audit
```

---

# 70. Build Gate

Final Audit 之后：

```text
Build
```

必须：

```text
PASS
```

---

# 71. Runtime Gate

执行：

```text
Application Start
+
Critical User Flow
```

确认：

```text
PASS
```

例如：

```text
启动
 ↓
登录
 ↓
上传
 ↓
搜索
 ↓
结果
```

---

# 72. Release Gate

最终：

```text
Requirements PASS
+
Acceptance PASS
+
Tests PASS
+
Build PASS
+
Runtime PASS
+
Code Review PASS
+
Final Audit PASS
+
Version Consistent
+
Git State Valid
```

进入：

```text
RELEASE_READY
```

---

# 73. Release

Version：

```text
v1.0.0
```

Changelog：

```text
CHANGELOG.md
```

Tag：

```text
v1.0.0
```

是否：

```text
push
merge
release
```

继续由现有 Git Workflow 与 Repository Policy 决定。

---

# 74. Git Safety

Git Workflow 当前设计：

```text
Policy
 ↓
Facts
 ↓
Agent Resolution
 ↓
Verification
```

并拥有：

```text
P0 Safety
P1 Repository Policy
P2 User Instruction
P3 Skill Policy
P4 Default
```

的层级。

ForgeLoop 不修改这个层级。

---

# 75. Commit Safety

Commit 前：

```text
inspect-repo
 ↓
detect changes
 ↓
scan secrets
 ↓
validate commit
 ↓
commit
 ↓
verify state
```

继续使用现有：

```text
inspect-repo.py
detect-changes.py
validate-commit.py
scan-secrets.py
verify-state.py
```

这些脚本负责事实和验证，Policy Resolution 继续属于 Agent / Policy 层。

---

# 76. Commit Atomicity

一个 Task：

```text
One logical change
```

对应：

```text
One atomic commit
```

或者按照现有 Git Policy 的实际要求进行合理拆分。

核心关系：

```text
Commit
→ Task
→ Requirement
```

---

# 77. Git Working Tree

每轮开始：

```text
git status
git diff
```

建立：

```text
Iteration Baseline
```

每轮结束：

```text
git status
git diff
```

确认：

```text
Expected Changes
```

---

# 78. Commit Message

Commit message 继续服从：

```text
rules/git.md
```

和：

```text
Git Workflow
```

例如：

```text
feat(parser): support encrypted PDF metadata
```

具体格式以仓库规则为准。

---

# 79. Long-Running State

所有长期状态持久化：

```text
docs/status/
```

对话只承担：

```text
Current Reasoning
Current Evidence
Current Task
Current Result
```

文件承担：

```text
Persistent Project State
```

---

# 80. Recommended Project Structure

```text
project/
│
├── src/
├── tests/
│
├── .ai/
│   └── <feature>/
│       ├── tasks.md
│       └── ...
│
├── docs/
│   │
│   ├── source/
│   │
│   ├── mvp/
│   │   ├── mvp-scope.md
│   │   ├── value-proposition.md
│   │   └── excluded-scope.md
│   │
│   ├── requirements/
│   │   ├── source-index.md
│   │   └── requirement-matrix.yaml
│   │
│   ├── spec/
│   │   └── SPEC.md
│   │
│   ├── plan/
│   │   └── implementation-plan.md
│   │
│   ├── status/
│   │   ├── development-status.yaml
│   │   ├── version-state.yaml
│   │   ├── current-iteration.yaml
│   │   └── audit-state.yaml
│   │
│   ├── evidence/
│   │   └── requirement-evidence.yaml
│   │
│   └── review/
│       ├── requirement-review.md
│       ├── spec-review.md
│       ├── iteration-review.md
│       └── final-audit.md
│
├── CHANGELOG.md
└── ...
```

---

# 81. ForgeLoop Skill Structure

你的统一 Harness：

```text
skills/
│
├── forge-loop/
│   ├── SKILL.md
│   └── references/
│       ├── lifecycle.md
│       ├── goal-mode.md
│       ├── mvp.md
│       ├── requirements.md
│       ├── task-lifecycle.md
│       ├── version-control.md
│       ├── evidence.md
│       └── final-audit.md
│
├── mvp/
│   └── ...
│
├── iterative-development/
│   └── ...
│
└── git-workflow/
    └── ...
```

其中：

```text
mvp
    = slavingia

iterative-development
    = aspiers

forge-loop
    = your orchestration layer
```

---

# 82. ForgeLoop Skill 的核心职责

`forge-loop/SKILL.md`：

```text
1. Detect project state
2. Load applicable existing rules
3. Determine current lifecycle phase
4. Use slavingia/mvp for MVP scope
5. Use existing document/spec skills
6. Use existing planning skills
7. Use aspiers iterative-development semantics
8. Execute one task
9. Test
10. Review
11. Verify requirement
12. Commit
13. Update state
14. Continue
15. Final Audit
```

---

# 83. Goal Mode

```text
Active /goal
    ↓
ForgeLoop Goal Mode
```

行为：

```text
One Task
 ↓
Complete
 ↓
Checkpoint
 ↓
Report Evidence
 ↓
Continue
```

---

# 84. Manual Mode

没有 Active Goal：

```text
ForgeLoop Manual Mode
```

行为：

```text
One Task
 ↓
Complete
 ↓
Pause
 ↓
User decides
```

这样保留 `aspiers/iterative-development` 的人工审核价值。

---

# 85. Goal Mode Adapter

核心适配器：

```text
aspiers
    ↓
Single Task
    ↓
Normal pause boundary

ForgeLoop Goal Adapter
    ↓
Single Task
    ↓
Verification
    ↓
Checkpoint
    ↓
Goal Continuation
```

因此 Adapter 改变的是：

```text
continuation policy
```

保持：

```text
task size
verification discipline
task state
```

---

# 86. `/mvp` 的位置

在 ForgeLoop 中：

```text
/goal
  ↓
forge-loop
  ↓
slavingia/mvp
```

`/mvp` 不再是整个开发系统的最外入口。

它是：

```text
MVP Scope Engine
```

---

# 87. `/spec` 的位置

```text
forge-loop
    ↓
Document Reader
    ↓
Requirement Review
    ↓
/spec
```

`/spec` 是：

```text
Specification Engine
```

---

# 88. `/plan` 的位置

```text
forge-loop
    ↓
/plan
    ↓
Task Graph
```

它是：

```text
Planning Engine
```

---

# 89. `iterative-development` 的位置

```text
forge-loop
    ↓
iterative-development
    ↓
One Task
```

它是：

```text
Execution Engine
```

---

# 90. Requirement Verifier 的位置

```text
iterative-development
    ↓
Requirement Verifier
```

它是：

```text
Acceptance Engine
```

---

# 91. Final Auditor 的位置

```text
all requirements verified
    ↓
Final Auditor
```

它是：

```text
Completion Proof Engine
```

---

# 92. Complete System

```text
                      Claude Code
                           │
                          /goal
                           │
                           ▼
                     ┌────────────┐
                     │ ForgeLoop  │
                     └─────┬──────┘
                           │
                           ▼
                    slavingia/mvp
                           │
                           ▼
                    MVP Scope
                           │
                           ▼
                 Document / Requirements
                           │
                           ▼
                     Requirement
                       Review
                           │
                           ▼
                        /spec
                           │
                           ▼
                     SPEC Review
                           │
                           ▼
                       /plan
                           │
                           ▼
                     Task Graph
                           │
                           ▼
            aspiers/iterative-development
                           │
                           ▼
                     One Task
                           │
             ┌─────────────┼─────────────┐
             ▼             ▼             ▼
        Implementation    Test         Review
             │             │             │
             └─────────────┼─────────────┘
                           ▼
                 Requirement Verification
                           │
                           ▼
                         Commit
                           │
                           ▼
                      Checkpoint
                           │
                           ▼
                    Next Iteration
                           │
                           ▼
                   More Requirements?
                      │          │
                     YES        NO
                      │          │
                      └────┐     ▼
                           │ Final Audit
                           │      │
                           │    FAIL
                           │      │
                           └──────┘
                                  │
                                PASS
                                  │
                                  ▼
                             Release Gate
                                  │
                                  ▼
                            Product Version
                                  │
                                  ▼
                             GOAL COMPLETE
```

---

# 93. Final Traceability Model

ForgeLoop 最重要的数据关系：

```text
SOURCE
  ↓
REQ
  ↓
SPEC
  ↓
TASK
  ↓
ITERATION
  ↓
COMMIT
  ↓
TEST
  ↓
REVIEW
  ↓
EVIDENCE
  ↓
VERIFIED
```

这条链必须保持完整。

---

# 94. Final Completion Model

```text
Document Complete
       =
All Required Requirements Verified
       +
All Acceptance Criteria Passed
       +
Tests Passed
       +
Code Review Passed
       +
Build Passed
       +
Runtime Passed
       +
Final Audit Passed
       +
Version Consistent
       +
Git State Valid
```

---

# 95. Example

假设原始需求：

```text
支持 PDF 上传
支持 Word 上传
支持搜索
支持删除
```

MVP：

```text
PDF Upload
Word Upload
Search
```

Delete：

```text
Deferred
```

SPEC：

```text
REQ-001 PDF
REQ-002 Word
REQ-003 Search
```

Plan：

```text
TASK-001 PDF Upload
TASK-002 Word Upload
TASK-003 Search API
TASK-004 Search UI
```

Iteration：

```text
ITER-001
TASK-001
```

完成：

```text
Test PASS
Review PASS
REQ-001 VERIFIED
Commit A
```

下一轮：

```text
ITER-002
TASK-002
```

最终：

```text
REQ-001 VERIFIED
REQ-002 VERIFIED
REQ-003 VERIFIED
```

然后：

```text
Final Audit
```

审计发现：

```text
REQ-003 的中文搜索没有覆盖
```

创建：

```text
TASK-005
```

继续：

```text
ITER-004
```

直到：

```text
Final Audit PASS
```

然后：

```text
v1.0.0
```

---

# 96. Failure Loop

ForgeLoop 所有失败最终进入统一修复路径：

```text
Test Failure
    ↓
Fix Task
    ↓
Iteration

Review Failure
    ↓
Fix Task
    ↓
Iteration

Requirement Failure
    ↓
Fix Task
    ↓
Iteration

Final Audit Failure
    ↓
Remediation Task
    ↓
Iteration
```

所以系统始终拥有一个统一工作单元：

```text
Task
```

---

# 97. Impossible / Blocked

出现：

```text
外部服务不可用
缺少凭证
无法访问依赖
需求矛盾
平台权限不足
```

进入：

```text
BLOCKED
```

状态。

报告：

```text
Requirement
Blocker
Evidence
Required Action
```

高优先级规则与安全边界继续由现有 Rules / Git Workflow 决定。

---

# 98. Goal Resume

Goal 被中断以后：

```text
Resume
 ↓
Read development-status.yaml
 ↓
Read version-state.yaml
 ↓
Read tasks.md
 ↓
Read Git state
 ↓
Find current incomplete task
 ↓
Continue
```

核心状态都已经持久化。

---

# 99. Compact Resume

Context compact：

```text
Conversation
    ↓
Compact
    ↓
Project Files
    ↓
State Restore
```

ForgeLoop 不把：

```text
Current Task
Current Requirement
Current Version
Current Checkpoint
```

只放在上下文里。

---

# 100. Long-Horizon Safety

长周期运行的安全边界：

```text
No silent scope expansion
No silent requirement deletion
No unverified completion
No untracked code changes
No unknown Git history rewrite
No undocumented version bump
```

这些约束分别落到：

```text
MVP
Requirement Matrix
Verification
Git Workflow
Rules
```

---

# 101. Minimal Modification

ForgeLoop 与现有 Global Agent Contract 保持：

```text
Read before write
Smallest valid change
Preserve existing code
Task-scoped changes
```

因此每个迭代都是：

```text
最小实现
+
完整验证
```

---

# 102. Completion Report

最终由 Claude 输出：

```text
ForgeLoop Complete

Goal:
GOAL-001

MVP:
0.1

SPEC:
1.0.0

Requirements:
42 / 42 VERIFIED

Acceptance:
42 / 42 PASS

Tasks:
96 / 96 COMPLETE

Tests:
PASS

Build:
PASS

Runtime:
PASS

Code Review:
PASS

Final Document Audit:
PASS

Git:
CLEAN

Version:
1.0.0

HEAD:
a82c91f
```

Goal evaluator 根据当前对话中的完成证据判断 Goal 是否满足。Claude Code 官方的 Goal 机制因此与这种“每轮输出证据”的工作流天然适配。([code.claude.com](https://code.claude.com/docs/en/goal))

---

# 103. Installation / Upstream Management

两个外部 Skill 继续作为上游依赖：

```text
slavingia/mvp
aspiers/iterative-development
```

ForgeLoop 不直接把它们揉成一份巨型 SKILL.md。

推荐：

```text
upstream skill
       ↓
installed skill
       ↓
ForgeLoop adapter
```

尤其对 `aspiers/iterative-development`：

```text
upstream
    ↓
保持原始版本
    ↓
ForgeLoop Goal Adapter
```

这样以后升级上游时：

```text
upstream update
    ↓
compatibility check
    ↓
adapter verification
```

不会导致整个 ForgeLoop 工作流失控。

---

# 104. Provenance

现有 Harness 已经要求安装 Skill 时记录 provenance，并把用户自己的配置仓库作为统一 Source of Truth。

因此建议：

```text
docs/skills-provenance.md
```

记录：

```text
slavingia/mvp
Source:
https://github.com/slavingia/skills

aspiers/iterative-development
Source:
<your installed upstream source>

ForgeLoop
Owner:
User Harness
```

---

# 105. ForgeLoop References

推荐：

```text
forge-loop/
├── SKILL.md
└── references/
    ├── architecture.md
    ├── lifecycle.md
    ├── mvp-integration.md
    ├── iterative-integration.md
    ├── requirement-model.md
    ├── task-model.md
    ├── goal-mode.md
    ├── version-control.md
    ├── evidence-model.md
    ├── audit-model.md
    └── recovery.md
```

`SKILL.md` 只做：

```text
Routing
Core Rules
Workflow
Reference Loading
Output Contract
```

具体细节放 references。

这样也符合你现有 Git Workflow 的渐进披露思路：主 Skill 做路由，具体规则放 reference。

---

# 106. ForgeLoop State Contract

ForgeLoop 识别以下状态：

```text
PROJECT_INIT
DISCOVERY
MVP_DEFINITION
REQUIREMENT_EXTRACTION
REQUIREMENT_REVIEW
SPECIFICATION
SPEC_REVIEW
PLANNING
ITERATIVE_DEVELOPMENT
FINAL_AUDIT
RELEASE_READY
COMPLETE
BLOCKED
```

---

# 107. Lifecycle Transition

```text
PROJECT_INIT
    ↓
DISCOVERY
    ↓
MVP_DEFINITION
    ↓
REQUIREMENT_EXTRACTION
    ↓
REQUIREMENT_REVIEW
    ↓
SPECIFICATION
    ↓
SPEC_REVIEW
    ↓
PLANNING
    ↓
ITERATIVE_DEVELOPMENT
    ↓
FINAL_AUDIT
    ↓
RELEASE_READY
    ↓
COMPLETE
```

失败统一回：

```text
ITERATIVE_DEVELOPMENT
```

需要重新定义范围或 SPEC 时：

```text
MVP_DEFINITION
```

或：

```text
SPECIFICATION
```

---

# 108. Core Invariants

ForgeLoop 实现必须保持：

```text
I-001
Every Required Requirement has an ID.

I-002
Every Required Requirement has acceptance criteria.

I-003
Every Task maps to a Requirement or explicit engineering objective.

I-004
Every completed Task has verification evidence.

I-005
Every meaningful implementation has a Git record.

I-006
Verified Requirement changes become stale and require re-verification.

I-007
Final Audit compares implementation against source requirements.

I-008
Goal cannot be complete while Required Requirements remain unverified.

I-009
Git Policy comes from existing Git Workflow.

I-010
Safety comes from existing Rules.
```

---

# 109. Acceptance Criteria for ForgeLoop Itself

ForgeLoop 完成以后必须能够证明：

```text
A. 能读取文档
B. 能建立 Requirement
C. 能执行 MVP Scope
D. 能生成 SPEC
E. 能生成 Plan
F. 能执行单 Task Iteration
G. 能测试
H. 能 Review
I. 能验证 Requirement
J. 能形成 Git Checkpoint
K. 能恢复中断状态
L. 能执行 Final Audit
M. 能继续修复 Audit Findings
N. 能进入 Release
```

---

# 110. Final Architecture Decision

最终架构固定为：

```text
Claude Code /goal
        │
        ▼
ForgeLoop
        │
        ├── slavingia/mvp
        │       │
        │       └── MVP Scope
        │
        ├── Existing Document / Spec Skills
        │       │
        │       └── Requirement + SPEC
        │
        ├── Existing Planning Skills
        │       │
        │       └── Plan + Task Graph
        │
        ├── aspiers/iterative-development
        │       │
        │       └── One Task at a Time
        │
        ├── Existing Agents
        │       ├── code-explorer
        │       ├── code-architect
        │       └── code-reviewer
        │
        ├── Existing Rules
        │       ├── git
        │       ├── filesystem
        │       ├── testing
        │       └── security
        │
        └── Existing Git Workflow
                │
                ├── Branch
                ├── Commit
                ├── Version
                ├── Tag
                └── Release
```

---

# 111. 最终运行模型

用户只需要启动：

```text
/goal
完成当前项目 MVP Scope 中规定的全部 Required 功能，并通过所有验收标准。
```

然后：

```text
ForgeLoop
    ↓
MVP
    ↓
Requirements
    ↓
SPEC
    ↓
PLAN
    ↓
Task 1
    ↓
Implement
    ↓
Test
    ↓
Review
    ↓
Verify
    ↓
Commit
    ↓
Checkpoint
    ↓
Task 2
    ↓
...
    ↓
Task N
    ↓
Final Audit
    ↓
修复发现的问题
    ↓
再次 Audit
    ↓
Release
    ↓
Goal Complete
```

---

# 112. 核心定位

最终四个核心组件的职责保持非常清晰：

```text
┌────────────────────────────┐
│ Claude Code /goal          │
│                            │
│ “一直做到完成”              │
└─────────────┬──────────────┘
              │
┌─────────────▼──────────────┐
│ slavingia/mvp              │
│                            │
│ “这一版做什么”               │
└─────────────┬──────────────┘
              │
┌─────────────▼──────────────┐
│ SPEC / PLAN                │
│                            │
│ “必须做到什么、拆成什么”      │
└─────────────┬──────────────┘
              │
┌─────────────▼──────────────┐
│ aspiers/iterative-dev      │
│                            │
│ “一次做一个 Task”            │
└─────────────┬──────────────┘
              │
       Test / Review / Verify
              │
              ▼
          Git / Version
              │
              ▼
         Final Document Audit
              │
              ▼
          Goal Complete
```

---

# 113. Final Recommendation

ForgeLoop 的正式职责应该定义为：

> **ForgeLoop 是 Claude Code 的 Goal-driven 项目级开发编排器。它使用 `slavingia/mvp` 控制产品范围，使用现有 Spec/Plan 能力建立实现契约，使用 `aspiers/iterative-development` 执行“一次一个 Task”的增量开发，通过测试、代码审核和 Requirement Verification 建立完成证据，通过现有 Git Workflow 形成版本历史，并在最终 Document Audit 通过前持续迭代。**

最终你得到的是：

```text
/goal
  ↓
ForgeLoop
  ↓
MVP
  ↓
SPEC
  ↓
PLAN
  ↓
ONE TASK
  ↓
IMPLEMENT
  ↓
TEST
  ↓
REVIEW
  ↓
VERIFY
  ↓
COMMIT
  ↓
CHECKPOINT
  ↓
NEXT TASK
  ↓
...
  ↓
ALL REQUIREMENTS VERIFIED
  ↓
FINAL DOCUMENT AUDIT
  ↓
RELEASE
  ↓
GOAL COMPLETE
```

**建议正式仓库名就使用 `forge-loop`，Skill 名使用 `forge-loop`，产品级描述使用 `ForgeLoop — Goal-Driven Iterative Product Engineering`。保留 `slavingia/mvp` 与 `aspiers/iterative-development` 为上游能力，ForgeLoop 负责把它们和你现有的 `agents / commands / rules / Git Workflow` 组合成一套真正能从文档一路跑到完成版本的工程闭环。**