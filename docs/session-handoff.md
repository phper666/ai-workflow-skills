# 会话交接（2026-08-24）

> 新会话先读本文件接上讨论。仓库：/Users/liyuzhao/AI/project/ai-workflow-skills

## 当前状态（已完成，全部推送）

### 仓库组成
- **12 个 skills**：8 个 phper666-teamflow-*（共识/契约/实现/核验流程）+ 4 个 phper666-git-*（commit/worktree/rollback/pr）
- **全局 AGENTS.md v15**：团队工作流 + 通用编码纪律（手术式修改）+ 需求上下文清单 + 需求标识
- **README 沉淀来源表**：已落地借鉴（ZCF / anthropics/skills / Google Stitch DESIGN.md / Matt Pocock / DeepSeek Harness-pre-push-checks）
- **README 待评估借鉴段**：5 个候选概念（见下）
- **evals/**：验证基线（git 三件套 + 需求标识触发断言，低频跑）
- **install.sh + detect-git-conflicts.sh**：分发 + 冲突检测

### 最近关键改动
- `cb0c128` README 加「待评估借鉴」段
- `f179c1c` README 沉淀来源表补 DSH（push 前检查）
- `e93a2ef` git-pr 加 push 前检查纪律（最小相关测试/修复再 push/禁 raw force）
- `1fefcb9` 通用编码纪律进模板 v15
- 需求标识机制（共识-{模块}-{需求标识}.md + CON-R-{需求标识}-{序号} + 合并 gate）
- PR 合并三模式（full/semi/manual）+ 检测合并
- UI 规范最小落地（docs/ui/ + templates/UI规范模板.md）

## 下一步讨论（按价值排序）

### 待评估借鉴（README 已记，落地后移沉淀来源表）
1. **独立验收 agent**（dsh-proof）——每次 turn 前 spawn verifier 独立验收
2. **flaky 测试管理**（dsh-flakefinder）——测试稳定性分类/隔离
3. **任务台账事件溯源**（task-board）——跨会话任务审计
4. find-simplifications 证据审计（低优先，与 ponytail/simplify 重叠）

### 已评估未做
- **需求漂移守卫**（dsh-requirements-alignment）——概念通用（基线+漂移检测+上报），降级可实现（共识=基线+模型检测+问用户），但当前痛点不强（流程契约冻结已锁定方向），先记等痛点出现

### 待定
- 装 huashu-design（补 PM 原型 UI 缺口）——用户「考虑后再看」
- GitHub Pages 启用（仓库公开后）——私有阶段用 ?plain=1，公开后启用

## 关键决策记录
- **借鉴策略**：内化吸收（理解思想写自己的规则），不复制快照——外部升级不影响（除非原则级变化）
- **记录策略**：落地才记 README 沉淀来源表；候选记 README 待评估借鉴段；不建独立记录系统
- **分工定位**：团队 skills 管流程编排；专业能力靠角色 agent（slim）+ 专业 skills 补足；不困死 slim（松耦合）

## 交接原因
原会话超长（约 1700 万 tokens），输出出现重复异常。新会话接上后建议：读本文件 + 从「下一步讨论」开始，避免重新评估已讨论的。
