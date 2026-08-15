# Linear 适配器

## 平台标识

- 名称：Linear
- API：**GraphQL** `https://api.linear.app/graphql`（⚠️ 实测 REST v1 端点 /v1/* 已不存在，2026-08 返回 404 "Cannot GET"）
- 认证：`Authorization: {API_KEY}`（**裸 key，不要加 Bearer**——带 Bearer 会返回 "Remove the Bearer prefix"）

## 环境变量

```
LINEAR_API_KEY    # Settings → Account → Security & access → Personal API keys
LINEAR_TEAM_ID    # 可选，默认 team（teams query 获取）
```

认证方式：
```
Authorization: lin_api_xxx
Content-Type: application/json
POST https://api.linear.app/graphql  {"query": "..."}
```

---

## 工具映射

### 1. parseUrl — URL 解析

```
标准 URL: https://linear.app/{workspace}/issue/{KEY}   例如 linear.app/yuzhao-test/issue/YUZ-12
Key 格式: {TEAM}-{number}   例如 YUZ-12

提取: teamKey=YUZ, issueNumber=12, itemType 需查 API（Linear 无原生类型，用 label 区分）
```

### 2. readItem — 读工作项

```
query {
  issue(id: "{id}") {          # 或 issue(identifier: "YUZ-12")
    id identifier title description state { name } assignee { id name }
    labels { nodes { name } } parent { id identifier title }
    children { nodes { id identifier title } }
    createdAt updatedAt
  }
}

返回映射:
  identifier  → ItemDetail.key（YUZ-12）
  title       → ItemDetail.title
  description → ItemDetail.description
  state.name  → ItemDetail.status（Todo/In Progress/Done/Backlog/Canceled）
  assignee    → ItemDetail.assignee { id, name }
  labels      → ItemDetail.labels（类型区分：bug 用 label，Q-item 用 label）
  parent      → ItemDetail.parent（子任务 parentId 关联）
  children    → ItemDetail.children
```

评论（单独查询）：
```
query { issue(id: "{id}") { comments { nodes { id body user { name } createdAt } } } }
```

### 3. createItem — 创建工作项

```
mutation {
  issueCreate(input: {
    title: fields.title,
    description: fields.description,
    teamId: "{TEAM_ID}",                    // 必填（parent 或默认 team）
    parentId: parent?.itemId,               // 子任务：parent 关联（Linear 无独立子任务类型）
    labelIds: [...]                         // 类型/标签（bug 等）
    assigneeId: fields.assigneeId,
  }) { success issue { id identifier } }
}

返回: { id, identifier } → ItemRef { itemId: id, key: identifier, url: "https://linear.app/{workspace}/issue/{identifier}" }
```

**⚠️ Linear 无原生 issue 类型（Story/Bug/Task 字段不存在）**——类型用 label 区分：
- story → 无 label 或 label `story`
- bug → label `bug`（Linear 创建时默认有 bug label 模板）
- Q-item → label `q-item`
- 子任务 → parentId 关联（与 OpenProject/TAPD 一致）

### 4. addComment — 添加评论

```
mutation {
  commentCreate(input: { issueId: "{id}", body: "..." }) { success comment { id } }
}
```

### 5. getCurrentUser — 当前用户

```
query { viewer { id name email } }
→ { id, name, email }
```

**⚠️ 注意用 API key 所属用户（viewer），不要用父 issue 经办人。**

### 6. listItems — 搜索列表

```
query {
  issues(filter: {
    team: { id: { eq: "{TEAM_ID}" } },
    state: { type: { neq: "completed" } },      # 排除已完成
    labels: { name: { eq: "q-item" } },          # 按标签过滤
    title: { contains: "{keyword}" },
    parent: { id: { eq: "{parentId}" } }         # 查子任务
  }, first: 50) { nodes { id identifier title state { name } } }
}
```

过滤器语法：Linear GraphQL 过滤是 `{ 字段: { 操作符: 值 } }`，操作符：eq/neq/contains/in 等。

---

## 概念差异：Linear 独有特性

| 特性 | 说明 | 影响 |
|------|------|------|
| 无原生 issue 类型 | 没有 Story/Bug/Task 类型字段 | 用 label 区分（bug/q-item 等） |
| 子任务=parentId | Sub-issue 通过 parentId 关联 | 与 OpenProject/TAPD 一致，与 Jira 不同 |
| REST v1 已移除 | /v1/* 全部 404 | **必须用 GraphQL**（实测 2026-08） |
| 认证=裸 key | Bearer 前缀会报错 | 严格 `Authorization: {key}` |
| Key 格式 | {TEAM}-{number}（YUZ-12） | 与 Jira 的 PROJECT-NUMBER 相似 |
| 状态组 | Todo/Backlog/In Progress/Done/Canceled/Duplicate（类型分 unstarted/backlog/started/completed/canceled/duplicate） | 按 type 判断 open/closed |
| 免费版限制 | 250 issues 上限、2 teams | Q-item 量大需升 Basic |
| 删除=归档 | 无硬删除，issueArchive 软删 | 清理测试数据用 archive |

---

## 门禁规则

与 Jira 适配器一致：

1. **回写评论**：展示评论预览，确认后执行
2. **创建子任务**：展示预览（标题、parent、label），确认后创建
3. **修改父 issue 状态**：不做（固定边界：不修改父工作项状态）

---

## 实测记录（2026-08，Linear 免费版）

- 认证：裸 key 有效；Bearer 报 "Remove the Bearer prefix"；REST /v1/* 404
- team：`{ teams { nodes { id key name } } }` 可查（YUZ / Yuzhao-test）
- states：Todo(unstarted)/Backlog(backlog)/In Progress(started)/Done(completed)/Canceled(canceled)/Duplicate(duplicate)
- issueCreate/commentCreate/issueArchive 均实测通过
