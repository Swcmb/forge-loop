# goal-mode

Goal Mode 与 Manual Mode 的判定、推进行为，以及 `/goal` 的可用性前置。

依据：`DESIGN.md` §83（Goal Mode）、§84（Manual Mode）、§85（Goal Mode Adapter）。

---

## 1. Mode 判定

```text
存在 Active /goal  → Goal Mode
无 Active /goal    → Manual Mode
```

`/goal` 是 Claude Code 内建命令（见 code.claude.com/docs/en/goal）。它的可用性受 workspace trust 与
`disableAllHooks` / `allowManagedHooksOnly` 设置约束。若运行时不可用，Goal Mode 覆盖点为**不可达**，
本 Workflow 恒为 Manual Mode，并如实记录，不以 Manual Mode 结果冒充 Goal Mode 已验证。

## 2. 推进行为（§83 / §84）

Goal Mode：

```text
One Task → Complete → Checkpoint → Report Evidence → Continue
```

完成即自动取下一个 Task（按 `task-model.md` §4 取件策略），不向用户逐任务索取许可。

Manual Mode：

```text
One Task → Complete → Pause → User decides
```

保留人工审核价值。

## 3. Goal Mode Adapter（§85）

对上游 `aspiers/iterative-development` 的适配**只改 continuation policy**（推进行为），保持 Task 粒度、
验证纪律、Task State：

```text
上游（Manual-first）：
  一个 Task 完成 → Ask "Ready for the next sub-task?" → 等 yes/y → 下一个

ForgeLoop Goal Mode Adapter：
  一个 Task 完成 → Checkpoint → 报告 Evidence → 取下一个 Task（不问 yes/y）
```

逐条覆盖点与判定规则见 `iterative-integration.md`。

## 4. Evidence 中的续行标记

Goal Mode 下每次 Checkpoint 后，在 `evidence.yaml` 写入机器可检的续行标记：

```yaml
mode: goal
next: TASK-xxx
```

该标记是「未被上游暂停拦截」的反证：Checkpoint 后出现面向用户的 `Ready for the next sub-task?` 类提问，
或该标记缺失，均视为 Goal Mode 未生效（见 `iterative-integration.md` 的 FAIL 判据）。