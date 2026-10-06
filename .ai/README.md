# .ai/ — ForgeLoop 自身运行状态

依据 `DESIGN.md` §79（Owner = FORGELOOP → `.ai/`；Owner = CURRENT_PROJECT → `.dev-ai/`）、
`AGENTS.md` §12、`rules/state-and-recovery.md`、`rules/artifact-persistence.md` §6。
详细设计见 `doc/design/spac-001-detailed-design.md` §3.5。

## 文件

| 文件 | 作用 | 权威依据 |
| :--- | :--- | :--- |
| `development-status.yaml` | 当前 Goal / Phase / Task / Iteration / Checkpoint / Blocker / Mode | §56 |
| `version-state.yaml` | goal.id / mvp.version / spec.version / plan.revision / iteration.current / git.branch·head·clean | §55 |
| `verification-state.yaml` | §109 第一阶段判据矩阵 V-00～V-13 与进行中的 Gate | 详细设计 §5 |
| `<feature>/tasks.md` | 任务清单（与上游 `.ai/[feature]/tasks.md` 路径兼容） | §28、§29 |

第一阶段不含 `audit-state.yaml`（随 §109 的 L Final Audit / M Audit Repair Loop 延后）。

## 恢复链（§98 Goal Resume）

```text
Load State
  ↓ Read .ai/development-status.yaml
  ↓ Read .ai/version-state.yaml
  ↓ Read .ai/<feature>/tasks.md
  ↓ Read Git state
  ↓ Reconcile（状态与 Git 不一致时 STOP AUTO-PROGRESSION，先协调）
  ↓ Resume
```

## 状态 / Git 冲突的可执行判据

```text
比对对象 = 代码与文档路径（排除 .ai/）
命令     = git status --porcelain -- ':!.ai/'
冲突条件 = 上式非空 且 development-status.yaml 的 task.status=complete
处置     = STOP AUTO-PROGRESSION → Reconcile
```

`.ai/` 自身入库会带来「每次状态更新即产生工作树改动」，因此 `.ai/` 的变更不计入「Uncommitted
Changes」判据。

## 入库策略

`.ai/` 的状态文件纳入版本控制，仅在 Checkpoint 时提交，迭代中途不入库（`rules/artifact-persistence.md` §6
将 `.ai/` 定义为 durable workflow state；`rules/state-and-recovery.md` §3 要求 Checkpoint / Resume
Position 不得只存于对话）。`.ai/` 是否入库属仓库 `.gitignore` 配置决定，不构成 Git Policy。

## B-03（Project Version 无来源）

`version-state.yaml` 的 `project.version` 在 B-03 解除前写显式待定值 `pending: B-03`，不自定版本号；
其余字段正常维护。版本判定服从 Global Version Management Rules（`rules/version-management.md` §2）。