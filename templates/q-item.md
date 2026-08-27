# Q-item 模板 v1

> 版本纪律：只增不改名；schema 变更走版本头 bump

## Summary（身份，创建后冻结，skill 不改）

[Q-<编号>][<模块>][<需求标识>][<视角>] <问题一句话（≤50字）>

- 视角：BE/FE/QA/PM/通用
- 编号由 repo 未决项表统一分配，跨载体一致
- 正则：`^\[(Q-\d+)\]\[([^\]]+)\]\[([^\]]+)\]\[([^\]]+)\]\s*(.+)$`

## 字段（状态源，AI 只读这层）

- status: open | answered | pending_review | done | closed
  - answered 必须伴随【回答】评论，否则 AI 标记存疑
  - pending_review = 待复核（OpenProject 需自定义态，不与 In progress 混用）
- severity: blocker | high | normal | low   ← 唯一落点，summary 不重复
- assignee: 负责人（载体原生映射）
- 降级（无 custom_fields 载体）→ description 头 meta 块：
  `<!-- q-item-meta: status=answered; severity=high; updated=2026-08-27 -->`

## Description（冻结区；唯一例外 = 结论区）

1. 问题（不可变）：触发场景 / 为什么模糊 / 已确认边界
2. 回写锚（不可变）：回写目标（repo 文件 + 节号，如 共识-QA-m1.md §10）
3. 结论区（唯一可变区，skill 独占）：
   `<!-- 结论区(派生): 源=最新【回答】/【复核】评论；禁止人工编辑 -->`
   （空 | 最新结论；【打回】/【追问】→ 标记已失效）

## 评论（事件流）：见 comment.md（Q-item 注册表）
