# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 仓库当前状态

本仓库目前只有设计与治理层，没有实现代码。

```text
DESIGN.md                  系统设计（113 节，权威依据）
AGENTS.md                  项目级 Agent 契约（16 节）
CONTRIBUTING.md            贡献流程
rules/                     7 份项目规则
  forge-loop-development.md   自身开发流程与完成条件
  git-integration.md         Git 接入（不建第二套 Git Policy）
  state-and-recovery.md      状态持久化与恢复
  version-management.md      版本管理接入
  workspace-namespace.md     Owner 与命名空间归属
  artifact-persistence.md    工程产物落盘（强制）
  domestic-mirror.md         拉取模型/依赖优先使用国内镜像
doc/                       4 份开发文档
  DEVELOPMENT.md / PROJECT-CONSTRAINTS.md / WORKSPACE-NAMESPACE.md
  INITIAL-DELIVERY.md        初始一次性交付稿，内容已拆分进上述文件
src/  tests/  .ai/         空目录（git 不跟踪空目录，clone 后不存在）
```

没有构建、测试、lint 工具链，`src/` 与 `tests/` 为空。首次引入工具链时，由实际 Task 决定栈，并把命令写回本文件。

## 权威顺序

```text
Global Rules（~/.claude/rules/）
    ↓
ForgeLoop 项目规则（AGENTS.md + rules/）
    ↓
Task Instructions
```

冲突时 Global Rule wins（`AGENTS.md` §2）。版本管理、Git、Repository、Release、Security 一律服从全局规则，本项目不建第二套体系。

设计表述以 `DESIGN.md` 为唯一权威（`AGENTS.md` §5「Design Is The Single Authority」）：术语、生命周期顺序、Gate 名称、状态名、ID 格式、Checkpoint 字段一律回查 DESIGN.md 原始定义；其他文件只做索引，引用必须指向节号；与 DESIGN.md 冲突时 DESIGN.md wins，修正引用方而非反向修改 DESIGN.md。修改 DESIGN.md 本身需要用户明确指示。

## 核心设计表述

以下表述与 `DESIGN.md` 对应章节一致。CLAUDE.md 只做索引，具体判据一律回查 `DESIGN.md` 节号。

### 生命周期

`DESIGN.md` §106–§107 状态机：

```text
PROJECT_INIT → DISCOVERY → MVP_DEFINITION → REQUIREMENT_EXTRACTION
→ REQUIREMENT_REVIEW → SPECIFICATION → SPEC_REVIEW → PLANNING
→ ITERATIVE_DEVELOPMENT → FINAL_AUDIT → RELEASE_READY → COMPLETE
```

失败统一回 `ITERATIVE_DEVELOPMENT`；需要重定范围或 SPEC 时回 `MVP_DEFINITION` 或 `SPECIFICATION`。另有终态 `BLOCKED`（§97）。

### Iteration Loop

`DESIGN.md` §64 完整一轮：

```text
Read State → Select Task → Read Applicable Rules → Explore Code
→ Implement → Test → Review → Requirement Verify
→ Commit → Update State → Checkpoint → Expose Evidence
```

Requirement Verify 失败走 `Fix → Re-test → Re-review`（§64 FAIL 分支、§96 Failure Loop），无法安全继续时进 `BLOCKED`（§97）。

### One-Task Rule

`DESIGN.md` §30、§32：每个 Goal Turn 的主目标是 **ONE PRIMARY TASK**，允许同一轮内包含 Implementation、Tests、必要文档更新、必要状态更新。§32 禁止把无关功能塞进同一轮。

`DESIGN.md` §31 Task Selection Policy 取件顺序：

```text
1. Blocker
2. Required Requirement
3. Dependency prerequisite
4. High-risk Task
5. Small verifiable Task
```

Task 原则（§31）：`Small / Atomic / Verifiable / Traceable`。

### Goal Mode 与 Manual Mode

`DESIGN.md` §83–§84：

```text
Goal Mode（存在 Active /goal）
One Task → Complete → Checkpoint → Report Evidence → Continue

Manual Mode（无 Active Goal）
One Task → Complete → Pause → User decides
```

Manual Mode 保留人工审核价值。

### 三层 Gate

`DESIGN.md` §36–§38 分别由 Test / Code Review / Requirement Verification 承担，职责不重叠：

| Gate | 回答的问题 | 章节 |
| :--- | :--- | :--- |
| Test Gate | 代码运行是否正确 | §36 |
| Code Review Gate | 实现质量是否合格（`code-reviewer` 审 Correctness / Architecture / Security / Regression / Maintainability / Scope） | §37 |
| Requirement Verification Gate | 用户要求是否真正实现 | §38 |

发布前另需通过 Build Gate（§70）、Runtime Gate（§71）、Release Gate（§72）。

### Evidence

`DESIGN.md` §39：每个 Requirement 保存 `source` / `spec` / `task` / `implementation` / `tests` / `review` / `runtime` / `acceptance` 关联，最终 `status: verified`。Code Review 存在 Finding 时走 `Fix → Test → Review Again`（§37）。

Requirement 或 SPEC 语义变化时，既有 evidence 失效，必须重新验证（§59 Evidence Invalidation、§62 SPEC Change、§63 Plan Change）。

### Checkpoint

`DESIGN.md` §53：每轮 `ITERATION COMPLETE` 生成 Checkpoint，内容含 `goal.id` / `iteration.id` / `task.id` / `git.commit` / `spec.version` / `progress.requirements`。用途是 Resume / Audit / Rollback / Progress Tracking / Version Comparison（§54）。

Checkpoint 通过全局 Git Workflow 形成，本项目不定义 branch / commit / merge / tag / push 策略。

### 状态持久化与恢复

作用域分两层，不要混用：

| 作用域 | 位置 | 依据 |
| :--- | :--- | :--- |
| ForgeLoop 自身运行状态 | `.ai/` | `AGENTS.md` §12、`rules/state-and-recovery.md`、`rules/artifact-persistence.md` §6、`DESIGN.md` §79 |
| 被开发项目的长期状态 | `.dev-ai/`（`version-state.yaml`、`development-status.yaml`、`audit-state.yaml`、`<feature>/tasks.md`） | `DESIGN.md` §28、§55–§57、§79–§80 |
| 被开发项目的 ForgeLoop 文档 | `dev-doc/`（`requirements/`、`spec/`、`plan/`、`mvp/`、`evidence/`、`review/`） | `DESIGN.md` §17–§18、§22、§80、`rules/artifact-persistence.md` §5 |

恢复流程：`Load State → Inspect Current Task → Inspect Workspace → Inspect Git → Inspect Checkpoint → Reconile → Resume`（`DESIGN.md` §98–§99、`rules/state-and-recovery.md` §4）。运行时状态与 Git 状态不一致时停止自动推进，先做 Reconciliation（`rules/state-and-recovery.md` §5）。

### 最终验收

`DESIGN.md` §66–§69 Final Audit 重新读取 Source Documents，对照 Requirement Matrix / SPEC / Plan / Implementation / Tests / Git History，以 §67 Final Audit Matrix 逐条核对。Audit 失败回到 Iteration Loop 修复（§69），通过后进入 §73 Release。

### 核心不变量

`DESIGN.md` §108：

```text
I-001  Every Required Requirement has an ID.
I-002  Every Required Requirement has acceptance criteria.
I-003  Every Task maps to a Requirement or explicit engineering objective.
I-004  Every completed Task has verification evidence.
I-005  Every meaningful implementation has a Git record.
I-006  Verified Requirement changes become stale and require re-verification.
I-007  Final Audit compares implementation against source requirements.
I-008  Goal cannot be complete while Required Requirements remain unverified.
I-009  Git Policy comes from existing Git Workflow.
I-010  Safety comes from existing Rules.
```

## 文档必须落盘

`rules/artifact-persistence.md` 是强制的。核心是 `Conversation = Temporary Working Context`，`Filesystem = Durable Project Knowledge`，`.ai/ = Durable Workflow State`，`Git = Durable Version History`。

- Goal / MVP Scope / Requirement / Acceptance Criteria / SPEC / Plan / Task 定义 / Test Result / Review / Verification / Audit / Decision / Release 信息等，一旦形成正式结果就写入文件。对话里生成了 SPEC 不等于 SPEC 已完成，流程是 `Generate → Write to File → Verify File Exists → Continue Workflow`。
- 阶段推进前，当前阶段的产物必须已落盘（Phase Gate，§9）。
- 写入后确认 `File Exists + Content Is Complete + Correct Path + Correct Owner`，不能只调了写文件动作就假定成功。
- 已有文档发生实质变化时 `Read → Modify → Write Back → Verify`，不能只在对话里说「我们把设计改成了……」。
- 阶段完成的判据是 `Artifact Generated + Artifact Persisted + Artifact Verified`。

## 命名空间规则

创建任何 ForgeLoop 管理资产前先定 Owner：

```text
Owner = FORGELOOP        → 使用正常命名（doc/、.ai/、config/、scripts/…）
Owner = CURRENT_PROJECT  → 使用 dev-* / .dev-*
```

`dev-doc/`、`dev-config/`、`dev-scripts/`、`dev-tools/`、`dev-agents/`、`dev-commands/`、`dev-skills/`、`dev-rules/`、`dev-hooks/`、`dev-prompts/`、`dev-templates/`、`dev-reports/` 以及 `.dev-ai/`、`.dev-cache/`、`.dev-work/` 全部保留给外部项目。本仓库自身开发使用 `doc/` 与 `.ai/`，不得引入 `dev-doc/`、`.dev-ai/` 作为中间层。

Namespace 表达 Owner，不表达成熟度。Draft / Review / Approved / Stable / Released 都不改变命名空间，也不存在 `dev-doc → doc` 的迁移流程。源码目录（`src/`、`tests/`、`app/`、`server/`、`client/`、`packages/`）不受 `dev-` 约束。

## 版本

`DESIGN.md` 顶部的 `Version: 1.0.0` 是 **Design Document Version**。Project / Package / Skill / Release Version 各自独立，由全局 Version Management 的单一权威源判定，各层之间不自动继承。项目版本号不得从 Design Version 推导，也不得自行决定 major / minor / patch / pre-release / tag。

设计文档涉及的版本层（`DESIGN.md` §44–§52）：Goal ID、MVP Version、SPEC Version、Plan Revision、Iteration ID、Task ID、Product Version。

## 部署形态

`DESIGN.md` §81–§82、§103：ForgeLoop 是 Skill 而非代码。`skills/forge-loop/SKILL.md` 是编排层；`slavingia/mvp` 与 `aspiers/iterative-development` 保持为上游依赖，不揉成一份巨型 SKILL.md。升级走 `upstream → installed skill → ForgeLoop adapter` 三段式并做 compatibility check。provenance 记录在 `docs/skills-provenance.md`（§104）。

## 既有能力优先

开发前先检查 `agents/`、`commands/`、`skills/`、`rules/` 是否已有可用能力，按 `Reuse → Extend → Create` 顺序处理，不重复实现。

## 工作方式约束

- 无实际工程依据时不预先假定 Architecture / Module / API / Database / Task Breakdown / Implementation Structure（`rules/forge-loop-development.md` §4）。
- 完成状态必须附证据（Test Result / Build Result / Runtime Result / Review Result / Inspection Result / Requirement Verification），报告实际运行的命令与输出。
- 任何验证失败即 `Task ≠ Complete`（`rules/state-and-recovery.md` §7）。
- 遇到未提交改动、Detached HEAD、异常分支、冲突改动或缺失 Checkpoint，先按全局 Git Rules 处理，不擅自恢复 Git 状态（`rules/git-integration.md` §6）。
- 拉取模型、依赖包、Git 仓库等外部资源时优先使用国内镜像；镜像失败一次重试一次，仍失败才回退上游并说明（`rules/domestic-mirror.md`）。

## Git 工作流

「提交」的含义是完整落地，不是只做本地 commit（`rules/git-integration.md` §9）：

```text
git add → git commit → push 分支 → 开 PR → squash 合并
→ 删除本地分支与远程分支 → 本地 main 同步 origin/main
```

- 「提交所有内容」= 同一轮提交工作树全部改动（含未跟踪文件）。
- 用户说「不用审核」时跳过对抗式评审，直接走完流程。
- 合并后本地与远程分支**都必须删除**，没有「只删远程、保留本地」的例外（`rules/git-integration.md` §8）。Squash 合并的分支无共同祖先，`git branch -d` 会拒绝；判断内容是否并入 main 用 tree hash 比对（`git rev-parse main^{tree}` 对比分支 tree），一致后再 `git branch -D`。
- 不得直接向 main 推送 Agent 变更。
- 提交格式与合并条件遵循 `ai-git-workflow`。

## 命名不一致（注意）

`AGENTS.md`、`CONTRIBUTING.md`、`README.md`、`rules/`、`doc/`、`CLAUDE.md` 正文中多处引用设计文档为 `ForgeLoop.DESIGN.md`，磁盘上的实际文件名是 `DESIGN.md`（文件内部首行标题为 `# ForgeLoop`）。新增引用时使用实际路径 `DESIGN.md`。统一的是引用方，文件名以磁盘现状为准（`rules/git-integration.md` §10）。