# ForgeLoop 第二阶段实施 Plan（spac-002）

Plan 修订号：`PLAN-r1`（§48，Plan 采用修订号，不采用 SemVer）

产出方：本机既有 planning 链路 + `code-architect`（调用记录见 AC-E4 证据区）。
依据：`doc/design/spac-002-detailed-design.md`（SPEC-2026-10-13.0.1.0）、
`.ai/forgeloop-phase2/tasks.md`、`DESIGN.md` 节号、`doc/decisions/ADR-007-phase2-scope.md`。

已完成任务写实际记录与证据指针，未排期；排期覆盖 T-22～T-24、T-26～T-30。

---

## 1. 已完成任务记录（不排期）

- **T-16** 范围裁定 + Goal 建立。产出：`doc/decisions/ADR-007-phase2-scope.md` + `.ai/forgeloop-phase2/` 五件工件。证据：`requirement-matrix.yaml` 解析出 REQ-D/E/L/M/N 各含 AC（I-002）。
- **T-17** B-03 解除。产出：仓库根 `VERSION`（0.1.0）；`version-state.yaml` 改引用；`SKILL.md` frontmatter 加 `version`；自检第 2 组翻转为一致性断言。证据：`evidence.yaml` `b03_resolved`（94/0/1 skip，负向两条 exit 1）。
- **T-18** D 契约。产出：`requirement-model.md` §7（§23 十二项 + §24 三分类 + §25 Gate）。证据：`evidence.yaml` `t18_spec_contract`。
- **T-19** E 契约。产出：`task-model.md` §6（路由 + PLAN-rN + 映射 Gate + AC-E4 判据）。证据：`evidence.yaml` `t19_plan_contract`。
- **T-20** audit-state schema。产出：`.ai/audit-state.yaml`（§57 五键 + 扩展键 + release_gate 段）。证据：`evidence.yaml` `t20_audit_state_schema`。
- **T-25** 延后表述改写。产出：`SKILL.md` / `lifecycle.md` 引用翻转，audit-model.md 暂入 PENDING_REFS。证据：`evidence.yaml` `t25_deferred_rewriting`。

## 2. 待排期任务

### T-22 audit-model.md §1–§6（Final Audit 判据）
- Requirement: REQ-L（AC-L1～L5）
- 输入：读 `DESIGN.md` §66–§69、`requirement-matrix.yaml` 五条 REQ、SPEC §11 AC 清单
- 动作：新建 `skills/forge-loop/references/audit-model.md`，§1–§6 承载 §66 判据 + §67 Matrix 九列 + §68 四维可判定问句
- 判据：文件存在非空；负向——清零文件 → 自检 exit 1
- 产出：`references/audit-model.md`（§1–§6）

### T-23 audit-model.md §7–§8（Audit Repair Loop）
- Requirement: REQ-M（AC-M1～M5）
- 输入：读 `DESIGN.md` §96 四类失败路径、§97 BLOCKED 五类外部条件
- 动作：同文件续写 §7–§8：四类路径 → Remediation Task 映射 + BLOCKED 判据互斥
- 判据：四条路径各有映射行；负向——删一条映射 → 判据 FAIL
- 产出：`references/audit-model.md`（§7–§8）

### T-24 N 契约：Release Gate 九项
- Requirement: REQ-N（AC-N1、N3、N4、N5）
- 输入：读 `DESIGN.md` §70–§73、`audit-state.yaml` release_gate 段
- 动作：扩展 `references/version-control.md`，逐条载九项，每项注明取证来源；Version / Git 两项指向 `version-state.yaml`
- 判据：九项可 grep 定位；Version 项含 `version-state.yaml` 字样
- 产出：`references/version-control.md`（§72 九项段）

### T-26 自检第 1 组翻转 + 双向负向
- Requirement: 工程目标（判据）
- 前置：T-22 / T-23 已交付（ADR-007 §8-1），库部署目标已同步（§8-2，文件数 11→12，走 `manage-skills deploy` 不手工复制）
- 动作：`scripts/check-forge-loop.sh` 第 1 组负向断言改正向；从 PENDING_REFS 移除 audit-model.md
- 判据：正向全项 PASS；负向≥2 项（删文件 / 清零）各 exit 1；复原 exit 0
- 产出：`scripts/check-forge-loop.sh` 第 1 组更新

### T-27 L 真实演练：Final Audit
- Requirement: REQ-L（AC-L2～L5）
- 前置：T-21 的真实 SPEC / Plan（ADR-007 §8-3，即本 Plan 与 `spac-002-detailed-design.md`）
- 动作：按 audit-model §1–§6 执行，行集合 = required 五条
- 判据：Matrix 九列齐全；§68 四维各有结论；结论逐条回指 source-index 编号（I-007）
- 产出：`doc/audits/phase2/final-audit.md` + `final-audit-matrix.md` + `spec-review.md`

### T-28 M 真实演练：Audit Repair Loop
- Requirement: REQ-M（AC-M1～M4）
- 前置：T-27 至少一条 Finding
- 动作：Finding → Remediation Task → 三层 Gate（§36/§37/§38）→ Commit；复审轮次递增
- 判据：全链证据在 evidence.yaml 八字段；复审结论翻转
- 产出：`.ai/forgeloop-phase2/evidence.yaml` M 条目 + 复审记录

### T-29 N 真实演练：Release
- Requirement: REQ-N（AC-N1～N5）
- 前置：T-17 已翻转版本一致性断言（唯一硬阻塞，ADR-007 §7）；§72 九项逐项 PASS
- 动作：产出 `CHANGELOG.md`；tag 指向 Audit 通过后 commit；版本号取 `VERSION`
- 判据：九项逐项 PASS 记录；tag 可 `git tag -l` 核对
- 产出：`CHANGELOG.md` + Git tag

### T-30 Phase 2 Final Audit + Goal 收口
- Requirement: 工程目标（收口，§94 完成模型）
- 动作：`AGENTS.md` §15 六项核对；`verification.overall` 转 `complete`；I-007/I-008 判据落盘
- 判据：D/E/L/M/N 五项各有一条独立 verified evidence
- 产出：`doc/audits/phase2/goal-completion.md` + `.ai/development-status.yaml` 终态

## 3. 关键路径（ADR-007 §8 三条硬约束）

```text
T-22 ─→ T-23 ─→ [库同步] ─→ T-26 ─→ T-27 ─→ T-28 ─→ T-29 ─→ T-30
  │                                        ↑
  │  T-24 可并行                           │
  └─ T-25 引用翻转已完成（T-22 先于 T-25 的约束已兑现）
T-17（已完成）只阻塞 T-29；T-27 依赖 T-21 真实 SPEC/Plan
```

## 4. 证据记录（AC-E4）

`code-architect` 调用条目：agent 名 = code-architect；调用位置 = 本 Plan 的 D 路由（SPEC §1 → E 契约产出 `doc/plans/spac-002-implementation-plan.md`）；输入 = SPEC 全文 + tasks.md + DESIGN.md 节号 + 本任务六条要求。

## 5. Release 前置清单（T-30 执行 §72 九项逐项核对）

| # | 判据 | 取证来源 |
|---|------|----------|
| 1 | Requirements PASS | requirement-matrix 五条 status 终态 |
| 2 | Acceptance PASS | 各 REQ AC 在 evidence.yaml 逐条 verified |
| 3 | Tests PASS | `bash scripts/check-forge-loop.sh` 全组 exit 0 |
| 4 | Build PASS | 无构建，显式 N/A + 理由（仓库无构建工具链） |
| 5 | Runtime PASS | 自检脚本即 runtime，同上 N/A 或 0 FAIL 记录 |
| 6 | Code Review PASS | 各 Task review 八字段（ai-git-workflow §5.2 自审） |
| 7 | Final Audit PASS | T-30 Matrix 结论 PASS（I-007/I-008） |
| 8 | Version Consistent | `VERSION` 单一源 + 自检第 2 组断言 |
| 9 | Git State Valid | 详细设计 §3.5 判据 + `version-state.yaml` git.clean 同口径 |
