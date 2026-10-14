# FL-003 Goal 收口（DI-02 处置完成）

依据：`DESIGN.md` §94（Final Completion Model）在本 Goal 范围内的适用项、
项目 `AGENTS.md` §15（Completion）、`rules/git-integration.md` §10（处置口径的唯一出处）。
时点：2026-10-13。

本 Goal 与 FL-002 分工不同：FL-002 交付能力（§109 的 A～N），FL-003 不引入新能力，
只处置 FL-002 遗留的已登记缺陷 DI-02。收口审计据此只核对该缺陷的处置完整性，
不重复 §94 九项的能力交付判定——那属 `doc/audits/phase2/goal-closeout.md` 的范围。

## 本 Goal 的完成模型

| 条件 | 结论 | 取证 |
| :--- | :--- | :--- |
| All Required Requirements Verified | PASS | 本 Goal 无新增 Requirement；T-31 的 Requirement 是「工程目标（一致性）」，证据见 `.ai/forgeloop-phase3/evidence.yaml` |
| All Acceptance Criteria Passed | PASS | T-31 无独立 AC（缺陷处置类 Task）；判据落为自检第 11 组的四条负向验证 |
| Tests Passed | PASS | `bash scripts/check-forge-loop.sh` → 110 pass / 0 fail / 0 skip，exit 0 |
| Code Review Passed | PASS | PR #22 附独立 `code-reviewer` 六维评审记录：2 MAJOR + 5 MINOR + 1 建议，全部已修复并复验 |
| Build Passed | PASS | 本仓库无构建工具链；判据 = 自检脚本 exit 0（与 FL-002 同一口径） |
| Runtime Passed | PASS | 判据在仓库内、库部署目标未受影响（本 Task 未改动 `skills/forge-loop/`） |
| Final Audit Passed | PASS | 见下「处置完整性核对」 |
| Version Consistent | PASS | 本 Goal 无版本变更，沿用 `VERSION` = 1.0.0 与 `v1.0.0` tag |
| Git State Valid | PASS | CK-14 锚点可达性、CK-16/CK-17 跨文件一致性 |

## 处置完整性核对

DI-02 的五类处置是否覆盖全部命中：

| 类别 | 命中数 | 覆盖率 | 验证方式 |
| :--- | :-- | :-- | :--- |
| 活引用 | 12 | 全部改写 | 第 11 组扫描断言「白名单外零命中」 |
| 规则与说明 | 2 | 全部改写 | §10 与 `CLAUDE.md` 各保留 1 处历史说明，属有意保留 |
| 历史记录 | 19 | 全部保留并加注记 | 白名单按路径豁免；注记逐文件可查 |
| 判据自身 | 2 | 全部按设计保留 | 白名单含 `scripts/check-forge-loop.sh` 与本 Goal 的 evidence |

落盘状态实测：白名单外活引用命中数 **0**；白名单内保留 23 处，逐处登记在脚本的 `DI02_BUDGET_*`
变量中并按次数双向校验。「入口基线 31 处」与「落盘保留 23 处」测的不是同一件事，不应相加。

## 判据的长期价值

DI-02 原先是「一次性改对」——改完即失去防护。本次把处置固化为可执行断言：
旧写法重新出现在活引用文档中即 `exit 1`。

判据自身的失效模式与被断言对象的失效模式同等重要。四条负向覆盖：
十条负向各 `exit 1`、复原后均 `exit 0`。除「有违规会不会红」外，另覆盖两类**判据自身失效**：

1. 白名单文件注入（`CLAUDE.md` / `git-integration.md` / `CHANGELOG.md`）——整文件豁免曾让这三处注入全部静默 PASS，改为按次数预算后拦截；
2. 预算少于实际（删掉 CHANGELOG 的历史说明）——双向校验使预算过时显式变红，阈值不会悄悄放宽；
3. 扫描零命中（复制到非 git 目录运行）——git 不可用时「零命中」不等于「无违规」。

另有两条针对**范围**：白名单文件移出白名单路径即判 FAIL（白名单按路径而非内容生效）；
新增受控文件 `Makefile`（无文档类扩展名且未显式豁免）即判 FAIL（防止将来新增格式静默漏检）。

## 结论

Goal FL-003 收口。DI-02 从「已登记的已知不一致」变为「有断言防护的既定约定」。
`verification.overall` 维持 `complete`——本 Goal 未引入新能力，不改变 FL-002 的收口判定，
但新增了一条持续生效的回归防护断言。