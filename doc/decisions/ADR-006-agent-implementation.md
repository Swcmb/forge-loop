# Decision Record: §10 下层 Agent 落地方式

决策日期：2026-10-06
状态：已修订（2026-10-06，第 1 轮评审后）
修订原因：CRITICAL — 原落点违反全局 harness 硬边界
决策人：用户（原决策）→ 依全局规则强制修订（AGENTS.md §2 Global Rule wins）
关联审计：`doc/audits/repository-audit.md` §9 第 4 项

---

## 1. Decision（修订后）

三个下层 Agent 安装到全局 harness 的规范位置：

```text
D:\ai-configs\agents/code-explorer.md
D:\ai-configs\agents/code-architect.md
D:\ai-configs\agents/code-reviewer.md
```

---

## 2. 修订依据（本次评审的 CRITICAL 发现）

原决策把三个 Agent 放在 `D:\ForgeLoop\agents/`，理由是「比照 ADR-003 对 skill 的处理」。该类比不成立：

| 项 | Skill | Agent |
| :--- | :--- | :--- |
| 全局规则豁免 | `rules/skills.md` 明文：「开发阶段可直接编辑 authoring 文件」 | **无对应豁免** |
| 硬边界原文 | — | `CLAUDE.md`：「Never install agents, commands, mcp, rules, or skills outside `D:/ai-configs`… Installing into… **or into a project directory is prohibited**」 |
| 实际加载路径 | 库 → agent 目录 | `C:\Users\Swcmb\.claude\agents -> /d/ai-configs/agents/`（符号链接实测） |

`D:\ForgeLoop\agents/` 既违反全局硬边界，又不会被 Claude Code 加载 —— `DESIGN.md` §109 能力 H（能 Review）与判据 V-04 的执行证据无法产生。依 `AGENTS.md` §2「Global Rule wins」，本条强制修订。

---

## 3. 修订后内容

### 3.1 安装位置

```text
D:\ai-configs\agents/          唯一权威副本，Claude Code 按此路径加载
```

仓库内不保留 `agents/` 源码副本。Agent 定义文件的版本化随 `D:\ai-configs` 仓库进行（该仓库为 AI agent 配置的唯一 Source of Truth）。

### 3.2 职责定义（不变）

| §10 职责 | 决策 | 说明 |
| :--- | :--- | :--- |
| `code-explorer`：项目结构 / 调用关系 / 依赖 / 已有实现 / 测试 / 影响面 | 新建 | 服务 §33 Code Exploration 与 §34 Architecture Check |
| `code-architect`：技术方案 / 架构边界 / 模块关系 / 风险 / 实现策略 | 新建 | 主要服务 Plan 阶段（能力 E），第一阶段基本闲置，为后续 E/Plan 预留 |
| `code-reviewer`：Diff / Correctness / Regression / Security / Maintainability / Architecture | 新建 | 服务 §37 Code Review Gate（能力 H，第一阶段必需） |

理由（不变）：本机 `code-review` skill 走 CodeRabbit 外部 CLI（需认证、非离线可复现），不适合做每轮强制 Gate；`document-reviewer` 审文档非代码；`requesting-code-review` 只是通用子代理调度模式。三者均不构成 §37 要求的确定性 Reviewer。

### 3.3 与 ADR-003 的关系（本次修订厘清）

ADR-003 裁定 skill 采用「仓库为权威源码 + 库为部署」。该形态**只适用于 skill**，因为 `rules/skills.md` 给 skill 的开发阶段提供了 authoring 文件豁免。Agent 没有这一豁免，因此不套用同一形态。

| 资产 | 权威源码位置 | 部署位置 | 依据 |
| :--- | :--- | :--- | :--- |
| `forge-loop` skill | `D:\ForgeLoop\skills/forge-loop/` | `D:\ai-configs\skills\skills/forge-loop/` | `rules/skills.md` 开发阶段豁免 + ADR-003 |
| 三个 Agent | `D:\ai-configs\agents/` | 同左（无第二处） | 全局硬边界，无豁免 |

### 3.4 新增前置判据

「三个 Agent 由 Claude Code 按名解析成功」作为 V-04（Review 有真实执行证据）的**前置条件**。解析失败则 V-04 无法取证。

---

## 4. Constraints

- ForgeLoop 负责决定「何时调用 / 为什么调用 / 调用结果进入哪个 Gate」（§10），Agent 本身只负责专业执行。
- `code-architect` 在第一阶段（ADR-002 A/B/C/F/G/H/I/J/K）不参与闭环，仅落地定义，为能力 E 预留；不得因此提前实现 Plan 阶段逻辑。
- `code-reviewer` 的审查维度与产出按详细设计 §3.4 的双层结构执行：§10 六维产出 Finding（`Diff` 为审查输入），§37 六维给出 Gate 判定（`Scope` 为此前无人承载的维度），记为 Design Inconsistency DI-04。

---

## 5. Consequences

- 详细设计 §2.1 与 §4 T-02 已同步修订。
- 实施动作落点从「本仓库新建文件」变为「写入 `D:\ai-configs\agents/`」，涉及跨仓库写入，执行前需按 `rules/git.md` 走分支 + PR 流程，不直接向 `main` 推送。