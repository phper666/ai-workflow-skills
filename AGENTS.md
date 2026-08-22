# ai-workflow-skills — 仓库导航（给 AI 代理）

本仓库是 **12 个 phper666-\* skills 的源码与分发仓库**（团队 AI 研发工作流 + git 工具规范）：
consensus-doc / consensus-scan / story-to-contract / tech-design / implement-discipline / change-propagation / lesson-deposit / workflow-setup / git-commit / git-worktree / git-rollback / git-pr

## 当用户要求「安装 / 接入 / 弄到我的 agent 里」时

执行：`bash install.sh`

脚本自动完成：克隆（若已在仓库内则跳过，直接使用当前目录）→ 链接 12 个 skill 到平台 skills 目录（默认 opencode `~/.config/opencode/skills/`，其他平台用 `SKILLS_DIR` 覆盖）→ 幂等追加 `templates/AGENTS.global.md`（team-workflow 导航段）到宿主 `~/.config/opencode/AGENTS.md` → 冲突检测（`scripts/detect-git-conflicts.sh` 扫描 git 同类 skill）。

## 其他

- 本项目文件是 skill 源码，**不要**把仓库本身当作普通应用项目去改业务代码
- 修改 skill 后提交回本仓库即可（平台侧只是符号链接，pull 即同步）
- 配套文档在 `docs/`（落地手册 / skill 规格 / 角色使用手册 / 流程可视化 HTML）
- 本仓库自身不依赖外部 skills
