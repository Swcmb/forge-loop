# forgeloop-phase2

第二阶段实施任务清单（`DESIGN.md` §28 格式）。范围裁定：
`doc/decisions/ADR-007-phase2-scope.md`。详细设计：`doc/design/spac-002-detailed-design.md`。

目标：交付 §109 的 D / E / L / M / N 五项能力，并解除 B-03。

每条都带 `Requirement:` 行——这是 I-003 的硬要求（每个 Task 必须映射到 Requirement
或明确的工程目标）。第一阶段有 11 个条目缺这行，是 T-15 的机械扫描才发现的。

---

- [x] 1. T-16 Phase 2 范围裁定 + Goal 建立

  Requirement: 工程目标（前置）——ADR-007 裁定 + `.ai/forgeloop-phase2/` 五件输入工件
  Acceptance: []
  Tests: 五个状态文件 YAML 可解析；每条 REQ 至少一个 AC（I-002）；`source-index.md` 的 SRC 编号可被 `source` 引用
  Evidence: `doc/decisions/ADR-007-phase2-scope.md` + 本目录五件工件

- [ ] 2. T-17 B-03 解除：VERSION 文件作为唯一版本源

  Requirement: REQ-N（AC-N2）——Version Consistent 的前置
  Acceptance: [AC-N2]
  Tests: VERSION 文件存在且格式合规；`version-state.project.version` 改为引用而非 `pending: B-03`；**自检第 2 组（frontmatter `version:` 断言）在本 Task 翻转**，负向验证两条：清零 → exit 1、version 与 VERSION 不一致 → exit 1
  Evidence: 待补

- [ ] 3. T-18 D 契约：SPEC 路由与 SPEC_APPROVED Gate

  Requirement: REQ-D
  Acceptance: [AC-D1, AC-D2, AC-D3, AC-D4]
  Tests: `requirement-model.md` 承载 §23 十二项与 §25 Gate；自检能检出「自建生成引擎」的越界实现
  Evidence: 待补

- [ ] 4. T-19 E 契约：Plan 路由与 REQ→TASK 映射 Gate

  Requirement: REQ-E
  Acceptance: [AC-E1, AC-E2, AC-E3, AC-E4]
  Tests: `task-model.md` 承载 §27 映射契约与 §48 的 PLAN-rN；判据能检出无 Requirement 的 Required Task
  Evidence: 待补

- [ ] 5. T-20 `.ai/audit-state.yaml` schema 建立

  Requirement: 工程目标（前置）——§57 的五键 + §72 的九项所需字段
  Acceptance: []
  Tests: 文件存在且可解析；§57 五键齐备；自检 group 8 扩展断言其必填段；负向：删任一必填段 → exit 1
  Evidence: 待补

- [ ] 6. T-21 D/E 真实演练

  Requirement: REQ-D + REQ-E
  Acceptance: [AC-D1, AC-D2, AC-D3, AC-D4, AC-E1, AC-E2, AC-E3, AC-E4]
  Tests: 用已部署副本执行；产出 `doc/design/spac-002-detailed-design.md` 与 `doc/plans/spac-002-implementation-plan.md`
  Evidence: 待补

- [ ] 7. T-22 `audit-model.md` §1–§6：Final Audit 判据（L）

  Requirement: REQ-L
  Acceptance: [AC-L1, AC-L2, AC-L3, AC-L4, AC-L5]
  Tests: 文件存在且非空；自检第 1 组翻转后判 PASS；负向：清零文件 → exit 1
  Evidence: 待补

- [ ] 8. T-23 `audit-model.md` §7–§8：Audit Repair Loop（M）

  Requirement: REQ-M
  Acceptance: [AC-M1, AC-M2, AC-M3, AC-M4, AC-M5]
  Tests: §96 的四类失败路径各自映射到 Task；BLOCKED 判据与修复路径互斥
  Evidence: 待补

- [ ] 9. T-24 N 契约：Release Gate 九项

  Requirement: REQ-N
  Acceptance: [AC-N1, AC-N3, AC-N4, AC-N5]
  Tests: `version-control.md` 承载 §72 九项，每项有取证来源；Version / Git 两项指向 `version-state.yaml`
  Evidence: 待补

- [ ] 10. T-25 延后表述改写

  Requirement: 工程目标（一致性）——`SKILL.md` / `lifecycle.md` 中「L/M/N 延后、第一阶段不存在」的表述
  Acceptance: []
  Tests: 自检第 3 组（交叉引用可解析）仍 PASS；改写后的引用全部命中实存章节
  Evidence: 待补

- [ ] 11. T-26 自检断言翻转（第 1 组）+ 双向负向

  Requirement: 工程目标（判据）——第 1 组的负向断言改为正向
  Acceptance: []
  Tests: 第 1 组正向全项 PASS；负向 ≥2 项各 exit 1（删 audit-model / 清零）；复原后 exit 0。第 2 组（frontmatter version）的翻转在 T-17 执行，不在本 Task
  Evidence: 待补

- [ ] 12. T-27 L 真实演练：Final Audit

  Requirement: REQ-L
  Acceptance: [AC-L2, AC-L3, AC-L4, AC-L5]
  Tests: Matrix 九列齐全；行集合 = required；§68 四维各有结论；结论逐条回指 SRC
  Evidence: 待补

- [ ] 13. T-28 M 真实演练：Audit Repair Loop

  Requirement: REQ-M
  Acceptance: [AC-M1, AC-M2, AC-M3, AC-M4]
  Tests: 至少产生一条 Finding；Finding → Remediation Task → 三层 Gate → Commit 全链证据；复审轮次递增且结论翻转
  Evidence: 待补

- [ ] 14. T-29 N 真实演练：Release

  Requirement: REQ-N
  Acceptance: [AC-N1, AC-N2, AC-N3, AC-N4, AC-N5]
  Tests: §72 九项逐项 PASS；CHANGELOG.md 产出；tag 指向 Audit 通过后的 commit
  Evidence: 待补

- [ ] 15. T-30 Phase 2 Final Audit + Goal 收口

  Requirement: 工程目标（收口）——§94 的完成模型
  Acceptance: []
  Tests: D/E/L/M/N 五项各有独立 AC 与证据；`AGENTS.md` §15 六项全部满足；`verification.overall` 转 `complete`
  Evidence: 待补

## Relevant Files

- `doc/decisions/ADR-007-phase2-scope.md` — 第二阶段范围裁定（权威）
- `doc/audits/mvp-acceptance.md` — 第一阶段验收与未覆盖清单
- `doc/design/spac-002-detailed-design.md` — 第二阶段详细设计（T-21 产出）
- `skills/forge-loop/references/audit-model.md` — §105 清单的 audit-model.md 条目（T-22 / T-23 产出）
- `.ai/audit-state.yaml` — §57 的 Audit 状态（T-20 产出）
- `VERSION` — B-03 的解除载体（T-17 产出）

