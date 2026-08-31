# 团队 AI 研发工作流 — 配置说明

> 本文档说明项目接入后，`docs/spec/团队配置.md` 里有哪些可配置项、哪些有模式、选不同模式什么效果、怎么改。新用户/新 AI 先读本文档再决定配置。

## 可配置项总览

| 配置段 | 用途 | 有模式? | 谁读 |
|:---|:---|:---|:---|
| 项目载体 | 项目用哪个 PM 平台 + 载体标识 | 6 平台（lark-task/jira/tapd/linear/github/openproject） | story-to-contract |
| Q-items 载体 | 待确认项存哪 | 同上 | consensus-scan |
| status_map | 抽象状态 → 载体实际状态 | 平台映射不同 | scan / story-to-contract |
| 角色映射 | 角色 → 账号 | 谁负责谁 | scan / change-propagation |
| 合并模式 | PR 合并怎么走 | ✅ 3 模式 | git-pr |
| 评审机制 | 技术方案怎么评审 | ✅ 4 模式 | tech-design |
| worktree 模式 | 分支开发怎么建工作区 | ✅ 3 模式 | git-worktree |

## 有模式的配置

### 合并模式（git-pr）
| 模式 | 含义 | merge 按钮谁按 |
|:---|:---|:---|
| full | AI 提 PR + AI 自己 merge + 清理 | AI |
| semi | AI 提 PR + 等人工 approve + merge | AI 或人工 |
| manual | AI 提 PR + 人工全权 merge | 人工 |

查找顺序：需求级覆盖 > 项目级默认 > 问用户

### 评审机制（tech-design，技术方案评审）
| 模式 | 含义 | 交互 |
|:---|:---|:---|
| self-check | AI 自查通过即 frozen | 不打扰用户（默认） |
| review | 先给用户 review 再 frozen | 用户不表态则阻塞 |
| review-auto | 先给用户 review（给选项 A/B/C），用户跳过则 AI 自查 | 不阻塞也不黑盒（推荐） |
| gate | 正式 Gate 评审，留痕 | 多人团队 |

review-auto 交互：方案 draft → AI 问用户 [A]通过 [B]要改 [C]跳过 → A 冻结 / B 修订再确认 / C AI 自查冻结

### worktree 模式（git-worktree）
| 模式 | 含义 | 适合场景 |
|:---|:---|:---|
| auto | AI 判断——多需求并行/持续开发 → worktree（一需求一目录，目录即分支）；单文件单 commit 小修 → 主目录直切，完成后必须回 main | 大多数项目（默认） |
| always | 所有分支开发一律 worktree，无例外 | 多会话/多人并行频繁的项目 |
| manual | 不用 worktree，主目录切分支，收尾必须回 main | 不想多目录、需求串行的项目 |

查找顺序：需求级覆盖 > 项目级默认 > 默认 auto

配套纪律（不管什么模式都适用，详见 phper666-git-worktree「收尾纪律」）：
- **收尾回 main**：开发完成/暂停 → 主目录切回 main（分支提交不丢，回来 checkout 接上）——防止新会话加载错分支
- **ticket 验收清理**：ticket 移 Done（交付核验通过）→ 检测对应 worktree 三重门（ticket Done + 分支已合并 + 无未提交改动）→ 满足则清理（worktree remove + branch -d + prune），不满足则不清理 + 报告原因——worktree 存活期 = ticket 生命周期，防目录爆炸

## 怎么改配置

直接编辑 `docs/spec/团队配置.md` 对应段一行即可，改后生效，无需重跑 workflow-setup。
示例：改评审机制 → 编辑「评审机制」段的模式值（self-check → review-auto）。
存量项目没配某段 → 默认值兜底（评审 self-check、合并 full、worktree auto）。

## 评审指南

（从 tech-design 的「评审指南」节引用，见 phper666-teamflow-tech-design/SKILL.md）
