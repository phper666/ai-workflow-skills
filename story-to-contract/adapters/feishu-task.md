# 飞书任务（Lark Tasks）适配器

## 平台标识

- 名称：飞书任务（Lark Tasks）
- 载体：任务清单（Tasklist）——**双清单约定**：`{项目名}`（ticket 载体）+ `{项目名}-q-item`（Q-items 载体）
- 工具：feishu MCP（`feishu_create_task`/`feishu_get_task`/`feishu_update_task`/`feishu_complete_task`/`feishu_list_tasks`）+ lark-cli 备选（清单/看板列操作）

## 环境变量

无（走 MCP 认证；lark-cli 路径备选：`LARK_CLI` 指向二进制）

---

## 工具映射

### 1. parseUrl — URL 解析

```
任务 URL: https://applink.feishu.cn/client/todo/detail?guid={task_guid}&suite_entity_num=t100001
清单 URL: （清单无标准 URL，用 guid）

提取: task_guid（32 位 uuid）——API 的唯一定位键
⚠️ 不要用 task_id（t100001 展示编号）做 API 定位，必须用 guid
```

### 2. readItem — 读工作项

```
feishu_get_task({ task_guid })

返回映射:
  summary           → ItemDetail.title
  description       → ItemDetail.description
  status            → ItemDetail.status（"todo"；completed 时 completed_at 非 "0"）
  completed_at      → 完成时间戳（"0" = 未完成）
  members           → ItemDetail.assignee（role=assignee 的成员）
  tasklists[].tasklist_guid → 所属清单（ticket 清单 or q-item 清单）
  tasklists[].section_guid  → 看板列（状态列）——状态流转的 API 表达
  parent_task_guid  → ItemDetail.parent（子任务）
  subtask_count     → 子任务数
  due               → 截止时间
  extra             → 附加 JSON（可承载编号等）
```

### 3. createItem — 创建工作项

```
# 基本创建
feishu_create_task({
  summary: fields.title,
  description: fields.description,
  members: [{ id: assigneeId, role: "assignee" }],
  due: ...,
})

# ⚠️ 关联清单：feishu_create_task 无 tasklist 参数 → 用 lark-cli
lark-cli task tasks create --data '{
  "summary": "...",
  "tasklists": [{ "tasklist_guid": "{清单guid}" }]
}' --as user

返回: { task_guid, task_id, url } → ItemRef { itemId: task_guid, key: task_id, url }
```

**⚠️ 清单关联是关键**——不关联清单的任务不在任何项目里；custom_fields 也必须在目标清单配置后才能写入。

### 4. addComment — 添加评论

**⚠️ 飞书任务 API 无评论能力**（实测 create/get/update 均无评论端点）。降级方案（按需选择）：

```
方案 A（推荐）: feishu_update_task({ task_guid, update_fields: ["description"], task: { description: 原描述 + "\n[评论] {作者} {时间}: {内容}" } })
方案 B: extra 字段追加 JSON 评论记录
```

适配器行为：addComment 一律走方案 A（追加到描述），并在产物中说明"飞书任务无原生评论，评论已追加至描述"。

### 5. getCurrentUser — 当前用户

```
feishu_get_user_info / feishu_get_login_status
→ { id: open_id, name }
```

### 6. listItems — 搜索列表

```
# 按清单过滤
lark-cli task tasklists tasks --data '{"tasklist_guid":"{清单guid}"}' --as user
# 或按看板列（section）过滤
lark-cli task sections tasks --params '{"section_guid":"{看板列guid}"}' --as user
# 我的任务
feishu_list_tasks({ completed: false })

→ items[]: { task_guid, task_id, summary, status, completed_at }
```

---

## 概念差异：飞书任务独有特性

| 特性 | 说明 | 影响 |
|------|------|------|
| **看板列 = section** | 状态列在 API 层是 section_guid（sections API 可增删改） | 状态流转 = 任务移动 section；状态可自定义（用户已确认 UI 可加列） |
| 原生状态二态 | status=todo / completed（completed_at 标记） | 中间态用 section（看板列）表达 |
| **无评论** | API 无评论端点 | addComment 降级：描述追加（方案 A） |
| **custom_fields 依赖清单配置** | 字段必须先在清单 UI 创建，才能写入 | 创建任务前确认清单已配字段（优先级/类型/规则编号） |
| 双清单约定 | {项目名} + {项目名}-q-item | ticket 与 Q-items 分清单管理 |
| guid 是唯一定位键 | task_id（t100001）是展示编号 | 一律用 guid |
| 子任务 | parent_task_guid 关联 | 与 OpenProject/Linear 一致 |
| 清单成员 | tasklists add_members/remove_members | 权限：q-item 清单可只给相关角色 |

---

## 门禁规则

与 Jira 适配器一致：

1. **回写评论**：展示追加内容预览，确认后执行（注意：飞书是"描述追加"不是真评论）
2. **创建任务**：展示预览（标题、清单、类型字段），确认后创建
3. **修改父任务状态**：不做（固定边界：不修改父工作项状态）
4. **清单/看板列操作**：创建清单、加列是配置性操作，涉及用户界面结构变更，需用户确认

---

## 实测记录（2026-08，lark-cli 1.0.86 / feishu MCP）

- 清单创建：`task tasklists create --data {"name":"..."}` ✅（guid 返回）
- 任务创建 + 清单关联：`task tasks create --data {"tasklists":[{"tasklist_guid":"..."}]}` ✅
- 任务读取：`feishu_get_task` ✅（含 tasklists[].section_guid）
- custom_fields：API 支持，但**字段必须先在清单 UI 创建**（未配置时报 field validation failed）
- 看板列：`task sections` 子命令（create/delete/get/list/patch/tasks）✅
- 评论：API 无评论端点（实测确认）→ 降级描述追加
- 删除：需要确认流程（requires confirmation）
- 双清单实测：`冒烟测试-tickets` + `冒烟测试-q-item` 创建成功
