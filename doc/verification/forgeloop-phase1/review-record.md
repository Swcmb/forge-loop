# T-10b Code Review Gate 证据（六维逐条）

对应判据：**V-04**（Review 有真实执行证据，逐条对应 DESIGN.md §37 六维，含 Scope）
执行者：`code-reviewer` 子代理（安装于 `D:\ai-configs\agents\code-reviewer.md`，ADR-006）
日期：2026-10-09
结论：**passed** —— 5 轮审（EXEC-1 三轮 + EXEC-2 两轮），全部无阻断项

---

## 0. 执行体可解析性（V-04 前置）

| 项 | 结果 |
| :--- | :--- |
| `code-reviewer` 按名解析 | 成功（出现在本会话 agent 列表） |
| 自检第 4 组 | `[PASS] code-reviewer 已安装` |
| 解析失败处置 | 未触发（`iterative-integration.md` CK-05：按名解析落空即 `BLOCKED`） |

## 1. 六维逐条结论（DESIGN.md §37）

审查对象：`scripts/check-forge-loop.sh` 的 CK-07/08/09 与 8b 新增块。

| 维度 | 结论 | 关键证据 |
| :--- | :--- | :--- |
| **Correctness** | 通过 | 逻辑主干经独立复现验证：正向 52/52 exit 0；负向 10 个 exit-1 场景各失败且复原（T-09 两项 + EXEC-1 四项 + EXEC-2 四类，其中 EXEC-2「仅注释/裸标量/列表」按 1 类 3 变体计；另有 1 个 CRLF 容忍场景期望 exit 0）。审查方在隔离副本构造对抗场景（空仓库 / 双空 / 同数量异名 / 双向多文件 / 全 CRLF / CRLF+真实漂移 / 目标缺失 / 正文孤立 CR / 无尾换行）逐条复现 |
| **Architecture** | 通过 | 新增块与既有 8 组结构一致；`DEPLOY_TARGET` 复用既有 `$LIBRARY` 常量；比较对象与 ADR-003 §1/§4 一致；符号链接 `~/.claude/skills/forge-loop` 已在注释中显式排除 |
| **Security** | 通过 | 无 `eval` / 反引号拼接 / 网络调用 / 凭据处理；路径由既有常量派生，脚本内已无用户名字面量；YAML 用 `safe_load` 不构造任意对象；路径经 `sys.argv[1]` 传入而非拼进 `-c` 代码串 |
| **Regression** | 通过 | 既有 1～7 组语义逐组复跑未变；已消除对库仓库 `core.autocrlf=true` 的硬耦合（改去 CR 归一内容摘要） |
| **Maintainability** | 通过 | 注释引用的 ADR-003/§3.5/ADR-004/§55 节号经核对；PASS 文案与实际覆盖边界（`.md`、仅章节骨架不校验正文）一致 |
| **Scope** | 通过 | 每个 Task 改动限于 `scripts/check-forge-loop.sh` + `.ai/` 状态文件；提交分离（脚本与状态文件各自独立 commit）；无无关重构 |

## 2. Finding 闭环明细

### 2.1 EXEC-1（7 条：3 Important + 3 Important→Minor/Minor + 1 Minor）

| # | 严重度 | 问题 | 修法 | 状态 |
| :--- | :--- | :--- | :--- | :--- |
| F1 | Important | 裸 sha256 比对遇库仓库 `autocrlf=true` 会全量误报漂移 | 去 CR 归一后取内容摘要 | closed |
| F2 | Important | `DEPLOY_DIR` 硬编码用户名绝对路径，无环境覆盖，其他机器恒 FAIL | 改用 `$LIBRARY/forge-loop` | closed |
| F3 | Important | 标题/注释误述比较对象（`.claude` 路径实为指向库的符号链接） | 标题改为「仓库源码 vs 库部署目标（ADR-003）」 | closed |
| F4 | Important→Minor | 空数组 / count 不等时输出内容为假的 PASS | 最终 ok 行三重守卫 + 数量不等分支递增 `set_mismatch` | closed |
| F5 | Minor | 文件集合比较用词拼接相等，对含空格文件名有损 | 先比元素个数再逐元素比 | closed |
| F6 | Minor | PASS 文案「逐文件 sha256 全部一致」超范围（仅 `.md`） | 文案限定 `.md` 并写明边界 | closed |
| F7 | Minor | group 7 注释未声明检查深度 | 补「仅校验章节骨架标题存在，不校验正文非空」 | closed |

### 2.2 EXEC-2（8 条：3 Important + 5 Minor，其中 2 条 Minor 留档）

| # | 严重度 | 问题 | 修法 | 状态 |
| :--- | :--- | :--- | :--- | :--- |
| I1 | Important | 空文件 `safe_load` 返回 `None` 判 PASS，恢复链读到 None | `isinstance(d,dict) and d` 非空映射断言 | closed |
| I2 | Important | 文件缺失与语法错误共用一条 FAIL 文案，把排查引向缩进 | 循环体前置 `[ -f ]`，缺失与解析两条独立消息 | closed |
| I3 | Important | `check_keys` 只验顶层段，§55 注释承诺的叶子字段未校验 | 新增 `check_leaf` 二级断言（`iteration.current` / `git.branch·head·clean`） | closed |
| m1 | Minor | `check_keys` 成功路径返回 1，`set -e` 落雷点 | 显式 `return 0` | closed |
| m2 | Minor | PyYAML 缺失降级不计数，证据条数随环境漂移 | `skip` 计数器入汇总行 | closed |
| m3 | Minor | `evidence.yaml` 路径硬编码 feature 段 | `nullglob` 通配枚举 `.ai/*/evidence.yaml` | closed |
| m4 | Minor | `check_leaf` 按缩进而非父段作用域定位 | 留档后续收紧；放错父段时恢复链同样暴露 | 留档 |
| m5 | Minor | feature 目录缺 `evidence.yaml` 时不判 FAIL | 留档后续收紧；8b 已拦住更大类问题 | 留档 |

### 2.3 过程说明（双方结论交叉确认）

**F1 的判据选择**经双方独立实测交叉确认：审查方首轮用 `sed 's/$/\r/'` 在已是 CRLF 的文件上构造
探针，导致 CR 计数未变却未察觉，第二轮用 `awk` 从 index blob 重建纯 LF/CRLF 变体后复现了作者的数据。
最终双方一致认定 `git hash-object` 在该库仓库中对已跟踪 / 未跟踪文件的归一化行为不可靠，采用去 CR
归一内容摘要。

## 3. 门禁判定

| 项 | 结果 |
| :--- | :--- |
| 阻断项 | 无 |
| 未修阻断 Finding | 0 |
| Finding 全部闭环 | 是（含 2 条 Minor 明确留档，附不修理由） |
| 复审轮次 | EXEC-1 ×3、EXEC-2 ×2 |
| 每轮 Finding | 均重新构造对抗场景，不依赖修复摘要 |

## 4. 关联

- 结构化证据：`.ai/forgeloop-phase1/evidence.yaml`（`review` 字段）
- Test Gate 记录：`doc/verification/forgeloop-phase1/test-record.md`
- 演练 Review：`doc/reviews/forgeloop-phase1/iteration-review.md`