#!/usr/bin/env bash
# ForgeLoop 结构化自检（详细设计 §3.6 第一类证据：结构化自检）
# 校验 SKILL.md frontmatter、references 完整性、reference 交叉引用可解析、
# 下层 Agent 齐备、上游副本 blob 未偏离登记指纹、部署副本与库副本一致、
# SKILL.md 承载 §105 五项职责。
# 退出码：0 = 全部通过；1 = 有检查项失败。
#
# 权威：DESIGN.md §105（文件清单基准）、ADR-004、ADR-006、ADR-001 §2 / ADR-005 §2。
# 注意：§81 的 8 文件清单是历史遗留，不作为校验基准（ADR-004 §6）。

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_DIR="$ROOT/skills/forge-loop"
REF_DIR="$SKILL_DIR/references"
AGENTS_DIR="/d/ai-configs/agents"
LIBRARY="/d/ai-configs/skills/skills"
# 集成分支：Checkpoint 锚点可达性（§54）与 §11.1 的「main 侧」都以它为准。
# 分支名属全局 Git Rules 的 Branch Policy 参数，不在本脚本内固定；可用环境变量覆盖。
INTEGRATION_BRANCH="${FORGELOOP_INTEGRATION_BRANCH:-main}"

fail=0
pass=0
skip=0
ok()   { printf '  [PASS] %s\n' "$1"; pass=$((pass+1)); }
bad()  { printf '  [FAIL] %s\n' "$1"; fail=$((fail+1)); }

echo "ForgeLoop 结构化自检"
echo "root: $ROOT"
echo

# --- 1. §105 权威 references 清单（第一阶段 10 个，audit-model.md 延后）---
echo "== 1. references 清单（基准 = DESIGN.md §105）=="
REQUIRED_REFS=(
  architecture.md lifecycle.md mvp-integration.md iterative-integration.md
  requirement-model.md task-model.md goal-mode.md version-control.md
  evidence-model.md recovery.md
)
for f in "${REQUIRED_REFS[@]}"; do
  if [ -s "$REF_DIR/$f" ]; then ok "$f 存在且非空"; else bad "$f 缺失或为空"; fi
done
if [ -e "$REF_DIR/audit-model.md" ]; then
  bad "audit-model.md 不应存在（随 §109 的 L/M 延后，ADR-004）"
else
  ok "audit-model.md 未出现（符合第一阶段范围）"
fi

# --- 2. SKILL.md 与 frontmatter ---
echo
echo "== 2. SKILL.md 与 frontmatter =="
if [ -s "$SKILL_DIR/SKILL.md" ]; then ok "SKILL.md 存在且非空"; else bad "SKILL.md 缺失或为空"; fi
if head -1 "$SKILL_DIR/SKILL.md" | grep -q '^---$'; then
  ok "frontmatter 分隔符正确"
else
  bad "frontmatter 起始分隔符缺失"
fi
for key in name description; do
  if awk 'NR==1{next} /^---$/{exit} /^'"$key"':/{found=1} END{exit !found}' "$SKILL_DIR/SKILL.md"; then
    ok "frontmatter 含 $key"
  else
    bad "frontmatter 缺 $key"
  fi
done
if grep -q '^version:' "$SKILL_DIR/SKILL.md"; then
  bad "frontmatter 含 version 字段（B-03 未解除，不得自定版本号）"
else
  ok "frontmatter 无 version 字段（符合 B-03 约束）"
fi

# --- 3. reference 交叉引用可解析 ---
echo
echo "== 3. reference 交叉引用可解析 =="
# 运行期工件与外部文档不是 reference，其引用不纳入本项校验
RUNTIME_ARTIFACTS="source-index.md tasks.md compaction-probe.md skills-provenance.md"
mapfile -t KNOWN < <(cd "$REF_DIR" && ls *.md 2>/dev/null)
broken=0
for ref in "${KNOWN[@]}"; do
  while read -r cited; do
    [ -z "$cited" ] && continue
    [ "$cited" = "$ref" ] && continue
    case " $RUNTIME_ARTIFACTS " in *" $cited "*) continue ;; esac
    if [ ! -f "$REF_DIR/$cited" ]; then
      bad "$ref 引用了不存在的 reference：$cited"
      broken=$((broken+1))
    fi
  done < <(grep -o '`[a-z0-9-]*\.md`' "$REF_DIR/$ref" | tr -d '`' | sort -u)
done
[ "$broken" -eq 0 ] && ok "reference 交叉引用全部可解析"

# --- 4. 下层 Agent 齐备（ADR-006：规范位置 D:\ai-configs\agents） ---
echo
echo "== 4. 下层 Agent（ADR-006）=="
for a in code-explorer code-architect code-reviewer; do
  if [ -s "$AGENTS_DIR/$a.md" ]; then ok "$a 已安装"; else bad "$a 缺失（$AGENTS_DIR）"; fi
done

# --- 5. 上游副本 blob 未偏离登记指纹（ADR-001 §2 / ADR-005 §2）---
echo
echo "== 5. 上游来源指纹（默认 git hash-object，含 CRLF 归一化）=="
check_blob() {
  local name="$1" dir="$2" expected="$3"
  if [ ! -f "$dir/SKILL.md" ]; then
    bad "$name 副本缺失：$dir"
    return
  fi
  local actual
  actual="$(cd "$(dirname "$dir")" && git hash-object "$dir/SKILL.md" 2>/dev/null)"
  if [ "$actual" = "$expected" ]; then
    ok "$name blob 与登记指纹一致"
  else
    bad "$name blob 偏离：实际 $actual / 登记 $expected"
  fi
}
check_blob "iterative-development" "$LIBRARY/iterative-development" \
  "cf1011224c27c503d9e1fae3386c8e5494fd4755"
check_blob "mvp" "$LIBRARY/mvp" \
  "a42a7996f5befe5cc8389ba41aed86b72da0f9f1"

# --- 6. 权威源码与库部署目标一致（ADR-003 §1/§4）---
# 比较对象 = ForgeLoop 仓库 skills/forge-loop/（权威源码）
#         vs D:\ai-configs\skills\skills\forge-loop/（manage-skills 部署分发目标）
# 判据：两个仓库 EOL 契约不同（ForgeLoop eol=lf；库 core.autocrlf=true 且无 .gitattributes），
# 直接按字节比对会因行尾差异误报。git hash-object 在该库仓库中对已跟踪/未跟踪文件的
# 归一化行为不一致（实测不可靠），故此处按「去 CR 归一后的内容摘要」比对——行为确定，
# EOL 差异不计为漂移，真实内容差异必被捕获。
# 注：~/.claude/skills/forge-loop 是指向库部署目标的符号链接，非独立副本，不在此比对。
echo
echo "== 6. 仓库源码 vs 库部署目标一致性（ADR-003）=="
DEPLOY_TARGET="$LIBRARY/forge-loop"
if [ ! -d "$DEPLOY_TARGET" ]; then
  bad "库部署目标缺失：$DEPLOY_TARGET（未部署，manage-skills deploy 未执行）"
else
  mapfile -t SRC_MD < <(cd "$SKILL_DIR" && find . -name '*.md' | sed 's|^\./||' | sort)
  mapfile -t DEP_MD < <(cd "$DEPLOY_TARGET" && find . -name '*.md' | sed 's|^\./||' | sort)
  set_mismatch=0
  # 集合判据：先比元素个数，再逐元素比，避免词拼接相等把不同集合判为一致
  if [ "${#SRC_MD[@]}" -eq 0 ]; then
    bad "仓库源码无可校验的 .md 文件（$SKILL_DIR）"
  elif [ "${#SRC_MD[@]}" -ne "${#DEP_MD[@]}" ]; then
    bad "文件数量不一致：源码 ${#SRC_MD[@]} 个 / 部署目标 ${#DEP_MD[@]} 个"
    set_mismatch=$((set_mismatch+1))
  else
    for i in "${!SRC_MD[@]}"; do
      if [ "${SRC_MD[$i]}" != "${DEP_MD[$i]}" ]; then
        bad "文件集合不一致：第 $((i+1)) 项 源码 ${SRC_MD[$i]} / 部署目标 ${DEP_MD[$i]}"
        set_mismatch=$((set_mismatch+1))
      fi
    done
    [ "$set_mismatch" -eq 0 ] && ok "文件集合一致（${#SRC_MD[@]} 个 .md）"
  fi
  # 归一化摘要：去掉 CR 后取 sha256，跨 EOL 契约稳定
  norm_sha() { tr -d '\r' < "$1" | sha256sum | awk '{print $1}'; }
  drift=0
  for f in "${SRC_MD[@]}"; do
    if [ ! -f "$DEPLOY_TARGET/$f" ]; then
      bad "库部署目标缺少文件：$f"
      drift=$((drift+1))
      continue
    fi
    s="$(norm_sha "$SKILL_DIR/$f")"
    d="$(norm_sha "$DEPLOY_TARGET/$f")"
    if [ "$s" != "$d" ]; then
      bad "库部署目标漂移：$f（源码 $s / 部署 $d）"
      drift=$((drift+1))
    fi
  done
  [ "$drift" -eq 0 ] && [ "${#SRC_MD[@]}" -gt 0 ] && [ "$set_mismatch" -eq 0 ] && ok "全部 .md 归一化内容一致（EOL 差异不计）"
fi

# --- 7. SKILL.md 承载 §105 五项职责（ADR-004 核心判据）---
# 仅校验章节骨架标题存在，不校验正文非空。
echo
echo "== 7. SKILL.md §105 五项职责锚点 =="
for anchor in "Routing" "Core Rules" "Workflow" "Reference Loading" "Output Contract"; do
  if grep -qE "^## [0-9]+\. ${anchor}" "$SKILL_DIR/SKILL.md"; then
    ok "SKILL.md 含职责章节：$anchor"
  else
    bad "SKILL.md 缺职责章节：$anchor"
  fi
done

# --- 8. .ai/ 运行状态落盘契约（详细设计 §3.5）---
# 校验 §3.5 定义的必填段存在；只校验骨架键，值域由 §55/§56 及各 reference 定义。
echo
echo "== 8. .ai/ 运行状态落盘契约（详细设计 §3.5）=="
AI_DIR="$ROOT/.ai"
check_keys() {
  local file="$1"; shift
  local missing=0 k
  if [ ! -f "$file" ]; then
    bad "状态文件缺失：${file#$ROOT/}"
    return
  fi
  for k in "$@"; do
    if grep -qE "^${k}:" "$file"; then
      ok "${file#$ROOT/} 含必填段：$k"
    else
      bad "${file#$ROOT/} 缺必填段：$k"
      missing=$((missing+1))
    fi
  done
  if [ "$missing" -gt 0 ]; then bad "${file#$ROOT/} 有 $missing 个必填段缺失"; fi
  return 0
}
# 叶子字段断言：段名 → 其下必填叶子键（一级缩进）。§98 Goal Resume 从这些叶子取
# Checkpoint 双写所需的 git.head 等值，缺失要到恢复时刻才暴露。
check_leaf() {
  local file="$1" parent="$2" leaf="$3"
  if grep -qE "^${parent}:" "$file" && grep -qE "^  ${leaf}:" "$file"; then
    ok "${file#$ROOT/} ${parent}.${leaf} 存在"
  else
    bad "${file#$ROOT/} 缺叶子字段：${parent}.${leaf}"
  fi
}
check_keys "$AI_DIR/development-status.yaml" goal phase mode task iteration checkpoint blockers verification
# version-state.yaml 的 §55 schema：goal.id / mvp.version / spec.version / plan.revision
# / iteration.current / git.branch·head·clean / project.version
check_keys "$AI_DIR/version-state.yaml" project goal mvp spec plan iteration git
check_leaf "$AI_DIR/version-state.yaml" iteration current
check_leaf "$AI_DIR/version-state.yaml" git branch
check_leaf "$AI_DIR/version-state.yaml" git head
check_leaf "$AI_DIR/version-state.yaml" git clean

# --- 8c. Checkpoint 字段承载（§53 六字段 + §54 逐 CP 配对与锚点可达）---
# §53 的 checkpoint 字段名为 goal.id / iteration.id / task.id / git.commit /
# spec.version / progress.requirements。AGENTS.md §5 规定 Design 是唯一权威，故此处
# 按 §53 原字段名断言，不使用自定义名（DI-09：T-12 初稿曾落地 task.current 与标量
# git_commit，均偏离 §53，已在本轮更正）。
# §54 的 Version Comparison / Progress Tracking 依赖逐 Checkpoint 的 id↔git.commit
# 配对（checkpoint.history）；§53/§54 声明的 Rollback 用途进一步要求每个锚点在集成分支
# 上真实可达——只校验形状不校验可达性，会让「悬空 hash」这类缺陷回归而不被发现
# （CP-001 记 823615b、CP-004 记 0f7fd4f 正是此类，二者均不在 main 历史）。
# CK-09 的骨架键检查只断言顶层段，断言不到这些叶子——T-12 初稿正因此高估了 CK-09
# 的覆盖范围。故此处按 YAML 结构（路径解析）而非文本匹配逐字段断言。
echo
echo "-- 8c. Checkpoint 字段承载（§53 六字段 + §54 逐 CP 配对与锚点可达）--"
if python -c "import yaml" 2>/dev/null; then
  ck8c="$(python - "$AI_DIR/development-status.yaml" "$AI_DIR/version-state.yaml" "$AI_DIR" <<'PYEOF'
import re, sys, yaml

def load(path):
    with open(path, encoding='utf-8') as fh:
        return yaml.safe_load(fh) or {}

def dig(node, *path):
    for key in path:
        if not isinstance(node, dict):
            return None
        node = node.get(key)
    return node

ds = load(sys.argv[1])
vs = load(sys.argv[2])
ai_dir = sys.argv[3]

checks = [
    ("checkpoint.id", dig(ds, 'checkpoint', 'id')),
    ("checkpoint.goal.id", dig(ds, 'checkpoint', 'goal', 'id')),
    ("checkpoint.iteration.id", dig(ds, 'checkpoint', 'iteration', 'id')),
    ("checkpoint.task.id", dig(ds, 'checkpoint', 'task', 'id')),
    ("checkpoint.git.commit", dig(ds, 'checkpoint', 'git', 'commit')),
    ("checkpoint.spec.version", dig(ds, 'checkpoint', 'spec', 'version')),
    ("checkpoint.progress.requirements.total", dig(ds, 'checkpoint', 'progress', 'requirements', 'total')),
    ("checkpoint.progress.requirements.verified", dig(ds, 'checkpoint', 'progress', 'requirements', 'verified')),
    ("checkpoint.history", dig(ds, 'checkpoint', 'history')),
]

def empty(value):
    return value is None or value == '' or value == {} or value == []

for label, value in checks:
    verdict = "FAIL" if empty(value) else "PASS"
    print("%s\t%s 存在且非空（§53）" % (verdict, label))

# §54：逐 CP 配对的每一项须同时含 id 与 git_commit；锚点须在集成分支上真实可达。
# 占位值（pending: <taskID> merge）按 rules/git-integration.md §11.2 豁免可达性校验，
# 因为它的 hash 尚未产生；该豁免本身受约束——占位值必须匹配 §11.2 的词表。
history = dig(ds, 'checkpoint', 'history')
if not isinstance(history, list) or not history:
    print("FAIL\tcheckpoint.history 是非空列表（§54 逐 CP 配对锚点）")
else:
    print("PASS\tcheckpoint.history 是非空列表（§54 逐 CP 配对锚点）")
    broken = [i for i, item in enumerate(history)
              if not isinstance(item, dict)
              or empty(item.get('id')) or empty(item.get('git_commit'))]
    if broken:
        print("FAIL\tcheckpoint.history 每项须同时含 id 与 git_commit（缺失项：%s）"
              % ",".join(str(i) for i in broken))
    else:
        print("PASS\tcheckpoint.history 每项须同时含 id 与 git_commit")
        # 输出形如 "ANCHOR<TAB><index><TAB><id><TAB><hash>"，由 bash 侧跑 git 校验可达性。
        # python 侧不直接调 git，保持判据与 git 命令分离，便于测试时替换。
        placeholder = re.compile(r'^pending: [A-Za-z0-9._-]+ merge$')
        for idx, item in enumerate(history):
            value = str(item.get('git_commit'))
            if placeholder.match(value):
                print("PASS\tcheckpoint.history[%d] %s 的 git_commit 为 §11.2 占位值，"
                      "hash 尚未产生，豁免可达性校验" % (idx, item.get('id')))
            elif re.match(r'^[0-9a-f]{7,40}$', value):
                print("ANCHOR\t%d\t%s\t%s" % (idx, item.get('id'), value))
            else:
                print("FAIL\tcheckpoint.history[%d] %s 的 git_commit 既非 §11.2 占位值"
                      "也非 hex hash：%s" % (idx, item.get('id'), value))

# CK-14：version-state.git.head 须是集成分支上真实可达的 commit。
# CK-09 的 check_leaf 只断言该键存在，不校验其值——V-07 记录的正是这类缺陷：
# git.head 曾被误设为 PR #11 的分支头 44d9e4f，该 commit 不在集成分支历史，
# 恢复链读者据此得出的「当前在哪」是错的，而全部既有判据仍全绿。
# 与 checkpoint.git.commit 不同，git.head 不接受 §11.2 占位值：后者因 squash 语义
# 无法自含自身 hash（这是结构性约束），而 git.head 指向的是**已合并**的 commit，
# 永远可被已知。任何非 hex 值都判 FAIL。
head_value = dig(vs, 'git', 'head')
if empty(head_value):
    print("FAIL\tversion-state.git.head 缺失，§98 恢复链无法定位当前位置")
elif re.match(r'^[0-9a-f]{7,40}$', str(head_value)):
    print("HEAD\t%s" % head_value)
else:
    print("FAIL\tversion-state.git.head 必须是集成分支上真实可达的 hex commit hash，实际为：%s"
          % head_value)

# CK-13：checkpoint.progress.requirements 的计数须与 requirement-matrix.yaml 的
# status 实际分布一致。两处各自手写时极易漂移（本 Task 落地时 verified 写成 8 而
# 实际为 7），恢复链读者据 checkpoint.progress 判断进度时会得到错误结论。
import glob, os
matrix_paths = sorted(glob.glob(os.path.join(ai_dir, '*', 'requirement-matrix.yaml')))
declared = dig(ds, 'checkpoint', 'progress', 'requirements')
if not matrix_paths:
    print("FAIL\t未找到 .ai/*/requirement-matrix.yaml（CK-13 无法核对 progress 计数）")
else:
    for path in matrix_paths:
        matrix = load(path)
        rel = os.path.relpath(path, os.path.dirname(os.path.dirname(path)))
        statuses = [v.get('status') for k, v in sorted(matrix.items())
                    if isinstance(v, dict) and str(k).startswith('REQ-')]
        if not statuses:
            print("FAIL\t%s 未解析出任何 REQ- 条目的 status" % rel)
            continue
        # 四个键全部核对：total / verified / reviewing / pending 与被校验字段同属一处
        # 手写映射，只校验其中两个等于给另外两个留了漂移口子（M-3）。
        actuals = [('total', len(statuses))]
        for name in ('VERIFIED', 'REVIEWING', 'PENDING'):
            actuals.append((name.lower(), sum(1 for s in statuses if s == name)))
        for field, actual in actuals:
            claimed = (declared or {}).get(field)
            if claimed != actual:
                print("FAIL\t%s: checkpoint.progress.requirements.%s 声明 %r，"
                      "实际 %d 条（status 分布：%s）"
                      % (rel, field, claimed, actual,
                         ", ".join("%s=%d" % (s, statuses.count(s))
                                   for s in sorted(set(statuses)))))
            else:
                print("PASS\tcheckpoint.progress.requirements.%s 与 %s 一致（%d）"
                      % (field, rel, actual))

PYEOF
)"
  ck8c_py_rc=$?
  # 区分两种「产出不足」：
  #   (a) python 崩溃/抛异常 → rc 非 0，stdout 为空，全部判据静默消失。必须拦截，
  #       否则汇总会无标记地少掉 8c 组的全部断言（Test Gate 证据条数无解释地漂移）。
  #   (b) python 正常退出但状态文件有缺陷 → rc 为 0，行数天然减少。**不得**拦截：
  #       那些行本身就是精确的 FAIL 诊断（N2/N3 的报错信息由此保留）。早前的实现用
  #       行数下界统一拦截，把 (b) 误报为「判据静默失效」并清空输出，吞掉真实诊断。
  if [ "$ck8c_py_rc" -ne 0 ]; then
    bad "8c 组内嵌 python 异常退出（rc=$ck8c_py_rc）——判据未产出，全部 8c 断言缺失"
    ck8c=""
  fi
  # Windows 上 python 的文本模式 stdout 会把 \n 翻译为 \r\n，末列字段因此带尾随 \r，
  # 使 git 收到 "bab31db\r" 而判定为不可达。此处统一剥离 CR 再消费。
  ck8c="$(printf '%s\n' "$ck8c" | tr -d '\r')"
  # 集成分支必须先存在：分支名写错时 git 退出码是 128，若不单独判别，6 条锚点会被
  # 一并误报为「不可达」，把环境配置错误伪装成状态文件缺陷。
  anchor_branch_ok=1
  if [ -n "$ck8c" ] && ! git -C "$ROOT" rev-parse --verify --quiet "$INTEGRATION_BRANCH" >/dev/null 2>&1; then
    bad "集成分支 $INTEGRATION_BRANCH 在 $ROOT 不存在——跳过 §54 锚点可达性校验（环境配置错误，非状态文件缺陷）"
    anchor_branch_ok=0
  fi
  while IFS="$(printf '\t')" read -r verdict f1 f2 f3; do
    [ -z "$verdict" ] && continue
    if [ "$verdict" = "HEAD" ]; then
      # version-state.git.head 的可达性（§98 Resume 的定位前提）
      if [ "$anchor_branch_ok" -eq 0 ]; then
        continue
      fi
      if git -C "$ROOT" merge-base --is-ancestor "$f1" "$INTEGRATION_BRANCH" 2>/dev/null; then
        ok "version-state.git.head $f1 在 $INTEGRATION_BRANCH 上可达（§98 Resume 定位前提）"
      else
        bad "version-state.git.head $f1 不在 $INTEGRATION_BRANCH 历史——§98 恢复链据此定位到的位置是错的"
      fi
      continue
    fi
    if [ "$verdict" = "ANCHOR" ]; then
      # 逐条验证锚点在集成分支上可达（§54 的 Rollback/Resume/Progress Tracking 依赖它）
      if [ "$anchor_branch_ok" -eq 0 ]; then
        continue    # 分支不存在时不再逐条判定，避免把环境配置错误伪装成锚点不可达
      fi
      if git -C "$ROOT" merge-base --is-ancestor "$f3" "$INTEGRATION_BRANCH" 2>/dev/null; then
        ok "checkpoint.history[$f1] $f2 的锚点 $f3 在 $INTEGRATION_BRANCH 上可达（§54）"
      else
        bad "checkpoint.history[$f1] $f2 的锚点 $f3 不在 $INTEGRATION_BRANCH 历史——§54 的 Rollback/Resume/Progress Tracking 对该项失效"
      fi
      continue
    fi
    if [ "$verdict" = "PASS" ]; then
      ok "$f1"
    else
      bad "$f1"
    fi
  done <<< "$ck8c"
else
  skip=$((skip+1))
  echo "  [SKIP] python/PyYAML 不可用，跳过 §53 Checkpoint 字段承载校验"
fi

# 状态文件必须是可解析、且解析出非空映射的合法 YAML——恢复链（§98 Goal Resume）
# 直接读取这些文件。语法错误、空文件（safe_load 返回 None）、仅注释、裸标量
# 都会让恢复链静默失效，故一律判 FAIL。仅校验骨架键无法捕获这些缺陷。
# python+PyYAML 可用时执行解析校验；不可用时降级跳过（骨架键检查已在上面完成），
# 跳过计入 skip 并在汇总行显示，使降级在 Test Gate 证据中留痕。
echo
echo "-- 8b. 状态文件 YAML 可解析性（恢复链前置）--"
if python -c "import yaml" 2>/dev/null; then
  # 枚举 .ai/*/evidence.yaml（§3.5 的 <feature> 为参数，不写死具体阶段目录）
  shopt -s nullglob
  evidence_files=("$AI_DIR"/*/evidence.yaml)
  # 枚举 .ai/ 下全部 YAML（含 requirement-matrix.yaml / mvp-scope.yaml）。
  # 这两个文件承载 §109 的 B（Requirement Extraction）与 C（MVP Scope）两项能力，
  # 此前不在校验范围内：requirement-matrix.yaml 的 AC 描述与 mvp-scope.yaml 的
  # "pending: B-03" 都因含裸冒号而无法被 YAML 解析，缺陷因此长期未被发现——
  # 直到 CK-13 首次加载 requirement-matrix.yaml 才暴露。恢复链（§98）与 Audit
  # （§66）都要读取这些文件，故纳入 8b 全量校验。
  all_yaml=("$AI_DIR"/*.yaml "$AI_DIR"/*/*.yaml)
  shopt -u nullglob
  state_files=("$AI_DIR/development-status.yaml" "$AI_DIR/version-state.yaml" \
               "$AI_DIR/verification-state.yaml")
  seen_rel=" "          # 前后哨兵空格，使 *" $rel "* 模式可靠匹配
  for sf in "${state_files[@]}" "${evidence_files[@]}" "${all_yaml[@]}"; do
    rel="${sf#$ROOT/}"
    case "$seen_rel" in
      *" $rel "*) continue ;;   # 已被前面的 state_files / evidence_files 覆盖
    esac
    seen_rel="$seen_rel$rel "
    if [ ! -f "$sf" ]; then
      bad "$rel 缺失（恢复链将无法读取）"
      continue
    fi
    if python -c "import yaml,sys; d=yaml.safe_load(open(sys.argv[1],encoding='utf-8')); sys.exit(0 if isinstance(d,dict) and d else 1)" "$sf" 2>/dev/null; then
      ok "$rel YAML 解析通过且为非空映射"
    else
      bad "$rel YAML 解析失败或非空映射（空/仅注释/裸标量/语法错误均属此类）"
    fi
  done
  if [ "${#evidence_files[@]}" -eq 0 ]; then
    bad ".ai/*/evidence.yaml 未找到（§3.5 要求每个 feature 目录含 evidence.yaml）"
  fi
else
  skip=$((skip+1))
  echo "  [SKIP] python/PyYAML 不可用，跳过 YAML 解析校验（骨架键检查已覆盖结构存在性）"
fi

# --- 8d. CK-15 未加引号的冒号空格标量 ---
# 该缺陷已在 .ai/ 下发生四次，每次都要等 8b 报「解析失败」才被发现，而 8b 不指出成因。
# 本组按文本扫描，不解析 YAML：文件一旦语法错误，8c 的内嵌 python 会先行崩溃，
# 放在那里就永远拦不到它要拦的那一类输入。
echo
echo "-- 8d. CK-15 未加引号的冒号空格标量 --"
if python -c "import re" 2>/dev/null; then
  ck15="$(python - "$AI_DIR" <<'PYEOF'
import glob, os, re, sys

ai_dir = sys.argv[1]
colon_space = ': '

# 键名允许非 ASCII：.ai/ 的值全是中文，键名将来也可能是中文，
# 用 [A-Za-z_] 限定会把中文键整行漏掉。
key_re = re.compile(r'^([^\s:#]+)[ \t]*:[ \t]+(.*)$')
block_start = re.compile(r'^[|>][-+0-9]*\s*$')
list_mark = re.compile(r'^-\s+')
# 流映射内部的条目分隔：逗号后紧跟「键: 」才算一个新条目，
# 避免把值内部的逗号误切。
flow_split = re.compile(r',\s+(?=[^\s:#]+[ \t]*:)')

def plain_scalar_bad(value):
    # 未加引号的纯标量值内含「冒号加空格」时，YAML 解析会失败。
    # 时刻字面量（12:30）与 URL（https://）的冒号后面跟的是数字或斜杠，
    # 本就不构成「冒号加空格」，因此不为它们设任何豁免——早前的豁免用整串子串
    # 搜索，反而让「值里前面有个时刻、后面又有裸冒号」的写法整行漏网。
    v = value.strip()
    if not v:
        return False
    # 带锚点或标签前缀的流集合（&anchor {…} / !!map {…}）首字符是 & 或 !，
    # 剥掉前缀后再判定定界符，否则会被当成纯标量而在其内部误报。
    m_anchor = re.match(r'^[&!][^\s]*\s+', v)
    if m_anchor:
        v = v[m_anchor.end():].strip()
        if not v:
            return False
    if v[0] == '{':
        inner = v.strip()
        inner = inner[1:-1] if inner.endswith('}') else inner[1:]
        for seg in flow_split.split(inner):
            seg = seg.strip()
            if seg.startswith('{'):
                seg = seg[1:]
            m = key_re.match(seg)
            if m and plain_scalar_bad(m.group(2)):
                return True
        return False
    if v[0] in '\'"[':
        return False
    return colon_space in v.split(' #', 1)[0]

for path in sorted(glob.glob(os.path.join(ai_dir, '*.yaml')) +
                  glob.glob(os.path.join(ai_dir, '*', '*.yaml'))):
    rel = os.path.relpath(path, os.path.dirname(os.path.dirname(path)))
    bad = []
    block_indent = None
    with open(path, encoding='utf-8') as fh:
        for lineno, raw in enumerate(fh, 1):
            line = raw.rstrip('\n').rstrip('\r')
            stripped = line.strip()
            if block_indent is not None:
                # 块标量内的空行不重置块态——YAML 里空行仍属块内容，
                # 若在此重置，紧随空行之后的合法内容行会被误判。
                if not stripped or (len(line) - len(line.lstrip())) > block_indent:
                    continue
                block_indent = None
            if not stripped or stripped.startswith('#'):
                continue
            work = line.strip()
            indent = len(line) - len(line.lstrip())
            m = key_re.match(work)
            if not m:
                # 列表项：剥掉 "- " 后再判。- {id: ..., note: ...} 是本仓库
                # checkpoint.history 与 verification-state gates 的实际写法，
                # 漏判它等于漏掉最高频的形态。
                lm = list_mark.match(work)
                if lm:
                    rest = work[lm.end():]
                    if rest.startswith('{'):
                        if plain_scalar_bad('{' + rest):
                            bad.append((lineno, rest.split(' #', 1)[0][:60].rstrip()))
                        continue
                    m = key_re.match(rest)
            if not m:
                continue
            value = m.group(2).strip()
            if block_start.match(value):
                block_indent = indent
                continue
            if not value:
                continue
            if plain_scalar_bad(value):
                bad.append((lineno, value.split(' #', 1)[0][:60].rstrip()))
    for lineno, body in bad:
        print("FAIL\t%s\t%d\t%s" % (rel, lineno, body))
    print("%s\t%s" % ("SUMOK" if not bad else "SUMBAD", rel))
PYEOF
)"
  ck15_rc=$?
  # 崩溃守卫：命令替换只收 stdout，traceback 走 stderr。若 python 崩溃，ck15 只剩
  # 崩溃前已 flush 的部分，其余文件零断言而汇总仍显示 PASS——与 8c 曾修过的
  # 「判据静默消失」同类。rc 非 0 即判 FAIL 并清空输出。
  if [ "$ck15_rc" -ne 0 ]; then
    bad "8d 组内嵌 python 异常退出（rc=$ck15_rc）——判据未产出，全部 CK-15 断言缺失"
    ck15=""
  fi
  ck15="$(printf '%s\n' "$ck15" | tr -d '\r')"
  while IFS="$(printf '\t')" read -r kind rel lineno body; do
    [ -z "$kind" ] && continue
    if [ "$kind" = "FAIL" ]; then
      bad "$rel 第 $lineno 行：未加引号的标量值内含冒号加空格，YAML 解析会失败（CK-15）——$body"
    elif [ "$kind" = "SUMOK" ]; then
      ok "$rel 无未加引号的冒号空格标量（CK-15）"
    elif [ "$kind" = "SUMBAD" ]; then
      bad "$rel 存在未加引号的冒号空格标量（CK-15），行号见上"
    fi
  done <<< "$ck15"
else
  skip=$((skip+1))
  echo "  [SKIP] python 不可用，跳过 CK-15"
fi

# --- 汇总 ---
echo
echo "=============================="
echo "pass: $pass   fail: $fail   skip: $skip"
if [ "$fail" -gt 0 ]; then
  echo "RESULT: FAIL"
  exit 1
fi
echo "RESULT: PASS"
exit 0
