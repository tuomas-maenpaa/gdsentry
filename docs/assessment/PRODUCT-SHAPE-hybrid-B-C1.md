# Product shape: hybrid B+C1

**Status:** Locked (retro gate pass 2026-08-31)  
**Applies to:** GDSentry (this repo) and Quill agentic workflow (Cursor skills)

This note supersedes open product-shape questions in the older migration prompt. Inventory in the WIP assessment remains useful as facts; its tentative “keep `src/` / reshape CLI” labels are **not** the migration default under this lock.

---

## Decision

| Role | Owner |
|------|--------|
| Test methodology (TDD, BDD, integration, E2E, styles, harness, asserts) | **This repo:** `.cursor/skills/gdsentry-methodology/` |
| Quill implementation / verify | **Quill:** `.cursor/skills/` — thin skills that **Read** GDSentry methodology paths |
| Test execution | Godot + `framework_paths` + `gdsentry-self-test` harness |
| Coverage | Thin Conda-friendly sidecar: [`tools/coverage/`](../../tools/coverage/) — **not** a Typer CLI product |
| Recovered laptop WIP | Archive / parts yard on `origin/wip/coverage-restructure` — **no wholesale merge** |

**One sentence:** the agent is the UX; Godot is the engine; skills are the playbook (methodology in GDSentry, game implement skills in Quill with hard pointers).

### Explicit answers

- Is the Python CLI the supported front door? **No.**
- Mega-merge `wip/coverage-restructure`? **No.**
- Big-bang `src/` layout move in this spine? **Defer.**
- Skill ownership? **Methodology in `.gdsentry`; Quill does not own the thick TDD playbook.**
- Nested skill auto-scope? **Accepted limitation** — Quill skills must `Read` / `/` invoke GDSentry skill paths (soft composition).

---

## Non-goals (keep clean)

- Shipping or centering the Typer/`pyproject` CLI as daily UX  
- Podman / container test matrix as daily UX  
- `gdsentry.toml` as primary config (Godot `GDTestConfig` / `framework_root` remain primary)  
- Merging `trail-artifacts/`, `.windsurf/`, spike HTML, or `__pycache__` onto `main`  
- Treating plan-2.x “COMPLETE” as shipped UX  
- `addons/` + `plugin.cfg` packaging (future epic only)  
- Native Cursor “aggregate submodule skills into parent” (not supported — use pointers)

---

## Relationship to prior assessment artifacts

| Artifact | Role now |
|----------|----------|
| [WIP-coverage-restructure-assessment.md](./WIP-coverage-restructure-assessment.md) | Historical inventory |
| [PROMPT-migration-strategy-plan.md](./PROMPT-migration-strategy-plan.md) | Outdated on product shape |
| [GATE4-coverage-parked.md](./GATE4-coverage-parked.md) | Superseded — coverage salvage **started** (see Gate 4 reopen) |
| This file | Authoritative product-shape lock |

---

## Agentic workflow

1. In Quill: use Quill implementation skill(s) for how to build/verify game work.  
2. Those skills instruct: **Read** `.gdsentry/.cursor/skills/gdsentry-methodology/SKILL.md` (and references) before writing/running tests.  
3. Runner remains Godot + harness — never invent `gdsentry test run` / pip CLI.  
4. Coverage: see `tools/coverage/README.md` when measuring coverage.

---

## Sequencing (done / in flight)

1. Framework-root-config on `main` — done  
2. Align docs/CI/happy-path — done  
3. Methodology skill in GDSentry + thin Quill pointer — this batch  
4. Coverage salvage into `tools/coverage/` — this batch  
5. Quill submodule pin / `project.godot` — done (Gate 5 keep)
