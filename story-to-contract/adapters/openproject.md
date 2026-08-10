# OpenProject 适配器

## 平台标识

- 名称：OpenProject
- API：REST API v3（`{OPENPROJECT_URL}/api/v3`）
- 认证：API key（Basic Auth 用户名固定为 `apikey`）——**2FA 用户禁用密码认证，API key 是唯一可靠方式**（实测 2026-08）

## 环境变量

```
OPENPROJECT_URL        # 例如 http://localhost:8080（自部署）或 https://xxx.openproject.com
OPENPROJECT_API_KEY    # UI 生成：我的账号 → 访问令牌 → 创建 API 令牌
```

认证方式：
```
Authorization: Basic base64("apikey:{OPENPROJECT_API_KEY}")
```

---

## 工具映射

### 1. parseUrl — URL 解析

```
标准 URL: {OPENPROJECT_URL}/work_packages/{id}
或:       {OPENPROJECT_URL}/projects/{projectIdentifier}/work_packages/{id}
Key 格式: wp-{id}（OpenProject 无 PROJECT-NUMBER 格式，用 id 合成）

提取: itemId={id}, projectIdentifier（如可获取）, itemType 需查 API
```

只有 Key（wp-{id}）时，需从对话或项目配置获取 OPENPROJECT_URL。

### 2. readItem — 读工作项

```
GET {OPENPROJECT_URL}/api/v3/work_packages/{id}

返回映射:
  subject                → ItemDetail.title
  description.raw        → ItemDetail.description
  status.name            → ItemDetail.status（如 New/In progress/Closed）
  _type                  → "WorkPackage"（类型在 _links.type）
  _links.type.title      → ItemDetail.type（User story/Bug/Task/Feature/Epic）
  _links.assignee.title  → ItemDetail.assignee { name }
  _links.parent.href     → ItemDetail.parent（从 href 提取 id，再查 subject）
  _links.children         → 需逐个 GET（或查 filters parent 关联）
  _links.project.title   → 项目名
```

评论/活动（单独查询）：
```
GET {OPENPROJECT_URL}/api/v3/work_packages/{id}/activities
→ 每条 activity: comment.raw（评论内容）, comment.author.name, createdAt
```

### 3. createItem — 创建工作项

```
POST {OPENPROJECT_URL}/api/v3/work_packages
Body:
{
  "subject": fields.title,
  "description": { "raw": fields.description },
  "_links": {
    "type": { "href": "/api/v3/types/{typeId}" },        // 需先查 /types 拿类型 id
    "project": { "href": "/api/v3/projects/{projectId}" }
  }
}

# 子任务（OpenProject 用 parent 关联，无独立子任务类型）
Body 追加:
  "_links": { "parent": { "href": "/api/v3/work_packages/{parentId}" } }

返回: { id, _links.self.href } → ItemRef { itemId: id, key: "wp-{id}", url }
```

**⚠️ OpenProject 无独立 Sub-task 类型**——层级靠 parent 关联，与 Linear/TAPD 一致，与 Jira 不同。

类型 id 获取：`GET /api/v3/types` → elements[].id/title（User story/Bug/Task/Feature/Epic）。类型映射：
| 抽象类型 | OpenProject 类型名 |
|----------|--------------------|
| story | User story |
| bug | Bug |
| task | Task |
| epic | Epic |

### 4. addComment — 添加评论

```
POST {OPENPROJECT_URL}/api/v3/work_packages/{id}/activities
Body: { "comment": { "raw": "..." } }
```

### 5. getCurrentUser — 当前用户

```
GET {OPENPROJECT_URL}/api/v3/users/me
→ { id, name, email, login }
```

**⚠️ 注意用当前 API key 所属用户，不要用父工作包经办人。**

### 6. listItems — 搜索列表

```
GET {OPENPROJECT_URL}/api/v3/work_packages?filters={urlencoded-json}&pageSize=50

filters 示例（JSON 数组，urlencode 后传入）:
[
  {"type":   {"operator": "=", "values": ["{typeId}"]}},
  {"project":{"operator": "=", "values": ["{projectId}"]}},
  {"status": {"operator": "!", "values": ["closed"]}},
  {"subject": {"operator": "~", "values": ["{keyword}"]}},
  {"parent": {"operator": "=", "values": ["{parentId}"]}}   // 查子任务
]
→ elements[]: { id, subject, status.name, _links.type.title }
```

---

## 概念差异：OpenProject 独有特性

| 特性 | 说明 | 影响 |
|------|------|------|
| 类型名不同 | Story 叫 **User story**；还有 Milestone/Summary task 特有类型 | 适配器按类型名映射 |
| 无独立子任务类型 | 层级用 parent 关联 | 与 Linear/TAPD 一致 |
| Key 格式 | 无 PROJECT-NUMBER，用数字 id | 合成 key `wp-{id}` |
| 状态流可自定义 | 默认 Scrum 14 态（New→In progress→Closed 等） | 按需精简 |
| 优先级默认 4 级 | Low/Normal/High/Immediate | 可 UI 改 P0/P1/P2 |
| 自定义类型 | UI 可加"待确认项"类型（Q-items 载体） | Q-item 用自定义类型承载 |
| 2FA 与 API | 2FA 用户密码认证禁用，**API key 仍可用** | 一律用 API key |
| Host 校验 | 配置 OPENPROJECT_HOST_NAME，Host header 不匹配报 "Invalid host_name" | 本地 curl 需匹配 host |

---

## 门禁规则

与 Jira 适配器一致：

1. **回写评论**：展示评论预览，确认后执行
2. **创建子任务**：展示预览（标题、类型、parent），确认后创建
3. **修改父工作包状态**：不做（固定边界：不修改父工作项状态）

---

## 实测记录（2026-08，OpenProject 16.6.10 自部署）

- API key 认证：`-u "apikey:{KEY}"` 有效（rails 生成的 token 无效，必须 UI 生成）
- 默认类型：Task/Milestone/Summary task/Feature/Epic/User story/Bug
- 默认状态：New(默认)/In specification/Specified/Confirmed/To be scheduled/Scheduled/In progress/Developed/In testing/Tested/Test failed/Closed/On hold/Rejected
- 默认优先级：Low/Normal(默认)/High/Immediate
