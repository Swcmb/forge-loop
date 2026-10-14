# Changelog

本文件记录 ForgeLoop 的版本变更。格式依 Keep a Changelog，版本号依 Semantic Versioning 2.0.0。
版本号的唯一权威源是仓库根的 `VERSION` 文件；本文件抬头引用该值，不各自手写
（`rules/version-management.md` §6、§8）。

## [1.0.0] — 2026-10-13

首次 Release。ForgeLoop 是项目级工程编排器 Skill，本版本交付 `DESIGN.md` §109 的
A～N 全部十三项能力，解除 B-03，并收口 Goal FL-001 / FL-002。

### Added

- **生命周期与状态**：13 态状态机与转移判据（`references/lifecycle.md`），含失败回退与 `BLOCKED` 终止条件
- **文档发现与需求提取**：`source-index.md` 来源索引（`SRC-xxx` 可回查）、`requirement-matrix.yaml` 的 REQ/AC 结构与 §58 Requirement State Machine（`references/requirement-model.md` §1–§6）
- **SPEC 契约**：`references/requirement-model.md` §7——路由到既有 `create-specification` / `/spec` skill、§23 十二项内容、§24 `MAJOR.MINOR.PATCH` 与三分类版本规则、§25 `SPEC_APPROVED` 三条件 Gate
- **Plan 契约**：`references/task-model.md` §6——路由到既有 planning skill、`code-architect` 真实调用判据、`PLAN-rN` 修订号、§27 REQ→TASK 映射 Gate
- **Task 模型**：九态 Task State、§31 取件顺序、One-Task Rule（`references/task-model.md` §1–§5）
- **Iteration 循环**：上游 `iterative-development` Adapter 与六处覆盖点（`references/iterative-integration.md`）
- **Goal 模式**：Goal / Manual Mode 判定与续行标记（`references/goal-mode.md`）
- **Evidence 模型**：八字段 Evidence、§59 Evidence Invalidation（`references/evidence-model.md`）
- **Checkpoint**：双重落点（状态文件 + Git History）与 §53 六字段（`references/version-control.md` §1–§3）
- **Recovery**：`Load State → Inspect → Reconcile → Resume` 恢复链与六类中断场景（`references/recovery.md`）
- **Final Audit**：`references/audit-model.md` §1–§6——§66 触发条件、§67 九列 Matrix、§68 四维核对、§69 失败处置、产物落盘路径
- **Audit Repair Loop**：`references/audit-model.md` §7–§8——§96 四类失败路径统一收敛到 Task、`BLOCKED` 与修复路径的互斥判据
- **Release Gate**：`references/version-control.md` §6——§72 九项逐项判据与取证来源
- **运行状态落盘契约**：`.ai/`（Owner = FORGELOOP）与 `.dev-ai/`（Owner = CURRENT_PROJECT）双作用域，含 `.ai/audit-state.yaml` 的 §57 五键 schema
- **结构化自检**：`scripts/check-forge-loop.sh`，103 项断言，含正负向判据

### Changed

- `SKILL.md` 与 `lifecycle.md` 中「L/M/N 延后、第一阶段不存在」的表述改写为第二阶段的承接表述（ADR-007 裁定）

### Removed

- 无

### Fixed

- **B-03**（Project Version 无来源）：仓库根 `VERSION` 文件确立为唯一权威源，`version-state.yaml` 与 `SKILL.md` frontmatter 均引用它
- **CK-15**：未加引号的冒号空格标量导致 YAML 解析失败的自检盲区

### Notes

- 本版本不含破坏性变更。`references/` 从 10 个文件增至 11 个（新增 `audit-model.md`），属向后兼容的新增。
- Project Version 与 `DESIGN.md` 的 Design Version（1.0.0）各自独立，不由后者推导（`AGENTS.md` §7）。本次取 `1.0.0` 的依据是 `version-governance.md` §4.4 的 adoption 条件——Skill 已注册进共享库、部署至 `claude_code`、成为 preset 成员并具备 Git source。

## [Unreleased]

### Fixed

- **DI-02**（设计文档引用路径不一致）：文档正文曾将设计文档写作 `ForgeLoop.DESIGN.md`，磁盘实际文件名为 `DESIGN.md`，导致引用指向不存在的文件。12 处活引用已统一（`AGENTS.md`、`CONTRIBUTING.md`、`README.md`、`doc/DEVELOPMENT.md`、`doc/PROJECT-CONSTRAINTS.md`、`rules/version-management.md`、`rules/forge-loop-development.md`）；`rules/git-integration.md` §10 与 `CLAUDE.md` 改写为已落定约定。历史记录类文件（初始交付稿、第一阶段设计、审计与需求记录）按当时的事实保留原写法。

### Added

- 结构化自检第 11 组：DI-02 的判据从一次性改对升级为可执行断言防回归。白名单按「文件 → 允许命中次数」双向校验——多于预算即新增违规，少于预算即预算已过时须显式更新；另断言 `DESIGN.md` 磁盘实存、扫描零命中时判 FAIL（防判据自身静默失效）、以及落在扫描格式之外的受控文件须显式豁免（防将来新增格式静默漏检）。

本 Goal（FL-003）不引入新能力，`v1.0.0` 之后的首个变更条目。

<!-- 版本号引用仓库根 VERSION 文件；修改版本号时只改 VERSION，不改本行。 -->
