# TAPD 适配器

> 基于 `sun-jingtao/tapd-mcp-server` v18 工具，2026-07 验证。

## 平台标识

- 名称：TAPD (腾讯敏捷研发管理平台)
- 官网：https://www.tapd.cn
- MCP Server：`tapd-mcp-server`（npm: `tapd-mcp-server`）
- 安装：`npx -y tapd-mcp-server`，需配 `TAPD_ACCESS_TOKEN`

## 环境变量

| 变量 | 必填 | 说明 |
|------|------|------|
| `TAPD_ACCESS_TOKEN` | ✅ | [个人访问令牌](https://www.tapd.cn/company/my_tokens) |
| `TAPD_ALLOW_RAW_WRITE` | 可选 | 设为 `true` 才允许 `tapd_call_api` 发起 POST 写操作 |

## 真实工具清单 (18 个)

```
需求: tapd_list_stories | tapd_get_stories | tapd_create_story | tapd_writeback_story | tapd_list_story_changes | tapd_list_story_test_cases
缺陷: tapd_list_bugs | tapd_get_bugs | tapd_create_bug | tapd_writeback | tapd_list_bug_changes
附件: tapd_upload_bug_attachment | tapd_upload_bug_image | tapd_append_bug_description_image
项目: tapd_list_workspaces | tapd_list_iterations | tapd_search_users
兜底: tapd_call_api
```

**关键发现**：

- ❌ **没有 Task 工具**。Story/Bug 各有 6/5 个工具，Task 必须走 `tapd_call_api` 透传
- ❌ **没有 `tapd_get_current_user`**。用 `tapd_search_users` + 环境变量 `TAPD_NICK_NAME` 找自己
- ✅ **`tapd_get_stories` 返回包含评论**（描述、评论、附件、内嵌媒体一次性返回）
- ⚠️ **Bug 回填是 `tapd_writeback`**（不是 `tapd_writeback_bug`），Story 回填是 `tapd_writeback_story`
- ✅ **`tapd_list_stories` 支持跨项目聚合**（不传 workspace_id 自动跨项目）
- ✅ **`tapd_create_story` 支持 `parent_id`**（子需求）

---

## 6 个抽象操作映射

### 1. parseUrl — URL 解析

```
Story: https://www.tapd.cn/{workspace_id}/prong/stories/view/{story_id}
Bug:   https://www.tapd.cn/{workspace_id}/bugtrace/bugs/view?bug_id={bug_id}
Task:  https://www.tapd.cn/{workspace_id}/prong/tasks/view/{task_id}

提取 → { workspaceId, itemId, itemType: story|bug|task }
```

TAPD ID 是 19 位数字，无项目前缀。类型必须从 URL 路径判断。

### 2. readItem — 读工作项

```yaml
story → tapd_get_stories({ workspace_id, id: itemId })
        # 返回含 description + comments + attachments（一次搞定）
        
bug   → tapd_get_bugs({ workspace_id, id: itemId })
        # 返回含 description + 复现步骤 + comments + attachments

task  → tapd_call_api({ path: "/tasks", params: { workspace_id, id: itemId } })
        # ⚠️ 无专用工具，走透传
```

**字段映射**：

| TAPD 字段 | 抽象字段 | 说明 |
|-----------|----------|------|
| `Story.name` | `ItemDetail.title` | |
| `Story.description` | `ItemDetail.description` | |
| `Story.status` | `ItemDetail.status` | 中文：新建/实现中/已实现/已拒绝 |
| `Story.owner` | `ItemDetail.assignee` | nick_name |
| `Story.parent_id` | `ItemDetail.parent` | 0 表示无父需求 |
| 子需求列表 | `ItemDetail.children` | 需 `tapd_list_stories({ parent_id: itemId })` |
| 评论（包含在 get 返回中） | `ItemDetail.comments` | ✅ 不需要额外 API |
| `Story.priority_label` | 优先级 | High/Middle/Low |
| `Story.label` | `ItemDetail.labels` | 单个字符串，非数组 |

### 3. createItem — 创建工作项

```yaml
story → tapd_create_story({
          workspace_id,
          name: fields.title,
          description: fields.description,
          owner: fields.assigneeId,        # nick_name
          parent_id: parent?.itemId,       # 子需求
          priority_label: "Middle",
        })
bug   → tapd_create_bug({
          workspace_id,
          title: fields.title,
          description: fields.description,
          current_owner: fields.assigneeId,
        })
task  → tapd_call_api({                    # ⚠️ 透传
          method: "POST",
          path: "/tasks",
          body: { workspace_id, name: fields.title, ... }
        })
```

**⚠️ Task 支持受限**：TAPD MCP 无 `tapd_create_task`，需走 `tapd_call_api` 透传，且需要 `TAPD_ALLOW_RAW_WRITE=true`。

### 4. addComment — 添加评论

```yaml
story → tapd_writeback_story({
          workspace_id,
          id: itemId,
          comment: body           # 只传 comment，不碰其他字段
        })
bug   → tapd_writeback({
          workspace_id,
          id: itemId,
          comment: body
        })
task  → tapd_call_api({           # ⚠️ 透传
          method: "POST",
          path: "/tasks/add_comment",
          body: { workspace_id, id: itemId, description: body }
        })
```

**⚠️ 注意**：`tapd_writeback_story` 同时可改状态/描述/处理人/标题/优先级/迭代/标签。必须只传 `comment` 字段，防止意外覆盖。

### 5. getCurrentUser — 当前用户

```yaml
# TAPD 无 get_current_user 工具。用 search 查自己：
tapd_search_users({ keyword: "{TAPD_NICK_NAME}" })
  → 匹配 nick → { id: nick, name: nick }
```

**⚠️ 依赖 `TAPD_NICK_NAME` 环境变量**。未设置时需询问用户。

### 6. listItems — 搜索列表

```yaml
# 支持跨项目聚合（不传 workspace_id）
tapd_list_stories({
  workspace_id,          # 可选：不传则跨项目
  name: filter.keyword,  # 模糊匹配名称
  status: filter.status,
  owner: filter.assigneeId,
  label: filter.labels?.[0],  # ⚠️ TAPD label 是单字符串
})

# Bug 同理：
tapd_list_bugs({ workspace_id, title: filter.keyword, status: filter.status })
```

---

## 真实差异：与 Jira 的关键分歧

| 维度 | Jira | TAPD 真实情况 | 影响 |
|------|------|-------------|------|
| **工作项模型** | Issue 统一容器 | Story/Bug/Task 三套独立工具 | Phase 1 需类型分支 |
| **评论获取** | 独立 API `get_comments` | `get_stories` 返回自带评论 | ✅ 比预期简单 |
| **评论写入** | 独立 API `add_comment` | `writeback` 工具可同时改多个字段 | ⚠️ 必须只传 comment |
| **子任务** | Sub-task 独立类型 | 子需求 (parent_id)，类型仍是 Story | Phase 9 语义不同 |
| **Task 支持** | 完整 | ❌ 无专用工具，必须透传 | 重大限制 |
| **当前用户** | `get_user_profile` | 无专用工具，靠 `search_users` | 需环境变量 |
| **状态变更** | Transition API | 直接设 status 字段（writeback） | 跳过 transition 查询 |
| **标签** | 数组 | 单个字符串 | 多标签需特殊处理 |
| **跨项目查询** | 需逐个 project | `list_stories` 不传 workspace 自动聚合 | ✅ 比 Jira 方便 |

---

## 门禁规则

所有写操作执行前需在对话中确认（MCP Server 内置此机制）：

1. `tapd_writeback_story` / `tapd_writeback`：展示 preview → 用户 OK → 执行
2. `tapd_create_story`：展示 preview（标题、父需求、处理人）→ 确认 → 创建
3. `tapd_call_api` (POST)：需 `TAPD_ALLOW_RAW_WRITE=true` + 每次显式确认

---

## 限制

1. **Task 功能残缺**：无专用工具，`tapd_call_api` 透传体验差。推荐：统一用 Story 类型承载工作项，Bug 类型承载缺陷。Task 类型仅做透传兜底。
2. **无 workflow transition**：不知道当前状态能转换到哪些状态。写 status 时可能传无效值。
3. **子需求≠子任务**：子需求仍是完整 Story（有独立状态、处理人），不是 Jira sub-task。
