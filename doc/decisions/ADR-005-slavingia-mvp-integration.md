# Decision Record: `slavingia/mvp` 接入形态

决策日期：2026-10-06
状态：已裁定
决策人：用户
关联审计：`doc/audits/repository-audit.md` §8 B-02

---

## 1. Decision

`slavingia/mvp` 按 ADR-001 同一三段式接入（upstream → installed skill → ForgeLoop adapter）。上游作为 MVP Scope 的**启发式输入**；MVP Minimality Gate 的判据与产出契约以 `DESIGN.md` §15 / §16 为准。

---

## 2. Pinned Upstream Source

| 项 | 值 |
| :--- | :--- |
| Repository | `https://github.com/slavingia/skills` |
| Path | `skills/mvp` |
| Path Last Commit | `338c4301ebd530dd721d7f2ec22c01dbd6d3f274`（2026-03-23，`Add 9 Claude Code skills based on The Minimalist Entrepreneur`） |
| Blob SHA (SKILL.md) | `a42a7996f5befe5cc8389ba41aed86b72da0f9f1` |
| File Size | 3748 B（上游字节大小；Windows 工作区副本经 CRLF 转换后会偏大，**字节数不作指纹依据**，比对一律用默认 `git hash-object`） |
| Repo Stars | 10844 |
| 本机状态（2026-10-06 实测） | 库内不存在，尚未安装 —— 详细设计 T-01 待完成项，含 §4.1 降级路径 |

版本管理仍遵循 Global Version Management Rules；上述 commit 与 blob 为来源指纹，非 ForgeLoop Project Version。

---

## 3. Semantic Analysis（上游与 §15/§16 的关系）

上游是商业顾问人格 skill（`You are a business advisor channeling the philosophy of The Minimalist Entrepreneur`），`## Output` 产出五项：唯一一件事、最简实现、周末可交付物、初始定价、反馈收集方式。

与 §16 MVP Minimality Gate 四问的契合度：

| §16 判据 | 上游对应 | 契合 |
| :--- | :--- | :---: |
| 功能是否核心价值一部分 | Is it making my customers' life a little better? | 弱（价值框架不同） |
| 功能是否可延期 | Don't build features you think you'll need someday | 强 |
| 是否已有更简单实现 | Don't write code when a spreadsheet works | 强 |
| 流程能否先人工实现 | Stage 1 Manual「Do it yourself」 | 强 |

`DESIGN.md` §15 要求 MVP 阶段产出 `required` / `optional` / `deferred` 需求集合；上游产出形态是商业启动方案。两者产出契约不同构，需 adapter 收束。

---

## 4. Adapter Contract

| 编号 | 约束 |
| :--- | :--- |
| M-01 | 上游作为 MVP Scope 的启发式输入（能否周末交付、能否先人工、是否已有更简单实现） |
| M-02 | Gate 判据以 §16 四问为准；上游启发式不得替代判据 |
| M-03 | ForgeLoop MVP Scope Engine 的产出契约为 §15 的 `required` / `optional` / `deferred` 需求集合 YAML |
| M-04 | 商业启动话术（公司名、域名、社交账号、收款、定价）不进入 ForgeLoop 输出 |
| M-05 | 上游不承担 Task Execution / Git / Testing / Final Audit / Goal Completion（§3.1） |
| M-06 | 上游升级走 §103 三段式 + compatibility check |

---

## 5. Consequences

- MVP Scope（ADR-002 能力 C）第一阶段实现，依赖上游 installed skill + 本仓库 `references/mvp-integration.md` adapter。
- 商业语义与工程 scope 的落差记录在 `references/mvp-integration.md`，不修改 DESIGN.md。