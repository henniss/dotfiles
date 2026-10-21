---
name: bt_plan
description: Generate an implementation plan in plan.md for a described feature. Reads the codebase first; does not write any code. Takes a feature description as argument.
---

I want to build: $ARGUMENTS

Before writing the plan, read all relevant source files. Base the plan entirely on the actual codebase — not assumptions. If a research.md exists in this directory, read it first.

Write a plan.md document that includes:
- A clear description of the approach
- If any new schemas or data models are needed, include them. If existing schemas or data models need be updated, describe these changes.
- Considerations, trade-offs, and alternatives you rejected
- Any risks or dependencies to be aware of
- Each file that will be modified or created, with the required changes described.

Do not forget my preference: avoid unpronouncible slugs in the middle of prose. 

Do not implement anything. Write the plan only.
