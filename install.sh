#!/usr/bin/env bash
# ai-workflow-skills 一键安装：克隆 + 链接 8 个 skill + 全局 AGENTS.md 导航段
# 用法：bash <(curl -fsSL https://raw.githubusercontent.com/phper666/ai-workflow-skills/main/install.sh)
# 可覆盖：SKILLS_DIR=~/.claude/skills 指定平台目录；REPO_URL=... 指定仓库
set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/phper666/ai-workflow-skills.git}"
SRC_DIR="${SKILLS_SRC_DIR:-$HOME/ai-workflow-skills}"
SKILLS_DIR="${SKILLS_DIR:-$HOME/.config/opencode/skills}"
AGENTS="$HOME/.config/opencode/AGENTS.md"
SKILLS=(phper666-teamflow-change-propagation phper666-teamflow-consensus-doc phper666-teamflow-consensus-scan phper666-teamflow-implement-discipline phper666-teamflow-lesson-deposit phper666-teamflow-story-to-contract phper666-teamflow-tech-design phper666-teamflow-workflow-setup)

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

echo "== 3/3 AGENTS.md 导航段（幂等）"
if [ -f "$AGENTS" ] && grep -q "team-workflow:begin" "$AGENTS"; then
  echo "   已含 team-workflow 段，跳过"
else
  mkdir -p "$(dirname "$AGENTS")"
  cat "$SRC_DIR/templates/AGENTS.global.md" >> "$AGENTS"
  echo "   已追加到 $AGENTS"
fi

echo "== 完成。项目侧：跑 phper666-teamflow-workflow-setup（\"给这个项目接入研发工作流\"）"
