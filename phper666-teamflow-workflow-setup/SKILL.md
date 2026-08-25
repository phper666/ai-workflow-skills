---
name: phper666-teamflow-workflow-setup
metadata.source: https://github.com/phper666/ai-workflow-skills
description: 把任意项目（新项目或已有项目）接入"团队 AI 研发工作流"。当用户说"给这个项目接入研发工作流"、"初始化项目流程"、"搭建共识/契约文档结构"、"登记团队角色"、"配置待确认项载体（Q-items）"、"接入 workflow"、"这个项目要跑共识到契约的流程"时使用。接入完成后项目可立即开始跑共识文档→扫描→待确认闭环→契约→技术方案→实现纪律→交付核验→变更传播→沉淀的全流程。项目已接入过时，重跑本 skill 只会更新配置（幂等），不会破坏已有文档。边界：只做工作流层接入（模板/规则编号/Q-items/角色登记）；工程基线（git/脚手架/测试框架）检查与初始化归 phper666-teamflow-tech-design 工程基线三问，不在此重复。
---

# 项目接入 AI 研发工作流

把任意项目接入 15 环节研发工作流：需求探索（复杂必产 PRD+原型）→ 共识文档（业务事实源）→ 发布基线 → 跨角色扫描 → 待确认闭环 → 评审 → 拆解 → 契约 → 复核 → 澄清 → **技术方案（判级 + 工程基线三问，复杂必出）** → **实现纪律（分级执行）** → 交付核验（三层）→ 变更传播 → 沉淀。

本 skill 只做**一次性接入**：落地模板、建规则索引、配置载体、登记角色、写导航。接入后的日常动作由其他 skill 承担（`phper666-teamflow-consensus-doc` / `phper666-teamflow-consensus-scan` / `phper666-teamflow-story-to-contract` / `phper666-teamflow-tech-design` / `phper666-teamflow-implement-discipline` / `phper666-teamflow-change-propagation` / `phper666-teamflow-lesson-deposit`）。

## 执行前

1. 检查项目是否已接入：找 `AGENTS.md` 中的工作流导航段，或 `docs/spec/团队配置.md`。
2. 已接入 → 按"重跑模式"更新配置（见下），不重复创建模板。
3. 问清两个问题（用户已指定则跳过）：
   - **Q-items 载体平台**：飞书多维表格 / Jira q-item 子任务（检测环境里可用的 MCP；都可用时默认飞书，可指定）
   - **团队角色账号**：谁是什么角色（PM/BE/FE/QA），有账号信息更好（用于自动挂载问题）

## Phases

### Phase 0.5：全局就位检查（安装时自动，用户零手动复制）

检查环境级工作流文件是否就位，缺失则询问后自动加载（**写入全局配置前必须询问用户**）：

1. **全局 AGENTS.md**（`~/.config/opencode/AGENTS.md`，无则创建）：
   - 无 `<!-- team-workflow -->` 段 → 询问"加载团队流程全局模板？（Y/n）" → 将 `ai-workflow-skills/templates/AGENTS.global.md` 全文追加（或写入空文件）
   - 有段但版本号 < 模板版本（`templates/AGENTS.global.md` 的 begin 标记内版本）→ 提示"模板已更新"，询问是否替换段内容
2. **opencode + slim 调度层**（检测 `~/.config/opencode/oh-my-opencode-slim/` 存在）：
   - `orchestrator_append.md` 不存在 → 询问"安装调度层（orchestrator-append）？" → 从 `templates/orchestrator-append.md` 复制
   - 已存在 → 提示差异（模板版本落后时可询问替换，原文件先备份 `.bak.<timestamp>`）
3. **通用平台（无 slim）**：跳过 2，仅 1 生效——团队流程已在全局 AGENTS.md，调度层仅 opencode+slim 需要

> 模板单一源 = `ai-workflow-skills/templates/`（git 版本化）；本阶段只做"加载/替换"，不修改模板本体。仓库尚未 clone 到本地时 → 提示先 `git clone git@github.com:phper666/ai-workflow-skills.git`（或按 README 安装）。

### Phase 1：环境检测

检测当前会话可用工具，决定载体（**原则：Q-items 载体 = 团队现有 PM 平台，同平台管理，推广阻力最小**）：
- Jira MCP 可用 → Jira（q-item 子任务）
- TAPD 可用 → TAPD（缺陷类型 + 自定义字段）
- Linear 可用 → Linear（Issue + label）
- GitHub Issues 可用 → GitHub（Issue + labels + Projects v2）
- `OPENPROJECT_URL` + `OPENPROJECT_API_KEY` 环境变量存在 → OpenProject（自定义类型"待确认项"，用户可在 UI 添加）
- **飞书任务模块可用（feishu MCP 有 create_task/get_task 或 lark-cli 可用）→ 飞书任务清单（双清单方案，推荐轻量团队）**
- 飞书 MCP 可用 → 飞书多维表格（**无 PM 平台团队的默认**）
- 用户明确指定 → 指定优先于检测
- 载体地址与角色映射写入 `docs/spec/团队配置.md`（不存在则创建）

**项目载体段写入格式**（团队配置.md 必须含结构化「项目载体」段）：

```markdown
## 项目载体
- platform: <lark-task | jira | tapd | linear | github | openproject>
- ticket 载体: { idType: <tasklist_guid | projectKey | repo | workspaceId | teamId>, id: "<标识>" }
- q-item 载体: { idType: <同上>, id: "<标识>" }
```

- `platform` 用统一枚举值（各 adapter 的 platform 标识，见 `phper666-teamflow-story-to-contract/adapters/`）。
- `idType` 表示「载体标识的类型」（平台不同：飞书是 `tasklist_guid`、Jira 是 `projectKey`、GitHub 是 `repo` 等）。
- 存量团队配置.md（旧格式：直接写「平台 + 清单 guid」）无需强制迁移，新 skill 读旧格式也能工作（platform 已有）；但新接入的项目按新格式写。

### Phase 2：目录与模板来源

**不复制模板到项目**（模板单一源 = skill 仓库，与 phper666-teamflow-story-to-contract 一致）。只需建目录，生成实际文档时从对应 skill 的 references 读取模板：

| 生成什么时 | 模板来源（只读，不复制） |
|:-----------|:-------------------------|
| 共识文档（phper666-teamflow-consensus-doc 生成） | `phper666-teamflow-consensus-doc/references/模板-共识文档.md` |
| 变更摘要（phper666-teamflow-change-propagation 生成） | `phper666-teamflow-change-propagation/references/模板-变更摘要.md` |
| 契约文档（phper666-teamflow-story-to-contract 生成） | `phper666-teamflow-story-to-contract/references/api-contract-template.md` |

```
mkdir -p docs/spec docs/api
```

团队要自定义模板 → 改对应 skill 的 references（git 推送即团队同步），项目内不维护模板副本。存量项目已有复制模板（旧版接入）→ 可删除，不影响已有文档。若项目已有自己的文档约定（已有 `docs/` 或 wiki），遵循已有约定，只补缺失文件，不重构已有结构。

### Phase 3：规则索引

创建 `docs/spec/规则索引.md`：登记表（编号 / 规则摘要 / 所属模块 / 共识文档版本 / 状态），编号从 `CON-R-{需求标识}-{序号}` 起（如 `CON-R-m1-001`、`CON-R-login-001`；存量 `CON-R001` 历史编号不重排）。已接入过则跳过。存量项目：从已有文档中能识别的规则开始登记，标注来源。

### Phase 4：Q-items 载体配置

按 Phase 1 的载体选择初始化（字段映射细节见 `phper666-teamflow-consensus-scan/references/载体适配.md`，五平台通用字段：编号/问题/优先级/待确认角色/创建人/共识版本/章节/规则编号/状态/回答/回写位置/复核人/创建时间）：
- **飞书多维表格**：建"待确认项"表（类型参考：编号/问题/回答/回写位置=文本，优先级/待确认角色/状态/共识版本=单选，创建人/复核人=人员或文本，章节/规则编号=文本，创建时间=日期）
- **Jira**：约定 q-item 子任务类型，字段映射到 Jira 自定义字段
- **TAPD**：约定缺陷类型"待确认项"，自定义字段承载
- **Linear**：约定 Issue + label `q-item`，自定义字段承载
- **GitHub**：约定 Issue + labels，结构化信息用 Projects v2 字段
- **OpenProject**：约定自定义工作项类型"待确认项"（UI 添加：管理 → 工作包类型 → 新建），优先级改 P0/P1/P2（可选）
- **飞书任务清单（双清单方案）**：全自动初始化（lark-cli）——
  - 建清单：`task tasklists create --data '{"name":"{项目名}"}'` 和 `--data '{"name":"{项目名}-q-item"}'`，记录 guid
  - 配字段：`task custom_fields create`（resource_type=tasklist + resource_id=清单guid）：
    - ticket 清单：优先级（单选 P0/P1/P2）、类型（单选 Story/Bug/Task）、规则编号（文本）
    - q-item 清单：优先级（单选 P0/P1/P2）、状态（单选 open/answered/closed，或用看板列）、编号（文本）、共识版本（文本）、规则编号（文本）、回写位置（文本）
  - 选项 guid 在创建时返回，保存 字段名→guid、选项名→guid 映射到团队配置
  - 若 custom_fields API 不可用（缺授权）→ 降级 extra JSON 承载（见载体适配.md）
  - 建清单/字段/任务的工具映射见 `phper666-teamflow-story-to-contract/adapters/feishu-task.md`
- 载体地址写入 `docs/spec/团队配置.md`，按「项目载体段写入格式」组织（见 Phase 1）：`platform` 用统一枚举值，`ticket 载体` 与 `q-item 载体` 各记 `{idType, id}`——新接入项目一律按结构化「项目载体」段写

### Phase 4.5：状态就绪检查

载体建好后**必检**（工作流需要的状态是否就绪，检查清单见 `phper666-teamflow-consensus-scan/references/载体适配.md` 状态就绪检查章节）：

- **统一 6 态模板**（双清单共用）：`Backlog → Todo → In Progress → Verify → Done` + `Blocked`
- **ticket**：完整走 6 态；**Q-items 映射**：open=Todo、answered=Verify、closed=Done，**Blocked 对 q-item 同样有效**（等外部确认），复核不通过 Verify→Todo 打回

按载体执行：
- **飞书任务清单**：`sections list` 查看板列——**默认 6 列即满足**（Backlog/Blocked/Todo/In Progress/Verify/Done），零配置；缺列才**自动创建**（`sections create`）
  - ⚠️ **新清单自带一个空名默认列**（回归实测 2026-08）：处理方式 = **patch 改名为第一个必需态（Todo）**，再建其余缺失列——**不要删除默认列**（sections delete 是 high-risk-write，需用户 --yes 确认，agent 不得自行确认）
  - 目标终态：恰好 6 列（Backlog/Blocked/Todo/In Progress/Verify/Done），无多余列
- **飞书多维表格**：查状态字段单选选项 → 缺则补选项（6 选项）
- **OpenProject / Linear**：默认状态已含必需态 → 用默认映射，不建
- **Jira**：查工作流状态 → 缺则**提示用户配置**（Jira 工作流无法 API 创建）
- **GitHub**：answered 需 label `q-answered` → 缺则自动建 label

检查结果写入 `docs/spec/团队配置.md` 的 status_map（抽象状态 → 载体实际状态名/guid），供 phper666-teamflow-consensus-scan 闭环使用。缺失且无法自动补的（Jira）→ 明确告知用户配置后重跑本阶段。

### Phase 5：角色账号登记

建 `docs/spec/团队配置.md` 的角色映射段：

```yaml
roles:
  pm:   { name: 赵六, account: <可选，用于自动挂载> }
  be:   { name: 张三, account: ... }
  fe:   { name: 李四, account: ... }
  qa:   { name: 王五, account: ... }
```

- 不知道账号 → 只记名字，挂载退化为"指定人名"
- 中途有人加入/换角色 → 直接编辑此文件追加/修改一行即可，无需重跑本 skill
- **角色管归属，需求标识管唯一性（分离）**：角色 `name` = **归属**（谁负责哪个需求，问题挂载/影响清单指派责任人），需求标识 = **唯一性**（文档名/规则编号，见 consensus-doc Phase 1）。**新角色加入 = 配角色（归属），不改变已有需求文档名**——需求标识跟需求生命周期走，不跟角色走。团队配置只登记"角色 | name | 负责需求"的归属关系，文档命名唯一性由需求标识保证
- 此映射供 `phper666-teamflow-consensus-scan`（问题自动挂载到人）和 `phper666-teamflow-change-propagation`（影响清单指派责任人）使用

### Phase 5.5：合并模式配置（PR 合并模式两级表）

在 `docs/spec/团队配置.md` 加「合并模式」两级表，供 phper666-git-pr 合并时读取：

**项目级默认**（必配）：

```
合并模式（项目级默认）：
| 项目 | 默认模式 | 说明 |
|:-----|:---------|:-----|
| <项目名> | full/semi/manual | 不配则默认 full |
```

**需求级覆盖**（可选，覆盖项目默认）：

```
合并模式（需求级覆盖）：
| 项目 | 需求标识 | 模式 | 说明 |
|:-----|:---------|:-----|:-----|
| <项目名> | <m1/login> | full/manual | 覆盖项目默认 |
```

AI 合并时查找顺序：**需求级覆盖 > 项目级默认 > 问用户**。切换模式 = 改这里一行，不改 skill 代码。

- 三模式语义：**full**（AI 提 PR + AI 自己 merge）/ **semi**（AI 提 PR + 等人工 approve + AI 检测合并）/ **manual**（AI 提 PR + 人工全权 merge + AI 检测合并）
- 检测合并在 semi/manual 都要（merge 非 AI 自做时 AI 无法自知结果），full 不需要

### Phase 5.6：评审机制配置（技术方案评审两级表）

在 `docs/spec/团队配置.md` 加「评审机制」两级表，供 phper666-teamflow-tech-design 评审技术方案时读取（决定走 gate / self-check / review / review-auto 哪条）。

**初始化时先列模式让用户选**（决定项目级默认值）：

```
评审机制有四种模式，选一个作为项目级默认（不选则默认 self-check）：
  [self-check]   AI 自查通过即 frozen —— 不打扰用户（solo/小团队）
  [review]       先给用户/指定人 review 再 frozen —— 用户不表态则阻塞
  [review-auto]  先给用户 review（给选项），用户跳过则 AI 自查冻结 —— 不阻塞也不黑盒（推荐）
  [gate]         正式 Gate 评审，评审记录留痕 —— 多人团队

review-auto 交互：方案 draft → AI 问用户 [A]通过 [B]要改 [C]跳过 → A 冻结 /
                  B 用户列问题 → AI 修订 → 再给用户看 → 确认才冻结 / C AI 自查通过则冻结
                  （只有用户明确选 C 才降级 AI 自查，不默认跳过）
```

用户选一个写入「评审机制（项目级默认）」；用户不选 → 默认 self-check（兜底）。

**项目级默认**（必配，不配则默认 self-check）：

```
评审机制（项目级默认）：
| 项目 | 默认模式 | 说明 |
|:-----|:---------|:-----|
| <项目名> | gate/self-check/review/review-auto | 不配则默认 self-check |
```

**需求级覆盖**（可选，覆盖项目默认）：

```
评审机制（需求级覆盖）：
| 项目 | 需求标识 | 模式 | 说明 |
|:-----|:---------|:-----|:-----|
| <项目名> | <m1/login> | gate/review/review-auto | 覆盖项目默认 |
```

AI 评审时查找顺序：**需求级覆盖 > 项目级默认 > 默认 self-check**。切换模式 = 改这里一行，不改 skill 代码。

- 四模式语义：**self-check**（solo/小团队，AI 自查通过即 frozen，默认值）/ **review**（方案先给用户/指定人 review 再 frozen）/ **review-auto**（方案先给用户 review（给选项 A/B/C），用户跳过则自动降级 AI 自查后 frozen——不阻塞也不黑盒）/ **gate**（多人团队，方案走正式 Gate 评审，评审记录留痕：评审人/机制 + 日期 + 结论）
- solo 项目可直接配 self-check；有评审文化/多人团队配 gate；对内部设计有把关诉求配 review；希望不阻塞也不黑盒配 review-auto（推荐）

### Phase 6：导航与实现管道落地

在项目 `AGENTS.md`（无则创建）写工作流段，**用 `<!-- team-workflow:begin/end -->` 标记包裹**。项目段只写「接入标记 + 项目专属信息」，**不复制管道全文**——管道定义单一源 = 全局模板 `ai-workflow-skills/templates/AGENTS.global.md`（安装时加载到全局 AGENTS.md），项目段引用它：

```markdown
<!-- team-workflow:begin -->
## AI 研发工作流（已接入）

- 流程定义见全局 AGENTS.md `team-workflow` 段（ai-workflow-skills 模板）；未加载全局模板 → 跑 phper666-teamflow-workflow-setup 或按 README 加载
- 文档地图：docs/spec/（共识、规则索引、团队配置、变更摘要）、docs/api/（契约）、docs/design/（技术方案）、docs/prd/（需求）、docs/prototype/（原型）、docs/lessons/（经验）
- 载体：Q-items 见 docs/spec/团队配置.md
- 项目专属：<红线/约定，按项目补充>
<!-- team-workflow:end -->
```

写入规则（幂等 + 可回滚）：
- 已有 `team-workflow` 标记 → **只替换标记内的内容**（更新不追加）
- 无标记 → 在文件末尾追加标记段，不动已有内容；若发现旧版未标记导航段（标题「AI 研发工作流（已接入）」）或旧版含完整管道段的标记段 → 替换为新项目段
- 可回滚：删除标记段即完整移除，无残留

**项目级完整管道段 → 全局模板迁移**：存量项目若项目 AGENTS.md 含完整管道段（v1 早期格式）→ 替换为上面的项目段；全局 AGENTS.md 加载 `AGENTS.global.md` 模板（见仓库 README，写入前向用户确认）。

### Phase 7：存量模式（--existing 或项目已有存量文档）

- 不重写存量文档；存量文档在索引中标注"未纳入流程"
- 从下一个新需求开始走流程
- 已有规则从可识别处登记编号，标注来源
- 明确告知用户：存量部分以"增量接入"处理，历史欠账不回流

## 产出确认

完成后向用户汇报：
- 文档目录（docs/spec/、docs/api/ 已建；模板不复制进项目，生成时从 skill references 读取）
- 规则索引起始编号
- Q-items 载体（平台 + 地址）
- 角色映射（哪些人已登记，缺账号的标注）
- AGENTS.md 导航位置
- 下一步建议（通常：从第一个共识文档开始）

## 纪律

- **幂等**：重跑只更新配置，不重建模板、不覆盖已有文档、不产生 -v2 副本；AGENTS.md 段靠 `team-workflow` 标记去重（有标记替换、无标记追加），重复跑不产生重复段
- 接入动作只写以上 5 类文件，**不碰**项目业务代码和已有业务文档
- 载体选择一旦定下尽量不变；确需更换时只迁移 Q-items 数据（共识/契约文档在 git/wiki 中不受影响），流程逻辑不变
