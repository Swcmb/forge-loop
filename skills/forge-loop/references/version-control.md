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

## 6. Release Gate 九项（§72，REQ-N / T-24）

T-24 契约。进入 `RELEASE_READY`（§73）前九项同时成立，每项注明取证来源：

| # | Gate 项 | 取证来源 | 判据 |
| :-- | :--- | :--- | :--- |
| 1 | Requirements PASS | `.ai/<feature>/requirement-matrix.yaml` 的 `status` 区 | 全部 required Requirement 为 `verified`（§38 Requirement Verification Gate） |
| 2 | Acceptance PASS | 同上文件的 `acceptance` 区 | 每个 REQ 的每条 AC 有 verified 证据（§20） |
| 3 | Tests PASS | `.ai/<feature>/evidence.yaml` 的 `tests` 字段 | 本轮 Test Gate 记录含实际执行的命令与结果（§36） |
| 4 | Build PASS | `.ai/audit-state.yaml` 的 `build.status` | 本仓库无构建工具链，判据 = 自检脚本 exit 0（T-15 起） |
| 5 | Runtime PASS | `.ai/audit-state.yaml` 的 `runtime.status` | 自检 + Recovery 演练的运行时取证（§71 Runtime Gate） |
| 6 | Code Review PASS | `.ai/audit-state.yaml` 的 `code_review.status` | 三层 Gate 之一（§37 `code-reviewer` 六维） |
| 7 | Final Audit PASS | `.ai/audit-state.yaml` 的 `final_document_audit.status` + `doc/audits/phase2/final-audit.md`（L 产出） | §66–§69 判据全过（T-27 L 演练） |
| 8 | Version Consistent | `VERSION` 文件 + `.ai/version-state.yaml` 的 `project.version` | B-03 已由 T-17 解除；frontmatter 一致性断言（自检第 2 组） |
| 9 | Git State Valid | `.ai/version-state.yaml` 的 `git.branch/head/clean` + CK-14 / CK-16 / CK-17 | 集成分支可达 + 状态一致 + 工作树干净 |

九项任一不成立 → 停留 `ITERATIVE_DEVELOPMENT`（§72 反向：未全过即不进 `RELEASE_READY`）。