# GDSentry coverage thin tool

Hybrid **B+C1 sidecar**: Python instruments GDScript, Godot runs tests via `core/test_runner.gd`, reports land as terminal summary + HTML. This is **not** the WIP Typer CLI product, not a `gdsentry.toml` platform, and not Podman-based.

Salvaged from `origin/wip/coverage-restructure` (`src/gdsentry/coverage/`) into `tools/coverage/` for Gate 4 reopen. Design context: [coverage-refs](../../docs/assessment/coverage-refs/) and [GATE4-coverage-parked.md](../../docs/assessment/GATE4-coverage-parked.md).

## Requirements

- Python 3.10+ (stdlib only — no Typer, no extra pip deps for the thin path)
- Conda OK: activate any env with Python 3.10+, then run as below
- Godot 4.x on `PATH` (or `--godot-path`) for a full instrument → test → report run

## Layout

```
tools/coverage/
  run_coverage.py          # argparse CLI entry
  gdsentry_coverage/       # importable package (PYTHONPATH=tools/coverage)
  templates/               # coverage_tracker.gd (also embedded in templates.py)
  gdscript/                # analyzer + reporter (Godot-side; not auto-wired)
  tests/                   # adapted unit / GDScript tests from WIP
```

## How to run

From the GDSentry repo root (this checkout), or any project that nests `.gdsentry`:

```bash
# Conda example
conda activate <env>
cd tools/coverage

# Help
python run_coverage.py --help

# Instrument only (no Godot)
python run_coverage.py \
  --source-root ../.. \
  --output-dir ../../.coverage_out \
  --framework-root ../.. \
  --instrument-only

# Full run: instrument → godot --headless --script …/core/test_runner.gd → reports
python run_coverage.py \
  --source-root ../.. \
  --output-dir ../../.coverage_out \
  --framework-root ../.. \
  -- --discover
```

Equivalent with `PYTHONPATH`:

```bash
PYTHONPATH=tools/coverage python -c "from gdsentry_coverage import Instrumenter, CoverageConfig"
PYTHONPATH=tools/coverage python tools/coverage/run_coverage.py --help
```

Godot invocation shape (current main layout, **not** `src/core/`):

```text
godot --path <project> --headless --script <framework_root>/core/test_runner.gd [test args…]
```

Framework root is auto-detected when it contains `core/test_runner.gd` (repo root or nested `.gdsentry`).

## Inputs / outputs

| Input | Meaning |
| --- | --- |
| `--source-root` | Tree of `.gd` files to instrument |
| `--framework-root` | Directory with `core/test_runner.gd` |
| `--project-path` | Godot `--path` when not using the instrumented tree |
| env `GDSENTRY_COVERAGE=1` | Enables tracker (set by orchestrator) |
| env `GDSENTRY_COVERAGE_OUTPUT` | Where tracker writes JSON |

| Output | Location |
| --- | --- |
| Raw hits JSON | `<output-dir>/coverage_data.json` |
| Terminal summary | stdout after run |
| HTML summary | `<output-dir>/html/index.html` (thin Python page) |
| Instrumented copies | `<output-dir>/instrumented/` (removed on cleanup) |

Default `--output-dir` is `.coverage_out` (gitignored). Older WIP used `.gdsentry/coverage/`.

## Tests

Python unit tests (stdlib `unittest`, no pytest required):

```bash
cd tools/coverage && PYTHONPATH=. python -m unittest tests.test_parser tests.test_instrumenter -v
```

GDScript tests under `tests/test_coverage_*.gd` expect `res://coverage_*.gd` and are reference-only (not wired into `gdsentry-self-test` yet).

## What is stubbed / incomplete

- **Instrumented project copy** is thin: writes `project.godot` + instrumented `.gd` + tracker; does **not** full-copytree the whole framework. A full Godot run may need `--no-instrumented-project` against a real project that already has the `__coverage_tracker` autoload, or a richer prepare step later.
- **GDScript analyzer/reporter** under `gdscript/` are shipped for reference / future Godot-side wiring; the sidecar writes a **minimal Python HTML** summary instead.
- **No Typer app**, no Podman, no trail-artifacts, no WIP `pyproject` product surface.
- WIP `test_orchestrator.py` / analyzer-reporter Python integration tests were not ported (heavy Godot mocks).

## Autoload note

Instrumented calls use `__coverage_tracker.hit(...)`. The prepared `project.godot` registers:

```text
__coverage_tracker="*res://coverage_tracker.gd"
```

(WIP had a name mismatch between `CoverageTracker` autoload and `__coverage_tracker` calls; this sidecar aligns them.)
