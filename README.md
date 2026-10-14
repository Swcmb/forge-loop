# ForgeLoop

Goal-driven、迭代式的 Claude Code 工程编排器。Skill 形态：`DESIGN.md`（113 节，唯一权威）
驱动 14 项核心能力——Goal / MVP / Requirement / SPEC / Plan / Task / Iteration /
Test / Review / Verification / Git Checkpoint / State / Final Audit / Release。

## 使用

1. 进入目标项目目录
2. 激活 Goal Mode：`/goal <目标描述>` 或 `claude /goal`
3. 路由到 `skills/forge-loop/SKILL.md`（自动加载）
4. 详细契约：`AGENTS.md` §1–§16、`rules/*.md`（7 份）

Skill 形式：

```bash
claude --skill forge-loop "/goal 完成当前项目 MVP Scope 中规定的全部 Required 功能"
```

## 仓库布局

```text
DESIGN.md                  系统设计（113 节，权威依据）
AGENTS.md                  项目级 Agent 契约（16 节）
CONTRIBUTING.md            贡献流程
CLAUDE.md                  Agent 读库入口（镜像 CLAUDE.md → AGENTS.md）
VERSION                    Project Version 唯一权威源（当前 1.0.0）
CHANGELOG.md               版本变更记录（Keep a Changelog）
rules/                     7 份项目规则
  forge-loop-development.md    自身开发流程与完成条件
  git-integration.md         Git 接入（不建第二套 Git Policy）
  state-and-recovery.md      状态持久化与恢复
  version-management.md      版本管理接入
  workspace-namespace.md     Owner 与命名空间归属
  artifact-persistence.md    工程产物落盘（强制）
  domestic-mirror.md         拉取模型/依赖优先使用国内镜像
skills/forge-loop/         编排层本体（Deploy 形态，DESIGN.md §81–§82）
  SKILL.md                    路由与核心约束
  references/                 11 份契约
scripts/check-forge-loop.sh  结构化自检（仓库唯一测试入口，当前 111/0/0）
doc/                       项目文档（索引见 doc/README.md）
.ai/                       ForgeLoop 自身运行状态（§79，Owner = FORGELOOP）
.ai/forgeloop-phase1/      第一阶段 Goal FL-001 的工件（已冻结）
.ai/forgeloop-phase2/      第二阶段 Goal FL-002 的工件
.ai/forgeloop-phase3/      第三阶段 Goal FL-003 的工件（DI-02 处置）
```

## 关键判据

```bash
bash scripts/check-forge-loop.sh   # exit 0 = PASS；当前 111/0/0
```

负向判据见脚本尾部说明：VERSION 清零、frontmatter 与 VERSION 漂移、
`audit-model.md` 缺失、DI-02 旧写法复活等。

## 文档权威分布

| 职能 | 权威位置 |
| :--- | :--- |
| 设计 | `DESIGN.md`（113 节，唯一权威） |
| 条文 | `rules/*.md`（7 份，单一事实来源） |
| 决策 | `doc/decisions/ADR-*.md`（7 份） |
| 交付快照 | `doc/audits/phase*/goal-closeout.md` + `CHANGELOG.md` |
| 操作 | `skills/forge-loop/SKILL.md`（路由 + 核心约束） |
| 入口 | 本文件 |

CLAUDE.md 的「仓库状态块」是 Agent 读库的紧凑镜像；本文件面向人类读者，
允许比 CLAUDE.md 块更宽。
