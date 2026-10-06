# SPAC 设计规格:ForgeLoop 第一阶段端到端闭环

阶段：Detailed Design（`/SPAC-plus-auto` Step 1，评审第 1 轮修订版）
日期：2026-10-06
约束来源：ADR-001～ADR-006、`DESIGN.md`、全局 Version/Git/Security/Skills Rules
状态：评审第 1 轮已处理 17 条 mustFix，待风险视角补充后定稿

---

## 1. Purpose

交付一个真正可运行的 ForgeLoop 编排层（`skills/forge-loop/`），能在一轮工程工作中完成：

```text
选任务 → Implementation → Test → Review → Requirement Verification
→ Commit → Checkpoint → State Persistence → Recovery → Continue
```

并满足 ADR-002 的 V-01～V-13 完成判据（真实跑通一轮闭环 + Session Restart / Context Compaction / Interrupted Work 三类场景下可靠恢复）。

对应 `DESIGN.md` §109 的 A/B/C/F/G/H/I/J/K。

---

## 2. Boundaries

### 2.1 In Scope（第一阶段交付物）

| 产物 | 位置 | 说明 |
| :--- | :--- | :--- |
| 编排层 Skill（源码） | `skills/forge-loop/SKILL.md` | 路由 + 核心规则 + 工作流 + reference 加载 + 输出契约（§105 五项职责） |
| References（10 个） | `skills/forge-loop/references/` | §105 清单去掉 `audit-model.md`；承载全部细节 |
| 下层 Agent（部署） | `D:\ai-configs\agents/code-explorer.md`<br>`D:\ai-configs\agents/code-architect.md`<br>`D:\ai-configs\agents/code-reviewer.md` | 按 §10 职责定义（ADR-006 修订，见 §7.2） |
| 自检脚本 | `scripts/check-forge-loop.sh` | 结构化自检（T-09） |
| 运行状态结构 | `.ai/` | 第一阶段所需状态文件与 schema |
| 上游 installed skill | `D:\ai-configs\skills\skills/{iterative-development,mvp}` | ADR-001 / ADR-005 三段式第二段 |
| forge-loop deployed | `D:\ai-configs\skills\skills/forge-loop/` | ADR-003 部署目标 |
| provenance | `D:\ai-configs\docs/skills-provenance.md` | §104 |

`.ai/` 内第一阶段输入工件（由 T-10a 产出，承载 §109 的 A/B/C）：

| 工件 | 内容 | 依据 |
| :--- | :--- | :--- |
| `<runtime>/<feature>/source-index.md` | Document Discovery 产出，SRC 编号可被 Evidence.source 引用 | §17 |
| `<runtime>/<feature>/requirement-matrix.yaml` | REQ ID + Acceptance Criteria + status 流转 | §18–§21、§58 |
| `<runtime>/<feature>/mvp-scope.yaml` | §15 的 required / optional / deferred 三集合 | §15 |

### 2.2 Out of Scope（第一阶段明确不做）

| 项 | 依据 |
| :--- | :--- |
| §109 的 L Final Audit / M Audit Repair Loop / N Release Gate | ADR-002 延后 |
| `references/audit-model.md` | 随 L/M 延后（ADR-004） |
| SPEC / Plan 原生生成 | 复用本机 `spec` / `writing-plans`，ForgeLoop 只做路由与 Gate（ADR-002 §4） |
| 商业启动能力（定价/域名/收款） | ADR-005 M-04 |
| ForgeLoop Project Version 判定 | 服从全局 Version Management；B-03 未解除前不自行定版本号 |
| worktree 并行隔离 | 第一阶段串行闭环，`version-control.md` 仅声明不启用 |

### 2.3 既有能力判定（AGENTS.md §9 Reuse → Extend → Create）

| 能力 | 判定 | 理由 |
| :--- | :--- | :--- |
| SPEC 生成 | Reuse `spec` skill | 本机已装，语义匹配 §87 |
| Plan 生成 | Reuse `writing-plans` skill | 本机已装，语义匹配 §88 |
| 需求澄清 | Reuse `brainstorming` skill | 本次需求澄清即由它产出 |
| 详细设计 | Reuse `/SPAC-plus-auto` command | 本次设计即由它产出 |
| 单任务迭代 | Reuse 上游 `iterative-development` + Extend（Adapter） | ADR-001 |
| MVP Scope | Reuse 上游 `mvp` + Extend（Adapter） | ADR-005 |
| Git Checkpoint | Reuse 全局 `ai-git-workflow` | `rules/git-integration.md` §2 |
| 代码探索 | Extend（新建 `code-explorer`） | 无等价能力（ADR-006） |
| 架构边界判断 | Extend（新建 `code-architect`，第一阶段闲置） | 无等价能力，为 E/Plan 预留 |
| 代码 Review | Extend（新建 `code-reviewer`） | `code-review` skill 走 CodeRabbit 外部认证，非确定性，不适合强制 Gate |
| `executing-plans` | **排除** | 「有 plan 则一次执行完且任务间不停顿」，与 One-Task 逐个停顿方向相反；仅可用于单个 Task 内部步骤，不得用于迭代推进 |
| `spec-plan-executor` | **排除**（不用于迭代推进） | 规范→审查→审批→执行编排流，与 §21/§25 重叠；Phase 1 不引入 |

---

## 3. Technical Approach

### 3.1 编排层：SKILL.md 的形态

`SKILL.md` 只做五件事（§105）：

1. **Routing** —— 判定当前处于 §106 的 13 态（12 个主态 + 终态 `BLOCKED`；`BLOCKED` 已含在 13 态内，不另计），据此加载对应 reference。第一阶段对六态声明行为：
   - `SPECIFICATION` / `SPEC_REVIEW` / `PLANNING` → 路由到本机 `spec` / `writing-plans`，ForgeLoop 只执行 Gate 判定。
   - `FINAL_AUDIT` / `RELEASE_READY` / `COMPLETE` → 报告阶段收口，本阶段不执行 Audit / Release（ADR-002 延后 L/M/N），明确提示进入第二迭代。
2. **Core Rules** —— 不可违反的硬约束：One-Task Rule（§32）、Evidence Required（§39）、Design Authority（`AGENTS.md` §5）、Git/Version 服从全局规则。
3. **Workflow** —— §82 的十五步职责序列。第一阶段按能力集启用：第 1–4、7–14 步。第 5、6 步（SPEC / Plan）只保留路由与 Gate 声明，执行体由本机 `spec` / `writing-plans` 承担；第 15 步（Final Audit）报告为延后。
4. **Reference Loading** —— 渐进披露：SKILL.md 只列 reference 清单与加载时机，细节全在 references。
5. **Output Contract** —— 每轮的固定产出：更新后的状态文件、Evidence、Checkpoint 记录。

SKILL.md 不含：具体状态机细节（→`lifecycle.md`）、Gate 判据（→各 model 文件）、上游适配细节（→`iterative-integration.md`）。

### 3.2 References 的职责划分（§105 权威，10 个）

| reference | 承载内容 | 关键设计依据 |
| :--- | :--- | :--- |
| `architecture.md` | ForgeLoop 全局编排视图：依赖的 Agent / Skill / Rule / Git Workflow 及其调用时机；既有能力纳入/排除判定（复用 / 扩展 / 排除 + 理由） | §110、§2.3 |
| `lifecycle.md` | 13 态状态机 + 合法转移（失败回 `ITERATIVE_DEVELOPMENT`，范围/SPEC 变更回 `MVP_DEFINITION`/`SPECIFICATION`）+ 第一阶段激活状态集合 | §106、§107 |
| `mvp-integration.md` | MVP Scope Engine：调用上游 `mvp` 作启发式，Gate 判据按 §16 四问，产出 §15 的 required/optional/deferred | §14–§16、§86、ADR-005 |
| `iterative-integration.md` | 上游 Adapter：逐条覆盖上游暂停点；Task State 与 Gate/Evidence 的权威来源划清；上游升级 compatibility check | §3.2、§89、§103、ADR-001 |
| `requirement-model.md` | Requirement ID 格式（`REQ-001`，§19）、Acceptance Criteria（§20）、Document Review（§21）、Requirement State Machine（§58）、Evidence（§39）、Evidence 失效（§59）。**`I-0xx` 为 §108 不变量编号，与 Requirement ID 分属两套命名空间，不可互换** | §18–§21、§58、§59 |
| `task-model.md` | **Task State 唯一权威 reference**（§29 九态）、Task 结构（`<runtime>/<feature>/tasks.md`）、One-Task Rule、Requirement→Task 映射 | §27–§32 |
| `goal-mode.md` | Goal Mode vs Manual Mode 判定与推进行为；`/goal` 会话集成 | §83–§85 |
| `version-control.md` | Checkpoint 的 Git 实现（复用全局 `ai-git-workflow`，不自建 Policy）；分支命名、提交格式、合并与删除、推送策略一律取 `rules/git-integration.md` §8 与全局 `ai-git-workflow`，reference 内不复制也不重述；worktree 声明但不启用 | §53、§54、`rules/git-integration.md` §2/§3/§8 |
| `evidence-model.md` | Evidence 八字段（source / spec / task / implementation / tests / review / runtime / acceptance）、`status: verified` 判定、Evidence Invalidation | §38、§39、§59 |
| `recovery.md` | Resume 流程（Load State → Inspect → Reconcile → Resume）、六类中断场景处理、Reconciliation 规则 | §79、§98、§99、`AGENTS.md` §13、`rules/state-and-recovery.md` |

### 3.3 两个 Adapter 的核心机制

**iterative-integration（ADR-001）** —— 全设计最关键的机制点。

上游实测含 **4 处独立强制暂停 + 1 句总括强制**，外加 frontmatter description 的路由层排除：

| # | 上游位置 | 原文要点 | 覆盖策略 |
| :--- | :--- | :--- | :--- |
| 1 | `### Sub-task Iteration (IMPORTANT)` | Do NOT start or even consider the next sub-task until you ask the user for permission and they say "yes" or "y" | Goal Mode 替换为 §83 的 Checkpoint→Evidence→Continue；Manual Mode 保留 §84 暂停 |
| 2 | `## Quality Controls` 第 4 条 | Ask for user approval before moving to the next sub-task | 同上 |
| 3 | `## Communication` 第 3 条 | Ask for permission to continue with the next sub-task | 同上 |
| 4 | `## Workflow` 步骤 5–6 | Ask: "Ready for the next sub-task?" / Wait for "yes" or "y" | 同上 |
| 5 | 文末 | Follow the above steps EXACTLY!!! NO EXCEPTIONS!!! | 逐条覆盖表优先于该总括声明 |
| 6 | frontmatter `description` | …rather than letting the agent run the list unattended…（把 unattended 排除在适用场景外） | **路由层**：Goal Mode 下由 SKILL.md §3.1 Routing 显式选定该技能作为 Execution Engine（§89），并在 `iterative-integration.md` 写明该排除条件在 Goal Mode 下由 ForgeLoop Mode 覆盖 |

判定规则：**上游任一暂停点在 Goal Mode 下均失效。**

**覆盖不依赖提示层声明。** 「在 reference 中声明优先级」属提示层对抗，无法保证上游的 `NO EXCEPTIONS!!!` 语气不压过 ForgeLoop 控制流。设计采用两条可测机制：

- **结构降级** —— ForgeLoop 不把上游 SKILL.md 全文载入主上下文，只把其中三条语义（Task 粒度、任务清单维护、Relevant Files 维护）内联进 `task-model.md`；上游原文作为 `iterative-integration.md` 的参考附件保留，不参与指令竞争。CK-02/CK-05 判据用于检测上游语义漂移。
- **续行标记** —— Goal Mode 下每次 Checkpoint 后，ForgeLoop 在 Evidence 中输出机器可检的续行标记：

```text
mode: goal
next: TASK-xxx
```

  该标记是「未被上游暂停拦截」的反证。T-10b 断言：连续 ≥2 个 Task 完成，每次 Checkpoint 后均出现该标记，且全程无面向用户的 `Ready for the next sub-task?` 类提问。

**`/goal` 前置** —— Goal Mode 的成立前提是存在 Active `/goal`。`/goal` 是 Claude Code 内建命令（code.claude.com/docs/en/goal），其可用性受 workspace trust 与 `disableAllHooks` / `allowManagedHooksOnly` 约束。T-01 含运行时实测；不可用时本节的 Goal Mode 覆盖点为不可达，按 §6 记 Blocker，闭环演练退为 Manual Mode 全链路并在验收报告中显式标注，不将 Manual Mode 结果记作 Goal Mode 已验证。

除暂停点外的复用/覆盖裁定：

| 上游内容 | 裁定 |
| :--- | :--- |
| 一次一个 Task | 复用（§32） |
| 任务清单勾选维护 | 复用（§28 checkbox） |
| Relevant Files 维护 | 复用（§29 相关，纳入 Task 完成定义） |
| Quality Controls 的 lint/test 环节 | 复用，作为 Gate 之前的早期拦截 |
| **Task State 九态** | **以 DESIGN.md §29 为准，来源为 `task-model.md`；上游无任何 Task State 定义可供保持**（ADR-001 §3 该行判定由「契合」修正为「部分契合：上游仅覆盖 §28 checkbox」） |
| **Gate 与 Evidence** | **唯一来源为 §36–§39；上游 Quality Controls 只提供早期拦截，Gate 通过与否由 ForgeLoop 判据决定** |
| `prp.txt` 同步维护指令 | 该条不适用，跳过（ForgeLoop 无该文件，文档落盘走 `rules/artifact-persistence.md`）；纳入 compatibility check 判据，避免上游升级时无声丢失 |
| Task 粒度 | 复用，不因 Goal Mode 放宽（ADR-001 C-05） |

**上游升级 compatibility check（§103 三段式，ADR-001 C-06 / ADR-005 M-06）** —— 本详细设计按 DESIGN 要求产出判定标准：

| 编号 | 判据 | 失败处置 |
| :--- | :--- | :--- |
| CK-01 | 上游 SKILL.md 的 Instructions / Quality Controls / Communication / Workflow 四个小节全部存在 | 停，升 Design Inconsistency |
| CK-02 | 四处暂停点（表 3.3 第 1–4 项）的语义文本指纹未变 | 停，重做覆盖表并复跑 T-10 断言 |
| CK-03 | Relevant Files 与 tasks.md 维护指令未变 | 停，更新 `iterative-integration.md` |
| CK-04 | 上游未新增 Task State、Gate、Evidence 语义 | 停，评估与 §29/§36–§39 的冲突 |
| CK-05 | 上游 frontmatter description 未变更 | 停；按名解析落空时按 §6 报 BLOCKED |
| CK-06 | `git hash-object` 与 ADR-001 §2 指纹一致 | 停，不一致即按 §6 报 BLOCKED |

比对时机：T-01 安装后、每次上游升级前、每次 T-10 演练前。

**mvp-integration（ADR-005）** ——

- 调用上游 `mvp` 获取启发式（能否周末交付、能否先人工、是否已有更简单实现）。
- Gate 判据以 §16 四问为准，上游启发式不得替代判据（M-02）。
- 产出契约为 §15 的 `required` / `optional` / `deferred` 需求集合，不输出商业启动内容（M-04）。
- 职责排除（M-05，原样）：不承担 Task Execution / Git / Testing / Final Audit / Goal Completion。
- 上游输出若被误用于任务执行或 Gate 判定 → 按 M-02/M-05 收束回 §15/§16（见 §6）。

### 3.4 下层 Agent（ADR-006 修订，见 §7.2）

| Agent | 触发时机 | 输出 | 第一阶段参与 |
| :--- | :--- | :--- | :--- |
| `code-explorer` | Implement 前（§33 Code Exploration） | 项目结构/调用关系/依赖/已有实现/测试/影响面 | 参与 |
| `code-architect` | Plan 阶段（§34） | 技术方案/架构边界/模块关系/风险/实现策略 | 闲置（为 E/Plan 预留） |
| `code-reviewer` | §37 Code Review Gate | 见下方双层结构 | 参与 |

**code-reviewer 双层结构** —— `DESIGN.md` §10 的 Agent 职责清单与 §37 的 Gate 审核清单是两个不同的六维：

| 层 | 维度 | 用途 |
| :--- | :--- | :--- |
| 审查产出（§10） | Diff / Correctness / Regression / Security / Maintainability / Architecture | `Diff` 是审查输入，其余五维产出 Finding |
| Gate 判定（§37） | Correctness / Architecture / Security / Regression / Maintainability / **Scope** | 给出 PASS / FINDINGS |

`Scope` 维度此前在 §10 与本规格中无人承载。其检查内容：改动是否超出当前 Task 的授权范围（对应 §32 One-Task Rule、§101 Minimal Modification）。本设计记为 Design Inconsistency DI-04，按「§10 产出 + §37 判定」双层执行。

ForgeLoop 决定「何时调用 / 为什么调用 / 结果进入哪个 Gate」（§10）。

### 3.5 `.ai/` 运行状态结构（开放项 1 的解法）

依据 `DESIGN.md` §55/§56/§79/§80、`AGENTS.md` §12、`rules/state-and-recovery.md` §2/§3、`rules/artifact-persistence.md` §6。

```text
.ai/                                  （Owner = FORGELOOP 时；Owner = CURRENT_PROJECT 时为 .dev-ai/）
├── development-status.yaml           Goal / Phase / 当前 Task / 当前 Iteration / Checkpoint / Blocker / Mode
├── version-state.yaml                §55 schema：goal.id / mvp.version / spec.version / plan.revision
│                                     / iteration.current / git.branch·head·clean
│                                     project.version 在 B-03 解除前写显式待定值
├── verification-state.yaml           进行中的 Gate 与各 Gate 的验证结论
└── <feature>/
    ├── tasks.md                      任务清单（上游路径兼容）
    ├── source-index.md               A：Document Discovery
    ├── requirement-matrix.yaml       B：Requirement Extraction
    ├── mvp-scope.yaml                C：MVP Scope
    └── evidence.yaml                 I：Evidence 八字段
```

第一阶段不含 `audit-state.yaml`（L/M 延后）。

**version-state.yaml 必须存在**：`DESIGN.md` §98 Goal Resume 恢复链明列读取它，§99 Compact Resume 三源之一，§53 Checkpoint 中 `spec.version` 的唯一持久化来源。B-03 只约束 `project.version` 这一个字段的取值来源，与文件是否存在无关。该字段在 B-03 解除前写显式待定标记（如 `pending: B-03`），其余字段正常维护。

**Checkpoint 双重落点**：结构化字段进 `.ai/development-status.yaml` 与 `version-state.yaml`（id / iteration / git.commit）；Git 记录进版本历史，走全局 Workflow。

**路径按 Owner 解析**：`<runtime>` = `.ai/`（Owner=FORGELOOP）或 `.dev-ai/`（Owner=CURRENT_PROJECT）。`task-model.md` 与 `iterative-integration.md` 一律用 `<runtime>` 表述，不写死 `.ai/`；上游硬编码的 `.ai/[feature]/tasks.md` 兼容性按 Owner 分别处理。

**`.ai/` 是否入库**：属仓库 `.gitignore` 配置决定，不构成 Git Policy（全局 `rules/git.md` 未对任何目录的入库与否作规定，§79 只讲持久化位置）。第一阶段选择：`.ai/` 下的状态文件**纳入版本控制**，仅在 Checkpoint 时提交，迭代中途不入库。理由：`rules/artifact-persistence.md` §6 将 `.ai/` 定义为 durable workflow state，`rules/state-and-recovery.md` §3 要求 Checkpoint / Resume Position 不得只存于对话。

**状态/Git 冲突的可执行判据**（`rules/state-and-recovery.md` §5 只给了示例，未给判据，此处补齐）：

```text
比对对象 = 代码与文档路径（排除 .ai/）
命令     = git status --porcelain -- ':!.ai/'
冲突条件 = ① 上式非空（代码/文档有未提交改动）
         且 ② .ai/development-status.yaml 的 task 状态为 complete
处置     = STOP AUTO-PROGRESSION → 进入 recovery.md 的 Reconcile
```

`.ai/` 自身入库会带来「每次状态更新即产生工作树改动」，与 §5 示例一自触发。因此 `.ai/` 的变更**不计入**「Uncommitted Changes」判据，比对对象限定为代码与文档路径。相应地 §6 增一条 Contingency：恢复时工作树脏但改动仅限 `.ai/`，属第一阶段预期，正常继续。

### 3.6 验证策略与证据形态（开放项 2 的解法）

Skill 型交付物无编译、无单测框架。第一阶段采用四类证据组合，全部落盘：

| 证据类型 | 验证对象 | 形态与路径 | 依据 |
| :--- | :--- | :--- | :--- |
| 结构化自检 | SKILL.md / references / agents 是否齐备、frontmatter 合法、reference 交叉引用可解析、`<runtime>` 路径按 Owner 正确、**上游副本 blob 未偏离登记指纹** | `scripts/check-forge-loop.sh`；**必须以非零退出码失败才算有效**（T-09 负向证据：注入一个故意缺失的 reference 引用，脚本必须非零退出）；文件名校验基准 = §105 的 11 项（第一阶段 10 项，延后 `audit-model.md`），§81 清单为历史遗留不作基准；B-03 解除前 `SKILL.md` frontmatter 不写 version 字段，自检不得把 version 存在性作为合法判据 | §105、ADR-004 |
| 闭环演练证据 | 选任务→…→Continue 全链路 | `.ai/<feature>/evidence.yaml` + `doc/reviews/<feature>/iteration-review.md` | V-01/V-02 |
| Gate 证据 | Test / Review / Requirement Verify | 各 Gate 的实际执行记录与结论，落 `doc/verification/<feature>/`；Review 逐条对应 §37 六维 | §36/§37/§38、V-03～V-05 |
| 状态与恢复证据 | Persistence / Checkpoint / Recovery | `.ai/` 状态文件前后对比 + `doc/verification/<feature>/recovery-record.md` + Git 记录 | §53、§79、§98/§99、V-06～V-08 |

### 3.6.1 Test Gate 在本阶段的形态

第一阶段产物是 markdown（SKILL.md + 10 references + 3 agents），仓库无构建/测试/lint 工具链。`DESIGN.md` §36 的选项（Lint / Unit / Integration / E2E / Build / Runtime）对纯 markdown 任务不适用。处置：

| Gate 项 | 第一阶段取值 | 理由 |
| :--- | :--- | :--- |
| Lint / Unit / Integration / E2E / Build | **N/A** | 仓库无工具链；`rules/artifact-persistence.md` §10 的 File Verification（File Exists + Content Is Complete + Correct Path + Correct Owner）由结构化自检承担 |
| Test | 结构化自检（`scripts/check-forge-loop.sh`） | 作为本阶段 Test Gate 主体；**正负双向证据缺一不算通过**（T-09 正向 + T-09 负向非零退出） |
| Runtime | **N/A（显式）** | 无可运行产物；Evidence 的 `runtime` 字段写 `N/A: phase-1 artifact is markdown, no runtime surface`，**不留空**，避免被读成通过 |

T-10b 的演练 Task 须额外具备可判定的 Requirement Verification 判据，避免 Test/Verify 同时退化为自证。

### 3.6.2 Compaction 取证协议

Context compact 由 harness 触发、agent 无法控制时机与内容（`DESIGN.md` §99 只声明「不把 Current Task / Requirement / Version / Checkpoint 只放上下文」，未给验证手段）。取证协议：

```text
1. 压缩前：计算 .ai/development-status.yaml 的 sha256，与当前 Iteration ID 一并
   写入 doc/verification/<feature>/compaction-probe.md
2. 触发压缩：/compact 或自然触发
3. 恢复后：agent 重新读取 <runtime>/ 全量状态，重算 sha256 追加到 probe 文件尾
4. 判定：两值一致 → 通过；不一致 → V-08 FAIL
5. 声明：probe 中显式写 restored_from: files-only
        —— 恢复结论只能来自文件读取，不来自对话记忆
```

其余六类中断场景的取证方式（`AGENTS.md` §13）：Session Restart / Interrupted Work 为 V-08 验收场景；Agent Failure 取子代理退出状态与 `verification-state.yaml` 中的中断位置；Partial Execution 取工作树变更与 tasks.md 勾选状态的差集；Unexpected Git State 取 §3.5 判据的比对结果。

### 3.6.3 上游指纹的运行时校验

指纹必须用 `git hash-object`（默认，含 CRLF 归一化），**不使用文件字节数** —— 实测库副本 2203 B vs ADR 记录 2131 B（CRLF 转换），但 `git hash-object` 结果与 ADR-001 §2 指纹一致。`--no-filters` 会得到不匹配值，不可使用。

该命令列为 T-09 结构化自检的常驻项，使 compatibility check 具备运行时触发点，而不只在安装时发生一次。偏离时按 §6「上游副本偏离登记指纹」处置。

### 3.7 Evidence 包结构（贯穿 Test/Review/Verify/Checkpoint）

每个 Requirement 的 Evidence 按 `DESIGN.md` §39 的**八字段**落盘：

```text
source / spec / task / implementation / tests / review / runtime / acceptance
```

最终 `status: verified`。落盘位置唯一：`.ai/<feature>/evidence.yaml`（运行态结构化）+ `doc/verification/<feature>/`（文档层记录）。**不再使用「或评审记录」这类模糊表述。**

Checkpoint 记录含 `goal.id` / `iteration.id` / `task.id` / `git.commit` / `spec.version` / `progress.requirements`（§53）。第一阶段 SPEC/Plan 不在范围内，`spec.version` 取显式缺省标记（如 `absent: not-started`），字段保留不省略。

---

## 4. Concrete Actions（实施分解，按 ADR-002 One-Task 推进）

| # | Task | 产出 | 依赖 |
| :--- | :--- | :--- | :--- |
| T-01 | 核验 `/goal` 可用 + 按 pinned commit 取源安装上游 + 校验 blob | ① `/goal` 运行时实测：确认本会话可用（`/goal` 为 Claude Code 内建命令，受 workspace trust 与 `disableAllHooks` 约束，见 code.claude.com/docs/en/goal）；不可用则 Adapter 的 Goal Mode 覆盖点为不可达，记 Blocker ② `iterative-development`（commit `f18bd2e3`）与 `mvp`（commit `338c4301`）安装到库内 ③ `git hash-object <副本>/SKILL.md` 逐项比对 ADR 指纹（`cf101122…` / `a42a7996…`） | ADR-001、005 |
| T-02 | 新建三个 Agent 到规范位置并验证可解析 | `D:\ai-configs\agents/` 三份（ADR-006 修订）；Claude Code 按名解析成功 | ADR-006 |
| T-03 | 定义 `.ai/` 状态 schema | `development-status.yaml`（含 Checkpoint 字段）、`version-state.yaml`（§55 schema）、`verification-state.yaml`、`<feature>/tasks.md` 模板；含 `<runtime>` 按 Owner 解析规则；含状态/Git 冲突的可执行判据（§3.5） | §3.5 |
| T-04 | 写 `references/` 模型类 | `requirement-model.md`、`task-model.md`、`evidence-model.md` | §18–§21、§27–§32、§39 |
| T-05 | 写 `references/` 流程类 | `lifecycle.md`、`goal-mode.md`、`version-control.md`、`recovery.md` | §83–§85、§53、§79/§98/§99 |
| T-06 | 写 `references/architecture.md` | 依赖调用视图 + §2.3 既有能力判定表 | §110、§2.3 |
| T-07 | 写两个 Adapter reference | `mvp-integration.md`、`iterative-integration.md`（含逐条覆盖表、CK-01～CK-06、Goal Mode 续行标记） | ADR-001、005 |
| T-08 | 写 `SKILL.md` 编排层 | 五项职责 + Phase 路由（含六态第一阶段行为）+ reference 加载 | T-04～T-07 |
| T-09 | 结构化自检通过（含负向测试） | `scripts/check-forge-loop.sh` + 正向通过证据 + **负向证据：注入一个故意缺失的 reference 引用，脚本必须非零退出** | T-01～T-08 |
| T-09b | 部署 forge-loop 到 harness 并验证可解析 | `manage-skills adopt` + `set-source` → Registered；`manage-skills deploy` → Deployed；新会话按名解析 forge-loop → Loadable。三项独立确认。**T-10 未通过则 T-10b 不启动**（避免用手工粘贴 reference 做出假闭环） | T-09 |
| T-10a | 演练准备：产出 A/B/C 三项输入工件 | `source-index.md`、`requirement-matrix.yaml`、`mvp-scope.yaml` | T-03 |
| T-10b | 闭环演练：真实 Task 跑通 A→Continue | **必须用已部署副本执行**。产出 `.ai/<feature>/evidence.yaml` + `doc/reviews/<feature>/iteration-review.md`。断言：① Goal Mode 连续完成 ≥2 个 Task 且全程无用户逐任务确认 ② 每个 Checkpoint 后 Evidence 中出现机器可检的续行标记 `mode: goal / next: TASK-xxx`。若被上游暂停拦截（出现 `Ready for the next sub-task?` 类提问或标记缺失）→ 按 §6 升 Design Inconsistency | T-09b、T-10a |
| T-11 | Gate 证据固化 | `doc/verification/<feature>/` 下 Test/Review/Verify 记录；Review 证据逐条对应 §37 六维 | T-10b |
| T-12 | Checkpoint + State Persistence 验证 | Git 记录 + `.ai/` 状态文件前后对比；含冲突判据负向测试（故意制造 Runtime/Git 不一致，断言停在 Reconcile 不推进 Task） | T-11 |
| T-13 | Recovery 演练 | `doc/verification/<feature>/recovery-record.md`；Restart / Compaction / Interrupted Work 三场景状态逐字段比对，Compaction 按 §3.6 的 probe 协议取证 | T-12 |
| T-14 | 状态一致性负向验证复核 | 冲突判据与 compaction probe 的复跑记录 | T-13 |
| T-15 | 结构自检 + 全闭环证据汇总，映射 V-01～V-13 | `doc/audits/mvp-acceptance.md` | T-14 |

T-10b～T-13 是 ADR-002 V-02～V-08 的直接证据来源；T-15 完成 MVP 验收。

演练任务的选材约束：T-10b 的真实 Task 需具备可判定的 Test Gate 与 Verification 判据（`rules/testing.md` 要求先定成功标准），不得选纯文档改写类任务作为唯一演练样本，否则 Test Gate 与 Requirement Verification 会退化为自证。

### 4.1 上游缺失时的降级路径

`slavingia/mvp` 在库内不存在（本轮审计实测），T-01 安装失败会阻塞能力 C。降级规则：

```text
mvp 安装失败
  ↓
记录 Blocker（Cause / Impact / Required Action / Context）
  ↓
MVP Scope 能力（C）由上游启发式缺席状态运行：
  §15 的 required/optional/deferred 由 §16 四问直接产出
  mvp-integration.md 保留为待接入占位并记录 Blocker
  ↓
第一阶段其余能力（A/B/F/G/H/I/J/K）继续推进，不整体停摆
```

不做的动作：以内置实现顶替上游、删除 `DESIGN.md` 的上游依赖定义、把上游降级为可选依赖（ADR-001 §7、ADR-005 M-05）。

---

## 5. Success Criteria

| 编号 | 判据 | 证据来源（任务号 + 文件路径） |
| :--- | :--- | :--- |
| V-00 | forge-loop 在目标 harness 中可被按名解析并载入 references（前置条件） | T-09b → Registered / Deployed / Loadable 三项证据 |
| V-01 | 端到端可运行闭环（用已部署副本执行） | T-10b → `.ai/<feature>/evidence.yaml` |
| V-02 | 至少一个真实工程任务跑完整链路 | T-10b → `evidence.yaml` |
| V-03 | Test 有真实执行证据：**T-09 负向测试（注入故障 → 脚本非零退出）+ T-11 正向运行，缺一不算通过** | T-09 + T-11 → `doc/verification/<feature>/` |
| V-04 | Review 有真实执行证据，逐条对应 §37 六维（含 Scope）。**前置：`code-reviewer` 在目标 harness 中可被按名解析，解析失败即 BLOCKED** | T-02 + T-11 → `doc/verification/<feature>/` + `doc/reviews/<feature>/iteration-review.md` |
| V-05 | Requirement Verification 有真实执行证据（Evidence 八字段 → verified） | T-11 → `evidence.yaml` |
| V-06 | Checkpoint 由全局 Git Workflow 形成的真实记录 | T-12 → Git log + `.ai/development-status.yaml` |
| V-07 | State Persistence 真实落盘证据 | T-12 → `.ai/` 状态文件前后对比 |
| V-08 | Recovery 三场景状态一致证据 | T-13 → `doc/verification/<feature>/recovery-record.md` |
| V-09 | 无超前实现（L/M/N、audit-model.md、商业能力均未出现） | T-15 + 范围检查 |
| V-10 | Document Discovery（A）：产出 `source-index.md`，SRC 编号可被 Evidence.source 引用 | T-10a → `.ai/<feature>/source-index.md` |
| V-11 | Requirement Extraction（B）：产出 `requirement-matrix.yaml`，含 REQ ID + Acceptance Criteria + status 流转 | T-10a → `requirement-matrix.yaml` |
| V-12 | MVP Scope（C）：产出 §15 三集合并通过 §16 四问 | T-10a → `mvp-scope.yaml` |
| V-13 | 上游来源指纹校验通过：blob 与 ADR-001/ADR-005 记录一致，或差异清单 + Adapter 判定结论已落盘 | T-01 → provenance 条目 |

### 5.1 完成定义（两层）

**本阶段可判定条件** = V-00～V-13 全部有证据 + `DESIGN.md` §108 中不依赖 L/M/N 的不变量（I-001～I-006、I-009、I-010）成立。

**项目级完成条件** = `AGENTS.md` §15 六项（Required Requirements Verified + Required Tests Passed + Required Reviews Passed + Final Audit Passed + Version State Valid + Git State Valid），在 L 交付且 B-03 解除后判定。

**明确延后至 ADR-002 第二迭代**：§108 的 I-007（Final Audit compares implementation against source requirements）与 I-008（Goal cannot be complete while Required Requirements remain unverified）依赖 L；`AGENTS.md` §15 的 Final Audit Passed 依赖 L；Version State Valid 依赖 B-03。第一阶段收口不等于 Goal 收口。

**证据缺失时的判定规则**：V-00～V-13 任一条缺少证据即为未通过，不得以「机制已实现」替代证据（`rules/testing.md`）。因上游 mvp 不可得而按 §4.1 降级时，V-12 的证据降为「§16 四问直接产出」并在验收报告标注上游缺席状态，不计为完整通过 C。

---

## 6. Contingency（失败路径）

| 风险 | 触发信号（可被 agent 实际检测） | 处置 | 依据 |
| :--- | :--- | :--- | :--- |
| 上游副本偏离登记指纹 | T-09 自检执行 `git hash-object <库副本>/SKILL.md`（默认过滤，不用 `--no-filters`）≠ provenance 登记值 | 跑 CK-01～CK-06，更新覆盖表并重跑 T-10b 断言 | §3.6.3、ADR-001 C-06 |
| 上游拉取失败 | T-01 拉取命令非零退出 | Mirror → Retry once → Upstream 回退顺序；仍失败则按 §4.1 降级并报 Blocker，不静默替换 | `rules/domestic-mirror.md` §6 |
| 上游内容漂移 | `git hash-object` 与 ADR 指纹不一致（CK-06） | 停，不记 provenance，按 §6 报 BLOCKED | ADR-001 §7、`rules/state-and-recovery.md` §8 |
| 上游兼容性破坏 | CK-01～CK-05 任一不通过 | 暂停适配，重做覆盖表并复跑 T-10b 断言 | §103、ADR-001 C-06 |
| Adapter 覆盖失效 | T-10b 断言失败：Checkpoint 后出现面向用户的 `Ready for the next sub-task?` 类提问，或 Evidence 中缺少 `mode: goal / next: TASK-xxx` 续行标记 | 升 Design Inconsistency，不进入下一 Task | §3.3 判定规则 |
| `/goal` 不可用 | T-01 运行时实测确认本会话无法使用 Active `/goal`（workspace trust 或 hooks 被禁用） | 记录 Blocker；Goal Mode 覆盖点标为不可达；闭环演练退为 Manual Mode 全链路并在验收报告显式标注，不将 Manual Mode 结果记作 Goal Mode 已验证 | §3.3 `/goal` 前置、§5.1 |
| `code-reviewer` 无法解析 | T-02 后按名解析失败 | 记 Blocker；V-04 无法取证，H 能力不得判定完成 | ADR-006 §3.4 |
| forge-loop 未部署 | T-09b 三项确认任一未通过 | T-10b 不启动，不以手工粘贴 reference 方式做假闭环 | ADR-003 §4 |
| 上游 mvp 输出越界 | mvp 输出被用于任务执行或 Gate 判定 | 按 M-02/M-05 收束回 §15/§16 | ADR-005 |
| Git 与运行状态不一致 | §3.5 判据：`git status --porcelain -- ':!.ai/'` 非空 且 `development-status.yaml` 的 task 状态为 complete | `STOP AUTO-PROGRESSION`，先 Reconcile 再继续；Reconcile 依据为 `<runtime>/` 全量状态与 Git 实际状态的逐项比对 | §3.5、§98/§99、`rules/state-and-recovery.md` §5 |
| 恢复时工作树脏（仅 `.ai/`） | `git status` 改动仅限 `.ai/` 路径 | 属第一阶段预期（状态文件仅 Checkpoint 时提交），正常继续 | §3.5 |
| 中断 | 六类场景（`AGENTS.md` §13） | `recovery.md` 流程：Load → Inspect → Reconcile → Resume；Context Compaction 按 §3.6.2 probe 协议取证 | §98/§99 |
| 无法安全继续 | 缺凭证 / 依赖不可达 / 需求矛盾 | 进入 `BLOCKED`，报告字段取并集：Requirement（受阻的 REQ/TASK）+ Blocker + Cause + Impact + Evidence（已取得的证据）+ Required Action + Context | §97 与 `rules/state-and-recovery.md` §8 并列要求 |
| Version 判定受阻 | B-03 未解除 | `project.version` 写显式待定值，不自定版本号；版本相关交付延后并报告 | `rules/version-management.md`、`AGENTS.md` §6 |
| 自检失败 | T-09 检查项不通过 | 修复后重跑，不进入演练 | `rules/testing.md` |

---

## 7. Design Inconsistency 记录（记录，不改 Design）

依 `AGENTS.md` §5，以上均不触发对 DESIGN.md 的反向修改；修改 Design 本身需用户明确指示。

| 编号 | 不一致 | 处置 |
| :--- | :--- | :--- |
| DI-01 | §81 的 references（8 个）与 §105 的 references（11 个）冲突 | 以 §105 为准（ADR-004）；§81 旧清单记录为历史遗留 |
| DI-02 | 文档正文多处写 `ForgeLoop.DESIGN.md`，磁盘为 `DESIGN.md` | 以 `rules/git-integration.md` §10 为准：统一引用方，文件名以磁盘为准 |
| DI-03 | `slavingia/mvp` 是商业顾问人格，§15/§16 是工程 scope 契约，产出不同构 | Adapter 收束（ADR-005） |
| DI-04 | §10 的 Agent 六维与 §37 的 Gate 六维不一致（`Diff` vs `Scope`） | 按「§10 产出 + §37 判定」双层执行（§3.4），待 DESIGN.md 层面裁定 |
| DI-05 | ADR-001 §3 把上游 tasks.md 勾选判定为「§28 checkbox + §29 Task State 契合」，实测上游无 Task State 定义 | ADR-001 §3 判定修正为「部分契合」，C-05 措辞同步修订（§3.3） |
| DI-06 | ADR-006 原把 Agent 放项目目录，类比 ADR-003 的 skill 形态 | skills 有 authoring 豁免、agents 无；依 `AGENTS.md` §2 Global Rule wins 强制修订到 `D:\ai-configs\agents/` |
| DI-07 | ADR-001 / ADR-005 记录的 SKILL.md 字节数（2131 / 3748 B）与 Windows 工作区副本字节数不符（CRLF 转换） | 指纹统一改用 `git hash-object`（默认过滤）；字节数不作指纹依据（§3.6.3） |
| DI-08 | `DESIGN.md` §36 Test Gate 的选项（Lint/Unit/Integration/E2E/Build/Runtime）对第一阶段纯 markdown 产物不适用 | 结构化自检承担本阶段 Test Gate 主体，Runtime 显式标 N/A 并写明理由（§3.6.1） |

---

## 8. 与 Design / 全局规则的关系

- 本设计不修改 `DESIGN.md`。
- Checkpoint / Branch / Commit / PR / Merge / Tag / Push 全部服从全局 `rules/git.md` 与 `ai-git-workflow`；ForgeLoop 不建第二套 Git Policy。
- 版本相关一律服从全局 Version Management，不自行决定 major/minor/patch/tag。
- Skill 与 Agent 的安装位置一律服从全局 `rules/environment.md` 的 canonical targets（`D:\ai-configs`）；仓库内只保留 skill 源码（skills 有 authoring 豁免），Agent 无此豁免。
- 安全、文件操作、删除等服从全局 `rules/security.md` / `rules/filesystem.md`。