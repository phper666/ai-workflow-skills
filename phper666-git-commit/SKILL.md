---
name: phper666-git-commit
metadata.source: https://github.com/phper666/ai-workflow-skills
description: git commit 提交规范 + 拆分：用户说 git commit / 提交 / 写 commit message 时使用。生成 Conventional Commits 规范消息（<type>(<scope>): <summary>），diff 含多个独立逻辑时建议拆成多个 commit（分析 diff 按逻辑分组），提交前提示跑 lint/test（pre-commit 检查，不通过不提交）。git commit 场景强制使用本 skill；若本地有其他同类 skill（如 commitizen、其他 commit 风格 skill），团队模式默认用本 skill（用户显式指定别的 skill 除外）。角色中立：不绑定任何具体 agent/平台角色。
---

# git commit（提交规范 + 拆分）

AI 会 git，但没有规范——本 skill 固化提交规范。**核心能力是拆分建议**：一个 diff 含多个独立逻辑，必须提示拆开，不让一次 commit 混多个逻辑。

## 触发时机

- 用户说"commit"、"提交"、"写 commit message"
- 提交前 review diff，需要生成规范提交信息
- 一个 diff 里有多个改动逻辑需要拆分

## 提交前检查

1. `git status` + `git diff` 看清改动内容
2. **lint/test 前置**：提交前提示跑项目 lint + 测试（`npm test`/`pytest`/`cargo test` 等按技术栈），**不通过不提交**（本 skill 是提示不是强制工具，无 pre-commit hook 时口头提示）
3. **拆分检查**：diff 含多个独立逻辑（如一个 diff 同时改了 bug 修复 + 新功能 + 重构）→ **必须建议拆分**成多个 commit，按逻辑分组逐个提交：
   - 分组：按改动意图切（修复、功能、重构、文档各一 commit）
   - 分批 stage：`git add <file>`（或 `git add -p` 精确到块），再分别 commit
   - 小步提交：每个 commit 一个逻辑，可独立回滚，review 更好看

## commit message 规范（Conventional Commits）

```
<type>(<scope>): <summary>
```

- **type**（必选）：`feat`（新功能）/ `fix`（修 bug）/ `refactor`（重构，不改行为）/ `perf`（性能）/ `docs`（文档）/ `test`（测试）/ `chore`（杂务）/ `build`（构建）/ `ci`（CI）/ `style`（格式）/ `revert`（回滚）
- **scope**（可选）：影响范围（模块/需求标识，如 `m1`、`login`）
- **summary**：祈使句（add/fix/remove），≤50 字符尽量，不加句号
- **body**（可选）：只写非显然的 why（为什么这么改），不写 obviously 的 what
- **footer**（可选）：关联 issue/breaking change

```bash
git commit -m "fix(login): fix token refresh race on expire" -m "旧逻辑在 token 过期瞬间可能双重刷新，改为单飞模式"
```

## 极简风格（可选）

默认标准格式 + 拆分建议。用户明确要极简时（如"简短点"），用压缩风格：`<type>: <一句话>`（如 `fix: 修登录过期`），仍保持 type 前缀。

## 规范

- **subject 祈使句**（add/fix/remove），≤50 chars 尽量
- **body 只写非显然的 why**，不写 obvious 的 what
- **拆分建议是核心能力**：一个 diff 多逻辑必须提示拆分，不默认一次提交
- 提交前 lint/test 检查提示（不通过不提交）
- 遵守团队分支模型：commit 在 `feature/<需求标识>` 分支上做，不直接 commit 到主分支共享文档之外的需求代码
