#!/usr/bin/env bash
# 检测用户已安装 skills 中与 phper666-git-* 功能重叠的同类 skill
# 通用功能类别匹配（不写死任何具体 skill 名）：
#   commit 类  → 名称/描述含 commit/message/conventional-commit/commitizen 等
#   worktree 类 → 名称/描述含 worktree
#   rollback 类 → 名称/描述含 rollback/revert/reset
# 用法：SKILLS_DIR=~/.claude/skills bash scripts/detect-git-conflicts.sh
# 退出码：0 = 无冲突；1 = 检测到潜在冲突（提示语气，不强制）
set -uo pipefail

SKILLS_DIR="${SKILLS_DIR:-$HOME/.config/opencode/skills}"

# 类别 → 关键词映射（正则，匹配名称/描述，忽略大小写）
declare -A CATEGORY_KEYWORDS=(
  [commit]='commit|message|conventional-?commit|commitizen'
  [worktree]='worktree'
  [rollback]='rollback|revert|reset'
)

# 聚合：所有已装 skill 目录中，读取 SKILL.md frontmatter 的 name/description 用于匹配
declare -A HITS=()
FOUND_ANY=0

# 排除目录名（误报源）：配置/管理类、review 类、查询历史类、测试类、工具名无关类
# 按目录名前缀/关键词排除（这些不是「生成 commit / 管理 worktree / git 回滚」的同类 skill）
EXCLUDE_BASE='arkcli-|open-code-review|release-smoke-test|commit-context|commit-history|oh-my-opencode|phper666-git-'
# 描述/名称里含这些词 → 视为非同类（配置/审查/查询语义）
EXCLUDE_DESC='review|config|usage|stats|history|context|test|audit|analy'

scan() {
  local cat="$1" kw="$2"
  local d
  for d in "$SKILLS_DIR"/*/; do
    [ -d "$d" ] || continue
    local base; base="$(basename "$d")"
    # 跳过自身 phper666-git-* + 排除误报目录
    case "$base" in phper666-git-*) continue ;; esac
    if echo "$base" | grep -qiE "$EXCLUDE_BASE"; then continue; fi
    local haystack=""
    if [ -f "$d/SKILL.md" ]; then
      # 只取 frontmatter（首尾 --- 之间），减少噪声
      haystack="$(awk '/^---$/{c++; next} c==1' "$d/SKILL.md" | head -c 2000)"
    fi
    # 描述含排除语义词 → 非同类
    if echo "$haystack" | grep -qiE "$EXCLUDE_DESC"; then continue; fi
    # 无 SKILL.md 也按目录名匹配
    haystack="$haystack $base"
    if echo "$haystack" | grep -qiE "$kw"; then
      local name=""
      [ -f "$d/SKILL.md" ] && name="$(awk '/^name:/{sub(/^name:[[:space:]]*/,""); print; exit}' "$d/SKILL.md")"
      name="${name:-$base}"
      HITS["$base"]="$cat|$name"
      FOUND_ANY=1
    fi
  done
}

for cat in "${!CATEGORY_KEYWORDS[@]}"; do
  scan "$cat" "${CATEGORY_KEYWORDS[$cat]}"
done

if [ "$FOUND_ANY" -eq 0 ]; then
  echo "[git-conflict] 未检测到与 phper666-git-* 功能相同的已装 skill"
  exit 0
fi

echo "[git-conflict] 检测到可能功能相同的已装 skill："
for base in "${!HITS[@]}"; do
  IFS='|' read -r cat name <<< "${HITS[$base]}"
  echo "  - ${name}（${cat} 类）"
done
echo "[git-conflict] 建议：卸载或停用上述 skill，避免触发冲突；保留则双保险兜底（团队模式默认用 phper666-git-*，用户显式指定才用其他）。"
echo "[git-conflict] 说明：部分命中 skill 可能与 phper666-git-* 定位不同（如 orchestrator 专用编排/其他框架组件），可按需共存，不强制卸载。"
exit 1
