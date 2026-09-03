---
name: phper666-git-pr
metadata.source: https://github.com/phper666/ai-workflow-skills
description: git PR 合并流程：feature/<需求标识> 分支开发完要合到主分支（提 PR / 合并需求 / 合并代码到主分支 / merge / PR）场景使用。按团队配置的合并模式（full/semi/manual）自动走对应流程：full = AI 提 PR + AI 自己 merge；semi = AI 提 PR + 等人工 approve + AI 检测合并；manual = AI 提 PR + 人工全权 merge + AI 检测合并。push/提 PR 前做最小检查（只跑受影响测试、修复再 push、禁 raw force，有 CI 则 PR 后查 CI）。合并前做需求标识唯一性检测（slug 冲突自动改名 m1→m1b + 同步引用），合并后清理已合并分支。git PR/合并场景强制使用本 skill；若本地有其他同类 skill，团队模式默认用本 skill（用户显式指定别的 skill 除外）。角色中立：不绑定任何具体 agent/平台角色。
---

# git PR 合并流程

feature 分支开发完要合到主分支时，先读合并模式，再按模式走对应流程。**三模式区别只在「merge 按钮谁按」**；「检测合并」是 semi/manual 的通用能力（merge 非 AI 自做时必须检测），full 不需要（AI 自己合，结果自知）。

## 触发时机

- feature 分支开发完，要合到主分支（`feature/<需求标识>` → 主分支）
- 用户说"提 PR"、"合并需求"、"合并代码到主分支"、"merge"
- 合并后要继续推进（检测上一步 PR 是否已合并）

## 合并前置门：交付核验通过（强制，顺序 A）

合并顺序钉死（顺序 A）：**开发完 → 交付核验通过（ticket 移 Done）→ 提 PR → 合并 → 清理**。

- 绑 ticket 的需求开发：ticket 在 Verify（核验中）→ **先跑交付核验（phper666-teamflow-story-to-contract 核验模式），不合并**——主分支只进「验证过的」代码
- 核验通过 → 正常走下方流程（push 前检查 → 提 PR → 按模式合并 → 清理）
- 无 ticket 的散任务/小修 → 无此门，正常 PR

> 为什么核验在合并前：核验在 feature worktree 里做（环境还在，不通过直接修）；
> 合并后再核验 = 主分支进过未验证代码 + 核验不通过时工作环境已清。

## 工具降级链：gh → GitHub MCP → 显式报告（禁止静默本地 merge）

PR 操作按此顺序选工具，**任何一级失败都显式报告，禁止静默换路径**：

1. **gh CLI**（首选）：`gh pr create / merge / view / checks`
2. **gh 不可用（未安装 / 401 未认证）→ GitHub MCP**（远端是 GitHub 时，owner/repo 从 `git remote -v` 解析）：
   - 提 PR：`github_create_pull_request`
   - merge：`github_merge_pull_request`（merge_method 按仓库约定：squash/merge/rebase）
   - 检测合并：`github_get_pull_request`（state=merged）或 `github_get_pull_request_status`
   - 列 PR / 查 CI：`github_list_pull_requests` / `github_get_pull_request_status`
3. **MCP 也不可用（非 GitHub 平台或无工具）→ 显式报告 + 问用户**：
   - 报告「gh 与 GitHub MCP 均不可用，无法走 PR」
   - 问用户：解决工具（装 gh / `gh auth login`）还是本地 merge 兜底
   - **用户明确同意才本地 merge**——本地 merge = 绕过 PR 流程（无 PR 记录、检测合并失效、semi/manual 语义作废、协作不可见），**不是降级是绕过，禁止 AI 自行选择**

> 非 GitHub 平台（GitLab 等）→ 用对应平台 CLI/MCP 等价操作，同样禁止静默本地 merge。

## 第零步：push 前检查（提交后、push/提 PR 前，强制）

push/提 PR 前先做最小检查，**不 push 后希望 CI 兜底**：

1. **选最小相关测试**：只跑受影响模块的测试/检查（`pnpm exec vitest run <受影响模块>/*.spec.ts` 或等价），**不跑全量套件**（省时；改哪个模块跑哪个）
2. **修复再 push**：本地检查失败 → 先修 → 重跑通过 → 才 push；**不 push 后等 CI 发现再修**
3. **禁 raw force**：历史重写（rebase 后）用 `git push --force-with-lease`（确认远端没变才覆盖），**禁止 `git push --force`**（无条件覆盖会破坏他人基于旧历史的提交）
4. **PR 后检查 CI**（**有 CI 时**）：`gh pr checks` 确认远程 CI 过；**无 CI 时跳过**（本地最小检查是唯一防线，更要跑够）

> **无 CI 时不影响核心**：第 1-3 步照做（本地测试/修复再 push/force 保护），只跳过「PR 后查 CI」。没 CI 兜底 → push 前检查更重要（问题不进主分支/PR）。

## 第一步：读取合并模式（两级配置）

合并前先查 `docs/spec/团队配置.md` 的「合并模式」两级表：

1. **需求级覆盖**（可选）：表「合并模式（需求级覆盖）」按 `项目 | 需求标识 | 模式` 登记，命中当前需求标识 → 用该模式
2. **项目级默认**：表「合并模式（项目级默认）」按 `项目 | 默认模式` 登记，需求级无覆盖 → 用项目默认

```
查找顺序：需求级覆盖（匹配 <项目> + <需求标识>）> 项目级默认（匹配 <项目>）> 问用户
```

得到 `full` / `semi` / `manual` 后走对应流程。用户提及切换/了解合并模式时，按 `docs/团队AI研发工作流-配置说明.md` 的「模式切换交互」三分流（了解 → 讲解；目标明确 → 确认后改；目标模糊 → 列选项）。

## full 流程（全自主）

AI 全程自己做，不等人工：

1. 提 PR：`gh pr create --base main --head feature/<需求标识> --title ... --body ...`
2. **合并 gate**：合并前检测需求标识唯一性（见下）——冲突则先自动改名
3. AI 自己 merge：`gh pr merge <编号> --squash`（或按仓库约定 merge 方式）
4. 清理分支：`git branch -d feature/<需求标识>`（本地）+ 删远程（如需）

## semi 流程（半自主）

AI 提 PR，等人工 approve，然后 merge 后检测合并：

1. 提 PR：`gh pr create --base main --head feature/<需求标识> --title ... --body ...`
2. 告知用户等人工 approve
3. 等人工 approve → merge（AI 或人工按，按团队约定）
4. **检测合并**（通用能力）：见「检测合并」——已合并 → 继续；未合并 → 提示用户等待/处理

## manual 流程（人工）

AI 只提 PR，合并完全由人工操作：

1. 提 PR：`gh pr create --base main --head feature/<需求标识> --title ... --body ...`
2. 告知用户：人工 merge（AI 不做）
3. 后续对话推进时（用户说"继续"、"检测合并"等）→ **检测合并**（通用能力）：
   - 已合并 → 继续（清理分支、标记完成）
   - 未合并 → 提示用户 PR 还没合，等合并后再继续

## 检测合并（通用，semi + manual 都要）

semi/manual 的合并不是 AI 自做，AI 无法自知结果，必须显式检测：

```bash
gh pr view <编号> --json state,mergedAt    # 最可靠：state=merged = 已合并
```

- `state` 为 `MERGED` → 已合并（`mergedAt` 有值），继续后续步骤
- `state` 为 `OPEN` / `CLOSED` → 未合并，提示用户（等 approve / 等人工合并），不静默继续

兜底方法（gh 不可用时，按降级链顺序）：

```bash
# 1. GitHub MCP（优先）
github_get_pull_request   # state=merged = 已合并（见「工具降级链」节）
# 2. 最后兜底（本地启发式，非权威）
git branch --merged origin/main             # feature 分支在列表 = 已合并
```

## 合并 gate（需求标识唯一性，合并前强制）

合并到主分支时，**主分支是唯一事实源**，检测新增文档名是否与主分支已有 slug 冲突：

1. **检测**：PR 里新增文档名 vs 主分支已有 slug（需求标识唯一性）
2. **冲突则自动改名**：`m1` → `m1b`，并同步改所有引用（文档名、规则编号、契约/设计/记录文件名）
3. 改名后再合并

> 检测放在**合并时**而非生成前：生成前有竞态窗口（检查到提交之间别人占用），合并时主分支无竞态。

## 规范

- **分支模型绑定**：合并目标是 `feature/<需求标识>` → 主分支，PR 的 head 必须是 feature 分支
- **需求不做 → 不合并**：feature 分支留着（下次继续），主分支干净
- **合并后标记完成**：按团队约定标记需求完成（变更摘要 / 影响清单 / 载体状态）
- **清理已合并分支**：`git branch -d feature/<需求标识>`（`-d` 会检查是否已合并，未合并会拒删，安全）
- **清理分支同时清理对应 worktree**（如该项目用了 worktree，`git worktree list` 确认存在）：`git worktree remove <path>` + `git worktree prune`，并确认主目录已切回 main（`git branch --show-current`）——防止分支留在主目录被新会话加载
- **改共享文档前** → 先 merge 主分支最新（减少冲突窗口）
- **合并是变更** → 需要时走 phper666-teamflow-change-propagation 更新变更摘要
- **禁 raw force**：历史重写用 `--force-with-lease`，禁 `git push --force`（与 phper666-git-rollback 的「reset 仅限本地未推送」一致——都是防破坏他人）
