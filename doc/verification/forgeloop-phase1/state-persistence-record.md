# T-12 Checkpoint + State Persistence 验证

对应判据：**V-06**（Checkpoint 由全局 Git Workflow 形成的真实记录）、
**V-07**（State Persistence 真实落盘证据）
日期：2026-10-09
结论：**passed**（含 1 项 Checkpoint 约定修正与 1 项历史记录遗留）

---

## 1. Checkpoint 双重落点（V-06）

Checkpoint 的双重落点（详细设计 §3.5）：结构化字段进 `.ai/development-status.yaml` 与
`version-state.yaml`，Git 记录进版本历史走全局 Workflow。

### 1.1 各 Checkpoint 的 Git 记录可追溯性验证

复跑命令（逐个 commit，可原样复制）：

```bash
for c in 823615b bab31db 2ccef05 a8b60e9 9217165 24d6e2c 0f7fd4f b5d8601 44d9e4f; do
  if git merge-base --is-ancestor "$c" main 2>/dev/null; then
    echo "$c => 在 main 历史 (exit 0)"
  else
    echo "$c => 不在 main 历史 (exit 1)"
  fi
done
```

实际输出：

```text
823615b => 不在 main 历史 (exit 1)
bab31db => 在 main 历史 (exit 0)
2ccef05 => 在 main 历史 (exit 0)
a8b60e9  => 在 main 历史 (exit 0)
9217165 => 在 main 历史 (exit 0)
24d6e2c => 在 main 历史 (exit 0)
0f7fd4f => 不在 main 历史 (exit 1)
b5d8601 => 不在 main 历史 (exit 1)
44d9e4f => 不在 main 历史 (exit 1)
```

### 1.2 Checkpoint ↔ commit ↔ 角色对照

`checkpoint.git_commit` 标量字段实际写入过的值（逐 commit 从 Git 历史提取）。
命令：

```bash
for c in bab31db 2ccef05 a8b60e9 9217165 24d6e2c; do
  echo "--- $c"
  git show $c:.ai/development-status.yaml | grep -E '^  (last|id): CP|^  git_commit:'
done
```

字面输出：

```text
--- bab31db
  last: CP-001
  id: CP-001
  git_commit: 823615b
--- 2ccef05
  last: CP-002
  id: CP-002
  git_commit: bab31db
--- a8b60e9
  last: CP-002
  id: CP-002
  git_commit: bab31db
--- 9217165
  last: CP-004
  id: CP-004
  git_commit: 0f7fd4f
--- 24d6e2c
  last: CP-005
  id: CP-005
  git_commit: 9217165
```

**整理后对照表**（上表字面输出的归纳，便于阅读）：

```text
bab31db => git_commit: 823615b | last: CP-001
2ccef05 => git_commit: bab31db  | last: CP-002
a8b60e9  => git_commit: bab31db | last: CP-002   （CP-003 的结构化 last 未落盘）
9217165 => git_commit: 0f7fd4f | last: CP-004
24d6e2c => git_commit: 9217165  | last: CP-005
```

据此区分三种 commit 角色：

| commit | 是否在 main | 角色 |
| :--- | :---: | :--- |
| `823615b` | 否 | CP-001 当时写入的**分支内** commit（已失联） |
| `0f7fd4f` | 否 | CP-004 当时写入的**分支内** commit（已失联） |
| `bab31db` | 是 | CP-001 交付内容的 main 侧 squash commit |
| `2ccef05` | 是 | CP-002 交付内容的 main 侧 squash commit |
| `a8b60e9` | 是 | **CP-003** 交付内容的 main 侧 squash commit（PR #9，T-10b-EXEC-1） |
| `9217165` | 是 | CP-004 交付内容的 main 侧 squash commit |
| `24d6e2c` | 是 | CP-005 交付内容的 main 侧 squash commit |
| `b5d8601` / `44d9e4f` | 否 | T-11 / PR #11 的分支内 commit，squash 后失联 |

**`a8b60e9` 是 CP-003 的定性与依据**（第 2 轮 Review 判 Blocker——初稿称其为
「EXEC-1 的 implementation commit（非 CP 主记录）」并据此在 history 中跳过 CP-003，
该定性错误）：

```text
$ git log -1 --format='%h parent=%p' a8b60e9
a8b60e9 parent=2ccef05

$ git show 9217165:.ai/version-state.yaml | grep 'clean:'
  clean: true                    # CP-003 已合并至 main（PR Swcmb/forge-loop#9）

$ git show 24d6e2c:.ai/version-state.yaml | grep 'clean:'
  clean: true                    # CP-003 已合并至 main（PR Swcmb/forge-loop#9）
```

三条事实合并：`a8b60e9` 的父提交 `2ccef05` 本身即当时的 `main`（squash 合并的拓扑特征）；
其提交信息自述「三次提交 squash」；仓库内已提交的 `version-state.yaml` 在两个 commit 中
都写明 CP-003 经 PR #9 合并至 main。PR 编号自洽（#7=bab31db、#8=2ccef05、
#9=a8b60e9）。

**证据强度的诚实标注**：#7 与 #8 有提交信息内的 `(#7)` / `(#8)` 佐证；#9 的唯一来源是
`version-state.yaml` 的注释行，与紧邻的第三条证据**同源**，不构成独立交叉验证。因此
CP-003 的归属由「父提交拓扑」与「提交信息自述 squash」两条**互相独立**的事实支撑，
PR 编号仅为佐证。

**初稿为何错**：把「`a8b60e9` 这个 commit 里 `checkpoint.last` 字段的快照值是 CP-002」
读成了「CP-003 不存在」。`checkpoint.last` 是标量、每个 Checkpoint 覆写一次，某个 commit
里的取值只反映**该 commit 时刻的状态文件内容**，不反映历史上发生过哪些 Checkpoint。

### 1.3 发现的缺口与修正

**缺口（两类，性质不同）**：

1. **悬空指向** —— CP-001 记 `823615b`、CP-004 记 `0f7fd4f`，二者均为 squash 前的分支内
   commit，分支删除后从 main 历史消失。§54 声明的 Rollback / Resume / Progress Tracking /
   Version Comparison 四项用途对这两次 Checkpoint 均无法执行。
2. **指向滞后一格** —— CP-002 记 `bab31db`（实为 CP-001 的 main 侧 commit）、CP-005 记
   `9217165`（实为 CP-004 的 main 侧 commit）。这类值是有效的 main 侧对象，但指向了**上一
   个** Checkpoint 交付的 commit，而非本次交付的 commit——排查时会把变更归错 Checkpoint。
3. **结构化落盘缺口** —— CP-003 的 `checkpoint.last` 从未落进任何 commit（取值集合只有
   CP-001/002/004/005），被 CP-004 的状态写入直接覆盖。Git 侧有 a8b60e9 锚点，结构化侧
   无记录。按「CP-001..CP-005 均有结构化记录」表述会高估 V-06 的落盘覆盖率，并让 T-13
   Recovery 按不存在的落点恢复。

**根因**：squash 合并产生的新 commit 无法包含自身 hash，且合并发生在状态文件写入之后。
单标量 `git_commit` 只能承载「最近一个已知 main 侧 hash」，结构上无法同时满足两项要求。

**修正（本轮落地）**：

1. 标量 `checkpoint.git_commit` 明确为**当前** Checkpoint 的 main 侧 hash；形成它的 commit
   无法自含，故先写占位值，由下一 Task 回填。
2. 新增 `checkpoint.history` 列表，逐 Checkpoint 固化 `id + git_commit` 配对，补齐上表
   中可确证的配对（含 CP-003），使 §54 的 Version Comparison 与 Progress Tracking 有稳定
   锚点；CP-003 的落盘缺口在 `note` 字段显式披露。
3. 占位值词表统一为 `pending: <task> merge`，并在 `rules/git-integration.md` 立为项目规则，
   跨 Goal 有效。
4. 自检 8c 组对每个非占位值锚点实测 `git merge-base --is-ancestor`，使「悬空 hash」这类
   缺陷无法回归而不被发现。

## 2. State Persistence 前后对比（V-07）

`.ai/` 状态文件在 Task 周期内的真实演进（从 Git 历史提取，可复查）：

### 2.1 `development-status.yaml`（CP-004 → CP-005）

| 字段 | 前（EXEC-2 收尾，commit 9217165） | 后（T-11 完成，commit 24d6e2c） |
| :--- | :--- | :--- |
| `task.current` | T-11 | T-12 |
| `iteration.task_seq` | 12 | 13 |
| `checkpoint.last` | CP-004 | CP-005 |

### 2.2 `version-state.yaml`

| 字段 | 前 | 后 |
| :--- | :--- | :--- |
| `iteration.current` | ITER-002 | ITER-002 |
| `git.head` | 0f7fd4f | 0f7fd4f |

`git.head` 未随 CP-005 更新。本 Task 在 main 上同步修正为 CP-005 的 main 侧 hash `24d6e2c`。

**第二次修正（本 Task 收口时的 Reconcile）**：初次修正误将 `44d9e4f`（PR #11 的**分支头**，
squash 前的分支内 commit）写入 `git.head`。该 commit 经
`git merge-base --is-ancestor 44d9e4f main` 判定**不在 main 历史**（exit 1），
与本 Task 刚建立的「统一记 main 侧 hash」约定自相矛盾——同一个仓库里两处 Git 事实
采用了两种口径。已统一修正为 `24d6e2c`（CP-005 的 main 侧 squash commit，
`--is-ancestor` exit 0）。

本次 Reconcile 依据 §98 Goal Resume 恢复链 + §3.5 冲突判据得出，判定对象为
「状态文件记录的 Git 事实」与「实际 Git 事实」的逐项比对，而非对话记忆。

### 2.3 状态演进均由真实提交驱动

上述前后对比均可通过 `git show <commit>:.ai/<file>` 复查，非对话记忆。

## 3. 状态/Git 冲突判据负向测试（§3.5）

判据（详细设计 §3.5）：

```text
比对对象 = 代码与文档路径（排除 .ai/）
命令     = git status --porcelain -- ':!.ai/'
冲突条件 = ① 上式非空（代码/文档有未提交改动）
         且 ② development-status.yaml 的 task.status 为 complete
处置     = STOP AUTO-PROGRESSION → 进入 recovery.md 的 Reconcile
```

### 3.1 正向：制造不一致，断言判据触发停止

```text
步骤1：临时将 .ai/development-status.yaml 的 task.status 置为 complete（模拟 Runtime 报完成）
步骤2：制造 Git 未提交改动——新建 doc/verification/forgeloop-phase1/.conflict-probe.md
步骤3：执行判据
```

步骤3 的完整输出（`git status --porcelain -- ':!.ai/'`，执行时工作树的**全部**非 `.ai/`
改动均已列出，探针的触发源因此可确证，不靠推断）：

```text
 M doc/verification/forgeloop-phase1/state-persistence-record.md
?? doc/verification/forgeloop-phase1/.conflict-probe.md
```

```text
① 代码/文档未提交改动: [非空] → 上述两项
② task.status: complete
判据结果: 冲突成立 → STOP AUTO-PROGRESSION → 进入 Reconcile（不推进 Task）
```

说明：判据条件①按「非空」判定，不指定触发源。执行时本文件 `state-persistence-record.md`
自身亦为未提交状态（它就是 T-12 的产出），与探针并列出现。两者都满足①，判据按设计
只要求「存在未提交改动」即触发，无需区分触发源。

**结论**：Runtime 报 Task 完成但 Git 存在未提交代码改动时，判据正确触发并要求停止推进，
进入 Reconcile 而非继续——满足 `rules/state-and-recovery.md` §5「状态与 Git 不一致时
停止自动推进」。

### 3.2 反向：清除改动，断言判据不误报

```text
删除 .conflict-probe.md，Runtime 仍为 complete
  ① 代码未提交改动: [空]
  ② task.status: complete
  判据结果: 无冲突（判据①不满足）→ 正常推进，判据不误报
```

**结论**：Git 干净时即便 Runtime 报 complete，判据也不误报。两个条件是**合取**关系，
任一不满足即不触发停止。

### 3.3 复原

负向测试全程受控：临时 status 改动与探针文件均已复原，`task.status` 回到 `ready`。

## 4. Checkpoint 双重落点的字段完整性

按 DESIGN.md §53，Checkpoint 记录含 `goal.id` / `iteration.id` / `task.id` / `git.commit` /
`spec.version` / `progress.requirements`。

**本 Task 初稿在此处高估了覆盖范围，已修正**：初稿称这些字段「经自检 CK-09 校验存在性」，
经复验不成立——`scripts/check-forge-loop.sh` 的 `check_keys` 只断言 `development-status.yaml`
的 7 个顶层键，`check_leaf` 仅施加于 `version-state.yaml` 的 `iteration.current` 与
`git.branch` / `git.head` / `git.clean`。`checkpoint.id` / `checkpoint.git_commit`
从未被脚本断言；`progress.requirements` 键在两个状态文件中**均不存在**。

本轮的处置是**补齐 + 按 §53 原字段名落地 + 扩断言**，而非下调结论：

1. `.ai/development-status.yaml` 的 `checkpoint` 段按 §53 原字段名落地六字段：
   `goal.id` / `iteration.id` / `task.id` / `git.commit` / `spec.version` /
   `progress.requirements.{total,verified}`。
2. 自检新增 **CK-10**：按 YAML 路径断言上述六字段存在且非空（9 条断言）。
3. 新增 **CK-11**：断言 `checkpoint.history` 为非空列表、每项同时含 `id` 与 `git_commit`。
4. 新增 **CK-12**：对 `history` 中每个非占位值的 `git_commit` 实测
   `git merge-base --is-ancestor <hash> <集成分支>`，校验锚点真实可达。占位值按
   `rules/git-integration.md` §11.2 的词表豁免，并显式 PASS 留痕。

扩断言后的正向与负向证据见 `doc/verification/forgeloop-phase1/test-record.md` §6。

### 4.1 DI-09：字段名偏离 §53（本 Task 引入并修正）

§53 的 Checkpoint 字段名为 `task.id` / `git.commit` / `spec.version`。本 Task 初稿落地为
`task.current` 与标量 `git_commit`，并把 `spec.version` 放在 `version-state.yaml` 顶层——
三项均偏离 §53。按 `AGENTS.md` §5（Design 是唯一权威，发现冲突先修正引用方），本轮已把状态
文件改回 §53 原字段名与原层级。记为 DI-09。

设计文档本身未被修改：DESIGN.md 的修改需用户明确指示（`AGENTS.md` §5），此处只修正引用方。

## 5. 关联

- 结构化证据：`.ai/forgeloop-phase1/evidence.yaml`（REQ-008）
- Review 记录：`doc/verification/forgeloop-phase1/review-record.md`
- Test 记录：`doc/verification/forgeloop-phase1/test-record.md`
- Verify 记录：`doc/verification/forgeloop-phase1/verify-record.md`

## 6. Checkpoint hash 回填规则

squash 合并产生的新 commit 无法包含自身的 hash，因此 `checkpoint.git.commit` 无法在
形成它的那个 commit 内自洽。项目规则（`rules/git-integration.md` §11）约定：

```text
CP 形成的 commit  →  checkpoint.git.commit 写占位值 "pending: <taskID> merge"
下一 Task 的 commit →  回填该 CP 在集成分支上的 hash，并同步 version-state.yaml 的 git.head
```

这是 squash 语义下的结构性约束，不是记录疏漏。

**DI-09 的连带修正**：本 Task 初稿把该字段落地为标量 `checkpoint.git_commit`，偏离 §53 的
`checkpoint.git.commit`（嵌套结构）。已改回 §53 原字段名与原层级，见 §4.1。

**规则存放位置的修正**：初稿把该约定整段写进 `.ai/development-status.yaml` 的
`checkpoint.convention` 字段。该文件是 per-Goal 运行态文件（文件头自述「由 T-03 建立；
每个 Checkpoint 时更新」），FL-002 建立时会被重写，约定随之消失，下一个 Goal 的
Checkpoint 将重新落回分支内 commit——恰是本 Task 花大力气修掉的缺陷复发。故规范条文
迁至 `rules/git-integration.md`（跨 Goal 有效），`.ai/` 内只保留一行指针。

占位值保留在 `.ai/` 内是刻意的：`rules/state-and-recovery.md` §9 要求「状态必须能够
解释当前工程为什么处于当前阶段」，而 `checkpoint.convention` 这行指针使恢复链读者
能立即判读待定值含义并查到规则全文。

## 7. Code Review Gate 记录（DESIGN.md §37 六维）

Reviewer：`code-reviewer` agent（第 1 轮 FINDINGS → 全部修复 → 第 2 轮复核）。
独立复验基线：8 个 commit 的 `git merge-base --is-ancestor <c> main` 退出码，以及
`git show <c>:.ai/development-status.yaml` 的逐字段提取。审查范围含未跟踪的
本文件全文。

### 7.1 第 1 轮判定

**FINDINGS —— 1 Blocker + 6 Important + 3 Minor。**

| 编号 | 维度 | 问题 | 处置 |
| :--- | :--- | :--- | :--- |
| Blocker | Correctness | §1.2 称「CP-005 由分支内 `b5d8601` 修正为 `24d6e2c`」，而 `git show 24d6e2c:.ai/development-status.yaml` 的值是 `9217165`，从未是 `b5d8601`。补救动作被记为虚构，V-06 的 passed 建立其上。同源错误另见 `evidence.yaml` 与 `verification-state.yaml` | §1.2 按真实历史重写，区分「悬空指向」与「指向滞后一格」；两处同源表述同步修正 |
| Important | Correctness | REQ-008 预置 `review.status: passed`（Gate 输入自称已通过），且 REQ-008 已置 VERIFIED、V-06/V-07 已置 passed | 第 1 轮 Review 结论落定前不接受这些前置断言；修复后的实际结果写入 `evidence.yaml` 的 `review` 段 |
| Important | Regression | `development-status.verification.pending` 未随 V-06/V-07 转正 | `passed` 补入 V-06/V-07，`pending` 收窄为 `[V-08]` |
| Important | Correctness | §4 称 §53 六字段「经 CK-09 校验」，实为高估；`progress.requirements` 键不存在 | 补齐四字段 + 自检新增 8c 组逐字段断言（见 §4 与 test-record.md §6） |
| Important | Architecture | 单标量 `git_commit` 无法承载 §54 的 Version Comparison / Progress Tracking | 新增 `checkpoint.history` 逐 CP 配对 + 8c 组配对断言 |
| Important | Scope | 跨 Goal 的约定写入 per-Goal 运行态文件，FL-002 即丢失 | 规范条文迁至 `rules/git-integration.md` §11，`.ai/` 只留指针（见 §6） |
| Important | Regression | 占位值两套拼写（`pending: <task> merge` vs `pending: T-12 commit`）；回填未规定同步 `git.head` | 词表统一为 `pending: <taskID> merge`；规则 §11.2 明确回填须同步 `version-state.git.head` |
| Minor | Maintainability | 顶部段头与 CP-006 段头重复，且顶部段头下辖的是 REQ-005 | 顶部改为文件级续行标记段头，不标 CP |
| Minor | Maintainability | §1.1 命令不可原样复跑；无 CP↔hash↔角色映射 | 改为可复跑脚本 + 真实输出 + 角色表 |
| Minor | Correctness | `git.clean: true` 的语义时点未界定 | 注释写明「截至最近一次 Checkpoint 提交，不是本会话此刻」 |

### 7.2 第 2 轮判定

**FINDINGS —— 1 Blocker + 3 Important + 4 Minor。**

| 编号 | 维度 | 问题 | 处置 |
| :--- | :--- | :--- | :--- |
| Blocker | Correctness | §1.2 把 `a8b60e9` 定性为「非 CP 主记录」并据此跳过 CP-003。实为 CP-003 的 main 侧 commit（父提交 `2ccef05`=main、提交信息自述三次 squash、仓库内 `version-state.yaml` 两处声明 PR #9） | 角色表更正 + 附三条拓扑证据；`checkpoint.history` 补 CP-003 条目并在 `note` 披露结构化落盘缺口（见 §1.2） |
| Important | Correctness | V-06 结论「CP-001..CP-005 均有结构化记录」对 CP-003 不成立：`checkpoint.last` 取值集合仅 CP-001/002/004/005 | 措辞改为区分「Git 侧确认」与「结构化 last 落盘」，并把该覆盖缺口列为已知遗留（`verification-state.yaml` V-06、`evidence.yaml` AC-012） |
| Important | Correctness | §53 六字段中 3 项偏离：落地为 `task.current`（§53 为 `task.id`）、标量 `git_commit`（§53 为嵌套 `git.commit`）、`spec.version` 落在 `version-state.yaml` 顶层（§53 置于 checkpoint 下） | 状态文件改用 §53 原字段名与原层级；8c 注释与本记录 §4/§6 同步更正；记为 DI-09（见 §4.1） |
| Important | Correctness | 第 1 轮 Important 1 未真正闭环——`rounds: 2` 与「复审无阻断项 / Gate 判定 PASS」在第 2 轮尚未发生时即已写入，断言从 `status` 字段搬到了 `verdict` 字段 | `evidence.yaml` REQ-008 的 `review.status` 置 `pending`、`verdict` 置「待第 3 轮结论落定后回填」 |
| Minor | Maintainability | 8c 内嵌 python 抛异常时 stdout 为空、heredoc 仍 exit 0，while 循环零次执行 → 11 条断言静默消失且不计 skip，汇总从 63 掉到 52 无任何标记 | 显式断言 python 输出行数 `< 11` 即判 FAIL 并清空，使降级留痕 |
| Minor | Correctness | 8c 只校验形状不校验锚点可达性，悬空 hash 写回 history 仍 63/63 全绿 | 新增 CK-12：对非占位值的 `git_commit` 实测 `git merge-base --is-ancestor`；占位值按 §11.2 词表豁免并显式 PASS 留痕 |
| Minor | Architecture | `rules/git-integration.md` §11.1 把集成分支硬编码为 `main`，而分支名属全局 Git Rules 的 Branch Policy 参数 | 改为「集成分支（当前 main）」并注明分支名不属本 Rule；脚本侧改用 `INTEGRATION_BRANCH` 变量（可用 `FORGELOOP_INTEGRATION_BRANCH` 覆盖） |
| Minor | Maintainability | §1.2 的「实际输出」是重排版，与命令字面输出不符（合并行、调整字段顺序） | 改为「字面输出」+ 独立标注的「整理后对照表」两段 |

> Reviewer 附注（非 Finding）：`requirement-matrix.yaml` 中 REQ-001..007 仍为 `IMPLEMENTED`
> 而 `evidence.yaml` 已 `verified`。该分歧在 `24d6e2c` 即存在，本轮修复时已一并对齐——
> REQ-001..007 置 `VERIFIED`，REQ-008 置 `REVIEWING`（Review Gate 落定后转 `VERIFIED`），
> REQ-009 留 `PENDING`（归 T-13）。该状态分布由自检 CK-13 逐字段核对。

### 7.3 第 3 轮判定

**FINDINGS —— 0 Blocker + 4 Important + 7 Minor。**

Reviewer 对 Git 历史的全部断言做了独立复验，**零偏差**：§1.1 的 9 个 ancestry 结论、
§1.2 的字面输出块（含 `a8b60e9` 处的 `last: CP-002`）、`a8b60e9` 的父提交、
两处 `version-state.yaml` 的 PR #9 声明、提交信息的 squash 自述、§2.1/§2.2 的前后对比表、
`checkpoint.last` 取值集合、全 29 个 commit 对象计数、四条悬空 hash 的父子拓扑成因，
以及 DI-09 所依据的 `DESIGN.md:1654 §53` 字段名，全部逐条实测一致。

| 编号 | 维度 | 问题 | 处置 |
| :--- | :--- | :--- | :--- |
| Important 1 | Correctness | Test Gate 记录的三处数字与代码脱节（「17 条断言」「pass: 69」「期望 ≥11」） | 全部改用实测值：8c 20 条断言、`pass: 75`、守卫消息改为退出码形态。**注意**：这是第 3 轮当时的实测值，第 4 轮补入 CK-14 后基线升至 22 条 / `pass: 76`；本行的历史数字不应被当作当前值引用 |
| Important 2 | Correctness | 行数守卫在消费内容**之前**判定并 `ck8c=""`，导致 N2/N3 声称的失败信息在当前脚本下不可达（复现：13 行 / 12 行 < 19，触发守卫吞掉真实诊断） | 与 Important 4 同源，一并修复 |
| Important 3 | Correctness | §7.2 的 Reviewer 附注写「REQ-001..008 全部置 VERIFIED」，与落盘的 REQ-008 = `REVIEWING` 直接矛盾 | 附注改为「REQ-001..007 置 VERIFIED，REQ-008 置 REVIEWING（第 3 轮结论落定后转 VERIFIED），REQ-009 留 PENDING」 |
| Important 4 | Correctness | 行数守卫把「状态文件有缺陷」误标为「判据静默失效」——行数天然随缺陷减少 | 守卫改为按 python 退出码判定（`rc ≠ 0` 才拦截）；数据缺陷路径原样消费 FAIL 行 |
| Minor 1 | Maintainability | `ck8c_py_rc` 采集后从未读取（死变量） | 并入 Important 4 的修复，变量转为实际使用 |
| Minor 2 | Maintainability | `2>/dev/null` 把「集成分支不存在（exit 128）」与「锚点不可达（exit 1）」压成同一条诊断；分支名写错时 6 条锚点会一并误报 | 先 `git rev-parse --verify` 判分支存在性，失败单独报一条 |
| Minor 3 | Maintainability | `progress.requirements` 的 `reviewing` / `pending` 两个计数器无人校验 | CK-13 扩展为核对全部四个键 |
| Minor 4 | Maintainability | Evidence `status` 混入 §58 大写词表，同文件其余 8 条均为小写 `verified` | REQ-008 改为小写 `reviewing`，并注明 Requirement 态由 requirement-matrix 承载 |
| Minor 5 | Correctness | 「PR 编号自洽」中 #9 的唯一来源是 `version-state.yaml` 注释，与紧邻的第三条证据同源，不构成独立交叉 | 显式标注：#7/#8 有提交信息 `(#7)`/`(#8)` 佐证，#9 仅注释声明；CP-003 归属由父提交拓扑与提交信息自述两条独立事实支撑 |
| Minor 6 | Correctness | §58 状态跃迁（IMPLEMENTED → VERIFIED、PENDING → REVIEWING）在状态文件中无留痕 | requirement-matrix 头部加注释，指向 `verification-state.yaml` 的 `gates` 段与三份 Gate 记录 |
| Minor 7 | Scope | REQ-001..007 的状态改动发生在 T-12，而其实现归属 T-01..T-10b | 判定为 T-12 授权内（Reviewer 驱动 + 元数据对齐 + CK-13 依赖），在 `tasks.md` T-12 加附注避免后续归因到 T-10b |

Reviewer 对三个越界疑问的答复：

- **CK-12 判据未越权**——`rules/git-integration.md` §2 列举的七项 Git Policy
  （Branch / Commit / Merge / Rebase / Tag / Push / Remote）§11 一项都未定义；
  §11 规定的是状态字段该记什么值，并把分支名让给全局 Git Rules。
- **DI-09 处置正确**——按 `AGENTS.md` §5 只改引用方，DESIGN.md 未动。
- **Scope 判定通过**——`rules/` §11 与 8c 组在 T-12 授权内，`DESIGN.md` §32 允许同一
  Task 含 Tests 与必要文档更新；仓库已有 CK-07/08（EXEC-1）、CK-09/8b（EXEC-2）先例。

### 7.4 第 4 轮判定

**FINDINGS —— 0 CRITICAL + 2 Major + 4 Minor。**

Reviewer 对守卫改写构造了三个场景实跑（在其临时克隆副本上执行，源仓库只读、blob 哈希复核
零改动），三条路径全部正确：

```text
(a) 内嵌 python sys.exit(3)  → rc=3 一条 FAIL、清空输出、pass: 54 fail: 1  exit 1
(b) history 首项缺 git_commit → 守卫未触发、保留精确诊断「缺失项：0」、pass: 69 fail: 1  exit 1
(c) 集成分支不存在          → 仅 1 条环境诊断、锚点误报数 0、pass: 70 fail: 1  exit 1
默认 main                   → pass: 76 fail: 0，5 条锚点 + CK-14 的 git.head 全 PASS
```

> 上表 (b) 与「默认 main」两行在第 4 轮复审时按当前脚本重取过一次：Reviewer 首次记录的是
> CK-14 加入前的基线（68 / 75），加入 CK-14 后各 +1。本表为**第 5 轮复核时的实测值**，
> 非从上一轮照抄。
>
> **当前基线的构成**（`test-record.md` §6.1 与之一致）：非 8c 段基线 54 条 + 8c 段 22 条
> = 汇总 `pass: 76`。本节表格的「处置」列里出现的 20 条 / `pass: 75` / `pass: 69`
> 均为**当时的历史实测值**，不是当前值——引用时以 `test-record.md` §6 为准。

Git 历史断言再次全部复现：§1.1 九个 ancestry、§1.2 字面输出（逐字节）、`a8b60e9` 父提交
与 squash 自述、§2.1/§2.2 对比表、`checkpoint.last` 取值集合、29 个 commit 对象计数。

| 编号 | 维度 | 问题 | 处置 |
| :--- | :--- | :--- | :--- |
| Major 1 | Correctness | 记录写「8c 20 条断言」，实测 21 条（I-1 的修复自身差一格；`75−54=21` 独立佐证） | 改按 CK 编号分组表述。分组在第 5 轮再补入后加的 CK-14 1 条：CK-10 9 + CK-11 2 + CK-12 6 + CK-13 4 + CK-14 1 = 22 条 |
| Major 2 | Correctness | 四处门条件把「第 3 轮」写死，而第 3 轮已落定、§7.4 称第 4 轮未落定，读者据两条互斥事实会得出相反结论；`rounds` 仍为 2 | 门条件去掉轮次号，改指向权威处（本文档 §7，Code Review Gate 记录，子节 §7.1～§7.6 逐轮记录判定）；`rounds` 同步为 4 |
| Minor 1 | Correctness | N1 行只记「2 条 FAIL」，实测 6 条（2 条 CK-10 + 4 条 CK-13） | 补写完整条数。**第 4 轮当时的 `pass` 为 69**；CK-14 加入后升为 `pass: 70 fail: 6`，以 `test-record.md` §6.2 的现行值为准 |
| Minor 2 | Maintainability | requirement-matrix 头部注释把 §58 跃迁依据指向 `verification-state.yaml` 的 gates 段，但该段自述是 T-10b 的记录、`test_gate` 仍写 52/52 | gates 段改为按 Task 分条累积（`test_gate_by_task` / `review_gate_by_task` / `requirement_gate_by_task`），补 T-12 的 Test / Review / Requirement Gate 记录 |
| Minor 3 | Maintainability | evidence.yaml 称 `reviewing`「沿用 evidence-model.md 词表」，但该词表只定义 `verified` | 改为注明 `reviewing` 借用 `DESIGN.md` §29 的 Task State，Evidence 侧终态仍是 `verified` |
| Minor 4 | Maintainability | V-11 的 evidence 散文手写 status 分布，构成无判据核对的第二份副本 | 改为不复述具体取值，指向 requirement-matrix 为唯一来源；计数一致性交 CK-13 |

**Reviewer 在核对过程中发现的新缺口（本轮补上）**：8c 内嵌 python 里的 `vs` 变量是死变量，
`version-state.yaml` 虽作为 `argv[2]` 传入却从未被读取——这说明
`version-state.git.head` **从来没有可达性判据**。`check_leaf` 只断言该键存在，
而 V-07 记录的缺陷恰恰是 `git.head` 被设为不在集成分支历史的 `44d9e4f`。本轮补
**CK-14** 并重新启用 `vs`，负向证据见 `test-record.md` §6.2 的 N11 与 §6.6。

### 7.5 第 5 轮判定

**PASS —— 0 Blocker / 0 Important / 2 Minor。**

Reviewer 逐项核对第 4 轮的 7 项修复（第 4 轮 6 项 Finding + 第 4 轮核对中新发现的 CK-14），
全部判定为已落地且属实，修复未引入新问题；数字三方对账全部一致：

| 项 | 记录值 | 实测值 | 结论 |
| :--- | :--- | :--- | :--- |
| 汇总 `pass` | 76 | 非 8c 基线 54 + 8c 22 = 76 | 一致 |
| 8c 断言条数 | 22 | 22（PASS 16 + ANCHOR 5 + HEAD 1） | 一致 |
| CK-10 / 11 / 12 / 13 / 14 | 9 / 2 / 6 / 4 / 1 | 9 / 2 / 6 / 4 / 1 | 一致 |
| N1 | 6 FAIL，`pass: 70` | 6 FAIL（CK-10 两条 + CK-13 四条） | 一致 |
| N11 | `pass: 75 fail: 1` | 76 − 1 = 75 | 一致 |
| N10 缺分支 | `pass: 70 fail: 1`，跳过 6 条 | 5 ANCHOR + 1 HEAD = 6 | 一致 |
| §7.4 (a)(b)(c) | 54 / 69 / 70 | 54 / 69 / 70 | 一致 |

Git 历史断言再次零偏差：§1.1 的 9 个 ancestry、§1.2 字面输出（逐字节）、`a8b60e9` 父提交
与 squash 自述、两处 PR #9 声明、§2.1/§2.2 对比表、`checkpoint.last` 取值集合、
29 个 commit 对象计数，全部独立复跑一致。

Reviewer 另确认 CK-14 的鉴别力与判据分层：`git.head` 设为 `44d9e4f` 走 `HEAD` 分支判
不可达；设为 §11.2 占位值走 `else` 分支判 FAIL。并确认「`git.head` 不接受占位值」是
正确取舍——它指向**已合并**的 commit，结构上永远可被已知，与 `checkpoint.git.commit`
因 squash 语义必须用占位值的情形有意区分。

本轮 2 项 Minor（均为文档交叉引用可读性，不影响判据有效性）已顺手收敛：

| 编号 | 问题 | 处置 |
| :--- | :--- | :--- |
| Minor 1 | 门条件把权威处写成 §7「当前判定」节，但 §7 的子节是 §7.1～§7.6，没有同名节 | 改为「§7（Code Review Gate 记录，子节 §7.1～§7.6 逐轮记录判定）」 |
| Minor 2 | §7.4 代码块写现行值 76、处置列保留历史值 75，同节两套基线并存 | 在 §7.4 代码块上方补基线构成声明（54 + 22 = 76），并标明处置列的旧值为历史实测值 |

**Gate 判定：PASS。** REQ-008 的 Code Review Gate 至此落定，状态由 `REVIEWING` 转
`VERIFIED`（`DESIGN.md` §38：Review Gate 通过 + Evidence 八字段齐备 → verified）。

### 7.6 门条件轮次号漂移（本次确立）

把「Review Gate 未落定前不得置 VERIFIED」这类门条件写成「第 N 轮结论落定前」，在轮次推进后
必然失效：读者既按注释判定（N 已落定 → 可置 VERIFIED），又按轮次日志判定（N+1 未落定 →
不可置），两条互斥事实给出相反结论。故门条件只陈述**条件本身**，轮次信息一律到
`state-persistence-record.md` §7 查。本文档 §7 是 Review 轮次的唯一权威处。

### 7.7 Reviewer 独立确认的事实（本记录据此成立）

- 全部 29 个 commit 对象（含不可达）逐一复验 `git merge-base --is-ancestor` 与
  `git show`：`24d6e2c` = `9217165`、`9217165` = `0f7fd4f`、`a8b60e9`/`2ccef05` =
  `bab31db`、`bab31db` = `823615b`（各 commit 内状态文件记录的值）。
- §2.1 / §2.2 的状态前后对比表经 `git show` 逐字段核对属实。
- 8c 的 4 项负向场景（N1–N4）在临时副本上复现，结果与 `test-record.md` §6.2 一致。
- 独立检出 `checkpoint.last` 取值集合为 `{CP-001, CP-002, CP-004, CP-005}`——该事实是
  第 2 轮 Important「CP-003 结构化落盘缺口」的判定依据。
- `version-state.git.head` 由失效值 `0f7fd4f`（不在集成分支历史）改为 `24d6e2c`
  （在集成分支历史）是本 Task 的实质修复。
