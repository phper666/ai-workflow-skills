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

### 一键安装（推荐）

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/phper666/ai-workflow-skills/main/install.sh)
```

自动完成：克隆到 `~/ai-workflow-skills` → 链接 8 个 skill → 幂等追加 AGENTS.md 导航段。重跑即更新（git pull）。

**平台选择**：
- 终端交互跑 → 弹出菜单选平台：opencode（默认）/ Claude Code / Cursor / 自定义目录
- curl 管道一键跑（无交互）→ 默认 opencode
- 显式覆盖：`SKILLS_DIR=~/.claude/skills bash install.sh`（跳过菜单直接指定）、`REPO_URL=...`、`SKILLS_SRC_DIR=...`

### AI 直接安装

把本仓库 clone/复制到任意目录，用 agent（opencode 等）打开后说「安装」，agent 会读取仓库根 `AGENTS.md` 自动执行 `bash install.sh`（已在仓库内时跳过克隆，直接用当前目录）。

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

## 实战案例

| 项目 | 说明 | 用到的 skill |
|:-----|:-----|:-------------|
| [dsh-hull-desktop](https://github.com/phper666/dsh-hull-desktop) | Electron 桌面壳，包住 DeepSeek Harness（dsh）：子进程守护、npm overlay 原位升级、任务看板、托盘/通知/开机自启。纯壳不 fork/patch，两条独立升级通道 | workflow-setup（接入）→ consensus-doc（共识/拆解）→ story-to-contract（契约）→ tech-design（技术方案）→ implement-discipline（实现纪律）→ lesson-deposit（沉淀） |

> 状态说明：案例项目处于早期脚手架阶段，展示的是「工作流如何驱动一个真实项目从接入到推进」，非已完成产品。

## 项目接入工作流（安装后）

1. 项目负责人跑 `phper666-teamflow-workflow-setup`：`"给这个项目接入研发工作流"`
2. 团队按角色使用对应 skill（见上表触发示例）
3. 项目侧产物：`docs/spec/`（共识、规则索引、团队配置、变更摘要、影响清单）、`docs/api/`（契约）、`docs/design/`（技术方案）、`docs/prd/`（需求）、`docs/prototype/`（原型）、`docs/records/`（实现/核验记录）、`docs/lessons/`（经验）

### 产物目录说明

| 目录 | 装什么 | 文件命名 | 产出 skill / 时机 |
|:-----|:-------|:---------|:------------------|
| `docs/spec/` | 共识文档（15 节骨架，版本化；替换式大变更才归档）、规则索引（CON-R001 起登记表）、团队配置（载体+角色映射+status_map）、变更摘要（追加式单文件，最新在前）、影响清单 | `{模块}-共识文档.md`、`规则索引.md`、`团队配置.md`、`变更摘要.md`、`影响清单-<编号>.md` | workflow-setup（索引/配置）、consensus-doc（共识）、change-propagation（摘要/清单） |
| `docs/api/` | 契约双文件：叙事契约（追踪/规则/状态转换/测试场景）+ OpenAPI（字段结构唯一事实源）；状态三态：草案/待评审/已冻结 | `{platform}-{item}-api-contract.md` + `-openapi.yaml` | story-to-contract，每工作项一份 |
| `docs/design/` | 技术方案（架构决策/模块划分/关键机制/工程基线），状态 draft→frozen | `<id>-<模块>-design.md`（id 优先用 BE 子任务 key） | tech-design，仅复杂/高风险；未 frozen 不得进实现 |
| `docs/prd/` | 需求文档（需求可回溯的权威文档） | `<date>-<slug>-prd.md` | 复杂需求前置（consensus-doc Phase 0） |
| `docs/prototype/` | 交互原型 | `<date>-<slug>-prototype`（与 PRD 同 slug） | 复杂 UI 类需求 |
| `docs/records/` | 实现记录（判级结论+测试/lint/review/扫描结果）+ 核验记录（核对结论+风险项）两节 | `<id>-record.md`（与 design 同 id） | implement-discipline，交付核验时核对 |
| `docs/lessons/` | 经验沉淀（三硬标准过滤，90 天无引用 archived） | `<date>-<slug>.md` | lesson-deposit |

### 子需求编号约定（跨期）

- **id 含「期」维度**：`<期>-<子需求>`（如 `M2-S1`）或按模块用独立编号段（如看板期 `B1-B5`）；**禁止跨期复用编号**（M2 不得沿用 M1 的 S1-S8，避免同名冲突与语义漂移）
- **跨目录统一前缀**：同一子需求在 design/records/api/lessons 用同一编号前缀（`B1-看板-design.md` / `B1-record.md` / `B1-api-contract.md` / `B1-lesson.md`），追溯「某子需求的契约/设计/记录/经验」不靠人肉拼
- **全库统一**：大小写（建议全小写）、slug 语言（建议全中文模块名）一致；契约前缀避免锁死平台（`feishu-` 换平台即失效）

## 维护约定

- **单一源**：本仓库是 8 个 skill 的唯一源码位置，平台侧只放符号链接或副本
- **共享规则升级**：跨项目验证有效的扫描规则 → 提交 `phper666-teamflow-consensus-scan/references/扫描规则库.md` 共享区 → 全员 pull
- **适配器**：`phper666-teamflow-story-to-contract/adapters/` 按平台 MCP 工具名映射（Jira/TAPD/飞书），换平台只改映射，不动 skill 主体
- **上游跟踪**：方法论吸收点见「与 Matt Pocock 流水线的关系」映射表；上游 release 时人工评估同步，无自动更新链路
- **配套文档**（`docs/`）：
  - `docs/ai-team-workflow.html` — 12 步流程可视化（浏览器打开）
  - `docs/团队AI研发工作流-落地启动文档.md` — 落地手册（基础设施/rollout/沟通）
  - `docs/团队AI研发工作流-Skill规格文档.md` — skill 规格与设计决策
  - `docs/团队AI研发工作流-角色使用手册.md` — 各角色使用指南

## 与 Matt Pocock 流水线的关系

方法论吸收了 Matt Pocock 流水线（brainstorming → PRD → implement/tdd）的部分思想并内化为原生实现；本仓库**不依赖、不安装**任何外部 skills。

### 吸收点映射（上游跟踪用）

| 本仓库落点 | 吸收来源（Matt Pocock） | 吸收时间 |
|:-----------|:------------------------|:---------|
| `tech-design` 需求探索（PRD+原型必产） | brainstorming | 2026-08 |
| `tech-design` 工程基线三问 | project-init | 2026-08 |
| `implement-discipline` TDD → lint → Review → Semgrep | implement / tdd | 2026-08 |
| `story-to-contract` 交付核验第三层（PRD/业务核验） | PRD 回验 | 2026-08 |
| `consensus-doc` 领域术语表采集 | domain-modeling | 2026-08 |
| `consensus-doc` 子需求依赖 DAG 拆解 | 大需求分解 | 2026-08 |

上游 release 时按此表人工评估吸收点是否过时，按需同步；**无自动更新链路**（内化复制，非依赖）。业务层（共识/契约/变更传播/防漂移）不在此表——与 Matt 流水线无关。

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
