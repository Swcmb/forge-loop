# T-13 Recovery 演练

对应判据：**V-08**（Recovery 三场景状态一致证据）
执行者：`code-explorer` 子代理 ×3（A / B / C，均为 `fork_context: false`，即**无对话上下文**；
其中 A 与 C 报告了观察项，B 只执行 probe 重算）
依据：`DESIGN.md` §98 Goal Resume / §99 Compact Resume；`skills/forge-loop/references/recovery.md`
§1 恢复流程与 §4 probe 协议；项目规则 `rules/state-and-recovery.md` §4–§6。
日期：2026-10-10

> **文件状态**：§1 场景 A、§2 场景 B、§3 场景 C 三场景均已完成并附证据。
> 场景 C 执行时本文件曾处于半成品状态，该中间态即其被测对象，§3 如实记录了该时点。

---

## 0. 演练方法

三个场景共用同一个前提：**恢复者没有任何对话上下文**。这决定了演练的构造方式——

```text
不采用「主 agent 自己重读一遍文件然后宣称已恢复」
采用「派发 fork_context: false 的子代理，它只能看到磁盘上的文件」
```

`fork_context: false` 使子代理不继承本会话的历史。若恢复链真的把状态落在了文件里，
子代理应当能独立重建出与主 agent 相同的位置判断；若某个结论只能来自对话记忆，
子代理就答不出来。两种结果都能判定演练成败，不依赖对恢复者的信任。

演练前主 agent 已完成 `rules/git-integration.md` §11.2 要求的回填（CP-006 的
`checkpoint.git.commit` 与 `version-state.git.head` 从占位值改为 main 侧 `578eeaa`），
回填处于未提交状态——这是刻意保留的真实工作树状态，供场景 C 使用。

## 1. 场景 A：Session Restart

`recovery.md` §2 定义的六类场景之一。恢复要点：重新读 `<runtime>/` 全量状态，按
`tasks.md` 定位当前 Task。

### 1.1 执行

派发子代理 A，`fork_context: false`，指令只给出「按 `recovery.md` §1 的恢复流程执行，
回答 10 个关于当前状态的问题，每个答案须给出 file:line 或命令输出」，不透露任何答案。

### 1.2 子代理 A 的独立结论

| # | 问题 | 子代理 A 的回答 | 依据 |
| :--- | :--- | :--- | :--- |
| 1 | Goal id 与标题 | `FL-001` / ForgeLoop 第一阶段端到端闭环 MVP | `development-status.yaml:7-8` |
| 2 | Phase | `ITERATIVE_DEVELOPMENT` | `development-status.yaml:12` |
| 3 | Mode | **Goal Mode**（三处佐证） | `mode: GOAL` + `evidence.yaml` 的 `mode: goal`/`next: T-13` + BL-001 RESOLVED |
| 4 | 当前 Task | `T-13`，`status: ready`；14 项已勾选，下一个待办 T-13 | `development-status.yaml:16-17`、`tasks.md:55` |
| 5 | Iteration | `ITER-002`，`task_seq: 14` | `development-status.yaml:21-22` |
| 6 | 最近 Checkpoint | `CP-006`，工作树 commit `578eeaa`，实测在 main 上可达 | `development-status.yaml:25-30` + 实跑 |
| 7 | `version-state.git.head` | `"578eeaa"`，实测可达 | `version-state.yaml:27` + 实跑 |
| 8 | Requirement 进展 | 9 条，REQ-001..008 = `VERIFIED`，REQ-009 = `PENDING` | `requirement-matrix.yaml` 逐条读出 |
| 9 | 判据进展 | 13 条 passed，V-08 = `pending`（`task: T-13`） | `verification-state.yaml` |
| 10 | 状态 / Git 一致性 | 一致，无需 `STOP AUTO-PROGRESSION` | `git status --porcelain -- ':!.ai/'` 为空（**时点说明见 §1.5**） |

### 1.3 主 agent 核对

逐字段与主 agent 写入状态文件时的实际值比对，**10 项全部一致**，零偏差。子代理
独立算出的 `task_seq: 14` 与「`prev` 列 15 个 Task ID」之间的口径差异，它自己也给出了
解释：T-10b 在列表中拆为 `T-10b-EXEC-1` / `T-10b-EXEC-2` 两个执行单元，故 14 + 1 = 15。
这是子代理自行推导的，主 agent 未提示。

### 1.4 判定

**通过。** 全新会话仅凭文件即完整重建 Goal / Phase / Mode / Task / Iteration /
Checkpoint / Requirement / 判据 / 一致性九个维度，与写入方零偏差。

### 1.5 第 10 项的时点说明（场景 C 发现）

场景 C 的子代理核对时指出：§1.2 第 10 项记录的命令输出「为空」，而该命令在当前工作树
输出非空（`?? doc/verification/forgeloop-phase1/recovery-record.md`）。

**这不是失实记录。** 子代理 A 执行时本文件尚不存在，`recovery-record.md` 自身是后来
写出的未跟踪文件，且落在 §3.5 的比对对象内（排除 `.ai/`）。两条记录描述的是**不同时刻**
的工作树：场景 A 测的是「T-13 尚未落地产物时」，场景 C 测的是「产物已写出后」。

处置是在此处标注时点，而非改动 §1.2 的原始记录——`rules/state-and-recovery.md` §9
禁止静默覆盖历史。

### 1.6 场景 A 报告的 5 项观察（4 处偏差 + 1 项方法学提醒）

子代理 A 在执行 §1.2 的核对时**主动报告**了 5 项观察（它在回答末尾单列「需要你判定的
偏差」，主 agent 未提示）：前 4 项是状态层面的观察，第 5 项是方法学提醒。逐条如下——
其中哪几项构成缺陷，由本节末的计数段与 §4 承载，不在引导句里预先裁定。

| # | 偏差 | 子代理 A 的原述要点 | 主 agent 处置 |
| :--- | :--- | :--- | :--- |
| A-1 | `version-state.yaml` 的 `clean: true` 与 `git status --porcelain` 字面冲突（3 个文件 M） | 注释把语义时点定义为「最近一次 Checkpoint 提交时刻」，配合 §3.5 属预期；但字段名与取值的字面读法仍会误导恢复者 | **当时未处置**（T-12 轮已加过一条时点注释）。场景 C 再次暴露同一问题后，本 Task 补写了完整的口径与时点说明，并把锚定时刻写进字段注释 |
| A-2 | §11.2 回填未提交，只存在于工作树 | 任何只读 HEAD 的恢复者看到的是 CP-006 = `pending: T-12 merge` + `git.head: 24d6e2c` | **属预期**：回填本就是 T-13 的第一个动作，未提交的 Task 中间态符合 §3.5 的 Contingency。T-13 提交后自动消解 |
| A-3 | `verification-state.yaml` 的 V-06 证据文字已过期 | 它写「CP-006 的 checkpoint.git.commit 为占位值…该项从未实测」，而工作树已回填 | **已修正**：改为「已由 T-13 回填并经 CK-12 实测可达，六条锚点全部命中 exit 0」 |
| A-4 | V-09 归属的 Task 未完成但判据已 `passed` | V-09 `task: T-15`、`status: passed`，而 `tasks.md` 的 T-15 仍未勾选——这是一条前向引用 | **已修正**：按详细设计 §5 的权威取值恢复 `task: T-15 + 范围检查`（该值本身即含「范围检查」语义，未丢失），另加 `task_note` 说明 T-15 未执行为前向引用、当前实质证据来自自检第 1 组对 `audit-model.md` 不存在的持续断言 |
| A-5 | 关于 Goal Mode 作用域的提醒 | `mode: GOAL` 的注释写「本会话」，而本次恢复是全新会话；该字段的「本会话」指写入它的那个会话 | **已采纳为方法学说明**：§0 声明演练前提正是「恢复者没有对话上下文」，接手方需在本会话重新激活 `/goal` |

**关于计数口径的准确表述**（初稿曾写成「场景 A 4 处 + 场景 C 4 处 = 8 处真实偏差」，
该说法把「子代理报告的观察项数」误称为「真实缺陷数」）：本节共 5 项观察，其中
A-2 属预期的 Task 中间态、A-5 属方法学提醒，两者都不是缺陷；状态缺陷为 A-1 / A-3 /
A-4 三项。合并 §3.4 的场景 C 四项，全演练共 9 项观察，分类见 §4。

### 1.7 关于 `task_seq` 与 tasks.md 编号的口径差异（M-1）

子代理 A 注意到编号口径的差异，其解释只覆盖了一处。**实测后的完整口径如下**——
本节初稿曾给出错误的第二处归因，第 2 轮 Review 实测后已改写：

```text
tasks.md 已勾选项                    = 14 项      第 1..14 项 = T-01…T-12
development-status.iteration.task_seq = 14        本 Goal 已完成的 Task 数
development-status.task.prev          = 15 个 ID   ← 唯一真实差异
```

**`tasks.md` 已勾选数与 `task_seq` 完全相等（14 = 14），不存在差异。** 第 2 轮 Review 实测
发现本节初稿把 T-09b / T-10a / T-10b 的独立条目误当作差异来源——三者确实各占一项，
且 `task_seq` 也各计 1，两侧对齐，该归因不成立。

**唯一真实差异**是 `task.prev` 列 15 个 ID 而 `task_seq` 为 14：`prev` 记录的是**执行
单元**（T-10b 拆为 `T-10b-EXEC-1` / `T-10b-EXEC-2`），`task_seq` 记录的是**Task 数**。
两者语义不同，数值本就应不同。

另需注意 `tasks.md` 第 15 项是当前进行中的 T-13：列表项号 = 已完成数 + 1，故第 15 项
与 `task_seq` 的 14 相差 1 属**未完成态**的正常表现，不是口径差异。

该差异在 `24d6e2c` 即存在，非 T-13 引入。本 Task 只作说明不改口径——改口径会让
`task_seq` 与既有 Checkpoint 记录失去可比性。

---

## 2. 场景 B：Context Compaction

`DESIGN.md` §99 Compact Resume。压缩由 harness 触发，agent 无法控制时机与内容，
故 `recovery.md` §4 给出 probe 取证协议。本演练按该协议执行。

### 2.1 协议执行（`recovery.md` §4 五步）

| 步骤 | 协议要求 | 本次执行 |
| :--- | :--- | :--- |
| 1 | 压缩前计算状态文件 sha256，与当前 Iteration ID 一并记入 probe | 主 agent 取 5 个状态文件的 SHA256 基线（见 §2.2），Iteration ID = `ITER-002` |
| 2 | 触发压缩 | **agent 无法调用 `/compact`**，改用**性质相近**的构造：派发零上下文子代理 B。相似与不相似之处见 §5 |
| 3 | 恢复后重读 `<runtime>/` 全量状态，重算 sha256 | 子代理 B 独立重算 5 个文件的 SHA256，并独立重建工作位置（见 §2.3） |
| 4 | 判定：两值一致 → 通过 | 5 个值逐一比对，见 §2.3 |
| 5 | 声明 `restored_from: files-only` | 子代理 B 显式声明，见 §2.3 |

第 2 步的替代构造需要说明：`/compact` 是 harness 命令，agent 无法调用。用零上下文
子代理替代的理由是二者在本演练要验证的**核心性质上相近**——恢复者只能从文件重建
认知。相近不等于相同，差异清单见 §5。把「agent 无法触发 `/compact`」写成「已实测
`/compact`」，那才是失实记录。

### 2.2 压缩前基线（主 agent 取）

```text
7d7274a0b420f4675632ddd790e9e44d244ce1549f366b0b0a893529763a9386  .ai/development-status.yaml
ccafb73f067e4871d8050b93dd306c378a9030f3adf78a1a4f5b65f1c46fd270  .ai/version-state.yaml
bb05ad5aa31c3d2bfa006bc8aa6881faac6725124b366e50f86721f1ae51282c  .ai/verification-state.yaml
fc280b984faad399a59f1ed17578119ff5a62b0a4ee4855ff1b7ad26c6547794  .ai/forgeloop-phase1/tasks.md
36e029acd04ab0057c72b168cc1a3dea78ae2a23e3b6dbf583991a0e37f0fea1  .ai/forgeloop-phase1/evidence.yaml
```

命令：`Get-FileHash -Algorithm SHA256 <path>`（PowerShell，结果收进数组后输出）。

### 2.3 恢复后重算（子代理 B 独立执行）

子代理 B 独立重算 5 个 SHA256，结果与 §2.2 **逐一字节一致**：

```text
7d7274a0b420f4675632ddd790e9e44d244ce1549f366b0b0a893529763a9386  ← 一致
ccafb73f067e4871d8050b93dd306c378a9030f3adf78a1a4f5b65f1c46fd270  ← 一致
bb05ad5aa31c3d2bfa006bc8aa6881faac6725124b366e50f86721f1ae51282c  ← 一致
fc280b984faad399a59f1ed17578119ff5a62b0a4ee4855ff1b7ad26c6547794  ← 一致
36e029acd04ab0057c72b168cc1a3dea78ae2a23e3b6dbf583991a0e37f0fea1  ← 一致
```

子代理 B 同时独立重建了工作位置，全部与状态文件一致：

| 项 | 子代理 B 的独立结果 |
| :--- | :--- |
| Iteration ID | `ITER-002` |
| Checkpoint | `CP-006` / `578eeaa`（PR Swcmb/forge-loop#12 squash） |
| `version-state.git.head` | `"578eeaa"` |
| `git rev-parse --short HEAD` | `578eeaa` — 与上一行**一致** |
| 下一个未勾选 Task | T-13 Recovery 演练 |
| `evidence.yaml` 顶部 | `mode: goal` / `next: T-13` |

子代理 B 的恢复来源声明：

```text
restored_from: files-only
```

它自述执行的命令包含 `Get-FileHash -Algorithm SHA256` ×5、`Get-Content -Raw` ×5、
`git rev-parse --short HEAD`、`git status --porcelain -- ':!.ai/'` 等，并明确声明
**未使用任何对话历史记忆**。它还独立指出 `compaction-probe.md` 当时不存在。

### 2.4 判定

**通过。** 5 个 SHA256 逐一字节一致，恢复位置从文件完整重建，且恢复来源经子代理
自身声明为 `files-only`。

---

## 3. 场景 C：Interrupted Work / Partial Execution

### 3.1 被测状态的构造

本场景**不使用模拟数据**。主 agent 在场景 A、B 完成后停止推进，保留一个真实的
「agent 执行 Task 到中途死掉」的工作树：

```text
$ git status --porcelain
 M .ai/development-status.yaml          ← §11.2 回填 CP-006 的 git.commit + history 引号化
 M .ai/forgeloop-phase1/evidence.yaml   ← REQ-008 的 implementation.commit 回填
 M .ai/verification-state.yaml          ← V-06 证据文字更新 + V-09 的 task 字段
 M .ai/version-state.yaml               ← git.head 回填 + clean 口径注释
?? doc/verification/forgeloop-phase1/recovery-record.md   ← 本文件，写到 §2.4 即中断
```

同时 `tasks.md` 的 T-13 保持 `- [ ]` 未勾选，`verification-state.yaml` 的 V-08 保持
`status: pending`、`evidence: null`——即前一个 agent 确实死在 Task 完成之前。

### 3.2 执行

派发子代理 C，`fork_context: false`，指令声明这是 Partial Execution 场景，要求按
`rules/state-and-recovery.md` §6 的五步顺序判定真实工程状态，并明确指示「**不要用
`git status --porcelain` 的全量输出代替 §3.5 判据的实测**」。

### 3.3 子代理 C 的独立判定

**场景归类**——命中 `AGENTS.md` §13 六类中的**两类**：

| 场景 | 成立依据（子代理实测） |
| :--- | :--- |
| Interrupted Work | 本文件自述半成品；`tasks.md` T-13 仍为 `- [ ]` |
| Partial Execution | 4 个 `.ai/` 文件被改；本文件写到 §2 结束；`git log` HEAD 仍是 T-12 的 `578eeaa`，T-13 无任何 commit |

**未命中的一项——Unexpected Git State**：初稿曾把它列入命中表，同时又注明「不构成设计
定义的冲突」，读作「属于某类但其实不属于」，自相抵消。现移出命中表，改为独立说明：
§3.5 判据的两分支实测为条件①成立、条件②不成立，故本场景**不构成**设计定义的
Git/State 冲突，而是判据预期的「正常继续」路径。判据检查已完成，但归类不成立。

Session Restart 与 Context Compaction 是**被演练的场景**，不是本次中断的类型；
Agent Failure 无证据（没有子代理退出状态记录）。

**§3.5 判据逐步实测**——严格按判据原文（比对对象排除 `.ai/`）：

```text
命令     = git status --porcelain -- ':!.ai/'
输出     = ?? doc/verification/forgeloop-phase1/recovery-record.md
条件①    = 成立（输出非空）
条件②    = 不成立（task.status 实测为 ready，非 complete）
冲突条件 = ① AND ② → 不成立
处置     = 不触发 STOP AUTO-PROGRESSION，直接 Resume
```

子代理还指出一个判据覆盖上的细节：`§6` Contingency「恢复时工作树脏但改动仅限 `.ai/`」
在本场景**不适用**，因为脏工作树含一个 `.ai/` 之外的文档文件；而 §3.5 只解释了
「排除 `.ai/`」，未说明「Task 自身的产出物落在比对对象内」时该如何处理。判据本身
按设计仍判定为通过，此处记录为观察项。

**Partial Execution 五步**：

| 步骤 | 子代理 C 的结论 |
| :--- | :--- |
| Inspect Existing Changes | 4 个 `.ai/` 文件的改动逐项归因，全部属于 T-13 的 §11.2 回填与配套证据更新 |
| Determine Completed Work | 本文件已覆盖 §0 方法、§1 场景 A、§2 场景 B，均带独立证据与判定 |
| Determine Remaining Work | §3 场景 C 全缺、汇总结论缺、`compaction-probe.md` 缺失 |
| Determine Verification State | T-13 未勾选；V-08 `pending` / `evidence: null`；`evidence.yaml` 无 REQ-009 条目 |

**关键判定：Continue，不重做。** 子代理引用 `rules/state-and-recovery.md` §6 原文
「不得无条件重复执行」，给出三条对照理由：已完成部分有实质产出且质量可用（重做会丢弃
子代理 A/B 的执行记录）；未完成部分边界清晰；回填改动三处同批写入、自洽。

### 3.4 子代理 C 发现的偏差（本 Task 据此修正）

| # | 偏差 | 处置 |
| :--- | :--- | :--- |
| 1 | 本文件 §2.2 的基线哈希中，`version-state.yaml` 与 `verification-state.yaml` 两行与当前实测不符 | 原因是场景 A 的恢复者指出四处状态偏差后，主 agent 修改了这两个文件（`clean` 口径注释、V-06 证据文字、V-09 的 `task`）。**不修改原记录**，在 `compaction-probe.md` 增设「第 2 次 probe」重取基线，并把时效边界显式写出 |
| 2 | §1.2 第 10 项记录的判据输出「为空」与当前实测矛盾 | 见 §1.5：两条记录描述不同时刻的工作树，标注时点而非改写原记录 |
| 3 | V-06 声称「六条锚点全部命中 exit 0」，但无独立验证 | 已复跑 `scripts/check-forge-loop.sh` → `pass: 76 fail: 0 exit 0`，其中 `锚点 … 在 main 上可达` 命中 **6** 条，断言独立成立 |
| 4 | `task.status: ready` 与 T-13 实际执行中不符 | 记录为观察项，不改动。§3.5 判据只读该字段判 `complete`，无中间态需求 |

### 3.5 判定

**通过。** 零上下文接手方在真实的部分执行工作树上，正确归类了中断场景、严格按判据
原文执行 §3.5、区分出已完成与未完成工作，并明确判定「继续而非重做」。

演练同时产生了实质收益：子代理 C 独立发现的偏差 1 使 `compaction-probe.md` 得以存在，
偏差 2 澄清了 §1.2 的时点语义，偏差 3 促成了一次自检复跑。这三条都不是预设剧本。

---

## 4. 汇总结论（V-08）

| 场景 | 方法 | 判定 |
| :--- | :--- | :--- |
| A Session Restart | 零上下文子代理重建 10 项状态，主 agent 逐字段核对 | 通过，零偏差 |
| B Context Compaction | probe 协议五步，5 文件 SHA256 压缩前后逐一比对，`restored_from: files-only` | 通过，5/5 一致 |
| C Interrupted Work / Partial Execution | 真实半成品工作树 + 零上下文子代理按 §6 五步判定 | 通过，正确判定 Continue |

**V-08 判定：passed。** 三场景均以「恢复者只有文件、没有对话记忆」为前提构造，
结论来自子代理的独立测量而非主 agent 的自我声明。

两个恢复子代理共报告 **9 项观察**（场景 A 5 项见 §1.6，场景 C 4 项见 §3.4），其中
状态缺陷 3 项、时效标注 2 项、验证动作 1 项、预期中间态 1 项、方法学提醒 1 项、
观察项 1 项。全部已在 T-13 内修正或如实记录，无一项被静默忽略。

## 5. 演练方法学的边界（诚实声明）

本次演练**没有**真实触发 `DESIGN.md` §99 所说的 context compaction。压缩由 harness
控制，agent 无法调用 `/compact`，也无法控制其时机与内容。演练用的是零上下文子代理——
它与压缩后恢复的共同性质是「只能从文件重建认知」，但二者并不完全等价：

```text
真实压缩    = 对话被 harness 截断并摘要化，文件不动
本演练      = 子代理从一开始就没有对话上下文，文件同样不动
相同之处    = 恢复者只能依赖 <runtime>/ 下的文件
不同之处    = 真实压缩可能发生在 Task 执行中途，本演练发生在两个 Task 之间的明确边界
```

因此本演练能证明「恢复链的状态落盘是充分的」（文件确实承载了全部恢复所需信息），
**不能**证明「harness 的压缩不会截断掉某些需要保留的信息」。后者属于 harness 行为，
不在 ForgeLoop 可验证的范围内。

## 6. 关联

- probe 原始记录：`doc/verification/forgeloop-phase1/compaction-probe.md`
- Test Gate 证据：`doc/verification/forgeloop-phase1/test-record.md`
- Checkpoint 与状态落盘：`doc/verification/forgeloop-phase1/state-persistence-record.md`
- 状态一致性负向复核（T-14，**待产出**）：`doc/verification/forgeloop-phase1/consistency-recheck-record.md`
- 规则：`rules/state-and-recovery.md`、`skills/forge-loop/references/recovery.md`


