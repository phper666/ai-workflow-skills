# 飞书任务（Lark Tasks）适配器

## 平台标识

- 名称：飞书任务（Lark Tasks）
- 载体：任务清单（Tasklist）——**双清单约定**：`{项目名}`（ticket 载体）+ `{项目名}-q-item`（Q-items 载体）
- 工具：feishu MCP（`feishu_create_task`/`feishu_get_task`/`feishu_update_task`/`feishu_complete_task`/`feishu_list_tasks`）+ lark-cli 备选（清单/看板列操作）

## 环境变量

无（走 MCP 认证；lark-cli 路径备选：`LARK_CLI` 指向二进制）

## 授权（lark-cli user 身份，实测流程 2026-08）

```
1. 生成授权链接（10 分钟有效，scope 一次给全）：
   lark-cli auth login --scope "task:custom_field:write task:tasklist:write task:section:write task:task:write" --no-wait --json
   → 取 verification_url + device_code

2. 用户打开 verification_url 点"同意授权"

3. 完成轮询（⚠️ timeout 必须 ≥600s，用户授权在轮询期间完成）：
   lark-cli auth login --device-code {device_code}

4. 轮询输出 "OK: 授权成功!" 即生效——⚠️ 之后 auth status 可能仍显示 token None/scope 0（显示层异常，实测如此），
   以实际 API 调用为准（custom_fields create 成功 = 授权有效）
```

⚠️ 常见失败：轮询 timeout 太短被杀（用户授权晚于轮询结束）；device_code 与链接不匹配（多次生成导致用户开错链接）；"本次新授予 scopes 为空"是正常的（之前已授予过）。

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

# 带 custom_fields 创建（字段须先在该清单创建，格式：guid + 选项 guid）
lark-cli task tasks create --data '{
  "summary": "...",
  "tasklists": [{ "tasklist_guid": "{清单guid}" }],
  "custom_fields": [
    { "guid": "{字段guid}", "single_select_value": "{选项guid}" },
    { "guid": "{字段guid}", "text_value": "CON-R001" }
  ]
}' --as user

返回: { task_guid, task_id, url } → ItemRef { itemId: task_guid, key: task_id, url }
```

**⚠️ custom_fields 正确格式（实测 2026-08）**：
- 用 `guid` 引用字段（不是 field_name），单选值用 **选项的 guid**（不是选项名）——用选项名报 "isn't a visible option"
- 字段必须先在该清单创建（`custom_fields create`，resource_type=tasklist + resource_id=清单guid）
- 创建字段时选项返回 guid（`single_select_setting.options[].guid`）——保存映射：字段名→guid、选项名→guid

**⚠️ 清单关联是关键**——不关联清单的任务不在任何项目里；custom_fields 也必须在目标清单配置后才能写入。

### 4. addComment — 添加评论

**✅ 飞书任务支持原生评论**（实测 2026-08-27，POST/GET/DELETE /open-apis/task/v2/comments）：

```
# 写评论
lark-cli task +comment --task-id {guid} --content "{body}" --as user
# 读评论
lark-cli api GET "/open-apis/task/v2/comments" --params '{"resource_id":"{guid}","resource_type":"task"}' --as user
# 删评论
lark-cli api DELETE "/open-apis/task/v2/comments/{comment_id}" --as user
```

- 评论带 content/creator/created_at，AI 按 content【】前缀解析（信封格式见 `templates/comment.md`）
- 不再降级描述追加

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
| **原生评论** | API 支持写/读/删评论（POST/GET/DELETE /open-apis/task/v2/comments） | addComment 走 lark-cli 评论命令，不降级描述追加 |
| **custom_fields 依赖清单配置** | 字段必须先在清单 UI 创建，才能写入 | 创建任务前确认清单已配字段（优先级/类型/规则编号） |
| 双清单约定 | {项目名} + {项目名}-q-item | ticket 与 Q-items 分清单管理 |
| guid 是唯一定位键 | task_id（t100001）是展示编号 | 一律用 guid |
| 子任务 | parent_task_guid 关联 | 与 OpenProject/Linear 一致 |
| 清单成员 | tasklists add_members/remove_members | 权限：q-item 清单可只给相关角色 |

---

## 门禁规则

与 Jira 适配器一致：

1. **回写评论**：展示评论内容预览，确认后执行（lark-cli 原生评论）
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
- 评论：原生评论端点实测可用（写/读/删，/open-apis/task/v2/comments）✅
- 删除：需要确认流程（requires confirmation）
- 双清单实测：`冒烟测试-tickets` + `冒烟测试-q-item` 创建成功
