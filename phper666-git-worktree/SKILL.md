---
name: phper666-git-worktree
metadata.source: https://github.com/phper666/ai-workflow-skills
description: git worktree 分支开发工作区管理：分支开发默认建议 worktree（auto 语义）——多需求并行 / 持续开发的需求都建 worktree（一需求一目录，目录即分支），单文件单 commit 小修可主目录直切（完成后回 main）。按团队配置的 worktree 模式（auto/always/manual）决定是否建 worktree。每个需求独立目录，绑定团队分支模型（feature/<需求标识>），多需求并行不切分支。git worktree 场景强制使用本 skill；若本地有其他同类 skill，团队模式默认用本 skill（用户显式指定别的 skill 除外）。当用户说"worktree"、"多需求并行"、"切换需求"、"多分支同时开发"、"开需求"、"做需求"时使用。角色中立：不绑定任何具体 agent/平台角色。
---

# git worktree（分支开发工作区管理）

worktree 是团队分支模型的落地工具：**一个需求一个目录 = feature/<需求标识> 分支**，多个需求同时进行时各自独立工作区，互不干扰、不切分支。

## worktree 模式（两级配置）

开始分支开发前，先查 `docs/spec/团队配置.md` 的「worktree 模式」两级表：

```
查找顺序：需求级覆盖（匹配 <项目> + <需求标识>）> 项目级默认（匹配 <项目>）> 默认 auto
```

三档语义：

- **auto**（默认）：AI 判断——多需求并行 / 持续开发的需求 → worktree（一需求一目录，目录即分支）；单文件单 commit 小修 → 主目录直切可以，完成后必须回 main
- **always**：所有分支开发一律 worktree，无例外
- **manual**：不用 worktree，主目录切分支（收尾必须回 main）

切换模式 = 改团队配置.md 一行，不改 skill 代码。用户提及切换/了解 worktree 模式时，按 `docs/团队AI研发工作流-配置说明.md` 的「模式切换交互」三分流（了解 → 讲解；目标明确 → 确认后改；目标模糊 → 列选项）。

## 触发时机

- 一人同时并行多个需求（跨需求频繁切换）
- 持续开发的需求（非一次性小修）——auto 模式下默认建 worktree
- 切需求要 stash/commit 当前工作区，嫌烦
- 多个 feature 分支同时进行，来回 checkout

## 操作

### 1. 创建

```bash
# 先确认需求标识，再建分支 + worktree
git worktree add <path> feature/<需求标识>
```

- `<path>` 建议：仓库同级 `../<repo>-<需求标识>`（如 `../my-app-m1`），一眼区分
- 分支命名必须遵守团队分支模型：`feature/<需求标识>`（需求标识见共识文档，如 `m1`、`login`）

**创建前确认**：分支名（`feature/<需求标识>`）+ 需求标识与共识文档一致，不凭空造。

### 2. 列出

```bash
git worktree list
```

### 3. 删除

```bash
git worktree remove <path>
```

**删除前检查**：该 worktree 无未提交改动（`git -C <path> status`）；有改动 → 先提交/暂存到分支再删。worktree 目录删了，分支/提交不丢。

### 4. 迁移现有目录（可选）

已有目录在开发中想并入 worktree 管理：

```bash
git worktree add --track -b feature/<需求标识> <path> origin/main
```

先确认目录内改动已提交或已备份，再迁移。

## 规范

- **一个需求一个 worktree**：不跨需求混用 worktree/目录
- 创建前确认分支命名（`feature/<需求标识>`），删除前检查未提交改动
- 需求不做 → 分支/worktree 留着不删（下次继续，主分支干净），符合团队「不做留分支」
- 需求完成合并后 → 清理对应 worktree + 分支（`git branch -d feature/<需求标识>` + `git worktree prune`）
- 需要主分支（共享文档）改动时 → 在主仓库 worktree 操作，不在需求 worktree 里混改共享文档

## 收尾纪律（不管什么模式都适用）

- **收尾回 main**：开发完成/暂停 → 主目录切回 main（分支提交不丢，回来 checkout 接上）——防止新会话加载错分支
- **ticket 验收清理**：ticket 移 Done（交付核验通过）→ 检测对应 worktree，满足三重门 → 清理；不满足 → 不清理 + 报告原因：

  1. ticket 已 Done（交付核验通过）
  2. 分支已合并主分支（`git branch --merged main` 包含该分支）
  3. worktree 无未提交改动（`git -C <path> status`）

  三重门全满足 → 清理：`git worktree remove <path>` + `git branch -d feature/<需求标识>` + `git worktree prune`
  任一不满足 → 不清理，报告具体原因（如"分支未合并"、"有未提交改动"）

- **存活期 = ticket 生命周期**：验收即清，稳态下 worktree 数 = 在途需求数，防 worktree 目录爆炸
