# ForgeLoop 第一阶段 MVP 验收

Task：**T-15 结构自检 + 全闭环证据汇总**

依据：`DESIGN.md` §109（验收标准 A–N）、§108（核心不变量）；`AGENTS.md` §11（证据要求）、
§15（完成条件）；`doc/design/spac-001-detailed-design.md` §5（V-00～V-13 判据表）、
§5.1（两层完成定义）；`doc/decisions/ADR-002-mvp-scope.md` §2（第一阶段能力集）

日期：2026-10-10

---

## 1. 结论

```text
第一阶段能力集（ADR-002 §2：§109 的 A / B / C / F / G / H / I / J / K）
  → 判据 V-00 ～ V-13 全部 14 条 passed，每条均有落盘证据
  → §108 中不依赖 L/M/N 的不变量（I-001 ～ I-006、I-009、I-010）全部成立
  → 结构化自检 85/85 PASS，exit 0

第一阶段收口。
项目级 Goal 未收口——见 §5「本验收未覆盖的部分」。
```

详细设计 §5.1 的两层完成定义在此逐条对照，见 §3 与 §5。

---

## 2. 判据矩阵（V-00 ～ V-13）

判据来源：详细设计 §5 Success Criteria。状态与证据均取自
`.ai/verification-state.yaml`，本节只做汇总与指向，不复述证据内容。

| 判据 | 能力 | Task | 状态 | 证据量 | 证据落点 |
| :--- | :--- | :--- | :---: | ---: | :--- |
| V-00 | forge-loop 在目标 harness 可按名解析并载入 references | T-09b | passed | 266 字 | `.ai/verification-state.yaml` + 自检第 3 组 |
| V-01 | 端到端可运行闭环（用**已部署**副本执行） | T-10b | passed | 304 字 | `.ai/forgeloop-phase1/evidence.yaml` 三条断言 |
| V-02 | 至少一个真实工程任务跑完整链路 | T-10b | passed | 237 字 | 同上（EXEC-1 / EXEC-2 两个真实工程 Task） |
| V-03 | Test 有真实执行证据（**正向 + 负向非零退出，缺一不算**） | T-09 + T-11 | passed | 339 字 | `doc/verification/forgeloop-phase1/test-record.md` §1–§6 |
| V-04 | Review 有真实执行证据，逐条对应 §37 六维（含 **Scope**） | T-02 + T-11 | passed | 348 字 | `doc/verification/forgeloop-phase1/review-record.md` |
| V-05 | Requirement Verification 有真实执行证据（Evidence 八字段 → verified） | T-11 | passed | 250 字 | `doc/verification/forgeloop-phase1/verify-record.md` |
| V-06 | Checkpoint 由全局 Git Workflow 形成的真实记录 | T-12 | passed | 977 字 | `doc/verification/forgeloop-phase1/state-persistence-record.md` §1 |
| V-07 | State Persistence 真实落盘证据 | T-12 | passed | 429 字 | 同上 §2 |
| V-08 | Recovery 三场景状态一致证据 | T-13 | passed | 843 字 | `doc/verification/forgeloop-phase1/recovery-record.md` + `compaction-probe.md` |
| V-09 | 无超前实现（L/M/N、audit-model.md、商业能力均未出现） | T-15 + 范围检查 | passed | 212 字 | 自检第 1 组持续断言 `audit-model.md` 不存在 |
| V-10 | Document Discovery（A）：`source-index.md`，SRC 可被引用 | T-10a | passed | 54 字 | `.ai/forgeloop-phase1/source-index.md`（SRC-001..008） |
| V-11 | Requirement Extraction（B）：`requirement-matrix.yaml` | T-10a | passed | 470 字 | 同上（REQ-001..009 + AC） |
| V-12 | MVP Scope（C）：三集合 + §16 四问 | T-10a | passed | 328 字 | `.ai/forgeloop-phase1/mvp-scope.yaml` |
| V-13 | 上游来源指纹校验（blob 与 ADR 记录一致） | T-01 | passed | 164 字 | `D:\ai-configs\docs\skills-provenance.md` + 自检第 5 组 |

**14/14 passed，无一条以「机制已实现」替代证据。**

---

## 3. §108 核心不变量核对

详细设计 §5.1 规定：本阶段可判定的不变量是 **I-001 ～ I-006、I-009、I-010**
（I-007 / I-008 依赖 L，延后第二迭代）。

| 不变量 | 内容 | 核对方式 | 结果 |
| :--- | :--- | :--- | :--- |
| I-001 | Every Required Requirement has an ID | `requirement-matrix.yaml` 解析出 REQ-001..REQ-009，ID 连续且稳定 | **成立** |
| I-002 | Every Required Requirement has acceptance criteria | 逐条检查 `acceptance` 键非空 | **成立** |
| I-003 | Every Task maps to a Requirement or explicit engineering objective | 机械扫描 `tasks.md` 全部 18 个条目的正文段，要求每段含 `Requirement:` / `工程目标` / `前置` **之一**（合格键已收窄，见下方说明） | **成立** |
| I-004 | Every completed Task has verification evidence | 机械扫描 17 个已勾选条目，要求每段含 `Evidence` 或 `Tests` | **成立** |
| I-005 | Every meaningful implementation has a Git record | `checkpoint.history` 9 条锚点（自检 CK-12 对每条各发一条断言）：CP-001..CP-007 经 `git merge-base --is-ancestor` 实测可达；**CP-008 的锚点 `972a9fa` 恰为当前 HEAD，仅由本 Task 的复跑实测可达，尚未经 CP-008 自身的 Checkpoint Gate 验证**；CP-009 为 §11.2 占位值按规则豁免 | **成立**（后两级的层级差见下方说明） |
| I-006 | Verified Requirement changes become stale and require re-verification | `references/evidence-model.md` §5 定义 Evidence Invalidation 规则，§59 的失效机制已落 reference | **机制成立，运行态未触发** |
| I-009 | Git Policy comes from existing Git Workflow | `rules/git-integration.md` §2 列举的七项 Git Policy 无一被 ForgeLoop 自建；T-12 新增的 §11 只规定状态字段取值口径 | **成立** |
| I-010 | Safety comes from existing Rules | `rules/state-and-recovery.md` §9 列四项禁止：伪造完成 / 跳过验证 / 静默删除状态 / 静默覆盖历史。其中「静默覆盖历史」在 T-13 的 probe 处理中被实际执行——三次 probe 的原始取值全部保留，漂移以时效说明旁挂（`compaction-probe.md` 三个 probe 小节）；「不伪造完成」体现为 V-08 在三场景齐备前保持 `pending` | **成立** |

I-003 / I-004 的机械扫描在本 Task 首次执行，随即查出已完成 Task 缺追溯行与 Requirement
映射——此前「I-00x 成立」是推断而非核对。补齐后两条才真正成立。

**I-006 的结论口径需要说明**：该不变量的内容是**状态跃迁**（VERIFIED → STALE →
RE-VERIFY），而核对方式只是确认 `references/evidence-model.md` §5 有该定义。第一阶段从未发生
Requirement 语义变化（`verification-state.yaml` 的 V-05 evidence 明确记录「本轮无
Requirement 语义变化，既有 Evidence 未失效」），故该路径**未经运行态触发**。
结论写作「机制成立，运行态未触发」而非「成立」——机制已定义并落 reference 是事实，
路径被实际走通是另一件事。

I-003 的合格键在本次修正中收窄为 `Requirement:` / `工程目标` / `前置` 三项。初版扫描把
`Evidence:` / `Tests:` 也算作合格键，判据过宽——I-003 要求的是 Task 到 Requirement 的映射，
「有证据」不能替代「有映射」。按收窄后的判据复跑，另查出 T-09 / T-09b / T-10b / T-11 /
T-12 五条已勾选条目缺映射，已补齐（映射依据取自 `verification-state.yaml` 各判据的
`task` 归属）。

I-005 的 9 条锚点存在三个证据层级，验收表把它们分开陈述而非并列：

```text
CP-001 … CP-007   锚点落在已合并的历史 commit 上，经 git merge-base --is-ancestor 实测可达
CP-008            锚点 972a9fa 恰为当前 HEAD——它只由本 Task 的复跑实测可达，
                  尚未经 CP-008 自身的 Checkpoint Gate 验证（该 Gate 在 T-16 回填时执行）
CP-009            §11.2 占位值，hash 尚未产生，按规则豁免可达性并显式 PASS
```

把三者并列为「逐条实测可达」会让读者以为 CP-008 已经过它自己的 Checkpoint 验证——
实际证据只有本次 ad-hoc 复跑。

---

## 4. 结构自检结果

```text
$ bash scripts/check-forge-loop.sh
pass: 85   fail: 0   skip: 0
RESULT: PASS
exit 0
```

（断言总数随 `checkpoint.history` 的条目增长而递增——每新增一个 Checkpoint，CK-12 就多
一条锚点可达性断言。本 Task 收口时 CP-001..CP-009 共 9 条，其中 CP-009 为 §11.2 占位值，
按规则豁免可达性并显式 PASS。）

八组检查：

| 组 | 检查内容 |
| :--- | :--- |
| 1 | `references/` 清单（§105 权威 10 项）齐备且非空；`audit-model.md` 必须不存在（§109 的 L 尚未交付） |
| 2 | `SKILL.md` 非空、frontmatter 合法、含 `name` / `description`、**不含 `version:`**（B-03 未解除） |
| 3 | reference 交叉引用全部可解析 |
| 4 | 三个下层 Agent（`code-explorer` / `code-architect` / `code-reviewer`）在 `D:\ai-configs\agents\` 非空 |
| 5 | 上游副本 `git hash-object` 与 ADR-001 / ADR-005 登记指纹逐项一致 |
| 6 | 仓库源码与库部署目标一致（ADR-003），CRLF 容错 |
| 7 | `SKILL.md` §105 五项职责锚点齐备 |
| 8 | `.ai/` 落盘契约：8 段 + 8b YAML 全量可解析 + 8c Checkpoint §53/§54 + 8d CK-15 |

判据登记册：`.ai/verification-state.yaml` 的 `checks:` 段登记 CK-01 ～ CK-15 共 10 条
（CK-01..CK-06 合并为一条），与脚本内标注一一对应。

---

## 5. 本验收**未覆盖**的部分

详细设计 §5.1 写明：项目级完成条件依赖 L 与 B-03，二者在本阶段均未满足。以下逐条列出，
避免「第一阶段收口」被读成「Goal 完成」。

| 项 | 状态 | 依赖 |
| :--- | :--- | :--- |
| I-007（Final Audit compares implementation against source requirements） | 未判定 | 依赖 §109 的 **L**，ADR-002 明确延后至第二迭代 |
| I-008（Goal cannot be complete while Required Requirements remain unverified） | 未判定 | 同上 |
| `AGENTS.md` §15 的 **Final Audit Passed** | 未满足 | 同上 |
| `AGENTS.md` §15 的 **Version State Valid** | 未满足 | `version-state.project.version` = `pending: B-03`（见 §6） |
| §109 的 **D（SPEC）/ E（Plan）/ L / M / N** | 未实现 | ADR-002 第一阶段不含 |
| `references/audit-model.md` | 不存在 | 随 L / M 延后（ADR-004）；自检第 1 组持续断言其不存在 |

Phase 1 的 9 条 Required Requirement 状态分布：

```text
VERIFIED  9 / 9    REQ-001 … REQ-009
PENDING   0
REVIEWING 0
```

**Requirement 全部 verified，但 Goal 未完成**——两者是不同的判据：前者看需求兑现，
后者还需 Final Audit 与版本状态。`DESIGN.md` §108 的 I-008 正是这条界线的正式表述。

---

## 6. B-03（Project Version 无来源）

`version-state.project.version` 与 `mvp.version` 均保持 `pending: B-03`。

`rules/version-management.md` §5 规定 Project Version 由 Global Version Management 决定，
Agent 不得仅根据 Design Version（`DESIGN.md` 首部的 `Version: 1.0.0`）推导。

第二迭代处理该开放项时，`version-governance.md` §9.2 给出 Software 类对象的元数据位置为
package manifest 或专用 `VERSION` 文件；§4.6 禁止在多处手工编辑版本号。本仓库当前无
package manifest，因此**版本源的位置裁定**与**版本号本身**是两件事，需要分别处理。

---

## 7. 第一阶段交付物清单

```text
skills/forge-loop/
  SKILL.md                        编排层（§105 五项职责）
  references/*.md                 10 个 reference（§105 权威清单）
.ai/
  development-status.yaml         Goal / Phase / Task / Iteration / Checkpoint / Blocker / Mode
  version-state.yaml              §55 schema
  verification-state.yaml         V-00～V-13 判据矩阵 + Gate 登记 + CK 判据登记册
  forgeloop-phase1/
    source-index.md               A：Document Discovery（SRC-001..008）
    requirement-matrix.yaml       B：Requirement Extraction（REQ-001..009 + AC）
    mvp-scope.yaml                C：MVP Scope（三集合 + §16 四问）
    tasks.md                      18 个 Task 条目（T-01..T-15 已完成 + T-16 Phase 2 首项）
    evidence.yaml                 I：Evidence 八字段
scripts/check-forge-loop.sh       结构化自检（8 组 85 项）
doc/design/spac-001-detailed-design.md    第一阶段详细设计
doc/decisions/ADR-001..006               已裁定决策
doc/verification/forgeloop-phase1/       6 份 Gate 记录 + 1 份 probe 工件：
                                         test-record / review-record / verify-record /
                                         state-persistence-record / recovery-record /
                                         consistency-recheck-record + compaction-probe
doc/audits/mvp-acceptance.md             本文件
```

---

## 8. 下一 Task

```text
T-15 收口 → 建立 CP-009 → 第一阶段（FL-001）结束

第二阶段（ADR-002 第二迭代）：
  D 生成 SPEC 契约 → E 生成 Plan 契约 → L Final Audit → M Audit Repair Loop
  → N Release Gate → Release

开工前置：B-03 的 Project Version 来源裁定
```

