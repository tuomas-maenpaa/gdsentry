---
description: Create a plan as a spec to implement something
auto_execution_mode: 3
---

# Create a plan

## Workflow Goal
Generate a complete, well-structured implementation plan in Markdown — like a lightweight specification — similar to Cursor IDE’s "Plan Mode".  
The output should be a single Markdown document named `plan-<topic>.md`.

## Behavior
When the user runs `/create-plan <short description>`, create or update a file `plan-<slugified-topic>.md` in the current workspace in phases and increments.  
Fill it with a planning template that includes context, approach, step-by-step plan, risks, and a synced TODO checklist.

## Instructions for Cascade

1. Read the user input after `/create-plan` and interpret it as the **goal** or **feature** to plan for.
2. Create a new Markdown file named `plan-<shortened-topic>.md` (for example, `plan-user-auth.md`).
3. Populate the file using the structure and formatting below.
4. Use clear Markdown, short paragraphs, and bullet lists. Prefer concise sentences.
5. If information is unknown, insert placeholders in square brackets `[like this]` for the user to fill in later.
6. At the end, include a TODO checklist reflecting the planned steps.

## Markdown Template

```markdown

# Plan for <Topic>

## 1) Context & Goal
- **Problem**: [Briefly describe what needs to be solved]
- **Goal**: [Describe desired outcome and success criteria]
- **Non-goals**: [What is explicitly out of scope]

## 2) Inputs & Constraints
- **Assumptions**: [Key assumptions]
- **Constraints**: [Technical, business, or regulatory limits]
- **Stakeholders**: [List team members or roles involved]

## 3) High-Level Approach
- **Architecture / Design Overview**:
  - [Describe core components, APIs, or modules]
- **Key changes expected**:
  - `src/...`
  - `api/...`
  - `docs/...`

## 4) Plan (Step-by-step)
1. **Discover** – Review codebase, identify integration points  
2. **Design** – Define interfaces, update schema/docs  
3. **Implement** – Add core logic, integrate components  
4. **Test** – Write and run unit/integration tests  
5. **Docs** – Update README, usage, or migration notes  
6. **Deploy & Monitor** – Release with guardrails and metrics

## 5) Risks & Mitigations
- [List potential risks and how to address them]

## 6) Validation & Acceptance
- **Test plan**: [What to verify and how]
- **Success metrics**: [Quantitative metrics, e.g. latency, error rate]
- **Observability**: [Logs, dashboards, alerts]

## 7) Open Questions
- [Any unresolved decisions or research needed]

## 8) Decision Log
- {{today}} – Initial plan created

## 9) Artifacts & References
- PRs:  
- Design docs:  
- Tickets:  

## TODO
- [ ] Confirm scope and success criteria  
- [ ] Identify affected modules and dependencies  
- [ ] Draft or update design spec  
- [ ] Implement and test core functionality  
- [ ] Write documentation and update README  
- [ ] Deploy and verify success metrics  
- [ ] Close plan after validation

```
IMPORTANT:
Create the plan in phases and increments instead of one-shotting it.
