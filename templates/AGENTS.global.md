<!-- team-workflow:begin v1 -->
## 团队 AI 研发工作流（已接入）

> 本段由 ai-workflow-skills 模板生成（templates/AGENTS.global.md），单一事实源，勿手动编辑正文。
> 更新：`git pull` ai-workflow-skills → 重新加载本段（版本号随模板 bump）。

### 工作流导航（按需求触发对应 skill）

- 建立/更新共识文档 → consensus-doc
- 扫描共识 / 处理待确认项 → consensus-scan
- 生成/更新/复核契约 → story-to-contract
- 技术方案（判级/工程基线）→ tech-design
- 实现纪律（TDD/lint/Review/Semgrep）→ implement-discipline
- 经验沉淀 → lesson-deposit
- 共识规则变更传播 → change-propagation
- 项目接入/更新 → workflow-setup
- **守卫**：当前环境未安装对应 skill → 跳过该步增强（管道顺序不变）；需要时按 ai-workflow-skills README 安装

### 实现阶段管道（强制，三层保险）

子需求实现必须按序执行，缺一不可：

1. **实现** → implement-discipline（复杂需求 TDD 核心路径；非平凡逻辑不得跳过）
2. **lint + type-check** → 自动跑，报错修复到干净
3. **Code Review** → ocr review（或团队既有机制）→ 高/中问题修复 → 重审无新增
4. **Semgrep** → 有则跑；无则核验记录记风险项
5. **留痕** → 产出「实现记录/核验记录」文件（测试/lint/review/扫描结果）
6. **交付核验** → story-to-contract 核验模式对照验收标准（设计/契约/PRD 三层）
7. **沉淀** → lesson-deposit（三硬标准过滤）

### 需求分类路由（团队流程入口）

- **模糊新需求** → 复杂：需求探索 → PRD+原型（UI 类）→ consensus-doc 建共识（绑定 PRD/原型 + 术语表）；常规：直接建共识 → 拆子需求 → story-to-contract 契约 → tech-design 判级 → 实现管道 → 变更传播 → 沉淀
- **大需求** → consensus-doc 拆子需求（§14 附录）+ tech-design 模块划分承载依赖；全部子需求核验通过后集成验证
- **卡片拆解** → 契约已存在：按契约实现（契约 + 实现管道）→ 交付核验
- **契约/规则变更** → change-propagation 检测 + 契约更新
- **术语打磨/方案审查** → 共识术语表 + 对照规则编号逐项拷问（domain-modeling / grill-with-docs 兜底）

### 文档地图

docs/spec/（共识、规则索引、团队配置、变更摘要）、docs/api/（契约）、docs/design/（技术方案）、docs/prd/（需求）、docs/prototype/（原型）、docs/lessons/（经验）

<!-- team-workflow:end v1 -->
