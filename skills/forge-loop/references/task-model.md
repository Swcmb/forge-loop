# task-model

Task 的结构、状态机、取件策略与 One-Task Rule。本文件是 Task State 的**唯一权威 reference**。

依据：`DESIGN.md` §27（Requirement → Task Mapping）、§28（Task Structure）、§29（Task State）、
§30（Iterative Development）、§31（Task Selection Policy）、§32（One-Task Rule）。

---

## 1. 任务清单位置

`<runtime>/<feature>/tasks.md`，其中 `<runtime>` 按 Owner 解析：

| Owner | `<runtime>` |
| :--- | :--- |
| FORGELOOP（开发 ForgeLoop 自身） | `.ai/` |
| CURRENT_PROJECT（被开发项目） | `.dev-ai/` |

此布局兼容上游 `aspiers/iterative-development` 的 `.ai/[feature]/tasks.md` 约定；外部项目由
`iterative-integration.md` 的 Adapter 按 Owner 映射到 `.dev-ai/`。

## 2. Task 结构（§28）

```markdown
# <feature>

- [ ] 1. Implement Upload API

  Requirement: REQ-001
  Acceptance:
  - AC-001
  - AC-002
  Tests:
  - TEST-001
  State: pending

- [ ] 2. Add Upload Validation

  Requirement: REQ-001
  Acceptance:
  - AC-003
  Tests:
  - TEST-002
  State: pending
```

每个 Task 至少映射一个 Requirement 或一个明确的工程目标（Core Invariant I-003）。

## 3. Task State（§29，九态）

```text
pending → ready → implementing → implemented → testing → reviewing → verified → complete
                                                          ↓
                                                       blocked
```

- `pending`：已识别，未就绪（有未满足的前置依赖）
- `ready`：可取
- `implementing` / `implemented` / `testing` / `reviewing`：本轮推进中
- `verified`：通过三层 Gate，等待 Checkpoint
- `complete`：已形成 Checkpoint
- `blocked`：无法安全继续

Task State 归本文件定义。**上游 `iterative-development` 不提供状态机**，只维护清单勾选；二者不冲突。

## 4. Task Selection Policy（§31）

取件顺序：

```text
1. Blocker            解除阻塞
2. Required Requirement  覆盖 required 需求
3. Dependency prerequisite  前置依赖
4. High-risk Task     高风险优先
5. Small verifiable Task 小而可验证
```

## 5. One-Task Rule（§32）

每个 Goal Turn 的主目标是**一个** primary Task。允许同一轮内包含该 Task 的 Implementation、
Tests、必要文档更新、必要状态更新。**禁止**把无关功能塞进同一轮。

Task 原则：Small / Atomic / Verifiable / Traceable。

一个 Task 完成（含三层 Gate 通过 + Checkpoint）后才进入下一个 Task（见 `iterative-integration.md`
的 Mode 行为）。