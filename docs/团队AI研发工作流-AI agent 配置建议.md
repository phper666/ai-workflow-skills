# 团队 AI 研发工作流 — AI agent 配置建议

> 参考文档，非强制。团队 skills 本身角色中立、独立可用，**不配置任何 agent 也能用全流程**。
> 本表只是「哪些 AI agent 挂哪些 skills 效果更好」的建议，供使用者参考。
> 项目初期，部分搭配**待使用验证**——验证有效的会持续更新本表。

## 0. 一句话总览

团队流程 skills（phper666-teamflow-*）负责**流程编排**；专业能力（测试/设计/评审/架构）靠 **opencode slim 的角色 agent + 工具层 skills** 补足。两者松耦合：agent 是执行者，团队 skills 是流程路由。

## 1. 核心原则

1. **不配置也能用**：团队流程 skills 是角色中立的 skill，任何 agent 加载即可走流程。本表只是优化组合的建议。
2. **编排与能力分离**：流程路由（该走哪个 skill）由 orchestrator 判断；具体执行（怎么写测试/怎么设计/怎么评审）靠专业 agent + 工具 skills。
3. **建议非强制**：以下搭配来自当前使用经验，验证后会更新。你有更好的组合随时可覆盖。

## 2. 推荐搭配（基于角色切换表）

| 角色 | opencode slim agent | 挂载 skills | 说明 |
|:-----|:--------------------|:-----------|:-----|
| **pm** | orchestrator | 团队流程 skills 全部（consensus-doc / consensus-scan / story-to-contract / tech-design / implement-discipline / change-propagation / lesson-deposit） | 流程编排者，按 skill 名路由 |
| **be**（后端） | fixer | `tdd` + `codebase-design` | 后端实现：TDD 核心路径 + 深模块设计 |
| **fe**（前端） | fixer | `frontend-design` | 前端实现：视觉与交互方向 |
| **qa** | oracle | `open-code-review` | 评审与质量把关 |
| **designer** | designer | `prototype`（+ `frontend-design`） | UI 产出与原型 |
| **oracle**（架构） | oracle | `domain-modeling` + `codebase-design` | 架构决策、领域建模、代码深化 |

## 3. 工具层 skills 路由（按任务类型）

工具层 skills 是**方法论提供者**，等价工具引用，不构成流程路由。orchestrator 按任务类型挂给对应 agent：

| 任务类型 | 工具层 skill | 挂给谁 |
|:---------|:------------|:-------|
| 明确小任务（<20 行单文件） | —（直接做） | fixer |
| Bug 排查 | `diagnosing-bugs` | fixer |
| 踩坑沉淀（可选） | `phper666-teamflow-lesson-deposit` | 任意 |
| 架构改进 | `codebase-design` | fixer / oracle |
| 非平凡逻辑（分支/循环/解析器/资金/安全） | `tdd`（必挂，不得跳过） | fixer |
| 领域术语/方案拷问 | `domain-modeling` / `grill-with-docs` | oracle |
| 新需求/功能想法 | `brainstorming` | orchestrator |
| 原型验证 | `prototype` | designer |
| 通用实现 | `implement` | fixer |

## 4. 待验证搭配（项目初期，用后更新）

以下组合**尚未充分验证**，标注为待验证。使用后把有效的移入第 2 节推荐表，无效的移除。

| 待验证组合 | 场景 | 验证点 |
|:----------|:-----|:-------|
| designer + huashu-design | 正式级原型/评审/演示（多格式 MP4/PPTX） | 是否有「正式级原型」需求；与 prototype 是否互补 |
| oracle + frontend-design | 前端架构评审兼顾视觉 | 前端架构评审是否需要视觉视角 |
| fixer + domain-modeling | 后端实现中做领域建模 | 后端实现是否真的需要领域建模（vs 纯 CRUD） |

## 5. 与其他文档的关系

- **角色使用手册**（docs/团队AI研发工作流-角色使用手册.md）：讲**人的业务角色**（PM/后端/前端/QA）怎么用流程。本文讲 **AI agent 的配置**。对象不同，互补不重复。
- **orchestrator-append 模板**（templates/orchestrator-append.md）：本表是它的展开版（角色切换表 + 工具层 skill 路由的完整说明）。
