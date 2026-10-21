---
name: bt_research
description: Deep-read a codebase target and write findings to research.md. Use before planning any changes. Takes a path or description as argument.
---

Research a codebase. $ARGUMENTS. Understand how the specified parts work deeply — its structure, what it does, all its specificities, edge cases, and intricacies. Do not skim. Read every relevant file and follow every important code path.

When you are done, write a detailed report of your learnings and findings in research.md. The report should include:
- A high-level summary of what the system does
- The patterns, conventions, and idioms of the codebase.
- An enumeration of the major componets and their responsibilities. 
- Key data flows and how components interact
- Any bugs, inconsistencies, or surprising behavior you found. Especially highlight any cases where documentation or comments disagree with the code.

Avoid code snippets, and especially do not include large code snippets. The code itself should remain source of truth for these, not research.md. 

Do not suggest changes. Do not write any code. Research and document only.
