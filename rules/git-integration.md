# ForgeLoop Git Integration Rules

## 1. Authority

ForgeLoop 的 Git 权威规则：

```text
Global Git Rules
```

本 Rule 是集成规则，不是替代规则。

---

## 2. No Second Git Policy

ForgeLoop 不定义独立：

```text
Branch Policy
Commit Convention
Merge Policy
Rebase Policy
Tag Policy
Push Policy
Remote Policy
```

这些由全局 Git Rules 决定。

---

## 3. Checkpoint

ForgeLoop Lifecycle 中的：

```text
Checkpoint
```

必须通过合法 Git Workflow 形成可靠版本边界。

---

## 4. Task Completion

标准关系：

```text
Task
↓
Implementation
↓
Verification
↓
Git Workflow
↓
Checkpoint
```

Checkpoint 的实际形式由全局 Git Rules 决定。

---

## 5. Before Git Mutation

任何可能改变 Git 状态的操作：

```text
commit
reset
rebase
merge
revert
checkout
branch
push
```

必须遵守全局 Git Rules。

---

## 6. Unexpected Git State

如果发现：

```text
Uncommitted Changes
Detached HEAD
Unexpected Branch
Conflicting Changes
Missing Checkpoint
```

必须先按照全局 Git Rules 处理。

ForgeLoop 不得擅自恢复 Git 状态。

---

## 7. Release

Release 所涉及：

```text
Commit
Tag
Push
Branch
```

均由全局 Git Rules 和 Version Management 管理。

ForgeLoop 只负责工作流编排。

---

## 8. Branch Lifecycle

本节规定 Agent 发起变更时的分支终态，不定义 Branch Naming、Commit Convention、Merge Policy、Tag Policy 或 Push Policy——这些仍由全局 Git Rules 决定（§2）。

每个 Agent 变更使用独立分支，格式沿用全局 `ai-git-workflow` §2.2：

```text
agent/<任务ID>-<短描述>
```

变更完成后，**本地分支与远程分支都必须删除**：

```text
本地分支 → 必须删除（硬要求）
远程分支 → 必须删除
```

两者都是硬要求，不存在「只删远程、保留本地」的例外。删除时机是 PR 合并之后。

远程分支通常由 `gh pr merge --delete-branch` 一并删除；本地分支在确认内容已进入 main 之后删除（用 `git branch -d`，必要时 `-D`）。

Squash 合并的分支无法通过 `git branch -d` 删除（无共同祖先）。判断内容是否已进入 main 应比较 tree hash，而非依赖祖先关系：

```bash
git rev-parse main^{tree}
git rev-parse <branch>^{tree}
```

两个 tree hash 一致即代表内容完全并入，此时删除是安全的。

主分支：

```text
main
```

不得直接向 main 推送 Agent 变更。

---

## 9. Commit Means Commit, Push, And Merge

用户说「提交」时，含义是完整落地一个变更：

```text
git add
  ↓
git commit
  ↓
push 分支
  ↓
开 PR
  ↓
squash 合并
  ↓
删除本地分支与远程分支
  ↓
本地 main 同步到 origin/main
```

具体规则：

```text
1. 「提交」= commit + push + 自动合并，不停留在本地 commit。

2. 「提交所有内容」= 同一轮把工作树中的全部改动（包括未跟踪文件）
   提交掉，不留尾巴。

3. 用户明确说「不用审核」时，跳过对抗式评审，直接走完上述流程。

4. 用户点名保护的路径（如 DESIGN.md）不得在该轮被改动，
   除非用户在本轮明确要求改它。
```

合并条件遵循 `ai-git-workflow` §5.2 的四项要求，评审默认为作者 Agent 自审。

---

## 10. File Naming Inconsistency

文档正文多处将设计文档写作：

```text
ForgeLoop.DESIGN.md
```

磁盘上的实际文件名为：

```text
DESIGN.md
```

引用时使用实际路径 `DESIGN.md`。按 `AGENTS.md` §5「Design Is The Single Authority」，统一的是引用方，文件名本身以磁盘现状为准。

---

## 11. Checkpoint Commit Hash 口径

本节规定 `DESIGN.md` §53 Checkpoint 的 `git_commit` 字段该记什么值。它是跨 Goal 规则，
不随 `.ai/` 的单 Goal 运行态文件重写而失效。

### 11.1 记 main 侧 commit

字段名按 `DESIGN.md` §53 的原字段名 `checkpoint.git.commit`，不改名、不扁平化为标量。

该字段记**合并至集成分支之后**的 commit。squash 合并 + 分支删除会使分支内 commit 从集成分支
历史消失，记分支内 commit 会让 §54 声明的 Rollback / Resume / Progress Tracking /
Version Comparison 四项用途失效。

集成分支名（当前为 `main`）属全局 Git Rules 的 Branch Policy 参数，本 Rule 不自行固定。

### 11.2 占位值与回填

squash 合并产生的新 commit 无法包含自身 hash，且合并发生在状态文件写入之后，因此
`git_commit` 在形成它的那个 commit 内无法自洽。约定见下方两行：

```text
形成 Checkpoint 的 commit → checkpoint.git.commit 写占位值 "pending: <taskID> merge"
下一 Task 的 commit       → 回填该 Checkpoint 在集成分支上的 hash
```

占位值词表统一为 `pending: <taskID> merge`。其它写法（如 `pending: xxx commit`、留空、
写 `unknown`）都不合法——恢复链读者需要能机械识别待回填状态。

回填的那一次提交必须同时更新 `.ai/version-state.yaml` 的 `git.head`，否则「当前在哪」
会出现两个不一致的 Git 事实（`checkpoint.git.commit` 与 `version-state.git.head`）。

### 11.3 逐 Checkpoint 配对

标量 `git_commit` 只承载最近一个已知 main 侧 hash。§54 的 Version Comparison 与
Progress Tracking 需要跨 Checkpoint 比对，因此 `.ai/development-status.yaml` 的
`checkpoint.history` 以列表形式逐 Checkpoint 固化 `id + git_commit` 配对，只追加不改写。

每个非占位值的锚点须在集成分支上真实可达（`git merge-base --is-ancestor`）。仅校验形状
不校验可达性，会让「悬空 hash」这类缺陷回归而不被发现——CP-001 记 `823615b`、
CP-004 记 `0f7fd4f` 正是此类，二者均已失联。结构化自检 8c 组（CK-12）承担该判据。
