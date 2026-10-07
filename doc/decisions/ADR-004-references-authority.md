# Decision Record: references 权威清单

决策日期：2026-10-06
状态：已裁定
决策人：用户
关联审计：`doc/audits/repository-audit.md` §9 第 6 项

---

## 1. Decision

`references/` 的权威清单以 `DESIGN.md` §105「ForgeLoop References」为准。§81 的旧清单不再采用，不引入第三套命名。

---

## 2. Authoritative List（§105，共 11 个）

```text
references/
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

---

## 3. Phase 1 Scope（第一阶段 10 个）

按 ADR-002 的 MVP 范围（A/B/C/F/G/H/I/J/K）建立：

| reference | MVP 能力 | 设计依据 |
| :--- | :--- | :--- |
| `architecture.md` | 全局设计视图 | §110 Final Architecture Decision |
| `lifecycle.md` | 全流程 | §106 State Contract、§107 Lifecycle Transition |
| `mvp-integration.md` | C MVP Scope | §14–§16、§86 |
| `iterative-integration.md` | F 上游 Adapter | §3.2、§89、§103、ADR-001 |
| `requirement-model.md` | B Requirement | §18–§21、§58 Requirement State Machine |
| `task-model.md` | F Task / Iteration | §27–§32、§29 Task State |
| `goal-mode.md` | Goal / Manual Mode | §83、§84、§85 |
| `version-control.md` | J Checkpoint | §40–§43、§53、§54 |
| `evidence-model.md` | I Requirement Verification | §38、§39、§59 Evidence Invalidation |
| `recovery.md` | K Recovery | §79、§98、§99 |

延后项：

| reference | 能力 | 延后到 |
| :--- | :--- | :--- |
| `audit-model.md` | L Final Audit、M Audit Repair Loop | ADR-002 后续迭代 |

### 计数说明

决策原文写「先建立 9 个」。§105 实际含 11 个 reference，延后 `audit-model.md`（唯一延后项）后第一阶段为 **10 个**。本次按实质要求执行 10 个，包含决策中点名的 `recovery.md`、`architecture.md`、`iterative-integration.md`。若后续确需只建 9 个，需指明具体排除哪一个。

---

## 4. Naming Convention

统一采用 §105 的命名，`-model` / `-integration` 后缀用于明确 reference 的职责与语义。不回退 §81 的 `mvp.md` / `requirements.md` / `task-lifecycle.md` / `evidence.md` / `final-audit.md` 等旧名。

---

## 5. Conflict Handling Rule（后续同类冲突的处理原则）

ForgeLoop Design 中若再次出现 references 清单冲突，或 §81 与 §105 存在语义冲突：

```text
以当前 Design 的最新权威定义为准（当前为 §105）
        ↓
记录为 Design Inconsistency
        ↓
以 §105 作为当前实现依据继续开发
        ↓
除非后续明确修改 Design，不自行创造第三套结构
```

同时遵守 `AGENTS.md` §5：Design 是唯一权威，修正引用方而非反向改写 DESIGN.md；修改 DESIGN.md 本身需用户明确指示。

---

## 6. Consequences

- SKILL.md 采用 §105 明确的五项职责：`Routing` / `Core Rules` / `Workflow` / `Reference Loading` / `Output Contract`；具体细节一律下沉到 references（§105「SKILL.md 只做」）。
- §81 的 `references/` 8 文件清单视为历史遗留，不在实现中体现。
- `audit-model.md` 不在第一阶段创建，避免出现无验证依据的空 reference（ADR-002 V-09）。