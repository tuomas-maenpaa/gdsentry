# Test styles (unit → E2E)

Prefer the **smallest** style that gives confidence.

| Style | Intent | Typical base | Notes |
|-------|--------|--------------|-------|
| Unit | One function/class in isolation | `SceneTreeTest` / `GDTest` | Fast; mock collaborators |
| Component | One node/scene behavior | `NodeTest`, `Node2DTest`, `UITest` | Real node tree slice |
| Integration | Several systems together | Integration patterns / multi-node setup | Fewer mocks; still headless when possible |
| E2E / workflow | Player-visible flow across scenes | UI + scene changes; careful with timing | Slowest; use sparingly |
| Performance | Budgets / regressions | `PerformanceTest` | Separate category tags |
| Visual | Pixels / layout | `VisualTest`, regression helpers | Needs baselines; CI cost |
| Event | Input / signals | `EventTest` | Simulate, then assert state |

## Category / tags

Use `test_category` and `test_tags` so harness filters work (`--category`, `--pattern`).

Examples: `core`, `game`, `ui`, `physics`, `meta`, `bdd`, `integration`.

## Definition tips

- Name tests by behavior, not by implementation detail  
- Fail on the first meaningful assert; return `bool` from registered callables  
- Prefer deterministic setups (fixed seeds, no wall-clock sleeps unless required)  
- For `.gdsentry` installs: load via paths/`framework_paths`, not hardcoded `res://gdsentry/` when writing new tests  

## Anti-patterns

- Inventing a Python CLI for daily runs  
- Giant E2E when a unit test would catch the bug  
- Asserts that always pass (empty bodies, ignored return values)
