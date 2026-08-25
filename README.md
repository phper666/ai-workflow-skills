# AI 研发工作流 Skills 仓库

团队 AI 研发工作流（共识 → 扫描 → 待确认闭环 → 契约 → 判级/技术方案 → 实现纪律 → 交付核验 → 变更传播 → 沉淀）的 skill 源码与分发仓库。另含 4 个 git 工具 skill（commit/worktree/rollback/pr），给 AI 固化 git 操作规范。

> 本项目**仍在持续优化**——流程规则随团队实践不断迭代（版本见 `templates/AGENTS.global.md` 的 team-workflow 段），Skills 也随新教训/新需求持续演进。欢迎使用、反馈与贡献。

> **流程可视化**：[点此查看工作流总览图](https://phper666.github.io/ai-workflow-skills/ai-team-workflow.html)（GitHub Pages 渲染）

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
| `phper666-git-commit` | 全体 | git commit 提交规范：Conventional Commits + 拆分建议（一个 diff 多逻辑必须提示拆分）+ lint/test 前置 | "commit" / "提交" / "写 commit message" |
| `phper666-git-worktree` | 全体 | 多需求并行开发：一个需求一个 worktree（绑定 feature/<需求标识>），多需求并行不切分支 | "worktree" / "多需求并行" / "切换需求" |
| `phper666-git-rollback` | 全体 | 安全回滚：合并过的主分支改动 revert 不 reset；reset 仅限本地未推送；回滚前备份 + 双重确认 | "回滚" / "撤掉这个需求" / "误操作" |
| `phper666-git-pr` | 全体 | PR 合并流程：按团队配置合并模式（full/semi/manual）自动走提 PR + merge + 检测合并；合并 gate slug 冲突检测 + 清理已合并分支 | "提 PR" / "合并需求" / "合并代码到主分支" |

依赖：本仓库同时是**共享扫描规则库**的分发渠道——经验升级为扫描规则后提交到 `phper666-teamflow-consensus-scan/references/扫描规则库.md` 共享区，团队成员 pull 即同步生效。

## 平台接入

所有 skill 均为标准格式（SKILL.md + YAML frontmatter `name`/`description` + `references/`），兼容主流 agent 平台。

### 一键安装（推荐）

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/phper666/ai-workflow-skills/main/install.sh)
```

自动完成：克隆到 `~/ai-workflow-skills` → 链接 12 个 skill → 幂等追加 AGENTS.md 导航段 → 冲突检测。重跑即更新（git pull）。

### GitHub Pages（渲染流程可视化 html）

> 仓库已公开，Pages **已启用**。流程可视化正式地址见开头链接。

**若换仓库/域名需重新启用**（免费永久）：

1. 仓库 **Settings → Pages**
2. **Build and deployment → Source** 选 `Deploy from a branch`
3. **Branch** 选 `main` + 目录 `/docs`
4. **Save** → 等 1-2 分钟部署
5. 验证：`https://<owner>.github.io/ai-workflow-skills/ai-team-workflow.html`

> 若链接 404，说明 Pages 未启用或未选 `/docs` 目录。

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

## git 工具 skills（phper666-git-*）

三个 git skill 固化 AI 的 git 操作规范（AI 会 git 但没规范，skill 给规范），绑定团队分支模型（`feature/<需求标识>`）：

| Skill | 规范 |
|:------|:-----|
| `phper666-git-commit` | Conventional Commits（`<type>(<scope>): <summary>`）+ 拆分建议（一个 diff 多逻辑必须提示拆分）+ lint/test 前置 |
| `phper666-git-worktree` | 一个需求一个 worktree，绑定 `feature/<需求标识>`，多需求并行不切分支；创建前确认分支命名，删除前检查未提交改动 |
| `phper666-git-rollback` | 合并过的主分支改动撤销 = 必须 revert（新增反向 commit，保留历史）；reset --hard 仅限本地未推送；回滚前备份 + 双重确认 |
| `phper666-git-pr` | PR 合并流程（三模式）：full = AI 提 PR + AI 自己 merge；semi = AI 提 PR + 等人工 approve + AI 检测合并；manual = AI 提 PR + 人工全权 merge + AI 检测合并。合并前 slug 冲突检测（合并 gate），合并后清理已合并分支 |

**合并模式（团队配置.md 两级表）**：`docs/spec/团队配置.md` 配「合并模式（项目级默认）+ 合并模式（需求级覆盖）」两表，AI 合并时先查需求级覆盖 > 项目级默认。三模式区别只在「merge 按钮谁按」；检测合并是 semi/manual 的通用能力（merge 非 AI 自做时检测），full 不需要。切换模式 = 改团队配置一行，不改 skill 代码。

**冲突检测**：`install.sh` 安装时调用 `scripts/detect-git-conflicts.sh`，按通用功能类别（commit / worktree / rollback 关键词）扫描已装 skills，检测到同类 → 提示「建议卸载/停用避免触发冲突；保留则双保险兜底（默认用 phper666-git-*）」，**提示语气，不阻断安装**。双保险：skill description 强制声明（skill 层）+ AGENTS.md git 工具优先级声明（AGENTS 层）。

## 实战案例

| 项目 | 说明 | 用到的 skill |
|:-----|:-----|:-------------|
| [dsh-hull-desktop](https://github.com/phper666/dsh-hull-desktop) | Electron 桌面壳，包住 DeepSeek Harness（dsh）：子进程守护、npm overlay 原位升级、任务看板、托盘/通知/开机自启。纯壳不 fork/patch，两条独立升级通道 | workflow-setup（接入）→ consensus-doc（共识/拆解）→ story-to-contract（契约）→ tech-design（技术方案）→ implement-discipline（实现纪律）→ lesson-deposit（沉淀） |

> 状态说明：案例项目处于早期脚手架阶段，展示的是「工作流如何驱动一个真实项目从接入到推进」，非已完成产品。

## 项目接入工作流（安装后）

1. 项目负责人跑 `phper666-teamflow-workflow-setup`：`"给这个项目接入研发工作流"`
2. 团队按角色使用对应 skill（见上表触发示例）；AI agent 的 skills 搭配建议见 [docs/团队AI研发工作流-AI agent 配置建议.md](docs/团队AI研发工作流-AI agent 配置建议.md)（参考，非强制）
3. 接入后 `docs/spec/团队配置.md` 的可配置项/模式/修改方法见 [配置说明](docs/团队AI研发工作流-配置说明.md)（评审机制 self-check/review/review-auto/gate 四模式、合并模式 full/semi/manual 等）
4. 项目侧产物：`docs/spec/`（共识、规则索引、团队配置、变更摘要、变更摘要-<模块>.md、影响清单）、`docs/api/`（契约）、`docs/design/`（技术方案）、`docs/prd/`（需求）、`docs/prototype/`（原型）、`docs/records/`（实现/核验记录）、`docs/lessons/`（经验）

### 产物目录说明

| 目录 | 装什么 | 文件命名 | 产出 skill / 时机 |
|:-----|:-------|:---------|:------------------|
| `docs/spec/` | 共识文档（15 节骨架，版本化；替换式大变更才归档）、规则索引（CON-R001 起登记表）、团队配置（载体+角色映射+status_map）、变更摘要（三层：L1 索引 `变更摘要.md` + L2 模块详情 `变更摘要-<模块>.md` + L3 归档 `变更摘要-<模块>-<年份>.md`）、影响清单 | `{模块}-共识文档.md`、`规则索引.md`、`团队配置.md`、`变更摘要.md`、`变更摘要-<模块>.md`、`影响清单-<编号>.md` | workflow-setup（索引/配置）、consensus-doc（共识）、change-propagation（摘要/清单） |
| `docs/api/` | 契约双文件：叙事契约（追踪/规则/状态转换/测试场景）+ OpenAPI（字段结构唯一事实源）；状态三态：草案/待评审/已冻结 | `{platform}-{item}-{prd_slug}-api-contract.md` + `-openapi.yaml` | story-to-contract，每工作项一份 |
| `docs/design/` | 技术方案（架构决策/模块划分/关键机制/工程基线），状态 draft→frozen | `<id>-<模块>-{prd_slug}-design.md`（id 优先用 BE 子任务 key） | tech-design，仅复杂/高风险；未 frozen 不得进实现 |
| `docs/prd/` | 需求文档（需求可回溯的权威文档） | `<date>-<slug>-prd.md` | 复杂需求前置（consensus-doc Phase 0） |
| `docs/prototype/` | 交互原型 | `<date>-<slug>-prototype`（与 PRD 同 slug） | 复杂 UI 类需求 |
| `docs/records/` | 实现记录（判级结论+测试/lint/review/扫描结果）+ 核验记录（核对结论+风险项）两节 | `<id>-{prd_slug}-record.md`（与 design 同 id + 同 prd_slug） | implement-discipline，交付核验时核对 |
| `docs/lessons/` | 经验沉淀（三硬标准过滤，90 天无引用 archived） | `<date>-<slug>-{prd_slug}-lesson.md`（出生标记，跨期复用不受影响） | lesson-deposit |

### 子需求编号约定（跨期）

- **id 含「期」维度**：`<期>-<子需求>`（如 `M2-S1`）或按模块用独立编号段（如看板期 `B1-B5`）；**禁止跨期复用编号**（任何一期不得沿用其他期的编号段，避免同名冲突与语义漂移）
- **跨目录统一前缀**：同一子需求在 design/records/api/lessons 用同一编号前缀 + 同一需求标识（`B1-看板-m2-design.md` / `B1-m2-record.md` / `feishu-b1-m2-api-contract.md` / `2026-08-16-b1-xxx-m2-lesson.md`），追溯「某子需求的契约/设计/记录/经验」不靠人肉拼
- **需求标识必填**：`{prd_slug}` = 需求标识——复杂需求 = PRD 文件名 slug（`2026-08-14-m1-prd.md` → `m1`），常规需求 = 需求 slug（手给短标识如 `login`）；api/design/records/lessons 文件名必带，不留空占位；散任务类（Bug/优化/调研等）不走需求标识，用 `[模块][类型] <描述>`
- **全库统一**：大小写（建议全小写）、slug 语言（建议全中文模块名）一致；契约前缀避免锁死平台（`feishu-` 换平台即失效）

## 维护约定

- **单一源**：本仓库是 12 个 skill 的唯一源码位置，平台侧只放符号链接或副本
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

## 沉淀来源（外部项目借鉴）

本仓库部分 skill 吸收了外部开源项目/标准的思想，**内化为原生实现**（非依赖、非引用）。按用户要求记录沉淀来源，便于追溯与合规。

| 外部来源 | 借鉴内容 | 落点 | 说明 |
|:---------|:---------|:-----|:-----|
| **ZCF**（github.com/UfoMiao/zcf） | git 三件套（commit/worktree/rollback）+ PR 合并模式（full/semi/manual）+ 冲突检测 | `phper666-git-*`（4 个） | 参考其 git 工具 skill 思路，绑定我们的分支模型（feature/<需求标识>） |
| **anthropics/skills**（github.com/anthropics/skills） | skill 验证基线（测试用例 + should_trigger/should_not_trigger + 断言） | `evals/` | 借鉴 skill-creator 的 eval 机制，验证触发准确性与产出 |
| **Google Stitch DESIGN.md** | 设计系统文档格式（视觉主题/配色/字体/组件/布局/Do&Don'ts） | `templates/UI规范模板.md`、docs/ui/ 约定 | 借鉴 9 节结构，作为项目级 UI 规范骨架 |
| **Matt Pocock 流水线** | brainstorming → PRD → implement/tdd 思想 | 见上表「吸收点映射」 | 已记录，内化为原生实现 |
| **DeepSeek Harness**（github.com/deepseek-ai/deepseek-harness） | push 前检查纪律（选最小相关测试 + 修复再 push + 禁 raw force 用 force-with-lease） | `phper666-git-pr` 第零步 | 借鉴 dsh-pre-push-checks 思路，补「push 前最小检查」一环（有 CI 则 PR 后查 CI，无 CI 跳过） |

**原则**：
- 以上均为**内化吸收**（理解思想写成自己的规则），不是复制快照——外部升级不影响（除非原则级变化）
- 本仓库仍**不依赖、不安装**任何外部 skills（流程自包含）
- 新增借鉴外部项目 → 按本表追加一行（来源 + 借鉴内容 + 落点 + 时间）

## 待评估借鉴（候选概念）

评估过但未落地（痛点不强或待定）的外部概念，记于此防丢。**落地后移到「沉淀来源」表；评估后确认不需要的从表内移除**。

| 概念 | 来源 | 评估结论 | 状态 |
|:-----|:-----|:---------|:-----|
| **需求漂移守卫**（长会话防 AI 做偏） | dsh-requirements-alignment | 概念通用（基线+漂移检测+上报），降级可实现（共识=基线+模型检测+问用户），但当前痛点不强（流程契约冻结已锁定方向） | 先记，痛点出现再做 |

**已评估 → 不落地**（2026-08-24，痛点不强，划掉防重复评估）：
- 独立验收 agent（dsh-proof）——每次 turn 前 spawn verifier 成本高，现有交付核验已覆盖关键节点
- flaky 测试管理（dsh-flakefinder）——当前测试量小、低频跑，未构成痛点
- 任务台账事件溯源（task-board）——ticket 状态 + 变更摘要 + 实现/核验记录已覆盖跨会话可见性
- find-simplifications 证据审计——与 ponytail/simplify 重叠，增量价值低

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
