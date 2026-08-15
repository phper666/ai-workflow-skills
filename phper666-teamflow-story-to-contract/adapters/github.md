# GitHub Issues 适配器

## 平台标识

- 名称：GitHub Issues
- MCP：OpenCode 内置 github MCP（`github_*` 工具，已认证）
- REST 备选：`https://api.github.com`（需 `GITHUB_TOKEN`，用于 MCP 未覆盖的操作如读评论）

## 环境变量

```
GITHUB_TOKEN    # 可选（REST 备选路径用；MCP 路径无需）
```

---

## 工具映射

### 1. parseUrl — URL 解析

```
标准 URL: https://github.com/{owner}/{repo}/issues/{number}
Key 格式: {owner}/{repo}#{number}   例如 phper666/ai-workflow-skills#12

提取: owner, repo, issueNumber, itemType 需查 API（GitHub 用 label 区分类型）
```

### 2. readItem — 读工作项

```
github_get_issue({ owner, repo, issue_number })

返回映射:
  title        → ItemDetail.title
  body         → ItemDetail.description
  state        → ItemDetail.status（open/closed）
  labels       → ItemDetail.labels（类型区分：bug/q-item 等）
  assignee.login → ItemDetail.assignee { name }
  milestone.title → ItemDetail.迭代信息
```

评论（MCP 无 issue 评论读取工具，用 REST 备选）：
```
GET https://api.github.com/repos/{owner}/{repo}/issues/{number}/comments
（需 GITHUB_TOKEN）
```

**⚠️ GitHub Issue 无父子层级**——子任务用 body 内 task list（`- [ ]`）模拟，无法通过 API 结构化关联。

### 3. createItem — 创建工作项

```
# 普通 Issue
github_create_issue({
  owner, repo,
  title: fields.title,
  body: fields.description,
  labels: fields.labels,        // 类型用 label（bug/q-item 等）
  assignees: [fields.assigneeId],
})

# "子任务"：GitHub 无原生子任务——在父 issue body 追加 task list 项
github_update_issue({
  owner, repo, issue_number: parent.itemId,
  body: 原body + "\n- [ ] " + fields.title,
})

返回: { number, html_url } → ItemRef { itemId: number, key: "{owner}/{repo}#{number}", url }
```

### 4. addComment — 添加评论

```
github_add_issue_comment({ owner, repo, issue_number, body })
```

### 5. getCurrentUser — 当前用户

```
github_search_users({ q: "@me" })   # 或 REST: GET /user（需 GITHUB_TOKEN）
→ { login, name }
```

**⚠️ 用 token/MCP 当前用户，不要用父 issue 经办人。**

### 6. listItems — 搜索列表

```
github_list_issues({ owner, repo, state: "open", labels: "q-item" })
或 github_search_issues({ q: "repo:{owner}/{repo} label:q-item state:open" })

→ items[]: { number, title, state, labels[] }
```

---

## 概念差异：GitHub 独有特性

| 特性 | 说明 | 影响 |
|------|------|------|
| **无父子层级** | Issue 无 parent/children | 子任务用 body task list `- [ ]` 模拟（interface.md 概念映射已标注） |
| 无原生类型 | 类型语义用 labels | bug/q-item 等 label 约定 |
| 状态仅 open/closed | 无中间态 | answered 用 label `q-answered` 表达 |
| 代码同平台 | 仓库即工作区 | issue 天然关联代码/PR |
| 迭代 | Milestone | 可用作迭代载体 |
| 认证 | MCP 免配置 / REST 需 PAT | 优先 MCP 路径 |
| 评论读取 | MCP 无专门工具 | REST 备选（GITHUB_TOKEN） |

---

## 门禁规则

与 Jira 适配器一致：

1. **回写评论**：展示评论预览，确认后执行
2. **创建"子任务"**：展示 task list 追加预览，确认后更新父 issue
3. **修改父 issue 状态**：不做（固定边界：不修改父工作项状态）

---

## Q-items 载体（GitHub 场景）

- 载体：Issue + labels（`q-item`、`q-p0`/`q-p1`/`q-p2`、`q-be`/`q-fe`/`q-qa`/`q-pm`）
- 结构化信息（共识版本/规则编号/回写位置）：Projects v2 自定义字段（需 UI 配置）或 issue body 约定格式
- answered 态：label `q-answered`
- 详见 `phper666-teamflow-consensus-scan/references/载体适配.md`
