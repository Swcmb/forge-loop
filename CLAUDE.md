# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 仓库当前状态

本仓库目前只有设计与治理层，没有实现代码。

```text
DESIGN.md                  系统设计（113 节，权威依据）
AGENTS.md                  项目级 Agent 契约（16 节）
CONTRIBUTING.md            贡献流程
rules/                     5 份项目规则
doc/                       4 份开发文档
  DEVELOPMENT.md / PROJECT-CONSTRAINTS.md / WORKSPACE-NAMESPACE.md
  INITIAL-DELIVERY.md      初始一次性交付稿，内容已拆分进上述文件
src/  tests/  .ai/         空目录
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

## 核心设计要点

完整定义在 `DESIGN.md`，以下是读多个文件才能拼出的要点：

**ForgeLoop 是 orchestrator，不重实现能力。** 它负责生命周期编排、状态持久化、验证门、检查点、恢复、终审；专业执行交给已有的 Agents / Commands / Skills / Rules / Git Workflow。上游依赖明确指定：`slavingia/mvp`（范围控制）、`aspiers/iterative-development`（单 Task 执行模型）。

**三层验证互不替代。** Test 回答「代码运行是否正确」，Code Review 回答「实现质量是否合格」，Requirement Verification 回答「用户要求是否真正实现」。完成判断必须能回溯 `Requirement → Acceptance Criteria → Implementation → Evidence`，代码存在或测试通过都不构成完成。

**ONE TASK。** 默认循环 `Select → Explore → Implement → Test → Review → Verify → Checkpoint`，一个 Task 完成才进下一个。Goal Mode 下持续推进到 Goal Complete，Manual Mode 下 Checkpoint 后暂停。

**失败收敛为可恢复状态。** Test / Review / Requirement / Audit 失败统一进入 `Repair → Re-test → Re-review → Re-verify`；架构或需求大改走 Replan；无法安全继续则标 Blocked（记录 Cause / Impact / Required Action / Context）。

**Final Audit 可以产生新 Task。** 全部 Required Task 完成后回到最初目标与开发文档做终审，失败则重新进入 Iteration Loop，直到通过。

**状态必须持久化**。`AGENTS.md` §12 与 `rules/state-and-recovery.md` 规定 ForgeLoop 自身状态放 `.ai/`；`DESIGN.md` §55–§57、§79 对被开发项目规定放 `docs/status/`（`version-state.yaml`、`development-status.yaml`、`audit-state.yaml`）。两者作用域不同——前者是 ForgeLoop 自身，后者是被开发项目。恢复时先 Load State → Inspect Workspace → Inspect Git → Inspect Checkpoint → Reconcile → Resume；运行时状态与 Git 状态不一致时停止自动推进，先做 Reconciliation。

**Checkpoint 走全局 Git Workflow**（`DESIGN.md` §53–§54）。本项目不定义 branch / commit / merge / tag / push 策略，只决定何时需要形成版本边界。Checkpoint 内容包含 `goal.id` / `iteration.id` / `task.id` / `git.commit` / `spec.version` / `progress.requirements`，用途是 Resume / Audit / Rollback / Progress Tracking / Version Comparison。

**状态机是显式的**（`DESIGN.md` §106–§107）：

```text
PROJECT_INIT → DISCOVERY → MVP_DEFINITION → REQUIREMENT_EXTRACTION
→ REQUIREMENT_REVIEW → SPECIFICATION → SPEC_REVIEW → PLANNING
→ ITERATIVE_DEVELOPMENT → FINAL_AUDIT → RELEASE_READY → COMPLETE
```

失败统一回 `ITERATIVE_DEVELOPMENT`；需要重定范围或 SPEC 时回 `MVP_DEFINITION` 或 `SPECIFICATION`。另有终态 `BLOCKED`。

**Requirement 变更会使既有验证失效**（`DESIGN.md` §59、§62–§63）。Requirement 或 SPEC 发生语义变化时，相关实现与验证结果必须重新评估。新增需求走 `Scope Decision → Impact Analysis`，不得靠直接改代码绕过范围管理。

**可执行判据全部来自完整版 DESIGN.md 的 113 节**（如 §19 Requirement ID、§20 Acceptance Criteria、§25 SPEC Gate、§32 One-Task Rule、§36 Test Gate、§37 Code Review Gate、§38 Requirement Verification Gate、§39 Evidence、§70–§72 Build/Runtime/Release Gate、§108 Core Invariants I-001…I-010）。本文件只做索引，具体判据一律回查 `DESIGN.md` 对应节号。

**部署形态是 Skill 而非代码**（`DESIGN.md` §81–§82、§103）。`skills/forge-loop/SKILL.md` 是编排层，`slavingia/mvp` 与 `aspiers/iterative-development` 保持为上游依赖，升级时走 `upstream → installed → ForgeLoop adapter` 三段式并做 compatibility check。provenance 记录在 `docs/skills-provenance.md`。

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

## 既有能力优先

开发前先检查 `agents/`、`commands/`、`skills/`、`rules/` 是否已有可用能力，按 `Reuse → Extend → Create` 顺序处理，不重复实现。

## 工作方式约束

- 无实际工程依据时不预先假定 Architecture / Module / API / Database / Task Breakdown / Implementation Structure。
- 完成状态必须附证据（Test Result / Build Result / Runtime Result / Review Result / Inspection Result / Requirement Verification），报告实际运行的命令与输出。
- 任何验证失败即 `Task ≠ Complete`。
- 遇到未提交改动、Detached HEAD、异常分支、冲突改动或缺失 Checkpoint，先按全局 Git Rules 处理，不擅自恢复 Git 状态。

## 命名不一致（注意）

`AGENTS.md`、`CONTRIBUTING.md`、`rules/`、`doc/`、`README.md` 中多处引用设计文档为 `ForgeLoop.DESIGN.md`，磁盘上的实际文件名是 `DESIGN.md`（文件内部首行标题为 `# ForgeLoop`）。新增引用时使用实际路径 `DESIGN.md`。
