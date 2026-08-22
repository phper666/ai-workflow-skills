# 团队 AI 研发工作流 — Skill 规格文档

> 配套：`ai-team-workflow.html`（12 步流程可视化）· `团队AI研发工作流-落地启动文档.md`（落地手册）
> 定位：把 12 步流程沉淀为 8 个 teamflow skill（1 接入 + 7 运行时）+ 4 个 git 工具 skill（commit/worktree/rollback/pr）+ UI 规范 + 验证基线，分角色使用，可插拔接入任意项目。
> 设计原则：每角色最多碰 2 个 teamflow skill，git 四件套全员按需；触发用自然语言短句；写权分区无冲突；覆盖全部 12 步。

---

## 0. 总览

| # | Skill | 角色 | 步骤 | 写权 | 触发短语 |
|:--|:------|:-----|:-----|:-----|:---------|
| 1 | `phper666-teamflow-workflow-setup` | 初始化者 | 接入 | 模板+AGENTS.md | "给这个项目接入研发工作流" |
| 2 | `phper666-teamflow-consensus-doc` | PM | 1, 2, 5, 6-PM侧 | `docs/spec/` | "建立这个模块的共识文档" / "评审前检查" / "拆解子需求" |
| 3 | `phper666-teamflow-consensus-scan` | BE·FE·QA·PM | 3, 4, 12-规则升级 | Q-items 载体 | "扫描共识文档" / "合并扫描报告" / "闭环待确认项" |
| 4 | `phper666-teamflow-story-to-contract` | BE（FE/QA 复核） | 6-BE侧, 7, 8, 9, 10, 12-文档侧 | `docs/api/` | "为 DH-12 生成契约" / "更新契约" / "交付核验" |
| 5 | `phper666-teamflow-change-propagation` | AI+责任人 | 11, 12-团队侧 | 影响清单 | "共识规则改了，传播一下" |
| 6 | `phper666-teamflow-tech-design` | 实现角色 | 0(复杂), 8 后, 10-设计核验 | `docs/design/` + `docs/prd/` + `docs/prototype/` | "出个技术方案" / "怎么实现" |
| 7 | `phper666-teamflow-implement-discipline` | 实现角色 | 实现环节（技术方案后/常规直达） | 实现记录 | "开始实现" |
| 8 | `phper666-teamflow-lesson-deposit` | 实现角色 | 10 后, 12 | `docs/lessons/` | "这个坑记一下" / "沉淀" |
| 9 | `phper666-git-commit` | 全员 | 提交时 | — | "commit" / "提交" / "写 commit message" |
| 10 | `phper666-git-worktree` | 全员 | 多需求并行 | — | "worktree" / "多需求并行" / "切换需求" |
| 11 | `phper666-git-rollback` | 全员 | 回滚/撤销时 | — | "回滚" / "撤销" / "撤掉这个需求" |
| 12 | `phper666-git-pr` | 全员 | 合并需求到主分支 | — | "提 PR" / "合并需求" / "合并代码到主分支" |

**配套资产**：`docs/ui/UI规范.md`（项目级视觉规范）+ `evals/`（验证基线）——见 §12、§13。

**覆盖矩阵**（15 环节全部有家，无孤儿）：

```
前置0 需求探索 ─1 建共识 ─2 发基线 ─3 扫描 ─4 PM闭环 ─5 评审 ─6 拆解
   [6 复杂必产]   [2]      [2]      [3]      [3]      [2]     [2+4]
7 契约 ─8 复核 ─9 澄清 ─⛔ 实现前置Gate ─★ 技术方案 ─● 实现纪律 ─10 交付核验(三层) ─11 传播 ─12 沉淀
  [4]   [4]→[6]   [4]    [判级+基线     [6 方案冻结     [7 分级     [6+4+7→10]      [5]     [8+4+3+5]
                         三问+复杂       draft→frozen]  执行]       ①设计②契约③PRD
                         出方案冻结]
```

**协作方式**：skill 间通过文档路径 + 模板传递上下文；`phper666-teamflow-change-propagation` 编排"重跑"其他 skill 的既有 phase，**不复制逻辑**。

---

## 1. `phper666-teamflow-workflow-setup` — 接入胶水（最薄）

**定位**：把一个新项目或已有项目接入本流程，一次性完成。跑完即"可开工"。

**触发短语**：`给这个项目接入研发工作流` / `接入 workflow`

**Phases**：
1. **环境检测**：识别 PM 平台（Jira MCP / 飞书 MCP / TAPD 可用性）→ 决定 Q-items 适配器；识别文档仓库（git docs/ 或 wiki）
2. **模板落地**：复制 3 份模板到项目：
   - `docs/spec/模板-共识文档.md`（14 节）
   - `docs/api/模板-契约文档.md`（12+ 节，含决策与踩坑、完成记录）
   - `docs/spec/模板-变更摘要.md`（三层：L1 索引 + L2 模块详情 + L3 归档；规则编号/旧结论/新结论/影响范围）
3. **规则编号注册**：建 `docs/spec/规则索引.md`，`CON-R001` 起
4. **Q-items 载体配置**：按检测结果初始化（Jira q-item 子任务方案 / 飞书多维表格表结构），写载体地址到项目配置
5. **角色账号登记（推荐）**：登记角色→账号映射（张三=BE、李四=FE、王五=QA、赵六=PM），写入项目配置。作用：Q-items 创建时自动挂载到具体人（Jira 经办人 / 飞书表负责人字段）；变更传播影响清单自动指派责任人。未登记时影响项标"无负责人"由 PM 指派
6. **导航落地**：写/更新 `AGENTS.md` 的流程入口段（5 个触发短语 + 文档地图）
7. **存量模式（--existing）**：已有项目不重写存量文档；存量文档标注"未纳入流程"，从下一个新需求开始走；已有规则从可识别处开始登记编号

**产物**：目录结构 + 模板 + 规则索引 + Q-items 配置 + AGENTS.md 导航。

---

## 2. `phper666-teamflow-consensus-doc` — 共识生命周期（PM 侧上游）

**定位**：PM 对共识文档的完整上游生命周期：建立 → 发布 → 评审 → 拆解。一个模块一个文档，四件事串成线。

**触发短语**：`建立 <模块> 的共识文档` / `发布共识基线` / `评审前检查` / `拆解 <模块> 子需求`

**Phases**：
1. **建文档**：按 14 节模板采集业务事实（流程/状态机/权限/字段/规则/枚举/第三方/未决项/页面/后端任务/端差异）；关键规则建编号+事实来源；显式记录未决项、适用范围、不做事项
2. **需求标识 + 命名规范**：共识文档命名 `共识-{模块}-{需求标识}.md`（如 `共识-桌面壳-m1.md`）。**需求标识** = 复杂需求用 PRD slug（PRD 文件名 slug，如 `2026-08-14-m1-prd.md` → `m1`），常规需求用需求 slug（手给短标识如 `login`）；无 PRD 的常规需求 → 建共识时手给需求 slug，检测 `docs/` 已用 slug 避免重复（有 → 改 `login2`）。同模块不同需求文档名不冲突，各需求独立隔离
3. **规则编号**：关键业务规则稳定编号 `CON-R-{需求标识}-{序号}` 起（如 `CON-R-m1-001`——**各需求独立编号域，不撞号**）；查 `docs/spec/规则索引.md` 现有编号避免冲突；存量 `CON-R001` 历史编号不重排（新规则用新格式）
4. **发布基线**：升版本号+更新时间；绑定原型、Jira Epic/父需求、来源链接；生成扫描通知（范围+截止时间）
5. **评审就绪（Gate A checklist 模式）**：会前验证——结构完整无自相矛盾、关键规则可唯一引用、P0 待确认项清零、版本可追踪；会后把评审结论回写正文+输出结构化变更摘要
6. **拆解（PM 侧）**：按模块拆子需求，每个子需求绑定共识版本+规则编号+验收标准+不做事项；标注依赖；**只建 PM 侧子需求**，各角色子任务由各角色自己的 skill 建

**UI 规范联动**：UI 类需求原型后 → 提取/更新项目级 UI 规范（`docs/ui/UI规范.md`，模板见 `templates/UI规范模板.md`），写入版本记录（绑定共识版本）——供前端实现做视觉基准、变更传播定位受影响前端实现（见 §12）。

**模板**：`docs/spec/模板-共识文档.md`（14 节）+ `docs/spec/模板-变更摘要.md`

**门禁**：Gate A 就绪 checklist（会前/会后两段）。

---

## 3. `phper666-teamflow-consensus-scan` — 扫描与待确认闭环（团队）

**定位**：步骤 3-4 的执行器：三角色扫描 → 去重聚类 → 待确认项创建 → 闭环回写校验；兼步骤 12 的"重复问题升级为扫描规则"。

**触发短语**：`扫描共识文档`（默认单人三角色） / `扫描共识文档 --role=BE|FE|QA` / `合并扫描报告` / `闭环待确认项` / `复盘扫描规则`

**Phases**：
1. **扫描（模式双支持，结果一致）**：
   - 默认：单人跑三角色（agent 依次切换 BE/FE/QA 视角扫同一文档）
   - `--role=X`：单角色跑（各自会话异步执行）
   - 扫描维度复用 phper666-teamflow-story-to-contract Phase 4（范围/状态/字段/接口/数据/外部系统/验收）
   - 问题格式统一：`[BLOCKER][Q-012][后端/产品] <问题>`
2. **去重聚类**：按待确认项编号去重；已被共识/决策/代码回答的自动关闭；区分 P0/P1/P2 + Blocker/Major/Minor；问题绑定共识版本+章节+规则编号
3. **merge 收口**（分角色跑后）：合并三角色报告，交叉引用，出合并问题集
4. **待确认项创建/更新**：写入 Q-items 载体（适配器层，见 §6）；不重复创建同一问题
5. **闭环校验**：PM 回答后——验证三连（已回答/已回写共识文档/发起人复核）；回写位置为强制字段
6. **复盘升级**：步骤 12 侧——重复出现的问题升级为扫描规则（写入 skill 的 rules 引用或团队规范）

**规则两级结构**：扫描规则库分"项目规则 + 共享规则"两级——
- 项目规则：本项目反复出现的问题升级而来，存项目内
- 共享规则：跨项目验证有效的经验升级而来，存 **skill 分发仓库**（规则跟随 skill 分发渠道，团队安装/更新 skill 即同步，不依赖任何成员的本机配置）→ 所有项目扫描自动加载
- 经验漏斗：`docs/lessons/` 随手记（被动）→ 第二次出现验证可复用 → 升级共享扫描规则（主动检查，所有项目生效）
- 载体边界：团队经验库 = 团队 git 仓库 `lessons/` 或团队 wiki（全员可达）；agentmemory 仅作个人本地记忆（跨项目回忆个人经历），不作为团队载体

**产物**：扫描报告 + 合并问题集 + Q-items 记录（状态可追踪）。

---

## 4. `phper666-teamflow-story-to-contract` — 契约枢纽（BE 侧，已存在）

**定位**：已实现的契约生命周期执行器，本方案**保留 + 微调**。核心能力（生成/复核/澄清/幂等更新/子任务创建）不动。

**微调清单**（当前缺失，对照 12 步）：
| 补什么 | 对应步骤 | 做法 |
|:-------|:---------|:-----|
| FE/QA 复核 checklist | 8 | references 增加 `review-feqa.md`：FE 联调可用性视角（字段覆盖/错误处理/示例自洽）+ QA 测试矩阵视角（边界/异常/权限/兼容）；补"复核通过才冻结"状态 |
| 协调事项机制 | 9 | 模板加"协调事项"表（跨模块问题/责任人/截止时间）；升级 PM 的触发条件明确化 |
| 完成记录章节 | 12 | 模板加"完成记录"（交付/验证/构建/发布/测试结果，要有证据） |
| 决策与踩坑章节 | 12 | 模板加"决策与踩坑"（可复用决策/反例/工程经验；纪律：沉淀不污染当前规格） |
| 交付核验模式 | 10 | 新 phase：开发完成后对照契约核验（实现 vs 契约 diff、核心+错误路径、偏差处理结论）；QA 用契约"联调与测试场景"表做验收 |

**契约防漂移**（双文件单一事实源）：
- **单一事实源**：字段级结构（Schema/参数/响应字段）与示例值的唯一权威为 OpenAPI yaml；md 只写业务语义（错误语义/状态转换/幂等/审计/测试要点）+ 导航摘要表
- **状态三态锁定**：契约状态仅 草案/待评审/已冻结，禁止自创状态词；部分实施受阻走开放问题表（阻塞接口/字段列 + Q-xxx 行级标记）
- **CONS-02 Blocker**（review-rubric）：md 接口清单行与 OpenAPI paths 集合双向相等（(方法, 完整路径含前缀) 精确匹配），不一致 = 打回
- **同生同步**：双文件同一次执行内更新，禁止只改其一

**不改**：适配器层、幂等收敛语义、P0 门禁、TBD 纪律。（review-rubric 仅新增 CONS-02，见上。）

---

## 5. `phper666-teamflow-change-propagation` — 变更传播（AI + 责任人）

**定位**：步骤 11 的执行器 + 步骤 12 团队侧。上游共识变化 → 影响显性化 → 下游收敛 → 复核闭环。

**触发短语**：`共识规则改了，传播一下` / `<R0xx> 变更了` / `影响清单`

**Phases**：
1. **变更摘要**：识别规则编号、旧结论、新结论、生效时间（复用 `docs/spec/模板-变更摘要.md`；详情写 `变更摘要-<模块>.md`，L1 索引只加一行）
2. **影响定位**：沿规则编号 grep 引用——子需求、契约（`docs/api/`）、测试场景；引用缺失时退化为全量通知+人工确认（不建图谱系统）
3. **重跑编排**（不复制逻辑）：
   - 受影响契约 → 按 phper666-teamflow-story-to-contract 幂等更新语义重跑收敛
   - 受影响子需求/测试 → 按 phper666-teamflow-consensus-scan 定位待确认/测试影响
4. **影响清单 + 待复核标记**：产出影响清单（产物/责任人/状态），责任人确认后解除待复核
5. **闭环确认**：**复核完成前不可宣称交付完成**；变更完成后更新 Jira 相关条目状态

**产物**：变更摘要 + 影响清单（责任到人、状态可查）。

---

## 6. Q-items 平台适配层

复用 phper666-teamflow-story-to-contract 的适配器模式（`adapters/interface.md`：parseUrl / readItem / createItem / addComment / getCurrentUser / listItems）。

| 平台 | 载体 | 状态 |
|:-----|:-----|:-----|
| Jira | q-item 子任务（字段：共识版本/章节/规则编号/优先级） | 适配器已有，补 q-item 约定 |
| 飞书多维表格 | 待确认项表（同字段 + 回写位置必填） | 需新增 adapter（lark-base MCP 现成） |
| TAPD / Linear / GitHub | 按需后补 | 接口已定义，加 adapter 即可 |

skill 主体只调抽象操作，平台差异锁在适配器内。

---

## 7. 接入路径

**新项目**：`phper666-teamflow-workflow-setup` 一步完成 → 从第一个共识文档开始走 12 步。
**已有项目**：`phper666-teamflow-workflow-setup --existing` → 存量不重写、标注未纳入 → 新需求开始走 → 规则编号逐步登记。

---

## 8. 实施顺序（依赖关系）

1. **`phper666-teamflow-workflow-setup`**（地基：模板+规则编号+载体配置，其余 skill 都依赖其产物）
2. **`phper666-teamflow-consensus-scan` + `phper666-teamflow-consensus-doc`**（上游：阶段 1 试点要跑通 Gate A，两 skill 配套）
3. **`phper666-teamflow-story-to-contract` 微调**（补齐 5 项缺口；枢纽已可用，微调量小）
4. **`phper666-teamflow-change-propagation`**（依赖 2/3/4 的引用锚点建立后才有意义，放最后）
5. **`phper666-teamflow-tech-design` + `phper666-teamflow-lesson-deposit`**（新增环节，随首个复杂需求落地时启用）

---

## 9. `phper666-teamflow-tech-design` — 技术方案（分级）

**定位**：契约冻结后、实现前，把共识（what）和契约（what-between）之间的 how 落成可评审、可对照、可传播的方案。**角色中立，不绑定任何平台特定角色。**

**分级判定**：有没有"实现形态的选择"（多条路要选 = 要方案；唯一做法 = 不要）：
- 复杂/高风险（状态机、安全/资金/数据、多模块、greenfield、外部系统集成）→ 必出 `docs/design/<id>-<module>-design.md` + 团队既有评审机制
- 常规/简单 → 跳过，决策留契约/review

**方案状态机**：`draft`（撰写中）→ `frozen`（评审通过·冻结，可进实现）。评审通过须在「评审记录」留痕（评审人/机制 + 日期 + 结论）；**未 frozen 不得进实现**。实现中偏离 → 显式更新方案 + 记录理由；架构/机制级重大偏离 → 回 `draft` 重新评审。

**内容骨架**：背景与范围（绑定共识版本+规则编号+契约路径）→ 架构决策（备选+取舍理由）→ 模块划分 → 关键机制实现形态 → 目录结构 → 风险与对策 → 核验记录（交付核验时填写偏离清单）

**与交付核验的关系**：phper666-teamflow-story-to-contract 交付核验模式 ①设计核验对照本方案；无方案的常规需求跳过设计核验。

---

## 10. `phper666-teamflow-implement-discipline` — 实现纪律（分级）

**定位**：契约/技术方案就绪后的实现环节。**机器能强制的检查必须做，工具缺失可降级，安全敏感不降级。**

**分级执行**：
- 复杂：TDD 核心路径（red-green-refactor，非平凡逻辑强制）→ lint 单遍 → Code Review（ocr/人工/AI，solo AI review 算数）→ Semgrep（有则跑）
- 常规：lint 单次 + 工程基线三问复核
- 安全敏感（密钥/权限/支付/数据）：强制安全扫描（Semgrep 或等价工具 gitleaks/trivy）

**工具降级**：lint 缺失 → review 人工查风格；ocr 缺失 → 人工/AI review；semgrep 缺失 → 普通跳过记风险项，安全敏感必须换等价工具。不阻断流程（安全敏感例外），降级记录在核验记录。

**测试分层**：单测必选（核心路径）；集成测试跨模块/外部依赖时必选；e2e 可选。

**留痕**：实现记录与核验记录合并写入 `docs/records/<子需求id>-record.md`，两节：
- **实现记录**：判级结论（复杂/常规/安全敏感 + 一句理由）+ 测试/lint/Code Review/Semgrep 结果
- **核验记录**：核对结论 + 风险项 + AI review 结果

**纪律**：原生实现（不调外部编排体系）；不设多轮强制循环；检查证据供交付核验 ③ 层核对（执行钩子）。

---

## 11. `phper666-teamflow-lesson-deposit` — 经验沉淀（自证）

**定位**：事后经验（踩坑/可复用模式），与事前决策（phper666-teamflow-tech-design）是两类产物。**决策让人拍板，沉淀让时间验证。**

**三硬标准**（全中才写）：可复用（换模块/项目还能用）· 非显而易见（读文档查不到）· 有代价（踩过坑）

**自证机制**（不绑人审）：引用计数（写时登记引用位置，复用 +1）→ 90 天无新引用 → archived（降级不删）。价值由复用证明，不由审批证明。

**产物**：`docs/lessons/<date>-<slug>.md`（背景/决策或坑/影响/适用范围/来源/引用）

---

## 12. `phper666-git-commit` / `phper666-git-worktree` / `phper666-git-rollback` / `phper666-git-pr` — git 工具四件套（全员）

**定位**：团队分支模型的落地工具，与需求标识机制强绑定。git 场景强制用对应 skill；本地有同类 skill（commitizen 等）时团队模式默认用本仓库的（用户显式指定别的除外）。角色中立。

### 12.1 `phper666-git-commit` — 提交规范（Conventional Commits + 拆分建议）

**触发短语**：`git commit` / `提交` / `写 commit message`

**Phases**：
1. **提交前检查**：`git status` + `git diff` 看清改动；**lint/test 前置**——提示跑项目 lint + 测试，不通过不提交（无 pre-commit hook 时口头提示）
2. **拆分建议（核心能力）**：diff 含多个独立逻辑（bug 修复 + 新功能 + 重构混在一个 diff）→ **必须建议拆分**成多个 commit，按逻辑分组（修复/功能/重构/文档各一 commit）、分批 stage（`git add <file>` 或 `git add -p`）、逐个提交——每 commit 一个逻辑，可独立回滚
3. **commit message 规范**：`<type>(<scope>): <summary>`——type 必选（feat/fix/refactor/perf/docs/test/chore/build/ci/style/revert）；scope 可选（模块/需求标识如 `m1`）；summary 祈使句 ≤50 字符；body 只写非显然的 why；footer 关联 issue/breaking change
4. **极简风格（可选）**：用户明确要简短时用 `fix: 修登录过期`，仍保持 type 前缀

**规范**：commit 在 `feature/<需求标识>` 分支上做，不直接 commit 到主分支共享文档之外的需求代码。

### 12.2 `phper666-git-worktree` — 多需求并行开发

**触发短语**：`worktree` / `多需求并行` / `切换需求` / `多分支同时开发`

**定位**：一个需求一个 worktree = `feature/<需求标识>` 分支，多需求并行各自独立工作区，互不干扰、不切分支。

**操作**：
1. **创建**：`git worktree add <path> feature/<需求标识>`（path 建议仓库同级 `../<repo>-<需求标识>`）；创建前确认分支名 + 需求标识与共识文档一致，不凭空造
2. **列出/删除**：`git worktree list`；`git worktree remove <path>`（删除前检查无未提交改动，有 → 先提交/暂存再删；目录删了分支/提交不丢）
3. **迁移现有目录（可选）**：`git worktree add --track -b feature/<需求标识> <path> origin/main`（先确认目录内改动已提交或备份）

**规范**：一个需求一个 worktree 不跨用；需求不做 → 分支/worktree 留着（下次继续，主分支干净）；需求完成合并后 → 清理 worktree + 分支（`git branch -d` + `git worktree prune`）；主分支（共享文档）改动 → 在主仓库 worktree 操作，不在需求 worktree 混改。

### 12.3 `phper666-git-rollback` — 安全回滚

**触发短语**：`回滚` / `撤销` / `撤掉这个需求` / `回退` / `误操作`

**定位**：回滚是高风险破坏不可逆操作。核心原则：**先看清，再备份，后动手；合并过的改动绝不 reset，只 revert。**

**操作顺序（固定三步）**：
1. **先列历史看清再动**：`git status` / `git log --oneline -10` / `git branch -a` / `git log --graph --oneline main feature/<需求标识>`——不看清不动手
2. **双重确认（执行前）**：复述「将执行什么、影响什么、是否可恢复」，得确认再执行
3. **自动备份（回滚前）**：`git branch backup/<原分支>-<时间戳>`（或未提交改动 `git stash`）

**安全模式（合并后撤需求，默认）**：合并到主分支的改动撤销 = 必须 `git revert <commit>`（新增反向 commit，保留完整历史、不重写、不破坏他人）；撤销后确认 `git log --oneline` 看到反向 commit。

**危险模式（`git reset --hard`，仅限本地未推送）**：仅限目标分支未推送远程或纯本地实验分支；**禁用**：已推送/他人已拉取的分支（reset 重写历史破坏他人，此场景必须 revert）；双重确认前置。

**规范**：回滚后确认结果不静默完成；回滚了已合并需求 → 需要时走 phper666-teamflow-change-propagation 更新变更摘要（回滚也是变更）。

### 12.4 `phper666-git-pr` — PR 合并流程（三模式）

**触发短语**：`提 PR` / `合并需求` / `合并代码到主分支` / `merge`

**定位**：feature 分支开发完要合主分支的落地工具，按团队配置合并模式自动走对应流程。**三模式区别只在「merge 按钮谁按」**；「检测合并」是 semi/manual 的通用能力（merge 非 AI 自做时 AI 无法自知结果），full 不需要（AI 自己合，结果自知）。

**合并模式两级配置**（`docs/spec/团队配置.md`）：
- 项目级默认：`项目 | 默认模式 | 说明`（不配默认 full）
- 需求级覆盖（可选）：`项目 | 需求标识 | 模式 | 说明`
- 查找顺序：**需求级覆盖 > 项目级默认 > 问用户**；切换 = 改团队配置一行，不改 skill 代码

**三模式流程**：
| 模式 | AI 自主度 | 流程 |
|:-----|:----------|:-----|
| full | 全自主 | AI 提 PR → 合并 gate（slug 冲突检测）→ AI 自己 merge → 清理分支 |
| semi | 半自主 | AI 提 PR → 等人工 approve → merge（AI 或人工按）→ AI 检测合并 |
| manual | 人工 | AI 提 PR → 人工全权 merge → AI 检测合并（继续对话时） |

**检测合并**（通用）：`gh pr view <编号> --json state,mergedAt`（state=merged = 已合并，最可靠）；兜底 `git branch --merged origin/main`（feature 在列表 = 已合并）。

**合并 gate**：合并前检测需求标识唯一性（新增文档名 vs 主分支已有 slug），冲突 → 自动改名（m1 → m1b）+ 同步改引用 → 再合并。

**规范**：合并目标 feature/<需求标识> → 主分支；合并后标记完成 + `git branch -d` 清理已合并分支；合并是变更 → 需要时走 change-propagation 更新变更摘要。

---

## 13. UI 规范（`docs/ui/UI规范.md`）

**定位**：项目级视觉规范，跨需求共享。复杂 UI 原型后提取/更新，前端实现必读做视觉基准，交付核验对照。

**模板**：`templates/UI规范模板.md`（复制到项目 `docs/ui/UI规范.md` 后按项目填写）——视觉主题 / 配色 / 字体 / 组件样式 / 布局 / Do & Don'ts，含版本记录（版本/日期/变更/来源需求）。

**五处联动**（贯穿全流程）：
| 环节 | Skill | 联动 |
|:-----|:------|:-----|
| 提取/更新 | `phper666-teamflow-consensus-doc` | UI 类需求原型后 → 提取/更新 `docs/ui/UI规范.md`，写版本记录（绑定共识版本） |
| 确认/更新 | `phper666-teamflow-tech-design` | UI 类需求 → 确认/更新 UI 规范（从原型提取），前端实现时读它做视觉基准 |
| 前端实现 | `phper666-teamflow-implement-discipline` | UI 类需求前端实现前 → **必读** UI 规范，视觉实现以规范为基准；规范缺失 → 提示先建/更新，不静默自造视觉 |
| 交付核验 | `phper666-teamflow-story-to-contract` | ④ UI 视觉核验对照 UI 规范逐项核对；规范缺失 → 跳过视觉核验 + 记录风险项（不阻断） |
| 变更传播 | `phper666-teamflow-change-propagation` | UI 规范变更 → 沿引用定位受影响前端实现（绑定该版本的契约/子需求/UI 类需求）→ 提示同步更新视觉 |

---

## 14. 验证基线（`evals/`）

**定位**：验证关键 skill 的**触发准确性**与**产出符合预期**。静态检查（grep/diff）只验证「文档写对」，eval 跑真实 prompt 看 AI 是否正确触发 + 产出符合预期。

**什么时候跑（低频）**：大改动/发布 → 全量跑；高价值 skill 改动 → 跑对应 skill 用例；日常小改（文案/格式）→ 静态检查即可。

**怎么跑**：每个用例（`evals.json`）——把 prompt 给子 agent（不带目标 skill 上下文）→ 看触发哪个 skill + 产出什么 → 对照 expected/assertions 判定（`should_trigger` / `should_not_trigger`）→ 记录结果（`evals/RESULTS.md`）。

**当前覆盖**：git 四件套（commit/worktree/rollback/pr 的 should_trigger + should_not_trigger）+ consensus-doc 需求标识（有 PRD + 无 PRD 两例，产出 `共识-{模块}-{需求标识}.md` + `CON-R-{需求标识}`）。

---

*规格版本：v1.5 · 日期：2026-08-22 · 新增 git PR 合并模式（phper666-git-pr：full/semi/manual 三模式 + 检测合并 + 合并 gate + 团队配置合并模式两级表）· git 三件套 → 四件套*
*历史：v1.4（2026-08-22）：新增 git 工具三件套（phper666-git-commit/worktree/rollback）、UI 规范（docs/ui/UI规范.md）、验证基线（evals/）章节 · 需求标识机制同步最新（共识-{模块}-{需求标识}.md + CON-R-{需求标识} 编号域）*
*历史：v1.3（2026-08-16）：决策记录：4+1 边界确认 · 步骤 10 归入契约核验 · Q-items 多平台适配 · 扫描双模式（结果一致）· 新增 phper666-teamflow-tech-design/phper666-teamflow-lesson-deposit/phper666-teamflow-implement-discipline 环节 · 交付核验三层（设计/契约/PRD）· 变更摘要升级（版本分组+取代链）· 15 环节流程（需求探索前置 + 实现纪律）· 判级矩阵（复杂/常规/安全敏感）· 工程基线三问 · 术语表章节 · 多 agent 共识评审（吸收 2.5 项）· 实现前置 Gate（判级+方案冻结+工程基线三问+核验回查，缺一不进实现）· 方案状态机（draft→frozen+评审留痕，重大偏离回 draft）· 契约防漂移（单一事实源/三态锁定/CONS-02/同生同步）· docs/records/ 实现留痕*
