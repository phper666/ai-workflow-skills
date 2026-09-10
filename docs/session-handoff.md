# 会话交接（2026-09-10）

> 新会话先读本文件接上讨论。仓库：/Users/liyuzhao/AI/project/ai-workflow-skills
> 接续方式：新会话说 **「读 docs/session-handoff.md 继续」** 或 **「recall 上次 ai-workflow-skills 讨论」**（后者搜 agentmemory）。

## 当前状态（本会话全部完成 + 已推送）

### 一、ai-workflow-skills 能力新增（本会话主体工作）

**worktree 生命周期闭环**（解决「主目录切分支→新会话加载错分支」问题）：
- worktree 模式可配置（`auto/always/manual`，团队配置.md 两级表，默认 auto）——`50407ff`
- 收尾纪律：开发完/暂停 → 主目录回 main；合并绕过流程时三重门兜底清理
- **合并顺序 A 钉死**：交付核验通过（ticket Done）→ 才提 PR 合并 → 合并后清理——`dc2da76`
- git-pr 工具降级链：gh → GitHub MCP → 显式报告（**禁静默本地 merge**，修复 gh 401 时 AI 自行绕过 PR）——`73aae1a`

**载体体系**：
- 载体模板方案：`templates/q-item.md` + `ticket.md` + `comment.md`（评论信封【】协议，回答/补充走原生评论）——`d3b1fd3`
- 飞书评论能力确认（写/读/删全支持：`lark-cli task +comment` 写、`lark-cli api GET /open-apis/task/v2/comments` 读；旧「降级描述追加」已废弃）
- 载体无关「项目任务盘点」（story-to-contract Phase 0，读团队配置拿载体，不全量扫）——`66ae8c8`
- Q-items 创建后全字段回读校验（平台感知：assignee/共识版本/编号等）——`1089057`/`d442fb5`/`91826ae`
- ticket 收尾检查（Phase 0.5：A 类有核验证据自动移 Done / C 类列清单）——`42c8e84`

**新 skill + 可配置模式**：
- `phper666-teamflow-project-overview`（项目概览：先概览后详情防上下文爆炸）——`08ecbd2` + evals `29f9ee8` + 修补 `60eaba6`
- 评审机制可配置（`gate/self-check/review/review-auto` 四模式 + 评审指南）——`f4e697d`/`d05e02b`
- 模式切换交互规则（了解型→讲解 / 目标明确→确认改 / 目标模糊→列选项，三配置项通用）——`544cca1`/`c6ee0ea`

**文档体系**：
- 快速上手（`docs/快速上手.md`：10 分钟最小闭环，人读+AI 可执行双形态「带我跑一遍快速上手」）——`668491e`
- 配置说明（`docs/团队AI研发工作流-配置说明.md`：可配置项/模式语义/切换交互）
- AI agent 配置建议（角色×skills 搭配参考，非强制）——`379bcb8`
- 流程可视化 HTML 修正 + **GitHub Pages 启用**：https://phper666.github.io/ai-workflow-skills/ai-team-workflow.html ——`8704841`
- evals 扩充（project-overview + 载体模板/评论协议断言，共 19 条）

### 二、playbooks 仓库（本会话新建）

- 地址：https://github.com/phper666/playbooks（公开）
- 内容：经验（release/semver-strategy、packaging/electron-crossplatform，通用化）+ skills（phper666-playbook-release/packaging）+ **tools/ 登记**（archify）
- archify（架构图生成工具）已本地安装 `~/tools/archify` 且实测可用（validate 9/9 + deliver 渲染）；**skills 不直接引入外部工具**（松耦合原则）
- semver-strategy 两次同步更新：分支保护豁免 + 发布=当前版本三阶段 + CI 平台可用性

### 三、环境维护（本会话）

- **全量工具升级**（14 项）：opencode 1.18.30 / claude-code 2.1.267 / cline 3.0.61 / agent-browser 0.37.1 / ocr 1.11.7 / codebase-memory-mcp 0.10.8 / lark-cli 1.0.94 / arkcli 1.0.26 / npm 12.0.2（两处）/ pnpm 12.3.4 / bun 1.4.2（修复历史坏安装）/ corepack 0.36.0 / oh-my-opencode-slim 2.2.18 / @opencode-ai/plugin 1.18.30
- **单一源重指**：`~/.agents/skills` 的 13 个 phper666 symlink 原指向落后克隆（`~/ai-workflow-skills`）→ 重指唯一源（`~/AI/project/ai-workflow-skills`）
- **修复**：/usr/local npm 损坏（升级中断造成）、`phper666-git-commit` YAML 引号（半角冒号解析失败）、`feishu-kanban-board` 缺 name 字段
- **清理**：`project/dsh-hull-desktop` 旧副本删除、`~/.local/bin` 542MB 旧备份删除
- 重启后健康检查：无错误（桌面 App 1.18.30 / slim 健康检查通过 / MCP 活体测试通过）

### 四、全局规则（本会话）

- **任务处理总结规则**写入 `~/.config/opencode/AGENTS.md`（task-summary 段）：每次处理完输出总结——先枚举所有问题/请求，逐条「问题→处理→结果」，条目数=问题数（覆盖自检），禁止空泛声明

## 下一步讨论 / 待办

1. **⚠️ token 轮换（需用户操作）**：opencode.jsonc 里 GitHub PAT + JIRA API token 明文（排查时被打印可见）→ 建议轮换或改环境变量
2. **github MCP 换官方版**：现用 `@modelcontextprotocol/server-github` 已归档 → 可换官方 `github-mcp-server`（我可做）
3. **wf-smoke-test 团队配置**补新配置段（worktree 模式等，低优先）
4. **huashu-design** 待实测再定（高保真设计 skill，与 prototype 有触发重叠）
5. 已评估未做（保持记录）：需求漂移守卫（痛点不强先记）

## 关键决策记录

- **合并顺序 A**：核验通过（ticket Done）才提 PR 合并——主分支只进验证过的代码
- **worktree 默认 auto**：多需求并行/持续开发→worktree；单 commit 小修→主目录（完事回 main）
- **禁静默降级**：工具失败（gh 401 等）→ 降级链 → 仍失败显式报告问用户，禁止 AI 自行绕过流程
- **载体评论走原生**：回答/补充用评论（飞书已验证写/读/删），description 只留问题区（结论区是派生缓存）
- **防上下文爆炸**：无硬预算，靠「白名单整读 + 完成清单 + 负面清单 + 软自查门」（项目概览 skill 实践）
- **playbooks 定位**：个人经验库（经验通用化）+ playbook skills + tools 登记；**skills 不引入外部工具**（松耦合）
- **任务总结机制**：先枚举再总结（覆盖自检）——总结完整性靠「问题数=条目数」保证

## 调研结论（本会话，供参考）

- **死循环根因**：LLM 输出退化（长上下文下固定短语自回归重复）+ compaction 未触发（单次 57 万 < 98 万阈值）→ 对策：会话长度闸门（开新会话）+ 等 opencode V2 per-turn 预估算压缩
- **RAG 调研**：对编码代理「有条件适用」——行业已转向 JIT 工具检索（grep/glob 为主）；建议 grep/结构化编号为主 + embedding 只兜底「白话跨文档查询」；全套向量 RAG 是过度工程
- **archify**：真工具（920 测试 + validate 9 项质量检查），已登记 playbooks/tools + 本地安装

## 交接原因

本会话覆盖工作量大（skill 体系重构 + playbooks 新建 + 环境全量升级），上下文已长。新会话接上后：读本文件 → 从「待办」开始，避免重新评估已完成的。
