---
name: phper666-git-rollback
metadata.source: https://github.com/phper666/ai-workflow-skills
description: git 安全回滚：合并主分支后要撤已合并需求 / 误操作 / 回滚场景使用。先列历史看清再动，执行前双重确认，回滚前自动备份；合并到主分支的改动撤销必须 revert（新增反向 commit，保留历史可追溯），reset --hard 仅限本地未推送分支。git rollback/回滚 场景强制使用本 skill；若本地有其他同类 skill，团队模式默认用本 skill（用户显式指定别的 skill 除外）。当用户说"回滚"、"撤销"、"撤掉这个需求"、"回退"、"误操作"时使用。角色中立：不绑定任何具体 agent/平台角色。
---

# git 安全回滚

回滚是高风险操作，破坏不可逆。**核心原则：先看清，再备份，后动手；合并过的改动绝不 reset，只 revert。**

## 触发时机

- 合并主分支后要撤已合并的需求/改动
- 误操作（提错分支、提交错了东西）
- 需要回退到某个历史状态

## 操作顺序（固定三步）

### 1. 先列历史，看清再动

```bash
git status                 # 当前状态
git log --oneline -10      # 最近提交
git branch -a              # 所有分支（本地+远程）
git log --graph --oneline main feature/<需求标识>   # 看清合并关系
```

**不看清不动手**：不知道撤销目标就撤销 = 第二次误操作。

### 2. 双重确认（执行前）

执行破坏性命令前，先向用户复述「将执行什么、影响什么、是否可恢复」，得到确认后再执行。危险操作二次确认，防误操作。

### 3. 自动备份（回滚前）

```bash
git branch backup/<原分支>-<时间戳>     # 分支备份（原分支当前指针）
# 或未提交改动：git stash
```

备份可恢复，出问题能回。

## 安全模式（合并后撤需求）——默认

**合并到主分支的改动撤销 = 必须 `git revert`，不能 reset。**

```bash
git revert <commit>        # 新增一个反向 commit，把该提交的改动撤销
git revert <commit1>..<commit2>   # 撤一段范围（按提交顺序反向逐个 revert）
```

- 保留完整历史，可追溯（revert 自己也是 commit）
- 不重写历史，不破坏他人（其他人已基于该提交拉取也不受影响）
- 撤销后确认：`git log --oneline` 看到反向 commit，改动已无

## 危险模式（reset --hard）——仅限本地未推送

```bash
git reset --hard <commit>  # 丢弃该 commit 之后的提交和改动
```

**仅限**：目标分支未推送远程（`git status` 显示 ahead，无 origin 对应分支），或纯本地实验分支。

**禁用**：已推送/他人已拉取的分支——reset 重写历史，破坏他人，此场景必须用 revert。

**双重确认前置**：确认目标分支未推送 + 改动可丢弃，再执行。

## 规范

- **合并到主分支的改动撤销 = revert**（新增反向 commit，保留历史，不破坏他人），**禁止 reset**
- **reset 仅限本地未推送分支**，且双重确认
- **回滚前必须备份**（`backup/<原分支>-<时间戳>` 或 stash）
- 回滚后确认结果，不静默完成
- 回滚了已合并需求 → 需要的话走 phper666-teamflow-change-propagation 更新变更摘要（回滚也是变更）
