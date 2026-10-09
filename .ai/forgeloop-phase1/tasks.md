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
- [x] 5. T-05 写 `references/` 流程类（lifecycle / goal-mode / version-control / recovery）
- [x] 6. T-06 写 `references/architecture.md`
- [x] 7. T-07 写两个 Adapter reference（mvp-integration / iterative-integration）
- [x] 8. T-08 写 `SKILL.md` 编排层
- [x] 9. T-09 结构化自检通过（含负向测试）

  Evidence: `scripts/check-forge-loop.sh`；正向 22/22 PASS；负向两项均非零退出（删除 recovery.md → exit 1；注入 nonexistent-ref.md → exit 1）；恢复后复跑 exit 0

- [x] 10. T-09b 部署 forge-loop 到 harness 并验证可解析

  Evidence: `skills adopt` → skill_id 9f921bc4；`skills deploy --agent claude_code` → 部署副本 `C:\Users\Swcmb\.claude\skills\forge-loop\`（SKILL.md + 10 references）落盘；Registered ✓ / Deployed ✓，Loadable 待新会话确认
- [x] 11. T-10a 演练准备：产出 A/B/C 三项输入工件
- [x] 12. T-10b 闭环演练：真实 Task 跑通 A→Continue

  Evidence: `.ai/forgeloop-phase1/evidence.yaml`（三条断言 passed）；EXEC-1 commit
  a8b60e9 / EXEC-2 commit 9217165

- [x] 13. T-11 Gate 证据固化

  Evidence: `doc/verification/forgeloop-phase1/` 下 test/review/verify 三份记录 +
  `doc/reviews/forgeloop-phase1/iteration-review.md`；main 侧 commit 24d6e2c（PR #11）

- [x] 14. T-12 Checkpoint + State Persistence 验证

  Evidence: `doc/verification/forgeloop-phase1/state-persistence-record.md`；V-06/V-07 passed
  附注：本 Task 内对 REQ-001..007 的 requirement-matrix 状态做了 `IMPLEMENTED` → `VERIFIED`
        对齐（由第 2 轮 Review 附注驱动，内容为元数据对齐，且被新增的 CK-13 依赖）。
        这几条 REQ 的实现归属 T-01..T-10b，状态对齐归属本 Task，后续归因勿记到 T-10b。
- [ ] 15. T-13 Recovery 演练
- [ ] 16. T-14 状态一致性负向验证复核
- [ ] 17. T-15 结构自检 + 全闭环证据汇总（V-00～V-13）

## Relevant Files

- `skills/forge-loop/SKILL.md` — 编排层（Routing / Core Rules / Workflow / Reference Loading / Output Contract）
- `skills/forge-loop/references/*.md` — 10 个 reference（§105 权威，audit-model.md 随 L/M 延后）
- `.ai/` — 运行状态（development-status / version-state / verification-state）
- `doc/design/spac-001-detailed-design.md` — 详细设计（权威实现依据）
- `doc/decisions/ADR-001..006` — 已裁定决策
- `doc/audits/repository-audit.md` — 现状审计
- `doc/reviews/spac-001-review-record.md` — 评审记录（含 CRITICAL 计数口径）
- `doc/requirements/brainstorming-results.md` — 需求澄清汇总 + DI-01..DI-08
