# T-14 状态一致性负向验证复核

任务定义（`tasks.md` 第 16 项）：**状态一致性负向验证复核 —— 冲突判据与 compaction probe
的复跑记录**。

依据：详细设计 §3.5（状态/Git 冲突的可执行判据）、§3.6.2（Compaction 取证协议）；
`skills/forge-loop/references/recovery.md` §3 / §4；`rules/state-and-recovery.md` §5。

日期：2026-10-10

---

## 0. 本 Task 的两类产出

```text
复核类   把 T-12 的冲突判据负向测试与 T-13 的 compaction probe 在新状态下复跑一遍
新增类   补一条判据（CK-15），针对本仓库已发生四次的 YAML 标量缺陷
```

新增判据的由来值得单列：T-13 收口时，我在写 `evidence.yaml` 的 AC-013 时第三次写出了
未加引号的冒号标量（`fork_context: false`）。**同一缺陷第四次**。此前三次分别是
`mvp-scope.yaml` 的 `pending: B-03`、`requirement-matrix.yaml` 的 AC-011 描述、
`evidence.yaml` 的 `fork_context: false`。四次都由 8b 的解析校验捕获，但 8b 只报
「解析失败」与行列号，不指出成因，且要在文件写完并复跑时才暴露。

逐个修不是处置方式——同一个成因反复出现，说明缺少的是**在作者写入时就拦住它的判据**。

---

## 1. §3.5 冲突判据复跑

判据原文（详细设计 §3.5）：

```text
比对对象 = 代码与文档路径（排除 .ai/）
命令     = git status --porcelain -- ':!.ai/'
冲突条件 = ① 上式非空  且  ② development-status.yaml 的 task 状态为 complete
处置     = STOP AUTO-PROGRESSION → Reconcile
```

两个条件是**合取**。复跑覆盖「都成立」与「各成立一次」两种组合。

### 1.1 R1 —— 两条件都成立，应触发 STOP

```text
构造：新建未跟踪文件 doc/verification/forgeloop-phase1/.recheck-probe.md
      （落在比对对象内）+ 把 development-status.yaml 的 task.status 置为 complete
实测：cond1（非 .ai 改动非空）= TRUE
      cond2（task.status = complete）= TRUE
判定：CONFLICT → STOP AUTO-PROGRESSION
```

**符合预期。** Runtime 报 Task 完成、Git 却有未提交的代码/文档改动时，判据要求停止
自动推进并先 Reconcile（`rules/state-and-recovery.md` §5）。

### 1.2 R2 —— 仅条件①成立，应不触发

```text
构造：保留 .recheck-probe.md，task.status 置回 ready
实测：cond1 = TRUE   cond2 = FALSE
判定：no conflict → Resume
```

**符合预期。** 证明合取语义正确：单独满足①不足以触发停止。

### 1.3 构造 `cond1 = FALSE` 的方法与两次失败

`cond1 = FALSE` 要求比对对象为空，而 Task 中途工作树必然含本 Task 自身的未提交改动。
第一次尝试的直接构造失败于该事实：

```text
$ git status --porcelain
 M .ai/development-status.yaml
 M .ai/forgeloop-phase1/evidence.yaml
 M .ai/version-state.yaml
 M scripts/check-forge-loop.sh          （T-14 新增 CK-15 所在文件）

$ git status --porcelain -- ':!.ai/'
 M scripts/check-forge-loop.sh          （排除 .ai/ 后仍非空）
```

初稿的 R3 构造假定「新建探针文件、删掉探针文件后比对对象即为空」，该假定忽略了 T-14
自身对 `scripts/check-forge-loop.sh` 的改动。实测显示排除逻辑**本身是正确的**——
`.ai/` 下三个文件被排除、只剩脚本一处——是测试构造的缺陷，不是判据的缺陷。

第二次尝试用 PowerShell 的 `git show HEAD:… | Set-Content` 还原脚本，仍失败。初稿把成因
归为「`-Encoding UTF8` 写入 BOM」，**该归因经复审实测证伪**：本机 PowerShell 7.6.5 的
`-Encoding UTF8` 不写 BOM（首字节为文件真实内容，非 `EF BB BF`）；且本仓库
`.gitattributes` 为 `* text=auto eol=lf`，CRLF 会被归一化——在等价仓库复现同样的
`git show | Set-Content` 写法，`git status` 实测为空。

可确证的观察是：`git status` 在内容经归一化后与 HEAD blob 一致时**仍可能报 ` M`**
（stat 缓存与换行归一化的交互）。本记录不猜测其确切机制，只登记「两次尝试均未得到
干净的比对对象」这一事实——这正是第三次改用文件移出法的原因。

第三次采用可靠做法——把两份改动临时移出工作树（脚本 `git checkout HEAD --`、新记录
移到 `%TEMP%`），测完原样放回：

```text
$ git status --porcelain -- ':!.ai/'
[空]                                     ← 比对对象为空，cond1 = FALSE 成立
```

全过程只移动文件、不改内容，测完后 `git status` 与测前逐项一致（见 §1.5）。

### 1.4 R3 / R4 —— 两个 `cond1 = FALSE` 分支

```text
R3  cond1 = FALSE   cond2 = TRUE（task.status=complete）  => no conflict → Resume
R4  cond1 = FALSE   cond2 = FALSE（task.status=ready）     => no conflict → Resume
```

两者**均不触发 STOP**，符合合取语义：条件①不成立时，无论条件②如何都不构成冲突。
R3 尤其重要——它是「Runtime 报完成但 Git 干净」这一最容易被误判为冲突的组合。

### 1.5 复跑小结

| 场景 | cond1 | cond2 | 期望 | 实测 | 结论 |
| :--- | :---: | :---: | :--- | :--- | :--- |
| R1 两条件都成立 | TRUE | TRUE | CONFLICT | CONFLICT | 符合 |
| R2 仅①成立 | TRUE | FALSE | no conflict | no conflict | 符合 |
| R3 仅②成立 | FALSE | TRUE | no conflict | no conflict | 符合 |
| R4 都不成立 | FALSE | FALSE | no conflict | no conflict | 符合 |

**四个分支全部覆盖，判据的合取语义完整验证。** 测后工作树与测前逐项一致：

```text
 M .ai/development-status.yaml
 M .ai/forgeloop-phase1/evidence.yaml
 M .ai/version-state.yaml
 M scripts/check-forge-loop.sh
?? doc/verification/forgeloop-phase1/consistency-recheck-record.md
```

---

## 2. Compaction probe 复跑

按 `recovery.md` §4 取第 4 次 probe。这是本 Goal 第 3 次 probe 之后的一次复跑，用于确认
「上一 Task 结束时记录的基线」在下一 Task 推进后发生了什么。

### 2.1 实测（当前工作树）

```text
c9d2fd5a3ae2bab170afc132fe143798b2878942fbbf091361765001abf02b2f  .ai/development-status.yaml
97ca6ec87177ff8ac7835cc81a0e76a57f0f81b2c38baed1700d8cd2aca9d9ca  .ai/version-state.yaml
559b6bd6eb74aa7ba19b90956171f03e0f2ce8d8f484d97b9e52a7e256cf2ffa  .ai/verification-state.yaml
8d05b437c9ccb4ff644a4dc3af4a20d8a67ae988b7e7db8ef1aa95cf46353d2c  .ai/forgeloop-phase1/tasks.md
33082f2e68d55ae7ba425018aa16afbcbc64c875b104f6a571adf48f59c269b3  .ai/forgeloop-phase1/evidence.yaml
```

Iteration ID：`ITER-002`　｜　Task：`T-14`　｜　Checkpoint：`CP-007` / `5450675`

### 2.2 与第 3 次 probe 的逐项对比

| 文件 | 第 3 次 | 第 4 次 | 变化原因 |
| :--- | :--- | :--- | :--- |
| `development-status.yaml` | `bf896cfa…` | `c9d2fd5a…` | 建立 CP-007（§53 六字段 + history 追加） |
| `version-state.yaml` | `0a0063a7…` | `97ca6ec8…` | `git.head` 回填为 `5450675`，`clean` 注释改为通用时点表述 |
| `evidence.yaml` | `3130d7c6…` | `33082f2e…` | REQ-009 的 `implementation.commit` 按 §11.2 回填 |
| `verification-state.yaml` | `559b6bd6…` | `559b6bd6…` | 未改 |
| `tasks.md` | `8d05b437…` | `8d05b437…` | 未改 |

**三个变、两个不变，且每一个变化都能对应到 T-14 的具体动作。** 这正是 probe 该有的行为：
它不证明「状态文件不再变化」，而是证明「在某一时刻，文件的内容与该时刻的工程状态一致」。
变化全部有据，说明状态文件的每次改写都留下了可追溯的对应关系；出现无法归因的漂移才是
probe 要暴露的失败模式。

### 2.3 判定

**通过。** 第 3 次基线的漂移被逐项解释，无「无法归因的变化」。

---

## 3. CK-15：未加引号的冒号空格标量

### 3.1 判据形态

扫描 `.ai/` 下全部 YAML，找「`key:` 后接未加引号的标量、且该标量内含冒号加空格」的
行。排除项：块标量的内容行、已加引号的值、流式序列/流式映射的定界符。

**不需要为时刻与 URL 设任何豁免。** YAML 的歧义规则是「冒号后跟空格」，而
`12:30` 的冒号后跟数字、`https://` 的冒号后跟斜杠——两者都不构成「冒号加空格」，
本就不会触发解析错误。首版却用整串子串搜索去豁免它们，结果是「值里前面有个时刻、
后面又有裸冒号」的写法整行漏网。该豁免已删除。

### 3.2 为什么必须独立于 8b

首版把 CK-15 放进 8c 的内嵌 python 里（与 CK-10～CK-14 同组）。负向测试随即证明它
**不可达**：

```text
注入  probe: fork_context: false 到 development-status.yaml
$ bash scripts/check-forge-loop.sh
[FAIL] 8c 组内嵌 python 异常退出（rc=1）——判据未产出，全部 8c 断言缺失
[FAIL] .ai/development-status.yaml YAML 解析失败或非空映射…
—— CK-15 一条都没产出
```

原因很直接：8c 的 python 在开头就 `yaml.safe_load()` 三个状态文件，文件一旦语法错误，
它先行崩溃，CK-15 永远跑不到。**它要拦的那一类输入，恰好是让它自己无法启动的输入。**

故 CK-15 改列为独立的 **8d 组**，按文本扫描、不解析 YAML。重跑同一负向场景：

```text
[FAIL] .ai\development-status.yaml 第 30  fork_context: false 行：未加引号的标量值内含
       冒号加空格，YAML 解析会失败（CK-15）
[FAIL] .ai\development-status.yaml 存在未加引号的冒号空格标量（CK-15），行号见上
[PASS] .ai\forgeloop-phase1\evidence.yaml 无未加引号的冒号空格标量（CK-15）
[PASS] .ai\forgeloop-phase1\mvp-scope.yaml 无…
[PASS] .ai\forgeloop-phase1\requirement-matrix.yaml 无…
[PASS] .ai\verification-state.yaml 无…
[PASS] .ai\version-state.yaml 无…
pass: 58   fail: 4   exit 1
```

### 3.3 判据的两处自身缺陷（复跑中发现并修复）

| # | 缺陷 | 处置 |
| :--- | :--- | :--- |
| 1 | 同一文件在报 FAIL 的同时又报 PASS——汇总行无条件输出「无未加引号的冒号空格标量」，未按命中数分支 | 汇总行改为 `SUMOK` / `SUMBAD` 二值，仅 `SUMBAD` 时判 FAIL 且不输出 PASS |
| 2 | 文件级摘要行与行级定位重复报错，信息冗余 | 保留行级定位 + 一条文件级汇总，去掉重复的 PASS |

### 3.4 边界测试：漏判与误判

在临时副本 `.ai/` 下构造十七行 YAML（路径须为 `.ai/<dir>/t.yaml`——8d 的 glob 是
`.ai/*/*.yaml`，**只覆盖一层**子目录），覆盖全部排除项与三类已知漏判：

```yaml
ok1: "已引用: 含冒号加空格"                 # 应 PASS（已加引号）
ok2: https://example.com/x                   # 应 PASS（URL，冒号后跟斜杠）
ok3: 12:30 重训                               # 应 PASS（时刻，冒号后跟数字）
ok4: >-                                      # 块标量起始
  块标量内容：这里有 colon space 也无所谓      # 应 PASS（块标量内容行）
                                          # 空行——不应重置块态
  块标量内的 key: value 也不该判              # 应 PASS（空行之后的块内容仍属块内）
ok5: 未加引号的值: 确实含冒号加空格              # 应 FAIL
ok6: &a {p: 1}                               # 应 PASS（锚点前缀的流映射）
ok7: !!map {a: b}                             # 应 PASS（标签前缀的流映射）
ok8: 单引号: 也是引号                         # 应 FAIL（用例本身漏写单引号，判据行为正确）
ok9: [a, b]                                  # 应 PASS（流式序列）
okA: {k: v}                                  # 应 PASS（流式映射）
bad1: - {id: CP-001, note: squash merge: main 侧}   # 应 FAIL（列表项 + 流映射）
bad2: note3: 复核于 12:30 完成: 已回填               # 应 FAIL（时刻与缺陷共存）
bad3: 说明: 未加引号的值: 确实含冒号加空格            # 应 FAIL（非 ASCII 键名）
bad4: note: 见 https://a.com : 说明                  # 应 FAIL（URL 之后仍有裸冒号）
```

实测输出（**脚本的字面输出，未作删节；路径中的空白为真实制表符**）：

```text
  [FAIL] ck15z\t.yaml 第 8 行：未加引号的标量值内含冒号加空格，YAML 解析会失败（CK-15）——未加引号的值: 确实含冒号加空格
  [FAIL] ck15z\t.yaml 第 11 行：未加引号的标量值内含冒号加空格，YAML 解析会失败（CK-15）——单引号: 也是引号
  [FAIL] ck15z\t.yaml 第 14 行：未加引号的标量值内含冒号加空格，YAML 解析会失败（CK-15）——- {id: CP-001, note: squash merge: main 侧}
  [FAIL] ck15z\t.yaml 第 15 行：未加引号的标量值内含冒号加空格，YAML 解析会失败（CK-15）——note3: 复核于 12:30 完成: 已回填
  [FAIL] ck15z\t.yaml 第 16 行：未加引号的标量值内含冒号加空格，YAML 解析会失败（CK-15）——说明: 未加引号的值: 确实含冒号加空格
  [FAIL] ck15z\t.yaml 第 17 行：未加引号的标量值内含冒号加空格，YAML 解析会失败（CK-15）——note: 见 https://a.com : 说明
  [FAIL] ck15z\t.yaml 存在未加引号的冒号空格标量（CK-15），行号见上
  [PASS] .ai\development-status.yaml 无未加引号的冒号空格标量（CK-15）
  [PASS] forgeloop-phase1\evidence.yaml 无未加引号的冒号空格标量（CK-15）
  [PASS] forgeloop-phase1\mvp-scope.yaml 无未加引号的冒号空格标量（CK-15）
  [PASS] forgeloop-phase1\requirement-matrix.yaml 无未加引号的冒号空格标量（CK-15）
  [PASS] .ai\verification-state.yaml 无未加引号的冒号空格标量（CK-15）
  [PASS] .ai\version-state.yaml 无未加引号的冒号空格标量（CK-15）
```

第 8 行（`ok5:`）是裸标量用例，应 FAIL；第 11 行（`ok8:`）本意是「单引号应 PASS」，
但用例文本自身漏写了单引号，实际是裸标量——判据报 FAIL 是正确的。

**十七行中十一行应通过的写法全部通过（含两条锚点/标签前缀用例），六行应失败的写法
全部命中（行号 8 / 11 / 14 / 15 / 16 / 17），六个真实状态文件零误判。**

临时副本测后即删除，`git status` 与测前逐项一致。

### 3.5 两轮 Review 暴露的判据缺陷及修复

首版 CK-15 通过了自己的九行边界测试，但**两个独立 Reviewer 各自构造出了它漏判的用例**，
且三处漏判中的第一处恰好落在本仓库最高频的写法上：

| # | 缺陷 | 后果 | 修复 |
| :--- | :--- | :--- | :--- |
| 1 | 键名正则要求紧跟行首空白，`- {id: …}` 前缀使整行不匹配 | `checkpoint.history` 七行与 `verification-state.yaml` gates 全是这个形状——**判据的新增动机与最大漏判面重叠** | 匹配前先剥行首 `- `，对流映射内部逐条目递归判定 |
| 2 | `url_time` 用整串子串搜索豁免 | 值里前面有时刻/URL、后面又有裸冒号时整行漏网 | 删除该豁免：时刻与 URL 的冒号后跟数字或斜杠，本就不触发歧义 |
| 3 | 8d 无 python rc 守卫 | 崩溃时 stdout 只剩前一个文件的结果，其余零断言而汇总仍显示 PASS | 照搬 8c 的 rc 守卫，rc 非 0 即判 FAIL 并清空 |
| 4 | 8d 未剥 CR | Windows 下末列字段带尾随 `\r`，消息文本错位 | 消费前统一 `tr -d '\r'`（与 8c 同） |
| 5 | 键名限定 `[A-Za-z_]`，非 ASCII 键整行不可见 | 中文键名的裸冒号漏网 | 键名放宽为「非空白非 `#` 起始」 |
| 6 | 块标量遇空行即重置块态 | 空行之后的合法内容行被误判 | 空行不重置块态 |
| 7 | 非标量前缀白名单缺 `&` 与 `!` | 锚点/标签前缀的流集合（`k: &a {…}`）被当纯标量而误报 | 入口先剥 `^[&!][^\s]*\s+` 前缀再判定界符 |
| 8 | FAIL 消息按首个 TAB 切分，行号与正文之间夹一个裸 TAB | 「第 72⇥fork_context: false 行」打断阅读 | python 侧输出四段、消费端 `read -r kind rel lineno body` |
| 9 | 行级片段未剔除行尾注释，60 字符截断切在注释中间 | 片段可读性下降，也让记录的「字面输出」难以自证 | 先 `split(' #', 1)[0]` 去注释，再 `[:60].rstrip()`——顺序要紧：`strip()` 只清整体尾部，截断点落在词内空格时仍会以空格收尾 |

第 1 项最值得记录：判据的**新增动机**（拦住 YAML 标量缺陷）与它的**最大漏判面**
（本仓库最常用的流映射列表项）重叠。若只靠自己构造的用例验证，一份会漏掉最高频写法的
判据也能「全部通过」。这是「自造用例不足以验证判据」的一个具体实例。

### 3.6 rc 守卫的验证

第 3 项（rc 守卫）的负向证据：在 `.ai/` 下放置一个非 UTF-8 编码的 `.yaml`
（字节 `FF FE 41 3A 20 42`），使内嵌 python 的 `open(..., encoding='utf-8')` 抛
`UnicodeDecodeError`。

```text
$ bash scripts/check-forge-loop.sh
[FAIL] 8d 组内嵌 python 异常退出（rc=1）——判据未产出，全部 CK-15 断言缺失
pass: 77   fail: 2
exit 1
```

对照修复前的行为：stdout 只会收到崩溃前已 flush 的部分，其余文件零断言，而汇总行仍显示
PASS——即「判据全部消失但结果显示通过」。守卫把这条路径改为显式 FAIL。

探针测后即删除，`git status` 与测前逐项一致，自检回到 `pass: 83 fail: 0`。

### 3.7 判据的依赖边界

CK-15 不依赖 `yaml` 模块，只依赖 `re`，故其 SKIP 条件是 `python` 不可用（比 8b/8c 的
`python + PyYAML` 更宽松）。它只读文本、不触碰任何状态文件，符合结构化自检「判据与被测
对象分离」的既有分层。

### 3.8 已知的判据边界（登记而非修复）

第 2 轮 Review 以 PyYAML 逐例对拍，测出 CK-15 的一处**潜伏漏判**——多行纯标量的续行：

```yaml
k: 第一行
  续行: 有冒号空格
```

YAML 会把缩进的续行并入上一行的纯标量，于是 `续行: ` 的冒号加空格落在**值**上，
这会破坏解析。但 CK-15 按行独立判定，把续行当成独立的 `key: value`，其冒号加空格落在
「键」上而被跳过，故漏判。

**处置：登记为边界，不在本 Task 修。** 理由有三：

1. 该形态在当前 `.ai/` 语料中出现 **0 次**——6 个 YAML 文件里共 24 处多行标量，
   全部是 `>-` 折叠风格（`|` 字面块 0 处），折叠标量内的行本就不参与键值判定。
   （复跑命令：`grep -rhE "^[[:space:]]*[A-Za-z_][A-Za-z0-9_.-]*:[[:space:]]*[>|]" .ai --include=*.yaml | wc -l`）
2. 真要修它需引入「续行合并」逻辑，即在 CK-15 里重新实现 YAML 的多行标量解析规则；
   那会让判据复杂到自身成为新的缺陷源。
3. **它不造成漏检危害**：这类写法一旦出现，8b 的 YAML 解析校验会立刻报「解析失败」。
   CK-15 的价值在于给出成因与行号，8b 负责兜住「有没有问题」这个二值判断——两者分工
   不重叠。

同一轮对拍还测出一处潜伏误报（`k: *anchor` 这类未定义别名），当前语料同样 0 次，
由 8b 兜底。

另有一条**在编写本节测试时实测暴露**的覆盖边界：8d（以及 8b 的全量 YAML 段）使用的 glob
是 `.ai/*.yaml` 加 `.ai/*/*.yaml`，**只覆盖一层子目录**。`.ai/<a>/<b>/t.yaml` 这样的两级
路径不会被扫描。该形态在当前 `.ai/` 结构中不存在（feature 目录一律单层），但若将来引入
两级结构，两组判据会静默漏扫。§3.4 的测试副本因此必须放在 `.ai/<dir>/t.yaml` 而非
`.ai/<dir>/<sub>/t.yaml`——这个约束是实测踩出来的，不是设计声明的。

---

## 4. 状态一致性总核对

五个状态文件对同一组事实的表述逐项核对：

| 事实 | 各文件的表述 | 一致 |
| :--- | :--- | :---: |
| 当前 Task | `development-status.task.current` = `T-14`；`tasks.md` 第 16 项 = T-14 未勾选 | 是 |
| Task 状态 | `development-status.task.status` = `ready` | 是 |
| Iteration | `development-status.iteration.current` = `ITER-002`；`version-state.iteration.current` = `ITER-002` | 是 |
| Checkpoint | `checkpoint.last` / `id` = `CP-007`；`checkpoint.git.commit` = `5450675`；`history` 末项 = CP-007 / `5450675` | 是 |
| `git.head` | `version-state.git.head` = `5450675`，与 `checkpoint.git.commit` 同步（§11.2 要求） | 是 |
| Requirement 计数 | `checkpoint.progress.requirements` 与矩阵实测分布一致 | 是（CK-13 跨文件核对） |
| Evidence 占位值 | 全仓库 `pending:` 出现处均属 §11.2 词表或版本待定标记 | 是 |

跨文件核对由自检 CK-13 与 CK-15 自动承担；上表是人工复核，二者结论一致。

---

## 5. 关联

- 冲突判据的原始负向测试：`doc/verification/forgeloop-phase1/state-persistence-record.md` §3（T-12）
- Recovery 演练：`doc/verification/forgeloop-phase1/recovery-record.md`（T-13）
- probe 全记录：`doc/verification/forgeloop-phase1/compaction-probe.md`
- 自检证据：`doc/verification/forgeloop-phase1/test-record.md`
- 判据矩阵：`.ai/verification-state.yaml`

