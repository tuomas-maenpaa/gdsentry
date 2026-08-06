---
description: Execute a plan that has been stored in markdown file.
auto_execution_mode: 1
---

# Execute Plan Workflow

## Workflow Goal
Execute a Markdown plan file (passed as an argument) end-to-end. Validate the plan, take the next TODO, implement the minimum necessary change, verify by inspection and/or tests, then either iterate until acceptance is satisfied or mark the item done using `|X]`. Repeat automatically for all remaining TODOs until completion or a serious-risk stop.

## Invocation
`/execute-plan <plan-filename.md>`

## High-level Behavior
1) Load the specified plan file.  
2) Run **Plan Verification** (below). If a required piece is missing, add an item under **Open Questions**, add a brief note under **Decision Log**, and **stop**.  
3) **Loop** through all TODOs automatically:
   - Treat “Phases” or “Sections” as **organizational headings only** — do **not** pause or stop between them unless a **Serious-Risk** condition is triggered.
   - Select the **first unchecked** TODO.
   - Understand intent from Context, Goal, Approach, and Plan steps.
   - Implement the **minimal** change required in the workspace/codebase.
   - **Verify** via inspection and/or available tests.
   - If acceptance is met, mark the TODO as `|X]` and append concise Execution Notes.
   - If not met, add a micro-step under the same TODO and retry. Make up to **2 micro-iterations**; if still failing or blocked, add **Blocked:** <reason> and **stop for guidance**.
   - Move automatically to the next unchecked TODO and continue.
4) Save updates back to the same plan file after each TODO completion or stop condition.
5) When all TODOs are complete, append a final **Plan fully executed** note with a timestamp under **Decision Log** and at the end of the file.  
6) On any stop condition, write a short **summary** and append a **Decision Log** line.

## Plan Verification (gate before any execution)
Confirm the following; if any fail, record the gap and stop:
- **Context & Goal** are present and specific enough to guide implementation.
- **Validation / Acceptance** section exists and is testable or inspectable.
- **Plan (Step-by-step)** is coherent.
- **TODO list** exists with at least one unchecked item.
- No critical `[TBD]` or missing details in the **next** TODO.

## Selecting the Next TODO
- Always use the **first unchecked** TODO in the plan’s TODO section.
- If the TODO references a numbered Plan step, consult that step for scope and success conditions.
- Even if TODOs are related, handle them **one at a time**; note sequencing if required.

## Implementing a TODO (minimal-change execution)
- Read relevant files/dirs mentioned in “Key changes,” “Artifacts,” or the TODO text.
- Infer language/tooling from the repository (files, manifests, tests).  
- Do **not** introduce new frameworks or patterns unless strictly necessary for acceptance.
- Keep edits **small and scoped** to the TODO’s acceptance.

## Verifying the Implementation
Use one or both:
- **Inspection**: check edited code and interfaces against acceptance criteria.
- **Tests**: run existing relevant tests or add the smallest reasonable test that demonstrates acceptance.

If acceptance fails:
- Add a concise micro-step under the same TODO and retry (up to **2** micro-iterations).
- If still failing or blocked, add **Blocked:** <reason> and stop for guidance.

## Serious-Risk / Ambiguity Stop (guidance required)
Immediately stop and add a short note under **Decision Log** and **Open Questions** if **any** of the following occur:
- Acceptance criteria or scope are **unclear** or **contradictory** for the next TODO.
- Change appears **irreversible** or **wide-ranging** beyond the plan’s intent.
- Potential **security/privacy** impact or data loss risk.
- Tests indicate **regressions** outside the TODO’s scope that cannot be quickly contained.
- Required external asset or credential is missing.

## Updating the Plan File
For each completed TODO:
- Change `[ ]` to `|X]`.
- Insert a compact **Execution Notes** block directly under that TODO:
  - Rationale (1–2 lines)
  - Files touched (paths only)
  - Verification performed (inspection and/or tests)
  - Outcome (pass/fail + brief observation)

If blocked:
- Add **Blocked:** <reason> under the TODO.
- Add a single actionable follow-up into **Open Questions**.

## Decision Log
Append one line after each **stop condition** (completion, block, or risk):
- `{{today}} – Executed TODOs: <k completed>. <blocked?/reason>. Next: "<next-todo-text>"`

## Stopping Conditions
- **All TODOs completed**, or  
- Encountered **Serious-Risk / Ambiguity** stop, or  
- A TODO remains **blocked** after micro-iterations, or  
- **Plan Verification** failed.

## Example Execution Notes Template (to insert under a TODO)
```markdown
**Execution Notes:**
- Rationale: <one-liner>
- Files: `path/a`, `path/b`
- Verification: <inspection summary and/or tests run>
- Outcome: <accepted | blocked>
```
