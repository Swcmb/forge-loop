# lifecycle

ForgeLoop 的 13 态状态机与合法转移。SKILL.md 的 Routing 依据本文件判定当前 Phase。

依据：`DESIGN.md` §106（State Contract）、§107（Lifecycle Transition）、§97（Impossible / Blocked）。

---

## 1. 状态契约（§106）

13 态（12 个主态 + 终态 `BLOCKED`；`BLOCKED` 已含在 13 态内，不另计）：

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

## 2. 正向转移主链（§107）

```text
PROJECT_INIT → DISCOVERY → MVP_DEFINITION → REQUIREMENT_EXTRACTION
→ REQUIREMENT_REVIEW → SPECIFICATION → SPEC_REVIEW → PLANNING
→ ITERATIVE_DEVELOPMENT → FINAL_AUDIT → RELEASE_READY → COMPLETE
```

## 3. 失败与回退

失败统一回 `ITERATIVE_DEVELOPMENT`（Fix → Re-test → Re-review）。需要重新定义范围回
`MVP_DEFINITION`；需要重定 SPEC 回 `SPECIFICATION`。无法安全继续进 `BLOCKED`（§97）。

## 4. 第一阶段的激活状态集合

第一阶段（§109 的 A/B/C/F/G/H/I/J/K；L/M/N 延后）各态行为：

| 态 | 第一阶段行为 |
| :--- | :--- |
| `PROJECT_INIT` / `DISCOVERY` | 读来源文档，产出 `source-index.md`（A） |
| `MVP_DEFINITION` | 产出 `required/optional/deferred`（C，见 `mvp-integration.md`） |
| `REQUIREMENT_EXTRACTION` / `REQUIREMENT_REVIEW` | 产出 `requirement-matrix.yaml`，`document-reviewer` 审（B） |
| `SPECIFICATION` / `SPEC_REVIEW` / `PLANNING` | 路由到本机 `spec` / `writing-plans`，ForgeLoop 只做路由与 Gate；执行体复用既有 skill |
| `ITERATIVE_DEVELOPMENT` | 本阶段主循环：单 Task 迭代 → Test → Review → Verify → Commit → Checkpoint |
| `FINAL_AUDIT` / `RELEASE_READY` / `COMPLETE` | 报告阶段收口：提示进入第二迭代，本阶段不执行 Audit / Release（L/M/N 延后） |
| `BLOCKED` | 记录 Blocker（Cause / Impact / Required Action / Context） |

## 5. Goal Continuation（§65）

Goal Mode 下，一个 Task 完成并形成 Checkpoint 后，若仍有未验证的 Required Requirement，则进入
下一轮迭代；全部 Requirement 已 verified 时进入 `FINAL_AUDIT`。Manual Mode 下完成即暂停，由用户
决定是否继续（见 `goal-mode.md`）。