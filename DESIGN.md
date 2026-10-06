# ForgeLoop.DESIGN.md

## Goal-Driven MVP Iterative Engineering

**Version:** 1.0.0  
**Status:** Design  
**Target:** Claude Code  
**Core:** `/goal` + `slavingia/mvp` + `aspiers/iterative-development`  
**Integration:** Existing Agents / Commands / Skills / Rules / Git Workflow

---

# 1. Purpose

ForgeLoop 是一套面向 Claude Code 的**长周期、目标驱动、迭代式软件工程工作流**。

ForgeLoop 的职责是把一个高层开发目标持续转换为可执行、可验证、可恢复的工程活动，并持续工作直到目标满足定义的完成条件。

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
...
 ↓
Final Audit
 ↓
Release
 ↓
Goal Complete
```

ForgeLoop 本身**不预先设计具体项目的详细实现方案**。

具体项目的：

```text
Requirement
SPEC
Architecture
API
Data Model
Implementation Plan
Task Breakdown
Test Plan
```

由 Claude Code 根据当前项目实际情况，在 ForgeLoop 流程中动态产生、审核和维护。

---

# 2. Core Philosophy

ForgeLoop 将软件开发划分为几个职责明确的层：

```text
Goal
    决定最终目标以及什么时候停止

MVP
    决定当前版本应该实现什么

Requirement
    决定必须满足什么需求

SPEC
    决定需求对应的技术行为与约束

PLAN
    决定如何拆解实现工作

Iteration
    决定当前这一轮具体完成哪个 Task

Verification
    决定任务和需求是否真正完成

Git Workflow
    决定如何形成可靠版本历史

Final Audit
    决定整个目标是否真正兑现
```

ForgeLoop 的核心思想：

```text
明确目标
→ 控制范围
→ 建立开发契约
→ 拆成可执行任务
→ 一次完成一个任务
→ 用证据验证
→ 建立版本检查点
→ 持续推进
→ 最终审计
```

---

# 3. Responsibility Boundary

ForgeLoop 是：

```text
Orchestrator
```

而不是所有能力的实现者。

## ForgeLoop 负责

```text
Workflow orchestration
Lifecycle control
Task progression
State persistence
Verification gates
Checkpoint control
Recovery
Final audit
```

## 上游 / 下游能力负责

```text
slavingia/mvp
    → MVP Scope

Existing document / specification skills
    → Requirement / SPEC

Existing planning skills
    → PLAN / Task

aspiers/iterative-development
    → One Task Iteration

Existing Agents
    → 专业执行

Existing Rules
    → 行为治理

Existing Git Workflow
    → Git / Version Control
```

ForgeLoop 将这些能力组织起来形成完整开发闭环。

---

# 4. `/goal` Boundary

Claude Code `/goal` 是长周期目标控制入口。

其职责是：

```text
WHEN TO STOP
```

ForgeLoop 的职责是：

```text
HOW TO WORK
```

因此：

```text
/goal
    ↓
ForgeLoop
    ↓
持续执行
    ↓
满足 Completion Criteria
```

ForgeLoop 不替代 Claude Code 的 Goal 机制。

ForgeLoop 为 Goal 提供：

```text
MVP
Requirement
SPEC
PLAN
Task
Iteration
Verification
Evidence
Checkpoint
Final Audit
```

等完成所需的工程状态与证据。

---

# 5. Goal Completion

一个 Goal 的完成必须具有明确的 Completion Contract。

典型完成条件：

```text
MVP Scope 已确定
AND
Required Requirements 已建立
AND
Required Requirements 已实现
AND
Acceptance Criteria 已通过
AND
必要测试已通过
AND
必要 Code Review 已通过
AND
Final Audit 已通过
AND
Git / Version State 有效
```

核心终态：

```text
ALL_REQUIRED_VERIFIED
+
ALL_ACCEPTANCE_PASS
+
FINAL_AUDIT_PASS
+
VERSION_VALID
```

达到终态后：

```text
Goal → Complete
```

---

# 6. MVP Integration

ForgeLoop 使用：

```text
slavingia/mvp
```

作为 MVP 范围控制能力。

ForgeLoop 将 Goal 转换为：

```text
Core Value
↓
MVP Scope
↓
Required
↓
Deferred / Out-of-Scope
```

MVP 的职责是控制范围。

ForgeLoop 不允许在长期开发过程中无控制地增加功能。

新增功能必须经过：

```text
Scope Decision
```

必要时重新影响：

```text
Requirement
SPEC
PLAN
Task
Verification
```

---

# 7. Requirement → SPEC → PLAN

ForgeLoop 使用三层工程契约：

```text
Requirement
    ↓
SPEC
    ↓
PLAN
```

### Requirement

描述：

```text
需要实现什么
```

### SPEC

描述：

```text
系统必须满足什么行为与技术约束
```

### PLAN

描述：

```text
如何拆解成可执行工作
```

ForgeLoop 不要求固定某一种 SPEC、PLAN 模板。

具体格式由：

```text
现有 Skills
+
项目特点
+
现有 Harness
```

共同决定。

ForgeLoop 只要求三者之间保持可追踪关系。

---

# 8. Iterative Development

ForgeLoop 使用：

```text
aspiers/iterative-development
```

作为 Task-level execution model。

核心规则：

```text
ONE TASK
```

一个 Iteration 的基本循环：

```text
Select Task
 ↓
Read Context
 ↓
Explore
 ↓
Implement
 ↓
Test
 ↓
Review
 ↓
Requirement Verify
 ↓
Checkpoint
```

然后：

```text
Next Task
```

ForgeLoop 不把 Iterative Development 改造成一次性批量编码。

---

# 9. Verification

ForgeLoop 使用三层验证：

```text
Test
Code Review
Requirement Verification
```

分别回答：

```text
Test
→ 代码运行是否正确？

Code Review
→ 实现质量是否合格？

Requirement Verification
→ 用户要求是否真正实现？
```

三者具有不同职责。

最终完成判断不能仅依赖：

```text
代码存在
```

或：

```text
测试通过
```

必须能够回溯到：

```text
Requirement
→ Acceptance Criteria
→ Implementation
→ Evidence
```

---

# 10. Git Integration

ForgeLoop 与现有 Git Workflow 集成。

ForgeLoop 不建立独立 Git Policy。

Git 行为继续由：

```text
AGENTS.md
+
rules/
+
Git Workflow
```

决定。

ForgeLoop 负责在适当的位置调用 Git Workflow：

```text
Task Complete
 ↓
Verification
 ↓
Git Workflow
 ↓
Commit / Checkpoint
```

Git Checkpoint 是 ForgeLoop 长周期运行的重要恢复边界。

---

# 11. Traceability

ForgeLoop 要求关键开发对象保持可追踪关系：

```text
Source
 ↓
Requirement
 ↓
SPEC
 ↓
Task
 ↓
Iteration
 ↓
Commit
 ↓
Test / Review
 ↓
Evidence
 ↓
Verification
```

ForgeLoop 不要求所有对象都使用统一文件格式。

ForgeLoop 要求：

```text
关系存在
ID 稳定
可以追踪
可以验证
```

当上游 Requirement 或 SPEC 发生语义变化时，相关实现和验证结果必须重新评估。

---

# 12. Persistent State

ForgeLoop 是长周期工作流，因此状态必须持久化。

状态至少包括：

```text
Current Goal
Current Phase
Current Task
Current Iteration
Last Checkpoint
Blockers
Verification State
```

状态用于：

```text
Resume
Recovery
Audit
Progress
```

对话上下文不是唯一状态来源。

项目文件与 Git 才是长期恢复基础设施。

---

# 13. Recovery

ForgeLoop 必须支持：

```text
Claude Code restart
Session interruption
Context compaction
Agent failure
Test failure
Partial implementation
```

恢复时：

```text
Load State
 ↓
Load Current Task
 ↓
Load Current Iteration
 ↓
Inspect Git
 ↓
Inspect Checkpoint
 ↓
Reconcile
 ↓
Resume
```

ForgeLoop 不允许在无法确定当前工程状态时静默继续。

---

# 14. Final Audit

所有 Required Task 完成以后，ForgeLoop 进入：

```text
Final Audit
```

Final Audit 回到最初目标和项目开发文档，检查：

```text
Goal
MVP
Requirement
SPEC
Implementation
Tests
Reviews
Evidence
Git
```

确保最终实现真正兑现当前目标。

审计发现缺失时：

```text
Audit Finding
 ↓
Task
 ↓
Iteration
 ↓
Verification
 ↓
Audit Again
```

因此 Final Audit 本身也可以重新进入 Iteration Loop。

---

# 15. Workspace Namespace Rule

ForgeLoop 采用统一的双命名空间规则：

```text
dev-* / .dev-*
    = 当前被开发项目

无 dev- / .*
    = ForgeLoop 本身
```

这是 ForgeLoop 的项目开发规则，而不是具体项目的详细设计。

---

# 16. Documentation Namespace

当前被开发项目的开发资料：

```text
dev-doc/
```

ForgeLoop 本身的开发资料：

```text
doc/
```

因此：

```text
dev-doc/
    = Product Development Documentation

doc/
    = ForgeLoop Documentation
```

项目中的具体：

```text
Requirement
SPEC
Architecture
Plan
Review
Audit
Design
```

根据实际需要由 Claude Code 创建到：

```text
dev-doc/
```

ForgeLoop 自身开发这些内容时使用：

```text
doc/
```

ForgeLoop 不要求当前项目提前建立固定文档树。

---

# 17. Runtime Namespace

当前项目的 AI / 开发运行状态：

```text
.dev-ai/
```

ForgeLoop 自身运行状态：

```text
.ai/
```

因此：

```text
.dev-ai/
    = Current Project Runtime

.ai/
    = ForgeLoop Runtime
```

典型状态：

```text
Task
Iteration
Checkpoint
Session
Execution State
Evidence State
Recovery State
```

由对应 Runtime Namespace 管理。

---

# 18. General `dev-*` Convention

命名空间规则不仅适用于 `doc`。

凡属于当前项目的 ForgeLoop 管理资产，原则上使用：

```text
dev-<name>
```

ForgeLoop 自身对应资源保持：

```text
<name>
```

例如：

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

隐藏运行目录遵循：

```text
.dev-<name>    ↔ .<name>
```

例如：

```text
.dev-ai/       ↔ .ai/
.dev-cache/    ↔ .cache/
.dev-work/     ↔ .work/
```

---

# 19. Namespace Ownership

创建任何 ForgeLoop 管理资产之前，必须确定 Owner：

```text
CURRENT_PROJECT
```

或者：

```text
FORGELOOP
```

然后应用：

```text
CURRENT_PROJECT
    → dev-* / .dev-*

FORGELOOP
    → * / .*
```

例如：

```text
当前项目的 Requirement
→ dev-doc/

当前项目的 Task State
→ .dev-ai/

ForgeLoop 的设计文档
→ doc/

ForgeLoop 自身 Task State
→ .ai/
```

---

# 20. Source Code Boundary

`dev-*` 主要用于 ForgeLoop 管理的开发资产。

项目源码不强制改名：

```text
src/
app/
server/
client/
packages/
tests/
```

仍由当前项目自己的正常结构决定。

例如：

```text
src/
tests/

dev-doc/
dev-scripts/
.dev-ai/
```

这是合法且推荐的组合。

---

# 21. Existing Harness Integration

ForgeLoop 建立在已有 Agent Harness 之上：

```text
AGENTS.md
    ↓
Rules
    ↓
Agents / Commands / Skills
    ↓
ForgeLoop
```

ForgeLoop 不重复实现已有能力。

### AGENTS.md

负责：

```text
Global Agent Contract
```

### Rules

负责：

```text
Git
Filesystem
Testing
Security
其他治理约束
```

### Agents

负责：

```text
专业分析与执行
```

### Commands

负责：

```text
显式用户入口
```

### Skills

负责：

```text
可复用能力
```

ForgeLoop：

```text
负责 orchestration
```

---

# 22. Existing Agent Integration

已有 Agent 可以直接作为 ForgeLoop Worker。

例如：

```text
code-explorer
code-architect
code-reviewer
```

ForgeLoop 决定：

```text
什么时候调用
为什么调用
结果进入哪个阶段
结果是否满足 Gate
```

Agent 不自行篡改 ForgeLoop 全局生命周期。

---

# 23. Existing Skill Integration

已有 Skill 继续作为能力组件。

例如：

```text
slavingia/mvp
aspiers/iterative-development
create-specification
create-implementation-plan
breakdown-plan
```

ForgeLoop 不复制这些 Skill 的实现。

采用：

```text
Skill = Capability
ForgeLoop = Orchestration
```

---

# 24. Document Design Policy

ForgeLoop 不预先规定当前项目应该有哪些详细设计文档。

Claude Code 根据当前项目实际情况决定：

```text
需要什么文档
文档如何组织
哪些内容需要 SPEC
哪些内容需要 Architecture
哪些内容需要 API Design
哪些内容需要 Test Plan
```

ForgeLoop 只规定：

```text
这些文档必须被正确归属
必须能够参与工作流
关键结果必须可追踪
```

因此：

```text
ForgeLoop 定规则
Claude Code 做具体设计
```

---

# 25. No Fixed Project Design

ForgeLoop 不假设当前项目一定具有：

```text
Web
Backend
Frontend
Mobile
AI
Database
Microservice
```

等固定结构。

ForgeLoop 只规定开发生命周期。

具体项目结构完全由：

```text
Current Repository
+
Project Documents
+
Requirements
+
Architecture
```

决定。

---

# 26. Scope Change

开发过程中如果出现新的需求：

```text
New Requirement
 ↓
Scope Decision
 ↓
Impact Analysis
```

必要时更新：

```text
MVP
Requirement
SPEC
PLAN
Task
```

然后继续 Iteration。

禁止通过直接修改代码的方式绕过 Scope / Requirement 管理。

---

# 27. Failure Model

ForgeLoop 将开发失败统一收敛为可恢复状态。

例如：

```text
Test Failure
Review Failure
Requirement Failure
Audit Failure
```

都进入：

```text
Repair
 ↓
Re-test
 ↓
Re-review
 ↓
Re-verify
```

架构或需求发生重大变化时：

```text
Replan
```

无法安全继续时：

```text
Blocked
```

---

# 28. Completion Invariants

ForgeLoop 的核心不变量：

```text
Every Required Requirement has an identity.

Every Required Requirement is traceable.

Every completed Task has verification evidence.

Every completed Iteration has a checkpoint or equivalent Git record.

Requirement changes can invalidate previous verification.

Goal completion requires final verification.

Final Audit can create new work.

Git behavior follows existing Git Workflow.

Workspace ownership follows dev-* namespace rules.
```

---

# 29. Core State Flow

ForgeLoop 的标准工作流：

```text
DISCOVERY
 ↓
MVP
 ↓
REQUIREMENTS
 ↓
SPEC
 ↓
PLAN
 ↓
ITERATION LOOP
 ↓
FINAL AUDIT
 ↓
RELEASE
 ↓
GOAL COMPLETE
```

Iteration Loop：

```text
SELECT
 ↓
IMPLEMENT
 ↓
TEST
 ↓
REVIEW
 ↓
VERIFY
 ↓
CHECKPOINT
 ↓
NEXT
```

---

# 30. Goal-Mode / Manual-Mode

ForgeLoop 支持两种运行方式。

## Goal Mode

存在 Active `/goal`：

```text
Task Complete
 ↓
Checkpoint
 ↓
Next Task
```

持续运行直到：

```text
Goal Complete
```

## Manual Mode

没有 Active Goal：

```text
Task Complete
 ↓
Checkpoint
 ↓
Pause
```

保留人工控制能力。

---

# 31. Design Boundary

ForgeLoop Design 只定义：

```text
Architecture
Lifecycle
Responsibilities
Integration
State Semantics
Verification Semantics
Workspace Rules
Namespace Rules
Completion Rules
```

ForgeLoop Design 不定义当前产品的：

```text
具体业务需求
具体页面
具体 API
具体数据库
具体模块实现
具体技术选型
具体 Task
```

这些属于当前项目，由 Claude Code 在运行过程中产生。

---

# 32. Final Model

ForgeLoop 的完整职责模型：

```text
                    USER
                     │
                     ▼
                  /goal
                     │
                     ▼
                ForgeLoop
                     │
        ┌────────────┼────────────┐
        ▼            ▼            ▼
       MVP       Requirement     State
        │            │
        └──────┬─────┘
               ▼
              SPEC
               │
               ▼
              PLAN
               │
               ▼
        Iterative Development
               │
               ▼
            ONE TASK
               │
        ┌──────┼──────┐
        ▼      ▼      ▼
      Code    Test   Review
        │      │      │
        └──────┼──────┘
               ▼
      Requirement Verify
               │
               ▼
           Checkpoint
               │
               ▼
          Next Task
               │
              ...
               │
               ▼
          Final Audit
               │
         ┌─────┴─────┐
         ▼           ▼
       FAIL         PASS
         │           │
         ▼           ▼
       Task       Release
         │           │
         └──→        ▼
               Goal Complete
```

---

# 33. Final Principle

ForgeLoop 的核心可以概括为：

```text
Goal defines the destination.
MVP controls the scope.
Requirement defines what is required.
SPEC defines the engineering contract.
PLAN defines the work.
Iteration executes one task.
Verification proves completion.
Git preserves the history.
State enables recovery.
Audit proves the goal was fulfilled.
```

ForgeLoop 本身只负责建立并执行这套工程闭环。

**具体项目怎么设计，由 Claude Code 在这个闭环中完成。**