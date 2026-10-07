# Decision Record: 交付物位置与部署形态

决策日期：2026-10-06
状态：已裁定
决策人：用户
关联审计：`doc/audits/repository-audit.md` §9 第 5 项

---

## 1. Decision

`skills/forge-loop/` 在 **ForgeLoop 仓库内作为权威源码**编写并随仓库版本化；本机技能库作为**部署目标**。

```text
D:\ForgeLoop\skills\forge-loop/          权威源码，随 DESIGN.md 一起版本化、评审、回滚
        ↓ manage-skills adopt + deploy
D:\ai-configs\skills\skills/forge-loop/  部署分发目标
```

---

## 2. Rationale

| 诉求 | 满足方式 |
| :--- | :--- |
| `DESIGN.md` 与其实现同处一个版本边界 | 交付物在 `D:\ForgeLoop` 内，随仓库 commit / PR / 回滚 |
| `DESIGN.md` §104 要求 provenance 记在 Harness 配置仓库 | 由 `D:\ai-configs\docs\skills-provenance.md` 承载，不在项目目录内另建 |
| 全局 `rules/skills.md` 要求 skill 管理唯一入口是 `manage-skills` | 部署环节走 `manage-skills`，不手工复制进 agent 目录 |
| 避免两份权威副本 | 仓库是唯一权威副本；库中副本由部署产生，不独立编辑 |

---

## 3. Lifecycle Mapping

按 `rules/skills.md` 的 skill 生命周期七步，本次交付的对应关系：

| 生命周期步骤 | 本次对应 |
| :--- | :--- |
| 1 需求分析 | ADR-002 MVP Scope |
| 2 开发 | 在 `D:\ForgeLoop\skills/forge-loop/` 直接编写（skill 开发阶段允许直接编辑 authoring 文件） |
| 3 本地验证 | MVP 完成标准 V-01～V-09（ADR-002 §5） |
| 4 上传 GitHub | 随 `D:\ForgeLoop` 仓库 PR 流程 |
| 5 进入规范库 | `manage-skills adopt` |
| 6 安装注册 | `manage-skills install` / `set-source` + `deploy`，provenance 记入 `D:\ai-configs\docs\skills-provenance.md` |
| 7 验证安装 | Registered / Deployed / Loadable 三项独立确认（`rules/skills.md` §Verification of an install） |

---

## 4. Constraints

- 仓库内的 `skills/forge-loop/` 是唯一可编辑的副本。
- `D:\ai-configs\skills\skills\forge-loop/` 由部署产生，在其中直接编辑会 desync 库、数据库行与各 agent 部署，属 `rules/skills.md` 明令禁止的手工管理绕行。
- 上游 `aspiers/iterative-development` 同样遵循 ADR-001 的三段式（upstream → installed skill → adapter），其 installed skill 也落在库内，ForgeLoop Adapter 在本仓库内编写。