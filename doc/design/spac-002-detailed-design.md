# ForgeLoop 第二阶段详细设计（spac-002）

SPEC 版本：`SPEC-2026-10-13.0.1.0`（首次发布，§24 SemVer）

本文件由 T-21 的 D 演练路由到既有 `spec` skill 产出，落点为 ForgeLoop 项目自有文档目录
`doc/design/`（Owner = FORGELOOP，§79），而非被开发项目的 `dev-doc/spec/SPEC.md`
（§22 的路由对象）。产出契约与 ADR-007 §2 的 REQ-D/REQ-E 一致。

---

## 1. Goal

让 ForgeLoop 在第二阶段（FL-002）具备 §109 的 D/E/L/M/N 五项能力，并解除 B-03
（Project Version 无来源），使 Final Audit 与 Release Gate 可以在同一 Goal 内走完，
收口 FL-001 遗留的 I-007 / I-008 / L / M / N 承接项。

## 2. Scope

In：
- D 契约：SPEC 路由（§22 `create-specification` / `/spec`）与 §25 SPEC_APPROVED Gate
- E 契约：Plan 路由（§26 既有 planning skill + `code-architect`）与 §27 REQ→TASK 映射 Gate
- L 契约：`audit-model.md` §1–§6 的 Final Audit 判据（§66–§69）
- M 契约：`audit-model.md` §7–§8 的 Audit Repair Loop（§96 四类失败路径）
- N 契约：`version-control.md` 承载 §72 Release Gate 九项，每项有取证来源
- B-03 解除：仓库根 `VERSION` 文件作为 Project Version 唯一权威源（已由 T-17 落地）

Out（明确不做）：
- 不新建 SPEC / Plan 生成引擎——AC-D4 / AC-E4 判据能检出「自建生成引擎」的越界实现
- 不改写第一阶段已冻结的 `doc/design/spac-001-detailed-design.md` 与 `.ai/forgeloop-phase1/*`
- 不建第二套 Git Policy——分支 / 提交 / 合并 / 删除一律取全局 `rules/git.md` 与 `ai-git-workflow`

## 3. Requirements

- R1（D）：SPEC 路由复用既有 `spec` skill，产出物含 §23 十二项内容小节
- R2（D）：SPEC 带 `MAJOR.MINOR.PATCH` 版本号；§24 三分类（Patch/Minor/Major）各有明确版本影响规则
- R3（D）：§25 三条件（Requirement Review PASS + SPEC COMPLETE + SPEC Review PASS）齐备时形成 SPEC_APPROVED
- R4（E）：Plan 路由复用既有 planning skill，`code-architect` 被真实调用（记录含 agent 名 + 调用位置 + 输入）
- R5（E）：Plan 带 `PLAN-rN` 修订号；每个 Task 映射到 Requirement 或明确工程目标（I-003）
- R6（L）：`audit-model.md` §1–§6 承载 §66–§69 Final Audit 判据，含 §67 Matrix 九列
- R7（M）：`audit-model.md` §7–§8 承载 §96 四类失败路径 → Repair Task 映射；BLOCKED 判据与修复路径互斥
- R8（N）：`version-control.md` 承载 §72 九项，每项注明取证来源；Version / Git 两项指向 `version-state.yaml`
- R9（B-03）：`VERSION` 文件存在且为唯一版本源；`version-state.yaml` 与 `SKILL.md` frontmatter 均引用它

## 4. Non-functional Requirements

- NFR-1：自检脚本 `scripts/check-forge-loop.sh` 对 D/E/L/M/N 各有至少一条正向断言与一条负向断言
- NFR-2：第一阶段 10 个 reference 的既有断言不回归（第 1 组正向全项保持 PASS）
- NFR-3：`.ai/audit-state.yaml` 五键（§57）齐备；§72 九项的判定区落在其 `release_gate` 段

## 5. Architecture Constraints

- `skills/forge-loop/` 是编排层，`references/` 是契约层；`audit-model.md` 随 L/M 在此交付
- 库部署目标 `D:\ai-configs\skills\skills\forge-loop\` 的同步走 `manage-skills deploy`（T-09b 建立）
- 自检第 1 组对 `audit-model.md` 的负向断言（必须不存在）由 T-26 翻转为正向（必须存在且非空）
- 自检第 2 组对 `SKILL.md` frontmatter `version:` 的负向断言已由 T-17 翻转为一致性断言

## 6. APIs

本仓库无运行时 API。契约面是文档引用：
- `DESIGN.md` 节号（§22–§28 / §48 / §57 / §66–§72 / §96 / §105–§109）是唯一权威定义源
- references 的 `依据：` 行引用节号，正文不复述 DESIGN.md 的定义

## 7. Data

- `.ai/audit-state.yaml`（T-20 建立）：§57 五键 + §72 九项判定区
- `.ai/version-state.yaml`：`project.version` / `mvp.version` 引用 `VERSION` 文件（T-17 翻转）
- `.ai/forgeloop-phase2/{source-index,requirement-matrix,mvp-scope,tasks,evidence}.yaml|md`：阶段输入工件

## 8. Errors

- 自检 exit 1 = 任一断言 FAIL；skip 计入汇总（降级须留痕，第 8 组原则）
- `audit-state-probe`：`.ai/audit-state.yaml` 存在则断言五键；T-20 勾选后文件缺失判 FAIL（守卫自身失效防守）

## 9. Security

不适用——本仓库无网络写入、无凭据、无用户输入面。证据链只读本地 Git 历史与 `.ai/` 状态文件。

## 10. Runtime

验证命令：`bash scripts/check-forge-loop.sh`，期望 `exit 0` 且汇总行无 FAIL。
各契约的负向判据由各 Task 的 Tests 行指明（`.ai/forgeloop-phase2/tasks.md`）。

## 11. Acceptance Criteria

- AC-D1：R1 的十二项小节在 SPEC 产出物中逐节存在（T-21 演练即本文件）
- AC-D2：本文件头部带 `SPEC-2026-10-13.0.1.0` 版本号，§24 三分类表在 `requirement-model.md` §7 可查
- AC-D3：`SPEC_APPROVED` 三条件的判据在 `requirement-model.md` §7 与自检第 10 组可执行
- AC-E1：Plan 产出物带 `PLAN-r1` 修订号（T-21 的 Plan 即 `doc/plans/spac-002-implementation-plan.md`）
- AC-E2：Plan 中每个 Task 的 `Requirement:` 行非空（I-003）
- AC-E3：无 Requirement 的 Required Task 会被 Gate 判 FAIL（判据在 `task-model.md` §6）
- AC-E4：`code-architect` 的调用记录（agent 名 + 调用位置 + 输入）落在 T-21 的 Evidence 条目
- AC-L1..L5：`audit-model.md` §1–§6 存在且非空；Matrix 九列齐备；§68 四维各有结论
- AC-M1..M5：`audit-model.md` §7–§8 存在；§96 四类失败路径各自映射到 Task
- AC-N1/N3/N4/N5：`version-control.md` 承载 §72 九项，每项有取证来源
- AC-N2：`VERSION` 文件存在且格式合规（T-17 已达成，本 SPEC 记录其完成状态）

## 12. Change Classification（§24）

首次发布为 `0.1.0` 级（§4.4 初始开发阶段值）。后续：
- 补正文字 → PATCH；新增兼容 Requirement → MINOR；改已有 Requirement 语义 → MAJOR + SPEC Impact Analysis（§59 失效既有 evidence）
