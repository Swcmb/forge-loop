# ForgeLoop Git Integration Rules

## 1. Authority

ForgeLoop 的 Git 权威规则：

```text
Global Git Rules
```

本 Rule 是集成规则，不是替代规则。

---

## 2. No Second Git Policy

ForgeLoop 不定义独立：

```text
Branch Policy
Commit Convention
Merge Policy
Rebase Policy
Tag Policy
Push Policy
Remote Policy
```

这些由全局 Git Rules 决定。

---

## 3. Checkpoint

ForgeLoop Lifecycle 中的：

```text
Checkpoint
```

必须通过合法 Git Workflow 形成可靠版本边界。

---

## 4. Task Completion

标准关系：

```text
Task
↓
Implementation
↓
Verification
↓
Git Workflow
↓
Checkpoint
```

Checkpoint 的实际形式由全局 Git Rules 决定。

---

## 5. Before Git Mutation

任何可能改变 Git 状态的操作：

```text
commit
reset
rebase
merge
revert
checkout
branch
push
```

必须遵守全局 Git Rules。

---

## 6. Unexpected Git State

如果发现：

```text
Uncommitted Changes
Detached HEAD
Unexpected Branch
Conflicting Changes
Missing Checkpoint
```

必须先按照全局 Git Rules 处理。

ForgeLoop 不得擅自恢复 Git 状态。

---

## 7. Release

Release 所涉及：

```text
Commit
Tag
Push
Branch
```

均由全局 Git Rules 和 Version Management 管理。

ForgeLoop 只负责工作流编排。
