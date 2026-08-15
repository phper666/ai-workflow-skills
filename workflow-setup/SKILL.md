---
name: workflow-setup
description: 把任意项目（新项目或已有项目）接入"团队 AI 研发工作流"。当用户说"给这个项目接入研发工作流"、"初始化项目流程"、"搭建共识/契约文档结构"、"登记团队角色"、"配置待确认项载体（Q-items）"、"接入 workflow"、"这个项目要跑共识到契约的流程"时使用。接入完成后项目可立即开始跑共识文档→扫描→待确认闭环→契约→技术方案→实现纪律→交付核验→变更传播→沉淀的全流程。项目已接入过时，重跑本 skill 只会更新配置（幂等），不会破坏已有文档。边界：只做工作流层接入（模板/规则编号/Q-items/角色登记）；工程基线（git/脚手架/测试框架）检查与初始化归 tech-design 工程基线三问，不在此重复。
---

# 项目接入 AI 研发工作流

把任意项目接入 15 环节研发工作流：需求探索（复杂必产 PRD+原型）→ 共识文档（业务事实源）→ 发布基线 → 跨角色扫描 → 待确认闭环 → 评审 → 拆解 → 契约 → 复核 → 澄清 → **技术方案（判级 + 工程基线三问，复杂必出）** → **实现纪律（分级执行）** → 交付核验（三层）→ 变更传播 → 沉淀。

本 skill 只做**一次性接入**：落地模板、建规则索引、配置载体、登记角色、写导航。接入后的日常动作由其他 skill 承担（`consensus-doc` / `consensus-scan` / `story-to-contract` / `tech-design` / `implement-discipline` / `change-propagation` / `lesson-deposit`）。

## 执行前

1. 检查项目是否已接入：找 `AGENTS.md` 中的工作流导航段，或 `docs/spec/团队配置.md`。
2. 已接入 → 按"重跑模式"更新配置（见下），不重复创建模板。
3. 问清两个问题（用户已指定则跳过）：
   - **Q-items 载体平台**：飞书多维表格 / Jira q-item 子任务（检测环境里可用的 MCP；都可用时默认飞书，可指定）
   - **团队角色账号**：谁是什么角色（PM/BE/FE/QA），有账号信息更好（用于自动挂载问题）

## Phases

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

### Phase 2：目录与模板来源

**不复制模板到项目**（模板单一源 = skill 仓库，与 story-to-contract 一致）。只需建目录，生成实际文档时从对应 skill 的 references 读取模板：

| 生成什么时 | 模板来源（只读，不复制） |
|:-----------|:-------------------------|
| 共识文档（consensus-doc 生成） | `consensus-doc/references/模板-共识文档.md` |
| 变更摘要（change-propagation 生成） | `change-propagation/references/模板-变更摘要.md` |
| 契约文档（story-to-contract 生成） | `story-to-contract/references/api-contract-template.md` |

```
mkdir -p docs/spec docs/api
```

团队要自定义模板 → 改对应 skill 的 references（git 推送即团队同步），项目内不维护模板副本。存量项目已有复制模板（旧版接入）→ 可删除，不影响已有文档。若项目已有自己的文档约定（已有 `docs/` 或 wiki），遵循已有约定，只补缺失文件，不重构已有结构。

### Phase 3：规则索引

创建 `docs/spec/规则索引.md`：登记表（编号 / 规则摘要 / 所属模块 / 共识文档版本 / 状态），编号从 `CON-R001` 起。已接入过则跳过。存量项目：从已有文档中能识别的规则开始登记，标注来源。

### Phase 4：Q-items 载体配置

按 Phase 1 的载体选择初始化（字段映射细节见 `consensus-scan/references/载体适配.md`，五平台通用字段：编号/问题/优先级/待确认角色/创建人/共识版本/章节/规则编号/状态/回答/回写位置/复核人/创建时间）：
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
  - 建清单/字段/任务的工具映射见 `story-to-contract/adapters/feishu-task.md`
- 载体地址写入 `docs/spec/团队配置.md`

### Phase 4.5：状态就绪检查

载体建好后**必检**（工作流需要的状态是否就绪，检查清单见 `consensus-scan/references/载体适配.md` 状态就绪检查章节）：

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

检查结果写入 `docs/spec/团队配置.md` 的 status_map（抽象状态 → 载体实际状态名/guid），供 consensus-scan 闭环使用。缺失且无法自动补的（Jira）→ 明确告知用户配置后重跑本阶段。

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
- 此映射供 `consensus-scan`（问题自动挂载到人）和 `change-propagation`（影响清单指派责任人）使用

### Phase 6：导航与实现管道落地

在项目 `AGENTS.md`（无则创建）写工作流段，**用 `<!-- team-workflow:begin/end -->` 标记包裹**。项目段只写「接入标记 + 项目专属信息」，**不复制管道全文**——管道定义单一源 = 全局模板 `ai-workflow-skills/templates/AGENTS.global.md`（安装时加载到全局 AGENTS.md），项目段引用它：

```markdown
<!-- team-workflow:begin -->
## AI 研发工作流（已接入）

- 流程定义见全局 AGENTS.md `team-workflow` 段（ai-workflow-skills 模板）；未加载全局模板 → 跑 workflow-setup 或按 README 加载
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
