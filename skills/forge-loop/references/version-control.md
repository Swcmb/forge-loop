# version-control

Checkpoint 的 Git 实现。Checkpoint 是 ForgeLoop 唯一的版本边界载体。

依据：`DESIGN.md` §53（Checkpoint）、§54（Checkpoint Purpose）、§40–§43；
项目规则 `rules/git-integration.md`；全局 `rules/git.md` 与 `ai-git-workflow`。

---

## 1. Checkpoint（§53）

每轮 `ITERATION COMPLETE` 形成一个 Checkpoint，记录：

```yaml
goal.id
iteration.id
task.id
git.commit
spec.version
progress.requirements
```

用途（§54）：Resume / Audit / Rollback / Progress Tracking / Version Comparison。

## 2. Checkpoint 双重落点

结构化字段写入 `<runtime>/` 状态文件（`development-status.yaml` 的 `checkpoint` 段、
`version-state.yaml` 的 `iteration`/`git` 段）；Git 记录进版本历史，走全局 Workflow。

Checkpoint 的 Git 实现严格遵循全局 `rules/git.md` 与 `ai-git-workflow`：
分支命名、提交格式、合并与删除、推送策略**一律取全局规则，本文件不复制也不重述**
（`rules/git-integration.md` §2：ForgeLoop 不建第二套 Git Policy）。

## 3. 冲突检测（可执行判据）

```text
比对对象 = 代码与文档路径（排除 .ai/）
命令     = git status --porcelain -- ':!.ai/'
冲突条件 = 上式非空 且 development-status.yaml 的 task.status=complete
处置     = STOP AUTO-PROGRESSION → Reconcile（见 recovery.md）
```

`.ai/` 状态文件自身的变更不计入「Uncommitted Changes」判据；仅在 Checkpoint 时提交。

## 4. 遇到异常 Git 状态

未提交改动、Detached HEAD、异常分支、冲突改动或缺失 Checkpoint 时，按全局 `rules/git.md` 处理；
不擅自 `reset` / `checkout` / `clean`（`rules/git-integration.md` §6、
全局 `rules/filesystem.md`）。破坏性 Git 操作需用户在该轮明确授权。

## 5. 未启用项

`DESIGN.md` §43 Worktree 属并行隔离能力，第一阶段串行闭环**不启用**，本文件仅声明不实现。