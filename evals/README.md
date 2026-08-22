# Eval（验证基线）

验证 ai-workflow-skills 关键 skill 的**触发准确性**与**产出符合预期**。

## 为什么用 eval

- **静态检查**（grep/diff）只验证「文档写对」，不验证「AI 按指令执行对」
- **eval**（执行验证）跑真实 prompt，看 AI 是否正确触发 skill + 产出是否符合预期——这是 skills 的真正价值

## 什么时候跑（低频）

| 时机 | 跑法 |
|:--|:--|
| **大改动/发布** | 全量跑（全部用例） |
| 高价值 skill 改动 | 跑对应 skill 用例 |
| 日常小改（文案/格式） | 静态检查即可（grep/diff） |

## 怎么跑

每个用例（`evals.json`）：
1. 把 `prompt` 给一个子 agent（不带目标 skill 上下文，模拟真实用户）
2. 看它**触发了哪个 skill** + **产出了什么**
3. 对照 `expected` 和 `assertions` 判定：
   - `should_trigger` → 应触发对应 skill，产出符合断言 → 通过
   - `should_not_trigger` → 不应误触发 → 通过
4. 记录结果（通过/失败 + 实际产出）

## 用例结构

```json
{
  "id": "git-commit-001",          // 唯一 ID
  "skill": "phper666-git-commit",  // 验证的目标 skill
  "type": "should_trigger",        // should_trigger = 该触发；should_not_trigger = 不该触发
  "prompt": "...",                 // 真实用户 prompt
  "expected": "...",               // 预期行为描述
  "assertions": ["..."]            // 具体断言（产出应符合）
}
```

## 当前覆盖

| skill | 用例 | 验证点 |
|:--|:--|:--|
| phper666-git-commit | should_trigger + should_not_trigger | 强制声明让 AI 在 commit 场景触发它（不触发 caveman） |
| phper666-git-worktree | should_trigger + should_not_trigger | worktree 场景触发，绑定 feature/<需求标识> |
| phper666-git-rollback | should_trigger + should_not_trigger | 合并后撤 = revert 优先，双重确认 |
| consensus-doc 需求标识 | 有 PRD + 无 PRD 两例 | 产出 共识-{模块}-{需求标识}.md + CON-R-{需求标识} |

## 新增用例

按上面结构往 `evals.json` 加即可。重点加：
- 高价值 skill 的触发边界（should_trigger / should_not_trigger）
- 产出断言（格式/命名/绑定关系）

## 记录结果

建议在 `evals/RESULTS.md` 记录每次跑的结果（日期 + 通过率 + 失败项），便于回归对比。
