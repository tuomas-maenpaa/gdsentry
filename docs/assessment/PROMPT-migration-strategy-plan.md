# Prompt artifact: migration strategy plan (do not execute migration here)

> **OUTDATED ON PRODUCT SHAPE (2026-08-11).** Hybrid **B+C1** is locked in [PRODUCT-SHAPE-hybrid-B-C1.md](./PRODUCT-SHAPE-hybrid-B-C1.md): skills + Godot/harness; Python CLI is **not** the front door; do not mega-merge `wip/coverage-restructure`. Do not use this prompt’s “CLI front door?” option matrix to reopen that decision. Inventory links and conflict facts below may still help historical planning.

**Purpose:** This file is a **prompt kit**. Paste the copy-paste block (section 7) into a new Plan-mode session so an agent can `CreatePlan` a **migration strategy with options**.  

**This file is not the migration strategy.** Do not treat tentative Keep/Reshape labels in the assessment as decided options.

**Assessment date / tips frozen for this prompt:**

| Ref | SHA (short) | Full |
|-----|-------------|------|
| WIP | `9462ea1` | `9462ea1b714376a370799595b30994f4fea28345` |
| main | `1ed5024` | `1ed5024714a35f3f8ef509a8b8b2ec343425ceab` |
| feature/framework-root-config | `e962180` | `e962180825eef6634f29e2e16272d6c249e8e870` |

If tips have moved, re-read the assessment and update SHAs before using this prompt.

**Repo:** GDSentry only (`the-quill-and-the-candle/.gdsentry` submodule → `https://github.com/tuomas-maenpaa/gdsentry`).  
**Assessment note:** [`WIP-coverage-restructure-assessment.md`](./WIP-coverage-restructure-assessment.md)

---

## 1. Context pack (for the planner)

- Recovered branch `wip/coverage-restructure` is one mega-commit: `src/` layout move, Python Typer CLI, coverage subsystem, infra/CI, plus trail/spike residue.
- Diverged from `feature/framework-root-config` (framework root auto-detect / fail-fast / harness project template). Neither contains the other.
- Plan docs 2.1–2.5 mark COMPLETE; CLI `--coverage` is **not** wired on the frozen tip.
- Dual config surfaces likely: `gdsentry.toml` (WIP) vs Godot `GDTestConfig` / `framework_root` (root-config).
- Parent Quill pin bump and game wire-up are **later, explicit** steps — out of scope for the strategy plan’s implementation phases unless listed as a future handoff.

---

## 2. Mission (what the next CreatePlan must produce)

Create a **migration strategy plan with explicit options** for integrating valuable work from `origin/wip/coverage-restructure` into GDSentry mainline, while correctly sequencing or combining `origin/feature/framework-root-config`.

The plan must compare options (trade-offs), then recommend a default **after** the comparison — not before.

---

## 3. Inputs the planner must use

Required:

1. [`docs/assessment/WIP-coverage-restructure-assessment.md`](./WIP-coverage-restructure-assessment.md) — executive snapshot, scorecards, conflicts, open unknowns
2. Remote tips above (verify with `git fetch` + `git rev-parse` if stale)
3. Root-config intent: configurable framework root, fail-fast unresolved roots, self-test host-or-standalone `project.godot` template (branch `feature/framework-root-config`)

Strongly recommended skim (on WIP tip via `git show`):

- `plan-coverage-master.md`
- `plan-2.1-python-instrumenter.md` … `plan-2.5-python-orchestrator.md` (status lines only if time-boxed)
- `pyproject.toml` entry points; `gdsentry.toml.example`
- `README.md` install/run sections on WIP vs main

Do **not** re-litigate the full trail-artifacts dump; treat it as archive-candidate unless a specific file is cited as blocking.

---

## 4. Required sections in the migration-strategy CreatePlan output

1. **Goals and non-goals**
2. **Options matrix** — at least these dimensions, with named options (not vague “maybe”):
   - Sequencing vs `feature/framework-root-config` (e.g. FRC→main first then port WIP; WIP base then port FRC; parallel topic branches)
   - Scope slices (layout-only vs layout+CLI vs layout+CLI+coverage vs archive-only extraction)
   - Commit hygiene (split mega-commit vs forward-fix theme PRs)
   - Fate of trail/spikes/HTML/`__pycache__`
3. **Trade-off table** per option (risk, effort, reversibility, verification cost)
4. **Recommended default** with rationale grounded in the assessment
5. **Phased sequence** with concrete path citations (`src/core/…`, `tests/framework/…`, etc.)
6. **Conflict handling** for known FRC↔WIP hotspots (runner, gdsentry.gd, reporter_manager, executor, docs)
7. **Config coexistence** sketch for `gdsentry.toml` vs `GDTestConfig` / `framework_root` (even if “decide later” — state the decision point)
8. **Verification gates** per phase (harness, pytest, conda, CI)
9. **Out of scope** (Quill parent pin, force-push of recovered history unless separately requested, implementing coverage in the strategy plan itself)
10. **Success criteria** for “migration strategy accepted”

---

## 5. Constraints the planner must respect

- Conda for Python environments; no Node.js; Podman not Docker
- No silent path fallbacks for framework root (root-config fail-fast semantics)
- Do not design implementation code in the strategy plan beyond naming files/phases
- Do not edit the Quill parent repo or bump the submodule pin inside the strategy plan’s execution todos
- Do not force-push rewritten recovered history unless the user separately requests it
- Attribute design decisions in repo docs as “the designer,” never a personal name
- Prefer smaller vertical slices over one big-bang merge of `9462ea1`

---

## 6. Quality bar (accept / reject the CreatePlan output)

Accept only if:

- Options are **real alternatives** with trade-offs (not a single path dressed as options)
- Recommendation comes **after** the matrix
- Open unknowns from the assessment are either resolved as plan decisions or listed as explicit user decision gates
- FRC path remap (`core/` → `src/core/`, `gdsentry-self-test/` → `tests/framework/`) is addressed
- Options remain open until after the matrix; the recommended default is argued, not assumed
- Concrete SHAs/paths cited; verification gates are testable

Reject if: only one option; ignores Python↔GDScript duality; proposes merging the entire mega-commit + trail dump to main unchanged; schedules Quill pin bump as silent side effect.

---

## 7. Copy-paste block (user message for a new Plan-mode chat)

Copy everything inside the fence below as the user query:

```text
Create a migration strategy plan (CreatePlan) with explicit options — do not implement.

Repo: GDSentry only at the-quill-and-the-candle/.gdsentry (remote https://github.com/tuomas-maenpaa/gdsentry). Do not edit the Quill parent repo or bump the submodule pin.

Frozen tips to verify first (git fetch + rev-parse):
- origin/wip/coverage-restructure = 9462ea1b714376a370799595b30994f4fea28345
- origin/main = 1ed5024714a35f3f8ef509a8b8b2ec343425ceab
- origin/feature/framework-root-config = e962180825eef6634f29e2e16272d6c249e8e870
If tips moved, note the delta; still use docs/assessment/WIP-coverage-restructure-assessment.md as the primary findings pack.

Mission: plan how to integrate valuable work from wip/coverage-restructure into GDSentry mainline, correctly sequencing or combining feature/framework-root-config. The plan MUST present an options matrix with trade-offs, THEN recommend a default. Do not smuggle a single path as the only option.

You MUST read before planning:
1) docs/assessment/WIP-coverage-restructure-assessment.md
2) docs/assessment/PROMPT-migration-strategy-plan.md (required sections + quality bar)
Skim on WIP tip as needed: plan-coverage-master.md, plan-2.1 … plan-2.5 status, pyproject.toml, gdsentry.toml.example.

Hard facts from assessment (do not rediscover from zero):
- One mega-commit (~369 files) bundling src/ layout move, Python Typer CLI, coverage stack, infra/CI, trail/spike residue
- Divergent from framework-root-config (1/1); FRC paths are pre-move (core/, gdsentry-self-test/) while WIP uses src/ and tests/framework/
- Known content conflict hotspots: CHANGELOG, README, getting-started.rst, src/core/gdsentry.gd, test_runner.gd, reporter_manager.gd, tests/framework/lib/executor.sh
- Plans 2.1–2.5 marked COMPLETE but CLI --coverage is not wired on tip
- Dual config risk: gdsentry.toml vs GDTestConfig/framework_root

Required plan sections: goals/non-goals; options matrix (sequencing vs FRC; scope slices layout/CLI/coverage; commit hygiene; fate of trail/spikes/HTML); trade-offs; recommended default after matrix; phased sequence with path citations; conflict handling; config coexistence decision points; verification gates; out of scope; success criteria.

Constraints: Conda for Python; no Node; Podman not Docker; no silent framework-root fallbacks; no force-push of recovered history unless separately requested; no implementation coding in this plan; attribute design decisions as "the designer" in any repo docs named by the plan.

Quality bar: reject single-option plans, big-bang merge of mega-commit+trail to main, or silent Quill pin bumps. Prefer vertical slices.

Deliverable: a CreatePlan migration strategy document only — not the assessment rewrite, not the prompt rewrite, not code changes.
```

---

## 8. How to use (human)

1. Ensure assessment + this prompt are visible in the working tree (commit them on a branch if you want persistence across machines).
2. Start a **new** Plan-mode chat in the Quill workspace (or GDSentry checkout).
3. Paste section 7.
4. Review the resulting CreatePlan; do not execute until you accept the recommended option.
5. Optionally ask to refresh SHAs if `wip/coverage-restructure` or FRC advanced.
