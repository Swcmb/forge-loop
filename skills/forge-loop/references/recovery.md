# recovery

中断后的恢复流程、六类触发场景与取证协议。

依据：`DESIGN.md` §79（Long-Running State）、§98（Goal Resume）、§99（Compact Resume）；
`AGENTS.md` §13；项目规则 `rules/state-and-recovery.md`。

---

## 1. 恢复流程（§98 / §104）

```text
Load State
  ↓ Read <runtime>/development-status.yaml
  ↓ Read <runtime>/version-state.yaml
  ↓ Read <runtime>/<feature>/tasks.md
  ↓ Read Git state
  ↓ 定位当前未完成 Task
  ↓ Reconcile（状态与 Git 不一致时）
  ↓ Resume
```

状态不一致时 `STOP AUTO-PROGRESSION`，先 Reconcile 确定真实工程状态，再继续
（`rules/state-and-recovery.md` §5）。禁止在状态不明确时静默猜测。

## 2. 六类触发场景（`AGENTS.md` §13）

| 场景 | 恢复要点 |
| :--- | :--- |
| Session Restart | 重新读 `<runtime>/` 全量状态，按 tasks.md 定位当前 Task |
| Context Compaction | 按 §4 的 probe 协议取证，确认恢复结论来自文件而非对话记忆 |
| Interrupted Work | 检查工作树变更 + tasks.md 勾选状态差集，判定已完成/未完成部分 |
| Partial Execution | 同上，不无条件重复执行（`rules/state-and-recovery.md` §6） |
| Agent Failure | 取子代理退出状态 + `verification-state.yaml` 中的中断位置 |
| Unexpected Git State | 按 `version-control.md` §3 判据检测并按全局 `rules/git.md` 处理 |

## 3. 状态 / Git 冲突的 Reconcile

```text
Runtime = Task Complete，Git = 代码有未提交改动  → 冲突 → Reconcile
Runtime = Iteration N，Git = Iteration N-1 Checkpoint → 冲突 → Reconcile
```

判据与命令见 `version-control.md` §3。Reconcile 的依据是 `<runtime>/` 全量状态与 Git 实际状态的
逐项比对，不是对话记忆。

## 4. Context Compaction 取证协议

压缩由 harness 触发，Workflow 无法控制时机与内容。取证：

```text
1. 压缩前：计算 development-status.yaml 的 sha256，与当前 Iteration ID 一并
   写入 doc/verification/<feature>/compaction-probe.md
2. 触发压缩：/compact 或自然触发
3. 恢复后：重新读取 <runtime>/ 全量状态，重算 sha256 追加到 probe 文件尾
4. 判定：两值一致 → 通过；不一致 → 失败
5. 声明：probe 中写 restored_from: files-only
        —— 恢复结论只能来自文件读取，不来自对话记忆
```

## 5. 失败即非完成（`rules/state-and-recovery.md` §7）

任何验证失败：`Task ≠ Complete` → 修复 → Test → Review → Verify。