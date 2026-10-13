# Release Gate 九项核对（FL-002 T-29 N 演练）

依据：`DESIGN.md` §72（Release Gate 九项）、§73（Release）；判据
`skills/forge-loop/references/version-control.md` §6。时点：2026-10-13。

## 九项逐项核对

| # | Gate 项 | 结论 | 取证来源 | 取证内容 |
| :-- | :--- | :--- | :--- | :--- |
| 1 | Requirements PASS | PASS | `.ai/*/requirement-matrix.yaml` 的 `status` 合计 | 14 条 required 全 VERIFIED（phase1 的 REQ-001～009 九条 + phase2 的 REQ-D/E/L/M/N 五条） |
| 2 | Acceptance PASS | PASS | 同上 `acceptance` 区 + `.ai/forgeloop-phase2/evidence.yaml` | 每条 AC 有 verified 证据；phase1 见 `doc/audits/mvp-acceptance.md` 的 V-00～V-13，phase2 见 evidence 的十一条八字段条目 |
| 3 | Tests PASS | PASS | `scripts/check-forge-loop.sh` 实际执行记录 | 103 项断言，0 fail，0 skip，exit 0 |
| 4 | Build PASS | PASS | `.ai/audit-state.yaml` 的 `build.status` | 本仓库无构建工具链；判据 = 自检脚本 exit 0（T-15 起确立） |
| 5 | Runtime PASS | PASS | `.ai/audit-state.yaml` 的 `runtime.status` | 第一阶段自检 + T-13 Recovery 三场景演练的运行时取证 |
| 6 | Code Review PASS | PASS | `.ai/audit-state.yaml` 的 `code_review.status` | T-11 三层 Gate 证据固化；本轮各 PR 附作者自审结论 |
| 7 | Final Audit PASS | PASS | `doc/audits/phase2/final-audit.md` + `final-audit-matrix.md` | §67 Matrix 14 行齐备；§68 四维各有结论；§69 无 Missing 条目 |
| 8 | Version Consistent | PASS | `VERSION` + `.ai/version-state.yaml` 的 `project.version` | T-17 解除 B-03；自检第 2 组一致性断言（frontmatter 与 VERSION 同源）PASS |
| 9 | Git State Valid | PASS | `.ai/version-state.yaml` 的 `git.*` + CK-14 / CK-16 / CK-17 | 集成分支 `main` 上 commit 可达；两个状态文件的 goal.id / iteration.current 同值 |

## 版本判定

Project Version = `1.0.0`。

- **版本源**：仓库根 `VERSION`（B-03 已由 T-17 解除，唯一权威源）
- **判定依据**：Global Version Governance §4.4「Ship `1.0.0` once adopted — As soon as an
  external consumer depends on it」的 adoption 条件已满足：ForgeLoop 已注册进共享 skill 库
  （`skills show forge-loop` 可查）、部署至 `claude_code`、为 preset「前端-UI」成员、具备
  Git source 可供 `skills update`。
- **明确排除**：本判定**不由 `DESIGN.md` 首部的 `Version: 1.0.0` 推导**。Design Version 与
  Project Version 属不同层，互不继承（`AGENTS.md` §7、`rules/version-management.md` §4–§5）。
  两者数值相同属巧合。
- **T-17 的 `0.1.0`** 是解除 B-03 时写入的载体值，从未 Release，不构成递增基线。

## Release 产物

| 产物 | 路径 | 状态 |
| :--- | :--- | :--- |
| Changelog | `CHANGELOG.md` | 已产出（Keep a Changelog 格式，版本号引用 `VERSION`） |
| Version | `VERSION` | `1.0.0` |
| Tag | `v1.0.0` | 指向 Audit 通过后的 commit（§8.1 annotated tag，不可移动） |
| 状态 | `.ai/audit-state.yaml` 的 `release_gate` | `pending: []`，`outcome: RELEASE_READY` |

## 结论

九项全过，进入 `RELEASE_READY`（§72）。`REQ-N` 的 AC-N1～AC-N5 达成。
