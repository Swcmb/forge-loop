# forgeloop-phase1

第一阶段实施任务清单（DESIGN.md §28 格式）。

目标：ForgeLoop 端到端可运行闭环 MVP，对应 §109 的 A/B/C/F/G/H/I/J/K
详细设计：`doc/design/spac-001-detailed-design.md` §4

- [x] 1. T-01 核验 `/goal` 可用 + 按 pinned commit 安装上游 + 校验 blob

  Requirement: ADR-002 第一阶段基础设施
  Tests: 部署前状态查询、blob 逐项比对
  Evidence: `D:\ai-configs\docs\skills-provenance.md`（iterative-development / mvp 条目）；`verification-state.yaml` V-13=passed

- [x] 2. T-02 新建三个 Agent 到 `D:\ai-configs\agents\` 并验证可解析

  Requirement: §109 H（能 Review）前置 + §33 Code Exploration
  Tests: 经 `~/.claude/agents` 解析确认、frontmatter 合法
  Evidence: `D:\ai-configs\agents\{code-explorer,code-architect,code-reviewer}.md`

- [x] 3. T-03 定义 `.ai/` 状态 schema

  Requirement: DESIGN.md §55/§56/§79、AGENTS.md §12、rules/state-and-recovery.md §2
  Tests: 文件存在 + schema 与 §55 逐字段一致
  Evidence: 本目录 `development-status.yaml` / `version-state.yaml` / `verification-state.yaml`

- [x] 4. T-04 写 `references/` 模型类（requirement-model / task-model / evidence-model）

  Requirement: §109 F 的前置——§37/§38/§39 的判据细节落点（REQ-006 / REQ-007）
  Evidence: `skills/forge-loop/references/{requirement-model,task-model,evidence-model}.md`
  （2867 / 2593 / 2979 B），随 T-01..T-10a 批次合并于 main 侧 commit `bab31db`
- [x] 5. T-05 写 `references/` 流程类（lifecycle / goal-mode / version-control / recovery）

  Requirement: §109 K 的前置——§98/§99 的恢复链与 §106/§107 状态机落点（REQ-009）
  Evidence: `skills/forge-loop/references/{lifecycle,goal-mode,version-control,recovery}.md`
  （2344 / 1932 / 1953 / 2546 B），main 侧 commit `bab31db`
- [x] 6. T-06 写 `references/architecture.md`

  Requirement: §109 F 的前置——§10 的编排视图与 §11 的既有能力纳入/排除判定
  Evidence: `skills/forge-loop/references/architecture.md`（3117 B），main 侧 commit `bab31db`
- [x] 7. T-07 写两个 Adapter reference（mvp-integration / iterative-integration）

  Requirement: §109 C 与 F 的上游适配（REQ-003 的 mvp 侧、REQ-004 的 iterative-development 侧）
  Evidence: `skills/forge-loop/references/{mvp-integration,iterative-integration}.md`
  （3641 / 8368 B），main 侧 commit `bab31db`
- [x] 8. T-08 写 `SKILL.md` 编排层

  Requirement: §82 的十五步职责、§105 的五项编排层职责（Routing / Core Rules / Workflow /
  Reference Loading / Output Contract）
  Evidence: `skills/forge-loop/SKILL.md`（6417 B），§105 五项职责由自检第 7 组逐条断言，
  main 侧 commit `bab31db`
- [x] 9. T-09 结构化自检通过（含负向测试）

  Requirement: REQ-005（Test，§109 G）——V-03 的载体；结构化自检同时是 §36 Test Gate 的实现
  Evidence: `scripts/check-forge-loop.sh`；正向 22/22 PASS；负向两项均非零退出（删除 recovery.md → exit 1；注入 nonexistent-ref.md → exit 1）；恢复后复跑 exit 0

- [x] 10. T-09b 部署 forge-loop 到 harness 并验证可解析

  Requirement: V-00 的载体（前置条件）——forge-loop 须在目标 harness 可按名解析并载入
  references（§105 的渐进披露能力）；亦为 REQ-004/REQ-005 的执行前提
  Evidence: `skills adopt` → skill_id 9f921bc4；`skills deploy --agent claude_code` → 部署副本 `C:\Users\Swcmb\.claude\skills\forge-loop\`（SKILL.md + 10 references）落盘；Registered ✓ / Deployed ✓，Loadable 待新会话确认
- [x] 11. T-10a 演练准备：产出 A/B/C 三项输入工件

  Requirement: REQ-001（Document Discovery）、REQ-002（Requirement Extraction）、
  REQ-003（MVP Scope）——§109 的 A / B / C 三项能力
  Evidence: `.ai/forgeloop-phase1/source-index.md`（1091 B，V-10）、
  `requirement-matrix.yaml`（3954 B，V-11）、`mvp-scope.yaml`（2268 B，V-12），
  main 侧 commit `bab31db`
- [x] 12. T-10b 闭环演练：真实 Task 跑通 A→Continue

  Requirement: REQ-004（Single Task Iteration，§109 F）——V-01 / V-02 的载体；One-Task Rule
  与 Goal Mode 续行标记的实测实例
  Evidence: `.ai/forgeloop-phase1/evidence.yaml`（三条断言 passed）；EXEC-1 commit
  a8b60e9 / EXEC-2 commit 9217165

- [x] 13. T-11 Gate 证据固化

  Requirement: REQ-005（Test，V-03）、REQ-006（Code Review，§109 H，V-04）、
  REQ-007（Requirement Verification，§109 I，V-05）——三道 Gate 的证据固化
  Evidence: `doc/verification/forgeloop-phase1/` 下 test/review/verify 三份记录 +
  `doc/reviews/forgeloop-phase1/iteration-review.md`；main 侧 commit 24d6e2c（PR #11）

- [x] 14. T-12 Checkpoint + State Persistence 验证

  Requirement: REQ-008（Git Checkpoint，§109 J）——V-06 / V-07 的载体；§53 Checkpoint
  双重落点与 §79/§98 状态持久化的真实性验证
  Evidence: `doc/verification/forgeloop-phase1/state-persistence-record.md`；V-06/V-07 passed
  附注：本 Task 内对 REQ-001..007 的 requirement-matrix 状态做了 `IMPLEMENTED` → `VERIFIED`
        对齐（由第 2 轮 Review 附注驱动，内容为元数据对齐，且被新增的 CK-13 依赖）。
        这几条 REQ 的实现归属 T-01..T-10b，状态对齐归属本 Task，后续归因勿记到 T-10b。
- [x] 15. T-13 Recovery 演练

  Requirement: REQ-009（V-08）
  Evidence: `doc/verification/forgeloop-phase1/recovery-record.md`（三场景）
  + `compaction-probe.md`（probe 协议）；Review code-reviewer 三轮六维，第 3 轮 0 Blocker /
  0 Important + 1 Minor
- [x] 16. T-14 状态一致性负向验证复核

  Requirement: REQ-009（V-08）的证据链复核 + 判据覆盖面加固
  Evidence: `doc/verification/forgeloop-phase1/consistency-recheck-record.md`（冲突判据
  四分支复跑、compaction probe 第 4 次、CK-15 判据与边界登记）；新增自检 8d 组 CK-15
  （17 行综合用例 11 通过 / 6 命中）；`verification-state.yaml` 新增 `checks:` 判据登记册
  （CK-01..CK-15）；main 侧 commit `972a9fa`（PR #14）
- [x] 17. T-15 结构自检 + 全闭环证据汇总（V-00～V-13）

  Requirement: §109 全闭环证据汇总（V-00～V-13）+ §108 的 I-001～I-006 / I-009 / I-010
  Evidence: `doc/audits/mvp-acceptance.md`（14/14 判据 passed + 8 项不变量核对 +
  自检 85/85）。本 Task 的机械扫描首查 I-003/I-004 即发现已完成 Task 缺追溯行与
  Requirement 映射，已补齐（见上 T-04～T-08、T-09、T-09b、T-10a、T-10b、T-11、T-12、T-14）

# --- 第一阶段（FL-001）到此结束 ---

- [ ] 18. T-16 Phase 2 范围裁定 + Goal 建立

  Requirement: ADR-002 第二迭代的 §109 D / E / L / M / N 五项能力
  Evidence: 待补——计划产出 `.ai/forgeloop-phase2/`（mvp-scope / requirement-matrix /
  tasks）与 `doc/decisions/ADR-007-phase2-scope.md`

## Relevant Files

- `skills/forge-loop/SKILL.md` — 编排层（Routing / Core Rules / Workflow / Reference Loading / Output Contract）
- `skills/forge-loop/references/*.md` — 10 个 reference（§105 权威，audit-model.md 随 L/M 延后）
- `.ai/` — 运行状态（development-status / version-state / verification-state）
- `doc/design/spac-001-detailed-design.md` — 详细设计（权威实现依据）
- `doc/decisions/ADR-001..006` — 已裁定决策
- `doc/audits/repository-audit.md` — 现状审计
- `doc/reviews/spac-001-review-record.md` — 评审记录（含 CRITICAL 计数口径）
- `doc/requirements/brainstorming-results.md` — 需求澄清汇总 + DI-01..DI-08
