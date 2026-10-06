# ForgeLoop Development Rules

## 1. Scope

本 Rule 适用于 ForgeLoop 自身开发。

```text
OWNER = FORGELOOP
CURRENT_PROJECT = FORGELOOP
```

---

## 2. Governing Rules

本 Rule 必须服从：

```text
Global Rules
```

尤其是：

```text
Global Version Management
Global Git Rules
Global Security Rules
Global Repository Rules
```

---

## 3. Design

开发前读取：

```text
ForgeLoop.DESIGN.md
```

Design 是系统设计依据。

---

## 4. No Premature Detailed Design

不得在没有实际工程依据的情况下预先假定：

```text
Architecture
Module
API
Database
Task Breakdown
Implementation Structure
```

具体设计由 Claude Code 结合实际需求和代码形成。

---

## 5. Existing Harness First

开发前检查：

```text
agents/
commands/
skills/
rules/
```

遵循：

```text
Reuse
→ Extend
→ Create
```

---

## 6. Task Boundary

默认：

```text
ONE TASK
```

执行一个 Task 时：

```text
Explore
→ Implement
→ Test
→ Review
→ Verify
```

---

## 7. Evidence

任何完成状态必须能够回答：

```text
What was changed?
How was it tested?
How was it reviewed?
How was the requirement verified?
```

---

## 8. Requirement Integrity

Requirement、SPEC、PLAN、Task、Implementation、Verification 之间必须保持可追踪。

Requirement 或 SPEC 发生语义变化时：

```text
Existing Implementation
Existing Verification
```

必须重新评估。

---

## 9. State

ForgeLoop 自身状态存放：

```text
.ai/
```

---

## 10. Checkpoint

完成 Task 后需要形成 Checkpoint。

Checkpoint 的具体 Git 实现：

```text
遵循 Global Git Rules
```

ForgeLoop 不自行定义 commit / tag / branch 策略。

---

## 11. Version

任何版本相关工作：

```text
Read Global Version Management
→ Determine Current Version
→ Determine Required Version Change
→ Apply Global Rules
→ Verify Version State
```

不得直接猜测版本号。

---

## 12. Final Audit

全部 Required Task 完成后执行：

```text
Final Audit
```

Audit 发现问题时重新进入 Task Loop。

---

## 13. Completion

完成条件：

```text
Requirements Verified
+
Tests Passed
+
Reviews Passed
+
Final Audit Passed
+
Version Valid
+
Git Valid
```
