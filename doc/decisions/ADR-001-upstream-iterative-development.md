# Decision Record: 上游 `iterative-development` 接入路径

决策日期：2026-10-06
状态：已裁定
决策人：用户
关联审计：`doc/audits/repository-audit.md` §8 B-01

---

## 1. Decision

ForgeLoop 保留 `aspiers/iterative-development` 作为上游依赖，从真实来源接入，不以内置实现替代，不修改 `DESIGN.md` 的核心依赖定义。

接入路径遵循 `DESIGN.md` §103：

```text
Upstream
    ↓
Installed Skill
    ↓
ForgeLoop Adapter
    ↓
ForgeLoop Iteration Semantics
```

---

## 2. Pinned Upstream Source

| 项 | 值 |
| :--- | :--- |
| Repository | `https://github.com/aspiers/ai-config` |
| Visibility | public |
| Default Branch | `main` |
| Path | `.agents/skills/iterative-development` |
| Path Last Commit | `f18bd2e304924593c643708712f04be15dd4bbd2`（2026-08-27，message: `skill: fix descriptions that cannot route`） |
| Blob SHA (SKILL.md) | `cf1011224c27c503d9e1fae3386c8e5494fd4755` |
| File Size | 2131 B（上游字节大小；Windows 工作区副本经 CRLF 转换后为 2203 B，**字节数不作指纹依据**，比对一律用默认 `git hash-object`） |
| Repo HEAD at audit | `6c29f2480e17878e26704c3162be41f5feea5cd2`（2026-10-01） |

版本管理仍遵循 Global Version Management Rules（`rules/version-management.md` §2）；上述 commit 与 blob 是**来源指纹**，用于升级时的差异比对，不构成 ForgeLoop 的 Project Version。

---

## 3. Verified Alignment Between Upstream and DESIGN.md

`DESIGN.md` §28 原文：「为了兼容 `aspiers/iterative-development` 的任务驱动方式」，并采用 `<runtime>/<feature>/tasks.md` 结构。上游 SKILL.md 声明的路径为 `.ai/[feature]/tasks.md`，两者吻合。

| 上游行为 | DESIGN.md 对应 | 判定 |
| :--- | :--- | :--- |
| 任务清单路径 `.ai/[feature]/tasks.md` | §28 Task Structure | 契合 |
| 一次只做一个 sub-task | §30 Iterative Development、§32 One-Task Rule | 契合 |
| 维护任务清单勾选状态 | §28 checkbox | 部分契合：上游只覆盖 checkbox，**§29 Task State 九态无上游对应定义** |
| 完成一个 sub-task 后停下等用户 `yes`/`y` | §83 Goal Mode | **冲突**（实测 4 处独立暂停 + 1 句总括强制） |
| 「ONLY DO ONE SUB-TASK AT A TIME… NO EXCEPTIONS!!!」强制语气 | §32 One-Task Rule 的可执行性依赖 ForgeLoop 自身 Gate | 需 Adapter 逐条覆盖 |
| frontmatter description 排除 unattended | §83 Goal Mode | **路由层冲突**，需 Routing 层覆盖 |

---

## 4. Adapter Contract

Adapter 的职责边界（`DESIGN.md` §85 已确立的原则：只改 `continuation policy`，不改 `task size` / `verification discipline` / `task state`）：

| 编号 | 约束 |
| :--- | :--- |
| C-01 | 上游提供 One-Task-at-a-Time 的基础迭代能力，不承担 ForgeLoop 总体控制逻辑 |
| C-02 | 上游的用户交互行为（停下等 `yes`/`y`）不得未经适配直接改变 ForgeLoop Goal Mode |
| C-03 | Goal Mode / Manual Mode 的推进决策由 ForgeLoop 自身作出（`DESIGN.md` §83 / §84） |
| C-04 | ForgeLoop 自身不得重写上游 Skill 作为内置实现 |
| C-05 | Task 粒度与上游 Quality Controls 的 lint/test 环节保持上游语义，不因 Goal Mode 放宽。**Task State 以 DESIGN.md §29 九态为准（来源为 `task-model.md`），Gate 与 Evidence 以 §36–§39 为准** —— 上游无 Task State、Gate、Evidence 定义可供保持 |
| C-06 | 上游升级走 `upstream → installed skill → adapter` 三段式并做 compatibility check（§103），判定标准 CK-01～CK-06 由详细设计产出 |

---

## 5. Confirmed Conflict Detail

上游 SKILL.md（blob `cf1011224c27c503d9e1fae3386c8e5494fd4755`，2131 B）实测含 **6 处**冲突点：

| # | 位置 | 原文要点 |
| :--- | :--- | :--- |
| 1 | `### Sub-task Iteration (IMPORTANT)` | Do NOT start or even consider the next sub-task until you ask the user for permission and they say "yes" or "y" |
| 2 | `## Quality Controls` 第 4 条 | Ask for user approval before moving to the next sub-task |
| 3 | `## Communication` 第 3 条 | Ask for permission to continue with the next sub-task |
| 4 | `## Workflow` 步骤 5–6 | Ask: "Ready for the next sub-task?" / Wait for "yes" or "y" |
| 5 | 文末 | Follow the above steps EXACTLY!!! NO EXCEPTIONS!!! |
| 6 | frontmatter `description` | …rather than letting the agent run the list unattended…（把 unattended 排除在适用场景外） |

`DESIGN.md` §83 Goal Mode 原文：

```text
One Task → Complete → Checkpoint → Report Evidence → Continue
```

冲突点：Goal Mode 下任务完成后自动进入 Checkpoint 并继续下一个任务，不向用户索取逐任务许可。Adapter 必须在 Goal Mode 覆盖全部 5 处指令暂停（1–5），并在 Routing 层覆盖 description 的 unattended 排除条件（6），在 Manual Mode（§84）下保留暂停点。逐条覆盖表见详细设计 `doc/design/spac-001-detailed-design.md` §3.3。

---

## 6. Auxiliary Local Capabilities

按决策要求核对本机既有能力，结论为「辅助」，均**不替换**上游依赖：

| Skill | 定位 | 判定 |
| :--- | :--- | :--- |
| `executing-plans` | 「有 plan 则执行全部任务并报告完成」，任务间不停顿 | 与 One-Task 逐个停顿语义方向相反。可用于单个 Task 内部的步骤执行，不可用于迭代推进 |
| `spec-plan-executor` | 规范制定 → 子代理审查 → 用户审批 → 计划执行 | 与 `DESIGN.md` §21 Document Review、§25 SPEC Gate 语义重叠度高。可作 SPEC 阶段的辅助实现 |
| `spec` / `writing-plans` / `brainstorming` | SPEC 生成 / Plan 生成 / 需求澄清 | 对应 `DESIGN.md` §87、§88，可直接复用 |

---

## 7. Dependency Failure Handling

若上游在安装、访问、解析或适配环节失败：

```text
按 DESIGN.md 依赖失败处理规则报告
+
依据 rules/state-and-recovery.md §8 记录 Blocker（Cause / Impact / Required Action / Context）
+
不做静默替换
```

不做以下任何动作：以自研实现顶替上游、删除 `DESIGN.md` 中的上游依赖定义、把上游降级为可选依赖。

---

## 8. Consequences

- B-01 解除，架构级依赖已确定且可获取。
- `DESIGN.md` 保持不变，本次决策不触发 DESIGN.md 变更请求。
- 后续详细设计需产出：上游安装位置、Adapter 的实现形态与覆盖机制、compatibility check 的判定标准。**已产出**：`doc/design/spac-001-detailed-design.md` §3.3（逐条覆盖表 + CK-01～CK-06）、§4（T-01 安装与 blob 校验、T-07 编写覆盖表、T-10b 断言）、§5（V-13）、§6（兼容性破坏与覆盖失效路径）。
- 实测 `D:\ai-configs\skills\skills\iterative-development` 已安装且 blob 与 §2 指纹一致；`slavingia/mvp` 在库内不存在，属 T-01 待完成项。