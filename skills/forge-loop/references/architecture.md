# architecture

ForgeLoop 的编排视图：依赖哪些既有能力、各自调用时机、ForgeLoop 在其中的位置。

依据：`DESIGN.md` §110（Final Architecture Decision）、§10（Agent Integration）、
`AGENTS.md` §9（Reuse → Extend → Create）。

---

## 1. 编排视图（§110）

```text
/goal（Claude Code 内建）
  ↓
forge-loop（本 Skill：编排层）
  ├─ 上游 mvp            → MVP Scope
  ├─ 既有 spec/plan 能力 → Requirement + SPEC + Plan
  ├─ 上游 iterative-development → One-Task Iteration
  ├─ Agent code-explorer / code-architect / code-reviewer
  ├─ 既有 Rules（git / filesystem / testing / security）
  └─ 既有 Git Workflow（Branch / Commit / Version / Tag / Release）
```

ForgeLoop 只负责编排与 Gate，**不承担**任何专业执行：它决定「何时调用 / 为什么调用 / 调用结果进入
哪个 Gate」（§10）。

## 2. 既有能力纳入 / 排除判定（`AGENTS.md` §9）

| 能力 | 判定 | 调用时机 | 定位 |
| :--- | :--- | :--- | :--- |
| `mvp`（上游） | Reuse | MVP_DEFINITION | 启发式输入，Gate 判据归 §15/§16（`mvp-integration.md`） |
| `iterative-development`（上游） | Reuse + Extend | ITERATIVE_DEVELOPMENT | One-Task 执行引擎（`iterative-integration.md`） |
| `spec` skill | Reuse | SPECIFICATION / SPEC_REVIEW | SPEC 生成 |
| `writing-plans` skill | Reuse | PLANNING | Plan 生成 |
| `code-explorer` agent | Extend（新建） | Implement 前（§33） | 项目结构/调用/依赖/实现/测试/影响面 |
| `code-architect` agent | Extend（新建） | Plan 阶段（§34，第一阶段闲置） | 技术方案/架构边界/模块关系/风险/实现策略 |
| `code-reviewer` agent | Extend（新建） | §37 Code Review Gate | 六维 Finding |
| `ai-git-workflow` | Reuse | Checkpoint | 版本边界 |
| 既有 Rules（git/filesystem/testing/security） | Reuse | 全程 | 治理与安全 |
| `executing-plans` | **排除** | — | 「有 plan 则一次执行完且任务间不停顿」，与 One-Task 逐个停顿方向相反；仅可用于单个 Task 内部步骤 |
| `spec-plan-executor` | **排除** | — | 规范→审批编排流，与 §21/§25 重叠，第一阶段不引入 |

## 3. code-reviewer 双层结构（§10 vs §37）

`DESIGN.md` §10 的 Agent 职责清单与 §37 的 Gate 审核清单是两个不同的六维（DI-04）：

| 层 | 维度 | 用途 |
| :--- | :--- | :--- |
| 审查产出（§10） | Diff（输入）/ Correctness / Regression / Security / Maintainability / Architecture | 产出 Finding |
| Gate 判定（§37） | Correctness / Architecture / Security / Regression / Maintainability / **Scope** | PASS / FINDINGS |

`Scope` 维度（改动是否超出当前 Task 授权范围，对应 §32 / §101）在 §10 侧无人承载，由 Gate 侧承载。

## 4. 决策与实现依据的边界

设计表述以 `DESIGN.md` 为唯一权威（`AGENTS.md` §5）。本 Skill 的各 reference 只做索引与实现说明，
引用一律指向 `DESIGN.md` 节号；与 `DESIGN.md` 冲突时以 `DESIGN.md` 为准。