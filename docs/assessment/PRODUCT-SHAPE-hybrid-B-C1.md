# Product shape: hybrid B+C1

**Status:** Locked  
**Date:** 2026-08-11  
**Applies to:** GDSentry (this repo) and Quill agentic workflow (Cursor skills)

This note supersedes open product-shape questions in the older migration prompt. Inventory in the WIP assessment remains useful as facts; its tentative “keep `src/` / reshape CLI” labels are **not** the migration default under this lock.

---

## Decision

| Role | Owner |
|------|--------|
| Agent UX / TDD–BDD ritual | Cursor skill(s) in the Quill project (`.cursor/skills/gdsentry-tdd`) |
| Test execution | Godot + `framework_paths` + `gdsentry-self-test` harness |
| Coverage | Later thin Conda-friendly tool under `tools/coverage/` if gated in — **not** a Typer CLI product |
| Recovered laptop WIP | Archive / parts yard on `origin/wip/coverage-restructure` — **no wholesale merge** |

**One sentence:** the agent is the UX; Godot is the engine; skills are the playbook.

### Explicit answers (formerly open)

- Is the Python CLI the supported front door? **No.**
- Mega-merge `wip/coverage-restructure`? **No.**
- Big-bang `src/` layout move in this spine? **Defer** (separate epic only if needed later, still without Typer CLI).
- Skill home for Quill work? **Quill project** `.cursor/skills/` (not personal-only).

---

## Non-goals (keep clean)

- Shipping or centering the Typer/`pyproject` CLI (`gdsentry` console script) as daily UX  
- Podman / container test matrix as daily UX  
- `gdsentry.toml` as primary config (Godot `GDTestConfig` / `framework_root` remain primary)  
- Merging `trail-artifacts/`, `.windsurf/`, spike HTML, or `__pycache__` onto `main`  
- Treating plan-2.x “COMPLETE” as shipped UX  
- `addons/` + `plugin.cfg` packaging (future epic only)

---

## Relationship to prior assessment artifacts

| Artifact | Role now |
|----------|----------|
| [WIP-coverage-restructure-assessment.md](./WIP-coverage-restructure-assessment.md) | Historical inventory — facts, conflicts, buckets still valid |
| [PROMPT-migration-strategy-plan.md](./PROMPT-migration-strategy-plan.md) | **Outdated on product shape** (CLI front-door options). Do not use to re-open “CLI vs hybrid.” Inventory pointers still OK. |
| This file | Authoritative product-shape lock for B+C1 |

### Reinterpretation of assessment §5 labels

- `src/` GDScript tree: **not** default keep for this spine  
- Full `src/gdsentry/` Python package reshape: **wrong default** — leave on WIP vault  
- Coverage kernel + design plans: salvage **later**, thin tool only, after Godot+skills spine is green  
- Root-config (`framework_paths`, harness template): **keep** and mainline  

---

## Agentic workflow pointer

For Quill & Candle development, agents should load the project skill **`gdsentry-tdd`** (under the Quill repo `.cursor/skills/`). That skill points at this repo’s harness and `framework_paths`-aware runner — not at a Python CLI.

---

## Sequencing (locked)

1. Framework-root-config on `main`  
2. Align docs/CI/happy-path (Godot + harness)  
3. Quill `gdsentry-tdd` skill  
4. Coverage salvage only after an explicit gate  
5. Quill submodule pin / `project.godot` only after an explicit gate  

Never: salvage/merge WIP first.
