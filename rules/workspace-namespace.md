# Workspace Namespace Rules

## 1. Ownership

ForgeLoop 只有两个逻辑 Owner：

```text
FORGELOOP
CURRENT_PROJECT
```

---

## 2. Core Mapping

```text
FORGELOOP
    → normal namespace

CURRENT_PROJECT
    → dev-* / .dev-*
```

---

## 3. ForgeLoop Self Development

当开发 ForgeLoop 自身：

```text
Owner = FORGELOOP
```

使用：

```text
doc/
.ai/
```

以及正常源码目录。

不得使用：

```text
dev-doc/
.dev-ai/
```

作为 ForgeLoop 自身开发空间。

---

## 4. External Project

ForgeLoop 开发其他项目：

```text
Owner = CURRENT_PROJECT
```

使用：

```text
dev-doc/
.dev-ai/
```

以及：

```text
dev-*
.dev-*
```

---

## 5. Mapping

```text
Current Project       ForgeLoop

dev-doc/              doc/
dev-config/           config/
dev-scripts/          scripts/
dev-tools/            tools/
dev-agents/           agents/
dev-commands/         commands/
dev-skills/           skills/
dev-rules/            rules/
dev-hooks/            hooks/
dev-prompts/          prompts/
dev-templates/        templates/
dev-reports/          reports/
```

隐藏目录：

```text
.dev-ai/              .ai/
.dev-cache/           .cache/
.dev-work/            .work/
```

---

## 6. Ownership Is Not Maturity

以下状态不会改变 Namespace：

```text
Draft
Review
Approved
Stable
Released
```

Owner 决定 Namespace。

---

## 7. No Promotion

禁止默认：

```text
dev-doc → doc
.dev-ai → .ai
```

不存在“成熟后迁移到 ForgeLoop 目录”的标准流程。

---

## 8. Source Code

源码目录不强制使用 `dev-`。

例如：

```text
src/
tests/
server/
client/
packages/
```

仍由项目自身结构决定。
