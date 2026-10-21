---
name: bt_todo
description: Append a phased, checkbox todo list to plan.md. Run after the annotation cycle is complete and before implementation. No arguments needed.
---

Read plan.md and add a detailed todo list at the end of the document.

The todo list should:
- Break the implementation into phases (e.g., Schema Changes, Backend, Frontend, Tests)
- List every individual task within each phase as a markdown checkbox: `- [ ] task`
- Be granular enough that each task represents ~30 minutes of focused work or less
- Follow the order of implementation (dependencies first)

Add this to plan.md under a `## Todo` heading. Do not modify the rest of the document. Do not implement anything.
