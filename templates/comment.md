# 评论协议 v1（事件流，append-only）

> 版本纪律：只增不改名

## 信封

首行：`【类型】 角色 YYYY-MM-DD`
正文：自由文本

- 前缀即类型；AI 按前缀 grep 只读所需类型
- 【】全角：不与 markdown 链接 []( ) 冲突

## Q-item 注册表

| 类型 | 语义 | 状态联动 |
|---|---|---|
| 【补充】 | 补背景/边界 | 不变 |
| 【追问】 | 回答不满足 | open |
| 【回答】 | 给结论（固定三行：结论/适用范围/生效时间） | answered |
| 【打回】 | 回答不合格 | open（结论区失效） |
| 【复核】 | 确认答案 | pending_review / done |
| 【回写确认】 | 已写回 repo | closed |

## Ticket 注册表

【契约】【阻塞】【进展】【核验】【确认】【完成】

## 派生规则

- 最新【回答】/【复核】→ 覆盖提升到 Q-item 结论区（同一代码路径原子执行）
- 【追问】/【打回】→ 结论区标记失效
- 状态字段变更必须伴随对应事件评论（双证），否则 AI 标记存疑

## 无原生评论载体（仅能力矩阵确认后启用）

description 追加，复用同一信封首行格式

## 飞书任务（已实测 2026-08-27）

- 写：`lark-cli task +comment --task-id {guid} --content "{信封}" --as user`（POST /open-apis/task/v2/comments）
- 读：`lark-cli api GET "/open-apis/task/v2/comments" --params '{"resource_id":"{guid}","resource_type":"task"}' --as user`
- 删：`lark-cli api DELETE "/open-apis/task/v2/comments/{comment_id}" --as user`
- 评论带 content/creator/created_at，AI 按 content【】前缀解析
