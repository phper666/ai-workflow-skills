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

## 怎么改配置

直接编辑 `docs/spec/团队配置.md` 对应段一行即可，改后生效，无需重跑 workflow-setup。
示例：改评审机制 → 编辑「评审机制」段的模式值（self-check → review-auto）。
存量项目没配某段 → 默认值兜底（评审 self-check、合并 full）。

## 评审指南

（从 tech-design 的「评审指南」节引用，见 phper666-teamflow-tech-design/SKILL.md）
