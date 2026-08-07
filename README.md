# AI 研发工作流 Skills 仓库

团队 AI 研发工作流（共识 → 扫描 → 待确认闭环 → 评审 → 拆解 → 契约 → 复核 → 澄清 → 开发核验 → 变更传播 → 沉淀）的 skill 源码与分发仓库。

## 包含的 Skills

| Skill | 角色 | 一句话 | 触发示例 |
|:------|:-----|:-------|:---------|
| `workflow-setup` | 初始化者 | 接入胶水：模板落地、规则索引、Q-items 载体配置、角色账号登记、AGENTS.md 导航 | "给这个项目接入研发工作流" |
| `consensus-doc` | PM | 共识生命周期：建文档 → 发布基线 → 评审检查（Gate A）→ 拆解子需求 | "建立订单模块的共识文档" |
| `consensus-scan` | BE·FE·QA·PM | 三角色扫描（默认自动切换视角）+ 待确认项创建/闭环 + 复盘升级扫描规则 | "扫描共识文档" / "处理待确认项" |
| `story-to-contract` | BE（FE/QA 复核） | 契约生成/幂等更新/复核/澄清/子任务创建/交付核验 | "为 DH-12 生成契约" |
| `change-propagation` | AI+责任人 | 变更传播：变更摘要 → 影响定位 → 分级处理 → 影响清单 → 待复核闭环 | "R012 改了，传播一下" |

依赖：本仓库同时是**共享扫描规则库**的分发渠道——经验升级为扫描规则后提交到 `consensus-scan/references/扫描规则库.md` 共享区，团队成员 pull 即同步生效。

## 平台接入

所有 skill 均为标准格式（SKILL.md + YAML frontmatter `name`/`description` + `references/`），兼容主流 agent 平台。

### 通用步骤

```bash
git clone <本仓库地址> ~/ai-workflow-skills
```

### opencode

```bash
ln -sfn ~/ai-workflow-skills/<skill-name> ~/.config/opencode/skills/<skill-name>
```

### Claude Code

```bash
ln -sfn ~/ai-workflow-skills/<skill-name> ~/.claude/skills/<skill-name>
# 或按项目：~/<project>/.claude/skills/<skill-name>
```

### 其他平台（Cursor / 自建 agent 等）

将 `~/ai-workflow-skills/<skill-name>` 复制或符号链接到该平台约定的 skills 目录（多数平台支持项目内 `.agents/skills/` 或 `.cursor/skills/`）。

## 项目接入工作流（安装后）

1. 项目负责人跑 `workflow-setup`：`"给这个项目接入研发工作流"`
2. 团队按角色使用对应 skill（见上表触发示例）
3. 项目侧产物：`docs/spec/`（共识、规则索引、团队配置）、`docs/api/`（契约）、`docs/lessons/`（经验）

## 维护约定

- **单一源**：本仓库是 5 个 skill 的唯一源码位置，平台侧只放符号链接或副本
- **共享规则升级**：跨项目验证有效的扫描规则 → 提交 `consensus-scan/references/扫描规则库.md` 共享区 → 全员 pull
- **适配器**：`story-to-contract/adapters/` 按平台 MCP 工具名映射（Jira/TAPD/飞书），换平台只改映射，不动 skill 主体
- **配套文档**（`docs/`）：
  - `docs/ai-team-workflow.html` — 12 步流程可视化（浏览器打开）
  - `docs/团队AI研发工作流-落地启动文档.md` — 落地手册（基础设施/rollout/沟通）
  - `docs/团队AI研发工作流-Skill规格文档.md` — skill 规格与设计决策
  - `docs/团队AI研发工作流-角色使用手册.md` — 各角色使用指南

## 流程对应

12 步流程 → skill 映射：

```
1 建共识 ─2 发基线 ─3 扫描 ─4 PM闭环 ─5 评审 ─6 拆解 ─7 契约 ─8 复核 ─9 澄清 ─10 核验 ─11 传播 ─12 沉淀
   [consensus-doc]    [consensus-scan]    [consensus-doc]  [story-to-contract]     [change-     [story-to-contract
                       + consensus-doc                       + consensus-scan       propagation]  + consensus-scan]
```
