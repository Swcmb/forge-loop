# ForgeLoop

> Goal-Driven MVP Iterative Engineering

**Version:** 1.0.0 &nbsp;|&nbsp; **Status:** Design &nbsp;|&nbsp; **Target:** Claude Code

ForgeLoop 是 Claude Code 的 Goal-driven 项目级开发编排器。它使用 `slavingia/mvp` 控制产品范围，使用现有 Spec/Plan 能力建立实现契约，使用 `aspiers/iterative-development` 执行"一次一个 Task"的增量开发，通过测试、代码审核和 Requirement Verification 建立完成证据，通过现有 Git Workflow 形成版本历史，并在最终 Document Audit 通过前持续迭代。

## 它解决什么问题

给 Claude 一组项目文档、需求和现有代码后，如何让 Claude 从 MVP 开始，经过 Spec、Plan、单任务迭代、测试、Review、需求验收、版本控制，**持续工作到文档规定的全部功能真正完成**。

## 四个层次的职责划分

| 层次 | 回答的问题 | 承担者 |
| :--- | :--- | :--- |
| Goal | 什么时候停止 | Claude Code `/goal` |
| MVP | 这一版做什么 | `slavingia/mvp` |
| SPEC + PLAN | 必须做到什么、拆成什么 | 现有 Spec/Plan 能力 |
| Iterative Development | 这一轮具体完成什么 | `aspiers/iterative-development` |

再叠加三道约束：

| 约束 | 决定什么 |
| :--- | :--- |
| Git Workflow | 如何形成可靠版本 |
| Requirement Verification | 一个需求是否真正完成 |
| Final Audit | 整个文档是否兑现 |

## 核心定位

```text
Claude Code /goal     "一直做到完成"
       ↓
slavingia/mvp         "这一版做什么"
       ↓
SPEC / PLAN           "必须做到什么、拆成什么"
       ↓
aspiers/iterative-dev "一次做一个 Task"
       ↓
Test / Review / Verify
       ↓
Git / Version
       ↓
Final Document Audit
       ↓
Goal Complete
```

## 完整生命周期

```text
Source Documents → MVP Definition → Requirement Extraction → Requirement Review
    → SPEC → SPEC Review → Implementation Plan → Task Breakdown
    → Iterative Development → Test → Code Review → Requirement Verification
    → Git Commit → Version Checkpoint → Next Task
    → Final Document Audit → Release → Goal Complete
```

## 追溯链

设计要求保留完整追溯链，任何"已完成"的结论都能回溯到证据：

```text
SOURCE → REQ → SPEC → TASK → ITERATION → COMMIT → TEST → REVIEW → EVIDENCE → VERIFIED
```

## 设计原则

复用既有 Harness（`AGENTS.md` / `rules` / `agents` / `commands` / `skills` / Git Workflow）作为执行层，ForgeLoop 自身只做编排，不复制已有规则。

## 仓库结构（规划）

```text
ForgeLoop/
├── SKILL.md              # 路由、核心规则、工作流、引用加载、输出契约
├── references/           # 具体规则，按渐进披露拆分
│   ├── architecture.md
│   ├── lifecycle.md
│   ├── mvp-integration.md
│   ├── iterative-integration.md
│   ├── requirement-model.md
│   ├── task-model.md
│   ├── goal-mode.md
│   ├── version-control.md
│   ├── evidence-model.md
│   ├── audit-model.md
│   └── recovery.md
├── DESIGN.md             # 完整设计文档（113 节）
└── docs/                 # 补充文档
```

## 当前状态

处于 **Design** 阶段。仓库已建立，尚未实现 `SKILL.md` 与 `references/`。

设计文档见 [DESIGN.md](DESIGN.md)。

## 上游依赖

| 依赖 | 角色 |
| :--- | :--- |
| `slavingia/mvp` | MVP 定义层 / MVP Scope Engine（[source](https://github.com/slavingia/skills)） |
| `aspiers/iterative-development` | 单任务迭代执行模型 / Execution Engine |
| Claude Code `/goal` | 长周期完成控制（[docs](https://code.claude.com/docs/en/goal)） |

ForgeLoop 通过 adapter 组合上游能力，升级上游时保持原始版本不动，只验证 adapter 兼容性。

## 待定事项

以下内容在设计文档中明确留空，待实现阶段确定：

- 技术栈
- License
- `aspiers/iterative-development` 的上游来源地址
- 分支策略（交由 Repository Policy 决定）
- BLOCKED 状态的恢复策略与超时阈值
