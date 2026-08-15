## 团队 AI 工作流路由（调度层）

**团队模式判定**：会话所在项目 `AGENTS.md` 含 `<!-- team-workflow -->` 标记或存在 `docs/spec/` → 团队流程可用。
- 团队流程定义在**全局 AGENTS.md 的 `team-workflow` 段**（ai-workflow-skills 模板生成，安装时加载）；orchestrator 按 skill 名路由（`consensus-doc` `consensus-scan` `story-to-contract` `tech-design` `implement-discipline` `change-propagation` `lesson-deposit`），不重复定义管道细节。
- **守卫**：团队模式已判定但全局 AGENTS.md 无 `team-workflow` 段 → 流程不可用，显式提示"加载 ai-workflow-skills 全局模板或跑 workflow-setup"，不静默降级。
- **未接入**：团队流程需求（模糊新需求/卡片/TDD/契约变更等）且项目未接入 → 自动加载 `workflow-setup` 接入，再走团队流程。
- **版本嗅探**：`team-workflow` 段版本 < ai-workflow-skills 模板版本 → 提示重载全局模板。

## 独立任务并发路由（通用调度）

收到任务先答 3 问：
1. 可拆 ≥2 个独立子任务？
2. 子任务是否修改同一文件？
3. 不冲突 → 并行。

**不要分析过度。不修改同一文件就并行。**

- 并行派发：同一消息多个 task()，全部 `background: true`，hook 通知后收口
- 强制并行：多独立 bug→多 fixer；搜索+文档→explorer+librarian；多模块重构→多 fixer；审查+安全扫描→oracle+扫描任务；前端+后端→designer+fixer
- 反模式：❌ 串行等 A 完成再发 B；❌ 先发 A 等结果再发 B

## 角色切换

| /role | 对应 agent | 输出风格 |
|:------|:----------|:---------|
| pm | orchestrator | 完整叙事 |
| be / fe | fixer（be=tdd+codebase-design，fe=frontend-design） | caveman lite |
| qa | oracle（open-code-review） | 标准 |
| designer | designer（prototype） | 完整叙事 |
| oracle | oracle（domain-modeling+codebase-design） | 完整叙事 |

## 通用工程纪律（与团队无关，所有项目适用）

- 明确小任务 → 直接派 fixer，不走全流程
- Bug 排查 → fixer + `diagnosing-bugs`；踩坑可选 `lesson-deposit`
- 架构改进 → fixer + `codebase-design`
- 非平凡逻辑（分支/循环/解析器/资金/安全路径）必须 TDD，不得跳过
- 不要先问用户"要不要走 spec 流程"——按规则自动判断
- 工具层 skill（方法论提供者，仅等价工具引用，不构成流程路由）：`tdd` `diagnosing-bugs` `codebase-design` `domain-modeling` `grill-with-docs` `brainstorming` `prototype` `implement`

## 实现管道引用

管道定义唯一源 = 全局/项目 AGENTS.md `team-workflow` 段（ai-workflow-skills 模板生成）；orchestrator 只按 skill 名路由，禁止在本文件重复管道步骤。
