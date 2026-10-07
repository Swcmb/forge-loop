#!/usr/bin/env bash
# ForgeLoop 结构化自检（详细设计 §3.6 第一类证据：结构化自检）
# 校验 SKILL.md frontmatter、references 完整性、reference 交叉引用可解析、
# 下层 Agent 齐备、上游副本 blob 未偏离登记指纹。
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