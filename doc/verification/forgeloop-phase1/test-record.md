# T-10b Test Gate 证据

对应判据：**V-03**（Test 有真实执行证据：**T-09 负向测试 + T-11 正向运行，缺一不算通过**）
测试命令：`bash scripts/check-forge-loop.sh`
判据来源：详细设计 §3.6.1（第一阶段产物为 markdown，无编译/单测框架，结构化自检承担 Test Gate 主体）
日期：2026-10-09
结论：**passed**

---

## 1. 正向运行（T-11 执行）

```text
$ bash scripts/check-forge-loop.sh
pass: 52   fail: 0   skip: 0
RESULT: PASS
exit 0
```

52 项检查分 9 组：references 清单（11）/ SKILL.md frontmatter（5）/ reference 交叉引用（1）/
下层 Agent（3）/ 上游来源指纹（2）/ 部署目标一致性（2）/ §105 职责锚点（5）/ `.ai/` 状态骨架段与
叶子字段（19）/ 状态文件 YAML 可解析性（4）。

## 2. 负向证据（注入故障 → 非零退出）

「结构化自检」的有效性判据是**必须以非零退出码失败**。以下场景全部实测 exit 1 并复原。

### 2.1 T-09 阶段负向（前序）

| 场景 | 结果 |
| :--- | :--- |
| 删除 `references/recovery.md` | exit 1 |
| 注入 `nonexistent-ref.md` 悬空引用 | exit 1 |

### 2.2 EXEC-1 阶段负向

| 场景 | 结果 |
| :--- | :--- |
| 库部署目标内容漂移（`references/recovery.md` 追加一行） | exit 1，报「库部署目标漂移」 |
| 库部署目标缺文件（移走 `references/goal-mode.md`） | exit 1，报数量不一致 + 缺少文件 |
| 库部署目标多文件（新增 `references/extra.md`） | exit 1，报数量不一致 |
| 删除 SKILL.md `## 5. Output Contract` | exit 1，CK-07 漂移 + CK-08 缺章节双捕获 |
| 库部署目标全 CRLF（63 CR 字节） | **exit 0** —— EOL 差异被归一化吸收（正向容忍验证） |

### 2.3 EXEC-2 阶段负向

| 场景 | 结果 |
| :--- | :--- |
| 空文件（`verification-state.yaml` 清零，`safe_load`→`None`） | exit 1 |
| 仅注释 / 裸标量 / YAML 列表 | exit 1 |
| 文件缺失（移走 `verification-state.yaml`） | exit 1，报「缺失（恢复链将无法读取）」 |
| 叶子字段缺失（删 `git.head` / `git.clean`） | exit 1，各报一条 |

## 3. 证据形态说明（DI-08）

第一阶段产物为 markdown（SKILL.md + 10 references + 3 agents），仓库无构建/测试/lint 工具链。
按详细设计 §3.6.1：

| Gate 项 | 取值 | 说明 |
| :--- | :--- | :--- |
| Lint / Unit / Integration / E2E / Build | **N/A** | 仓库无工具链；文件级验证（File Exists + Content Complete + Correct Path + Correct Owner）由结构化自检承担 |
| Test | **结构化自检** | 正负双向证据缺一不算通过 |
| Runtime | **N/A（显式）** | 无可运行产物；Evidence `runtime` 字段写 `N/A: phase-1 artifact is markdown, no runtime surface` |

## 4. 降级可观测性

`python`/`PyYAML` 不可用时，8b 降级跳过并计入 `skip`，汇总行显示 `skip: N`。实测 PATH 剥离
python → `[SKIP]` + `skip:1`，使 Test Gate 证据条数不随环境漂移而失去可解释性。

## 5. 关联

- 结构化证据：`.ai/forgeloop-phase1/evidence.yaml`（`tests` 字段）
- Review 记录：`doc/verification/forgeloop-phase1/review-record.md`
- Verify 记录：`doc/verification/forgeloop-phase1/verify-record.md`

---

## 6. 增补：CK-10 / CK-11 / CK-12 / CK-13 / CK-14（自检 8c 组，T-12 追加）

T-12 第 1 轮 Review 判 Important——初稿称 §53 六字段「经自检 CK-09 校验存在性」，复验不成立：
CK-09 的骨架键检查只断言顶层段，断言不到叶子字段，且 `progress.requirements` 键当时在状态
文件中根本不存在。本 Task 的处置是补齐字段 + 扩断言，故新增自检 8c 组。

第 2 轮 Review 追加两项判据并要求一处更正：

- **DI-09**：§53 原字段名是 `task.id` / `git.commit` / `spec.version`，初稿落地为
  `task.current` 与标量 `git_commit`、`spec.version` 挂在 `version-state.yaml` 顶层。
  按 `AGENTS.md` §5（Design 是唯一权威，先修正引用方）改回 §53 原字段名与原层级。
- **CK-12**：8c 起初只校验 `history` 的形状，不校验锚点真实可达——把 CP-001 的悬空 hash
  `823615b` 写回去仍会 63/63 全绿。故对每个非占位值锚点实测
  `git merge-base --is-ancestor <hash> <集成分支>`；占位值按 `rules/git-integration.md`
  §11.2 词表豁免并显式 PASS 留痕。
- **静默失效守卫**：内嵌 python 抛异常时 stdout 为空、heredoc 仍 exit 0，断言会静默消失
  且不计 `skip`。守卫改为按 python 的**退出码**判定（`rc ≠ 0` 即判 FAIL 并清空输出）。

  守卫的首版实现用「输出行数下界」判定，第 3 轮 Review 判 Important——行数会随状态文件
  的真实缺陷自然减少，于是**数据缺陷被误报为「判据静默失效」，且 `ck8c=""` 把真实诊断
  一并吞掉**（N2/N3 的报错信息因此不可达，读者只看到「实得 13 行，期望 ≥19」）。
  现版按退出码区分两种成因：python 崩溃 → 拦截并清空；python 正常退出但数据有缺陷 →
  原样消费那些 FAIL 行，诊断得以保留。N2/N3 在现版下重新实测通过（见 §6.2）。

### 6.1 正向

```text
$ bash scripts/check-forge-loop.sh
pass: 76   fail: 0   skip: 0
RESULT: PASS
exit 0
```

8c 组 **22 条**断言逐条通过，按判据分组：

| 判据 | 条数 | 内容 |
| :--- | :--- | :--- |
| CK-10 | 9 | §53 字段存在且非空：`id` / `goal.id` / `iteration.id` / `task.id` / `git.commit` / `spec.version` / `progress.requirements.total` / `.verified` / `history` |
| CK-11 | 2 | `history` 为非空列表；每项含 `id` 与 `git_commit` |
| CK-12 | 6 | 5 个锚点实测 `git merge-base --is-ancestor` + 1 个 §11.2 占位值豁免（CP-006） |
| CK-13 | 4 | `checkpoint.progress.requirements` 的 `total` / `verified` / `reviewing` / `pending` 与 requirement-matrix 实际分布一致 |
| CK-14 | 1 | `version-state.git.head` 在集成分支上可达（§98 Resume 定位前提） |

### 6.2 负向（证明新断言有鉴别力，而非恒真检查）

| 场景 | 结果 |
| :--- | :--- |
| N1 删 `checkpoint.progress.requirements` 整段 | exit 1，共 **6 条** FAIL：CK-10 的 `total` / `verified` 两条 + CK-13 的 4 条计数核对（`pass: 70  fail: 6`） |
| N2 `checkpoint.history` 写成标量 `none`（守卫修复后复测） | exit 1，保留精确诊断「history 是非空列表（§54 逐 CP 配对锚点）」 |
| N3 `history` 首项缺 `git_commit`（守卫修复后复测） | exit 1，保留精确诊断「每项须同时含 id 与 git_commit（缺失项：0）」 |
| N4 删 `checkpoint.goal` 整段 | exit 1，报「checkpoint.goal.id 存在且非空」 |
| N5 把 CP-001 的悬空 hash `823615b` 写回 `history` | exit 1，报「锚点 823615b 不在 main 历史——§54 的 Rollback/Resume/Progress Tracking 对该项失效」 |
| N6 `history` 项写入 `TBD-later`（既非占位值也非 hex） | exit 1，报「既非 §11.2 占位值也非 hex hash」 |
| N7 把 `checkpoint.task.id` 退回 `task.current`（违反 DI-09 更正） | exit 1，报「checkpoint.task.id 存在且非空（§53）」 |
| N8 内嵌 python 抛异常（`sys.exit(3)`，stdout 为空） | exit 1，报「8c 组内嵌 python 异常退出（rc=3）——判据未产出，全部 8c 断言缺失」 |
| N10 `FORGELOOP_INTEGRATION_BRANCH=no-such-branch`（集成分支拼错） | exit 1，**只报 1 条**「集成分支 no-such-branch 不存在——跳过 §54 锚点可达性校验（环境配置错误，非状态文件缺陷）」，锚点误报数为 0 |
| N11 把 `version-state.git.head` 设为 V-07 记录的悬空 hash `44d9e4f` | exit 1，报「version-state.git.head 44d9e4f 不在 main 历史——§98 恢复链据此定位到的位置是错的」（`pass: 75  fail: 1`） |
| 复原后正向 | exit 0，76/76 PASS |

N5/N6/N7 由 Python 改写 `.ai/development-status.yaml` 后运行同一命令产生；N8 由 Python 改写
脚本内嵌代码后复原脚本产生。全部场景结束后文件已复原，并以三条独立判据复核：

```text
bash scripts/check-forge-loop.sh          → pass: 76   fail: 0   RESULT: PASS   exit 0
grep -c "if false; then" 脚本              → 0
grep -c "TBD-later" .ai/development-status.yaml → 0
```

8c 组沿用 8b 的降级约定：`python`/`PyYAML` 不可用时输出 `[SKIP]` 并计入 `skip`，不判 FAIL。

### 6.3 CK-13 与 8b 全量 YAML 校验：两个 Phase 1 输入工件此前根本不是合法 YAML

落地 CK-13（`checkpoint.progress.requirements` 计数须与 `requirement-matrix.yaml` 的
status 实际分布一致）时，内嵌 python 首次尝试加载 `requirement-matrix.yaml`，立刻报出
解析错误。顺着这条线排查，发现两个此前**从未被任何判据解析过**的文件存在 YAML 语法错误：

```text
$ python -c "import yaml; yaml.safe_load(open('.ai/forgeloop-phase1/mvp-scope.yaml',encoding='utf-8'))"
yaml.scanner.ScannerError: mapping values are not allowed here
  in ".ai/forgeloop-phase1/mvp-scope.yaml", line 6, column 19
    version: pending: B-03              # 版本服从全局 Version Management，不自定

$ python -c "import yaml; yaml.safe_load(open('.ai/forgeloop-phase1/requirement-matrix.yaml',encoding='utf-8'))"
yaml.scanner.ScannerError: mapping values are not allowed here
  in ".ai/forgeloop-phase1/requirement-matrix.yaml", line 80, column 43
    description: Evidence 八字段完整 → status: verified
```

两行均为 `git show HEAD:<file>` 取出的**修复前原文**（逐字，含原注释）。修复后实测：

```text
$ python -c "import yaml; print(len(yaml.safe_load(open('.ai/forgeloop-phase1/mvp-scope.yaml',encoding='utf-8'))))"
1
$ python -c "import yaml; print(len(yaml.safe_load(open('.ai/forgeloop-phase1/requirement-matrix.yaml',encoding='utf-8'))))"
9
```

**为什么长期未被发现**：自检 8b 只枚举三个固定状态文件加 `.ai/*/evidence.yaml`，
`mvp-scope.yaml` 与 `requirement-matrix.yaml` 从不在解析范围内。而这两个文件恰好承载
§109 的 **B（Requirement Extraction）** 与 **C（MVP Scope）** 两项能力的核心产物——
V-11 / V-12 判据写着「产出 requirement-matrix.yaml」「产出 mvp-scope.yaml」，
产出物存在，但无法被任何 YAML 解析器读取。§98 Goal Resume 恢复链要读它们，
§66 Final Audit 要对照它们，两者都会静默失败。

这与 T-10b-EXEC-2 修过的 `version-state.yaml` 的 `pending: B-03` 是**同一类缺陷**：
含冒号的未加引号标量。当时只修了被 CK-09 加载的那一个文件，没有推广到其余同模式文件。

**处置**：

1. 两处加引号修正：`version: "pending: B-03"`、`description: "Evidence 八字段完整 → status: verified"`。
2. 自检 8b 扩展为枚举 `.ai/*.yaml` + `.ai/*/*.yaml` 全量解析（含去重），
   覆盖 `.ai/` 下每一个 YAML 文件。
3. 新增 CK-13 跨文件核对 `checkpoint.progress` 计数与 requirement-matrix 实际状态分布。

### 6.4 CK-13 / 8b 全量校验的正负向证据

正向：

```text
$ bash scripts/check-forge-loop.sh
pass: 76   fail: 0   skip: 0
RESULT: PASS
exit 0
```

8b 现覆盖 6 个文件（三个状态文件 + evidence.yaml + mvp-scope.yaml + requirement-matrix.yaml），
无重复计数。

负向：

| 场景 | 结果 |
| :--- | :--- |
| N9 把 `mvp-scope.yaml` 的 `"pending: B-03"` 退回未加引号的 `pending: B-03` | exit 1，报「mvp-scope.yaml YAML 解析失败或非空映射」 |
| CK-13 首跑时 `checkpoint.progress.requirements.verified` 声明 8 而实际 7 | exit 1，内嵌 python 的 `ScannerError`（`requirement-matrix.yaml` line 80）暴露了两个 Phase 1 输入工件的 YAML 语法错误 |
| 复原后正向 | exit 0，76/76 PASS |

去重逻辑本身经历一次返工：首版 `seen_rel` 在判重**之前**就把当前路径写入集合，
导致所有文件被 `continue` 跳过、8b 段落整体消失（`pass` 从 69 掉到 67 且无任何
FAIL 提示）；次版缺尾部哨兵空格，模式 `*" $rel "*` 恒不匹配，`evidence.yaml`
被重复校验。现版为 `seen_rel=" "` 起头、追加时带尾部空格，`pass: 76` 与 8b 的 6 行
一一对应。

去重逻辑的两处返工都属于「判据失效但汇总仍显示 PASS」这一类：第一次让 8b 整段消失、
第二次让同一文件重复计数。二者都由最终汇总行与 8b 行数的一一对应关系暴露——
`pass` 数与各段行数对不上时，判据本身已经不可信。

### 6.5 诊断分层：崩溃 / 数据缺陷 / 环境配置错误三种成因互不掩盖

第 3 轮 Review 的 Important 2 与 4 同源——守卫把不同成因压成同一条消息。现版按成因分层：

| 成因 | 判定依据 | 处置 |
| :--- | :--- | :--- |
| python 崩溃（判据未产出） | `ck8c_py_rc -ne 0` | 拦截并清空输出，报「异常退出（rc=N）」 |
| 状态文件数据缺陷 | python `rc == 0` | 原样消费 FAIL 行，精确诊断得以保留 |
| 集成分支配置错误 | `git rev-parse --verify` 失败 | 报 1 条环境诊断并跳过锚点循环 |

N10 是第三种成因的判据。修复前 `2>/dev/null` 把「分支不存在（git exit 128）」与
「锚点不可达（git exit 1）」压成同一条消息，分支名写错时 6 条锚点会同时报不可达——
把环境配置错误伪装成状态文件缺陷。修复后实测：

```text
FORGELOOP_INTEGRATION_BRANCH=no-such-branch → pass: 70   fail: 1   （唯一 FAIL 是环境诊断）
FORGELOOP_INTEGRATION_BRANCH=main（默认）    → pass: 76   fail: 0   RESULT: PASS
```

被跳过的断言是 6 条：5 条 ANCHOR（CP-001..CP-005）+ 1 条 CK-14 的 `git.head`。
CP-006 是 §11.2 占位值，走 PASS 分支不依赖分支存在性，因此照常计入。

### 6.6 CK-14：`version-state.git.head` 的可达性

CK-09 的 `check_leaf` 只断言 `version-state.git.head` 这个**键存在**，不校验它的**值**——
这正是 V-07 记录的缺陷类型：`git.head` 曾被设为 PR #11 的分支头 `44d9e4f`，该 commit
不在集成分支历史，恢复链读者据此得出的「当前在哪」是错的，而当时全部判据仍然全绿。

第 4 轮 Review 在核对过程中发现该缺口。此前 8c 内嵌 python 里的 `vs` 变量是死变量，
`version-state.yaml` 虽作为 `argv[2]` 传入却从未被读取——这本身就是「这条判据根本不存在」
的直接证据。本轮补上 CK-14 并重新启用 `vs`。

负向证据见 §6.2 的 N11：把 `git.head` 改回 `44d9e4f` 后，脚本报
「version-state.git.head 44d9e4f 不在 main 历史——§98 恢复链据此定位到的位置是错的」，
`pass: 75  fail: 1  exit 1`。
