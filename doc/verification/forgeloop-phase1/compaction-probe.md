# Context Compaction 取证 probe

依据 `skills/forge-loop/references/recovery.md` §4「Context Compaction 取证协议」五步。
对应判据：**V-08** 的一部分。演练全记录见 `recovery-record.md` §2。

---

## 第 1 次 probe（T-13 场景 B 原始执行）

### 压缩前基线

```text
7d7274a0b420f4675632ddd790e9e44d244ce1549f366b0b0a893529763a9386  .ai/development-status.yaml
ccafb73f067e4871d8050b93dd306c378a9030f3adf78a1a4f5b65f1c46fd270  .ai/version-state.yaml
bb05ad5aa31c3d2bfa006bc8aa6881faac6725124b366e50f86721f1ae51282c  .ai/verification-state.yaml
fc280b984faad399a59f1ed17578119ff5a62b0a4ee4855ff1b7ad26c6547794  .ai/forgeloop-phase1/tasks.md
36e029acd04ab0057c72b168cc1a3dea78ae2a23e3b6dbf583991a0e37f0fea1  .ai/forgeloop-phase1/evidence.yaml
```

Iteration ID（随基线一并记录，协议第 1 步）：`ITER-002`

### 恢复后重算（零上下文子代理独立执行）

5 个值与上表**逐一字节一致**，`restored_from: files-only`。

**判定：通过。**

---

## 该 probe 的时效边界（场景 C 演练中发现）

场景 C 的零上下文子代理在独立核对时发现：上表的 `version-state.yaml` 与
`verification-state.yaml` 两行**与当前磁盘实测值不符**。

```text
version-state.yaml       第 1 次记录 ccafb73f… → 当前实测 eea8247c…  不符
verification-state.yaml  第 1 次记录 bb05ad5a… → 当前实测 4ecde676…  不符
其余三个文件            一致
```

**原因不是失实，而是时序**：基线取于场景 B 执行时点；此后场景 A 的恢复者指出了四处
状态偏差，主 agent 据此修改了 `version-state.yaml`（`clean` 口径注释）与
`verification-state.yaml`（V-06 证据文字、V-09 的 `task` 字段）。这两个文件的内容
因此在基线之后发生了变化。

**这正是 probe 协议要防的失败模式**：若接手方沿用第 1 次的「五值一致」结论而不重取
基线，就等于引用一份已过期的比对，并把它当成当前工作树的证据。故第 2 次 probe 重取基线。

原记录**不修改、不覆盖**——`rules/state-and-recovery.md` §9 禁止静默覆盖历史。
第 1 次的数值与其当时的判定一并保留在上节，本节只补充时效说明。

---

## 第 2 次 probe（场景 C 收口时重取，锚定当前工作树）

### 基线

```text
7d7274a0b420f4675632ddd790e9e44d244ce1549f366b0b0a893529763a9386  .ai/development-status.yaml
eea8247c2835d1fc25c583fbf62538d14dfe73f534533f264219ddbdcd70fee4  .ai/version-state.yaml
4ecde676a23fa9698fafaf1b79d28c5d53dc49799107c23208e288bd25ed8ee0  .ai/verification-state.yaml
fc280b984faad399a59f1ed17578119ff5a62b0a4ee4855ff1b7ad26c6547794  .ai/forgeloop-phase1/tasks.md
36e029acd04ab0057c72b168cc1a3dea78ae2a23e3b6dbf583991a0e37f0fea1  .ai/forgeloop-phase1/evidence.yaml
```

Iteration ID：`ITER-002`

命令：`Get-FileHash -Algorithm SHA256 <path>`

### 交叉核对

本次基线与场景 C 子代理的独立实测**逐值一致**（含它指出的两个已变更文件），
即该子代理的测量本身是可靠的。

### 判定

基线成立，锚定**该时刻**的工作树状态。

### 时效边界：Task 推进会使 probe 立即过期（本次实测确认）

第 2 次 probe 之后，主 agent 继续推进 T-13 的记录工作——把 V-08 置 passed、把 REQ-009
的 Evidence 写入 `evidence.yaml`、把 `task.status` 置 `reviewing`。这三个动作本身就会
修改状态文件，于是基线再次漂移：

```text
文件                      第 2 次基线      其后实测        变化原因
development-status.yaml   7d7274a0…       eb1969a4…       task.status → reviewing
evidence.yaml             36e029ac…       24b8388d…       写入 REQ-009 条目
verification-state.yaml   4ecde676…       b78964fb…       写入 V-08 的 evidence
tasks.md                  fc280b98…       fc280b98…       未改
version-state.yaml        eea8247c…       eea8247c…       未改
```

**这不是缺陷，是 probe 协议的固有性质。** probe 验证的是「在某一时刻被压缩后，恢复者
能仅凭文件重建出同一状态」，而不是「状态文件此后不再变化」——后者与 Task 正常推进
互斥。`rules/state-and-recovery.md` §6 要求 Task 继续时更新状态；§4 的恢复链又要求
恢复者读到最新状态。两者共同决定了 probe 只能在**离散时刻**取样。

因此本文件的正确读法是：每次 probe 记录「在该时刻，文件足以支撑完整恢复」。判断一份
probe 是否过期，看的是它声称锚定的时刻与使用它的时刻是否相同——而不是看哈希是否
至今未变。接手方若要复用某次 probe，必须重取基线（正如场景 C 的子代理所建议）。

**T-13 收口时的最终基线为文末「第 3 次 probe（待补）」**，取于 Review Gate 落定、状态
文件不再变动之后。该节当前尚未填充——Review Gate 未落定前状态文件仍在变动，此刻取
基线只会立刻过期。此处显式标注「待补」而非留一个指向不存在章节的完成时态承诺。

## 第 3 次 probe（待补）

**状态：已填充。** 取样时机 = Code Review Gate 第 3 轮落定、REQ-009 转 `VERIFIED`、
`.ai/` 状态文件停动之后。

### 基线

```text
bf896cfa27a0cf7780835267ebe1022bc88aacfff73ff117507dc101fa44abd6  .ai/development-status.yaml
0a0063a76b92a75e711a6b361f5cb52283046ec69050723a6822f35dde16bdae  .ai/version-state.yaml
559b6bd6eb74aa7ba19b90956171f03e0f2ce8d8f484d97b9e52a7e256cf2ffa  .ai/verification-state.yaml
8d05b437c9ccb4ff644a4dc3af4a20d8a67ae988b7e7db8ef1aa95cf46353d2c  .ai/forgeloop-phase1/tasks.md
3130d7c691f913aecb434e1810c36c456ab27dd6e1603132fb74ceca354157e8  .ai/forgeloop-phase1/evidence.yaml
```

Iteration ID：`ITER-002`　｜　Task：`T-14`（T-13 已结清）　｜　Checkpoint：`CP-006` / `578eeaa`

命令：`Get-FileHash -Algorithm SHA256 <path>`

### 状态文件已停动的证据

取基线的前一步刚修掉一处 YAML 语法错误并复跑自检通过——该次修改落在 `evidence.yaml`，
故 `evidence.yaml` 的 hash 在上一次取样（`eb1969a4` 时刻为 `24b8388d`）之后再次变化，
上表是修复后的值。此后本 Task 不再修改任何 `.ai/` 状态文件，只补写本 probe 与提交记录。

```text
$ bash scripts/check-forge-loop.sh
pass: 76   fail: 0   skip: 0
RESULT: PASS
exit 0
```

`git status --porcelain -- ':!.ai/'` 的实测输出为两个未跟踪文档
（`compaction-probe.md` 与 `recovery-record.md`），二者落在判据的比对对象内。依
详细设计 §3.5，该输出使冲突条件①成立；而 `task.status` 为 `ready` 非 `complete`，
条件②不成立，故不触发 `STOP AUTO-PROGRESSION`。判据处置与
`recovery-record.md` §3.3 记录的一致。

### 判定

基线成立，锚定 T-13 结清、Phase 1 全部 9 条 Requirement 均为 `VERIFIED` 的工作树状态。
本基线是 T-13 的最终 probe；T-14 起若再次修改状态文件，须按本文件「时效边界」节的规则
重新取样，不得直接沿用。

### 一条值得记录的副产物

填充本节前的最后一次自检**失败**了：`evidence.yaml` 第 333 行含
`fork_context: false` 这一未加引号的裸冒号标量，YAML 报
`mapping values are not allowed here`。这是同类缺陷在本仓库的**第三次**出现
（前两次：`mvp-scope.yaml` 的 `pending: B-03`、`requirement-matrix.yaml` 的
`Evidence 八字段完整 → status: verified`）。

三次都由 T-12 建立的 8b 组（枚举 `.ai/` 下全部 YAML 并解析）捕获，而 8b 在 T-12 之前
根本不解析 `evidence.yaml` 之外的 feature 文件——第三次若发生在 `requirement-matrix.yaml`
或 `mvp-scope.yaml` 上，同样会被抓住。这是「补齐判据覆盖面」这项修复的直接收益，
可作为 CK 类判据价值的实例。

---

## 协议五步与本文件字段的对应

| 协议步骤 | 要求 | 本文件落点 |
| :--- | :--- | :--- |
| 1 | 压缩前算 sha256，与 Iteration ID 一并写入 probe | 「基线」小节 + 各次的 Iteration ID |
| 2 | 触发压缩 | **agent 无法调用 `/compact`**，用零上下文子代理替代（性质相近性论证见 `recovery-record.md` §2.1 与 §5） |
| 3 | 恢复后重读全量状态、重算 sha256 追加到文件尾 | 「恢复后重算」小节 |
| 4 | 判定：两值一致 → 通过 | 「判定」小节 |
| 5 | 声明 `restored_from: files-only` | `recovery-record.md` §2.3（子代理显式声明） |

## 关联

- 演练全记录：`doc/verification/forgeloop-phase1/recovery-record.md`
- 状态一致性负向复核：`doc/verification/forgeloop-phase1/consistency-recheck-record.md`（T-14，**待产出**）
- 判据：`recovery.md` §4；`rules/state-and-recovery.md` §4、§9
