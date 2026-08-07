# Jira 适配器

## 平台标识

- 名称：Jira (Atlassian)
- MCP Server：`@tarasrushchak/jira-mcp-server`（内置于 OpenCode）

## 环境变量

通过 OpenCode 内置 MCP 配置，无需额外环境变量。

---

## 工具映射

### 1. parseUrl — URL 解析

```
标准 URL: https://{site}.atlassian.net/browse/{PROJECT}-{number}
Key 格式: {PROJECT}-{number}  例如 DH-12

提取: project_key=DH, issue_key=DH-12, itemType 需查 API 获取
```

只有 Key 时，需从对话或项目配置中获取 site_url。

### 2. readItem — 读工作项

```
jira_get_ticket({ ticketId: "{PROJECT}-{number}" })

返回映射:
  fields.summary     → ItemDetail.title
  fields.description → ItemDetail.description
  fields.status.name → ItemDetail.status
  fields.issuetype.name → ItemDetail.type (Story/Task/Bug/Epic/Sub-task)
  fields.assignee    → ItemDetail.assignee { accountId, displayName }
  fields.parent      → ItemDetail.parent { key, fields.summary }
  fields.subtasks    → ItemDetail.children [{ key, fields.summary }]
```

评论需单独查询：
```
jira_get_comments({ ticketId: "{PROJECT}-{number}" })
```

### 3. createItem — 创建工作项

```
# 普通 Issue
jira_create_ticket({
  projectKey: parent?.projectKey || config.defaultProject,
  summary: fields.title,
  description: fields.description,
  issuetype: fields.type,      // Story/Task/Bug
  labels: fields.labels,
})

# 子任务 (Jira sub-task)
jira_create_ticket({
  parent: parent.itemKey,
  summary: fields.title,
  description: fields.description,
  issuetype: "Sub-task",
})

返回: { issueKey, issueUrl }
```

**⚠️ Jira sub-task 是独立 issuetype，不是通过 parentId 关联。这是 Jira 独有的概念。**

### 4. addComment — 添加评论

```
jira_add_comment({
  ticketId: "{PROJECT}-{number}",
  body: "...",
})
```

### 5. getCurrentUser — 当前用户

```
jira_get_user_profile()
→ { accountId, displayName, emailAddress }
```

**⚠️ 注意用当前用户的 accountId，不要用父 Story 经办人。**

### 6. listItems — 搜索列表

```
jira_search_tickets({
  searchText: filter.keyword,
  projectKeys: "{PROJECT}",
})

或 JQL:
jira_list_tickets({
  jql: "project = {PROJECT} AND labels = ready-for-agent AND status != Closed"
})
```

---

## 概念差异：Jira 独有特性

| 特性 | 说明 | 对其他平台的影响 |
|------|------|-----------------|
| Sub-task 是独立 issuetype | Jira 子任务有独立类型名，不同于父任务 | Linear/TAPD 只是 parentId 关联 |
| Transition API | 状态变更需先查可用 transition，再执行 | TAPD/Linear/GitHub 直接设状态字段 |
| Issue Type 可切换 | Story 可以转成 Task | TAPD 不能，创建时类型固定 |
| 评论可删除 | Jira 提供删除评论 API | 其他平台多不支持 |

---

## 门禁规则

以下操作需要二次确认：

1. **回写 Jira 评论**：展示评论预览，确认后执行
2. **创建子任务**：展示子任务预览（标题、类型、经办人），确认后创建
3. **修改 Story 状态**：不做（固定边界：不修改父 Story 状态）
