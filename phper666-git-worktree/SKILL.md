---
name: phper666-git-worktree
metadata.source: https://github.com/phper666/ai-workflow-skills
description: git worktree 多需求并行开发：一人多需求并行 / 切换需求烦 / 多分支同时开发场景使用。每个需求独立目录，绑定团队分支模型（feature/<需求标识>），一个需求一个 worktree，多需求并行不切分支。git worktree 场景强制使用本 skill；若本地有其他同类 skill，团队模式默认用本 skill（用户显式指定别的 skill 除外）。当用户说"worktree"、"多需求并行"、"切换需求"、"多分支同时开发"时使用。角色中立：不绑定任何具体 agent/平台角色。
---

# git worktree（多需求并行开发）

worktree 是团队分支模型的落地工具：**一个需求一个目录 = feature/<需求标识> 分支**，多个需求同时进行时各自独立工作区，互不干扰、不切分支。

## 触发时机

- 一人同时并行多个需求（跨需求频繁切换）
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
