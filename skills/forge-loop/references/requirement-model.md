# requirement-model

Requirement 的提取、标识、验收标准与状态模型。

依据：`DESIGN.md` §17–§21（Document Discovery / Requirement Extraction / Requirement ID /
Acceptance Criteria / Document Review）、§58（Requirement State Machine）、§59（Evidence Invalidation）。

---

## 1. Document Discovery（§17）

读取当前项目已有资料，建立来源索引。被开发项目自身的文档路径由该项目决定，与 ForgeLoop 管理的目录无关。

产出：`<runtime>/<feature>/source-index.md`，每条来源给一个稳定编号 `SRC-001`、`SRC-002`……，
供 Requirement 的 `source` 字段引用，使「需求来自哪份文档哪一节」可回查（§39 Evidence 的 `source`
字段即引用这些编号）。

## 2. Requirement Extraction（§18）

产出 `<runtime>/<feature>/requirement-matrix.yaml`，每个 Requirement：

```yaml
REQ-001:
  title: Document Upload
  source:
    - SRC-001
  priority: required          # required | optional | deferred（§15）
  acceptance:
    - AC-001
    - AC-002
  status: pending            # §58 Requirement State Machine
```

## 3. Requirement ID（§19）

Requirement ID 永久稳定，格式 `REQ-001`、`REQ-002`、`REQ-003`。一旦进入正式 SPEC，不因文字修改而
重新编号——Git、Task、Test、Audit 都稳定引用它。

**命名空间隔离**：`I-001`…`I-010` 是 §108 Core Invariants 的十条不变量编号，与 Requirement ID 分属两套
命名空间，不可互换。Requirement 一律用 `REQ-xxx`。

## 4. Acceptance Criteria（§20）

每个 Requirement 至少一个 Acceptance Criterion：

```yaml
REQ-001:
  acceptance:
    AC-001:
      description: Correct file uploads successfully
    AC-002:
      description: Invalid file type is rejected
```

Acceptance Criterion 是 Requirement 与 Verification 之间的桥梁（§38 的 Requirement Verification Gate
逐条核对 AC）。AC 编号随所属 Requirement，形如 `AC-001`。

## 5. Document Review（§21）

需求从来源文档提取后、进入 SPEC 前，进行 Document Review：由 `document-reviewer` 审一致性、遗漏、
风险与歧义。这是 Requirement Review Phase 的执行体（§107 的 `REQUIREMENT_REVIEW`）。

## 6. Requirement State Machine（§58）

```text
PENDING → PLANNED → IMPLEMENTING → IMPLEMENTED → TESTING → REVIEWING → VERIFIED
                                                                    ↓
                                                                  BLOCKED（失败）
```

Requirement 或 SPEC 发生语义变化时（§59）：

```text
VERIFIED → STALE → RE-VERIFY（重新走 Plan Impact → Task → Test → Review → Verify）
```

`VERIFIED` 不是终态终点：一旦其依据的语义改变，既有 evidence 立即失效，必须重新验证
（Core Invariant I-006）。