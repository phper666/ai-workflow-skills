---
name: phper666-teamflow-implement-discipline
metadata.source: https://github.com/phper666/ai-workflow-skills
description: 实现纪律（分级执行）：复杂需求完整流水线（TDD 核心路径 → lint 单遍 → Code Review → Semgrep 有则跑），常规需求轻量检查（lint 单次 + 工程基线三问复核），安全敏感需求强制安全扫描。工具可降级（lint/ocr/semgrep 缺失时跳过并记录，安全敏感例外）。原生实现，不依赖任何外部 skill 编排。当用户说"开始实现"、"写代码"、"实现这个功能"、或技术方案/契约已冻结进入实现阶段时使用。角色中立：不绑定任何具体 agent/平台角色。
---

# 实现纪律（分级）

契约/技术方案就绪后的实现环节。**核心原则：机器能强制的检查必须做，工具缺失可降级，安全敏感不降级。**

## 判级分流

按 phper666-teamflow-tech-design 判级矩阵进入：

| 级别 | 实现纪律 |
|:-----|:---------|
| **复杂** | 完整流水线：TDD（核心路径）→ lint 单遍 → Code Review → Semgrep（有则跑） |
| **常规** | 轻量：lint 单次 + 工程基线三问复核 |
| **安全敏感**（密钥/权限/支付/资金/数据） | 在任一级之上**强制安全扫描** |

## 完整流水线（复杂任务）

### 1. TDD（测试驱动，核心路径强制）

- 非平凡逻辑（分支、循环、解析器、资金/安全路径）必须 TDD：red → green → refactor
- 核心路径先写测试再实现；非核心路径可后补测试
- 例外（可不 TDD）：纯 UI、原型、migration、纯配置、框架胶水代码、自动生成代码、一次性脚本
- **测试分层**：单元测试必选（核心路径）；集成测试在跨模块/外部依赖时必选（模块协作、DB/API/文件系统/子进程真实协作）；e2e 可选（UI 主链路）

### 2. Lint + Type-check（单遍）

- 实现完成后跑 lint + type-check（按项目技术栈选工具：ESLint/Biome/tsc 等）
- 报错 → 修复 → 验证干净
- 编译 error → 退回实现，修复后再继续

### 3. Code Review

- 用团队既有 review 机制（ocr CLI / 人工 review / AI review）
- 高/中问题 → 修复 → 重审到无新增问题
- **solo 场景 AI review 明确算数**，结果记录在核验记录

### 4. Semgrep 安全扫描（有则跑）

- 有工具：`semgrep --config=auto .` → 报错修复 → 重扫到无错
- 无工具：普通需求 → 跳过 + 核验记录风险项（不阻断）
- **安全敏感需求例外**：必须做安全扫描——换等价工具（gitleaks/trivy/依赖扫描）或安装 Semgrep

## 工具降级原则

| 工具 | 缺失时 |
|:-----|:-------|
| lint | 跳过 → review 时人工检查风格（记录降级） |
| ocr/审查工具 | 换人工 review 或 AI review（solo 算数） |
| semgrep | 普通：跳过 + 记风险项；**安全敏感：必须**（换等价工具） |

工具缺失**不阻断流程**（安全敏感例外），降级与风险项必须记录，交付核验时可见。

## 完成标准

- 复杂：测试覆盖核心路径（单测 + 该有的集成测试）+ lint 干净 + review 无新增问题 + semgrep 0（或已记录降级）
- 常规：lint 干净 + 三问复核通过
- 完成后进入交付核验（phper666-teamflow-story-to-contract：设计/契约/PRD 三层核验）

## 纪律

- **原生实现**：本 skill 为完整内化实现，不调用外部编排体系（如 feature-pipeline 等）的 skill；工具（tdd 方法论、ocr 等）只作等价工具引用
- 不设多轮强制循环：lint/review/semgrep 各一遍，不过则修到干净，不搞轮次仪式
- 检查结果（判级结论 + 测试/lint/review/扫描）记录在 `docs/records/<id>-record.md`（两节：实现记录 + 核验记录；核验结论与风险项记核验记录节），交付核验时核对（执行钩子）；`<id>` 与技术方案（docs/design/）同 id——优先后端实现子任务 key，无 ticket 用子需求编号
- 实现中发现的契约/共识语义问题 → 走对应闭环（契约走 phper666-teamflow-story-to-contract 更新流程，共识走 phper666-teamflow-consensus-scan Q-items），不静默绕过
- 可复用的实现决策/踩坑 → 候选 lessons（phper666-teamflow-lesson-deposit 三硬标准）
