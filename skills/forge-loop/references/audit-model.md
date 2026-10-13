# audit-model

Final Audit（L）与 Audit Repair Loop（M）的判据。承载 `DESIGN.md` §109 的 L / M 两项能力。

依据：`DESIGN.md` §66–§69（Final Audit / Matrix / Failure / Repair）、§96（Failure Loop）、§97（BLOCKED）、§109（L/M/N 能力定义）。

---

## 1. Final Audit 触发条件（§66）

进入 `FINAL_AUDIT` 态时，重读 Source Documents，对照六个对象：

```text
Requirement Matrix / SPEC / Plan / Implementation / Tests / Git History
```

判据：任一对照对象缺失或无法定位 → Audit 判 FAIL，回 `ITERATIVE_DEVELOPMENT`（§69）。

## 2. Final Audit Matrix（§67）

Matrix 九列，逐 Required Requirement 填一行：

```text
| Req | Source | SPEC | Task | Code | Test | Review | Runtime | Status |
```

八列 ✅ + `Status: VERIFIED` 齐备 → 该行通过。任一列缺 ✅ → 该 Requirement 未 verified（I-008：有未验证的 Required Requirement 时 Goal 不能 complete）。

## 3. Final Document Audit 四维（§68）

沿 `Source ↔ Requirement ↔ SPEC ↔ Implementation` 链条核对四维：

```text
Coverage      每个 Source 条目被 Requirement 覆盖
Consistency   Requirement ↔ SPEC ↔ Implementation 语义一致
Completeness  无悬空引用（SPEC 的 Requirement 在 Matrix 有行）
Behavior      行为性 AC 在 Runtime 列有执行证据
```

四维任一维度失败 → Audit 判 FAIL，失败处置见 §69。

## 4. Audit Failure 处置（§69）

失败条目登记为 `Missing: <Requirement> <缺失项>`，创建 Remediation Task（Task ID 续号），进入 `ITERATIVE_DEVELOPMENT` 的 Failure Loop（§96 第四类：Final Audit Failure → Remediation Task → Iteration）。

## 5. Audit 产物落盘

| 产物 | 路径 | 承载 |
| :--- | :--- | :--- |
| Final Audit 记录 | `doc/audits/phase2/final-audit.md` | §66 触发记录 + §67 Matrix + §68 四维结论 |
| 逐行矩阵 | `doc/audits/phase2/final-audit-matrix.md` | §67 九列全量 |
| SPEC 审核记录 | `doc/audits/phase2/spec-review.md` | §25 SPEC Review PASS 取证 |

落盘后 `audit-state.yaml` 的 `final_document_audit.status` 由 `pending` 改 `passed`。

## 6. L 的负向判据

```text
Matrix 行集合 = required Requirement 集合（漏行 → FAIL）
Status 列含非 VERIFIED → FAIL
§68 四维任一维度无结论 → FAIL
```

## 7. Audit Repair Loop（M，§96 四类失败路径）

所有失败统一收敛到单一工作单元 `Task`：

```text
Test Failure          → Fix Task       → Iteration
Review Failure        → Fix Task       → Iteration
Requirement Failure   → Fix Task       → Iteration
Final Audit Failure   → Remediation Task → Iteration
```

四类各自映射：前三类回 `ITERATIVE_DEVELOPMENT` 按 §64 的 FAIL 分支 `Fix → Re-test → Re-review` 走；第四类（Audit Failure）创建 Remediation Task 后按 §69 处置。

## 8. BLOCKED 判据（§97）与修复路径互斥

出现以下情形进 `BLOCKED`（终态），停止自动推进：

```text
外部服务不可用 / 缺少凭证 / 无法访问依赖 / 需求矛盾 / 平台权限不足
```

互斥判据：BLOCKED 只由 §97 的五类外部不可控情形触发；§96 的四类失败路径各自有明确的
Fix / Remediation Task 出口，**不属于** BLOCKED。判 FAIL 先查 §97 五类是否命中，命中进
BLOCKED；未命中走对应 Fix / Remediation Task，两条路径不交叉。
