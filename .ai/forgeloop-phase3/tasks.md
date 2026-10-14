# forgeloop-phase3

第三阶段任务清单（`DESIGN.md` §28 格式）。范围：已登记缺陷 DI-02 的处置与回归防护。

处置口径的唯一出处是 `rules/git-integration.md` §10——统一引用方，文件名以磁盘现状为准。

本阶段不引入新能力。FL-002 已交付 `DESIGN.md` §109 的 A～N 全部十三项能力（`v1.0.0`），
FL-003 只处理遗留缺陷，因此不新建 ADR：§10 本身就是该缺陷的裁定条文，T-31 执行它。

---

- [x] 1. T-31 DI-02：设计文档引用路径统一

  Requirement: 工程目标（一致性）——DI-02 的处置与回归防护
  Acceptance: []
  Tests: 活引用方 12 处全部改为 `DESIGN.md`；`rules/git-integration.md` §10 改写为已落定约定；`CLAUDE.md` 的提示段改为直接约定；历史记录类文件保留原写法并加注记；自检新增第 11 组断言。负向三条各 `exit 1`：活文件改回旧写法、白名单文件移出白名单路径、`DESIGN.md` 缺失
  Evidence: `.ai/forgeloop-phase3/evidence.yaml` T-31 条目

- [ ] 2. T-32 FL-003 Goal 收口

  Requirement: 工程目标（收口）——Goal 范围的最小收口
  Acceptance: []
  Tests: 本 Goal 的 Task 清单无未完成项；自检 exit 0；Goal 状态文件与 Checkpoint 完整
  Evidence: 待补

## 处置分类

DI-02 的 31 处命中分四类，处置依据是「该处是否描述当时的事实」：

| 类别 | 文件（命中数） | 处置 |
| :--- | :--- | :--- |
| 活引用——会误导读者或 Agent 去打开不存在的文件 | `AGENTS.md`(5)、`CONTRIBUTING.md`(1)、`README.md`(1)、`doc/DEVELOPMENT.md`(1)、`doc/PROJECT-CONSTRAINTS.md`(2)、`rules/version-management.md`(1)、`rules/forge-loop-development.md`(1) | 改为 `DESIGN.md` |
| 定义处置口径的规则 | `rules/git-integration.md` §10 | 改写为已落定约定，保留历史说明（该文件仍含 1 处旧写法，是「历史说明」而非引用） |
| 提示注意的项目说明 | `CLAUDE.md` §命名不一致 | 改写为直接约定（同上，保留 1 处历史说明） |
| 历史记录——描述的是当时的事实 | `doc/INITIAL-DELIVERY.md`(15，含 T-31 加的注记 1 处)、`doc/design/spac-001-detailed-design.md`(1，ADR-007 冻结)、`doc/audits/repository-audit.md`(1)、`doc/requirements/brainstorming-results.md`(1)、`CHANGELOG.md`(1) | 保留原写法，加处置注记 |
| 判据自身 | `scripts/check-forge-loop.sh`(3：模式串、报错文案、注释)、`.ai/forgeloop-phase3/evidence.yaml`(2) | 必须含旧写法字符串，判据才能检出它 |

活引用 12 处改写；规则与说明各改写 1 段；历史记录 19 处保留原写法；判据自身 5 处按设计保留。

处置判据是**该处是否在描述当时的事实**：描述事实的保留原样（改写会让记录失真），
指向可操作对象的才统一。CHANGELOG 是处置过程中新增的白名单成员——它是 Keep a Changelog
格式的版本变更记录，描述 DI-02 这个已修复缺陷时必须写出旧写法，否则条目无法被理解。

## Relevant Files

- `rules/git-integration.md` §10 —— 处置口径的唯一出处
- `scripts/check-forge-loop.sh` 第 11 组 —— 回归防护断言（DI-02）
- `DESIGN.md` —— §10 规定的引用目标，断言其磁盘实存