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