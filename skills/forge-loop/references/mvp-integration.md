# mvp-integration：上游 `slavingia/mvp` 的 ForgeLoop Adapter

依据：`DESIGN.md` §3.1、§14–§16、§86
决策：`doc/decisions/ADR-005-slavingia-mvp-integration.md`
设计：`doc/design/spac-001-detailed-design.md` §3.3

---

## 1. 本文件的角色

上游 `slavingia/mvp` 是**商业顾问人格**的 skill（`You are a business advisor channeling the
philosophy of The Minimalist Entrepreneur`），其产出形态是商业启动方案（唯一一件事、最简实现、
周末可交付物、初始定价、反馈收集方式）。`DESIGN.md` §15 的产出契约是工程 scope 集合
（required / optional / deferred），两者**不同构**。

本文件是适配层：上游只作**启发式输入**，Gate 判据与产出契约以 `DESIGN.md` §15 / §16 为准。

## 2. 指令优先级

```text
ForgeLoop 指令 > 本文件（Adapter） > 上游 mvp
```

## 3. 复用：启发式输入（M-01）

上游以下内容作为 MVP Scope 推理的启发式输入：

| 上游启发式 | 对应 §16 判据 |
| :--- | :--- |
| Can I ship it in a weekend? | 最小可交付范围 |
| Don't write code when a spreadsheet works | 功能是否已有更简单实现 |
| Stage 1 Manual（自己动手做） | 这个流程能否先人工 / 简单实现 |
| Don't build features you think you'll need someday | 功能是否可延期 |

上游启发式**不得替代** §16 判据（M-02）。

## 4. Gate：§16 MVP Minimality Gate

进入 SPEC 前执行 Minimality Review，逐条回答：

```text
这个功能是不是核心价值的一部分？
这个功能是否可以延期？
这个功能是否已经有更简单实现？
这个流程能否先人工 / 简单实现？
```

目标：最小范围 + 最大可验证性。四问全部可答才进入 SPECIFICATION。

## 5. 产出契约（M-03）：§15 MVP Scope Model

```yaml
mvp:
  version: <由全局 Version Management 判定，ForgeLoop 不自定>
  required:  [REQ-001, REQ-002]   # 当前 Goal 必须兑现
  optional:  [REQ-010]            # 可选
  deferred:  [REQ-020]            # 延后
```

产出落盘 `<runtime>/<feature>/mvp-scope.yaml`。

## 6. 排除项

- **商业启动话术不进 ForgeLoop 输出**（M-04）：公司名、域名、社交账号、收款、定价均排除。
- **不承担**（M-05，原样）：Task Execution / Git / Testing / Final Audit / Goal Completion。
- 上游输出若被误用于任务执行或 Gate 判定 → 按 M-02 / M-05 收束回 §15 / §16。

## 7. 上游缺失时的降级（详细设计 §4.1）

```text
mvp 安装失败
  ↓ 记录 Blocker（Cause / Impact / Required Action / Context）
  ↓ §15 的 required / optional / deferred 由 §16 四问直接产出
  ↓ 本文件保留为待接入占位并记录 Blocker
  ↓ 第一阶段其余能力继续推进，不整体停摆
```

不做的动作：以内置实现顶替上游、删除 `DESIGN.md` 的上游依赖定义、把上游降级为可选依赖。

## 8. 上游现状（2026-10-06 实测）

| 项 | 值 |
| :--- | :--- |
| Repository | `https://github.com/slavingia/skills`（public，`main`，10844 stars） |
| Path | `skills/mvp` |
| Path Last Commit | `338c4301ebd530dd721d7f2ec22c01dbd6d3f274`（2026-03-23） |
| Blob SHA（`SKILL.md`） | `a42a7996f5befe5cc8389ba41aed86b72da0f9f1` |
| 中央库副本 | `D:\ai-configs\skills\skills\mvp\` |
| 部署副本 | `C:\Users\Swcmb\.claude\skills\mvp\` |
| skill_id | `496208ea-0363-4f71-8f44-c9f8f6b454c9` |

库副本 `git hash-object` 与上游 blob 逐字一致。完整来源登记见
`D:\ai-configs\docs\skills-provenance.md`。commit 与 blob 为来源指纹，不构成 Project Version。