# Decision Record: 第二阶段范围

决策日期：2026-10-10
状态：已裁定
决策人：作者 Agent（用户授权 Goal Mode 自动执行；本裁定依据 ADR-002 §2 的延后清单与
`DESIGN.md` §109 的验收标准作出，不引入新范围）
关联：`doc/decisions/ADR-002-mvp-scope.md`（第一阶段范围与延后项）、
`doc/audits/mvp-acceptance.md`（第一阶段验收与未覆盖清单）

---

## 1. Decision

ForgeLoop 的第二阶段交付 `DESIGN.md` §109 中第一阶段未覆盖的五项能力：

```text
D  能生成 SPEC            §22–§25、§87
E  能生成 Plan            §26–§28、§88
L  能执行 Final Audit     §66–§69、§91
M  能继续修复 Audit Findings  §69、§96
N  能进入 Release         §70–§73
```

并解除 **B-03**（Project Version 无来源），它是 N 的前置。

第一阶段（FL-001 / A、B、C、F、G、H、I、J、K）已于 T-15 收口，验收见
`doc/audits/mvp-acceptance.md`：V-00～V-13 十四条判据全部 passed，§108 的
I-001～I-006 / I-009 / I-010 全部成立，自检 85/85。

### 1.1 FL-002 的成立方式：新 Goal，承接未收口项

`DESIGN.md` §45 规定 Goal ID 为 `GOAL-001` / `GOAL-002` 的递增序列。本仓库的既有实例
（FL-001）采用了 `FL-nnn` 前缀，故第二阶段沿用同一前缀取 `FL-002`。

**FL-002 是新 Goal，不是 FL-001 的改名。** 判据是三处结构性事实：

1. **范围不同** —— FL-001 的 `scope_ref` 是 ADR-002（§109 的 A/B/C/F/G/H/I/J/K），
   FL-002 的是本 ADR（§109 的 D/E/L/M/N + B-03）。两者无交集。
2. **Task 清单不同源** —— FL-001 的任务权威登记处是 `.ai/forgeloop-phase1/tasks.md`，
   FL-002 的是 `.ai/forgeloop-phase2/tasks.md`。第一阶段清单不重复登记第二阶段条目：
   同一 Task 出现在两份清单里会让 Task State 出现两个来源，恢复者无法判断哪份权威
   ——这正是 T-13 Recovery 演练中实测过的「字段快照被读成事实」同类缺陷。
3. **收口条件不同** —— FL-001 的 §94 九项中，Final Audit / Version State Valid /
   Git State Valid 三项依赖 L 与 B-03（项目级完成条件见
   `doc/design/spac-001-detailed-design.md` §5.1），已在 `mvp-acceptance.md` §5 列为
   「本验收未覆盖」并显式声明「第一阶段收口不等于 Goal 收口」。

**FL-002 承接 FL-001 的未覆盖部分**（`development-status.yaml` 的 `goal.carried_over`
逐项登记：I-007 / I-008 / D / E / L / M / N / B-03），因此它不是「重新开始」，而是 FL-001
剩余收口项的继续执行。

**Task ID 序列跨 Goal 连续**（T-16 起不重编）。理由同上：Task ID 指向具体产物，
重编会让第一阶段的验证记录引用到不存在的 Task。`iteration.task_seq` 则改为**本 Goal 内**
计数，从 1 起算——它回答「这个 Goal 做了多少」，与跨 Goal 累计的 `global_task_seq`
语义不同，两者并列登记（`task_seq_note` 说明该口径）。

**Checkpoint 归属不改写**：`checkpoint.goal.id` 与 `checkpoint.iteration.id` 记录的是
**形成该 Checkpoint 的** Goal 与 Iteration。CP-009 由 FL-001 / ITER-002 形成，故跨 Goal
切换后仍记 FL-001 / ITER-002；`checkpoint.history` 九条锚点同理。新 Goal 的首个
Checkpoint 是 CP-010，记 FL-002 / ITER-003。

`goal.prev` 段登记前一 Goal 的 id、收口 Task 与 commit，使 Goal 链可追溯而不必回查
Git 历史。

## 2. Requirement ID 沿用

`REQ-L` / `REQ-M` / `REQ-N` 已在第一阶段的 `mvp-scope.yaml` 中以该名字登记为
`deferred`。`DESIGN.md` §19 要求 Requirement ID 永久稳定，故第二阶段**沿用原名**，
不重新编号为 `REQ-010` 之类。

`REQ-D` / `REQ-E` 是首次登记，命名采用 `DESIGN.md` §109 的字母序（A…N），
与 §109 的能力清单一一对应，便于双向引用。

```text
REQ-D  §109 D   能生成 SPEC
REQ-E  §109 E   能生成 Plan
REQ-L  §109 L   能执行 Final Audit
REQ-M  §109 M   能继续修复 Audit Findings
REQ-N  §109 N   能进入 Release
```

## 3. 既有能力优先（`AGENTS.md` §9）

与 ADR-002 §4 同一条原则在第二阶段继续适用：

| 能力 | 处置 | 依据 |
| :--- | :--- | :--- |
| SPEC 生成 | **Reuse** 本机 `spec` skill；ForgeLoop 只做路由与 `SPEC_APPROVED` Gate（§25） | ADR-002 §4；`DESIGN.md` §87 |
| Plan 生成 | **Reuse** 本机 `writing-plans` skill；ForgeLoop 只做路由与 REQ→TASK 映射 Gate（§27） | ADR-002 §4；`DESIGN.md` §88 |
| 架构边界判断 | **Reuse** 第一阶段已落地但闲置的 `code-architect` agent | ADR-006；`DESIGN.md` §34 |
| Final Audit / Audit Repair Loop | **Create** `references/audit-model.md` | §105 清单的 `audit-model.md` 条目；ADR-004 裁定以 §105 为权威清单 |
| Release Gate | **Extend** `references/version-control.md`，不新建 | §94 把 Version Consistent / Git State Valid 归版本与 Git 层 |

**不自建 SPEC / Plan 生成引擎。** 第二阶段交付的是「路由 + Gate + 判据」，生成体由既有
skill 承担。若 ForgeLoop 自己实现 SPEC/Plan 生成，它就成了被它自己审计的对象——
Audit 的独立性无从谈起。

## 4. 交付物落点

Phase 2 沿用 Owner = FORGELOOP 的正常命名空间（`AGENTS.md` §4）：

```text
.ai/forgeloop-phase2/          第二迭代的运行状态（mvp-scope / requirement-matrix /
                               tasks / evidence / source-index）
doc/decisions/ADR-007-phase2-scope.md      本文件
doc/design/spac-002-detailed-design.md    第二阶段详细设计（D/E 的产出契约与演练对象）
doc/plans/spac-002-implementation-plan.md E 的产出契约与演练对象
doc/audits/phase2/                        L 的 Audit 产物（final-audit.md /
                                          final-audit-matrix.md / spec-review.md 等）
skills/forge-loop/references/audit-model.md    §105 清单的 audit-model.md 条目（L / M）
CHANGELOG.md                              N 的 Release 产物
VERSION                                    B-03 的解除载体（见 §5）
```

第一阶段的 `doc/design/spac-001-detailed-design.md` 与 `.ai/forgeloop-phase1/*`
**冻结**。第二阶段只通过指针引用，不改写其正文与历史 Evidence。

「冻结」的边界按下表判定，逐条对应到本次 T-16 的实际动作：

| 类别 | 处置 | 本次是否触及 |
| :--- | :--- | :--- |
| 设计正文与论证（`spac-001-detailed-design.md`） | 不可改 | 否 |
| 已完成 Task 的历史 Evidence 条目 | 不可改 | 否 |
| 已关闭的 Gate 结果 | 不可改 | 否 |
| 指向「下一 Task」的待办占位 | 随 Goal 切换移交权威登记处 | 是 |
| 文件级 `mode` / `next` 续行标记 | 允许改注并说明时点 | 是 |
| 跨 Goal 续行所需的指针与计数 | 允许新增，注明时点 | 是 |

`tasks.md` 末尾原本有一条「第 18 项 T-16」的待办占位。该条目不是已完成的 Task，
它的内容已由 `.ai/forgeloop-phase2/tasks.md` 以 `[x]` 状态登记；两处并存会让同一 Task
拥有两个状态来源，违反 `rules/state-and-recovery.md` §9「静默删除状态」禁止项的意图，
Recovery 场景下的恢复者无法判断哪份权威。故本次**删除该占位条目**并留下移交说明。

> 口径说明：`DESIGN.md` §29 只枚举九个状态值，不含「单一来源」表述（全域 grep 零命中）；
> 「一个 Task 只在一处登记状态」是本项目约定，其可依据的明文条款是
> `rules/state-and-recovery.md` §9 的静默删除禁令。

`evidence.yaml` 的改动限于文件级 `next: T-16` 续行标记的注释——补记「Phase 1 于 T-15
收口，T-16 起进入第二迭代」。该字段按 `goal-mode.md` §4 本就是每次 Checkpoint 后覆写的
续行指针，不承载任何已验证结论。第二阶段的 Evidence 条目一律追加在
`.ai/forgeloop-phase2/evidence.yaml`，第一阶段的 Evidence 区不新增任何条目。

## 5. B-03 的解除路径

`version-governance.md` §9.2 给出 Software 类对象的元数据位置为 package manifest
或**专用 `VERSION` 文件**；§4.6 禁止在多处手工编辑版本号；§1.3 第 5 条要求单一权威源。

本仓库无 package manifest，故裁定：版本源 = 仓库根的 `VERSION` 文件（唯一权威源）。
其它位置（`version-state.yaml` 的 `project.version`、CHANGELOG 抬头、tag 名）
一律**引用** VERSION，不各自手写。

**版本号本身**与**版本源位置**是两件事。前者依 §4.1 的 SemVer 规则判定，在 N 阶段
（Release）落定；后者即本节裁定，在 T-17 执行。

**明确不做**：从 `DESIGN.md` 首部的 `Version: 1.0.0` 推导 Project Version。
那是 Design Version，`rules/version-management.md` §4 与 `AGENTS.md` §7 均禁止此类推导。

## 6. 自检断言的翻转

第一阶段建立的两条「负向断言」必须在第二阶段翻转，否则它们会拦住正确的实现：

| 断言 | 第一阶段 | 第二阶段 | 翻转执行者 |
| :--- | :--- | :--- | :--- |
| 自检第 1 组 `references/audit-model.md` | **必须不存在**（V-09 无超前实现） | **必须存在且非空** | T-26 |
| 自检第 2 组 `SKILL.md` frontmatter `version:` | **必须不存在**（B-03 未解除） | 与 `VERSION` 文件一致 | T-17 |

第 1 组的翻转必须晚于 `audit-model.md` 产出（T-22 / T-23）。第 2 组不由第 1 组决定——
`VERSION` 文件在 T-17 即建立，`version-governance.md` §4.6 要求版本号单一权威源且禁止
多处手工编辑，故 frontmatter 的 `version:` 字段须与 `VERSION` 同源；该项在 T-17 独立
翻转，不等待 audit-model.md。两条的共同前置都是库副本已同步（第 6 组会校验源码与
库部署目标一致）。

## 7. Task 分解

见 `.ai/forgeloop-phase2/tasks.md`。关键路径：

```text
T-16 范围裁定（本 Task）
  → T-18 D 契约 → T-19 E 契约 → T-20 audit-state schema
  → T-21 D/E 真实演练 → T-22 audit-model L → T-23 audit-model M → T-24 N 契约
  → T-25 延后表述改写 → T-26 自检第 1 组翻转 → T-27 L 演练 → T-28 M 演练
  → T-29 N 演练 → T-30 Phase 2 Final Audit + Goal 收口

T-17 B-03 版本源裁定与自检第 2 组翻转可与 T-18..T-26 并行，只阻塞 T-29
```

## 8. 顺序的三条硬约束

1. **T-22 必须先于 T-25。** T-25 改写 `SKILL.md` / `lifecycle.md` 时会引用
   `audit-model.md`；该文件不存在则自检第 3 组的交叉引用可解析性判 FAIL。
2. **部署必须先于 T-26。** 新增 `audit-model.md` 后源码 .md 从 11 变 12，库部署目标
   未同步时自检第 6 组直接判「文件数量不一致」。按 ADR-003 §4，库副本由
   `manage-skills adopt` + `deploy` 产生，**不得手工复制**让检查通过。
3. **T-27 依赖 T-21 的真实 SPEC/Plan。** §67 的 Audit Matrix 需要 SPEC 列填入真实
   内容，否则 Audit 只能持续产出 Finding、无法达到 PASS。

## 9. Consequences

- 第一阶段 `verification-state.yaml` 的 V-09（无超前实现）在 `audit-model.md` 落地后
  **失效**，须按 `DESIGN.md` §59 置 `STALE` 并由 Phase 2 的对应判据取代。
- `.ai/forgeloop-phase2/` 的状态文件加入后，自检 8b 的全量 YAML 枚举自动覆盖
  （`.ai/*/*.yaml`），无需改脚本。
- Goal 在 T-30 之前不收口：I-007 / I-008、Final Audit Passed、Version State Valid、
  Git State Valid 四项的判定条件在 Phase 2 全程保持未满足（完成条件的六项全称见
  `doc/design/spac-001-detailed-design.md` §5.1）。
- T-16 超出 ADR-007 字面授权的两处脚本改动（CK-16 / CK-17 / CK-18 三项跨文件一致性
  断言，以及 audit-state 探测附带的 T-20 勾选后降级守卫）已在
  `.ai/verification-state.yaml` 的 `checks:` 登记册登记，授权边界交 Review Gate 判定。
  CK-18 针对的是项目自造字段（`task_seq` / `global_task_seq` 在 DESIGN.md 与 rules/
  全域无定义），无设计层保护时恢复者误改不会变红。

