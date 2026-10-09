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

fail=0
pass=0
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

# --- 汇总 ---
echo
echo "=============================="
echo "pass: $pass   fail: $fail"
if [ "$fail" -gt 0 ]; then
  echo "RESULT: FAIL"
  exit 1
fi
echo "RESULT: PASS"
exit 0