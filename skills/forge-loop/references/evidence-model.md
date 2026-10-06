# evidence-model

Evidence 的字段结构、`verified` 判定与失效规则。Requirement 只有在 Evidence 完整时才算完成。

依据：`DESIGN.md` §38（Requirement Verification Gate）、§39（Evidence）、§59（Evidence Invalidation）。

---

## 1. Evidence 八字段（§39）

每个 Requirement 在 `<runtime>/<feature>/evidence.yaml` 保存：

```yaml
REQ-017:
  source:
    - SRC-004
  spec:
    section: 4.3
    version: 0.6.0
  task:
    - TASK-042
  implementation:
    commit: a82c91f
  tests:
    - TEST-108
  review:
    status: passed
  runtime:
    status: passed
  acceptance:
    AC-017-1: passed
    AC-017-2: passed
    AC-017-3: passed
  status: verified
```

八字段：`source` / `spec` / `task` / `implementation` / `tests` / `review` / `runtime` / `acceptance`。
字段保留不省略；某项不适用时写显式 N/A 与理由（见 §4），**不留空**，避免空值被读成通过。

## 2. Requirement Verification Gate（§38）

Gate 回答的问题是「用户要求是否真正实现」。逐条核对该 Requirement 的每个 Acceptance Criterion
（§20）：AC 是否全部 `passed`，`tests` / `review` 是否有真实执行记录。

```text
全部 AC passed + tests 有记录 + review 有记录
    → status: verified
任一 AC 未通过 或 无真实记录
    → 不置 verified → 回 Iteration Loop 修复（Fix → Test → Re-test → Re-review）
```

Gate 判据来自本文件 + `requirement-model.md`；**上游 `iterative-development` 不提供 Gate 或 Evidence
定义**（它只在 Gate 之前做 lint/test 早期拦截）。

## 3. 三层 Gate 的分工（§36/§37/§38）

| Gate | 回答的问题 | 执行体 | 产出 |
| :--- | :--- | :--- | :--- |
| Test Gate（§36） | 代码运行是否正确 | 仓库测试/lint 工具链 | test 结果 |
| Code Review Gate（§37） | 实现质量是否合格 | `code-reviewer` agent | 六维 Finding（见 `architecture.md`） |
| Requirement Verification Gate（§38） | 用户要求是否真正实现 | 本文件判据 + AC 核对 | `status: verified` |

三者职责不重叠，顺序：Test → Code Review → Requirement Verify。

## 4. Runtime 字段的 N/A 规则

`runtime` 字段在无可运行产物的交付物中显式标 N/A：

```yaml
runtime:
  status: N/A
  reason: phase-1 artifact is markdown, no runtime surface
```

不留空、不省略该键。ForgeLoop 第一阶段产物为 markdown + Skill，无运行时表面，按 DI-08 处理。

## 5. Evidence Invalidation（§59）

Requirement 或 SPEC 发生**语义变化**时，既有 Evidence 立即失效：

```text
VERIFIED → STALE → RE-VERIFY
```

例如 REQ-017 从「支持 PDF」改为「支持 PDF + 加密 PDF」，原 `PDF PASS` 不再覆盖新语义，
须重新走 Plan Impact → Task → Test → Review → Verify（Core Invariant I-006）。

文字修改不构成语义变化，不触发失效；判定标准是「原验证结论是否仍覆盖新语义」。