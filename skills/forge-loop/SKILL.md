---
name: forge-loop
description: "Goal-driven project-level engineering orchestrator for Claude Code. Use when driving a project from its documents to a completed, verified version — detects lifecycle phase, loads applicable rules, defines MVP scope, establishes requirements, and runs one-task-at-a-time iteration with Test / Code Review / Requirement Verification gates, Git checkpoints, state persistence and recovery. Use when the user says '/goal 完成当前项目 MVP Scope 中规定的全部 Required 功能', or asks to continue/resume an interrupted ForgeLoop run. Do not use for a single small edit, or for pure Q&A about an existing codebase."
---

# ForgeLoop

Goal-driven、迭代式的项目级工程编排器。你**编排**，不**执行**专业工作：决定何时调用哪个能力、
为什么调用、结果进入哪个 Gate。

---

## 1. Routing（路由）

**每次开始工作前，先判定当前处于哪个 Phase**，再加载对应 reference。状态机与转移见
`references/lifecycle.md`。

判定顺序：

```text
1. 读 <runtime>/development-status.yaml（若存在）→ 恢复的 Phase
2. 无状态文件 → 从 PROJECT_INIT / DISCOVERY 开始
3. /goal 是否激活 → 判定 Goal Mode 或 Manual Mode（见 references/goal-mode.md）
```

`<runtime>`：Owner = FORGELOOP → `.ai/`；Owner = CURRENT_PROJECT → `.dev-ai/`（`DESIGN.md` §79）。

Phase → reference 映射：

| Phase | 加载 |
| :--- | :--- |
| DISCOVERY | `requirement-model.md` §1 |
| MVP_DEFINITION | `mvp-integration.md` |
| REQUIREMENT_EXTRACTION / REVIEW | `requirement-model.md` |
| SPECIFICATION / SPEC_REVIEW / PLANNING | 路由到本机 `spec` / `writing-plans`，本 skill 只做 Gate |
| ITERATIVE_DEVELOPMENT | `task-model.md` + `iterative-integration.md` + `goal-mode.md` + `evidence-model.md` + `version-control.md` |
| 中断恢复 | `recovery.md` |
| BLOCKED | 记录 Blocker 后停止推进 |

## 2. Core Rules（硬约束，不可违反）

1. **Design 是唯一权威** —— 术语、生命周期、Gate 名、状态名、ID 格式以 `DESIGN.md` 节号为准；
   与其冲突时以其为准（`AGENTS.md` §5）。
2. **One-Task Rule** —— 一个 Goal Turn 一个 primary Task；禁止塞入无关功能（`DESIGN.md` §32，
   `references/task-model.md` §5）。
3. **Evidence Required** —— 声明完成必须附真实执行证据；「写完了」不等于完成（`DESIGN.md` §39）。
4. **Git / Version 服从全局规则** —— 不建第二套 Git Policy（`rules/git-integration.md` §2）；
   不自定版本号（`rules/version-management.md`）。
5. **既有能力优先** —— `Reuse → Extend → Create`，见 `references/architecture.md` §2。
6. **产物落盘** —— 正式结果必须写入文件并验证存在（`rules/artifact-persistence.md`）。
7. **失败即非完成** —— 任一验证失败 → `Task ≠ Complete`（`rules/state-and-recovery.md` §7）。

## 3. Workflow（§82）

```text
1  Detect project state          → Routing
2  Load applicable rules
3  Determine current phase
4  Use mvp for MVP scope          → mvp-integration.md
5  Use document/spec skills      → 路由到既有 spec / writing-plans
6  Use planning skills           → 路由到既有 planning skills
7  Use iterative-development      → iterative-integration.md
8  Execute one task              → task-model.md
9  Test                          → §36
10 Review                       → §37（code-reviewer，六维）
11 Verify requirement           → §38（evidence-model.md）
12 Commit                       → 全局 Git Workflow
13 Update state                 → <runtime>/ 状态文件
14 Continue                     → 按 goal-mode.md 的 Mode 策略
15 Final Audit                  → 第二迭代（§109 的 L/M/N）
```

第一阶段：第 1–4、7–14 步启用；第 5–6 步只做路由与 Gate（执行体复用既有 skill）；第 15 步报告为
第二迭代。

### 一个 Task 的完整动作

```text
Select Task（按 §31 取件顺序）
  → Read Applicable Rules
  → Explore Code（code-explorer）
  → Implement
  → Test Gate → Code Review Gate → Requirement Verification Gate
  → Commit（全局 Workflow）
  → Update State
  → Checkpoint（§53，双重落点）
  → Expose Evidence
  → 按 Mode 继续或暂停
```

任一 Gate FAIL → 失败路径（`references/lifecycle.md` §3）：修复 → 重测 → 重审；无法安全继续 → `BLOCKED`。

## 4. Reference Loading（渐进披露）

细节一律在 references，SKILL.md 不复述。按需加载，不全量载入。

| reference | 承载 |
| :--- | :--- |
| `architecture.md` | 编排视图、既有能力 Reuse/Extend/排除、code-reviewer 双层结构 |
| `lifecycle.md` | 13 态状态机、转移、第一阶段激活状态集合 |
| `mvp-integration.md` | 上游 `mvp` Adapter、§16 Gate、§15 产出、降级路径 |
| `iterative-integration.md` | 上游 `iterative-development` Adapter、6 处覆盖点、CK-01～CK-06 |
| `requirement-model.md` | Document Discovery、REQ/AC 提取、Requirement State Machine |
| `task-model.md` | **Task State 唯一权威**、Task 结构、取件策略、One-Task Rule |
| `goal-mode.md` | Goal / Manual Mode 判定、续行标记、`/goal` 前置 |
| `version-control.md` | Checkpoint 双重落点、Git/状态冲突判据 |
| `evidence-model.md` | Evidence 八字段、`verified` 判定、Evidence Invalidation |
| `recovery.md` | 恢复链、六类中断场景、Compaction 取证协议 |

`audit-model.md` 随 §109 的 L / M 延后，第一阶段不存在。

## 5. Output Contract（每轮固定产出）

每一轮结束时，必须落盘：

```text
<runtime>/development-status.yaml     Goal / Phase / Task / Iteration / Checkpoint / Blocker / Mode
<runtime>/version-state.yaml          goal.id / iteration / git 状态（§55 schema）
<runtime>/<feature>/tasks.md          任务清单与勾选状态
<runtime>/<feature>/evidence.yaml     本轮 Requirement 的 Evidence（八字段）
```

并在对话中给出：做了什么、验证结果（实际命令与输出）、Checkpoint 记录、下一步。

**落盘校验**（`rules/artifact-persistence.md` §10）：写后确认 `File Exists + Content Is Complete +
Correct Path + Correct Owner`。完成定义是「Artifact Generated + Persisted + Verified」，不是「已生成」。