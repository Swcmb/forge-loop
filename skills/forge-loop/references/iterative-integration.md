# iterative-integration：上游 `aspiers/iterative-development` 的 ForgeLoop Adapter

依据：`DESIGN.md` §3.2、§85、§89、§103、§29
决策：`doc/decisions/ADR-001-upstream-iterative-development.md`
设计：`doc/design/spac-001-detailed-design.md` §3.3

---

## 1. 本文件的角色

上游 SKILL.md 是**面向 Claude Code 直读**的指令文本，内含与 `DESIGN.md` §83 Goal Mode 方向相反的
硬约束。本文件是 ForgeLoop 侧的适配层，只改写**推进策略（continuation policy）**；`DESIGN.md` §85
已明确 Task 粒度、验证纪律、Task State 三项保持不变。

## 2. 指令优先级

```text
ForgeLoop 指令 > 本文件（Adapter） > 上游 iterative-development
```

同时载入本文件与上游原文时，上游原文在 continuation policy 这一冲突点上按本文件解释；其余条款
按上游语义执行。

## 3. 覆盖：continuation policy（逐条）

上游实测含 **6 处**与 Goal Mode 冲突的约束。Goal Mode 下**全部失效**，Manual Mode 下**全部保留**。

| # | 上游位置 | 原文要点 | Goal Mode | Manual Mode |
| :--- | :--- | :--- | :--- | :--- |
| 1 | `### Sub-task Iteration (IMPORTANT)` | Do NOT start or even consider the next sub-task until you ask the user for permission and they say "yes" or "y" | 失效 | 保留 |
| 2 | `## Quality Controls` 第 4 条 | Ask for user approval before moving to the next sub-task | 失效 | 保留 |
| 3 | `## Communication` 第 3 条 | Ask for permission to continue with the next sub-task | 失效 | 保留 |
| 4 | `## Workflow` 步骤 5–6 | Ask: "Ready for the next sub-task?" / Wait for "yes" or "y" | 失效 | 保留 |
| 5 | 文末 | Follow the above steps EXACTLY!!! NO EXCEPTIONS!!! | 逐条覆盖表优先于该总括声明 | 保留 |
| 6 | frontmatter `description` | …rather than letting the agent run the list unattended… | 路由层：由 `goal-mode.md` Routing 显式选定本技能为 Execution Engine（§89），该排除条件被覆盖 | 保留 |

**判定规则：上游任一暂停点在 Goal Mode 下均失效。**

### 3.1 覆盖不依赖提示层声明

「声明优先级」属提示层对抗，无法保证上游的强制语气不压过 ForgeLoop 控制流。采用两条可测机制：

- **结构降级** —— ForgeLoop 不把上游 SKILL.md 全文载入主上下文；只把其中三条语义（Task 粒度、
  任务清单维护、Relevant Files 维护）内联进 `task-model.md`。上游原文作为本文件的参考保留，
  不参与指令竞争。
- **续行标记** —— Goal Mode 下每次 Checkpoint 后在 `evidence.yaml` 写入机器可检标记：

```yaml
mode: goal
next: TASK-xxx
```

该标记是「未被上游暂停拦截」的反证。

### 3.2 Mode 无关的暂停

以下情形无论 Mode 如何都停，不进入 continuation：

| 情形 | 依据 |
| :--- | :--- |
| Test / Review / Requirement Verify 任一 FAIL | `DESIGN.md` §64 FAIL 分支、§96 |
| Git 与状态不一致 | `rules/state-and-recovery.md` §5、`version-control.md` §3 |
| 无法安全继续 | `DESIGN.md` §97 → `BLOCKED` |
| Blocker 存在 | `DESIGN.md` §31 取件顺序第 1 项 |

## 4. 保持：上游语义（§85 不放宽）

| 项 | 权威来源 | 上游是否提供 |
| :--- | :--- | :--- |
| Task 粒度（一次一个 Task） | `DESIGN.md` §32 | 是（`ONLY DO ONE SUB-TASK AT A TIME`） |
| 验证纪律（实现后跑 lint/test，失败先修） | 上游 `## Quality Controls` 1–3 | 是 |
| Task State 九态 | `DESIGN.md` §29（`task-model.md`） | **否** —— 上游只维护清单勾选 |
| 任务清单维护 | 上游 `## Sub-task Implementation` | 是 |
| Relevant Files | 上游 `## Sub-task Implementation` | 是 |
| Gate 与 Evidence | `DESIGN.md` §36–§39 | **否** —— 上游无 Gate / Evidence 定义 |

上游 Quality Controls 的 lint/test 只作为**各 Gate 之前的早期拦截**；Gate 通过与否由 ForgeLoop 判据
决定（`evidence-model.md`）。Goal Mode 只改变「完成后是否停」，不改变「完成前必须验证」。

上游提到的 `prp.txt` 是 aspiers 自己的工具约定，ForgeLoop 无该文件，本 Adapter 下该条**不适用**；
ForgeLoop 的文档落盘走 `rules/artifact-persistence.md`。

## 5. 上游语义 → ForgeLoop 语义映射

| 上游步骤 | ForgeLoop 对应 | 章节 |
| :--- | :--- | :--- |
| 1. Select one sub-task from tasks.md | Select Task（按取件顺序） | §31 |
| 2. Implement it completely | Implement（内部含 Explore Code） | §30、§33 |
| 3. Run linters and tests | Test Gate（早期拦截） | §36 |
| 4. Report completion | Report Evidence | §39 |
| 5. Ask: "Ready for the next sub-task?" | **由 §3 的 Mode 策略取代** | §83–§85 |
| 6. Wait for "yes" or "y" | **仅 Manual Mode 生效** | §84 |
| 7. Repeat until all sub-tasks complete | Continue / Goal Continuation | §65 |

上游步骤 3 只覆盖 lint / test。ForgeLoop 在其后追加 Code Review Gate（§37）、Requirement Verify Gate
（§38）、Commit → Checkpoint（§53）。追加的 Gate 不因 Goal Mode 而跳过。

## 6. 上游升级的 compatibility check（§103）

```text
upstream update → compatibility check → adapter verification
```

| 编号 | 判据 | 失败处置 |
| :--- | :--- | :--- |
| CK-01 | 上游 SKILL.md 的 Instructions / Quality Controls / Communication / Workflow 四个小节全部存在 | 停，升 Design Inconsistency |
| CK-02 | 四处暂停点（§3 表第 1–4 项）的语义文本指纹未变 | 停，重做覆盖表并复跑 Goal Mode 断言 |
| CK-03 | Relevant Files 与 tasks.md 维护指令未变 | 停，更新本文件 |
| CK-04 | 上游未新增 Task State / Gate / Evidence 语义 | 停，评估与 §29 / §36–§39 的冲突 |
| CK-05 | 上游 frontmatter `description` 未变更 | 停；按名解析落空时进 `BLOCKED` |
| CK-06 | `git hash-object` 与 ADR-001 §2 指纹一致 | 停，不一致进 `BLOCKED` |

比对时机：安装后、每次上游升级前、每次闭环演练前。指纹必须用默认 `git hash-object`（含 CRLF
归一化），**不用字节数**、**不用 `--no-filters`**（DI-07）。

**adapter verification**：CK 全通过后，跑一次真实 Task 闭环，确认 Goal Mode 下「完成 → Checkpoint →
继续」不向用户索取许可（续行标记出现），且 Manual Mode 下仍暂停。

上游副本保持原样（ADR-001 C-04）；差异由本文件承接，不修改已安装的上游副本。

## 7. 上游不可用时的处置

上游在安装、访问、解析或适配环节失败时（ADR-001 §7）：记录 Blocker（Cause / Impact / Required
Action / Context），进入 `BLOCKED`。禁止：以自研实现顶替上游、把上游降级为可选依赖、删除
`DESIGN.md` 的上游依赖定义、修改已安装的上游副本。

## 8. 任务清单路径

上游写死 `.ai/[feature]/tasks.md`。`DESIGN.md` §28 采用同一结构，路径按 Owner 解析：

```text
Owner = FORGELOOP       → .ai/<feature>/tasks.md
Owner = CURRENT_PROJECT → .dev-ai/<feature>/tasks.md
```

## 9. 本机既有能力的定位（`AGENTS.md` §9）

以下能力**辅助**上游，不替代：

| 能力 | 定位 |
| :--- | :--- |
| `executing-plans` | 与 One-Task 逐个停顿方向相反。可用于单个 Task **内部**的步骤执行，不用于迭代推进 |
| `spec-plan-executor` | 规范→审查→审批→执行，与 §21 / §25 重叠。可作 SPEC 阶段辅助，不进入 Task 循环 |
| `spec` / `writing-plans` / `brainstorming` | SPEC / Plan / 需求澄清，在迭代循环**之前**运行 |

## 10. 上游现状（2026-10-06 实测）

| 项 | 值 |
| :--- | :--- |
| Repository | `https://github.com/aspiers/ai-config`（public，`main`） |
| Path | `.agents/skills/iterative-development` |
| Path Last Commit | `f18bd2e304924593c643708712f04be15dd4bbd2`（2026-08-27） |
| Blob SHA（`SKILL.md`） | `cf1011224c27c503d9e1fae3386c8e5494fd4755` |
| 中央库副本 | `D:\ai-configs\skills\skills\iterative-development\` |
| 部署副本 | `C:\Users\Swcmb\.claude\skills\iterative-development\` |
| skill_id | `c0ed2a19-5d52-4905-8633-f9c8ff07a8d8` |

库副本与部署副本的 `git hash-object` 均等于上游 blob。完整来源登记见
`D:\ai-configs\docs\skills-provenance.md`。commit 与 blob 为来源指纹，不构成 Project Version。