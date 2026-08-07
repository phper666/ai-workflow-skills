# 适配器接口规范

每个 PM 平台适配器必须实现以下 6 个操作。SKILL.md 只调用这些抽象操作，不直接引用任何平台的 MCP 工具名。

---

## 操作定义

### 1. parseUrl(url: string) → ItemRef

从 URL 或 Key 提取定位信息。

```
输入: "https://www.tapd.cn/12345678/prong/stories/view/1123456789001000001"
输出: { workspaceId: "12345678", itemId: "1123456789001000001", itemType: "story" }

输入: "DH-12"
输出: { projectKey: "DH", itemKey: "DH-12", itemType: "story" }
```

### 2. readItem(ref: ItemRef) → ItemDetail

读取工作项完整信息。

```
输出: {
  key: "DH-12",
  url: "https://...",
  title: "告警中心",
  description: "...",
  status: "In Progress",
  type: "story",        // story | bug | task | epic
  assignee: { id: "...", name: "张三" },
  parent: null | { key: "...", title: "..." },
  children: [{ key: "...", title: "...", type: "subtask" }],
  comments: [{ author: "李四", body: "...", created: "..." }],
  labels: ["ready-for-agent"],
}
```

### 3. createItem(parent: ItemRef | null, fields: CreateFields) → ItemRef

创建工作项（含子任务）。

```
输入: { title: "...", description: "...", type: "story", assigneeId: "..." }
输出: { key: "DH-13", url: "https://..." }
```

### 4. addComment(ref: ItemRef, body: string) → void

给工作项添加评论。

### 5. getCurrentUser() → User

```
输出: { id: "...", name: "张三", email: "..." }
```

### 6. listItems(workspaceId: string, filter: ItemFilter) → ItemRef[]

搜索/列出工作项。

```
输入: { type: "story", status: "open", labels: ["ready-for-agent"] }
输出: [{ key: "DH-12", title: "...", status: "...", type: "story" }]
```

---

## 类型定义

```
ItemRef:     { workspaceId?, projectKey?, itemId, itemKey?, key, url, itemType }
ItemDetail:  ItemRef + { title, description, status, assignee, parent, children, comments, labels }
CreateFields:{ title, description, type, assigneeId?, labels? }
ItemFilter:  { type?, status?, labels?, assigneeId?, keyword? }
User:        { id, name, email? }
```

---

## 概念映射表

不同平台对同一概念叫法不同，适配器负责翻译：

| 抽象概念 | Jira | Linear | GitHub | TAPD |
|----------|------|--------|--------|------|
| 工作项 | Issue | Issue | Issue | 需求(Story)/缺陷(Bug)/任务(Task) |
| 子任务 | Sub-task | Sub-issue(parentId) | ❌ (task list) | 子需求(parent_id) |
| 经办人 | Assignee | Assignee | Assignee | 处理人(owner) |
| 迭代 | Sprint | Cycle | Milestone | 迭代 |
| 项目 | Project | Team | Repository | 工作空间(workspace) |

---

## 适配器文件规范

每个适配器文件包含：

1. **平台标识**：名称、URL 模式
2. **环境变量**：认证所需
3. **工具映射表**：6 个抽象操作 → 具体 MCP 工具名 + 参数映射
4. **概念差异说明**：该平台特有的限制和行为
5. **URL 解析规则**：如何从 URL/Key 提取定位信息
