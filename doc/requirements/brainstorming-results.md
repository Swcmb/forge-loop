# Brainstorming Results: ForgeLoop 第一阶段需求澄清

日期：2026-10-06
方式：brainstorming（逐项澄清）
输入：`doc/audits/repository-audit.md` §9 的 8 项待澄清
输出：6 份 ADR（已裁定）+ 2 项移交详细设计

---

## 1. 已裁定的决策

| ADR | 主题 | 结论 |
| :--- | :--- | :--- |
| ADR-001 | 上游 `aspiers/iterative-development` 接入 | 接入 `aspiers/ai-config` 真实上游（已固定 commit/blob）；upstream → installed skill → adapter；上游实测 6 处冲突点（4 处暂停指令 + 1 句总括强制 + 1 处 description 路由排除），Adapter 逐条覆盖；Task State 与 Gate/Evidence 权威来源划清至 DESIGN.md |
| ADR-002 | MVP Scope | 第一阶段 = §109 的 A/B/C/F/G/H/I/J/K 端到端可运行闭环；L/M/N（Final Audit、修复循环、Release Gate）延后；完成判据 V-01～V-13 |
| ADR-003 | 交付物位置 | `D:\ForgeLoop\skills/forge-loop/` 为权威源码（随仓库版本化）；`D:\ai-configs` 技能库为部署目标（manage-skills adopt + deploy）。该形态仅适用 skill |
| ADR-004 | references 清单 | 以 §105 为准（11 个）；第一阶段建 10 个，仅延后 `audit-model.md`（随 L/M）；§81 旧清单视为历史遗留 |
| ADR-005 | `slavingia/mvp` 接入 | 上游作启发式输入（已固定 commit/blob）；Gate 判据与产出契约归 §15/§16（required/optional/deferred）；商业启动话术不进入 ForgeLoop 输出 |
| ADR-006 | §10 下层 Agent | **已修订**：安装到 `D:\ai-configs\agents/`（非项目目录）；与 §10 职责对齐；`code-architect` 第一阶段闲置，为 E/Plan 预留；review 走「§10 产出 + §37 判定」双层 |

---

## 2. 移交详细设计的开放项

以下两项属 `/SPAC-plus-auto` 详细设计范围，本阶段不作决定：

| 项 | 已知约束 | 待设计 |
| :--- | :--- | :--- |
| `.ai/` 状态文件实际结构 | `DESIGN.md` §79/§80 已定 Owner=FORGELOOP → `.ai/`；`rules/state-and-recovery.md` §2 定最小集合 Goal/Phase/Task/Iteration/Checkpoint/Blocker/Verification；§80 示例含 `development-status.yaml` / `version-state.yaml` / `audit-state.yaml` / `<feature>/tasks.md` | 第一阶段（不含 L/M）的确切文件与 schema |
| 验证方式 | ADR-002 V-01～V-09 要求 Test/Review/RequirementVerify/Checkpoint/Persistence/Recovery 有真实证据 | Skill 型交付物（无编译、无单测框架）的验收依据与证据形态 |

---

## 3. 已识别的 Design Inconsistency（记录，不改 Design）

| 编号 | 不一致 | 处置 |
| :--- | :--- | :--- |
| DI-01 | §81 的 references（8 个）与 §105 的 references（11 个）冲突 | 已裁定以 §105 为准（ADR-004）；§81 旧清单记录为历史遗留 |
| DI-02 | 文档正文 21 处写 `ForgeLoop.DESIGN.md`，磁盘为 `DESIGN.md` | 已由 `rules/git-integration.md` §10 记录：统一引用方，文件名以磁盘为准 |
| DI-03 | `slavingia/mvp` 是商业顾问人格，§15/§16 是工程 scope 契约，产出不同构 | 已裁定 Adapter 收束（ADR-005），不修改 Design |
| DI-04 | §10 的 Agent 六维与 §37 的 Gate 六维不一致（`Diff` vs `Scope`） | 详细设计 §3.4 按「§10 产出 + §37 判定」双层执行，待 DESIGN.md 裁定 |
| DI-05 | ADR-001 §3 把上游 tasks.md 勾选判定为「§28 checkbox + §29 Task State 契合」，实测上游无 Task State 定义 | ADR-001 §3 判定修正为「部分契合」，C-05 措辞同步修订 |
| DI-06 | ADR-006 原把 Agent 放项目目录，类比 ADR-003 的 skill 形态 | skills 有 authoring 豁免、agents 无；依 `AGENTS.md` §2 Global Rule wins 强制修订到 `D:\ai-configs\agents/` |

依 `AGENTS.md` §5，以上均不触发对 DESIGN.md 的反向修改；修改 Design 本身需用户明确指示。

---

## 4. 下一阶段入口

```text
本文件（需求澄清完成）
  ↓
/SPAC-plus-auto 详细设计
  ├─ .ai/ 状态结构（开放项 1）
  ├─ 验证策略与证据形态（开放项 2）
  ├─ SKILL.md 编排层结构（§82 十五步职责 + §105 五项职责）
  ├─ iterative-integration.md Adapter 覆盖机制（ADR-001）
  ├─ mvp-integration.md Adapter（ADR-005）
  ├─ 三个 Agent 的职责边界与调用时机（ADR-006）
  └─ 实现拆分与任务分解
  ↓
Implementation → Test → Review → Requirement Verify → Checkpoint
```