# ForgeLoop Workspace Namespace

## 1. Core Rule

```text
FORGELOOP
    → normal namespace

CURRENT_PROJECT
    → dev-* / .dev-*
```

---

## 2. ForgeLoop

开发 ForgeLoop 自身：

```text
doc/
.ai/
```

例如：

```text
doc/
    ForgeLoop Documentation

.ai/
    ForgeLoop Runtime
```

---

## 3. External Project

ForgeLoop 被用于开发其他项目：

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

## 4. Mapping

```text
dev-doc/       ↔ doc/
dev-config/    ↔ config/
dev-scripts/   ↔ scripts/
dev-tools/     ↔ tools/
dev-agents/    ↔ agents/
dev-commands/  ↔ commands/
dev-skills/    ↔ skills/
dev-rules/     ↔ rules/
dev-hooks/     ↔ hooks/
dev-prompts/   ↔ prompts/
dev-templates/ ↔ templates/
dev-reports/   ↔ reports/
```

隐藏目录：

```text
.dev-ai/       ↔ .ai/
.dev-cache/    ↔ .cache/
.dev-work/     ↔ .work/
```

---

## 5. Important Meaning

```text
doc/
```

含义：

```text
ForgeLoop Documentation
```

```text
dev-doc/
```

含义：

```text
Current Project Development Documentation
```

因此 ForgeLoop 自身开发时直接使用：

```text
doc/
```

---

## 6. No Migration

不存在：

```text
dev-doc
    ↓
成熟
    ↓
doc
```

或者：

```text
.dev-ai
    ↓
成熟
    ↓
.ai
```

Namespace 是 Owner 信息，而不是成熟度信息。

---

## 7. Source Code

源码不需要使用：

```text
dev-src/
```

正常：

```text
src/
tests/
app/
server/
client/
packages/
```

即可。
