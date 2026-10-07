# Decision Record: MVP Scope

决策日期：2026-10-06
状态：已裁定
决策人：用户
关联审计：`doc/audits/repository-audit.md` §9 第 1 项

---

## 1. Decision

ForgeLoop 自身开发的第一批交付是**端到端可运行的最小闭环**，不是一次实现完整 `DESIGN.md` §109 的 A–N。

```text
MVP = End-to-End Runnable Loop
第一阶段 = §109 的 A / B / C / F / G / H / I / J / K
后续迭代 = §109 的 L / M / N
```

---

## 2. Phase 1 Capability Set

第一阶段必须打通的链路：

```text
选任务
  ↓
Implementation
  ↓
Test
  ↓
Review
  ↓
Requirement Verification
  ↓
Commit
  ↓
Checkpoint
  ↓
State Persistence
  ↓
Recovery
  ↓
Continue
```

对应 `DESIGN.md` §109 验收项：

| 编号 | 能力 | 设计依据 |
| :--- | :--- | :--- |
| A | 能读取文档 | §17 Document Discovery |
| B | 能建立 Requirement | §18 Requirement Extraction、§19 Requirement ID、§20 Acceptance Criteria |
| C | 能执行 MVP Scope | §14–§16、§86 |
| F | 能执行单 Task Iteration | §30–§32、§89 |
| G | 能测试 | §36 Test Gate |
| H | 能 Review | §37 Code Review Gate |
| I | 能验证 Requirement | §38 Requirement Verification Gate、§39 Evidence |
| J | 能形成 Git Checkpoint | §53 Checkpoint、§54 Purpose |
| K | 能恢复中断状态 | §98 Goal Resume、§99 Compact Resume、§79 Long-Running State |

延后项：

| 编号 | 能力 | 延后理由 |
| :--- | :--- | :--- |
| L | Final Audit | §66–§69；第一阶段闭环稳定后再建，且 Audit 的判据需要真实累积的 evidence 才有意义 |
| M | Audit Repair Loop | §69、§96；依赖 L |
| N | Release Gate | §70–§73；依赖 L 与版本源（B-03 尚未解除） |

---

## 3. ForgeLoop Phase 1 Responsibilities

ForgeLoop 第一阶段承担的职责：

```text
Orchestration
Routing
Gate
Task / Iteration State
Verification Coordination
Checkpoint Coordination
Persistence
Recovery
```

---

## 4. Reuse over Build

SPEC / Plan 阶段优先复用本仓库与本机既有能力，不重复实现：

| 阶段 | 复用对象 |
| :--- | :--- |
| SPEC | 本机 `spec` skill（对应 §87） |
| Plan | 本机 `writing-plans` skill（对应 §88） |
| 需求澄清 | 本机 `brainstorming` skill |
| 详细设计 | `/SPAC-plus-auto` command |
| 单任务迭代 | 上游 `aspiers/iterative-development` + ForgeLoop Adapter（见 ADR-001） |
| Git Checkpoint | 全局 `ai-git-workflow`（`rules/git-integration.md` §2 禁止自建 Git Policy） |

---

## 5. Completion Criteria for MVP

MVP 的完成标准是「能够真实跑通一轮闭环并可靠恢复」，不是代码量或目录完整度。判定条件：

| 编号 | 条件 |
| :--- | :--- |
| V-01 | MVP 端到端可运行，构成完整闭环 |
| V-02 | 至少一个真实工程任务跑完整条链路 |
| V-03 | Test 环节有真实执行证据 |
| V-04 | Review 环节有真实执行证据 |
| V-05 | Requirement Verification 环节有真实执行证据 |
| V-06 | Checkpoint 环节有真实 Git 记录，且由全局 Git Workflow 形成 |
| V-07 | State Persistence 有真实落盘证据 |
| V-08 | Recovery 环节有真实证据：Session Restart / Context Compaction / Interrupted Work 三类场景下状态一致 |
| V-09 | 不为覆盖 §109 的 A–N 而提前实现缺少真实验证依据的高级能力 |

---

## 6. Consequences

- 第一阶段不交付 `references/` 中与 L/M/N 相关的部分（final-audit、audit 相关 reference 可延后）。
- `DESIGN.md` §81/§105 的 references 清单冲突仍待裁定（审计 §9 第 6 项），但延后部分可随 L/M/N 一并补齐。
- 上游 Adapter 的覆盖机制属于 F，落在第一阶段范围内。