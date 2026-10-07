# SPAC-001 评审记录

评审对象：`doc/design/spac-001-detailed-design.md`
评审日期：2026-10-06
状态：第 2 轮结束，全部 mustFix 已落地

---

## 1. 计数口径（本文件为唯一权威表述）

评审分两轮，共 **58 条发现**。CRITICAL 计数按「去重、去误判后的实际独立问题」统计：

| 轮次 | 视角 | 发现数 | 原始 CRITICAL | 说明 |
| :--- | :--- | :--- | :--- | :--- |
| 第 1 轮 | design-conformance | 12 | 1 | version-state.yaml 被误删 |
| 第 1 轮 | practicality | 12 | 0 | — |
| 第 1 轮 | completeness | 12 | 0 | — |
| 第 1 轮 | governance | 12 | 1 | `agents/` 放项目目录违反全局硬边界 |
| 第 1 轮 | risk | 0 | — | API 502 失败，改由第 2 轮补跑 |
| 第 2 轮 | risk（补跑） | 10 | 3 | 见下方折算 |
| | **合计** | **58** | **5 原始** | **3 独立可执行** |

### 1.1 第 2 轮 3 条 CRITICAL 的折算

| # | 问题 | 判定 | 依据 |
| :--- | :--- | :--- | :--- |
| 1 | `/goal` 无任何实现，Goal Mode 前提不成立 | **误判，已驳回** | `/goal` 是 Claude Code 内建命令（code.claude.com/docs/en/goal），非 `commands/` 目录下的文件。评审代理搜索位置错误。保留其派生结论：T-01 增加 `/goal` 运行时实测 |
| 2 | 三个 Agent 落在项目目录，Review Gate 无执行者 | **与第 1 轮 CRITICAL-2 重复** | 同一问题，已在 ADR-006 修订中处置 |
| 3 | blob 比对只在安装时一次，compatibility check 无运行时触发点 | **成立，已采纳** | 落 §3.6.3，指纹改用默认 `git hash-object`（含 CRLF 归一化） |

### 1.2 权威结论

```text
独立 CRITICAL = 3
  C-1  version-state.yaml 被误删（已恢复）
  C-2  agents/ 落项目目录违反全局硬边界（已修订到 D:\ai-configs\agents\）
  C-3  compatibility check 缺运行时触发点（已补 §3.6.3）

MAJOR = 20（第 1 轮 15 + 第 2 轮 5，全部落地）
MINOR = 2（已并入 §6 Contingency 的可观测判据）
驳回   = 1（/goal 无实现，误判）
```

后续 provenance 与 audit 记录引用本节口径，不另行计数。

---

## 2. 关键实测证据

评审中的机器事实断言经复核：

```text
~/.claude/agents -> /d/ai-configs/agents/        符号链接，Agent 唯一加载路径
Claude Code 2.1.267                              /goal 内建命令可用
未设 disableAllHooks / allowManagedHooksOnly     无 managed-settings.json
git hash-object SKILL.md  = cf1011224c27c…       与 ADR-001 §2 指纹一致
git hash-object --no-filters = 22a7119a25b7…     不一致，--no-filters 不可用
工作区字节数 2203 B vs ADR 记录 2131 B            CRLF 转换，字节数不可作指纹
D:\ai-configs\skills\skills\mvp                  不存在（T-01 待完成，含 §4.1 降级）
```

---

## 3. 评审者一致确认的设计正确项

以下部分经多视角确认，无需再改：

- 三段式 `upstream → installed skill → adapter` 与 `DESIGN.md` §103 完全对齐，未把上游揉进主 SKILL.md。
- `SKILL.md` 五项职责与 §105 逐字对应，渐进披露切分正确。
- references 第一阶段 10 个、`audit-model.md` 随 L/M 延后，与 ADR-004 一致。
- 复用本机 `spec` / `writing-plans` 而非自行实现，符合 `AGENTS.md` §9。
- 版本与 Git 边界表述正确，未自建第二套体系。
- L/M/N 与商业能力明确列入 Out of Scope，并设 V-09 反向判据防范围蔓延。
- 任务分解按真实依赖排序，每步独立可验证、独立 Checkpoint。
- 开放项 1（`.ai/` 状态结构）与开放项 2（验证方式）由本规格显式承接并给出方案。
- §109 的 A–N 全部作为第一阶段验收对象，未提前实现无验证依据的能力。

---

## 4. 记录在案的设计不一致

见规格 §7 DI-01～DI-08。全部保留为记录，本轮不修改 `DESIGN.md`。