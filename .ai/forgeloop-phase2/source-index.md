# 来源索引 — ForgeLoop 第二阶段

第二阶段的 Source Documents。编号供 Requirement 的 `source` 字段引用
（`DESIGN.md` §17、§39 Evidence 的 `source`）。

与第一阶段 `../forgeloop-phase1/source-index.md` 的区别：这里的来源以**设计章节**
为主——第二阶段交付的是 ForgeLoop 自身的能力，判据来自 `DESIGN.md`。

| 来源 | 文档 | 承载 |
| :--- | :--- | :--- |
| SRC-101 | `DESIGN.md` §109 | 五项能力 D / E / L / M / N 的验收标准原文 |
| SRC-102 | `DESIGN.md` §22–§28 | SPEC 内容契约（§23）、SPEC Gate（§25）、Plan 与 REQ→TASK（§27） |
| SRC-103 | `DESIGN.md` §66–§69 | Final Audit（§66）、Audit Matrix（§67）、Final Document Audit 四维（§68）、Audit Failure（§69） |
| SRC-104 | `DESIGN.md` §70–§73 | Build Gate、Runtime Gate、Release Gate 九项、Release |
| SRC-105 | `DESIGN.md` §96、§98–§99 | 统一 Failure Loop、Goal Resume、Compact Resume |
| SRC-106 | `DESIGN.md` §105 | references 的 11 项权威清单（含 `audit-model.md` 条目） |
| SRC-107 | `DESIGN.md` §108 | 核心不变量 I-001～I-010 |
| SRC-108 | `DESIGN.md` §4 / §24 / §44–§49 / §52–§55 | SPEC SemVer、Plan Revision、Goal/SPEC 版本层、Checkpoint 字段 |
| SRC-201 | `doc/decisions/ADR-002-mvp-scope.md` | 第一阶段范围与 §2 的延后清单（L / M / N） |
| SRC-202 | `doc/decisions/ADR-004-references-authority.md` | references 清单以 §105 为权威 |
| SRC-203 | `doc/decisions/ADR-006-agent-implementation.md` | 三个下层 Agent 的位置与职责；`code-architect` 服务 Plan 阶段 |
| SRC-204 | `doc/decisions/ADR-007-phase2-scope.md` | 第二阶段范围、Requirement ID 沿用、B-03 路径、自检翻转时点 |
| SRC-205 | `doc/decisions/ADR-003-deliverable-location.md` | 仓库为权威源码、库为部署目标 |
| SRC-301 | `doc/audits/mvp-acceptance.md` | 第一阶段验收结论与 6 项未覆盖清单 |
| SRC-302 | `.ai/forgeloop-phase1/mvp-scope.yaml` | `REQ-L` / `REQ-M` / `REQ-N` 的原始登记（§19 ID 稳定性的出处） |
| SRC-401 | `rules/version-management.md` | Project Version 由全局规则决定；禁止从 Design Version 推导 |
| SRC-402 | `rules/state-and-recovery.md` | 状态完整性四条禁止；Recovery 恢复链 |
| SRC-403 | `rules/forge-loop-development.md` | Final Audit、Completion 条件 |
| SRC-404 | `rules/git-integration.md` | §2 No Second Git Policy；§11 Checkpoint hash 口径 |
| SRC-501 | `skills/forge-loop/references/lifecycle.md` | 13 态状态机与 FINAL_AUDIT / RELEASE_READY / COMPLETE 三态的现状 |
| SRC-502 | `skills/forge-loop/references/version-control.md` | Checkpoint 双重落点与冲突判据（N 的落点） |
| SRC-503 | `skills/forge-loop/references/evidence-model.md` | Evidence 八字段与失效规则 |
| SRC-504 | `skills/forge-loop/SKILL.md` | §82 的十五步；Workflow 第 15 步（Final Audit）的延后表述 |
| SRC-601 | `D:\ai-configs\rules\version-governance.md` | §4 SemVer、§9.2 元数据位置、§4.6 禁止项 |
| SRC-602 | `D:\ai-configs\rules\testing.md` | 正负双向测试要求 |

