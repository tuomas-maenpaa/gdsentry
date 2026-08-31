---
name: gdsentry-methodology
description: >-
  GDSentry test methodology: TDD, BDD, unit/integration/E2E styles, base classes,
  harness and Godot runner commands, asserts, and thin coverage tool. Use when
  writing or reviewing GDSentry tests, choosing test types, running
  gdsentry-self-test, or measuring coverage under tools/coverage. Do not invent
  a Python gdsentry Typer CLI.
---

# GDSentry test methodology

Owned by **this repo** (hybrid B+C1). Quill (or other games) should keep thin implementation skills that **Read this file** (and `references/`) — nested skills under `.gdsentry/` may not auto-surface for files outside this folder.

Product shape: [docs/assessment/PRODUCT-SHAPE-hybrid-B-C1.md](../../docs/assessment/PRODUCT-SHAPE-hybrid-B-C1.md)

## Execution truth

| Role | Use |
|------|-----|
| Runner | `godot --script …/core/test_runner.gd` + `gdsentry-self-test` harness |
| Config | `GDTestConfig` / `framework_root` — not `gdsentry.toml` as primary |
| Coverage | [`tools/coverage/`](../../tools/coverage/) — argparse sidecar, not Typer |
| Forbidden | `pip install -e .` + `gdsentry test run` (WIP vault CLI) |

Install folders: `gdsentry/`, `.gdsentry/`, future `addons/gdsentry/` — all via `framework_paths`.

## Happy path (spine)

From GDSentry root (Quill: `…/the-quill-and-the-candle/.gdsentry`):

```bash
./gdsentry-self-test/gdsentry-self-test.sh --category core --pattern "*framework_paths*" --verbose
```

Expect 6/6; harness may materialize/cleanup standalone `project.godot`, or use host project when present.

## TDD — red → green → refactor

1. **Red:** Smallest failing test for the behavior you want  
2. **Run:** Harness (framework) or Godot runner (project tests)  
3. **Green:** Minimum change to pass  
4. **Refactor:** Clean up; re-run same command  
5. **Stop:** Target tests pass; no weakened asserts; no scope creep  

## Choosing a base / test type

| Need | Extend / use |
|------|----------------|
| Headless logic | `SceneTreeTest` (default) |
| Node in tree | `NodeTest` / GDTest node bases |
| 2D | `Node2DTest` |
| UI controls | `UITest` |
| Physics | `PhysicsTest` |
| Performance | `PerformanceTest` |
| Visual / screenshots | `VisualTest` / `VisualRegressionTest` |
| Events / input simulation | `EventTest` |
| Multi-system flows | Integration-style tests (see references) |
| Fresh project without global classes | Plain `SceneTree` + manual asserts (`tests/core/framework_paths_test.gd`) |

Conventions:

- File: `*_test.gd`  
- Avoid relying on `class_name` inside `.`-prefixed folders  
- Set `test_description`, `test_tags`, `test_priority`, `test_category`  
- Register with `run_test("name", func(): return …)` → `bool`  
- Use `assert_*` helpers  

Details: [references/test-styles.md](references/test-styles.md), [references/bdd.md](references/bdd.md)

## Commands

**Framework self-tests:**

```bash
./gdsentry-self-test/gdsentry-self-test.sh --category core --pattern "*pattern*" --verbose
```

**Project tests** (from **game** root when nested as `.gdsentry`):

```bash
godot --path . --headless --script .gdsentry/core/test_runner.gd --discover --verbose
godot --path . --headless --script .gdsentry/core/test_runner.gd --test-dir path/to/tests
```

## Coverage

See [tools/coverage/README.md](../../tools/coverage/README.md) and [references/coverage.md](references/coverage.md).

```bash
cd tools/coverage
python run_coverage.py --help
```

## Reading failures

- Intentional `push_error` on fail-path resolution tests is OK  
- Non-zero harness exit = real failure  
- Missing global classes on brand-new `project.godot`: prefer harness (FOLLOWUP F2)
