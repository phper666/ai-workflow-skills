<!-- team-workflow:begin v14 -->
## 团队 AI 研发工作流（已接入）

> 本段由 ai-workflow-skills 模板生成（templates/AGENTS.global.md），单一事实源，勿手动编辑正文。
> 更新：`git pull` ai-workflow-skills → 重新加载本段（版本号随模板 bump）。

### 工作流导航（按需求触发对应 skill）

- 建立/更新共识文档 → phper666-teamflow-consensus-doc
- 扫描共识 / 处理待确认项 → phper666-teamflow-consensus-scan
- 生成/更新/复核契约 → phper666-teamflow-story-to-contract
- 技术方案（判级/工程基线）→ phper666-teamflow-tech-design
- 实现纪律（TDD/lint/Review/Semgrep）→ phper666-teamflow-implement-discipline
- 经验沉淀 → phper666-teamflow-lesson-deposit
- 共识规则变更传播 → phper666-teamflow-change-propagation
- 项目接入/更新 → phper666-teamflow-workflow-setup
- **守卫**：当前环境未安装对应 skill → 跳过该步增强（管道顺序不变）；需要时按 ai-workflow-skills README 安装

### 分支模型（共享文档 vs 需求专属）

- **主分支 = 共享文档**：PRD/原型/共识/规则索引/团队配置——单一事实源，集中维护
- **feature 分支 = 需求专属**：代码 + 契约/设计/记录（`feature/<需求标识>`）——需求标识隔离，合并不冲突
- **需求不做 → feature 分支留着**（代码+文档都不合并），下次做继续，主分支干净
- **改共享文档前** → 先 merge 主分支最新（减少冲突窗口）
- **固定时序**：共识定稿（主分支直推）→ **开 `feature/<需求标识>` 分支** → 契约/设计/记录在 **feature 分支上生成** → 代码实现 → 需求完成合并 / 不做留分支。**契约/设计/记录不直接写主分支**（需求专属，跟代码走分支）

### PR 合并模式（feature → 主分支，走 PR）

feature 分支开发完 → 提 PR 合主分支（phper666-git-pr 自动走对应流程）。三模式按 AI 自主度分档，**区别只在「merge 按钮谁按」**：

- **full（全自主）**：AI 提 PR → 合并 gate → AI 自己 merge → 清理分支
- **semi（半自主）**：AI 提 PR → 等人工 approve → merge（AI 或人工按）→ AI 检测合并
- **manual（人工）**：AI 提 PR → 人工全权 merge → AI 检测合并（继续对话时）

**检测合并是通用能力**（semi + manual 都要，merge 非 AI 自做时 AI 无法自知结果）：`gh pr view <编号> --json state,mergedAt`（state=merged = 已合并），或 `git branch --merged origin/main`。full 不需要（AI 自己合，结果自知）。

**配置两级（团队配置.md 合并模式表）**：需求级覆盖（`项目 | 需求标识 | 模式`）> 项目级默认（`项目 | 默认模式`）。切换模式 = 改团队配置一行，不改 skill 代码。

### 需求标识唯一性 = 合并 Gate（强制）

feature 分支合并到主分支时，**主分支是唯一事实源**：

1. **检测**：新增文档名是否与主分支已有 slug 冲突（需求标识唯一性）
2. **冲突则自动改名**（m1 → m1b）+ 同步改引用 → 再合并

> 检测放在**合并时**而非生成前：生成前有竞态窗口（检查到提交之间别人占用），合并时主分支无竞态。

### 实现前置 Gate（契约冻结 → 实现之间，强制）

进入实现管道前必须完成，**缺一项不得开始实现**：

1. **判级** → 跑 phper666-teamflow-tech-design 判级，结论（复杂/常规/安全敏感）+ 一句理由，写入实现记录
2. **复杂/高风险** → 必产 `docs/design/<id>-<module>-design.md` 且评审通过（**方案冻结**，状态约定见 phper666-teamflow-tech-design）；**无方案文档或未冻结 = 不得进入实现管道**
3. **工程基线三问** → git/脚手架/测试框架逐项核验；缺失先搭（脚手架搭建属判级环节，不算实现步骤）
4. **核验回查** → 交付核验的「判级匹配」对照实现复杂度，判级缺失或明显错判 → 核验不通过

### 实现阶段管道（强制，三层保险）

子需求实现必须按序执行，缺一不可：

1. **实现** → phper666-teamflow-implement-discipline（复杂需求 TDD 核心路径；非平凡逻辑不得跳过）
2. **lint + type-check** → 自动跑，报错修复到干净
3. **Code Review** → ocr review（或团队既有机制）→ 高/中问题修复 → 重审无新增
4. **Semgrep** → 有则跑；无则核验记录记风险项
5. **留痕** → 产出「实现记录/核验记录」文件（测试/lint/review/扫描结果）
6. **交付核验** → phper666-teamflow-story-to-contract 核验模式对照验收标准（设计/契约/PRD 三层）
7. **沉淀** → phper666-teamflow-lesson-deposit（三硬标准过滤）

### 需求分类路由（团队流程入口）

- **模糊新需求** → 复杂：需求探索 → PRD+原型（UI 类）→ phper666-teamflow-consensus-doc 建共识（绑定 PRD/原型 + 术语表）；常规：直接建共识 → 拆子需求 → phper666-teamflow-story-to-contract 契约 → phper666-teamflow-tech-design 判级 → 实现管道 → 变更传播 → 沉淀
- **大需求** → phper666-teamflow-consensus-doc 拆子需求（§14 附录）+ phper666-teamflow-tech-design 模块划分承载依赖；全部子需求核验通过后集成验证
- **卡片拆解** → 契约已存在：按契约实现 → phper666-teamflow-tech-design 判级（复杂/高风险先出技术方案再实现；常规直接实现）→ 实现管道 → 交付核验
- **契约/规则变更** → phper666-teamflow-change-propagation 检测 + 契约更新 → 判级（变更传播后重新判级）→ 实现管道
- **散任务类**（Bug/优化/调研/测试/文档/重构，无共识无契约）→ 判级 → 轻量实现管道（常规直接实现；复杂先技术方案；安全敏感强制扫描）→ **触发条件**：规则歧义 → 升级 Q-item 进共识；触 API → 变更传播更新契约
- **术语打磨/方案审查** → 共识术语表 + 对照规则编号逐项拷问（domain-modeling / grill-with-docs 兜底）

### 文档地图

docs/spec/（共识、规则索引、团队配置、变更摘要、变更摘要-<模块>.md）、docs/api/（契约）、docs/design/（技术方案）、docs/prd/（需求）、docs/prototype/（原型）、docs/ui/（UI 规范：项目级视觉规范，配色/字体/组件/布局）、docs/lessons/（经验）

### 需求上下文清单（按需加载，防上下文爆炸）

**项目大时不全量扫**——新人/AI 做需求时按「需求标识」按需加载上下文，只读该需求相关，不读无关需求/历史：

1. **AGENTS.md 导航段**（本项目入口，必读）
2. **团队配置.md**（合并模式/角色映射/载体）
3. **需求共识** `共识-<模块>-<需求标识>.md`（当前态，不读历史版本——历史在变更摘要）
4. **需求契约** `*<需求标识>*`（glob 定位，如 `ls docs/api/*m1*`）
5. **相关规则**（规则索引 CON-R-<需求标识>*）
6. **相关模块共识**（跨模块时才读）

**加载纪律**：
- 分层读取：先读摘要/索引（小）定位 → 需要详情再读具体文档/章节（grep/ctx_search 定位），**不全量读整份大文档**
- 共识文档只读**当前态**（最新版本），历史演进在变更摘要（按需）
- 完成需求 → 上下文聚焦该需求，不沉淀无关历史到上下文

> 需求标识 = PRD slug（复杂需求）/ 需求 slug（常规需求），见分组视图约定。

### 文档目录政策（禁止重构）

- **目录是装饰层，禁止扫目录导航**：AI 找文档靠规则编号（CON-Rxxx）+ 固定路径 + 规则索引 + 变更摘要 + 本导航段，不靠 `ls` 目录。文件多不是问题，不要提议按模块/期拆目录
- **分组视图在文件名前缀**：期前缀（S1/B1）+ 需求标识（`feishu-s1-m1-api-contract.md`，复杂需求=PRD slug、常规需求=需求 slug）已编码模块/期/需求，glob 即分组（`ls docs/api/*m1*`）
- **升级触发器**：仅当单目录 > 3k-5k 文件或全量 glob 打爆上下文时，才考虑局部升级（模块顶层 → 模块内按期）；升级前必须过「幂等性 + 硬编码路径 + 分发模板兼容」三问，且不移动存量文件
- **变更摘要滚动归档**：L2 模块文件 `docs/spec/变更摘要-<模块>.md` >100 条 或 跨年 → `git mv` 为 `变更摘要-<模块>-<年份>.md`，指针永远指向当前文件（L1 索引 `变更摘要.md` 永小，不轮转）

### git 工具优先级（默认强制）

- **git commit** → phper666-git-commit（默认强制：Conventional Commits + 拆分建议 + lint/test 前置）
- **git worktree** → phper666-git-worktree（默认强制：多需求并行，一个需求一个 worktree，绑定 feature/<需求标识>）
- **git rollback** → phper666-git-rollback（默认强制：合并过的主分支改动 revert 不 reset，reset 仅限本地未推送，回滚前备份 + 双重确认）
- **git PR 合并** → phper666-git-pr（默认强制：提 PR / 合并需求 / 合并代码到主分支，按团队配置合并模式 full/semi/manual 走流程 + 合并 gate slug 冲突检测）
- **其他第三方 git skill**（commitizen / 其他 commit 风格 / worktree / rollback / PR 类）→ 保留但不默认触发，仅用户显式指定时用
- **用户显式指定某个 skill**（如 `/caveman-commit`）→ 尊重用户选择，不覆盖
- **冲突双保险**：本优先级声明（AGENTS 层）+ 各 skill description 强制声明（skill 层）；检测到同类 skill 冲突见 install.sh 提示

### 通用编码纪律（团队所有项目适用）

- **改代码边界（手术式修改）**：只碰必须碰的，不顺手重构/改格式/改相邻代码；清理**自己改动产生**的孤儿（import/变量/函数），不删既有死代码（除非用户要求）；每行改动可追溯到用户请求
- **最小改动**：不投机、不加未请求的功能/抽象/配置；标准库优先，一行够不写五十行

<!-- team-workflow:end v15 -->
