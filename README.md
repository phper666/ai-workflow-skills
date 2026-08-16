# AI 研发工作流 Skills 仓库

团队 AI 研发工作流（共识 → 扫描 → 待确认闭环 → 契约 → 判级/技术方案 → 实现纪律 → 交付核验 → 变更传播 → 沉淀）的 skill 源码与分发仓库。

## 包含的 Skills

| Skill | 角色 | 一句话 | 触发示例 |
|:------|:-----|:-------|:---------|
| `phper666-teamflow-workflow-setup` | 初始化者 | 接入胶水：模板落地、规则索引、Q-items 载体配置、角色账号登记、AGENTS.md 导航 | "给这个项目接入研发工作流" |
| `phper666-teamflow-consensus-doc` | PM | 共识生命周期：建文档 → 发布基线 → 评审检查（Gate A）→ 拆解子需求 | "建立订单模块的共识文档" |
| `phper666-teamflow-consensus-scan` | BE·FE·QA·PM | 三角色扫描（默认自动切换视角）+ 待确认项创建/闭环 + 复盘升级扫描规则 | "扫描共识文档" / "处理待确认项" |
| `phper666-teamflow-story-to-contract` | BE（FE/QA 复核） | 契约生成/幂等更新/复核/澄清/子任务创建/交付核验（设计/契约/PRD 三层核验） | "为 DH-12 生成契约" |
| `phper666-teamflow-change-propagation` | AI+责任人 | 变更传播：变更摘要 → 影响定位 → 分级处理 → 影响清单 → 待复核闭环 | "R012 改了，传播一下" |
| `phper666-teamflow-tech-design` | 实现角色 | 技术方案分级：复杂/高风险需求产出 docs/design/<id>-<module>-design.md 供评审与回验对照；常规/简单跳过；复杂任务前置需求探索（PRD+原型必产）；工程基线三问 | "出个技术方案" |
| `phper666-teamflow-implement-discipline` | 实现角色 | 实现纪律（分级）：复杂完整流水线（TDD/lint/Review/Semgrep），常规轻量检查；工具可降级；安全敏感强制扫描 | "开始实现" |
| `phper666-teamflow-lesson-deposit` | 实现角色 | 经验沉淀：三硬标准过滤 + 引用计数自证（90 天无引用 archived），docs/lessons/ | "这个坑记一下" |

依赖：本仓库同时是**共享扫描规则库**的分发渠道——经验升级为扫描规则后提交到 `phper666-teamflow-consensus-scan/references/扫描规则库.md` 共享区，团队成员 pull 即同步生效。

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

### 其他平台（Claude Code / Cursor / 自建 agent 等）

将 `~/ai-workflow-skills/<skill-name>` 复制或符号链接到该平台约定的 skills 目录（如 `~/.claude/skills/`、项目内 `.agents/skills/`、`.cursor/skills/` 等）。

## 项目接入工作流（安装后）

1. 项目负责人跑 `phper666-teamflow-workflow-setup`：`"给这个项目接入研发工作流"`
2. 团队按角色使用对应 skill（见上表触发示例）
3. 项目侧产物：`docs/spec/`（共识、规则索引、团队配置、变更摘要、影响清单）、`docs/api/`（契约）、`docs/design/`（技术方案）、`docs/prd/`（需求）、`docs/prototype/`（原型）、`docs/records/`（实现/核验记录）、`docs/lessons/`（经验）

## 维护约定

- **单一源**：本仓库是 8 个 skill 的唯一源码位置，平台侧只放符号链接或副本
- **共享规则升级**：跨项目验证有效的扫描规则 → 提交 `phper666-teamflow-consensus-scan/references/扫描规则库.md` 共享区 → 全员 pull
- **适配器**：`phper666-teamflow-story-to-contract/adapters/` 按平台 MCP 工具名映射（Jira/TAPD/飞书），换平台只改映射，不动 skill 主体
- **配套文档**（`docs/`）：
  - `docs/ai-team-workflow.html` — 12 步流程可视化（浏览器打开）
  - `docs/团队AI研发工作流-落地启动文档.md` — 落地手册（基础设施/rollout/沟通）
  - `docs/团队AI研发工作流-Skill规格文档.md` — skill 规格与设计决策
  - `docs/团队AI研发工作流-角色使用手册.md` — 各角色使用指南

## 与 Matt Pocock 流水线的关系

本工作流与 Matt Pocock 流水线（brainstorming → PRD → to-issues → implement/tdd → feature-pipeline）**互补，不重叠**：

| 阶段 | Matt 流水线 | 本工作流 |
|:-----|:-----------|:---------|
| 需求定义 | PRD（创作态） | 共识文档（事实源，从 PRD/原型提取） |
| 任务拆解 | to-issues（PRD 任务） | phper666-teamflow-consensus-doc 拆子需求 + phper666-teamflow-story-to-contract 建 BE 子任务 |
| 契约 | 无（phper666-teamflow-story-to-contract 同源） | phper666-teamflow-story-to-contract |
| 实现 | implement / tdd | 契约冻结后先按级别出技术方案（phper666-teamflow-tech-design，复杂需求）→ 实现 → 交付核验模式（设计核验 + 契约核验） |
| 知识沉淀 | docs/spec/lessons/ | docs/lessons/ + phper666-teamflow-lesson-deposit（三硬标准 + 引用计数自证） + 契约"决策与踩坑" |

衔接点：契约冻结后 → phper666-teamflow-tech-design 判级（复杂需求：需求探索产 PRD+原型 → 工程基线三问 → 出技术方案）→ phper666-teamflow-implement-discipline 实现纪律 → phper666-teamflow-story-to-contract 交付核验模式（①设计核验对照技术方案 ②契约核验对照契约 ③PRD/业务核验）。已有项目接入顺序：project-onboarding（工程基线）→ phper666-teamflow-workflow-setup（工作流层）。

## 流程对应

15 环节流程 → skill 映射：

```
前置0 需求探索 ─1 建共识 ─2 发基线 ─3 扫描 ─4 PM闭环 ─5 评审 ─6 拆解 ─7 契约 ─8 复核 ─9 澄清
  [phper666-teamflow-consensus-doc]  [phper666-teamflow-consensus-doc]   [phper666-teamflow-consensus-scan]  [phper666-teamflow-consensus-doc]  [phper666-teamflow-story-to-contract]
  （PRD+原型必产，复杂）

★技术方案 ─●实现纪律 ─10 交付核验(三层) ─11 传播 ─12 沉淀
  [phper666-teamflow-tech-design]  [phper666-teamflow-        [phper666-teamflow-story-to-contract]   [change-     [phper666-teamflow-lesson-deposit]
   判级+工程基线]  implement-discipline]       ①设计 ②契约 ③PRD     propagation]  + phper666-teamflow-consensus-scan
```

- 前置 0（复杂需求）：需求探索——PRD + 交互原型（UI 类）必产，回溯链起点
- 契约复核（步骤 8）后：phper666-teamflow-tech-design 判级（复杂/常规/安全敏感）+ 工程基线三问（git/脚手架/测试框架）+ 技术栈决策（选择题+填空，评审兜底）
- 实现（●）：phper666-teamflow-implement-discipline 分级执行——复杂：TDD 核心路径 → lint → Review → Semgrep；常规：lint 单次；安全敏感：强制安全扫描；工具可降级（安全敏感例外）
- 交付核验（步骤 10）：三层——①设计核验（对照技术方案，无方案跳过）②契约核验（对照契约）③PRD/业务核验（PRD+原型落实 + 实现纪律执行核对）
- 沉淀（步骤 12）：phper666-teamflow-lesson-deposit 三硬标准入库，引用计数自证，90 天无引用 archived；phper666-teamflow-consensus-scan 复盘顺带审质量
