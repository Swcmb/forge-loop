# T-10b Requirement Verification Gate 证据

对应判据：**V-05**（Requirement Verification 有真实执行证据 —— Evidence 八字段 → `verified`）
Gate 定义：DESIGN.md §38 / §39
结构化证据：`.ai/forgeloop-phase1/evidence.yaml`
日期：2026-10-09
结论：**passed**

---

## 1. Gate 判据

Requirement Verification Gate 回答的问题是「用户要求是否真正实现」。判定规则：

```text
全部 AC passed + tests 有真实执行记录 + review 有真实执行记录
    → status: verified
任一 AC 未通过 或 无真实记录
    → 不置 verified → 回 Iteration Loop 修复（Fix → Test → Re-test → Re-review）
```

八字段（§39）：`source` / `spec` / `task` / `implementation` / `tests` / `review` / `runtime` /
`acceptance`。字段保留不省略；不适用项写显式 `N/A` + 理由，不留空。

## 2. Requirement 逐条判定

| REQ | 标题 | AC | status | 关键证据 |
| :--- | :--- | :--- | :--- | :--- |
| REQ-001 | Document Discovery | AC-001 | verified | `source-index.md` SRC-001..008，编号被 evidence 的 `source` 字段实际引用 |
| REQ-002 | Requirement Extraction | AC-002/003/004 | verified | `requirement-matrix.yaml` REQ-001..009；ID 与 I-xxx 命名空间分离；每 REQ 至少一 AC |
| REQ-003 | MVP Scope | AC-005/006 | verified | `mvp-scope.yaml` 三集合齐备 + §16 四问逐条作答 |
| REQ-004 | Single Task Iteration | AC-007/008 | verified | One-Task Rule（`git show --stat` 单文件）+ Goal Mode 暂停点失效（续行标记） |
| REQ-005 | Test | AC-009 | verified | 正向 52/52 + 负向 9 场景各 exit 1；Review 三轮 PASS |
| REQ-005-EXT | Test（CK-09 + 8b 扩充） | AC-009 | verified | 正向 52/52；I1/I1b/I2/I3 各 exit 1；Review 两轮 PASS |
| REQ-006 | Code Review | AC-010 | verified | `code-reviewer` 可解析；六维 Finding 含 Scope，逐条闭环 |
| REQ-007 | Requirement Verification | AC-011 | verified | 本文件即 Gate 证据本身（八字段齐备 → verified） |

未转正：REQ-008（Git Checkpoint）、REQ-009（Recovery）—— 分别归 T-12、T-13 判定。

## 3. Evidence 失效检查（§59 I-006）

Requirement 或 SPEC 语义变化时既有 Evidence 立即失效。本轮无 Requirement 语义变化
（仅新增检查项 CK-09/8b，不改变任何既有 AC 的语义），既有 Evidence 未失效。

EXC-2 期间修复的 `version-state.yaml` YAML 语法错误属**状态文件技术缺陷**，不构成 Requirement
语义变化——该 Requirement（REQ-008 Checkpoint 落盘）的 AC 判据未变。

## 4. 判据文件与一致性

- 结构化落盘唯一位置：`.ai/forgeloop-phase1/evidence.yaml`（详细设计 §3.7）
- 该文件通过自检 8b 的 YAML 非空映射校验（解析失败即 FAIL）

## 5. 关联

- 结构化证据：`.ai/forgeloop-phase1/evidence.yaml`
- Test 记录：`doc/verification/forgeloop-phase1/test-record.md`
- Review 记录：`doc/verification/forgeloop-phase1/review-record.md`