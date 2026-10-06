# ForgeLoop Project Constraints

## 1. Project

```text
Project = ForgeLoop
Owner = FORGELOOP
Target = Claude Code
```

---

## 2. Design

Design Authority：

```text
ForgeLoop.DESIGN.md
```

Design Version：

```text
1.0.0
```

---

## 3. Version Constraint

ForgeLoop Project Version 必须遵循：

```text
Global Version Management
```

项目不得自行定义与全局规则冲突的版本系统。

必须明确区分：

```text
Design Version
Project Version
Release Version
```

---

## 4. Git Constraint

ForgeLoop 所有 Git 行为必须遵循：

```text
Global Git Rules
```

项目不得建立第二套 Git Policy。

---

## 5. Workspace Constraint

ForgeLoop 自身：

```text
doc/
.ai/
```

External Project：

```text
dev-doc/
.dev-ai/
```

---

## 6. Development Constraint

开发遵循：

```text
Small Task
+
Actual Implementation
+
Actual Verification
+
Evidence
+
Checkpoint
```

---

## 7. Requirement Constraint

Required Requirement 必须：

```text
Have Identity
Be Traceable
Be Implemented
Be Verified
```

---

## 8. State Constraint

长期状态必须持久化。

ForgeLoop：

```text
.ai/
```

---

## 9. Recovery Constraint

恢复必须检查：

```text
State
Workspace
Git
Checkpoint
```

状态不一致时不得静默继续。

---

## 10. Final Audit Constraint

Goal Complete 前必须：

```text
Final Audit
```

Audit 可以产生新的 Task。

---

## 11. Completion Constraint

最终完成必须满足：

```text
Required Requirements Verified
+
Required Tests Passed
+
Required Reviews Passed
+
Final Audit Passed
+
Version State Valid
+
Git State Valid
```

其中：

```text
Version State Valid
```

由全局 Version Management 判断。

```text
Git State Valid
```

由全局 Git Rules 判断。

---

## 12. Absolute Rules

ForgeLoop 开发时必须始终遵循：

```text
Global Governance
        ↓
ForgeLoop Rules
        ↓
Current Task
```

版本：

```text
Global Version Management
```

Git：

```text
Global Git Rules
```

工作空间：

```text
ForgeLoop Namespace Rules
```

生命周期：

```text
ForgeLoop.DESIGN.md
```

具体实现：

```text
Claude Code 根据实际工程动态决定
```
