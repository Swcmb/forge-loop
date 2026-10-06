# State and Recovery Rules

## 1. Runtime Location

ForgeLoop：

```text
.ai/
```

External Project：

```text
.dev-ai/
```

---

## 2. Minimum State

必须能够恢复：

```text
Goal
Phase
Task
Iteration
Checkpoint
Blocker
Verification
```

---

## 3. Persistent State

以下信息不能只保存在对话：

```text
Current Goal
Current Phase
Current Task
Current Iteration
Verification
Checkpoint
Blocker
Resume Position
```

---

## 4. Recovery

恢复流程：

```text
Load State
↓
Inspect Current Task
↓
Inspect Workspace
↓
Inspect Git
↓
Inspect Checkpoint
↓
Reconcile
↓
Resume
```

---

## 5. Git/State Conflict

如果：

```text
Runtime State
```

和：

```text
Git State
```

不一致：

```text
STOP AUTO-PROGRESSION
```

先进行 Reconciliation。

例如：

```text
Runtime = Task Complete
Git = Uncommitted Changes
```

或：

```text
Runtime = Iteration 5
Git = Iteration 4 Checkpoint
```

必须先确认真实工程状态。

---

## 6. Partial Execution

发生中断时：

```text
Inspect Existing Changes
↓
Determine Completed Work
↓
Determine Remaining Work
↓
Determine Verification State
↓
Continue / Repair
```

不得无条件重复执行。

---

## 7. Failed Verification

任何验证失败：

```text
Task ≠ Complete
```

然后：

```text
Repair
↓
Test
↓
Review
↓
Verify
```

---

## 8. Blocked

无法安全继续时：

```text
Blocked
```

Blocker 至少记录：

```text
Cause
Impact
Required Action
Context
```

---

## 9. State Integrity

不得：

```text
伪造完成
跳过验证
静默删除状态
静默覆盖历史
```

状态必须能够解释当前工程为什么处于当前阶段。
