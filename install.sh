#!/usr/bin/env bash
# ai-workflow-skills 一键安装：克隆 + 链接 12 个 skill + 全局 AGENTS.md 导航段
# 用法：bash <(curl -fsSL https://raw.githubusercontent.com/phper666/ai-workflow-skills/main/install.sh)
# 可覆盖：SKILLS_DIR=~/.claude/skills 指定平台目录；REPO_URL=... 指定仓库
set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/phper666/ai-workflow-skills.git}"
SRC_DIR="${SKILLS_SRC_DIR:-$HOME/ai-workflow-skills}"
AGENTS="$HOME/.config/opencode/AGENTS.md"

# 平台选择：显式 SKILLS_DIR > 交互菜单 > 默认 opencode
if [ -z "${SKILLS_DIR:-}" ] && [ -t 0 ]; then
  echo "== 选择安装到哪个 agent 平台："
  echo "   1) opencode        (~/.config/opencode/skills/)  [默认]"
  echo "   2) Claude Code     (~/.claude/skills/)"
  echo "   3) Cursor          (~/.cursor/skills/)"
  echo "   4) 自定义目录"
  read -r -p "   输入 1-4（回车默认 1）: " CHOICE || true
  case "$CHOICE" in
    2) SKILLS_DIR="$HOME/.claude/skills" ;;
    3) SKILLS_DIR="$HOME/.cursor/skills" ;;
    4) read -r -p "   输入目录路径: " SKILLS_DIR ;;
    *) SKILLS_DIR="${SKILLS_DIR:-$HOME/.config/opencode/skills}" ;;
  esac
fi
SKILLS_DIR="${SKILLS_DIR:-$HOME/.config/opencode/skills}"
SKILLS=(phper666-teamflow-change-propagation phper666-teamflow-consensus-doc phper666-teamflow-consensus-scan phper666-teamflow-implement-discipline phper666-teamflow-lesson-deposit phper666-teamflow-story-to-contract phper666-teamflow-tech-design phper666-teamflow-workflow-setup phper666-git-commit phper666-git-worktree phper666-git-rollback phper666-git-pr)

echo "== 1/3 克隆/更新仓库"
if [ -f "templates/AGENTS.global.md" ] && ls phper666-teamflow-*/SKILL.md >/dev/null 2>&1; then
  SRC_DIR="$(pwd)"   # 已在仓库内运行（AI 直接安装场景），跳过克隆
  echo "   已在仓库内（${SRC_DIR}），跳过克隆"
elif [ -d "${SRC_DIR}/.git" ]; then
  echo "   已存在 ${SRC_DIR}，git pull 更新"
  git -C "${SRC_DIR}" pull --ff-only
else
  git clone "$REPO_URL" "$SRC_DIR"
fi

echo "== 2/3 链接 skills 到 $SKILLS_DIR"
mkdir -p "$SKILLS_DIR"
for s in "${SKILLS[@]}"; do
  ln -sfn "${SRC_DIR}/$s" "$SKILLS_DIR/$s"
done
echo "   linked ${#SKILLS[@]} 个 skill"

echo "== 2.5/3 冲突检测（git skills 同类冲突）"
if [ -f "$(dirname "$0")/scripts/detect-git-conflicts.sh" ]; then
  # 以当前仓库 scripts 为准；AI 在仓库内安装时用相对路径，外部安装用 SRC_DIR
  CONFLICT_SCRIPT="$(dirname "$0")/scripts/detect-git-conflicts.sh"
  [ -f "$CONFLICT_SCRIPT" ] || CONFLICT_SCRIPT="${SRC_DIR}/scripts/detect-git-conflicts.sh"
  SKILLS_DIR="$SKILLS_DIR" bash "$CONFLICT_SCRIPT" || true   # 提示语气，不阻断
else
  echo "   未找到冲突检测脚本，跳过"
fi

echo "== 3/3 AGENTS.md 导航段（幂等）"
if [ -f "$AGENTS" ] && grep -q "team-workflow:begin" "$AGENTS"; then
  echo "   已含 team-workflow 段，跳过"
else
  mkdir -p "$(dirname "$AGENTS")"
  cat "$SRC_DIR/templates/AGENTS.global.md" >> "$AGENTS"
  echo "   已追加到 $AGENTS"
fi

echo "== 完成。项目侧：跑 phper666-teamflow-workflow-setup（\"给这个项目接入研发工作流\"）"
