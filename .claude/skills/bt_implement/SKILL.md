---
name: bt_implement
description: Execute the full plan in plan.md phase by phase, marking tasks complete as they finish. Run only after plan.md is finalized and has a todo list. No arguments needed.
---

Read plan.md and implement everything in it. Follow the todo list in the plan phase by phase, task by task.

Rules:
- When you complete a task, mark it as completed in plan.md: change `- [ ]` to `- [x]`
- Do not stop until every task and phase is marked complete
- Do not add comments that merely restate the obvious. Use comments to explain the purpose of components at a higher level than the code.
- Do not ask for confirmation mid-implementation — keep going
- Do not deviate from the plan; if you discover a problem, note it in the plan and continue

The plan is the source of truth. Execute it completely.
