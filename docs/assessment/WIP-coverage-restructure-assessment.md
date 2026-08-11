# Assessment: `wip/coverage-restructure`

**Assessed tip:** `9462ea1b714376a370799595b30994f4fea28345` (`9462ea1`)  
**Subject:** WIP: restructure src/tests layout and add code coverage feature  
**Date of tip:** 2026-08-06  
**Assessment written:** 2026-08-06  
**Baselines:** `origin/main` = `1ed5024`; `origin/feature/framework-root-config` = `e962180`  
**Method:** read-only inventory against remotes (no merge/rebase). Working tree at assessment time was on `feature/framework-root-config`.

This note is an **assessment only**. It does not choose a migration path. Labels under “Keep / reshape / archive / discard” are tentative inputs for a later migration-strategy plan.

---

## 1. Executive snapshot

`wip/coverage-restructure` is a **single mega-commit** (~369 paths vs `main`, ~+79k / −2.5k lines) that bundles several years-of-laptop themes into one recoverable snapshot:

1. **Layout restructure** — product GDScript moved from repo-root folders (`core/`, `base_classes/`, …) into `src/<same>/`; self-test harness relocated to `tests/framework/`.
2. **Python CLI + toolchain** — installable package via `pyproject.toml` / Conda `environment.yml`, Typer entry point `gdsentry = gdsentry.cli.app:main`, TOML project config (`gdsentry.toml`).
3. **GDScript coverage subsystem** — plans 2.1–2.5 all marked COMPLETE in prose; code under `src/gdsentry/coverage/` plus spikes still present; master UX (`gdsentry test run --coverage`) **not wired** in CLI on this tip.
4. **Infra / CI expansion** — Podman-oriented CI, compose stub, pre-commit; several referenced paths missing on tip.
5. **Process residue** — large `trail-artifacts/` (~59 files, ~1 MB), Windsurf workflows, committed coverage HTML under nested `.gdsentry/coverage/`, one `__pycache__` file.

It diverges from `feature/framework-root-config` (left-right **1 / 1**): neither branch contains the other. Root-config’s path-resolution work (`framework_paths.gd`, harness `project.godot.template`, docs) sits on **pre-move** paths that WIP renamed under `src/` and `tests/framework/`.

**What this branch “really is”:** a recovery vault for a dual-stack (GDScript framework + Python orchestrator) redesign and coverage feature, not a merge-ready PR. The commit message itself says it will likely be split before merging to `main`.

---

## 2. Layout map (main → WIP)

| On `origin/main` | On WIP tip |
|------------------|------------|
| `core/` | `src/core/` |
| `base_classes/` | `src/base_classes/` |
| `assertions/` | `src/assertions/` |
| `advanced/` | `src/advanced/` |
| `reporters/` | `src/reporters/` |
| `templates/` | `src/templates/` |
| `test_types/` | `src/test_types/` |
| `utilities/` | `src/utilities/` |
| `integration/` | `src/integration/` |
| `gdsentry-self-test/` | `tests/framework/` |
| *(absent)* | `src/gdsentry/` (Python CLI + coverage) |
| *(absent)* | `infra/`, `scripts/`, plans, spikes, `trail-artifacts/`, `pyproject.toml`, `environment.yml`, `gdsentry.toml*` |

Approx. **68** git renames with high similarity. Root product dirs are gone on tip (not dual-layout at root).

Notable deletes vs main include `TODO.md`, some example `.gd` files, and a few `utilities/` helpers.

---

## 3. Artifact buckets

| Bucket | Scale / location | Notes |
|--------|------------------|-------|
| Product GDScript | ~49 `.gd` under `src/` (excl. coverage GD) | Core framework relocated |
| Coverage GDScript | 6 `.gd` under `src/gdsentry/coverage/` | Tracker / analyzer / reporter |
| Tests | `tests/` ~101 files (~63 `.gd`); Python under `tests/unit/`, `tests/test_coverage/` | Harness = `tests/framework/` |
| Python CLI / coverage | `src/gdsentry/` ~61 `.py`; entry `gdsentry` | Subpackages: cli, coverage, ci, container, … |
| Infra / CI | `.github/`, `infra/podman-compose.yaml`, `scripts/`, `.pre-commit-config.yaml` | Missing `containers/`; bad pre-commit script paths |
| Docs | `docs/` ~62 files (Sphinx under `docs/source/`) | Some README links omit `source/` |
| Plans / spikes | `plan-2.1`…`2.5`, `plan-coverage-master`, `PLAN-2.1/2.2-COMPLETE`, spikes 1–3 | Spikes retained after “COMPLETE” |
| Trail analysis | `trail-artifacts/` 59 files | Design-process dump, not runtime |
| Nested oddities | `.gdsentry/coverage/*.html`, `.windsurf/`, `__pycache__` | Generated / IDE residue |

---

## 4. Cluster scorecards

Scoring is qualitative for migration planning inputs (not a merge decision).

### 4.1 Layout restructure

| Dimension | Assessment |
|-----------|------------|
| Intent | Clear: package-style `src/` + mirrored `tests/` |
| Maturity | Structurally consistent at tree level; path rewrites incomplete in docs/README/hooks |
| Merge risk | **High** vs root-config (directory rename + content edits) |
| Depends on | Soft dependency on Python package layout if CLI is the supported entry; GDScript can stand alone once paths are fixed |

**Tentative label:** **keep** (core value of the branch), but expect **reshape** of docs/CI/hooks and integration with root-config.

### 4.2 Coverage / Python CLI

| Dimension | Assessment |
|-----------|------------|
| Intent | Enterprise GDScript coverage + Typer CLI (`gdsentry test run`, discover, …) |
| Maturity | Plan docs all ✅ COMPLETE; modules exist; spikes remain; **`--coverage` not in CLI**; TODOs in templates/orchestrator/ci command |
| Merge risk | **Medium–high** (large new surface, Conda/pyproject, dual mental model) |
| Depends on | Layout (`src/`); orchestrator assumes Godot + instrumented sources |

**Tentative label:** **reshape** — treat as a feature epic to land in slices; do not assume “COMPLETE” means shippable UX.

### 4.3 Config surface

| Dimension | Assessment |
|-----------|------------|
| Intent | `gdsentry.toml` for project/CLI; still have Godot `GDTestConfig` heritage on GDScript side |
| Maturity | Example + default TOML present; relationship to `res://gdsentry_config.tres` / `framework_root` **undefined on WIP** (root-config not present) |
| Merge risk | **Medium** (two config worlds) |
| Depends on | CLI + layout; root-config’s `framework_root` |

**Tentative label:** **reshape** — needs an explicit coexistence story in the migration plan.

### 4.4 Infra / CI

| Dimension | Assessment |
|-----------|------------|
| Intent | Podman CI, compose, pre-commit, docs validation |
| Maturity | Partial: compose references missing `containers/`; pre-commit points at missing scripts; CI assumes `pip install -e` + `gdsentry test run` |
| Merge risk | **Medium** |
| Depends on | Python package + layout |

**Tentative label:** **reshape** (keep direction; fix/complete or drop broken pieces).

### 4.5 Trail dump / Windsurf / nested coverage HTML

| Dimension | Assessment |
|-----------|------------|
| Intent | Process archaeology / IDE helpers / local report output |
| Maturity | Useful as historical context; not product |
| Merge risk | **Low** for code, **high** for repo noise if merged as-is |
| Depends on | None |

**Tentative label:** **archive** (trail, windsurf) / **discard** from mainline history (`.gdsentry/coverage` HTML, `__pycache__`).

### 4.6 Docs (Sphinx + README)

| Dimension | Assessment |
|-----------|------------|
| Intent | Expanded Sphinx; README updated for conda/CLI |
| Maturity | Mixed; broken relative links; overlaps root-config doc edits |
| Merge risk | **Medium** (content conflicts on shared rst/README/CHANGELOG) |
| Depends on | Chosen product shape (CLI vs Godot-only) |

**Tentative label:** **reshape**.

---

## 5. Keep / reshape / archive / discard (tentative)

| Item | Label |
|------|-------|
| `src/` GDScript tree (ex-root dirs) | **keep** |
| `tests/` reorganized GDScript tests + `tests/framework/` harness | **keep** (reshape paths vs root-config harness features) |
| `src/gdsentry/` Python package | **reshape** (slice for merge) |
| Coverage plans 2.1–2.5 + master | **archive** as design refs; not merge blockers |
| Spike dirs 1–3 | **archive** or drop after extracting any unique findings |
| `trail-artifacts/` | **archive** outside mainline (or keep on WIP only) |
| `.windsurf/` | **discard** from mainline |
| `.gdsentry/coverage/` HTML | **discard** |
| `docs/source/__pycache__/` | **discard** |
| `infra/` + CI direction | **reshape** |
| Root-config work (`framework_paths`, etc.) | **keep** on its branch; **must be ported** into `src/` layout when integrating |

---

## 6. Conflict risk vs `feature/framework-root-config`

**Direct path intersection** (both touch vs `main`):  
`CHANGELOG.md`, `README.md`, `docs/source/configuration.rst`, `docs/source/getting-started.rst`, `docs/source/troubleshooting.rst`.

**Rename-collision risk (FRC paths → WIP locations):**

| FRC path | Expected WIP location |
|----------|----------------------|
| `core/framework_paths.gd` | `src/core/framework_paths.gd` (missing on WIP) |
| `templates/project.godot.template` | `src/templates/project.godot.template` |
| `gdsentry-self-test/lib/project.sh` | `tests/framework/lib/project.sh` |
| `tests/core/framework_paths_test.gd` | `tests/core/framework_paths_test.gd` (path may still apply) |
| Core/reporter edits | `src/core/*`, `src/reporters/manager/reporter_manager.gd` |

**`merge-tree` content conflicts observed (WIP ← FRC):**  
`CHANGELOG.md`, `README.md`, `docs/source/getting-started.rst`, `src/core/gdsentry.gd`, `src/core/test_runner.gd`, `src/reporters/manager/reporter_manager.gd`, `tests/framework/lib/executor.sh`.

Highest-risk integration theme: **path remap + concurrent edits** to runner / gdsentry / reporter_manager / executor.

---

## 7. Safety and testability

| Check | Result |
|-------|--------|
| Secrets in `.env.development` | None observed (Podman/Godot version flags only) |
| Large binaries | None significant |
| Documented run path | `conda env create -f environment.yml` → `pip install -e .` → `gdsentry test run` |
| Coverage UX on tip | Modules present; CLI `--coverage` **not** implemented |
| Broken references | Missing `containers/`; pre-commit script paths; README doc links; `SECURITY.md` linked but absent |

---

## 8. Hard facts for the next migration planner

1. Tips: WIP `9462ea1`, main `1ed5024`, FRC `e962180` — **divergent**, not stacked.
2. **One commit** holds all recovered work; commit message expects later split.
3. Dual stack is real: **GDScript under `src/`** + **Python Typer CLI** under `src/gdsentry/`.
4. Plan documents claim COMPLETE; **runtime UX gap** for `--coverage`.
5. Root-config **fail-fast framework root** does not exist on WIP; must be re-homed under `src/core/` if that branch merges first or second.
6. Quill parent submodule pin and game `project.godot` are **out of band** for GDSentry-internal migration.
7. Assessment artifacts for this work live under [`docs/assessment/`](./) on the current working tree (not inside WIP’s `trail-artifacts/`).

---

## 9. Open unknowns (force into migration-strategy prompt)

1. **Sequencing:** merge/rebase FRC before WIP slices, or port FRC onto WIP tip first?
2. **Product shape:** is the Python CLI the supported front door, or optional tooling beside Godot `--script` runner?
3. **Coverage epic:** land with first layout PR, defer behind layout+FRC, or park indefinitely?
4. **Config duality:** how should `gdsentry.toml` relate to `GDTestConfig` / `framework_root`?
5. **Commit hygiene:** interactive split of `9462ea1` vs forward-fix commits that cherry-pick themes?
6. **Trail/spikes:** archive repo vs orphan branch vs delete from history-bound merges?
7. **Host install story:** `.gdsentry` / `gdsentry` / `addons/gdsentry` + `src/` nesting — does self-locate need new candidates (`res://…/src`)?
8. **Verification gates:** minimum bar to call a slice “merged” (harness, pytest, conda, CI green)?

---

## 10. Related paths

- This assessment: [`docs/assessment/WIP-coverage-restructure-assessment.md`](./WIP-coverage-restructure-assessment.md)
- Prompt for next step: [`docs/assessment/PROMPT-migration-strategy-plan.md`](./PROMPT-migration-strategy-plan.md)
- Remote WIP: `origin/wip/coverage-restructure`
- Root-config: `origin/feature/framework-root-config`
