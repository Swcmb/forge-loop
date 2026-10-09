# ForgeLoop Repository Audit

审计日期：2026-10-06
审计范围：仓库 `D:\ForgeLoop`（remote `git@github.com:Swcmb/forge-loop.git`，public）
审计依据：`DESIGN.md`（Design Version 1.0.0）、`AGENTS.md`、`rules/`、全局 Version / Git / Security Rules

---

## 1. Repository Inventory

审计时仓库共 17 个受版本控制文件，无实现代码。

```text
AGENTS.md                509 行   项目级 Agent 契约（16 节）
CLAUDE.md                219 行   工具入口索引
CONTRIBUTING.md          164 行   贡献流程（9 节）
DESIGN.md               3711 行   系统设计，113 节，权威依据
README.md                155 行   项目简介
doc/DEVELOPMENT.md       176 行
doc/INITIAL-DELIVERY.md 2301 行   已归档的初始交付稿，内容已拆分进其他文件
doc/PROJECT-CONSTRAINTS.md 223 行
doc/WORKSPACE-NAMESPACE.md 156 行
rules/artifact-persistence.md 411 行
rules/domestic-mirror.md       84 行
rules/forge-loop-development.md 199 行
rules/git-integration.md      211 行
rules/state-and-recovery.md   186 行
rules/version-management.md   168 行
rules/workspace-namespace.md   150 行
.gitattributes / .gitignore
```

空目录（git 不跟踪，clone 后不存在）：

```text
.ai/
src/
tests/
```

不存在的目录（`DESIGN.md` §81、§105 明确要求）：

```text
skills/
agents/
commands/
```

---

## 2. Git State

```text
当前分支      main（与 origin/main 同步）
工作区        clean
Tag           无
Release       无
Remote        origin → git@github.com:Swcmb/forge-loop.git
提交历史      6 个提交，全部为文档
              2fdc45c docs: 统一 DESIGN.md 目录语义并新增国内镜像规则 (#5)
              68da3b1 docs: [AI] 将工作流要求写入规则并声明设计为唯一权威 (#4)
              3da8bfa docs: 新增产物落盘规则并统一 CLAUDE.md 与 DESIGN.md 表述 (#3)
              83c22fc revert: [AI] 恢复 DESIGN.md 至 113 节完整设计 (#2)
              45c890a docs: 重构文档体系并归档初始交付稿 (#1)
              1d9dc0d chore: [AI] initialize ForgeLoop repository with design document
```

无未提交改动、无 detached HEAD、无冲突状态。符合 `rules/git-integration.md` §6。

---

## 3. Implementation Status

**实现完成度：0%。**

`DESIGN.md` §109 为 ForgeLoop 自身定义了 14 项验收标准（A–N），当前状态：

| 验收项 | DESIGN.md 依据 | 状态 |
| :--- | :--- | :--- |
| A 能读取文档 | §17 | 无实现 |
| B 能建立 Requirement | §18–§21 | 无实现 |
| C 能执行 MVP Scope | §14–§16、§86 | 无实现，且上游依赖未安装 |
| D 能生成 SPEC | §22–§25、§87 | 无实现 |
| E 能生成 Plan | §26–§27、§88 | 无实现 |
| F 能执行单 Task Iteration | §30–§32、§89 | 无实现，且上游依赖不可获得 |
| G 能测试 | §36 | 无工具链 |
| H 能 Review | §37 | 无实现 |
| I 能验证 Requirement | §38–§39 | 无实现 |
| J 能形成 Git Checkpoint | §53–§54 | 无实现 |
| K 能恢复中断状态 | §98–§99 | 无实现，`.ai/` 为空 |
| L 能执行 Final Audit | §66–§69 | 无实现 |
| M 能继续修复 Audit Findings | §69 | 无实现 |
| N 能进入 Release | §70–§73 | 无实现 |

---

## 4. Harness Dependency Availability

`DESIGN.md` §110「Final Architecture Decision」把 ForgeLoop 定义为对下列既有能力的**编排层**。审计逐项核对本机实际可用性。

### 4.1 生命周期控制器

| 依赖 | DESIGN.md 依据 | 本机状态 | 结论 |
| :--- | :--- | :--- | :--- |
| `/goal` | §4、§83、§85、§111 | Claude Code 内建命令（code.claude.com/docs/en/goal），本会话版本可用 | 可用 |

### 4.2 上游 Skill

| 依赖 | DESIGN.md 依据 | 上游是否存在 | 本机是否安装 | 结论 |
| :--- | :--- | :--- | :--- | :--- |
| `slavingia/mvp` | §3.1、§86、§104 | 存在：`github.com/slavingia/skills`，`skills/mvp/`，10844 stars | 已安装（T-01，blob 校验通过） | 已接入 |
| `aspiers/iterative-development` | §3.2、§89、§103、§112、§113 | **不存在**：`github.com/aspiers/iterative-development` 返回 404；用户 `aspiers`（Adam Spiers）存在，637 个公开仓库中无此项目 | 未安装 | **阻塞** |

`aspiers/iterative-development` 在 `DESIGN.md` 中出现 21 处，含 §3.2（语义定义）、§89（位置定义）、§103（升级策略）、§110（架构图）、§112（职责边界）、§113（正式职责定义），属架构级承重依赖。本地技能库 `/d/ai-configs/skills/skills/`（1353 个目录）全文检索 `aspiers` 无命中。

### 4.3 既有 Agent（`DESIGN.md` §10、§110 列为「Existing Agents」）

| 依赖 | 本机实际 | 结论 |
| :--- | :--- | :--- |
| `code-explorer` | 不存在。相近能力：`code-structure-analyst`、`Explore`、`repo-native-engineer` | 需映射决策 |
| `code-architect` | 不存在。相近能力：`repo-style-orchestrator`（产出 style contract，非架构设计） | 需映射决策 |
| `code-reviewer` | 不存在 agent。相近能力：`document-reviewer` agent、`code-review` / `requesting-code-review` skill | 需映射决策 |

### 4.4 既有 Spec / Plan 能力（`DESIGN.md` §87、§88 引用 `/spec`、`/plan`）

| 能力 | 本机 Skill | 状态 |
| :--- | :--- | :--- |
| SPEC 生成 | `spec`、`create-specification`、`update-specification` | 可用 |
| Plan 生成 | `writing-plans`、`create-implementation-plan`、`breakdown-plan` | 可用 |
| Plan 执行 | `executing-plans`、`spec-plan-executor` | 可用 |
| 需求澄清 | `brainstorming`（本会话正在用） | 可用 |
| 设计文档 | `SPAC-plus-auto` command（本会话正在用） | 可用 |

### 4.5 Git Workflow（`DESIGN.md` §13、§110）

| 依赖 | 本机实际 | 状态 |
| :--- | :--- | :--- |
| Git Workflow | `ai-git-workflow` skill（`rules/git.md` §Workflow 强制要求） | 可用 |
| Checkpoint 载体 | 复用全局 Git Workflow，`rules/git-integration.md` §2 禁止自建 Policy | 无需新建 |

---

## 5. Version State

```text
Design Document Version   1.0.0        （DESIGN.md 首部，权威）
ForgeLoop Project Version 未定义
ForgeLoop Skill Version   未定义
Release Version           未定义
Tag                       无
Changelog                 无
```

项目当前没有任何版本源（无 package manifest、无 VERSION 文件、无 tag）。`rules/version-management.md` §5、§6 要求 Claude Code 从全局规则与项目实际版本源判定，禁止由 Design Version 推导。

按 `DESIGN.md` §81，ForgeLoop 的产品形态是 Skill，其 Skill Version 应落在 `skills/forge-loop/SKILL.md` 的 frontmatter —— 该文件尚不存在，版本源随之缺失。

---

## 6. State Persistence

`rules/state-and-recovery.md` §2 要求可恢复 `Goal / Phase / Task / Iteration / Checkpoint / Blocker / Verification`。

```text
.ai/    空目录
```

无任何状态文件。ForgeLoop 自身的运行状态尚未开始记录。

---

## 7. Naming Inconsistency（已知，非阻塞）

文档正文 21 处写作 `ForgeLoop.DESIGN.md`，磁盘实际文件名为 `DESIGN.md`。`rules/git-integration.md` §10 已记录该事实并规定：统一的是引用方，文件名以磁盘现状为准。`AGENTS.md` §5 要求修改 `DESIGN.md` 本身需用户明确指示。

---

## 8. Blockers

### B-01（已解除，2026-10-06）`aspiers/iterative-development` 上游不可获得

**初判有误。** 搜索范围限于 `aspiers/<独立仓库名>` 形式，遗漏了 `aspiers/ai-config` 单仓库多 skill 的组织方式。真实上游为：

```text
https://github.com/aspiers/ai-config/tree/main/.agents/skills/iterative-development
```

来源已固定（路径末次 commit `f18bd2e3`，blob `cf101122`），接入路径与 Adapter 约束见 `doc/decisions/ADR-001-upstream-iterative-development.md`。用户裁定保留该上游依赖，不修改 DESIGN.md。

`DESIGN.md` §28 原文「为了兼容 `aspiers/iterative-development` 的任务驱动方式」证实设计原本即针对该上游写成，任务清单路径 `.ai/[feature]/tasks.md` 逐字吻合。

### B-02（已解除，2026-10-06）`slavingia/mvp` 未安装且安装方式待定

已裁定接入真实上游，Adapter 收束语义，接入契约见 `doc/decisions/ADR-005-slavingia-mvp-integration.md`。来源已固定（路径末次 commit `338c4301`，blob `a42a7996`）。

### B-03 Project Version 无来源

按 `DESIGN.md` §81，ForgeLoop 交付物是 Skill，需确定版本源位置与首个版本号。首个版本号由全局 Version Management 判定，不得由 Design Version 推导。

---

## 9. Open Requirements（进入 brainstorming）

以下问题在需求澄清阶段解决，本审计不作决定：

1. MVP Scope 边界。**已裁定**（`doc/decisions/ADR-002-mvp-scope.md`）：A/B/C/F/G/H/I/J/K 端到端可运行闭环，L/M/N 延后。
2. B-01 的路径选择。**已裁定**（`doc/decisions/ADR-001-upstream-iterative-development.md`）：接入 `aspiers/ai-config` 真实上游。
3. B-02 的依赖形态。**已裁定**（`doc/decisions/ADR-005-slavingia-mvp-integration.md`）：上游作启发式输入，Gate 判据归 §15/§16。
4. §10 三个 Agent 的映射方案。**已裁定**（`doc/decisions/ADR-006-agent-implementation.md`）：在 `D:\ForgeLoop\agents/` 新建三个，与 §10 对齐。
5. `skills/forge-loop/` 的落地位置。**已裁定**（`doc/decisions/ADR-003-deliverable-location.md`）：仓库为权威源码，库为部署。
6. `references/` 文件清单。**已裁定**（`doc/decisions/ADR-004-references-authority.md`）：以 §105 为准，第一阶段 10 个（延后 `audit-model.md`）。
7. `.ai/` 状态文件的实际结构（`rules/state-and-recovery.md` §2 只规定最小集合）。**待澄清**
8. 验证方式：Skill 型交付物无编译与单测，验收依据是 §109 A–N 的什么形式。**待澄清**

---

## 10. Audit Conclusion

```text
设计层      完成（DESIGN.md 113 节，Version 1.0.0）
规则层      完成（7 份项目规则 + 4 份开发文档）
治理层      完成（全局 Version / Git / Security 规则已接入）
实现层      零
状态层      零
版本层      未定义
```

仓库处于「设计完备、实现未开始」状态。推进顺序按 `AGENTS.md` §10 与用户指令：

```text
Repository Audit（本文件）
  ↓
Current State Assessment（本文件 §3、§8）
  ↓
brainstorming（澄清 §9 的 8 项）
  ↓
/SPAC-plus-auto（详细设计）
  ↓
Implementation
  ↓
Test / Review / Requirement Verification
  ↓
Checkpoint
```